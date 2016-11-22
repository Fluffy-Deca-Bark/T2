-- PROCEDURES

/**********************************************************************
*	PROCEDURE:
*		CriarProva
*	DESCRIÇÃO:
*   	Cria uma prova
*	PARÂMETROS:
*		pMod		- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexo	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDist		- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pData1		- ENTRADA	- DATA
*			Data da etapa eliminatória
*		pData2		- ENTRADA	- DATA
*			Data da etapa semifinal
*		pData3		- ENTRADA	- DATA
*			Data da etapa final	
**********************************************************************/
create or replace procedure CriarProva	(pMod in integer, pSexo in char, pDist in number,					-- COMPLETAR/TESTAR
										pData1 in date, pData2 in date, pData3 in date)
as
begin
	if pData1 = pData2 or pData1 = pData3 or pData2 = pData3 or pData1 > pData2 or pData2 > pData3 then
		-- fail
	end if
	insert into Prova(NumMod,Sexo,Dist)
		values (pMod,pSexo,pDist);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values	(pMod,pDist,pSexo,pData1);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values  (pMod,pDist,pSexo,pData2);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values  (pMod,pDist,pSexo,pData3);
end CriarProva;
/

/**********************************************************************
*	PROCEDURE:
*		CriarSeries
*	DESCRIÇÃO:
*   	Cria séries necessárias pra realizção de uma prova, segundo a
*		quantidade de particpantes selecionados
*	PARÂMETROS:
*		pModProva			- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva			- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva			- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pNumParticipantes	- ENTRADA	- NÚMERO
*			Número de participantes total que participará na prova
*														(de 0 a 64)
**********************************************************************/
create or replace procedure CriarSeries	(pModProva in integer, pSexoProva in char, pDistProva in number, 				-- RETESTAR
										pNumParticipantes in integer)
as
	numSeries integer;
begin
	numSeries := ceil(pNumParticipantes / 8);
	for i in 1..numSeries loop
		insert into Serie(NumMod,SexoProva,DistProva,Etapa,Seq,Status)
			values(pModProva,pSexoProva,pDistProva,1,i,0);
	end loop;
	if numSeries > 4 then
		numSeries := 4;
	end if;
	for i in 1..numSeries loop
		insert into Serie(NumMod,SexoProva,DistProva,Etapa,Seq,Status)
			values(pModProva,pSexoProva,pDistProva,2,i,0);
	end loop;
	insert into Serie(NumMod,SexoProva,DistProva,Etapa,Seq,Status)
		values(pModProva,pSexoProva,pDistProva,3,1,0);
end CriarSeries;
/

/**********************************************************************
*	PROCEDURE:
*		AlocarParticipantesSelecionados
*	DESCRIÇÃO:
*   	Coloca participantes selecionados em uma prova em séries e
*		raias aleatórias da etapa semifinal.
*	PARÂMETROS:
*		pModProva			- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva			- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva			- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pNumParticipantes	- ENTRADA	- NÚMERO
*			Número de participantes total que participará na prova
*														(de 0 a 64)
**********************************************************************/
create or replace procedure AlocarParticipantesSelecionados	(pModProva in integer, pSexoProva in char,				-- TESTAR
															pDistProva in number, pNumParticipantes in integer)
as
	numSeries integer;
	numRaiasExtras integer; -- Número de raias que serão usadas na última série
	raiaLimite integer;
	rSeed  BINARY_INTEGER;
	linhaInscrito Inscrito%rowtype;
	raiaRNG integer;
	serieRNG integer;
	linhaRNG integer;
	linhasRestantes integer;
	
	cursor cursorInscrito
		is
		select *
		from Inscrito;
begin
	rSeed := := TO_NUMBER(TO_CHAR(SYSDATE,'YYYYDDMMSS'));
	dbms_random.initialize(val => rSeed);
	
	numSeries := ceil(pNumParticipantes / 8);
	numRaiasExtras := pNumParticipantes % 8;
	if numRaiasExtras = 0 then -- Se a divisão é exata a última série possui 8 raias
		numRaiasExtras := 8;
	end if;
	
	create table RaiasAAlocar (
		Ident		number(2)	primary key,
		SeqSerie	number(1)	not null,
		NumRaia		number(1)	not null
	);
	
	for percorreSeries in 1..numSeries loop
		if percorreSeries = numSeries then -- última série -> preenchem-se algumas raias
			raiaLimite := numRaiasExtras;
		else -- primeiras séries -> preenchem-se todas as raias
			raiaLimite := 8;
		end if;
		
		for percorreRaias in 1..raiaLimite loop
			insert into RaiasAAlocar(Ident,SeqSerie,NumRaia)
				values((percorreSeries-1)*8+percorreRaias,percorreSeries,percorreRaias);
		end loop;
	end loop;
	
	linhasRestantes := pNumParticipantes;
	open cursorInscrito;
	loop
		fetch cursorInscrito into linhaInscrito;
		exit when cursorInscrito%notfound;
		
		if linhaInscrito.Aprovado = 'S' then
			linhaRNG := floor(dbms_random.value(1,linhasRestantes+1));
			select SeqSerie into serieRNG, NumRaia into raiaRNG
			from RaiasAAlocar casoATestar
			where linhaRNG-1 =	(select count(*) as qtdMenores
								from RaiasAAlocar
								where Ident < casoATestar.Ident);
			insert into Participa(NumInscr,NumMod,SexoProva,DistProva,EtapaSerie,SeqSerie,Tempo,Situacao,Raia)
				values(linhaInscrito.NumInscr,pModProva,pSexoProva,pDistProva,1,serieRNG,NULL,NULL,raiaRNG)
			delete from RaiasAAlocar
				where	SeqSerie = serieRNG,
						NumRaia = raiaRNG;
			linhasRestantes := linhasRestantes - 1;
		end if;
	end loop;
	close cursorInscrito;
	
	drop table RaiasAAlocar;
	
	dbms_random.terminate;
end AlocarParticipantesSelecionados;
/

/**********************************************************************
*	PROCEDURE:
*		FinalizarInscricoes
*	DESCRIÇÃO:
*   	Finaliza as inscrições de uma prova, impedindo inscrição
*		futura nela, selecionando os participantes, criando
*		automaticamente todas suas séries e alocando cada participante
*		em uma raia da etapa eliminatória.
*	PARÂMETROS:
*		pModProva			- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva			- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva			- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
**********************************************************************/
create or replace procedure FinalizarInscricoes (pModProva in integer, pSexoProva in char,					-- COMPLETAR/TESTAR
																	pDistProva in number)
as
	numSelecionados integer;
begin
	-- FECHAR INSCRIÇÕES
	numSelecionados := SelecionarParticipantes(pModProva,pSexoProva,pDistProva);
	if numSelecionados != 0 then
		CriarSeries(pModProva,pSexoProva,pDistProva,numSelecionados);
		AlocarParticipantesSelecionados(pModProva,pSexoProva,pDistProva,numSelecionados);
	end if;
end;
/

/**********************************************************************
*	PROCEDURE:
*		AdicionarPatrocinio
*	DESCRIÇÃO:
*   	Cadastra um patrocinador de um competidor
*	PARÂMETROS:
*		pNumInscr	- ENTRADA	- INTEIRO
*			Número de inscrição do competidor
*		pPatroc		- ENTRADA	- STRING
*			Nome do patrocinador
**********************************************************************/
create or replace procedure AdicionarPatrocinio (pNumInscr in integer, pPatroc in varchar2)
as
begin
	insert into Patrocinado(NumInscr,Patrocinador)
		values(pNumInscr,pPatroc);
end;
/

/**********************************************************************
*	PROCEDURE:
*		FazerInscricao
*	DESCRIÇÃO:
*   	Inscreve um competidor numa prova
*	PARÂMETROS:
*		pNumInscr	- ENTRADA	- INTEIRO
*			Número de inscrição do competidor
*		pModProva			- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva			- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva			- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pMelhorTempo		- ENTRADA	- NÚMERO
*			Melhor tempo de nado do competidor em categoria similar
*									em torneio antecedente, em segundos
*		pNomeTorneio		- ENTRADA	- STRING
*			Nome do torneio onde foi atingido melhor tempo pessoal
*		pLocalTorneio		- ENTRADA	- STRING
*			Nome do local onde torneio supracitado foi realizado
*		pDataTorneio		- ENTRADA	- DATA
*			Data de ocorrência de torneio supracitado
**********************************************************************/
create or replace procedure FazerInscricao (pNumInscr in integer, pModProva in integer,
					pSexoProva in char, pDistProva in number, pMelhorTempo in number,
		pNomeTorneio in varchar2, pLocalTorneio in varchar2, pDataTorneio in varchar2)
as
begin
	insert into Inscrito(NumInscr,NumMod,SexoProva,DistProva,MelhorTempo,NomeTorneio,
													LocalTorneio,DataTorneio,Aprovado)
		values(pNumInscr,pModProva,pSexoProva,pDistProva,pMelhorTempo,pNomeTorneio,
													pLocalTorneio,pDataTorneio,'N');
end;
/

/**********************************************************************
*	PROCEDURE:
*		CadastrarTempo
*	DESCRIÇÃO:
*   	Cadastra (ou substitui) o tempo de nado de um competidor que
*		realizou (e completou) uma série em uma etapa da prova. Isso
*		automaticamente cadastra a participação do competidor na série
*		como "CONCLUÍDA". Não funciona se a série já foi dada como
*														"executada".
*	PARÂMETROS:
*		pNumInscr	- ENTRADA	- INTEIRO
*			Número de inscrição do competidor
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pEtapaSerie	- ENTRADA	- INTEIRO
*			Número de 1 a 3 que representa a etapa da prova
*							(1- eliminatória, 2- semifinal, 3- final)
*		pTempo		- ENTRADA	- NÚMERO
*			Número que representa tempo de conclusão da série de nado
*			do competidor, em segundos. 
**********************************************************************/
create or replace procedure CadastrarTempo (pNumInscr in integer, pModProva in integer,
	pSexoProva in char, pDistProva in number, pEtapaSerie in integer, pTempo in number)
as
	sequenciaSerie integer;
	statusSerie integer;
	linhasAtualizadas integer;
begin
	select SeqSerie into sequenciaSerie
	from Participa
	where	NumInscr = PNumInscr and
			NumMod = pModProva and
			SexoProva = pSexoProva and
			DistProva = pDistProva and
			EtapaSerie = pEtapaSerie;
	select status into statusSerie
	from Serie
	where	NumMod = pModProva and
			SexoProva = pSexoProva and
			DistProva = pDistProva and
			Etapa = pEtapaSerie and
			Seq = sequenciaSerie;
	if statusSerie = 1 then -- Série já foi executada
		-- FAIL
	end if;
	
	update Participa
		set Situacao = 1, Tempo = pTempo
		where	NumInscr = PNumInscr and
				NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				EtapaSerie = pEtapaSerie;
	
	linhasAtualizadas := sql%rowcount;
	if linhasAtualizadas = 0 then
		-- FAIL
	end if;
end;
/

/**********************************************************************
*	PROCEDURE:
*		CadastrarSituacao
*	DESCRIÇÃO:
*   	Cadastra (ou substitui) a participação de um competidor numa
*		série de uma etapa de uma prova como "NULO" (ainda indefinida),
*		"DESCLASSIFICADO" ou "AUSENTE" (Para cadastrar como concluída,
*		deve-se usar a procedure "CadastrarTempo"). Não funciona se a
*		série já foi dada como "executada".
*	PARÂMETROS:
*		pNumInscr	- ENTRADA	- INTEIRO
*			Número de inscrição do competidor
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pEtapaSerie	- ENTRADA	- INTEIRO
*			Número de 1 a 3 que representa a etapa da prova
*							(1- eliminatória, 2- semifinal, 3- final)
*		pSituacao	- ENTRADA	- INTEIRO
*			Número que representa nova situação do competidor:
*			0- NULO, 1- DESCLASSIFICADO, 2- AUSENTE
**********************************************************************/
create or replace procedure CadastrarSituacao (pNumInscr in integer, pModProva in integer,
	pSexoProva in char, pDistProva in number, pEtapaSerie in integer, pSituacao in integer)
as
	sequenciaSerie integer;
	statusSerie integer;
	linhasAtualizadas integer;
begin
	select SeqSerie into sequenciaSerie
	from Participa
	where	NumInscr = PNumInscr and
			NumMod = pModProva and
			SexoProva = pSexoProva and
			DistProva = pDistProva and
			EtapaSerie = pEtapaSerie;
	select status into statusSerie
	from Serie
	where	NumMod = pModProva and
			SexoProva = pSexoProva and
			DistProva = pDistProva and
			Etapa = pEtapaSerie and
			Seq = sequenciaSerie;
	if statusSerie = 1 then -- Série já foi executada
		-- FAIL
	end if;
	
	if pSituacao = 0 then
		update Participa
			set Situacao = NULL, Tempo = NULL
			where	NumInscr = PNumInscr and
					NumMod = pModProva and
					SexoProva = pSexoProva and
					DistProva = pDistProva and
					EtapaSerie = pEtapaSerie;
	else
		if pSituacao = 1 or pSituacao = 2 then
			update Participa
				set Situacao = pSituacao+1, Tempo = NULL
				where	NumInscr = PNumInscr and
						NumMod = pModProva and
						SexoProva = pSexoProva and
						DistProva = pDistProva and
						EtapaSerie = pEtapaSerie;
		else -- pSituacao passada é inválida!
			-- FAIL
		end if;
	end if;
				
	linhasAtualizadas := sql%rowcount;
	if linhasAtualizadas = 0 then
		-- FAIL
	end if;
end;
/
