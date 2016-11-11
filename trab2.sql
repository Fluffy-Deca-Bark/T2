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
  
);



-----------------
-- ALTER TABLE --
-----------------


alter table prova
  add constraint ProvaFK_numMod foreign key (numMod) references modalidade (num);
  
