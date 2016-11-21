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
  dbms_output.put_line(a);
end;
/
