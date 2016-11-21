-- FUNCTIONS

/**********************************************************************
*	FUNÇÃO:
*		ObterEtapaSerie
*	DESCRIÇÃO:
*   	Obtém a data em que ocorre uma série, através de sua etapa
*	PARÂMETROS:
*		pSerie	- ENTRADA - SERIE%ROWTYPE
*			linha correspondente à série
*	RETORNO:
*		DATA - Retorna a data de realização da série
**********************************************************************/
create or replace function ObterDataSerie(pSerie in serie%rowtype)
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
end ObterEtapaSerie;


/**********************************************************************
*	FUNÇÃO:
*		SelecionarParticipantes
*	DESCRIÇÃO:
*   	Seleciona melhores participantes inscritos em uma prova e
*		muda o atributo "Aprovado" da tabela Inscrito deles para 'S'
*	PARÂMETROS:
*		pModProva	- ENTRADA	- NÚMERO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*	RETORNO:
*		NÚMERO - Retorna o número de participates selecionados
**********************************************************************/
create or replace function SelecionarParticipantes	(pMod in number, pSexoProva in char,
													pDist in number)
return number as
	linhaInscritoSelecionado Inscrito%rowtype;
	numSelecionados number;
	
	cursor cursorInscritoMenoresTempos (pModProva number, pSexoProva number, pDistProva, pQtdMelhores number)
	is
	select *
	from Inscrito tempoEmTeste
	where pQtdMelhores >	(select count(*) as qtdTemposMelhores
							from Inscrito
							where MelhorTempo < tempoEmTeste.MelhorTempo);
begin
	numSelecionados := 0;
	
	open cursorInscritoMenoresTempos(64);
	loop
		fetch cursorInscritoMenoresTempos into linhaInscritoSelecionado;
		exit when cursorInscritoMenoresTempos%notfound;
		
		update Inscrito
		set Aprovado = 'S'
		where NumInscr = linhaInscrito.NumInscr;
		
		numSelecionados := numSelecionados + 1;
	end loop;
	close cursorInscritoMenoresTempos;
	
	return numSelecionados;
end SelecionarParticipantes;