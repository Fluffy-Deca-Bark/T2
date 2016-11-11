------------
-- DROP * --
------------

drop table modalidade;
drop table prova;
drop table serie;

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



-----------------
-- ALTER TABLE --
-----------------


alter table prova
  add constraint ProvaFK_numMod foreign key (numMod) references modalidade (num);
  
alter table serie
  add constraint SerieDistProvaFK foreign key (distProva) references prova (dist);

alter table serie
  add constraint SerieNumMod foreign key (numMod) references modalidade (num);

alter table serie
  add constraint SerieSexoProva foreign key (sexoProva) references prova (sexo);



