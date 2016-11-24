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
