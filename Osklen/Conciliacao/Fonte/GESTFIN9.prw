#include "totvs.ch"

static oEnch2  := nil

/*/{Protheus.doc} GESTFIN9
	retorno das API
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFIN9(cTmp)
	// ApMsgInfo("Em desenvolvimento ...")
	// return

	MsgRun("Consultando bancos ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local bAction := {|| FWMsgRun(,{|oSay| fnBaixar(aTemps,oSay) },"Processando","Processando a rotina...") , oModal:deActivate() }
	Private n1Marcado   := 0
	Private n1Total     := 0.00
	Private n1TotMarc   := 0.00
	Private n2Marcado   := 0
	Private n2Total     := 0.00
	Private n2TotMarc   := 0.00
	Private n3Marcado   := 0
	Private n3Total     := 0.00
	Private n3TotMarc   := 0.00

	oModal := FwDialogModal():New()
	oModal:setEscClose(.T.)
	oModal:setTitle("Retorno das APIs")
	//oModal:setSize(200,400)
	oModal:enableAllClient()
	oModal:nBottom *= 0.9 // diminui em 10% a tela
	oModal:nRight  *= 0.9 // diminui em 10% a tela
	oModal:createDialog()

	aTemps := {}

	aButtons := {}
	aAdd(aButtons,{,"Fechar sem Baixar",{|| oModal:deActivate() },"",,.T.,.F.})
	aAdd(aButtons,{,"Confirmar e Baixar",bAction,"",,.T.,.F.})
	oModal:addButtons(aButtons)

	// oPanel := TPanel():new(,,,oModal:getPanelMain())
	oPanel := FwLayer():new()
	oPanel:init(oModal:getPanelMain(),.F.)
	oPanel:addLine('LINHA',100,.T.)
	oPanel:addCollumn('TELA',100,.T.,'LINHA')
	oPanel:addWindow('TELA','JANELA_PRINCIPAL'  ,'Titulos'			 ,80,.F.,.T.,,'LINHA')
	oPanel:addWindow('TELA','JANELA_RODAPE'  	,'Totais'			 ,20,.F.,.T.,,'LINHA')
	oWin1 	:= oPanel:getWinPanel('TELA','JANELA_PRINCIPAL'	,'LINHA')
	oWin2	:= oPanel:getWinPanel('TELA','JANELA_RODAPE'	,'LINHA')

	oWin1:align := CONTROL_ALIGN_ALLCLIENT

	aFolder := {'Itau','Santander','Banco do Brasil'/* ,'Safra','ABC Brasil' */}
	oFolder := TFolder():New( 0,0,aFolder,,oWin1,,,,.T.,,260,184)
	oFolder:align := CONTROL_ALIGN_ALLCLIENT
	oFolder:bChange := {|| fAtuTotal() }

	oItau := fnRetornoBanco():new("itau",oFolder:aDialogs[1])
	oItau:createPanel()
	oItau:addButton("Consultar")
	oItau:createTable()
	oItau:addGrid()
	oItau:activateView()
	aAdd(aTemps,oItau:oTmp)

	oSantander := fnRetornoBanco():new("santander",oFolder:aDialogs[2])
	oSantander:createPanel()
	oSantander:addButton("Consultar")
	oSantander:createTable()
	oSantander:addGrid()
	oSantander:activateView()
	aAdd(aTemps,oSantander:oTmp)

	oBrasil := fnRetornoBanco():new("brasil",oFolder:aDialogs[3])
	oBrasil:createPanel()
	oBrasil:addButton("Consultar")
	oBrasil:createTable()
	oBrasil:addGrid()
	oBrasil:activateView()
	aAdd(aTemps,oBrasil:oTmp)

	/* oSafra := fnRetornoBanco():new("safra",oFolder:aDialogs[4])
	oSafra:createPanel()
	oSafra:addButton("Consultar")
	oSafra:createTable()
	oSafra:addGrid()
	oSafra:activateView()
	aAdd(aTemps,oSafra:oTmp) */
	
	M->CTG2 := M->VLR2 := M->MKD2 := 0
	MsgRun("Criando totais ...." ,"AGUARDE",{|| TotalDef(oWin2) })
	oModal:activate()

	DestroyAll()
return

static function DestroyAll()
	FreeObj(oWin1)
	FreeObj(oFolder)
	oItau:destroy() ; FreeObj(oItau)
	//oSafra:destroy() ; FreeObj(oSafra)
	oBrasil:destroy() ; FreeObj(oBrasil)
	oSantander:destroy() ; FreeObj(oSantander)
	FreeObj(oModal)
	FwFreeArray(aFolder) ; FwFreeArray(aButtons) ; FwFreeArray(aTemps)
return

static function fnBaixar(aTemps,oSay)
	local nInx as numeric
	local cAlias as character
	local aBaixa as array
	Local nRecSE1   := 0
	Local lConcilia	:= SuperGetMv("MV_XAPICON",,.F.)

	for nInx := 1 to Len(aTemps)
		cAlias := aTemps[nInx]:getAlias()

		Sleep(500)

		(cAlias)->( dbGotop() )

		while (cAlias)->( ! Eof() )
			if (cAlias)->XX_OK
				SE1->( dbGoto((cAlias)->XX_RECNO) )
				nRecSE1	:= (cTmp)->XX_RECNO

				oSay:setText("BANCO: "+SE1->E1_PORTADO) ; ProcessMessages()

				aBaixa := {	{"E1_PREFIXO"  ,SE1->E1_PREFIXO	,nil    },;
							{"E1_NUM"      ,SE1->E1_NUM		,nil    },;
							{"E1_PARCELA"  ,SE1->E1_PARCELA	,nil    },;
							{"E1_TIPO"     ,SE1->E1_TIPO	,nil    },;
							{"AUTMOTBX"    ,"NOR"			,nil    },;
							{"AUTBANCO"    ,SE1->E1_PORTADO	,nil    },;
							{"AUTAGENCIA"  ,SE1->E1_AGEDEP	,nil    },;
							{"AUTCONTA"    ,SE1->E1_CONTA	,nil    },;
							{"AUTDTBAIXA"  ,SE1->E1_VENCREA	,nil    },;
							{"AUTDTCREDITO",SE1->E1_VENCREA	,nil    },;
							{"AUTHIST"     ,"RETORNO API"	,nil    },;
							{"AUTJUROS"    ,0				,nil,.T.},;
							{"AUTVALREC"   ,SE1->E1_SALDO	,nil    }}

				lMsErroAuto := .F. ; lAutoErrNoFile := .T. ; lMsHelpAuto := .T.
				msExecAuto({|x| fina070(x,3) },aBaixa)

				if lMsErroAuto
					AutoGrLog("BANCO: "+SE1->E1_PORTADO)
					AutoGrLog("TITULO: "+SE1->E1_NUM)
					MostraErro()
				Else
					If lConcilia
						//Chama fonte de conciliação
						U_XConcilia(nRecSE1)
					EndIf
				EndIf
				FwFreeArray(aBaixa)
			endif
			(cAlias)->( dbSkip() )
		end
	next nInx

	FwAlertSuccess("Processo de baixas finalizado","Baixa dos Retornos")
return

class fnRetornoBanco
			data oPMain
			data oPUp
			data oPDw
	public	data oTmp
			data oGrid
			data cID
			data cTmp
			data cCNPJ
			data aStruct
			data dDe
			data dAte
	
	method new()
	method createPanel()
	method addGetData()
	method addGetCNPJ()
	method addButton()
	method createTable()
	method addGrid()
	method activateView()
	method destroy()
	method getSqlUpdate()
	method atuaTotal()

	method getDataItau()
	method getDataSantander()
	method getDataSafra()
	method getDataBrasil()
endclass

method new(cId,oWin1) class fnRetornoBanco
	::cID		:= cId
	::oPMain	:= oWin1
	::aStruct	:= {}
	::dDe		:= Ctod("")
	::dAte		:= Ctod("")
	::cCNPJ		:= Space(14)
return

method createPanel() class fnRetornoBanco
	local oLayer := FwLayer():new()
	oLayer:init(::oPMain,.F.)
	oLayer:addLine("PARAM",15,.F.)
	oLayer:addLine("GRID" ,85,.F.)
	::oPUp := oLayer:getLinePanel("PARAM")
	::oPDw := oLayer:getLinePanel("GRID")
return

method addGetData() class fnRetornoBanco
	local nL1 := Int(::oPUp:nClientHeight/2/2)+2
	local nL2 := Int(::oPUp:nClientHeight/2/2)
	TSay():new(nL1,005,{||'Data De'},::oPUp,,,,,,.T.)
	TGet():new(nL2,035,{|u|If(PCount()==0,::dDe,::dDe := u)},::oPUp,40,15,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDe")
	TSay():new(nL1,105,{||'Data Ate'},::oPUp,,,,,,.T.)
	TGet():new(nL2,135,{|u|If(PCount()==0,::dAte,::dAte := u)},::oPUp,40,15,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"dDe")
return
return

method addGetCNPJ() class fnRetornoBanco
	local nL1 := Int(::oPUp:nClientHeight/2/2)+2
	local nL2 := Int(::oPUp:nClientHeight/2/2)
	TSay():new(nL1,175,{||'CNPJ'},::oPUp,,,,,,.T.)
	TGet():new(nL2,205,{|u|If(PCount()==0,::cCNPJ,::cCNPJ := u)},::oPUp,40,15,,,0,16777215,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F. ,,"cCNPJ")
return

method addButton(cTexto) class fnRetornoBanco
	local oButton as object
	local bAction as codeblock
	local nLarg	  := 40
	local nCol	  := ::oPUp:nClientWidth/2-nLarg-10 // esses 10 eh somente pra nao ficar tao grudado na borda
	local nLin	  := ::oPUp:nClientHeight/2/2

	do case
		case ::cID == "itau"
			bAction := {|| ::getDataItau() , ::oGrid:refresh(.T.) }
		case ::cID == "safra"
			bAction := {|| ::getDataSafra() , ::oGrid:refresh(.T.) }
		case ::cID == "santander"
			bAction := {|| ::getDataSantander() , ::oGrid:refresh(.T.) }
		case ::cID == "brasil"
			bAction := {|| ::getDataBrasil() , ::oGrid:refresh(.T.) }
	endcase

	oButton := TButton():new(nLin,nCol,cTexto,::oPUp,bAction,nLarg,15,,,.F.,.T.,.F.,,.F.,,,.F.)
return

method createTable() class fnRetornoBanco
	aAdd(::aStruct,{"XX_OK"	 ,"L",01,0})
	aAdd(::aStruct,{"XX_STATUS","C",01,0})
	aAdd(::aStruct,{"XX_RECNO" ,"N",09,0})
	aAdd(::aStruct,{"XX_DESCST","C",30,0})
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_FILIAL"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_PREFIXO"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_NUM"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_PARCELA"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_TIPO"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_CLIENTE"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_LOJA"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_VALOR"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_SALDO"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_EMISSAO"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_VENCTO"))
	aAdd(::aStruct,FwSx3Util():getFieldStruct("E1_VENCREA"))

	::oTmp := FwTemporaryTable():new(,::aStruct)
	::oTmp:create()
	::cTmp := ::oTmp:getAlias()
return

method addGrid() class fnRetornoBanco
	local cFld
	local nInd
	local oColuna
	local bMark := {|| Iif((::cTmp)->XX_OK,"LBOK","LBNO") }
	local bDblMark := {|oBrw| fnMark(::cTmp,oBrw) }
	local bStatus := {|| Iif((::cTmp)->XX_STATUS=='0',"UPDERROR",Iif((::cTmp)->XX_STATUS=='1',"PAPEL_ESCRITO","OK")) }

	::oGrid := FwBrowse():new(::oPDw)
	::oGrid:setDataTable(.T.)
	::oGrid:setAlias(::cTmp)
	::oGrid:setProfileID(::cID)
	::oGrid:disableConfig()
	::oGrid:disableReport()

	::oGrid:addMarkColumns(bMark,bDblMark)
	::oGrid:addStatusColumns(bStatus)

	oColuna := FwBrwColumn():new()
	oColuna:setData({||XX_DESCST})
	oColuna:setTitle("Status Banco")
	oColuna:setSize(30)
	oColuna:setAlign(0)
	oColuna:setPicture("@!")
	::oGrid:setColumns({oColuna})

	for nInd := 1 to Len(::aStruct)
		cFld := ::aStruct[nInd][1]
		if ! "XX_" $ cFld
			oColuna := FwBrwColumn():new()
			oColuna:setData(&("{||"+cFld+"}"))
			oColuna:setTitle(Alltrim(GetSx3Cache(cFld,"X3_TITULO")))
			oColuna:setSize(TamSx3(cFld)[1])
			oColuna:setAlign(Iif(GetSx3Cache(cFld,"X3_TIPO") == "N",2,1))
			oColuna:setPicture(GetSx3Cache(cFld,"X3_PICTURE"))
			::oGrid:setColumns({oColuna})
		endif
	next nInd
return

method activateView() class fnRetornoBanco
	::oGrid:activate(.T.)
return

method destroy() class fnRetornoBanco
	FreeObj(::oPMain) ; FreeObj(::oPUp) ; FreeObj(::oPDw)
	::oTmp:delete() ; FreeObj(::oTmp)
	::oGrid:destroy() ; FreeObj(::oGrid)
return

method getDataItau() class fnRetornoBanco
	local oRet		as object
	local oToken	:= fn4FinToken():new("341",.T.)
	local cToken	:= oToken:getToken()
	local lOk		:= .T.
	local cEndpoint	:= "https://secure.api.cloud.itau.com.br"
	local cRecurso  := "/boletoscash/v2/boletos"
	local cAppKey	:= "4671a37e-c21b-4481-9489-40601cfaaaf3"
	local cQuery	as character
	local cParms	as character
	local cHeadRet	as character
	local cStatus	as character
	local cRet		as character
	local aHeader	:= {}

	if Empty(cToken)
		Alert("nao foi possivel obter token de autenticacao do itau")
		lOk := .F.
	endif

	if lOk
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)
		aAdd(aHeader,"x-itau-apikey: "+cAppKey)
		aAdd(aHeader,"x-itau-correlationID: "+FWUUIDV4())
		aAdd(aHeader,"x-itau-flowID: "+FWUUIDV4())

		::cTmp := ::oTmp:getAlias()

		TcSqlExec("TRUNCATE "+::oTmp:getRealName())

		cQuery := ::getSqlUpdate("341")

		if TcSqlExec(cQuery) != 0
			Alert("erro ao obter dados")
			lOk := .F.
		endif

		if lOk
			(::cTmp)->( dbGotop() )

			if (::cTmp)->( Eof() )
				ApMsgInfo("Nao ha titulos para consultar")
			endif

			while (::cTmp)->( ! Eof() )
				SE1->( dbGoto((::cTmp)->XX_RECNO) )
				n1Total += (::cTmp)->E1_VALOR

				cParms := "id_beneficiario=004500741139"
				cParms += "&codigo_carteira=109"
				cParms += "&nosso_numero="+Right(SE1->E1_IDCNAB,8)

				cRet := HTTPSGet(cEndpoint+cRecurso,;
							"\certs\itau_cert.pem",;
							"\certs\itau_key.pem",;
							"",;
							cParms,;
							120,;
							aHeader,;
							@cHeadRet)

				if ! Empty(cRet)
					oRet := JsonObject():new()
					if Empty(oRet:fromJson(DecodeUtf8(cRet)))
						// 0=erro na req
						// 1=sucesso na req, mas nao liberado pra baixa
						// 2=sucesso na req, liberado pra baixa
						if Valtype(oRet["data"]) == "A" .and. Len(oRet["data"]) > 0
							if Valtype(oRet["data"][1]["dado_boleto"]["dados_individuais_boleto"]) == "A"
								if Len(oRet["data"][1]["dado_boleto"]["dados_individuais_boleto"]) > 0
									cStatus := oRet["data"][1]["dado_boleto"]["dados_individuais_boleto"][1]["situacao_geral_boleto"]
									Reclock(::cTmp,.F.)
									(::cTmp)->XX_DESCST := cStatus
									(::cTmp)->XX_STATUS := Iif(Lower(cStatus)$"baixada-paga","2","1")
									(::cTmp)->( msUnlock() )
								endif
							endif
						endif
					endif
				else
					Reclock(::cTmp,.F.)
					(::cTmp)->XX_DESCST := "erro ao consultar o banco"
					(::cTmp)->( msUnlock() )
				endif

				(::cTmp)->( dbSkip() )
			end
		endif
	endif

	FreeObj(oToken) ; FreeObj(oRet)
	FwFreeArray(aHeader)
return

method getDataSantander() class fnRetornoBanco
	local oRet		as object
	local oToken	:= fn4FinToken():new("033",.T.)
	local cToken	:= oToken:getToken()
	local lOk		:= .T.
	local cEndpoint	:= "https://trust-open.api.santander.com.br"
	local cRecurso  := "/collection_bill_management/v2/bills
	local cAppKey	:= "FZUAMCybSoLCWj8ulJLfoaVai1Y9m3HJ"
	local cParms	as character
	local cQuery	as character
	local cHeadRet	as character
	local cStatus	as character
	local cRet		as character
	local aHeader	:= {}

	if Empty(cToken)
		Alert("nao foi possivel obter token de autenticacao do santander")
		lOk := .F.
	endif

	if lOk
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)
		aAdd(aHeader,"X-Application-Key: "+cAppKey)

		::cTmp := ::oTmp:getAlias()

		TcSqlExec("TRUNCATE "+::oTmp:getRealName())

		cQuery := ::getSqlUpdate("033")

		if TcSqlExec(cQuery) != 0
			Alert("erro ao obter dados")
			lOk := .F.
		endif

		if lOk
			(::cTmp)->( dbGotop() )

			if (::cTmp)->( Eof() )
				ApMsgInfo("Nao ha titulos para consultar")
			endif

			while (::cTmp)->( ! Eof() )
				SE1->( dbGoto((::cTmp)->XX_RECNO) )
				n2Total += (::cTmp)->E1_VALOR

				cParms := "/344062" + "." + Strzero(Val(SE1->E1_IDCNAB),12)

				cRet := HTTPSGet(cEndpoint+cRecurso+cParms,;
							"\certs\certif_cert.pem",;
							"\certs\certif_key.pem",;
							"Agro2024#@!",;
							"tipoConsulta=settlement",;
							120,;
							aHeader,;
							@cHeadRet)

				if ! Empty(cRet)
					oRet := JsonObject():new()
					if Empty(oRet:fromJson(DecodeUtf8(cRet)))
						// 0=erro na req
						// 1=sucesso na req, mas nao liberado pra baixa
						// 2=sucesso na req, liberado pra baixa
						if oRet:hasProperty("status")
							cStatus := oRet["status"]
							Reclock(::cTmp,.F.)
							(::cTmp)->XX_DESCST := cStatus
							(::cTmp)->XX_STATUS := Iif(cStatus=="BAIXADA","2","1")
							(::cTmp)->( msUnlock() )
						endif
					endif
				else
					Reclock(::cTmp,.F.)
					(::cTmp)->XX_DESCST := "erro ao consultar o banco"
					(::cTmp)->( msUnlock() )
				endif

				(::cTmp)->( dbSkip() )
			end
		endif
	endif

	FreeObj(oToken) ; FreeObj(oRet)
	FwFreeArray(aHeader)
return

method getDataSafra() class fnRetornoBanco
	local oToken	:= fn4FinToken():new("422")
	local cToken	:= oToken:getToken()
	local oRest		as object
	local lOk		:= .T.
	local cEndpoint	:= "https://api.safranegocios.com.br/gateway/cobrancas/v1"
	local cRecurso  := "/boletos"
	local cAppKey	:= "41fa65a3-1a71-4437-a169-5bd209eb2d3a"
	local cQuery	as character
	local cParms	as character
	local cStatus	as character
	local aHeader	:= {}

	if Empty(cToken)
		Alert("nao foi possivel obter token de autenticacao do safra")
		lOk := .F.
	endif

	if lOk
		aAdd(aHeader,"Safra-Correlation-ID: "+cAppKey)
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)

		::cTmp := ::oTmp:getAlias()

		TcSqlExec("TRUNCATE "+::oTmp:getRealName())

		cQuery := ::getSqlUpdate("422")

		if TcSqlExec(cQuery) != 0
			Alert("erro ao obter dados")
			lOk := .F.
		endif

		if lOk
			(::cTmp)->( dbGotop() )

			if (::cTmp)->( Eof() )
				ApMsgInfo("Nao ha titulos para consultar")
			endif

			while (::cTmp)->( ! Eof() )
				SE1->( dbGoto((::cTmp)->XX_RECNO) )

				cParms := "agencia="+PadR(Val(SE1->E1_AGEDEP),5,"0")
				cParms += "&conta="+Strzero(Val(SE1->E1_CONTA),9)
				cParms += "&numero="+cValtochar(Val(SE1->E1_IDCNAB))
				cParms += "&numeroCliente="+Strzero(Val(SE1->E1_IDCNAB),9)

				/* oRest := FwRest():new(cEndpoint)
				oRest:setPath(cRecurso)
				if oRest:get(aHeader,cParms) */
				cHeaderGet := ""
				cRet := Httpget(cEndpoint+cRecurso,cParms,,aHeader,@cHeaderGet)
				if ! Empty(cRet)
					// 0=erro na req
					// 1=sucesso na req, mas nao liberado pra baixa
					// 2=sucesso na req, liberado pra baixa
					Reclock(::cTmp,.F.)
					(::cTmp)->XX_DESCST := cStatus
					(::cTmp)->XX_STATUS := "1"
					(::cTmp)->( msUnlock() )
				else
					Reclock(::cTmp,.F.)
					(::cTmp)->XX_DESCST := "erro ao consultar o banco"
					(::cTmp)->( msUnlock() )
				endif

				FreeObj(oRest)

				(::cTmp)->( dbSkip() )
			end
		endif
	endif

	FreeObj(oToken)
	FwFreeArray(aHeader)
return

method getDataBrasil() class fnRetornoBanco
	local oToken	:= fn4FinToken():new("001")
	local cToken	:= oToken:getToken()
	local oRest		as object
	local oRet		as object
	local lOk		:= .T.
	local cEndpoint	:= "https://api.bb.com.br/cobrancas/v2"
	local cRecurso  := "/boletos"
	local cAppKey	:= "94da3b26eb913c60614704611b324b7d"
	local cQuery	as character
	local cParms	as character
	local cStatus	as character
	local aHeader	:= {}

	if Empty(cToken)
		Alert("nao foi possivel obter token de autenticacao do banco do brasil")
		lOk := .F.
	endif

	if lOk
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)

		::cTmp := ::oTmp:getAlias()

		TcSqlExec("TRUNCATE "+::oTmp:getRealName())

		cQuery := ::getSqlUpdate("001")

		if TcSqlExec(cQuery) != 0
			Alert("erro ao obter dados")
			lOk := .F.
		endif

		if lOk
			(::cTmp)->( dbGotop() )

			if (::cTmp)->( Eof() )
				ApMsgInfo("Nao ha titulos para consultar")
			endif

			while (::cTmp)->( ! Eof() )
				SE1->( dbGoto((::cTmp)->XX_RECNO) )
				n3Total += (::cTmp)->E1_VALOR

				cParms := "gw-dev-app-key="+cAppKey
				cParms += "&numeroConvenio=3279055"
				/* cParms += "&indicadorSituacao=B"
				cParms += "&agenciaBeneficiario=2502"
				cParms += "&contaBeneficiario=125625"
				cParms += "&carteiraConvenio=17"
				cParms += "&variacaoCarteiraConvenio=19"
				cParms += "&modalidadeCobranca=4"
				cParms += "&codigoEstadoTituloCobranca=6" */ // liquidado

				oRest := FwRest():new(cEndpoint)
				oRest:setPath(cRecurso+"/"+"000"+"3279055"+SE1->E1_IDCNAB)
				if oRest:get(aHeader,cParms)
					if ! Empty(oRest:CRESULT)
						oRet := JsonObject():new()
						if Empty(oRet:fromJson(DecodeUtf8(oRest:CRESULT)))
							// 0=erro na req
							// 1=sucesso na req, mas nao liberado pra baixa
							// 2=sucesso na req, liberado pra baixa
							cStatus := getDescription(oRet["codigoEstadoTituloCobranca"])
							Reclock(::cTmp,.F.)
							(::cTmp)->XX_DESCST := cStatus
							(::cTmp)->XX_STATUS := Iif(cValtochar(oRet["codigoEstadoTituloCobranca"])$"6/7","2","1")
							(::cTmp)->( msUnlock() )
						endif
					endif
				else
					Reclock(::cTmp,.F.)
					if ! Empty(oRest:CRESULT)
						oRet := JsonObject():new()
						if Empty(oRet:fromJson(DecodeUtf8(oRest:CRESULT)))
							(::cTmp)->XX_DESCST := oRet["errors"][1]["message"]
						else
							(::cTmp)->XX_DESCST := "erro ao consultar o banco"
						endif
					else
						(::cTmp)->XX_DESCST := "erro ao consultar o banco"
					endif
					(::cTmp)->( msUnlock() )
				endif

				FreeObj(oRest)

				(::cTmp)->( dbSkip() )
			end
		endif
	endif

	FreeObj(oToken)
	FwFreeArray(aHeader)
return

method getSqlUpdate(cBanco) class fnRetornoBanco
	local cQuery	as character
	local cIn		as character
	local cAuxFil	as character

	if Right(cModo,2) == "CC"
		cAuxFil := " E1_FILIAL="+ValToSql(xFilial("SE1"))
	else
		cIn := ""
		aEval(FwAllFilial(,,,.F.),{|x| cIn += x+"/" })
		cIn := Left(cIn,Len(cIn)-1)
		cAuxFil := " E1_FILIAL IN "+FormatIn(cIn,"/")
	endif

	cQuery := "INSERT INTO "+::oTmp:getRealName()
	cQuery += " (XX_RECNO,XX_STATUS,E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCTO,E1_VENCREA)"
	cQuery += " SELECT R_E_C_N_O_,'0',E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_CLIENTE,E1_LOJA,E1_VALOR,E1_SALDO,E1_EMISSAO,E1_VENCTO,E1_VENCREA"
	cQuery += " FROM "+RetSqlName("SE1")
	cQuery += " WHERE"
	cQuery += cAuxFil
	cQuery += " AND E1_PORTADO="+ValToSql(cBanco)
	cQuery += " AND E1_SALDO>0"
	cQuery += " AND E1_IDCNAB<>''"
	cQuery += " AND E1_XAPI='T'"
	cQuery += " AND D_E_L_E_T_=' '"
return cQuery

static function fnMark(cAlias,oBrw)
	if (cAlias)->XX_STATUS == "2"
		Reclock(cAlias,.F.)
		(cAlias)->( XX_OK := ! XX_OK )
		(cAlias)->(msUnlock())
		oBrw:lineRefresh()

		If oFolder:noption = 1
			if (cAlias)->XX_OK
				n1TotMarc += (cAlias)->E1_VALOR
				n1Marcado++
			else
				n1TotMarc -= (cAlias)->E1_VALOR
				n1Marcado--
			endif
		Elseif oFolder:noption = 2
			if (cAlias)->XX_OK
				n2TotMarc += (cAlias)->E1_VALOR
				n2Marcado++
			else
				n2TotMarc -= (cAlias)->E1_VALOR
				n2Marcado--
			endif
		ElseIf oFolder:noption = 3
			if (cAlias)->XX_OK
				n3TotMarc += (cAlias)->E1_VALOR
				n3Marcado++
			else
				n3TotMarc -= (cAlias)->E1_VALOR
				n3Marcado--
			endif
		EndIf

		fAtuTotal()
	endif
return

static function getDescription(nRet)
	local cRet := ""
	do case
		case nRet == 1
			cRet := "NORMAL"
		case nRet == 2
			cRet := "MOVIMENTO CARTORIO"
		case nRet == 3
			cRet := "EM CARTORIO"
		case nRet == 4
			cRet := "TITULO COM OCORRENCIA DE CARTORIO"
		case nRet == 5
			cRet := "PROTESTADO ELETRONICO"
		case nRet == 6
			cRet := "LIQUIDADO"
		case nRet == 7
			cRet := "BAIXADO"
		case nRet == 8
			cRet := "TITULO COM PENDENCIA DE CARTORIO"
		case nRet == 9
			cRet := "TITULO PROTESTADO MANUAL"
		case nRet == 10
			cRet := "TITULO BAIXADO/PAGO EM CARTORIO"
		case nRet == 11
			cRet := "TITULO LIQUIDADO/PROTESTADO"
		case nRet == 12
			cRet := "TITULO LIQUID/PGCRTO"
		case nRet == 13
			cRet := "TITULO PROTESTADO AGUARDANDO BAIXA"
		case nRet == 14
			cRet := "TITULO EM LIQUIDACAO"
		case nRet == 15
			cRet := "TITULO AGENDADO"
		case nRet == 16
			cRet := "TITULO CREDITADO"
		case nRet == 17
			cRet := "PAGO EM CHEQUE - AGUARD.LIQUIDACAO"
		case nRet == 18
			cRet := "PAGO PARCIALMENTE"
		case nRet == 19
			cRet := "PAGO PARCIALMENTE CREDITADO"
		case nRet == 21
			cRet := "TITULO AGENDADO COMPE"
		case nRet == 80
			cRet := "EM PROCESSAMENTO (ESTADO TRANSITÓRIO)"
	endcase
return cRet

static Function fAtuTotal()

	If oFolder:noption = 1
		M->CTG2	:= n1Marcado
		M->VLR2  := n1Total
		M->MKD2  := n1TotMarc
	Elseif oFolder:noption = 2
		M->CTG2  := n2Marcado
		M->VLR2  := n2Total
		M->MKD2  := n2TotMarc
	ElseIf oFolder:noption = 3
		M->CTG2  := n3Marcado
		M->VLR2  := n3Total
		M->MKD2  := n3TotMarc
	EndIf

	//Atualiza totais
	if oEnch2 != nil
		oEnch2:refresh()
	endif
return

static function TotalDef(oWin2)
	local aField := {}
	local aCpoEnch2 := {"CTG2","VLR2","MKD2"}
	local aPos := {000,000,010,010}

	Aadd(aField, {"Marcados",;				// [01] - Titulo
				"CTG2",;						// [02] - campo
				"N",;						// [03] - Tipo
				16,;						// [04] - Tamanho
				0,;							// [05] - Decimal
				"9999999999999999",;		// [06] - Picture
				".T.",;						// [07] - Valid
				.F.,;						// [08] - Obrigat
				0,;							// [09] - Nivel
				"",;						// [10] - Inicializador Padrao
				nil,;						// [11] - F3
				"",;						// [12] - when
				.T.,;						// [13] - visual
				.F.,;						// [14] - chave
				"",;						// [15] - box
				nil,;						// [16] - folder
				.T.,;						// [17] - nao alteravel
				nil,;						// [18] - pictvar
				"N"})						// [19] - gatilho
	Aadd(aField, {"Total R$",;				// [01] - Titulo
				"VLR2",;						// [02] - campo
				"N",;						// [03] - Tipo
				14,;						// [04] - Tamanho
				2,;							// [05] - Decimal
				"@E 9,999,999,999.99",;		// [06] - Picture
				".T.",;						// [07] - Valid
				.F.,;						// [08] - Obrigat
				0,;							// [09] - Nivel
				"",;						// [10] - Inicializador Padrao
				nil,;						// [11] - F3
				"",;						// [12] - when
				.T.,;						// [13] - visual
				.F.,;						// [14] - chave
				"",;						// [15] - box
				nil,;						// [16] - folder
				.T.,;						// [17] - nao alteravel
				nil,;						// [18] - pictvar
				"N"})						// [19] - gatilho
	Aadd(aField, {"Total Marcado R$",;		// [01] - Titulo
				"MKD2",;						// [02] - campo
				"N",;						// [03] - Tipo
				14,;						// [04] - Tamanho
				2,;							// [05] - Decimal
				"@E 9,999,999,999.99",;		// [06] - Picture
				".T.",;						// [07] - Valid
				.F.,;						// [08] - Obrigat
				0,;							// [09] - Nivel
				"",;						// [10] - Inicializador Padrao
				nil,;						// [11] - F3
				"",;						// [12] - when
				.T.,;						// [13] - visual
				.F.,;						// [14] - chave
				"",;						// [15] - box
				nil,;						// [16] - folder
				.T.,;						// [17] - nao alteravel
				nil,;						// [18] - pictvar
				"N"})						// [19] - gatilho

	oEnch2 := MsmGet():new(,,2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnch2,aPos,{},/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oWin2,/*lF3*/,.T.,/*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aField)
	oEnch2:oBox:align := CONTROL_ALIGN_ALLCLIENT

	fAtuTotal()
return
