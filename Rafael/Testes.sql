----------------
-- DROP TABLE --
----------------


drop table inscrito cascade constraints;
drop table prova cascade constraints;
drop table serie cascade constraints;
drop table modalidade cascade constraints;
DROP TABLE COMPETIDOR cascade constraints;
DROP TABLE PARTICIPA cascade constraints;
DROP TABLE PATROCINADO cascade constraints;
DROP TABLE DATAETAPA cascade constraints; 
drop table RaiasAAlocar cascade constraints;
------------------
-- CREATE TABLE --
------------------

drop table Globais cascade constraints;
create table Globais (
  Nome  varchar2(30)  primary key,
  Valor number        null
);


drop table RaiasAAlocar cascade constraints;
create table RaiasAAlocar (
	Ident		number(2)	primary key,
	SeqSerie	number(1)	not null,
	NumRaia		number(1)	not null
);


drop table modalidade cascade constraints;
create table modalidade
(
  num number not null,
  nome varchar2(20) not null,
  
  constraint ModPK primary key (num)
);



drop table prova cascade constraints;
create table prova
(
  numMod number not null,
  sexo char not null,
  dist number not null,
  
  constraint ProvaPK primary key (numMod, dist, sexo),
  constraint ProvaDistPositiva check (dist > 0),
  constraint ProvaSexo check (sexo in ('M', 'F'))
);

drop table serie cascade constraints;
create table serie
(
  numMod number not null,
  sexoProva char not null,
  distProva number not null,
  etapa number not null,
  seq number not null,
  status number not null,
  
  constraint SeriePK primary key (distProva, etapa, numMod, seq, sexoProva),
  constraint SerieEtapaPositiva check (etapa in (1, 2, 3)),
  constraint SerieSeq check (seq >= 1 and seq <= 8),
  constraint SerieSexoProva check (sexoProva in ('M', 'F')),
  constraint SerieStatus check (status in (0, 1))
);

drop table inscrito cascade constraints;
create table inscrito
(
  NUMINSCR number(5) not null,
  numMod number not null,
  sexoProva char not null,
  distProva number not null,
  melhorTempo number(5,2) not null,
  nomeTorneio varchar2(200) not null,
  localTorneio varchar2(200) not null,
  dataTorneio date not null,
  aprovado char not null,
  
  constraint InscritoPK primary key (NUMINSCR, numMod, distProva, sexoProva),
  constraint InscritoNUMINSCR CHECK(NUMINSCR>0),
  constraint InscritoSexoProva check (sexoProva in ('M', 'F')),
  constraint InscritoAprovado check (aprovado in ('S', 'N')),
  constraint InscritoMelhorTempo check (melhorTempo > 0)
);

DROP TABLE COMPETIDOR cascade constraints;
create table competidor
(
   NUMINSCR NUMBER(5) NOT NULL,
   NOME VARCHAR2(100) NOT NULL,
   SEXO CHAR NOT NULL,
   ANONASC NUMBER(4) NOT NULL,
  
  CONSTRAINT COMPETIDOR_NUMINSCRPK PRIMARY KEY(NUMINSCR),
  CONSTRAINT COMPETIDOR_SEXOCK CHECK(SEXO IN('M','F')),
  CONSTRAINT COMPETIDOR_NUMINSCRCK CHECK(NUMINSCR>0)
);

DROP TABLE PARTICIPA cascade constraints;
create table PARTICIPA
(
   NUMINSCR NUMBER(5) NOT NULL,
   NUMMOD NUMBER NOT NULL,
   SEXOPROVA CHAR NOT NULL,
   DISTPROVA NUMBER NOT NULL,
   ETAPASERIE NUMBER NOT NULL,
   SEQSERIE NUMBER NOT NULL,
   TEMPO NUMBER(5,2),
   SITUACAO NUMBER,
   RAIA NUMBER NOT NULL,
   
  CONSTRAINT PARTICIPAPK PRIMARY KEY(NUMINSCR,NUMMOD,SEXOPROVA,DISTPROVA,ETAPASERIE,SEQSERIE),
  CONSTRAINT PARTICIPA_NUMINSCRCK CHECK(NUMINSCR>0),
  CONSTRAINT PARTICIPA_SEXOPROVACK CHECK(SEXOPROVA IN('M','F')),
  CONSTRAINT PARTICIPA_DISTPROVACK CHECK(DISTPROVA>0),
  CONSTRAINT PARTICIPA_ETAPASERIECK CHECK(ETAPASERIE IN (1,2,3)),
  CONSTRAINT PARTICIPA_SEQSERIECK CHECK(SEQSERIE>= 1 AND SEQSERIE <= 8),
  CONSTRAINT PARTICIPA_RAIACK CHECK(RAIA>= 1 AND RAIA<= 8),
  CONSTRAINT PARTICIPA_SITUCAOCK CHECK(SITUACAO IN(NULL,1,2,3))
);

DROP TABLE PATROCINADO cascade constraints;
create table PATROCINADO
(
  NUMINSCR number(5) not null,
  PATROCINADOR VARCHAR2(100) not null,
  
  CONSTRAINT PATROCINADO_NUMINSCRCK CHECK(NUMINSCR>0),
  CONSTRAINT PATROCINADOPK PRIMARY KEY (NUMINSCR,PATROCINADOR)
);

DROP TABLE DATAETAPA cascade constraints;  
create table DATAETAPA
(
   NUMMOD NUMBER NOT NULL,
   DISTPROVA NUMBER NOT NULL,
   SEXOPROVA CHAR NOT NULL,
   DATA DATE NOT NULL,
   
   CONSTRAINT DATAETAPAPK PRIMARY KEY(NUMMOD,DISTPROVA,SEXOPROVA,DATA),
   CONSTRAINT DATAETAPA_SEXOPROVACK CHECK(SEXOPROVA IN('M','F')),
   CONSTRAINT DATAETAPA_DISTPROVACK CHECK(DISTPROVA>0)
);



-----------------
-- ALTER TABLE --
-----------------

alter table prova
  add constraint ProvaFK_numMod foreign key (numMod) references modalidade (num);
  
alter table serie
  add constraint SerieFK_Prova foreign key (numMod, distProva, sexoProva) references prova (numMod, dist, sexo);

alter table inscrito
  add constraint InscritoFK_Competidor foreign key (NUMINSCR) references competidor (NUMINSCR);
  
alter table inscrito
  add constraint InscritoFK_Mod foreign key (numMod) references modalidade (num);
  
alter table inscrito
  add constraint InscritoFK_Prova foreign key (numMod, distProva, sexoProva) references prova (numMod, dist, sexo);
  
ALTER TABLE PARTICIPA
ADD CONSTRAINT PARTICIPA_NUMINSCRFK FOREIGN KEY (NUMINSCR) REFERENCES COMPETIDOR(NUMINSCR);

ALTER TABLE PARTICIPA
ADD CONSTRAINT PARTICIPA_NUMMODFK FOREIGN KEY (NUMMOD) REFERENCES MODALIDADE(NUM);

ALTER TABLE PARTICIPA
ADD CONSTRAINT PARTICIPA_SEXOPROVAFK FOREIGN KEY (SEXOPROVA,DISTPROVA,NUMMOD) REFERENCES PROVA(SEXO,DIST,NUMMOD);

ALTER TABLE PARTICIPA
ADD CONSTRAINT PARTICIPA_SERIEFK FOREIGN KEY (SEQSERIE,ETAPASERIE,SEXOPROVA,DISTPROVA,NUMMOD) REFERENCES SERIE(SEQ,ETAPA,SEXOPROVA,DISTPROVA,NUMMOD);

ALTER TABLE PATROCINADO
ADD CONSTRAINT PATROCINADO_NUMINSCRFK FOREIGN KEY (NUMINSCR) REFERENCES COMPETIDOR(NUMINSCR);

ALTER TABLE DATAETAPA
ADD CONSTRAINT DATAETAPA_NUMMODFK FOREIGN KEY (NUMMOD) REFERENCES MODALIDADE(NUM);

ALTER TABLE DATAETAPA
ADD CONSTRAINT DATAETAPA_PROVAFK FOREIGN KEY (NUMMOD,DISTPROVA,SEXOPROVA) REFERENCES PROVA(NUMMOD,DIST,SEXO);
  
  
insert into modalidade
  values(1,'Medley');
insert into modalidade
  values(2,'Crawl');
insert into modalidade
  values(3,'Borboleta');
insert into modalidade
  values(4,'Peito');
insert into modalidade
  values(5,'Costas');
insert into modalidade
  values(6,'Cachorrinho');
 

---------------------------------------------------------------------------------- INICIALIZAÇÕES ----------------------------------------------------------------------
insert into Globais(Nome, Valor)
  values('inscricoes', -1);

---------------------------------------------------------------------------------- DECLARAÇÃO DE PROCEDURES, FUNÇÕES  E TRIGGERS ----------------------------------------------------------------------

/**********************************************************************
*	PROCEDURE:
*		CriarProva
*	DESCRIÇÃO:
*   	Cria uma prova. Falha se datas passadas não seguirem requisitos:
*		Datas das etapas devem ser diferentes. Data da eliminatória é
*		predecessora da semifinal que vem antes da etapa final. 
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
create or replace procedure CriarProva	(pMod in integer, pSexo in char, pDist in number,					-- TESTADO
										pData1 in date, pData2 in date, pData3 in date)
as
begin
	if pData1 = pData2 or pData1 = pData3 or pData2 = pData3 or pData1 > pData2 or pData2 > pData3 then
		raise_application_error(-20001,'Datas de etapas inválidas');
	end if;
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

begin
  CriarProva(1,'M',200.5,to_date('10/12/2016','dd/mm/yyyy'),to_date('11/12/2016','dd/mm/yyyy'),to_date('12/12/2016','dd/mm/yyyy'));
end;
/

/**********************************************************************
*	FUNÇÃO:
*		ObterDataEtapa
*	DESCRIÇÃO:
*   	Obtém a data em que ocorre uma etapa (número de 1 a 3) de uma
*																prova
*	PARÂMETROS:
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pEtapa		- ENTRADA	- NÚMERO
*			Número de 1 a 3 que representa etapa (1- eliminatória,
*												2- semifinal, 3- final)	
*	RETORNO:
*		DATA - Retorna a data de realização da etapa
**********************************************************************/
create or replace function ObterDataEtapa(pModProva in integer, pSexoProva in char, pDistProva in number, pEtapa in integer)	-- TESTADO
return date as
  dataEsperada date;
begin
  select Data into dataEsperada
    from DataEtapa dataEmTeste
    where pModProva = NumMod and
          pSexoProva = SexoProva and
          pDistProva = DistProva and
            pEtapa-1 =  (select count(*)
                        from DataEtapa
                        where Data < dataEmTeste.Data);
    return dataEsperada;
end ObterDataEtapa;
/

declare
  dataEtapa date;
begin
  dataEtapa := ObterDataEtapa(1,'M',200.5,1);
  dbms_output.put_line('Data Etapa 1: '||dataEtapa);
  dataEtapa := ObterDataEtapa(1,'M',200.5,2);
  dbms_output.put_line('Data Etapa 2: '||dataEtapa);
  dataEtapa := ObterDataEtapa(1,'M',200.5,3);
  dbms_output.put_line('Data Etapa 3: '||dataEtapa);
end;
/

/**********************************************************************
*	FUNÇÃO:
*		CriarCompetidor
*	DESCRIÇÃO:
*   	Cadastra um competidor no BD
*	PARÂMETROS:
*		pNome	- ENTRADA	- STRING
*			Nome do competidor
*		pSexo	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo do competidor
*		pAno	- ENTRADA	- INTEIRO
*			Ano de nascimento do competidor
*	RETORNO:
*		INTEIRO - Retorna o número de inscrição do competidor criado
**********************************************************************/
create or replace function CriarCompetidor (pNome in varchar2, pSexo in char, pAno in integer)		-- TESTADO
return integer as
	inscr integer;
	numCompetidores integer;
begin
	select count(*) into numCompetidores
		from Competidor;
	
	if (numCompetidores = 0) then
		inscr := 1;
	else
		select max(NumInscr) into inscr
			from Competidor;
		inscr := inscr + 1;
	end if;
	
	insert into Competidor(NumInscr,Nome,Sexo,AnoNasc)
		values(inscr,pNome,pSexo,pAno);
	return inscr;
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

declare
  ident integer;
  numTorneio integer;
  tempoTotal number;
begin
  for i in 1..67 loop
    ident := CriarCompetidor('Competidor '||i,'M',1997);
    AdicionarPatrocinio(ident,'Padaria do Ze filial '||i);
    AdicionarPatrocinio(ident,'Selaria texana rua '||i);
    numTorneio := (i mod 7) + 1;
    tempoTotal := (i-34)*(i-34)+1;
    if tempoTotal >= 1000 then
      tempoTotal := 999.99;
    end if;
    FazerInscricao(ident,1,'M',200.5,tempoTotal,'Torneio '||numTorneio,'Local do torneio '||numTorneio,to_date('0'||numTorneio||'/11/2016','dd/mm/yyyy'));
  end loop;
end;
/

/**********************************************************************
*	FUNÇÃO:
*		SelecionarParticipantes
*	DESCRIÇÃO:
*   	Seleciona melhores participantes inscritos em uma prova e
*		muda o atributo "Aprovado" da tabela Inscrito deles para 'S'
*	PARÂMETROS:
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*	RETORNO:
*		INTEIRO - Retorna o número de participates selecionados
**********************************************************************/
create or replace function SelecionarParticipantes	(pModProva in integer, pSexoProva in char,					-- RETESTAR
													pDistProva in number)
return integer as
	inscicaoSelecionada Inscrito.NumInscr%type;
  numLinha integer;
	numSelecionados integer;
	
	cursor cursorInscritoMenoresTempos (pModProva integer, pSexoProva char, pDistProva number, pQtdMelhores integer)
	is
	(select *
		from (
		  select NumInscr,
		  row_number() over (order by MelhorTempo, NumInscr) posicao
		  from Inscrito
		  where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva
		)
		where posicao <= PqTDmELHORES);	
begin
	numSelecionados := 0;
	
	open cursorInscritoMenoresTempos(pModProva,pSexoProva,pDistProva,64);
	loop
		fetch cursorInscritoMenoresTempos into inscicaoSelecionada, numLinha;
		exit when cursorInscritoMenoresTempos%notfound;
		
		update Inscrito
			set Aprovado = 'S'
			where NumInscr = inscicaoSelecionada;
		
		numSelecionados := numSelecionados + 1;
	end loop;
	close cursorInscritoMenoresTempos;
	
	return numSelecionados;
end SelecionarParticipantes;
/

/**********************************************************************
*	PROCEDURE:
*		CriarSeries
*	DESCRIÇÃO:
*   	Cria séries necessárias pra realizção de uma prova, segundo a
*		quantidade de participantes selecionados (estritamente positivo)
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
create or replace procedure CriarSeries	(pModProva in integer, pSexoProva in char, pDistProva in number, 				-- TESTADO
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
*	PROCEDURE:
*		AlocarSelecionados
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
create or replace procedure AlocarSelecionados  (pModProva in integer, pSexoProva in char,              -- TESTADO
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
create or replace procedure FinalizarInscricoesProva (pModProva in integer, pSexoProva in char,                  -- COMPLETAR/TESTAR
                                                                    pDistProva in number)
as
    numSelecionados integer;
	fimInscricoes 	integer;
begin
	select Valor into fimInscricoes
		from Globais
		where Nome = 'fimInscricoes';
	if fimInscricoes = 1 then
		raise_application_error(-20008,'As inscrições já foram finalizadas');
	end if;
    
	numSelecionados := SelecionarParticipantes(pModProva,pSexoProva,pDistProva);
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
create or replace procedure FinalizarInscricoes               											  -- COMPLETAR/TESTAR
as
	fimInscricoes 	integer;
	linhaProva		Prova%rowtype;
	
	cursor cursorProva
		is
		select *
		from Prova;
begin
	select Valor into fimInscricoes
		from Globais
		where Nome = 'fimInscricoes';
	if fimInscricoes = 1 then
		raise_application_error(-20009,'As inscrições já foram finalizadas');
	end if;
    
	open cursorProva;
	loop
		fetch cursorProva into linhaProva;
		exit when cursorProva%notfound;
		
		FinalizarInscricoesProva(linhaProva.NumMod,linhaProva.Sexo,linhaProva.Dist);
	end loop;
	close cursorProva;
	
	update Globais
		set Valor = 1
		where Nome = 'fimInscricoes';
	
end FinalizarInscricoes;
/

begin
  FinalizarInscricoes;
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
		raise_application_error(-20003,'Série já foi executada e foi marcada como inalterável');
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
		raise_application_error(-20004,'Erro: Competidor ou etapa da série inválidos');
	end if;
end CadastrarTempo;
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
		raise_application_error(-20003,'Série já foi executada e foi marcada como inalterável');
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
			raise_application_error(-20005,'Número de situação passado é inválido (deve ser de 1 a 3)');
		end if;
	end if;
				
	linhasAtualizadas := sql%rowcount;
	if linhasAtualizadas = 0 then
		raise_application_error(-20006,'Série já foi executada e foi marcada como inalterável');
	end if;
end CadastrarSituacao;
/

begin
  for i in 2..45 loop
    CadastrarTempo(i,1,'M',200.5,1,i+10);
  end loop;
  for i in 46..52 loop
    CadastrarSituacao(i,1,'M',200.5,1,2);
  end loop;
  for i in 53..64 loop
    CadastrarSituacao(i,1,'M',200.5,1,1);
  end loop;
end;
