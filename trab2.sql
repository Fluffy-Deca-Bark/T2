----------------
-- DROP TABLE --
----------------


drop table inscrito;
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
  constraint ProvaDistPositiva check (dist > 0),
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
  constraint SerieEtapaPositiva check (etapa in (1, 2, 3)),
  constraint SerieSeq check (seq >= 1 and seq <= 8),
  constraint SerieSexoProva check (sexoProva in ('M', 'F')),
  constraint SerieStatus check (status in (0, 1))
);

drop table inscrito;
create table inscrito
(
  numInsc number(5) not null,
  numMod number not null,
  distProva number not null,
  sexoProva char not null,
  aprovado char not null,
  dataTorneio date not null,
  localTorneio varchar2(200) not null,
  melhorTempo number(3,2) not null,
  nomeTorneio varchar2(200) not null,
  
  constraint InscritoPK primary key (numInsc, numMod, distProva, sexoProva),
  constraint InscritoSexoProva check (sexoProva in ('M', 'F')),
  constraint InscritoAprovado check (aprovado in ('S', 'N')),
  constraint InscritoMelhorTempo check (melhorTempo > 0)
);

DROP TABLE COMPETIDOR;
create table competidor
(
   NUMINSC NUMBER(5) NOT NULL,
   NOME VARCHAR2(100) NOT NULL,
   SEXO CHAR NOT NULL,
   ANONASC NUMBER(4) NOT NULL,
  
  CONSTRAINT COMPETIDOR_SEXOCK CHECK(SEXO IN('M','F')), 
  CONSTRAINT COMPETIDOR_NUMINSCPK PRIMARY KEY(NUMINSC)
);

-----------------
-- ALTER TABLE --
-----------------

alter table prova
  add constraint ProvaFK_numMod foreign key (numMod) references modalidade (num);
  
alter table serie
  add constraint SerieFK_Prova foreign key (numMod, distProva, sexoProva) references prova (numMod, dist, sexo);

alter table inscrito
  add constraint InscritoFK_Competidor foreign key (numInsc) references competidor (numInsc);
  
alter table inscrito
  add constraint InscritoFK_Mod foreign key (numMod) references modalidade (num);
  
alter table inscrito
  add constraint InscritoFK_Prova foreign key (numMod, distProva, sexoProva) references prova (numMod, dist, sexo);