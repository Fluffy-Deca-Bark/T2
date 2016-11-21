begin
  CriarProva(1,'F',200,to_date('01/01/2001','dd/mm/yyyy'),to_date('02/01/2001','dd/mm/yyyy'),to_date('03/01/2001','dd/mm/yyyy'));
end;
/

delete from inscrito;
delete from competidor;

begin
  for i in 1..65 loop
    insert into Competidor
      values(i,'HMMMMM','M',0);
  end loop;
  
  for i in 1..65 loop
    insert into Inscrito
      values(i,1,'F',200,i,'Torneio','Piscina',to_date('01/01/3200','dd/mm/yyyy'),'N');
    end loop;
end;
/

declare
  a integer;
begin
  a := SelecionarParticipantes(1,'F',200);
  CriarSeries(1,'F',200,a);
  dbms_output.put_line(a);
end;
/

declare
  minhaData date;
begin  
  minhaData := ObterDataEtapa(1,'F',200,4);
  dbms_output.put_line(minhaData);
end;
/

declare
  meuInteiro integer;
  minhaSeed  BINARY_INTEGER;
begin
  minhaSeed := TO_NUMBER(TO_CHAR(SYSDATE,'YYYYDDMMSS'));
  dbms_random.initialize(val => minhaSeed);
  --meuInteiro := floor(select dbms_random.value(1,numRaiasExtras+1) from dual);
  meuInteiro := floor(dbms_random.value(1,9));
  dbms_output.put_line(meuInteiro);
  dbms_random.terminate;
end;
/
