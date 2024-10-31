#Include "rwmake.ch"
#Include "protheus.ch"
#include 'topconn.ch'

/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºPrograma  ³fWMEKit         Manoel de Sa ºAutor        º Data ³10/04/09 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDesc.     ³Funcao disparada pelo Botao "Kit Instr", no pedido de       º±±
	±±º          ³vendas, que tem, como finalidade, incluir os instrumentais  º±±
	±±º          ³no aCols do Pedido de Venda.                                º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ AP                                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	*/
User Function fWMEKit(lExplod	As Logical)
	// Exibe Kit's para selecao
	Local	aAreaAtu	:= FWGetArea()
	Local	nIncrementa	:= 0					As Numeric
	Local	aAreaSCJ	:= SCJ->(FWGetArea())
	Local	aAreaSF4	:= SF4->(FWGetArea())
	local	oArmazen							As Object
	Private	lExplode	:= .F.					As Logical
	Private	lPV			:= .F.					As Logical
	Private	lOrc		:= .F.					As Logical
	Private	nPosKit		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_XKIT"})//C6_XKIT = campo criado para diferenciar itens do kit
	Private	nPosProd	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRODUTO"})
	Private	nPosPrc		:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_PRCVEN"})
	Private	nPosKitExp	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_XKITEXP"})//C6_XKITEXP = campo criado para indicar se os itens do kit foram explodidos
	Private	nPosKitOrig	:= aScan(aHeader,{|x| AllTrim(x[2]) == "C6_XKITORG"})//C6_XKITORG = campo criado para indicar origem da inclusão do kit
	Private	cProdPrinc	:= ""					As Character
	Private	nPrecVend	:= 0					As Numeric
	Private nTotal								As Numeric
	Private	cAlias		:= "SZ3"				As Character
	Private	cLocalAL	:= "03"					As Character

	// Variaveis Private da Funcao
	Private ofWMEKitDlg				// Dialog Principal
	Private cFontUti    := "Tahoma"
	Private oFontSub    := TFont():New(cFontUti, , -15)
	// Variaveis que definem a Acao do Formulario
	Private VISUAL := .F.
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private DELETA := .F.
	// Privates das ListBoxes
	Private aKits  := {}
	Private aItens := {}
	Private oListBox1
    Private _cCodigo    := Space(TamSX3('C6_PRODUTO')[1])
	DEFAULT	lExplod	:= .F.
	
	nTotal	:= Len(aHeader[1])
	lExplode:= lExplod
	lPV		:= FWIsInCallStack("MATA410")
	lOrc	:= FWIsInCallStack("MATA415")

	Do Case
	Case lExplode .AND. !lPV
		Return FWAlertInfo("O processo de 'Explodir' o Kit esta disponivel apenas no pedido de vendas", "Acionamento indevido")

	Case lPV .AND. (nPosKit == 0 .OR. nPosKitExp == 0 .OR. nPosKitOrig == 0)
		Return FWAlertInfo("Problema ao obter os kits", "Nada a fazer")

	Case lExplode .AND. lPV .AND. (EMPTY(aCols[n][nPosKit]) .OR. aCols[n][nPosKitExp] .OR. AllTrim(aCols[n][nPosKitOrig]) == "PV")
		Do Case
		Case EMPTY(aCols[n][nPosKit])
			Return FWAlertInfo("Este item não possui kit atrelado a ele", "Nada a fazer")

		Case aCols[n][nPosKitExp] .OR. AllTrim(aCols[n][nPosKitOrig]) == "PV" .OR. EMPTY(aCols[n][nPosKitOrig])
			Return FWAlertInfo("Este item ja foi 'explodido'", "Nada a fazer")

		EndCase
	Case lPV .AND. lExplode
		nPrecVend	:= aCols[n][nPosPrc]
	EndCase

	if lPV
		nIncrementa	:= 50
	endif

	DEFINE MSDIALOG ofWMEKitDlg TITLE "Kit's Instrumentais" FROM 178, 181 TO 548 + nIncrementa, 717 PIXEL

	// Cria as Groups do Sistema
	@ 004,004 TO 154,264 LABEL "  Apresentação de KIT's  " PIXEL OF ofWMEKitDlg
	
	//Cria pesquisa de kit pelo codigo
	@ 012,155 Say "Pesquisa Kit:" Size 035,008 COLOR CLR_BLACK PIXEL OF ofWMEKitDlg
	@ 010,190 MsGet oCodigo  Var _cCodigo Size 60,009 COLOR CLR_BLACK Picture "@!" F3 "fPesquis(oListBox1:nAt, aKits)" PIXEL OF ofWMEKitDlg
	
	// Cria Componentes Padroes do Sistema
	if lPV
		@ 167,004 Say "Armazen" Size 029,008 COLOR CLR_BLACK PIXEL OF ofWMEKitDlg
		@ 165,030 MsGet oArmazen  Var cLocalAL Size 50,009 COLOR CLR_BLACK Picture "@!" F3 "NNR" PIXEL OF ofWMEKitDlg
		nIncrementa	:= 20
	endif

	@165 + nIncrementa,052 Button "&Seleciona" Action (nOpc := 1, IIF(Valida(), (FWMsgRun(, {|| U_fGrvKit()}, "Aguarde", "A processar os kits"), ofWMEKitDlg:End()),))	Size 037,012 PIXEL OF ofWMEKitDlg // Seleciona Kit
	@165 + nIncrementa,115 Button "&Visualiza" Action (nOpc := 3, U_fVzlKit(aKits))																						Size 037,012 PIXEL OF ofWMEKitDlg // Visualiza Kit
	@165 + nIncrementa,179 Button "&Cancela"   Action (nOpc := 2, ofWMEKitDlg:End())																					Size 037,012 PIXEL OF ofWMEKitDlg // Cancela

	// Cria ExecBlocks dos Componentes Padroes do Sistema

	// Chamadas das ListBox do Sistema
	fListBox1()

	ACTIVATE MSDIALOG ofWMEKitDlg CENTERED

	SCJ->(FWRestArea(aAreaSCJ))
	SF4->(FWRestArea(aAreaSF4))
	FWRestArea(aAreaAtu)

Return(.T.)

/*/{Protheus.doc} fPesquis
	Botao pesquisa kit
	@type  Function
	@author Wagner Neves
	@since 17/10/2024
	/*/
Static Function fPesquis(nLinhaNew, aDados)
	Local nI
	Local cCodPesq := alltrim(_cCodigo)
	Local nTamPesq := len(cCodPesq)

	nI := aScan(aDados, {|x| left(x[3],nTamPesq) = cCodPesq})
	if (nI > 0) .and. (nI <> oListBox1:nAt)
		oListBox1:nAt := nI
		oListBox1:Refresh()
	endif

Return

/*/{Protheus.doc} Valida
	Rotina 
	@type  Function
	@author Alissom
	@since 19/07/2023
	@version 12.1.33
	/*/
Static Function Valida()
	Local	lRetorno	:= .T.	As Logical
	
	if lPV
		lRetorno	:= !EMPTY(cLocalAL)
	endif

Return lRetorno

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa   ³fListBox1() ³ Autor ³ Ricardo Mansano       ³ Data ³23/04/2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ'±±
	±±³Descricao  ³ Montagem da ListBox                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox1()
	// List Box do Kit
	Local	aAreaAtu	:= GetArea()
	Local	aAreaSZ3	:= SZ3->(GetArea())
	Local	oOk			:= LoadBitmap( GetResources(), "LBOK"       )
	Local	oNo			:= LoadBitmap( GetResources(), "LBNO"       )
	Local	lOkKit		:= .F.
	Local	oCheck		:= LoadBitmap( GetResources(), "CHECKED" )      // Legends : CHECKED  / LBOK  /LBTIK
	Local	oNoCheck	:= LoadBitmap( GetResources(), "UNCHECKED" )    // Legends : UNCHECKED /LBNO  
	Local	lOkTrau		:= .F.
	Local	cQuery					As Character

	dbSelectArea("SZ3")
	dbSetOrder(1)
	dbGoTop()
	
	if lExplode
		cProdPrinc	:= AllTrim(aCols[n][nPosProd])
		cAlias		:= GetNextAlias()
		cQuery		:= "SELECT z3.*" + CRLF
		cQuery		+=   "FROM SZ3010 z3" + CRLF
		cQuery		+= "INNER JOIN SZ4010 z4 ON z4.D_E_L_E_T_ = ''" + CRLF
		cQuery		+= 					"AND Z3_CODIGO = Z4_CODIGO" + CRLF
		cQuery		+= 					"AND Z4_PRDPRNC ='1'" + CRLF
		cQuery		+= 					"AND Z4_PRODUTO = '" + cProdPrinc + "'" + CRLF
		cQuery		+=  "WHERE z3.D_E_L_E_T_ = ''" + CRLF
		TcQuery cQuery New Alias (cAlias)
	endif
	
	While (cAlias)->(!Eof())
		If lPV .OR. lOrc
			cTipo := Iif((cAlias)->Z3_TIPO == "1","Basico    ",Iif((cAlias)->Z3_TIPO == "2","Especifico","Implante  "))			
			aAdd(aKits,{lOkKit,lOkTrau,(cAlias)->Z3_CODIGO,(cAlias)->Z3_DESCR,cTipo})
			(cAlias)->(dbSkip())
		Else
			cTipo := Iif((cAlias)->Z3_TIPO == "1","Basico    ",Iif((cAlias)->Z3_TIPO == "2","Especifico","Implante  "))
			// Verifica se Kit já foi associado à Agenda
			// If AllTrim((cAlias)->Z3_CODIGO) $ cOkKit
			// 	lOkKit := .T.
			// Endif
			aAdd(aKits,{lOkKit,lOkTrau,(cAlias)->Z3_CODIGO,(cAlias)->Z3_DESCR,cTipo})
			lOkKit := .F.
			(cAlias)->(dbSkip())
		EndIf	
	Enddo
	
	if lExplode
		(cAlias)->(dbCloseArea())
	endif

	// Carrege aqui sua array da Listbox

	@ 024,012 ListBox oListBox1 Fields ;
	HEADER "X","Trauma?","Código","Descrição","Tipo";
	Size 241,114 Of ofWMEKitDlg Pixel;
	ColSizes ;
	On DBLCLICK ( aKits[oListBox1:nAt,1] := !(aKits[oListBox1:nAt,1]),IIF(MsgYesNo("Trauma?", "Atenção"),aKits[oListBox1:nAt,2]:=.T.,aKits[oListBox1:nAt,2]:=.F. ), oListBox1:Refresh() )
	oListBox1:SetArray(aKits)

	// Cria ExecBlocks das ListBoxes
	oListBox1:bLine	:= {|| {If(aKits[oListBox1:nAT,1],oOk,oNo),If(aKits[oListBox1:nAT,2],oCheck,oNoCheck),aKits[oListBox1:nAt,3],aKits[oListBox1:nAt,4],aKits[oListBox1:nAt,5]}}

	RestArea(aAreaSZ3)
	RestArea(aAreaAtu)

Return Nil

User Function fVzlKit(aKits)
	// Funcao para visualizar os itens do Kit
	// Variaveis Locais da Funcao
	Local cTipo	 := ""
	Local oKit
	Local oTipo
	Local nLp
	// Variaveis Private da Funcao
	Private ofVzlKitDlg				// Dialog Principal
	// Variaveis que definem a Acao do Formulario
	Private VISUAL    := .F.
	Private INCLUI    := .F.
	Private ALTERA    := .F.
	Private DELETA    := .F.
	// Privates das ListBoxes
	Private a2ListBox := {}
	Private o2ListBox
	Private cKit	  := ""

	// Identifica item selecionado na tela anterior para exibicao de seus itens
	For nLp := 1 to Len(aKits)
		If aKits[nLp][1]
			cKit  := aKits[nLp][3]
			cTipo := aKits[nLp][4]
		Endif
	Next

	if EMPTY(cKit) .AND. Len(aKits) > 0
		cKit  := aKits[1][3]
		cTipo := aKits[1][4]
	endif

	DEFINE MSDIALOG ofVzlKitDlg TITLE "Kit's Instrumentais" FROM 178,181 TO 581,717 PIXEL

	// Cria as Groups do Sistema
	@ 003,004 TO 181,265 LABEL "Apresentação de KIT" PIXEL OF ofVzlKitDlg
	@ 014,011 TO 064,255 LABEL ""  PIXEL OF ofVzlKitDlg

	// Cria Componentes Padroes do Sistema
	@ 026,025 Say "Kit"  Size 015,008 COLOR CLR_BLACK PIXEL OF ofVzlKitDlg
	@ 045,025 Say "Tipo" Size 015,008 COLOR CLR_BLACK PIXEL OF ofVzlKitDlg

	@ 026,045 MsGet oKit  Var cKit  When .F. Size 188,009 COLOR CLR_BLACK Picture "@!" PIXEL OF ofVzlKitDlg
	@ 045,045 MsGet oTipo Var cTipo When .F. Size 060,009 COLOR CLR_BLACK Picture "@!" PIXEL OF ofVzlKitDlg

	@ 187,116 BmpButton Type 1 Action (ofVzlKitDlg:End()) //"&Ok" Size 037,012 PIXEL OF ofVzlKitDlg

	// Cria ExecBlocks dos Componentes Padroes do Sistema

	// Chamadas das ListBox do Sistema
	fListBox2()
	ACTIVATE MSDIALOG ofVzlKitDlg CENTERED
Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
	±±³Programa   ³fListBox2() ³ Autor ³ Ricardo Mansano       ³ Data ³23/04/2009³±±
	±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ'±±
	±±³Descricao  ³ Montagem da ListBox                                          ³±±
	±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fListBox2()
	Local aAreaAtu := GetArea()
	Local aAreaSZ4 := SZ4->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())

	aItens   := {}

	// Carrega vetor com itens do Kit para serem apresentado na ListBox

	dbSelectArea("SZ4")
	dbSetOrder(1)
	SZ4->(DBGotop())
	
	if dbSeek(xFilial("SZ4") + cKit)	
		While SZ4->Z4_FILIAL + SZ4->Z4_CODIGO == xFilial("SZ4") + cKit .and. !Eof()		
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1") + SZ4->Z4_PRODUTO)		
			dbSelectArea("SZ4")		
			aAdd(aItens,{SZ4->Z4_PRODUTO,SZ4->Z4_QUANT,SB1->B1_DESC})		
			dbSkip()		
		Enddo
	else
		aAdd(aItens,{"",0,""})
	endif

	@ 070,012 ListBox o2ListBox Fields ;
	HEADER "Produto","Quant","Descrição";
	Size 246,100 Of ofVzlKitDlg Pixel;
	ColSizes ;
	On DBLCLICK ( aItens[o2ListBox:nAt,1] := !(aItens[o2ListBox:nAt,1]), o2ListBox:Refresh() )
	o2ListBox:SetArray(aItens)

	// Cria ExecBlocks das ListBoxes
	//o2ListBox:bLine	:= {|| {If(aItens[o2ListBox:nAT,1],oOk,oNo),aItens[o2ListBox:nAt,2],aItens[o2ListBox:nAt,3],aItens[o2ListBox:nAt,4]}}
	o2ListBox:bLine	:= {|| {aItens[o2ListBox:nAt,1],aItens[o2ListBox:nAt,2],aItens[o2ListBox:nAt,3]}}

	RestArea(aAreaSB1)
	RestArea(aAreaSZ4)
	RestArea(aAreaAtu)
Return Nil

User Function fGrvKit()
	// Grava nos itens da Agenda de Orcamento os itens do Kit selecionado
	// aItens devera ser replicado em aCols
	Local nX			:= 0
	Local nLp			:= 0
	Local cKit			:= ""
	Local cDesc			:= ""
	Local cLocal		:= ""
	Local cProxItem		:= ""
	Local nPrcVen		:= 0
	Local dDtValid		:= CTOD("  /  /  ")
	Local cUm			:= ""
	Local aCM			:= {}
	Local cTrauma		:= ""
	Local xObs			:= ""
	Local nPosItem				As Numeric
	Local nPosCLSFIS			As Numeric
	Local nPosDescr				As Numeric
	Local nPosQTDVen			As Numeric
	Local nPosPRCVen			As Numeric
	Local nPosPrunit			As Numeric
	Local nPosTotal				As Numeric
	Local nPosLocal				As Numeric
	Local nPosUM				As Numeric
	Local nPosDTValid			As Numeric
	Local nPosLote				As Numeric
	Local nPosTpPV				As Numeric
	Local nPosPrcMin			As Numeric
	Local nPosTES				As Numeric
	Local nPosCF				As Numeric
	Local nValPrecMin			As Numeric
	Local nPosprincipal			As Numeric
	Local nPosNovoItem			As Numeric
	Local cValTes				As Character
	Local cValCF				As Character
	Local lIncluiu		:= .F.	As Logical

	Do Case
	Case lPV .OR. lOrc
		if lPV
			nPosItem	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_ITEM"})
			nPosCLSFIS	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_CLASFIS"})
			nPosDescr	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_DESCRI"})
			nPosQTDVen	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_QTDVEN"})
			nPosPRCVen	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_PRCVEN"})
			nPosPrunit	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_PRUNIT"})
			nPosPrcMin	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_XPRCMIN"})
			nPosLocal	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_LOCAL"})
			nPosUM		:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_UM"})
			nPosDTValid	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_DTVALID"})
			nPosLote	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_LOTECTL"})
			nPosTpPV	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_XTIPOPV"})
			nPosTotal	:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_VALOR"})
			nPosTES		:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_TES"})
			nPosCF		:= aScan(aHeader,{|x| AllTrim(x[2]) = "C6_CF"})
			cProxItem	:= aCols[Len(aCols)][nPosItem]

			nValPrecMin	:= aCols[n][nPosPrcMin]
			cValTes		:= aCols[n][nPosTES]
			cValCF		:= aCols[n][nPosCF]

			if lExplode
				nPosprincipal			:= n
			endif
		endif
		For nLp := 1 to Len(aKits)
			
			If aKits[nLp][1] // Marcado
				
				cKit      := aKits[nLp][3]
				cTrauma   := IIF(aKits[nLp][2]==.T.,"S","")
				
				dbSelectArea("SZ4")
				dbSetOrder(1) // Codigo Kit + Produto
				dbSeek(xFilial("SZ4") + cKit)
				
				While SZ4->Z4_FILIAL + SZ4->Z4_CODIGO == xFilial("SZ4") + cKit .and. !SZ4->(Eof())
					if lPV .OR. (lOrc .AND. SZ4->Z4_PRDPRNC == '1')
						__cArea		:= GetArea()
						
						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(xFilial("SB1") + SZ4->Z4_PRODUTO)
						
						cDesc		:= SB1->B1_DESC
						cLocal		:= SB1->B1_LOCPAD
						cUm			:= SB1->B1_UM
						
						if lPV
							cLocal	:= cLocalAL
						endif

						//ponteira na SF4 conforme gatilho no C6_PRODUTO
						DbSelectArea("SF4")
						DbSetOrder(1)
						DbSeek(xFilial("SF4")+SB1->B1_TS)
						if lExplode .AND. nPrecVend > 0
							nPrcVen	:= nPrecVend
						else
							dbSelectArea("DA1")
							dbSetOrder(1)
							If dbSeek(xFilial("DA1") + AllTrim(GetNewPar("MV_XTABPRE","006")) + ALLTRIM(SZ4->Z4_PRODUTO) )
								nPrcVen   := IIF(DA1->DA1_PRCVEN>0,DA1->DA1_PRCVEN,0.00)						
								If nPrcVen <= 0.00						
									aCM := PegaCMAtu( PADR( ALLTRIM(SZ4->Z4_PRODUTO),TAMSX3("B2_COD")[1]),PADR( ALLTRIM(cLocal),TAMSX3("B2_LOCAL")[1]) ) //PEGA O CUSTO MEDIO
									nPrcVen := aCM[1]						
								EndIf
							Else
								//nPrcVen   := 0.00
								aCM := PegaCMAtu( PADR( ALLTRIM(SZ4->Z4_PRODUTO),TAMSX3("B2_COD")[1]),PADR( ALLTRIM(cLocal),TAMSX3("B2_LOCAL")[1]) ) //PEGA O CUSTO MEDIO
								nPrcVen := aCM[1]
							EndIf
						endif
						
						dbSelectArea("SB8")
						dbSetOrder(5) // Produto + Lote
						If dbSeek(xFilial("SB8") + SZ4->Z4_PRODUTO + SZ4->Z4_LOTE)
							dDtValid := SB8->B8_DTVALID
						Endif
						
						RestArea(__cArea)
						if lPV
							If (lExplode .AND. SZ4->Z4_PRDPRNC == '1') .OR. aScan(aCols,{|x| x[nPosKit] == cKit .and. x[nPosProd] = SZ4->Z4_PRODUTO .and. x[nPoslote] == SZ4->Z4_LOTE}) == 0
								
								If (Len(aCols) > 1 .AND. !EMPTY(aCols[Len(aCols)][nPosProd])) .OR. (Len(aCols) == 1 .AND. !EMPTY(aCols[1][nPosProd]))
									if lExplode .AND. SZ4->Z4_PRDPRNC == '1'
										nPosNovoItem	:= nPosprincipal
									else
										cProxItem := Soma1(cProxItem)
										aadd(aCols,Array(Len(aHeader)+1))
										
										nPosNovoItem	:= Len(aCols)
										For nX := 1 To Len(aHeader)
											Do Case
											Case AllTrim(aHeader[nX][2]) $ "C6_ALI_WT|CK_ALI_WT"
												aCols[nPosNovoItem][nX] := ""

											Case AllTrim(aHeader[nX][2]) $ "C6_REC_WT|CK_REC_WT"
												aCols[nPosNovoItem][nX] := 0
												
											Otherwise
												aCols[nPosNovoItem][nX] := CriaVar(aHeader[nX][2])										
											EndCase
										Next nX									
									endif
									n										:= nPosNovoItem
									aCols[n][Len(aHeader)+1]				:= .F.
									A410Produto(SZ4->Z4_PRODUTO)
									if (lExplode .AND. SZ4->Z4_PRDPRNC == '2') .OR. EMPTY(aCols[nPosNovoItem][nPosItem])
										aCols[nPosNovoItem][nPosItem]		:= cProxItem										
									endif
									aCols[nPosNovoItem][nPosProd]			:= SZ4->Z4_PRODUTO
									aCols[nPosNovoItem][nPosCLSFIS]			:= Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
									aCols[nPosNovoItem][nPosKit]			:= cKit
									aCols[nPosNovoItem][nPosDescr]			:= cDesc
									aCols[nPosNovoItem][nPosQTDVen]			:= SZ4->Z4_QUANT
									aCols[nPosNovoItem][nPosPRCVen]			:= nPrcVen
									aCols[nPosNovoItem][nPosPrunit]			:= nPrcVen
									aCols[nPosNovoItem][nPosLocal]			:= cLocal
									aCols[nPosNovoItem][nPosUM]				:= cUm
									aCols[nPosNovoItem][nPosDTValid]		:= IIF(EMPTY(dDtValid),CTOD("  /  /  "),dDtValid)
									aCols[nPosNovoItem][nPosLote]			:= SZ4->Z4_LOTE
									aCols[nPosNovoItem][nPosTpPV]			:= IIF(cTrauma=="S","T","I")	
								Else
									if lExplode .AND. SZ4->Z4_PRDPRNC == '1'
										nPosNovoItem	:= nPosprincipal
									else
										nPosNovoItem	:= Len(aCols)
									EndIf
									n										:= nPosNovoItem
									A410Produto(SZ4->Z4_PRODUTO)
									aCols[nPosNovoItem][nPosProd]			:= SZ4->Z4_PRODUTO
									aCols[nPosNovoItem][nPosCLSFIS]			:= Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
									aCols[nPosNovoItem][nPosKit]			:= cKit
									aCols[nPosNovoItem][nPosDescr]			:= cDesc
									aCols[nPosNovoItem][nPosQTDVen]			:= SZ4->Z4_QUANT
									aCols[nPosNovoItem][nPosPRCVen]			:= nPrcVen
									aCols[nPosNovoItem][nPosPrunit]			:= nPrcVen
									aCols[nPosNovoItem][nPosLocal]			:= cLocal
									aCols[nPosNovoItem][nPosUM]				:= cUm
									aCols[nPosNovoItem][nPosDTValid]		:= IIF(EMPTY(dDtValid),CTOD("  /  /  "),dDtValid)
									aCols[nPosNovoItem][nPosLote]			:= SZ4->Z4_LOTE
									aCols[nPosNovoItem][nPosTpPV]			:= IIF(cTrauma=="S","T","I")
								EndIf
								if lExplode
									aCols[nPosNovoItem][nPosPrcMin]			:= nValPrecMin
									aCols[nPosNovoItem][nPosTES]			:= cValTes
									aCols[nPosNovoItem][nPosCF]				:= cValCF									
								endif
								A410ReCalc(.T.)
								A410LotCTL()
								// RunTrigger(2,n,,,"C6_PRODUTO")
								RunTrigger(2,n,,,"C6_LOTECTL")
								GetDRefresh()//atualiza acols
								aCols[n][nPosKitExp]	:= .T.
							endif
						else
							if CheckNovoItem()
								lIncluiu	:= .T.
								oGetDad:AddLine()
							endif
							RecLock( "TMP1", .F. )
							TMP1->CK_PRODUTO	:= SZ4->Z4_PRODUTO
							A415Prod(TMP1->CK_PRODUTO)
							TMP1->CK_QTDVEN		:= SZ4->Z4_QUANT
							TMP1->CK_PRCVEN		:= nPrcVen
							TMP1->CK_VALOR		:= A410Arred(TMP1->CK_QTDVEN*TMP1->CK_PRCVEN,"CK_VALOR")
							TMP1->CK_TES		:= "508"
							TMP1->CK_CLASFIS	:= Subs(SB1->B1_ORIGEM,1,1)+SF4->F4_SITTRIB
							TMP1->CK_XKIT		:= cKit
							EvalTrigger()
							MSUNLOCK()
							oGetDad:oBrowse:Refresh()
							ExecutaTrigg("CK_PRODUTO")
							ExecutaTrigg("CK_QTDVEN")
						Endif
					endif
					SZ4->(dbSkip())
				Enddo
				
			Endif			
		Next nLp
		if lIncluiu
			oGetDad:lNewLine := .F.
		endif
		oGetDad:oBrowse:Refresh()


	Otherwise
		oGetDados1:Refresh()		
		xObs := U_AgendObs()		
		
		For nLp := 1 to Len(aKits)			
			If aKits[nLp][1] // Marcado				
				cKit     := aKits[nLp][3]
				cTrauma  := IIF(aKits[nLp][2]==.T.,"S","")
				
				dbSelectArea("SZ4")
				dbSetOrder(1) // Codigo Kit + Produto
				dbSeek(xFilial("SZ4") + cKit)
				
				While SZ4->Z4_FILIAL + SZ4->Z4_CODIGO == xFilial("SZ4") + cKit .and. !Eof()					
					cProxItem := Soma1(cProxItem)					
					cDesc  := Posicione("SB1",1,xFilial("SB1") + SZ4->Z4_PRODUTO,"B1_DESC")
					cLocal := Posicione("SB1",1,xFilial("SB1") + SZ4->Z4_PRODUTO,"B1_LOCPAD")					
					If aScan(aCols,{|x| x[6] == cKit .and. x[2] == SZ4->Z4_PRODUTO}) == 0
						aAdd(aCols,{cProxItem,SZ4->Z4_PRODUTO,cDesc,SZ4->Z4_QUANT,cKit," ",SZ4->Z4_LOTE,cLocal,"A","S",xObs,"",cUserName,cTrauma,.F.})
					Endif					
					dbSkip()					
				Enddo				
			Endif			
		Next nLp
		oGetDados1:Refresh()
	EndCase

Return

/*/{Protheus.doc} CheckNovoItem
	Necessario incluir novo item?
	@type  Function
	@author Alissom
	@since 03/07/2023
	@version 12.1.33
	/*/
Static Function CheckNovoItem()
	Local	aArea		As Array
	Local	lNovo		As Logical

	if EMPTY(TMP1->CK_PRODUTO)
		Return .F.
	else
	aArea		:= TMP1->(FWGetArea())

	TMP1->(DBGOBOTTOM())
	lNovo	:= !EMPTY(TMP1->CK_PRODUTO)
	if lNovo
		TMP1->(FWRestArea(aArea))
	endif
	oGetDad:oBrowse:nAt := TMP1->(RECNO())
	endif
Return lNovo

/*/{Protheus.doc} ExecutaTrigg
	Facilitador para runtriggers
	@type Function
	@author Alissom
	@since 03/07/2023
	@version 12.1.33
	@param cCampo, character, campo a ser acionado
	/*/
Static Function ExecutaTrigg(cCampo)
	// __readvar	:= "TMP1->" + cCampo
	If ExistTrigger(cCampo) // verifica se existe trigger para este campo
		RunTrigger(2,oGetDad:oBrowse:nAt,,,cCampo)
	Endif
Return 
