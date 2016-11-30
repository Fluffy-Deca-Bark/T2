-- PROCEDURES

/**********************************************************************
*   PROCEDURE:
*       AbrirInscricoes
*   DESCRIÇÃO:
*       Abre as inscrições em todas as prova, permitindo a inscrição de
*		competidores nelas. Não funciona caso inscrições já tenham sido
*		anteriormente abertas e fechadas.
**********************************************************************/
create or replace procedure AbrirInscricoes               											  -- TESTAR
as
	inscricoes 		integer;
begin
	select Valor into inscricoes
		from Globais
		where Nome = 'inscricoes';
	if inscricoes = 1 then
		raise_application_error(-20010,'As inscrições já foram abertas!');
	end if;
	if inscricoes = 0 then
		raise_application_error(-20011,'As inscrições já foram finalizadas! Não podem ser reabertas!');
	end if;
	if inscricoes != -1 then
		raise_application_error(-20012,'Erro desconhecido: Configuração "inscricoes" com valor inválido');
	end if;
	
	update Globais
		set Valor = 1
		where Nome = 'inscricoes';
end AbrirInscricoes;
/
 
/**********************************************************************
*   PROCEDURE:
*       CriarProva
*   DESCRIÇÃO:
*       Cria uma prova. Falha se datas passadas não seguirem requisitos:
*       Datas das etapas devem ser diferentes. Data da eliminatória é
*       predecessora da semifinal que vem antes da etapa final. 
*   PARÂMETROS:
*       pMod        - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexo   - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDist       - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pData1      - ENTRADA   - DATA
*           Data da etapa eliminatória
*       pData2      - ENTRADA   - DATA
*           Data da etapa semifinal
*       pData3      - ENTRADA   - DATA
*           Data da etapa final 
**********************************************************************/
create or replace procedure CriarProva  (pMod in integer, pSexo in char, pDist in number,                   -- TESTADO
                                        pData1 in date, pData2 in date, pData3 in date)
as
begin
    if pData1 = pData2 or pData1 = pData3 or pData2 = pData3 or pData1 > pData2 or pData2 > pData3 then
        raise_application_error(-20001,'Datas de etapas inválidas');
    end if;
    insert into Prova(NumMod,Sexo,Dist)
        values (pMod,pSexo,pDist);
    insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
        values  (pMod,pDist,pSexo,pData1);
    insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
        values  (pMod,pDist,pSexo,pData2);
    insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
        values  (pMod,pDist,pSexo,pData3);
end CriarProva;
/
 
/**********************************************************************
*   PROCEDURE:
*       AdicionarPatrocinio
*   DESCRIÇÃO:
*       Cadastra um patrocinador de um competidor
*   PARÂMETROS:
*       pNumInscr   - ENTRADA   - INTEIRO
*           Número de inscrição do competidor
*       pPatroc     - ENTRADA   - STRING
*           Nome do patrocinador
**********************************************************************/
create or replace procedure AdicionarPatrocinio (pNumInscr in integer, pPatroc in varchar2)		-- TESTADO
as
begin
    insert into Patrocinado(NumInscr,Patrocinador)
        values(pNumInscr,pPatroc);
end;
/
 
/**********************************************************************
*   PROCEDURE:
*       FazerInscricao
*   DESCRIÇÃO:
*       Inscreve um competidor numa prova.
*		Não funciona se inscrições estiverem finalizadas.
*   PARÂMETROS:
*       pNumInscr   - ENTRADA   - INTEIRO
*           Número de inscrição do competidor
*       pModProva           - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva          - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva          - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pMelhorTempo        - ENTRADA   - NÚMERO
*           Melhor tempo de nado do competidor em categoria similar
*                                   em torneio antecedente, em segundos
*       pNomeTorneio        - ENTRADA   - STRING
*           Nome do torneio onde foi atingido melhor tempo pessoal
*       pLocalTorneio       - ENTRADA   - STRING
*           Nome do local onde torneio supracitado foi realizado
*       pDataTorneio        - ENTRADA   - DATA
*           Data de ocorrência de torneio supracitado
**********************************************************************/
create or replace procedure FazerInscricao (pNumInscr in integer, pModProva in integer,         -- RETESTAR
                    pSexoProva in char, pDistProva in number, pMelhorTempo in number,
        pNomeTorneio in varchar2, pLocalTorneio in varchar2, pDataTorneio in varchar2)
as
	inscricoes integer;
begin
	select Valor into inscricoes
		from Globais
		where Nome = 'inscricoes';
	if inscricoes = 0 then
		raise_application_error(-20007,'A inscrição não pôde ser feita porque as inscrições já foram finalizadas');
	end if;
	if inscricoes = -1 then
		raise_application_error(-20013,'A inscrição não pôde ser feita porque as inscrições ainda não foram abertas');
	end if;
	if inscricoes != 1 then
		raise_application_error(-20014,'Erro desconhecido: Configuração "inscricoes" com valor inválido');
	end if;
    insert into Inscrito(NumInscr,NumMod,SexoProva,DistProva,MelhorTempo,NomeTorneio,
                                                    LocalTorneio,DataTorneio,Aprovado)
        values(pNumInscr,pModProva,pSexoProva,pDistProva,pMelhorTempo,pNomeTorneio,
                                                    pLocalTorneio,pDataTorneio,'N');
end;
/
 
/**********************************************************************
*   PROCEDURE:
*       CriarSeries
*   DESCRIÇÃO:
*       Cria séries necessárias pra realizção de uma prova, segundo a
*       quantidade de participantes selecionados (estritamente positivo)
*   PARÂMETROS:
*       pModProva           - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva          - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva          - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pNumParticipantes   - ENTRADA   - NÚMERO
*           Número de participantes total que participará na prova
*                                                       (de 0 a 64)
**********************************************************************/
create or replace procedure CriarSeries (pModProva in integer, pSexoProva in char, pDistProva in number,                -- TESTADO
                                        pNumParticipantes in integer)
as
    numSeries integer;
begin
    if pNumParticipantes <= 0 then
        raise_application_error(-20002,'Número de participantes da prova inválido');
    end if;
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
*   PROCEDURE:
*       AlocarSelecionados
*   DESCRIÇÃO:
*       Coloca participantes selecionados em uma prova em séries e
*       raias aleatórias da etapa semifinal.
*   PARÂMETROS:
*       pModProva           - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva          - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva          - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pNumParticipantes   - ENTRADA   - NÚMERO
*           Número de participantes total que participará na prova
*                                                       (de 0 a 64)
**********************************************************************/
create or replace procedure AlocarSelecionados  (pModProva in integer, pSexoProva in char,              -- RETESTAR
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
     
    cursor cursorInscritoAprovados
        is
        select *
			from Inscrito
			where Aprovado = 'S';
begin
    rSeed := TO_NUMBER(TO_CHAR(SYSDATE,'YYYYDDMMSS'));
    dbms_random.initialize(val => rSeed);
     
    numSeries := ceil(pNumParticipantes / 8);
    numRaiasExtras := pNumParticipantes mod 8;
    if numRaiasExtras = 0 then -- Se a divisão é exata a última série possui 8 raias
        numRaiasExtras := 8;
    end if;
     
    delete from RaiasAAlocar; -- Limpa tabela auxiliar para utilizá-la
     
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
    open cursorInscritoAprovados;
    loop
        fetch cursorInscritoAprovados into linhaInscrito;
        exit when cursorInscritoAprovados%notfound;
         
        linhaRNG := floor(dbms_random.value(1,linhasRestantes+1));
        select SeqSerie, NumRaia into serieRNG, raiaRNG
			from RaiasAAlocar casoATestar
			where linhaRNG-1 =  (select count(*) as qtdMenores
								from RaiasAAlocar
								where Ident < casoATestar.Ident);
        insert into Participa(NumInscr,NumMod,SexoProva,DistProva,EtapaSerie,SeqSerie,Tempo,Situacao,Raia)
            values(linhaInscrito.NumInscr,pModProva,pSexoProva,pDistProva,1,serieRNG,NULL,NULL,raiaRNG);
        delete from RaiasAAlocar
            where   SeqSerie = serieRNG and
                    NumRaia = raiaRNG;
        linhasRestantes := linhasRestantes - 1;
    end loop;
    close cursorInscritoAprovados;
     
    dbms_random.terminate;
end AlocarSelecionados;
/

/**********************************************************************
*   PROCEDURE:
*       FinalizarInscricoesProva
*   DESCRIÇÃO:
*       Finaliza as inscrições de uma prova, selecionando os
*		participantes, criando automaticamente todas suas séries e
*		alocando cada participante em uma raia da etapa eliminatória.
*		Não funciona se inscrições estiverem finalizadas.
*   PARÂMETROS:
*       pModProva           - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva          - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva          - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
**********************************************************************/
create or replace procedure FinalizarInscricoesProva (pModProva in integer, pSexoProva in char,                  -- RETESTAR
                                                                    pDistProva in number)
as
    numSelecionados integer;
	inscricoes 	integer;
begin
	select Valor into inscricoes
		from Globais
		where Nome = 'inscricoes';
	if inscricoes = 0 then
		raise_application_error(-20008,'As inscrições já foram finalizadas');
	end if;
	if inscricoes = -1 then
		raise_application_error(-20015,'As inscrições ainda nao foram abertas');
	end if;
	if inscricoes != 1 then
		raise_application_error(-20016,'Erro desconhecido: Configuração "inscricoes" com valor inválido');
	end if;
    
	numSelecionados := SelecionarInscritos(pModProva,pSexoProva,pDistProva);
	if numSelecionados > 0 then
		CriarSeries(pModProva,pSexoProva,pDistProva,numSelecionados);
		AlocarSelecionados(pModProva,pSexoProva,pDistProva,numSelecionados);
	end if;
	
end FinalizarInscricoesProva;
/

/**********************************************************************
*   PROCEDURE:
*       FinalizarInscricoes
*   DESCRIÇÃO:
*       Finaliza as inscrições de todas as prova, selecionando os
*		participantes de cada, criando automaticamente todas as séries e
*		alocando cada participante em uma raia de cada etapa eliminatória.
*		Por fim, encerra as inscrições.
*		Não funciona se inscrições estiverem finalizadas.
**********************************************************************/
create or replace procedure FinalizarInscricoes               				-- RETESTAR
as
	inscricoes 	integer;
	linhaProva		Prova%rowtype;
	
	cursor cursorProva
		is
		select *
		from Prova;
begin
	select Valor into inscricoes
		from Globais
		where Nome = 'inscricoes';
	if inscricoes = 0 then
		raise_application_error(-20009,'As inscrições já foram finalizadas');
	end if;
	if inscricoes = -1 then
		raise_application_error(-20017,'As inscrições ainda nao foram abertas');
	end if;
	if inscricoes != 1 then
		raise_application_error(-20018,'Erro desconhecido: Configuração "inscricoes" com valor inválido');
	end if;
    
	open cursorProva;
	loop
		fetch cursorProva into linhaProva;
		exit when cursorProva%notfound;
		
		FinalizarInscricoesProva(linhaProva.NumMod,linhaProva.Sexo,linhaProva.Dist);
	end loop;
	close cursorProva;
	
	update Globais
		set Valor = 0
		where Nome = 'inscricoes';
	
end FinalizarInscricoes;
/
 
/**********************************************************************
*   PROCEDURE:
*       CadastrarTempo
*   DESCRIÇÃO:
*       Cadastra (ou substitui) o tempo de nado de um competidor que
*       realizou (e completou) uma série em uma etapa da prova. Isso
*       automaticamente cadastra a participação do competidor na série
*       como "CONCLUÍDA". Não funciona se a série já foi dada como
*                                                       "executada".
*   PARÂMETROS:
*       pNumInscr   - ENTRADA   - INTEIRO
*           Número de inscrição do competidor
*       pModProva   - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva  - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva  - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pEtapaSerie - ENTRADA   - INTEIRO
*           Número de 1 a 3 que representa a etapa da prova
*                           (1- eliminatória, 2- semifinal, 3- final)
*       pTempo      - ENTRADA   - NÚMERO
*           Número que representa tempo de conclusão da série de nado
*           do competidor, em segundos. 
**********************************************************************/
create or replace procedure CadastrarTempo (pNumInscr in integer, pModProva in integer,			-- TESTADO
    pSexoProva in char, pDistProva in number, pEtapaSerie in integer, pTempo in number)
as
    sequenciaSerie integer;
    statusSerie integer;
    linhasAtualizadas integer;
begin
    select SeqSerie into sequenciaSerie
    from Participa
    where   NumInscr = PNumInscr and
            NumMod = pModProva and
            SexoProva = pSexoProva and
            DistProva = pDistProva and
            EtapaSerie = pEtapaSerie;
    select status into statusSerie
    from Serie
    where   NumMod = pModProva and
            SexoProva = pSexoProva and
            DistProva = pDistProva and
            Etapa = pEtapaSerie and
            Seq = sequenciaSerie;
    if statusSerie = 1 then -- Série já foi executada
        raise_application_error(-20003,'Série já foi executada e foi marcada como inalterável');
    end if;
     
    update Participa
        set Situacao = 1, Tempo = pTempo
        where   NumInscr = PNumInscr and
                NumMod = pModProva and
                SexoProva = pSexoProva and
                DistProva = pDistProva and
                EtapaSerie = pEtapaSerie;
     
    linhasAtualizadas := sql%rowcount;
    if linhasAtualizadas = 0 then
        raise_application_error(-20004,'Erro: Competidor ou prova/etapa da série inválidos');
    end if;
end CadastrarTempo;
/
 
/**********************************************************************
*   PROCEDURE:
*       CadastrarSituacao
*   DESCRIÇÃO:
*       Cadastra (ou substitui) a participação de um competidor numa
*       série de uma etapa de uma prova como "NULO" (ainda indefinida),
*       "DESCLASSIFICADO" ou "AUSENTE" (Para cadastrar como concluída,
*       deve-se usar a procedure "CadastrarTempo"). Não funciona se a
*       série já foi dada como "executada".
*   PARÂMETROS:
*       pNumInscr   - ENTRADA   - INTEIRO
*           Número de inscrição do competidor
*       pModProva   - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva  - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva  - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pEtapaSerie - ENTRADA   - INTEIRO
*           Número de 1 a 3 que representa a etapa da prova
*                           (1- eliminatória, 2- semifinal, 3- final)
*       pSituacao   - ENTRADA   - INTEIRO
*           Número que representa nova situação do competidor:
*           0- NULO, 1- DESCLASSIFICADO, 2- AUSENTE
**********************************************************************/
create or replace procedure CadastrarSituacao (pNumInscr in integer, pModProva in integer,				-- TESTADO
    pSexoProva in char, pDistProva in number, pEtapaSerie in integer, pSituacao in integer)
as
    sequenciaSerie integer;
    statusSerie integer;
    linhasAtualizadas integer;
begin
    select SeqSerie into sequenciaSerie
    from Participa
    where   NumInscr = PNumInscr and
            NumMod = pModProva and
            SexoProva = pSexoProva and
            DistProva = pDistProva and
            EtapaSerie = pEtapaSerie;
    select status into statusSerie
    from Serie
    where   NumMod = pModProva and
            SexoProva = pSexoProva and
            DistProva = pDistProva and
            Etapa = pEtapaSerie and
            Seq = sequenciaSerie;
    if statusSerie = 1 then -- Série já foi executada
        raise_application_error(-20003,'Série já foi executada e foi marcada como inalterável');
    end if;
     
    if pSituacao = 0 then
        update Participa
            set Situacao = NULL, Tempo = NULL
            where   NumInscr = PNumInscr and
                    NumMod = pModProva and
                    SexoProva = pSexoProva and
                    DistProva = pDistProva and
                    EtapaSerie = pEtapaSerie;
    else
        if pSituacao = 1 or pSituacao = 2 then
            update Participa
                set Situacao = pSituacao+1, Tempo = NULL
                where   NumInscr = PNumInscr and
                        NumMod = pModProva and
                        SexoProva = pSexoProva and
                        DistProva = pDistProva and
                        EtapaSerie = pEtapaSerie;
        else -- pSituacao passada é inválida!
            raise_application_error(-20005,'Número de situação passado é inválido (deve ser de 1 a 2)');
        end if;
    end if;
                 
    linhasAtualizadas := sql%rowcount;
    if linhasAtualizadas = 0 then
        raise_application_error(-20006,'Erro: Competidor ou prova/etapa da série inválidos');
    end if;
end CadastrarSituacao;
/

/**********************************************************************
*   PROCEDURE:
*       FinalizarSerie
*   DESCRIÇÃO:
*       Muda o status de uma série para "executada". Só funciona caso
*		todos os tempos ou situações dos competidores que nadaram nela
*		tenham sido inicializados. Finalizar a série bloqueia toda
*		futura alteração desses tempos e situações.
*   PARÂMETROS:
*       pModProva   - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva  - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva  - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pEtapaSerie - ENTRADA   - INTEIRO
*           Número de 1 a 3 que representa a etapa
*                           (1- eliminatória, 2- semifinal, 3- final)
*       pSeqSerie	- ENTRADA   - INTEIRO
*           Número sequencial que identifica a série da etapa
**********************************************************************/
create or replace procedure FinalizarSerie	(pModProva in integer, pSexoProva in char, pDistProva in number,		-- TESTAR
											pEtapaSerie in integer, pSeqSerie in integer)
as
	situacoesNulas integer;
	linhasAtualizadas integer;
begin
	select count(*) into situacoesNulas
		from Participa
		where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				EtapaSerie = pEtapaSerie and
				SeqSerie = pSeqSerie and
				Situacao is NULL;
	if situacoesNulas > 0 then
		raise_application_error(-20019,'A série não pode ser finalizada, ainda existem participantes de situação indefinida');
	end if;
	update Serie
		set Status = 1
		where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				Etapa = pEtapaSerie and
				Seq = pSeqSerie and
				Status = 0;
	linhasAtualizadas := sql%rowcount;
	if linhasAtualizadas = 0 then
		raise_application_error(-20020,'A série não existe ou já foi finalizada');
	end if;
end FinalizarSerie;
/

/**********************************************************************
*   PROCEDURE:
*       FinalizarEtapa
*   DESCRIÇÃO:
*       Finaliza a etapa eliminatória ou semifinal de uma prova, 
*		selecionando os melhores competidoes e passando-os para a etapa
*		seguinte. Aloca os competidores em séries e raias aleatórias da
*		nova etapa ou em raias específicas, no caso da etapa final. Só
*		funciona caso todas as séries da etapa encerrada estejam marcadas
*		como executadas.
*   PARÂMETROS:
*       pModProva   - ENTRADA   - INTEIRO
*           Número da modalidade (ver tabela Modalidade) da prova
*       pSexoProva  - ENTRADA   - CARACTER
*           'M' ou 'F', sexo dos participantes da prova
*       pDistProva  - ENTRADA   - NÚMERO
*           Distância de percurso da prova, em metros
*       pEtapa		- ENTRADA   - INTEIRO
*           Número de 1 a 2 que representa a etapa a ser finalizada
*                           (1- eliminatória, 2- semifinal)
**********************************************************************/
create or replace procedure FinalizarEtapa  (pModProva in integer, pSexoProva in char,              -- RETESTAR
											pDistProva in number, pEtapa in integer)
as
    numSeries integer;
    numRaiasExtras integer; -- Número de raias que serão usadas na última série
    raiaLimite integer;
    rSeed  BINARY_INTEGER;
    numInscrSelecionado Participa.NumInscr%type;
    raiaRNG integer;
    serieRNG integer;
    linhaRNG integer;
    linhasRestantes integer;
	numSelecionados integer;
	numSeriesNaoExecutadas integer;
	posSelecionado integer;
	posRaia integer;
	seriesDaEtapa integer;
     
	cursor cursorMenoresTemposEtapa (pModProva integer, pSexoProva char, pDistProva number, pEtapa number, pQtdMelhores integer) -- COMPLETAR/TESTAR
	is
	(select *
		from (
		  select NumInscr,
		  row_number() over (order by Tempo, NumInscr) posicao
		  from Participa
		  where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				EtapaSerie = pEtapa and
				Tempo is not NULL
		)
		where posicao <= pQtdMelhores);
begin

	select count(*) into numSeriesNaoExecutadas
		from Serie
		where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				Etapa = pEtapa and
				Status = 0;
	
	select count(*) into seriesDaEtapa
		from Serie
		where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				Etapa = pEtapa;
		
	if seriesDaEtapa = 0 then
		raise_application_error(-20022,'Prova ou etapa inválida');
	end if;
	
	if numSeriesNaoExecutadas > 0 then
		raise_application_error(-20023,'Não é possível finalizar a etapa pois há séries ainda não executadas!');
	end if;

	select count(*) into numSelecionados
		from (
		  select NumInscr,
		  row_number() over (order by Tempo, NumInscr) posicao
		  from Participa
		  where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva and
				EtapaSerie = pEtapa and
				Tempo is not NULL
		)
		where posicao <= pQtdMelhores;
		
	if pEtapa = 1 then
		rSeed := TO_NUMBER(TO_CHAR(SYSDATE,'YYYYDDMMSS'));
		dbms_random.initialize(val => rSeed);
		
		numSeries := ceil(numSelecionados / 8);
		numRaiasExtras := numSelecionados mod 8;
		if numRaiasExtras = 0 then -- Se a divisão é exata a última série possui 8 raias
			numRaiasExtras := 8;
		end if;
		
		delete from RaiasAAlocar; -- Limpa tabela auxiliar para utilizá-la
		
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
		
		linhasRestantes := numSelecionados;
		open cursorMenoresTemposEtapa(pModProva,pSexoProva,pDistProva,pEtapa,32);
		loop
			fetch cursorMenoresTemposEtapa into numInscrSelecionado;
			exit when cursorMenoresTemposEtapa%notfound;
			 
			linhaRNG := floor(dbms_random.value(1,linhasRestantes+1));
			select SeqSerie, NumRaia into serieRNG, raiaRNG
				from RaiasAAlocar casoATestar
				where linhaRNG-1 =  (select count(*) as qtdMenores
									from RaiasAAlocar
									where Ident < casoATestar.Ident);
			insert into Participa(NumInscr,NumMod,SexoProva,DistProva,EtapaSerie,SeqSerie,Tempo,Situacao,Raia)
				values(numInscrSelecionado,pModProva,pSexoProva,pDistProva,2,serieRNG,NULL,NULL,raiaRNG);
			delete from RaiasAAlocar
				where   SeqSerie = serieRNG and
						NumRaia = raiaRNG;
			linhasRestantes := linhasRestantes - 1;
		end loop;
		close cursorMenoresTemposEtapa;
		 
		dbms_random.terminate;

	else
		if pEtapa = 2 then
			open cursorMenoresTemposEtapa(pModProva,pSexoProva,pDistProva,pEtapa,8);
			posSelecionado := 1;
			loop
				fetch cursorMenoresTemposEtapa into numInscrSelecionado;
				exit when cursorMenoresTemposEtapa%notfound;
				
				if posSelecionado = 1 then posRaia := 4;
				else
					if posSelecionado = 2 then posRaia := 5;
					else
						if posSelecionado = 3 then posRaia := 3;
						else
							if posSelecionado = 4 then posRaia := 6;
							else
								if posSelecionado = 5 then posRaia := 2;
								else
									if posSelecionado = 6 then posRaia := 7;
									else
										if posSelecionado = 7 then posRaia := 1;
										else
											posRaia := 8;
										end if;
									end if;
								end if;
							end if;
						end if;
					end if;
				end if;
				
				insert into Participa(NumInscr,NumMod,SexoProva,DistProva,EtapaSerie,SeqSerie,Tempo,Situacao,Raia)
					values(numInscrSelecionado,pModProva,pSexoProva,pDistProva,3,1,NULL,NULL,posRaia);
				
				posSelecionado := posSelecionado + 1;
			end loop;
			close cursorMenoresTemposEtapa;
		else
			raise_application_error(-20021,'Etapa inválida');
		end if;		
	end if;
	
end FinalizarEtapa;
/
