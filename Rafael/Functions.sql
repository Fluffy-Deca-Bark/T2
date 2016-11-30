-- FUNCTIONS

/**********************************************************************
*	FUNÇÃO:
*		ObterDataEtapa
*	DESCRIÇÃO:
*   	Obtém a data em que ocorre uma etapa (número de 1 a 3) de uma
*																prova
*	PARÂMETROS:
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*		pEtapa		- ENTRADA	- NÚMERO
*			Número de 1 a 3 que representa etapa (1- eliminatória,
*												2- semifinal, 3- final)	
*	RETORNO:
*		DATA - Retorna a data de realização da etapa
**********************************************************************/
create or replace function ObterDataEtapa(pModProva in integer, pSexoProva in char, pDistProva in number, pEtapa in integer)	-- TESTADO
return date as
  dataEsperada date;
begin
  select Data into dataEsperada
    from DataEtapa dataEmTeste
    where pModProva = NumMod and
          pSexoProva = SexoProva and
          pDistProva = DistProva and
            pEtapa-1 =  (select count(*)
                        from DataEtapa
                        where Data < dataEmTeste.Data);
    return dataEsperada;
end ObterDataEtapa;
/

/**********************************************************************
*	FUNÇÃO:
*		CriarCompetidor
*	DESCRIÇÃO:
*   	Cadastra um competidor no BD
*	PARÂMETROS:
*		pNome	- ENTRADA	- STRING
*			Nome do competidor
*		pSexo	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo do competidor
*		pAno	- ENTRADA	- INTEIRO
*			Ano de nascimento do competidor
*	RETORNO:
*		INTEIRO - Retorna o número de inscrição do competidor criado
**********************************************************************/
create or replace function CriarCompetidor (pNome in varchar2, pSexo in char, pAno in integer)		-- TESTADO
return integer as
	inscr integer;
	numCompetidores integer;
begin
	select count(*) into numCompetidores
		from Competidor;
	
	if (numCompetidores = 0) then
		inscr := 1;
	else
		select max(NumInscr) into inscr
			from Competidor;
		inscr := inscr + 1;
	end if;
	
	insert into Competidor(NumInscr,Nome,Sexo,AnoNasc)
		values(inscr,pNome,pSexo,pAno);
	return inscr;
end;
/

/**********************************************************************
*	FUNÇÃO:
*		SelecionarInscritos
*	DESCRIÇÃO:
*   	Seleciona os 64 melhores competidores inscritos em uma prova e
*		muda o atributo "Aprovado" da tabela Inscrito deles para 'S'
*	PARÂMETROS:
*		pModProva	- ENTRADA	- INTEIRO
*			Número da modalidade (ver tabela Modalidade) da prova
*		pSexoProva	- ENTRADA	- CARACTER
*			'M' ou 'F', sexo dos participantes da prova
*		pDistProva	- ENTRADA	- NÚMERO
*			Distância de percurso da prova, em metros
*	RETORNO:
*		INTEIRO - Retorna o número de participates selecionados
**********************************************************************/
create or replace function SelecionarInscritos	(pModProva in integer, pSexoProva in char,					-- RETESTAR
												pDistProva in number)
return integer as
	inscricaoSelecionada Inscrito.NumInscr%type;
	numLinha integer;
	numSelecionados integer;
	
	cursor cursorInscritoMenoresTempos (pModProva integer, pSexoProva char, pDistProva number, pQtdMelhores integer)
	is
	(select *
		from (
		  select NumInscr,
		  row_number() over (order by MelhorTempo, NumInscr) posicao
		  from Inscrito
		  where	NumMod = pModProva and
				SexoProva = pSexoProva and
				DistProva = pDistProva
		)
		where posicao <= pQtdMelhores);
begin
	numSelecionados := 0;
	
	open cursorInscritoMenoresTempos(pModProva,pSexoProva,pDistProva,64);
	loop
		fetch cursorInscritoMenoresTempos into inscricaoSelecionada, numLinha;
		exit when cursorInscritoMenoresTempos%notfound;
		
		update Inscrito
			set Aprovado = 'S'
			where NumInscr = inscricaoSelecionada;
		
		numSelecionados := numSelecionados + 1;
	end loop;
	close cursorInscritoMenoresTempos;
	
	return numSelecionados;
end SelecionarInscritos;
/
