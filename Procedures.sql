-- PROCEDURES

/**********************************************************************
*	PROCEDURE:
*		CriarProva
*	DESCRIÇÃO:
*   	Cria uma prova
*	PARÂMETROS:
*			pMod		- ENTRADA	- NÚMERO
*				Número da modalidade (ver tabela Modalidade) da prova
*			pSexo	- ENTRADA	- CARACTER
*				'M' ou 'F', sexo dos participantes da prova
*			pDist		- ENTRADA	- NÚMERO
*				Distância de percurso da prova, em metros
*			pData1		- ENTRADA	- DATA
*				Data da etapa eliminatória
*			pData2		- ENTRADA	- DATA
*				Data da etapa semifinal
*			pData3		- ENTRADA	- DATA
*				Data da etapa final	
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
*		SelecionarParticipantes
*	DESCRIÇÃO:
*   	Seleciona melhores participantes inscritos em uma prova e
*		aloca-os em séries e raias aleatórias da etapa eliminatória
*	PARÂMETROS:
*		pModProva	- ENTRADA	- NÚMERO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
**********************************************************************/
create or replace procedure SelecionarParticipantes	(pMod in number, pSexoProva in char,
													pDist in number)
as
begin
	
end SelecionarParticipantes;