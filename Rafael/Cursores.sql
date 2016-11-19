-- CURSORES

/**********************************************************************
*	CURSOR:
*		cursorInscritoMenoresTempos
*	DESCRIÇÃO:
*   	Registro da tabela Inscrito, apenas com as linhas com coluna
*		"MelhorTempo" com valores mais baixos
*	PARÂMETROS:
*		pQtdMelhores	- NÚMERO
*			Quantidade de linhas que registro possuirá (quantidade de
*													melhores tempos)
**********************************************************************/
cursor cursorInscritoMenoresTempos (pQtdMelhores number)
is
	select *
	from Inscrito tempoEmTeste
	where pQtdMelhores >	(select count(*) as qtdTemposMelhores
							from Inscrito
							where MelhorTempo < tempoEmTeste.MelhorTempo);