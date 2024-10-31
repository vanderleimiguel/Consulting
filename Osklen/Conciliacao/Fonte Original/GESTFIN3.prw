#include "protheus.ch"
/*/{Protheus.doc} GESTFIN3
	estornar o bordero gerado
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function GESTFIN3(cTmp)
	local aSV		:= {(cTmp)->(getArea()),SEA->(getArea())}
	local cBkp		:= CFILANT
	local cNumBor	:= (cTmp)->E1_NUMBOR
	local cMsg		as character
	local cKey		as character
	local aRecs		as array
	local nOpc		as numeric

	if Empty(cNumBor)
		return
	endif

	cMsg := "Bordero = abrira nova tela marcadora com os titulos do bordero "+cNumBor+CRLF+CRLF
	cMsg += "Somente Posicionado = ira estornar somente o titulo posicionado"
	nOpc := Aviso("Modalidades de estorno",cMsg,{"Bordero","Somente Posicionado","Cancelar"},3)

	do case
		case nOpc == 3
			ApMsgInfo("Estorno cancelado")
			return

		case nOpc == 2
			if ! (cTmp)->E1_XAPI .or. ApMsgYesNo("Esse título já foi enviado ao banco via API. O estorno será feito somente no Protheus e deve ser feito manualmente no banco. Deseja continuar?")
				SEA->( dbSetOrder(RetOrder("SEA","EA_FILIAL+EA_NUMBOR+EA_CART+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO+EA_FORNECE+EA_LOJA")) )
				cKey := (cTmp)->( E1_NUMBOR+"R"+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO )

				if SEA->( msSeek(xFilial()+cKey) )
					SE1->( dbGoto((cTmp)->XX_RECNO) )

					RecLock("SE1",.F.) ; RecLock(cTmp,.F.)
					SE1->E1_PORTADO := (cTmp)->E1_PORTADO := ""
					SE1->E1_AGEDEP  := (cTmp)->E1_AGEDEP  := ""
					SE1->E1_CONTA	:= (cTmp)->E1_CONTA	  := ""
					SE1->E1_SITUACA := (cTmp)->E1_SITUACA := ""
					SE1->E1_NUMBOR  := (cTmp)->E1_NUMBOR  := ""
					SE1->E1_DATABOR := (cTmp)->E1_DATABOR := CtoD("")
					SE1->E1_MOVIMEN := (cTmp)->E1_MOVIMEN := CtoD("")
					SE1->(msUnlock()) ; (cTmp)->(msUnlock())

					Reclock("SEA",.F.)
					SEA->( dbDelete() )
					SEA->( msUnlock() )
				endif
			endif

		case nOpc == 1
			if ApMsgYesNo("Titulos ja enviados ao banco, devem ser estornado manualmente no banco tambem. Deseja continuar?")
				BrowserBordero(cNumBor,cTmp)
			endif

	endcase

	(cTmp)->(restArea(aSv[1])) ; SEA->(restArea(aSv[2]))
	FwFreeArray(aRecs) ; CFILANT := cBkp
return

static function BrowserBordero(cNumBor,cTmp)
	local cQuery	as character
	local cFld		as character
	local cFields	:= ""
	local nContFlds	as numeric
	local lOk		:= .T.
	local oDlg		as object
	local oBrowse	as object
	local oTable	as object
	local aColumns	:= {}
	local aFields	:= {}
	local aBrowse	:= {}
	local aButtons	:= {}
	local cAliasQry	:= GetNextAlias()

	private nTotal := 0
	private nMarcados := 0
	private nQuant := 0

	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_NUMBOR") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_PORTADO") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_AGEDEP") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_NUMCON") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_PREFIXO") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_NUM") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_PARCELA") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_SALDO") )
	aAdd( aBrowse, FwSx3Util():getFieldStruct("EA_DATABOR") )

	aFields := aClone(aBrowse)
	aAdd( aFields, {"XX_OK"		,"L",1,0})
	aAdd( aFields, {"XX_RECNO"	,"N",9,0})

	oTable := FwTemporaryTable():new(cAliasQry,aFields)
	oTable:create()

	aEval(aBrowse,{|x| cFields += Alltrim(x[1]) + "," })

	cQuery := "INSERT INTO "+oTable:getRealName()+" ("+cFields+"XX_RECNO,XX_OK)"
	cQuery += " SELECT "+StrTran(cFields,"EA_SALDO","E1_SALDO [EA_SALDO]")+"SEA.R_E_C_N_O_,'T'"
	cQuery += " FROM "+RetSqlName("SEA")+" SEA"
	cQuery += " JOIN "+RetSqlName("SE1")+" SE1"
	cQuery += " ON E1_FILIAL="+ValToSql(xFilial("SE1"))
	cQuery += 	" AND E1_PREFIXO=EA_PREFIXO"
	cQuery += 	" AND E1_NUM=EA_NUM"
	cQuery += 	" AND E1_PARCELA=EA_PARCELA"
	cQuery += 	" AND E1_TIPO=EA_TIPO"
	cQuery += 	" AND SE1.D_E_L_E_T_ = ' '"
	cQuery += 	" AND E1_NUMBOR=EA_NUMBOR"
	cQuery += 	" AND E1_SALDO>0"
	cQuery += " WHERE EA_FILIAL = "+ValToSql(xFilial("SEA"))
	cQuery += 		" AND EA_NUMBOR = "+ValToSql(cNumBor)
	cQuery += 		" AND EA_CART = "+ValToSql("R")
	cQuery += 		" AND SEA.D_E_L_E_T_ = ' '"
	xRet := TcSqlExec(cQuery)

	oDlg := FwDialogModal():new()
	oDlg:setTitle("Estorno Bordero - "+cNumBor)
	oDlg:setCloseButton(.F.)
	oDlg:setEscClose(.F.)
	oDlg:enableAllClient()
	oDlg:nBottom *= 0.5 // diminui em 50% a tela
	oDlg:nRight  *= 0.5 // diminui em 50% a tela
	oDlg:createDialog()

	aAdd(aButtons,{,"Estornar Marcados"	,{|| oDlg:deActivate() },"",,.T.,.F.})
	aAdd(aButtons,{,"Cancelar Estorno"	,{|| lOk := .F. , oDlg:deActivate() },"",,.T.,.F.})
	oDlg:addButtons(aButtons)

	@ 0.1,05 SAY "total R$" SIZE 35,07 OF oDlg:oBottom PIXEL
	@ 7,04 MSGET oTotal VAR nTotal PICTURE "@E 99,999,999.99" SIZE 45,09 WHEN .F. OF oDlg:oBottom PIXEL

	@ 0.1,53 SAY "marcados R$" SIZE 35,07 OF oDlg:oBottom PIXEL
	@ 7,52 MSGET oMark VAR nMarcados PICTURE "@E 99,999,999.99" SIZE 45,09 WHEN .F. OF oDlg:oBottom PIXEL

	@ 0.1,105 SAY "quantidade" SIZE 35,07 OF oDlg:oBottom PIXEL
	@ 7,104 MSGET oQtd VAR nQuant SIZE 45,09 WHEN .F. OF oDlg:oBottom PIXEL

	fnAtuTotal(cAliasQry)

	oBrowse := FWBrowse():new(oDlg:getPanelMain())
	oBrowse:setDataTable(.T.)
	oBrowse:setAlias(cAliasQry)
	oBrowse:disableConfig()
	oBrowse:disableReport()
	oBrowse:addMarkColumns({|| Iif((cAliasQry)->XX_OK,"LBOK","LBNO") }, {|| fnMark(oBrowse) }, {|| fnMark(oBrowse,.T.) })

	For nContFlds := 1 To Len( aBrowse )
		cFld := aBrowse[nContFlds][1]
		aAdd( aColumns, FWBrwColumn():new() )
		aTail(acolumns):setData( &("{ || " + cFld + " }") )
		aTail(acolumns):setTitle( GetSx3Cache(cFld,"X3_TITULO") )
		aTail(acolumns):setSize( aBrowse[nContFlds][3] + aBrowse[nContFlds][4] )
		aTail(acolumns):setID( cFld )
		aTail(acolumns):setPicture(GetSx3Cache(cFld,"X3_PICTURE"))
		if cFld $ "EA_SALDO"
			aTail(acolumns):setAlign(2)
		else
			aTail(acolumns):setAlign(0)
		endif
	Next nContFlds

	oBrowse:setColumns(aColumns)
	oBrowse:activate()

	oDlg:activate()

	if lOk
		MsgRun("Realizando estorno dos títulos selecionados ...","aguarde",{|| fnEstornar(cAliasQry,cTmp) })
	endif

	oTable:delete() ; FreeObj(oTable)
	oBrowse:deActivate() ; FreeObj(oBrowse)
	FreeObj(oDlg)
	FwFreeArray(aColumns) ; FwFreeArray(aFields) ; FwFreeArray(aBrowse) ; FwFreeArray(aButtons)
return

static function fnMark(oGrid,lMarkAll)
	local cTmp := oGrid:alias()
	default lMarkAll := .F.
	if lMarkAll
		(cTmp)->( dbGotop() )
		(cTmp)->( dbEval({|| Reclock(cTmp,.F.) , (cTmp)->XX_OK := ! (cTmp)->XX_OK , (cTmp)->(msUnlock()) }) )
		(cTmp)->( dbGotop() )
		fnAtuTotal(cTmp)
		oGrid:refresh(.T.)
	else
		Reclock(cTmp,.F.)
		(cTmp)->XX_OK := ! (cTmp)->XX_OK
		(cTmp)->(msUnlock())
		oGrid:lineRefresh()
	endif
return

static function fnAtuTotal(cTmp)
	nTotal := 0 ; nMarcados := 0 ; nQuant := 0
	(cTmp)->( dbGotop() )
	(cTmp)->( dbEval({|| nTotal += EA_SALDO , nQuant ++ , nMarcados += Iif(XX_OK,EA_SALDO,0) }) )
	(cTmp)->( dbGotop() )
	oTotal:refresh() ; oMark:refresh() ; oQtd:refresh()
return

static function fnEstornar(cTemp,cMain)
	local aSave := {(cMain)->(getArea()),SE1->(getArea())}
	local cKey as character

	SE1->( dbSetOrder(RetOrder("SE1","E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO")) )
	(cMain)->(dbSetOrder(4))
	(cTemp)->( dbGotop() )

	while (cTemp)->( ! Eof() )
		if (cTemp)->XX_OK
			SEA->( dbGoto((cTemp)->XX_RECNO) )
			cKey := SEA->(EA_FILIAL+EA_PREFIXO+EA_NUM+EA_PARCELA+EA_TIPO)
			if SE1->( msSeek(cKey) )
				if (cMain)->( dbSeek(cValtochar(SE1->(Recno()))) )
					RecLock("SE1",.F.) ; RecLock(cMain,.F.)
					SE1->E1_PORTADO := (cMain)->E1_PORTADO := ""
					SE1->E1_AGEDEP  := (cMain)->E1_AGEDEP  := ""
					SE1->E1_CONTA	:= (cMain)->E1_CONTA   := ""
					SE1->E1_SITUACA := (cMain)->E1_SITUACA := ""
					SE1->E1_NUMBOR  := (cMain)->E1_NUMBOR  := ""
					SE1->E1_DATABOR := (cMain)->E1_DATABOR := CtoD("")
					SE1->E1_MOVIMEN := (cMain)->E1_MOVIMEN := CtoD("")
					SE1->(msUnlock()) ; (cMain)->(msUnlock())

					Reclock("SEA",.F.)
					SEA->( dbDelete() )
					SEA->( msUnlock() )
				endif
			endif
		endif
		(cTemp)->( dbSkip() )
	end

	(cMain)->(restArea(aSave[1]))
	SE1->(restArea(aSave[2]))
return
