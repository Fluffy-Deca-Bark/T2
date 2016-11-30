-- TRIGGERS

/**********************************************************************
*	TRIGGERS:
*		DataEtapaDatasDiferentes/DataEtapaDatasDiferentes2
*	DESCRIÇÃO:
*   	Agem na inserção/update da tabela DataEtapa.
*		Garantem que etapas de uma mesma prova tenham datas diferentes.
**********************************************************************/
create or replace trigger DataEtapaDatasDiferentes
instead of insert on DataEtapas
referencing NEW as NovaData
for each row
declare
  nenhumaDataRepetida number;
begin
  nenhumaDataRepetida :=
    0 = (select count(*)
    from DataEtapas
    where NumMod = NovaData.NumMod and
          DistProva = NovaData.DistProva and
          SexoProva = NovaData.SexoProva and
          Data = NovaData.data);
  if (nenhumaDataRepetida) then
    insert into DataEtapas
      values(NovaData.NumMod,NovaData.DistProva,NovaData.SexoProva,NovaData.Data);
  end if;
end;
/

create or replace trigger DataEtapaDatasDiferentes2
instead of update on DataEtapas
referencing NEW as NovaData
for each row
declare
  nenhumaDataRepetida number;
begin
  nenhumaDataRepetida :=
    1 >= (select count(*)
    from DataEtapas
    where NumMod = NovaData.NumMod and
          DistProva = NovaData.DistProva and
          SexoProva = NovaData.SexoProva and
          Data = NovaData.data);
  if (nenhumaDataRepetida) then
    insert into DataEtapas
      values(NovaData.NumMod,NovaData.DistProva,NovaData.SexoProva,NovaData.Data);
  end if;
end;
/

/**********************************************************************
*	TRIGGERS:
*		ParticipaUmaSeriePorEtapa/ParticipaUmaSeriePorEtapa2
*	DESCRIÇÃO:
*   	Agem na inserção/update da tabela Participa
*		Garantem que cada competidor só participe de uma série por
*												etapa, para cada prova
**********************************************************************/
create or replace trigger ParticipaUmaSeriePorEtapa
instead of insert on Participa
referencing NEW as NovaParticipacao
for each row
declare
  nenhumaTreta number;
begin
  nenhumaTreta :=
    0 = (select count(*)
    from Participa
    where NumInscr = NovaParticipacao.NumInscr and
          NumMod = NovaParticipacao.NumMod and
          SexoProva = NovaParticipacao.SexoProva and
          DistProva = NovaParticipacao.DistProva and
          EtapaSerie = NovaParticipacao.EtapaSerie);
  if (nenhumaTreta) then
    insert into Participa
      values(NovaParticipacao.NumInscr,NovaParticipacao.NumMod,NovaParticipacao.SexoProva,
            NovaParticipacao.DistProva,NovaParticipacao.EtapaSerie,NovaParticipacao.SeqSerie,
            NovaParticipacao.Tempo,NovaParticipacao.Situacao,NovaParticipacao.Raia);
  end if;
end;
/

create or replace trigger ParticipaUmaSeriePorEtapa2
instead of update on Participa
referencing NEW as NovaParticipacao
for each row
declare
  nenhumaTreta number;
begin
  nenhumaTreta :=
    1 >= (select count(*)
    from Participa
    where NumInscr = NovaParticipacao.NumInscr and
          NumMod = NovaParticipacao.NumMod and
          SexoProva = NovaParticipacao.SexoProva and
          DistProva = NovaParticipacao.DistProva and
          EtapaSerie = NovaParticipacao.EtapaSerie);
  if (nenhumaTreta) then
    insert into Participa
      values(NovaParticipacao.NumInscr,NovaParticipacao.NumMod,NovaParticipacao.SexoProva,
            NovaParticipacao.DistProva,NovaParticipacao.EtapaSerie,NovaParticipacao.SeqSerie,
            NovaParticipacao.Tempo,NovaParticipacao.Situacao,NovaParticipacao.Raia);
  end if;
end;
/

/**********************************************************************
*	TRIGGER:
*		ParticipaProximaEtapa
*	DESCRIÇÃO:
*   	Age no update da tabela Participa.
*		Garante que um competidor só possa ter tempo e situação
*		colocados em uma série caso o status da série anterior
*											seja 'executada'.
**********************************************************************/
create or replace trigger ParticipaProximaEtapa
before update on Participa
referencing OLD as VelhaParticipacao NEW as NovaParticipacao
for each row
declare
  altereiOQueNaoDevia integer;
  statusAnterior integer;
begin 
  altereiOQueNaoDevia :=
  (VelhaParticipacao.tempo != NovaParticipacao.tempo or
  VelhaParticipacao.situcacao != NovaParticipacao.situacao);
  if altereiOQueNaoDevia = 1 then
    if VelhaParticipacao.SeqSerie > 1 then
      select Status into statusAnterior
		from Serie;
		where	NumMod = VelhaParticipacao.NumMod and
				SexoProva = VelhaParticipacao.SexoProva and
				DistProva = VelhaParticipacao.DistProva and
				Etapa = VelhaParticipacao.EtapaSerie and
				Seq = VelhaParticipacao.SeqSerie - 1;
		
		if statusAnterior = 0 then
			raise_application_error(-20023,'A série anterior ainda não foi finalizada, portanto não se pode mudar tempo e situação desse competidor ainda');
		end if;
    end if;
  end if;
end;
/
