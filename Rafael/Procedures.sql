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
create or replace procedure CriarProva	(pMod in integer, pSexo in char, pDist in number,
										pData1 in date, pData2 in date, pData3 in date)
as
begin
	insert into Prova(NumMod,Sexo,Dist)
		values (pMod,pSexo,pDist);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values	(pMod,pDist,pSexo,pData1),
				(pMod,pDist,pSexo,pData2),
				(pMod,pDist,pSexo,pData3);
end CriarProva;

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
create or replace procedure CriarSeries	(pModProva in integer, pSexoProva in char, pDistProva in number,
										pNumParticipantes in integer)
as
	numSeries integer;
begin
	numSeries := ceil(pNumParticipantes / 8);
	for i in 1..numSeries loop
		insert into Serie(NumMod,SexoProva,DistProva,Etapa,Seq,Status)
			values(pModProva,pSexoProva,pDistProva,1,i,0);
	end loop;
end CriarSeries;

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
create or replace procedure AlocarParticipantesSelecionados	(pModProva in integer, pSexoProva in char,
															pDistProva in number, pNumParticipantes in integer)
as
	numSeries integer;
	numRaiasExtras integer; -- Número de raias que serão usadas na última série
	raiaLimite integer;
begin
	dbms_random.initialize;
	
	numSeries := ceil(pNumParticipantes / 8);
	numRaiasExtras := pNumParticipantes % 8;
	if numRaiasExtras = 0 then -- Se a divisão é exata a última série possui 8 raias
		numRaiasExtras := 8;
	end if;
	
	create table RaiasAAlocar (
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
			insert into RaiasAAlocar(SeqSerie,NumRaia)
				values(percorreSeries,percorreRaias);
		end loop;
	end loop;
	
	-- Completar
	
	floor(select dbms_random.value(1,numRaiasExtras+1) from dual);
	dbms_random.terminate;
end AlocarParticipantesSelecionados;
