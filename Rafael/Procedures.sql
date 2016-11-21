-- PROCEDURES

/**********************************************************************
*	PROCEDURE:
*		CriarProva
*	DESCRIÇÃO:
*   	Cria uma prova
*	PARÂMETROS:
*		pMod		- ENTRADA	- NÚMERO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexo	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDist		- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pData1		- ENTRADA	- DATA
*			Data da etapa eliminatória
*		pData2		- ENTRADA	- DATA
*			Data da etapa semifinal
*		pData3		- ENTRADA	- DATA
*			Data da etapa final	
**********************************************************************/
create or replace procedure CriarProva	(pMod in number, pSexo in char, pDist in number,
										pData1 in date, pData2 in date, pData3 in date)
as
begin
	insert into Prova(NumMod,Sexo,Dist)
		values (pMod,pSexo,pDist);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values (pMod,pDist,pSexo,pData1);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values (pMod,pDist,pSexo,pData2);
	insert into DataEtapa(NumMod,DistProva,SexoProva,Data)
		values (pMod,pDist,pSexo,pData3);
end CriarProva;

/**********************************************************************
*	PROCEDURE:
*		CriarSeries
*	DESCRIÇÃO:
*   	Cria séries necessárias pra realizção de uma prova, segundo a
*		quantidade de particpantes selecionados
*	PARÂMETROS:
*		pMod				- ENTRADA	- NÚMERO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexo				- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDist				- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pNumParticipantes	- ENTRADA	- NÚMERO
*			Número de participantes total que participará na prova
*														(de 0 a 64)
**********************************************************************/
create or replace procedure CriarSeries	(pMod in number, pSexo in char, pDist in number,
										pNumParticipantes in number)
as
begin
	
end CriarSeries;