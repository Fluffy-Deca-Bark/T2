------------
-- DROP * --
------------


drop table prova;
drop table serie;
drop table modalidade;
DROP TABLE COMPETIDOR;

------------------
-- CREATE TABLE --
------------------

drop table modalidade;
create table modalidade
(
  num number not null,
  nome varchar2(20) not null,
  
  constraint ModPK primary key (num)
);



drop table prova;
create table prova
(
  numMod number not null,
  dist number not null,
  sexo char not null,
  
  constraint ProvaPK primary key (numMod, dist, sexo),
  constraint ProvaSexo check (sexo in ('M', 'F'))
);

drop table serie;
create table serie
(
  distProva number not null,
  etapa number not null,
  numMod number not null,
  seq number not null,
  sexoProva char not null,
  status number not null,
  
  constraint SeriePK primary key (distProva, etapa, numMod, seq, sexoProva),
  constraint SerieEtapaPositiva check (etapa > 0),
  constraint SerieStatus check (status in (0, 1))
);
DROP TABLE COMPETIDOR;
create table competidor
(
   NUMINSCR NUMBER(5) NOT NULL,
   NOME VARCHAR2(100) NOT NULL,
   SEXO CHAR NOT NULL,
   ANONASC NUMBER(4) NOT NULL,
  
  CONSTRAINT COMPETIDOR_SEXOCK CHECK(SEXO IN('M','F')), 
  CONSTRAINT COMPETIDOR_NUMINSCRPK PRIMARY KEY(NUMINSCR)
);

-----------------
-- ALTER TABLE --
-----------------

alter table prova
  add constraint ProvaFK_numMod foreign key (numMod) references modalidade (num);
  
alter table serie
  add constraint SerieFK_Prova foreign key (numMod, distProva, sexoProva) references prova (numMod, dist, sexo);

