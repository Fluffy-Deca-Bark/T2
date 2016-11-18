-- FUNCTIONS

/***********
* ObterEtapaSerie:
*   Recebe uma struct serie e retorna sua data.
*   (salva em sua prova)
*********/
create or replace function ObterEtapaSerie(pSerie in serie%rowtype)
return date as
  dataEsperada date;
begin

  dataEsperada :=
  (select Data
    from DataEtapa
    where pSerie.NumMod = NumMod and
          pSerie.SexoProva = SexoProva and
          pSerie.DistProva = DistProva and
          rownum = pSerie.Etapa
    order by Data);
    
    return dataEsperada;
end;
/