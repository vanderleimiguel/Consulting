#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} GESTFINJ
	concilia titulo
	@type function
	@version 1.0
	@author Wagner Neves
	@since 04/11/2023
/*/
user function GESTFINJ(cTmp)
	MsgRun("Consultando movimentos para conciliacao ...","Aguarde",{|| fpergunta() })
return

Static Function fPergunta()
	Local aPergs   	:= {}
	Local dDataDe  	:= FirstDate(Date())
	Local dDataAt  	:= LastDate(Date())
	Private cBanco 	:= Space(TamSX3('E5_BANCO')[01])
	Private cBcoNom	:= ""
	Private cAgencia:= Space(TamSX3('E5_AGENCIA')[01])
	Private cConta 	:= Space(TamSX3('E5_CONTA')[01])
	private cModo		:= FwModeAccess("SE5", 1) + FwModeAccess("SE5", 2) + FwModeAccess("SE5", 3)

	//Cria Consulta Padrao
	zCriaCEsp("XSEE", "Consulta Banco 4Fin", "SEE", "U_cEspXSEE()")

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Banco"	, cBanco	,  "", "", "XSEE", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Agencia"	, cAgencia	,  "", "", "", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Conta"	, cConta	,  "", "", "", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Data De"	, dDataDe	,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até"	, dDataAt	,  "", ".T.", "", ".T.", 80,  .F.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, "Informe os Parametros")
		cBanco		:= MV_PAR01
		cBcoNom     := MV_PAR01
		cAgencia	:= MV_PAR02
		cConta		:= MV_PAR03
		SA6->( DbSetOrder(1) )
		If SA6->(DbSeek(xFilial("SA6")+cBanco+cAgencia+cConta))
			cBcoNom	:= cBanco + "-" + SA6->A6_NREDUZ
		EndIf
		fMontaTela()
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Desc:  Função para montar tela    							       |
 *---------------------------------------------------------------------*/
Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos 		:= {}
	Local oTempTable 	:= Nil
	Local aColunas 		:= {}
	Local cFontPad    	:= 'Tahoma'
	Local oFontGrid   	:= TFont():New(cFontPad,,-14)
	Local aSeek   		:= {}
	local nInd			as numeric
	local aSE5			:= FwSx3Util():getAllFields("SE5",.F.)
	local aAux			:= {}
	local aFilter		:= {}
	local aBrowse		:= Iif(Right(cModo,2) == "CC",{},{"E5_FILIAL"})
	local cTitSeek		as character
	//Janela e componentes
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp 	:= GetNextAlias()
	Private aRotina   	:= MenuDef()
	//Tamanho da janela
	Private aTamanho 	:= MsAdvSize()
	Private nJanLarg 	:= aTamanho[5]
	Private nJanAltu 	:= aTamanho[6]
	Private lVoltar		:= .F.
	Private nMarcado	:= 0
	Private nValorMar	:= 0
	Private nQtdTot     := 0
	Private nVlrTot     := 0
	Private cFontUti    := "Tahoma"
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontTitP   := TFont():New(cFontUti, , -10)

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK'		, 'C', 2						, 0})
	aAdd(aCampos, { 'E5_FILIAL'	, 'C', TamSX3("E5_FILIAL")[1]	, 0})
	aAdd(aCampos, { 'E5_DTDISPO', 'D', TamSX3("E5_DTDISPO")[1]	, 0})
	aAdd(aCampos, { 'E5_PREFIXO', 'C', TamSX3("E5_PREFIXO")[1]	, 0})
	aAdd(aCampos, { 'E5_NUMERO'	, 'C', TamSX3("E5_NUMERO")[1]	, 0})
	aAdd(aCampos, { 'E5_PARCELA', 'C', TamSX3("E5_PARCELA")[1]  , 0})
	aAdd(aCampos, { 'E5_VALOR'	, 'N', TamSX3("E5_VALOR")[1]	, 2})
	aAdd(aCampos, { 'E5_CLIFOR'	, 'C', TamSX3("E5_CLIFOR")[1]	, 0})
	aAdd(aCampos, { 'E5_LOJA'	, 'C', TamSX3("E5_LOJA")[1]		, 0})
	aAdd(aCampos, { 'E5_BANCO'	, 'C', TamSX3("E5_BANCO")[1]	, 0})
	aAdd(aCampos, { 'E5_AGENCIA', 'C', TamSX3("E5_AGENCIA")[1]	, 0})
	aAdd(aCampos, { 'E5_CONTA'	, 'C', TamSX3("E5_CONTA")[1]	, 0})
	aAdd(aCampos, { 'E1Recno'	, 'N', 20	, 0})
	aAdd(aCampos, { 'E5Recno'	, 'N', 20	, 0})

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"E5_FILIAL", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA"})
	oTempTable:addIndex("2", {"E1Recno"})
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//Criando a janela

    // cCampoAux := "E5_NUMERO"
    // aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}}}  )
    // cCampoAux := "E5_PREFIXO"
    // aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}}}  )

	for nInd := 1 to Len(aSE5)
		aAux := FwSx3Util():getFieldStruct(aSE5[nInd])
		if GetSx3Cache(aAux[1],"X3_BROWSE") == "S"
			aAdd(aBrowse,aAux[1])
		endif
		aAdd(aFilter,{	aAux[1],;
						AllTrim(GetSx3Cache(aAux[1],"X3_TITULO")),;
						aAux[2],;
						aAux[3],;
						aAux[4],;
						""})
	next nInd

	aAux := {} ; cTitSeek := ""

	aEval(Separa(SE5->(IndexKey(7)),"+",.F.),;
			{|x| cTitSeek += Iif(! "FILIAL" $ x .or. Right(cModo,2) != "CC",Trim(GetSx3Cache(x,"X3_TITULO"))+"+","") })

	aEval(Separa(SE5->(IndexKey(7)),"+",.F.),;
			{|x| aAdd(aAux,{"",;
							GetSx3Cache(x,"X3_TIPO"),;
							GetSx3Cache(x,"X3_TAMANHO"),;
							GetSx3Cache(x,"X3_DECIMAL"),;
							AllTrim(GetSx3Cache(x,"X3_TITULO")),;
							AllTrim(GetSx3Cache(x,"X3_PICTURE"))}) })
	aAdd(aSeek,{cTitSeek,aAux})

	DEFINE MSDIALOG oDlgMark TITLE 'Conciliacao de Titulos' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
	//Cabecalho
	@ 002,010 SAY oSay0 PROMPT "Titulos a serem conciliados do banco:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 015,010 SAY oSay1 PROMPT "Banco:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 025,010 MSGET cBcoNom Picture "@!" WHEN .F. Size 090,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 015,110 SAY oSay2 PROMPT "Agencia:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 025,110 MSGET cAgencia Picture "@!" WHEN .F. Size 090,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 015,210 SAY oSay3 PROMPT "Conta:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 025,210 MSGET cConta Picture "@!" WHEN .F. Size 090,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	
	//Rodape
	@ 305,010 SAY oSay4 PROMPT "Qtd de Titulos:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,010 MSGET nQtdTot Picture "@E 999,999" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,130 SAY oSay5 PROMPT "Total de Titulos R$:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,130 MSGET nVlrTot Picture "@E 99,999,999.99" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,250 SAY oSay6 PROMPT "Títulos Marcados:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,250 MSGET nMarcado Picture "@E 999,999" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,370 SAY oSay7 PROMPT "Valor Marcado R$:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,370 MSGET nValorMar Picture "@E 99,999,999.99" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL

	//Dados
	oPanGrid := tPanel():New(050, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, 250)
	oMarkBrowse := FWMarkBrowse():New()
	// oMarkBrowse:SetDescription('Títulos de Comissões')
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:oBrowse:SetDBFFilter(.T.)
    oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
    oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
    oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
    oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:oBrowse:SetSeek(,aSeek)
	oMarkBrowse:oBrowse:setFieldFilter(aFilter)//teste
	oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:SetColumns(aColunas)
	oMarkBrowse:SetAfterMark({|| fMarcado()})
	// oMarkBrowse:SetAllMark({|| oMarkBrowse:AllMark() })
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMarcado                                                     |
 | Desc:  Função para atualizar valores							       |
 *---------------------------------------------------------------------*/
Static Function fMarcado()
	Local cMarca    	:= oMarkBrowse:Mark()

	If oMarkBrowse:IsMark(cMarca)
		nMarcado++
		nValorMar	+= (cAliasTmp)->E5_VALOR
	Else
		nMarcado--
		nValorMar	-= (cAliasTmp)->E5_VALOR
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Função para botoes do menu							       |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções do menu
	ADD OPTION aRotina TITLE 'Voltar'  ACTION 'U_fFinjVolt'     OPERATION 6 ACCESS 0	
	ADD OPTION aRotina TITLE 'Conciliar Titulos'  ACTION 'U_fBtnConc'     OPERATION 3 ACCESS 0

Return aRotina

/*---------------------------------------------------------------------*
 | Func:  fPopula                                                      |
 | Desc:  Função para popular tabela temporaria					       |
 *---------------------------------------------------------------------*/
Static Function fPopula()
	Local cQryDados := ''
	Local nTotal 	:= 0
	Local nAtual 	:= 0

	nQtdTot	:= 0
	nVlrTot	:= 0
	
	//Busca titulos atraves dos parametros
	cQryDados := " SELECT E5_RECPAG,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_VALOR,E5_DTDISPO,E5_CLIFOR,E5_LOJA,E5_FILIAL,E5_BANCO,E5_AGENCIA,E5_CONTA,"
	cQryDados += " SE1.E1_SALDO, SE5.R_E_C_N_O_ AS E5RECNO, SE1.R_E_C_N_O_ AS E1RECNO "
	cQryDados += " FROM "+RetSqlName("SE5")+" SE5 "
	cQryDados += " INNER JOIN "+RetSqlName("SE1")+" SE1 ON SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO AND SE1.E1_PARCELA = SE5.E5_PARCELA AND SE1.E1_CLIENTE = SE5.E5_CLIFOR AND SE1.E1_LOJA = SE5.E5_LOJA AND SE1.D_E_L_E_T_ = ' '"
	cQryDados += " WHERE E5_BANCO = '" + cBanco + "' AND " + CRLF
	cQryDados += " E5_AGENCIA = '" + cAgencia + "' AND " + CRLF
	cQryDados += " E5_CONTA   = '" + cConta + "' AND " + CRLF
	cQryDados += " E5_DTDISPO BETWEEN '"+dtoS(MV_PAR04)+"' AND '"+dtoS(MV_PAR05)+"' AND " + CRLF
	cQryDados += " E5_RECONC = ' ' AND " + CRLF
	cQryDados += " E5_RECPAG = 'R' AND " + CRLF
	cQryDados += " E5_DTCANBX = ' ' AND " + CRLF
	cQryDados += " E1_SALDO = 0 AND " + CRLF
	cQryDados += " SE5.D_E_L_E_T_ = ' '" 
	cQryDados += " ORDER BY E5_DTDISPO,E5_FILIAL,E5_PREFIXO,E5_NUMERO "
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Carregando registro: ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		nQtdTot++
		nVlrTot	+= QRYDADTMP->E5_VALOR

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		(cAliasTmp)->E5_FILIAL	:= QRYDADTMP->E5_FILIAL
		(cAliasTmp)->E5_PREFIXO := QRYDADTMP->E5_PREFIXO
		(cAliasTmp)->E5_NUMERO	:= QRYDADTMP->E5_NUMERO
		(cAliasTmp)->E5_PARCELA	:= QRYDADTMP->E5_PARCELA
		(cAliasTmp)->E5_VALOR 	:= QRYDADTMP->E5_VALOR
		(cAliasTmp)->E5_DTDISPO := QRYDADTMP->E5_DTDISPO
		(cAliasTmp)->E5_CLIFOR	:= QRYDADTMP->E5_CLIFOR
		(cAliasTmp)->E5_LOJA 	:= QRYDADTMP->E5_LOJA
		(cAliasTmp)->E5_BANCO	:= QRYDADTMP->E5_BANCO
		(cAliasTmp)->E5_AGENCIA	:= QRYDADTMP->E5_AGENCIA
		(cAliasTmp)->E5_CONTA	:= QRYDADTMP->E5_CONTA
		(cAliasTmp)->E1Recno 	:= QRYDADTMP->E1RECNO	
		(cAliasTmp)->E5Recno 	:= QRYDADTMP->E5RECNO	
		(cAliasTmp)->(MsUnlock())
		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

/*---------------------------------------------------------------------*
 | Func:  fCriaCols                                                    |
 | Desc:  Função para criar colunas do browse    				       |
 *---------------------------------------------------------------------*/
Static Function fCriaCols()
	Local nAtual       := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	aAdd(aEstrut, { 'E5_FILIAL'	, 'Filial'	, 'C', TamSX3("E5_FILIAL")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_PREFIXO', 'Prefixo'	, 'C', TamSX3("E5_PREFIXO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_NUMERO'	, 'Numero'	, 'C', TamSX3("E5_NUMERO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_PARCELA', 'Parcela'	, 'C', TamSX3("E5_PARCELA")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_VALOR'	, 'Valor'	, 'N', TamSX3("E5_VALOR")[1]	, 2, '@E 9,999,999,999,999.99'})
	aAdd(aEstrut, { 'E5_DTDISPO', 'Data Dispon'	, 'D', 10, 0, ''})
	aAdd(aEstrut, { 'E5_CLIFOR'	, 'Cliente'	, 'C', TamSX3("E5_CLIFOR")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_LOJA'	, 'Loja'	, 'C', TamSX3("E5_LOJA")[1]		, 0, ''})
	aAdd(aEstrut, { 'E5_BANCO'	, 'Banco'	, 'C', TamSX3("E5_BANCO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_AGENCIA', 'Agencia'	, 'C', TamSX3("E5_AGENCIA")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_CONTA'	, 'Conta'	, 'C', TamSX3("E5_CONTA")[1]	, 0, ''})

	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])

		//Adiciona a coluna
		aAdd(aColunas, oColumn)
	Next
Return aColunas

/*---------------------------------------------------------------------*
 | Func:  fVoltar                                                      |
 | Desc:  Função do botão voltar    		    				       |
 *---------------------------------------------------------------------*/
User Function fFinjVolt()
	(eval({||oDlgMark:End()}))	
Return

/*---------------------------------------------------------------------*
 | Func:  fBtnConc                                                     |
 | Desc:  Função do botão conciliar	    				               |
 *---------------------------------------------------------------------*/
User Function fBtnConc()
	Processa({|| fProcessa(), oDlgMark:End()}, 'Selecionando títulos...')
Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função processa conciliacao   				               |
 *---------------------------------------------------------------------*/
static function fProcessa()
	Local aArea     := FWGetArea()
	local nOpc as numeric
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc 	:= 0
	Local nRecSE1   := 0

	//Define o tamanho da régua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Conciliar Marcados","Cancelar"},2)

	if nOpc == 2
		return
	endif

	if nOpc == 1
		//Percorrendo os registros
		(cAliasTmp)->(DbGoTop())
		While ! (cAliasTmp)->(EoF())
			nAtual++
			IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

			//Caso esteja marcado
			If oMarkBrowse:IsMark(cMarca)
				nTotMarc++

				nRecSE1	:= (cAliasTmp)->E1Recno
				nRecSE5	:= (cAliasTmp)->E5Recno
				SE1->( dbGoto(nRecSE1) )
				Reclock("SE1", .F.)
				SE1->E1_PORTADO := cBanco
				SE1->E1_AGEDEP 	:= cAgencia
				SE1->E1_CONTA	:= cConta
				SE1->( MsUnLock() )
				
				U_XConcilia(nRecSE1, nRecSE5)
					
			EndIf

		(cAliasTmp)->(DbSkip())
		EndDo
	EndIf

	//Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
	FWAlertInfo('Foram conciliados [' + cValToChar(nTotMarc) + '] titulos', 'Atenção')
	//oDlgMark:End()

	FWRestArea(aArea)

return

/*---------------------------------------------------------------------*
 | Func:  XConcilia                                                    |
 | Desc:  Função inicia conciliacao      				               |
 *---------------------------------------------------------------------*/
User Function XConcilia(nRecSE1, nRecSE5)
	Local cIdProc	:= ""
	Local cSeqCon   := ""
	Local cBcoCon   := ""
	Local cAgnCon   := ""
	Local cCntCon   := ""
	Default nRecSE5 := 0

	SE1->( dbGoto(nRecSE1) )

	if SE1->E1_SALDO == 0
		If ProcName(1) == "FPROCESSA"
			cBcoCon   := SE1->E1_PORTADO
			cAgnCon   := SE1->E1_AGEDEP
			cCntCon   := SE1->E1_CONTA
		Else
			cBcoCon   := SE5->E5_BANCO
			cAgnCon   := SE5->E5_AGENCIA
			cCntCon   := SE5->E5_CONTA
		EndIf

		mv_par01	:=  cBcoCon // Banco
		mv_par02	:=  cAgnCon  // Agencia
		mv_par03	:=  cCntCon   // Conta
		mv_par04	:=  SE1->E1_VENCREA // Data de
		mv_par05	:=  SE1->E1_VENCREA // Data ate
		mv_par06	:= 1                // Aglutina lancamentos
		mv_par07	:= 1                // Mostra lanc. contabeis
		mv_par08	:= 2                // Contabiliza on-line
		mv_par09	:= 2                // Seleciona filial
		mv_par10	:= 2                // exibe baixas com estorno

		cIdProc	:= F473ProxNum("SIF")
		RecLock("SIF",.T.)
		SIF->IF_FILIAL 	:= xFilial("SIF")
		SIF->IF_IDPROC  := cIdProc
		SIF->IF_DTPROC  := SE1->E1_VENCREA
		SIF->IF_BANCO	:= SE1->E1_PORTADO
		SIF->IF_DESC	:= "Conciliado por GestFin"
		SIF->IF_STATUS 	:= '1'
		SIF->IF_ARQCFG	:= ""
		SIF->IF_ARQIMP	:= ""
		SIF->IF_ARQSUM	:= ""
		SIF->(MsUnlock())

		// Grava SIG
		cSeqCon   := F473ProxNum("SIG")
		RecLock("SIG",.T.)
		SIG->IG_FILIAL 	:= xFilial("SIG")
		SIG->IG_IDPROC	:= cIdProc
		SIG->IG_ITEM	:= "00001"
		SIG->IG_STATUS	:= '1'
		SIG->IG_DTEXTR	:= SE1->E1_VENCREA
		SIG->IG_DTMOVI	:= SE1->E1_VENCREA
		SIG->IG_DOCEXT	:= SE1->E1_NUM
		SIG->IG_SEQMOV  := cSeqCon
		SIG->IG_VLREXT 	:= SE1->E1_VALOR
		SIG->IG_TIPEXT	:= "001"
		SIG->IG_CARTER	:= "02"
		SIG->IG_AGEEXT  := cAgnCon
		SIG->IG_CONEXT  := cCntCon
		SIG->IG_HISTEXT := "Conciliado por GestFin"
		SIG->IG_FILORIG := cFilAnt
		SIG->(MsUnlock())

		If nRecSE5 == 0
			nRecSE5 := fFindSE5(SE1->E1_VENCREA, cBcoCon, cAgnCon, cCntCon, SE1->E1_TIPO,;
				SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_CLIENTE, SE1->E1_LOJA)
		EndIf
		If nRecSE5 > 0
			// fGrvSldBc(nRecSE5)
			fConciliar(nRecSE5, cSeqCon)
		EndIf
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fGrvSldBc                                                    |
 | Desc:  Função efetua atualizacao de saldo bancario	               |
 *---------------------------------------------------------------------*/
Static Function fGrvSldBc(_nRecSE5)
	Local dDtDisp
	Local nValor	:= 0
	Local cQuery    := ""
	Local cAliasSE8	:= GetNextAlias()

	SE5->(DbGoTo(_nRecSE5))
	dDtDisp	:= SE5->E5_DTDISPO
	nValor  := SE5->E5_VALOR

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM "+RetSqlName('SE8')+" SE8 "
	cQuery += " WHERE E8_BANCO = '" + cBanco + "' AND " + CRLF
	cQuery += " E8_AGENCIA = '" + cAgencia + "' AND " + CRLF
	cQuery += " E8_CONTA   = '" + cConta + "' AND " + CRLF
	cQuery += " E8_DTSALAT >= '"+dtoS(dDtDisp)+"' AND " + CRLF
	cQuery += " SE8.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSE8,.F.,.T.)

	(cAliasSE8)->(DbGoTop())

	While (cAliasSE8)->(!EOF())
		SE8->(DbGoTo((cAliasSE8)->RECNO)) 
			Reclock("SE8", .F.)
			SE8->E8_SALRECO := SE8->E8_SALRECO + nValor
			SE8->( MsUnLock() )
		(cAliasSE8)->(DbSkip())
	EndDo
	(cAliasSE8)->(DbCloseArea())

Return

/*---------------------------------------------------------------------*
 | Func:  fConciliar                                                   |
 | Desc:  Função efetua conciliacao       				               |
 *---------------------------------------------------------------------*/
Static Function fConciliar(nRECSE5, cSeqCon)
	Local cStatus	:= ""
	Local lAtuDtDisp:= .T.
	Local lDesconc	:= .F.
	Local dDataExt	:= CTOD("")
	Local dDataMov	:= CTOD("")
	Local dDataNova	:= CTOD("")
	Local lFK5		:= .F.
	Local lFKs		:= .T.
	Local cFilFKA	:= ''
	Local cIdOrig	:= ''
	Local nRecDesco := 0

	DbSelectArea("FKA")
	DbSelectArea("FK5")
	FK5->( DbSetOrder(1) )
	SIF->( DbSetOrder(1) ) //IF_FILIAL+IF_IDPROC
	SIG->( DbSetOrder(2) ) //IG_SEQMOV
	SE5->( DbSetOrder(20)) //E5_FILIAL+E5_SEQCON
	SA6->( DbSetOrder(1) )

	cStatus	 := "1"
	lDesconc := .F.
	dDataExt  := SE1->E1_VENCREA
	dDataMov  := SE1->E1_VENCREA

	//Atualiza SE5 e atualiza o Saldo
	If nRECSE5 > 0
		nRECSE5 := IIf(nRECSE5 == 0, nRecDesco, nRECSE5)
		SE5->(DbGoTo(nRECSE5))
		FKA->(DbSetOrder(3))

		If SE5->E5_TABORI == "FK1"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK1" + SE5->E5_IDORIG ) )
			lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
			lFKs := .T. // Possui dados migrados
		ElseIf SE5->E5_TABORI == "FK2"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK2" + SE5->E5_IDORIG ) )
			lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
			lFKs := .T. // Possui dados migrados
		ElseIf SE5->E5_TABORI == "FK5"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK5" + SE5->E5_IDORIG ) )
			lFK5 := .T. // NÃO PRECISA fazer o loop na FKA procurando o registro de Movimentação Bancaria, pois esse é o registro de movimentação
			lFKs := .T. // Possui dados migrados
			cIdOrig := FKA->FKA_IDORIG
			cFilFKA := FKA->FKA_FILIAL
		ElseIf Empty(SE5->E5_TABORI)
			lFKs := .F. // NÃO POSSUI dados migrados
		EndIf

		If lFKs //Possui dados migrados
			cIdProc := FKA->FKA_IDPROC

			If !lFK5 // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
				FKA->( DbSetOrder(2) )
				FKA->( DbSeek( FKA->FKA_FILIAL + cIdProc ) )

				While FKA->(!EoF()) .And. FKA->FKA_IDPROC == cIdProc
					If FKA->FKA_TABORI == "FK5"
						cIdOrig := FKA->FKA_IDORIG
						cFilFKA := FKA->FKA_FILIAL
					EndIf
					FKA->(DbSkip())
				Enddo
			EndIf

			If FK5->(DbSeek(cFilFKA + cIdOrig ) )
				If !lDesconc //Conciliou
					Reclock("SE5", .F.)
					SE5->E5_RECONC := 'x'
					SE5->E5_SEQCON := cSeqCon
					SE5->( MsUnLock() )

					Reclock("FK5", .F.)
					FK5->FK5_DTCONC	:= dDataBase
					FK5->FK5_SEQCON	:= cSeqCon
					FK5->( MsUnLock() )
				Else //Desconciliou
					Reclock("SE5", .F.)
					SE5->E5_RECONC	:= ' '
					SE5->E5_SEQCON	:= ' '
					SE5->( MsUnLock() )

					Reclock("FK5", .F.)
					FK5->FK5_DTCONC	:= CTOD("")
					FK5->FK5_SEQCON	:= ""
					FK5->( MsUnLock() )
				EndIf
			Else
				cLog := "Registro não localizado na tabela FK5" + cFilFKA + "' " + "Filial: " + cIdOrig + "' "//"Registro não localizado na tabela FK5. Filial: '"
				Help( ,,"MF473GRV1",,cLog, 1, 0 )
			EndIf
		Else //Registro da SE5 não possui dados nas Tabelas FKs, não foi migrado.
			If !lDesconc //Conciliou
				Reclock( "SE5", .F. )
				SE5->E5_RECONC	:= 'x'
				SE5->E5_SEQCON	:= cSeqCon
				SE5->( MsUnLock() )
			Else //Desconciliou
				Reclock( "SE5", .F. )
				SE5->E5_RECONC	:= ' '
				SE5->E5_SEQCON	:= ' '
				SE5->( MsUnLock() )
			EndIf
		EndIf

		If lDesconc
			dDataNova := dDataMov
		Else
			dDataNova := dDataExt
		EndIf

		//Acerto E5_DTDISPO dos titulos baixados
		If dDataNova !=  SE5->E5_DTDISPO .and. lAtuDtDisp
			dOldDispo := SE5->E5_DTDISPO

			If lFKs // Possui dados migrados
				//Posiciona a FK5 com base no IDORIG da SE5 posicionada
				DbSelectArea("FK5")
				FK5->( DbSetOrder(1) )

				If FK5->(DbSeek(xFilial("SE5")+cIdOrig))
					Reclock("FK5", .F.)
					FK5->FK5_DTDISP	:= SE5->E5_DTDISPO
					FK5->(MsUnlock())

					If SE5->E5_RECPAG == "P"
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
					Else
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
					EndIf

				Else
					cLog := "Registro não localizado na tabela FK5" + cFilFKA + "' " + "Filial: " + cIdOrig + "' " //"Registro não localizado na tabela FK5. Filial: '"
					Help( , , "MF473GRV2", , "Não foi possivel atualizar o Saldo do Banco" + CRLF + cLog, 1, 0 ) // "Não foi possivel atualizar o Saldo do Banco."
				EndIf

			Else // Registro da SE5 não possui dados nas Tabelas FKs, dados não foram migrados.
				If SE5->E5_RECPAG == "P"
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
				Else
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
				EndIf
			EndIf

		Else
			//Atualiza apenas o saldo reconciliado
			If lDesconc	    //Desconciliou
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
			Else //Conciliou
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
			EndIf
		EndIf
	EndIf

Return .T.

Static Function F473ProxNum(cTab)
	Local cNovaChave := ""
	Local aArea := GetArea()
	Local cCampo := ""
	Local cChave
	Local nIndex := 0

	If cTab == "SIF"
		SIF->(dbSetOrder(1))//IF_FILIAL+IF_IDPROC
		cCampo := "IF_IDPROC"
		nIndex := 1
	Else
		SIG->(dbSetOrder(2))//IG_FILIAL+IG_SEQMOV
		cCampo := "IG_SEQMOV"
		cChave := "IG_SEQMOV"+cEmpAnt
		nIndex := 2
	EndIf


	While .T.
		(cTab)->(dbSetOrder(nIndex))
		cNovaChave := GetSXEnum(cTab,cCampo,cChave,nIndex)
		ConfirmSX8()
		If cTab == "SIF"
			If (cTab)->(!dbSeek(xFilial(cTab) + cNovaChave) )
				Exit
			EndIf
		Else
			If (cTab)->(!dbSeek(cNovaChave) )
				Exit
			EndIf
		EndIf
	EndDo

	RestArea(aArea)
Return cNovaChave

/*---------------------------------------------------------------------*
 | Func:  fFindSE5                                                     |
 | Desc:  Função procura titulo na SE5    				               |
 *---------------------------------------------------------------------*/
static Function fFindSE5(dData, _cBanco, _cAgencia, _cConta, cTipo, cPrefixo, cNum, cParcela, cCliFor, cLoja)
	Local nRec		:= 0
	Local cQuery    := ""
	Local cAlias 	:= GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM "+RetSqlName('SE5')+" SE5 "
	cQuery += " WHERE "
	cQuery += " E5_BANCO = '" + _cBanco + "' AND " + CRLF
	cQuery += " E5_AGENCIA = '" + _cAgencia + "' AND " + CRLF
	cQuery += " E5_CONTA   = '" + _cConta + "' AND " + CRLF
	cQuery += " E5_SITUACA <> 'C' AND " + CRLF
	cQuery += " E5_RECONC = ' ' AND " + CRLF
	cQuery += " E5_PREFIXO = '" + cPrefixo + "' AND " + CRLF
	cQuery += " E5_NUMERO = '" + cNum + "' AND " + CRLF
	cQuery += " E5_PARCELA = '" + cParcela + "' AND " + CRLF
	cQuery += " E5_TIPO = '" + cTipo + "' AND " + CRLF
	cQuery += " E5_CLIFOR = '" + cCliFor + "' AND " + CRLF
	cQuery += " E5_DTCANBX = ' ' AND " + CRLF
	cQuery += " E5_RECPAG = 'R' AND " + CRLF
	cQuery += " E5_LOJA = '" + cLoja + "' AND " + CRLF
	cQuery += " SE5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		nRec := (cAlias)->RECNO
	EndIf
	(cAlias)->(DbCloseArea())

Return nRec

/*---------------------------------------------------------------------*
 | Func:  zCriaCEsp                                                    |
 | Desc:  Função cria consulta padrao   				               |
 *---------------------------------------------------------------------*/
Static Function zCriaCEsp(cConsulta, cDescricao, cAliasCons, cFuncao)
    Local aArea        := GetArea()
    Local aAreaXB      := SXB->(GetArea())
    Default cConsulta  := ""
    Default cDescricao := ""
    Default cAliasCons := ""
    Default cFuncao    := ""
     
    //Se tiver consulta, função e retorno
    If !Empty(cConsulta) .And. !Empty(cFuncao)
        //Caso não encontre, será criado os dados
        DbSelectArea("SXB")
        If !SXB->(DbSeek(cConsulta))
         
            //Descrição
            RecLock("SXB",.T.)
                XB_ALIAS   := cConsulta
                XB_TIPO    := "1"
                XB_SEQ     := "01"
                XB_COLUNA  := "RE"
                XB_DESCRI  := cDescricao
                XB_DESCSPA := cDescricao
                XB_DESCENG := cDescricao
                XB_CONTEM  := cAliasCons
                XB_WCONTEM := ""
            SXB->(MsUnlock())
             
            //Função
            RecLock("SXB",.T.)
                XB_ALIAS   := cConsulta
                XB_TIPO    := "2"
                XB_SEQ     := "01"
                XB_COLUNA  := "01"
                XB_DESCRI  := ""
                XB_DESCSPA := ""
                XB_DESCENG := ""
                XB_CONTEM  := cFuncao
                XB_WCONTEM := ""
            SXB->(MsUnlock())
             
            //Retorno
            RecLock("SXB",.T.)
                XB_ALIAS   := cConsulta
                XB_TIPO    := "5"
                XB_SEQ     := "01"
                XB_COLUNA  := ""
                XB_DESCRI  := ""
                XB_DESCSPA := ""
                XB_DESCENG := ""
                XB_CONTEM  := "SEE->EE_CODIGO"
                XB_WCONTEM := ""
            SXB->(MsUnlock())

            RecLock("SXB",.T.)
                XB_ALIAS   := cConsulta
                XB_TIPO    := "5"
                XB_SEQ     := "02"
                XB_COLUNA  := ""
                XB_DESCRI  := ""
                XB_DESCSPA := ""
                XB_DESCENG := ""
                XB_CONTEM  := "SEE->EE_AGENCIA"
                XB_WCONTEM := ""
            SXB->(MsUnlock())

            RecLock("SXB",.T.)
                XB_ALIAS   := cConsulta
                XB_TIPO    := "5"
                XB_SEQ     := "03"
                XB_COLUNA  := ""
                XB_DESCRI  := ""
                XB_DESCSPA := ""
                XB_DESCENG := ""
                XB_CONTEM  := "SEE->EE_CONTA"
                XB_WCONTEM := ""
            SXB->(MsUnlock())
        EndIf
    EndIf
     
    RestArea(aAreaXB)
    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  cEspXSEE                                                     |
 | Desc:  Função conuslta padrao customizada			               |
 *---------------------------------------------------------------------*/
User Function cEspXSEE()
	Local oDlg, oLbx
   	Local aCpos  := {}
   	Local aRet   := {}
   	Local cQuery := ""
   	Local cAlias := GetNextAlias()
   	Local lRet   := .F.

   	cQuery := " SELECT DISTINCT SEE.EE_CODIGO, SEE.EE_AGENCIA, SEE.EE_CONTA, SEE.EE_SUBCTA "
   	cQuery += " FROM " + RetSqlName("SEE") + " SEE "
   	cQuery += " WHERE SEE.D_E_L_E_T_ = ' ' "
   	cQuery += " AND SEE.EE_FILIAL  = '" + xFilial("SEE") + "' "
	// cQuery += " AND SEE.EE_SUBCTA  = 'ABC' "
	cQuery += " AND SEE.EE_SUBCTA  = '4FI' "
	cQuery += " AND SEE.EE_XTIPAPI  = 'A' "

	cQuery := ChangeQuery(cQuery)

   	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

   	While (cAlias)->(!Eof())
      	aAdd(aCpos,{(cAlias)->(EE_CODIGO), (cAlias)->(EE_AGENCIA), (cAlias)->(EE_CONTA) })
      	(cAlias)->(dbSkip())
   	End
   	(cAlias)->(dbCloseArea())

	If Len(aCpos) < 1
		aAdd(aCpos,{" "," "," "})
	EndIf

	DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Selecione o Banco" FROM 0,0 TO 240,500 PIXEL

		@ 10,10 LISTBOX oLbx FIELDS HEADER 'Banco' /*"Roteiro"*/, 'Agencia' /*"Produto"*/, 'Conta' SIZE 230,95 OF oDlg PIXEL

		oLbx:SetArray( aCpos )
		oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2], aCpos[oLbx:nAt,3]}}
		oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]}}}

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2], oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

  	If Len(aRet) > 0 .And. lRet
     	If Empty(aRet[1])
        	lRet := .F.
     	Else
        	SEE->(dbSetOrder(1))
        	SEE->(dbSeek(xFilial("SEE")+aRet[1]+aRet[2]+aRet[3]))
     	EndIf
  	EndIf
Return lRet

