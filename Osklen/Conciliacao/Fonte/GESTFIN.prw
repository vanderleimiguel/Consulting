#include "protheus.ch"
#include 'fwmvcdef.ch'

static oDlg   := nil
static oEnch  := nil
static oRadio := nil
static oGrid  := nil
static oTable := nil
static nRadio := 1
static cReal  := nil
static aFilt  := nil
static cTmp	  := nil

/*/{Protheus.doc} GESTFIN
	funcionalidades para o contas a receber
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
User Function GESTFIN
	local oLayer		as object
	local opAct  		as object
	local opDir 		as object
	local opFtr 		as object
	local opTot 		as object
	local opLog 		as object
	local oLogo 		as object
	local oScroll 		as object
	local oPButton 		as object
	local cBkp			:= Iif(Type("cCadastro")!="U",cCadastro,nil)
	local lContinue		:= .T.
	local aDimen		as array

	MsgRun("Inicializando ....","AGUARDE",{|| lContinue := fnValid() })
	if ! lContinue
		return
	endif

	private cModo		:= FwModeAccess("SE1", 1) + FwModeAccess("SE1", 2) + FwModeAccess("SE1", 3)
	private __aConta	:= {}
	private cCadastro	:= "Gerenciador de Boletos"
	//objeto0 
    Private oChkObj0 
    Private lChkObj0    := .T.  
    Private oChkObj1 
    Private lChkObj1    := .F.  
    Private oChkObj2 
    Private lChkObj2    := .F.  
    Private oChkObj3 
    Private lChkObj3    := .F.  
    Private oChkObj4 
    Private lChkObj4    := .F.  
    Private oChkObj5 
    Private lChkObj5    := .F.  
    Private oChkObj6 
    Private lChkObj6    := .F.  
    Private oChkObj7 
    Private lChkObj7    := .F.  
    Private oChkObj8 
    Private lChkObj8    := .F.  
    Private oChkObj9 
    Private lChkObj9    := .F.  
    Private oChkObj10 
    Private lChkObj10   := .F.  
    Private oChkObj11 
    Private lChkObj11   := .F.  
    Private oChkObj12 
    Private lChkObj12   := .F.  	
	Private cFontNome   := 'Tahoma'
    Private oFontPadrao := TFont():New(cFontNome, , -13)

	oDlg := FwDialogModal():new()
	oDlg:setTitle(cCadastro)
	oDlg:enableAllClient()
	oDlg:setCloseButton(.F.)
	oDlg:setEscClose(.F.)
	oDlg:enableFormBar(.F.)
	oDlg:createDialog()

	oLayer := FwLayer():new()
	oLayer:init(oDlg:getPanelMain(),.F.)
	oLayer:addLine('LINHA',100,.T.)

	oLayer:addCollumn('COLUNA_ESQ',15,.T.,'LINHA')
	oLayer:addWindow('COLUNA_ESQ','JANELA_ESQ_LOGO' ,''		,25,.F.,.T.,,'LINHA')
	oLayer:addWindow('COLUNA_ESQ','JANELA_ESQ_ACOES','Acoes',75,.F.,.T.,,'LINHA')

	oLayer:addCollumn('COLUNA_DIR',85,.T.,'LINHA')
	if FWGetDialogSize(oLayer:getColPanel('COLUNA_DIR','LINHA'))[3] > 768
		aDimen := {10,65,25}
	else
		aDimen := {15,55,30}
	endif

	oLayer:addWindow('COLUNA_DIR','JANELA_DIR_CIMA'  ,'Filtros'			 ,aDimen[1],.F.,.T.,,'LINHA')
	oLayer:addWindow('COLUNA_DIR','JANELA_DIR_CENTRO','Titulos a Receber',aDimen[2],.F.,.T.,,'LINHA')
	oLayer:addWindow('COLUNA_DIR','JANELA_DIR_BAIXO' ,'Totais'			 ,aDimen[3],.F.,.T.,,'LINHA')

	opLog := oLayer:getWinPanel('COLUNA_ESQ','JANELA_ESQ_LOGO'	,'LINHA')
	opAct := oLayer:getWinPanel('COLUNA_ESQ','JANELA_ESQ_ACOES'	,'LINHA')
	opDir := oLayer:getWinPanel('COLUNA_DIR','JANELA_DIR_CENTRO','LINHA')
	opFtr := oLayer:getWinPanel('COLUNA_DIR','JANELA_DIR_CIMA'	,'LINHA')
	opTot := oLayer:getWinPanel('COLUNA_DIR','JANELA_DIR_BAIXO'	,'LINHA')

	oLogo := TBitmap():new(1,1,1,,"gestfin-logo",,.T.,opLog,,,.F.,.T.)
	oLogo:align := CONTROL_ALIGN_ALLCLIENT

	oScroll := TScrollArea():new(opAct,01,01,100,100)
	oScroll:align := CONTROL_ALIGN_ALLCLIENT
	
	@ 000,000 MSPANEL oPButton OF oScroll SIZE 20,450 COLOR CLR_HRED
	
	oScroll:setFrame(oPButton)

	MsgRun("Definindo filtros estaticos ....","Aguarde",{|| Filter1Def() })
	MsgRun("Definindo botoes ...."			 ,"Aguarde",{|| ButtonDef(oPButton) })
	MsgRun("Definindo estruturas ...."		 ,"Aguarde",{|| StructDef() })
	MsgRun("Definindo dados ...."			 ,"Aguarde",{|| lContinue := LoadDef() })

	if ! lContinue
		return
	endif

	M->CTG := M->VLR := M->SLD := M->BXD := M->CON := M->NCO := M->MKD := 0

	MsgRun("Criando browse ...." ,"Aguarde",{|| BrowserDef(opDir) })
	// MsgRun("Criando filtros ....","Aguarde",{|| Filter2Def(opFtr) })
	MsgRun("Criando filtros ....","Aguarde",{|| fTcheckbox(opFtr) })
	MsgRun("Criando totais ...." ,"Aguarde",{|| TotalDef(opTot) })

	oDlg:activate()

	if cBkp != nil
		cCadastro := cBkp
	endif

	oTable:delete() ; FreeObj(oTable)
	oGrid:deActivate() ; FreeObj(oGrid)
	FreeObj(oDlg) ; FreeObj(oLayer) ; FreeObj(oLogo)
	FreeObj(opAct) ; FreeObj(opDir) ; FreeObj(opFtr) ; FreeObj(opTot) ; FreeObj(opLog)
	FreeObj(oScroll) ; FreeObj(oPButton)
	FwFreeArray(__aConta) ; FwFreeArray(aDimen)
return

static function Filter1Def()
	aFilt := {}
	aAdd(aFilt,{ "Abertos"		  , "E1_SALDO > 0 .AND. E1_VALOR == E1_SALDO"	, "E1_SALDO > 0 AND E1_VALOR = E1_SALDO"	})
	aAdd(aFilt,{ "Parc Baixados"  , "E1_SALDO > 0 .AND. E1_VALOR != E1_SALDO"	, "E1_SALDO > 0 AND E1_VALOR <> E1_SALDO"	})
	aAdd(aFilt,{ "Baixados"		  , "E1_SALDO == 0"								, "E1_SALDO = 0"							})
	aAdd(aFilt,{ "Com Borderô"	  , "E1_PORTADO != ''"							, "E1_PORTADO <> ''"						})
	aAdd(aFilt,{ "Sem Borderô"	  , "Empty(E1_PORTADO)"							, "E1_PORTADO = ''"							})
	aAdd(aFilt,{ "Adiantamento"	  , "E1_TIPO == 'RA '"							, "E1_TIPO = 'RA '"							})
	aAdd(aFilt,{ "Conciliados" 	  , "XX_RECONC == 'x'"							, "XX_RECONC = 'x'"							})
	aAdd(aFilt,{ "Não Conciliados", "XX_RECONC <> 'x'" 							, "XX_RECONC <> 'x'"						})
	aAdd(aFilt,{ "Itaú"			  , "E1_PORTADO == '341'"						, "E1_PORTADO = '341'"						})
	aAdd(aFilt,{ "Santander"	  , "E1_PORTADO == '033'"						, "E1_PORTADO = '033'"						})
	aAdd(aFilt,{ "Banco Brasil  "   , "E1_PORTADO == '001'"						, "E1_PORTADO = '001'"						})
	aAdd(aFilt,{ "Safra"		  , "E1_PORTADO == '422'"						, "E1_PORTADO = '422'"						})
return

static function LoadDef()
	local cSelect := ""
	local cSql	  as character

	aEval(FwSx3Util():getAllFields("SE1",.F.),{|x| cSelect += x + "," })

	cReal := oTable:getRealName()
	cSql := "INSERT INTO "+cReal+" ("+cSelect+"XX_OK,XX_RECNO,XX_RECONC)"
	cSql += " SELECT "+cSelect+"'F' AS XX_OK,SE1.R_E_C_N_O_,SE5.E5_RECONC"
	cSql += " FROM "+RetSqlName("SE1")+" SE1 "
	cSql += " LEFT JOIN " + RetSqlName("SE5") + " SE5 ON SE5.E5_DTCANBX = ' ' AND SE5.E5_RECPAG = 'R' AND SE5.E5_PREFIXO = SE1.E1_PREFIXO AND SE5.E5_NUMERO = SE1.E1_NUM AND SE5.E5_PARCELA = SE1.E1_PARCELA AND SE5.D_E_L_E_T_ = ''"
	cSql += " WHERE SE1.D_E_L_E_T_=' '"

	if TcSqlExec(cSql) != 0
		Alert(TcSqlError())
		return .F.
	endif
return .T.

static function RefreshDef(lGotop)
	MsgRun("atualizando dados ....","AGUARDE",{|| oTable:zap() , M->MKD:=0, LoadDef() , fnUpdateTotal() , oGrid:refresh(lGotop) })
return

static function fnMark(lMarkAll)
	if lMarkAll
		fnAllMark()
	else
		fnExecMark()
		oGrid:lineRefresh()
		if oEnch != nil
			oEnch:refresh()
		endif
	endif
return

static function fnExecMark(lMsg)
	default lMsg := .T.
	// if fnCanIAdd(lMsg)
		Reclock(cTmp,.F.)
		(cTmp)->XX_OK := StrTran(cValtochar( .not. ((cTmp)->XX_OK == "T") ),".")
		(cTmp)->(msUnlock())

		if (cTmp)->XX_OK == "T"
			M->MKD += (cTmp)->E1_VALOR
		else
			M->MKD -= (cTmp)->E1_VALOR
		endif
	// endif
return

static function fnCanIAdd(lMsg)
	if ! Empty((cTmp)->E1_NUMBOR)
		if lMsg
			ApMsgInfo("bordero ja gerado ["+(cTmp)->E1_NUMBOR+"]")
		endif
	endif
return .T.

static function fnLegenda(lLista)
	local cRet as character
	local aLegenda as array
	local nInd as numeric
	default lLista 	:= .T.
	
	if lLista
		aLegenda := {}
		aAdd(aLegenda,{"BR_VERDE"	, "Titulo em aberto" })
		aAdd(aLegenda,{"BR_AZUL"	, "Baixado parcialmente" })
		aAdd(aLegenda,{"BR_VERMELHO", "Titulo Baixado" })
		aAdd(aLegenda,{"BR_PRETO"	, "Titulo em Bordero" })
		aAdd(aLegenda,{"BR_BRANCO"	, "Adiantamento com saldo" })
		aAdd(aLegenda,{"BR_CINZA"	, "Titulo baixado parcialmente e em bordero" })
		BrwLegenda(cCadastro, "Legenda", aLegenda)
	else
		aAux := Fa040Legenda("SE1")
		for nInd := 1 to Len(aAux)
			if &(aAux[nInd][1])
				cRet := aAux[nInd][2]
				exit
			endif
		next nInd
		FwFreeArray(aAux)
	endif
return cRet

static function fnLegConc(lLista)
	local cRet as character
	local aLegenda as array
	local aAux as array
	local nInd as numeric
	Local cPrefixo	:= E1_PREFIXO
	Local cNum		:= E1_NUM
	Local cParcela	:= E1_PARCELA
	Local cTipo		:= E1_TIPO
	Local cCliente	:= E1_CLIENTE
	Local cLoja		:= E1_LOJA
	default lLista 	:= .T.
	
	if lLista
		aLegenda := {}
		aAdd(aLegenda,{"BR_VERMELHO", "Titulo nao conciliado" })
		aAdd(aLegenda,{"BR_AZUL"	, "Titulo Conciliado" })
		BrwLegenda(cCadastro, "Legenda", aLegenda)
	else
		aAux := {}
		aadd(aAux, {"ROUND(E1_SALDO,2) > 0", "BR_VERMELHO"} )
		aadd(aAux, {"ROUND(E1_SALDO,2) = 0", "BR_AZUL"} )

		for nInd := 1 to Len(aAux)
			if &(aAux[nInd][1])
				If nInd = 1
					cRet := aAux[nInd][2]
					exit
				Else
					SE5->( DbSetOrder(7) )                                                                                
					If SE5->(DbSeek(xFilial("SE5")+cPrefixo+cNum+cParcela+cTipo+cCliente+cLoja))
						While cPrefixo+cNum+cParcela+cTipo+cCliente+cLoja == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
							If !Empty(SE5->E5_RECONC)
								cRet := aAux[nInd][2]
								exit
							else
								cRet := "BR_VERMELHO"
								// exit
							EndIf
							SE5->(DbSkip())
						EndDo
						Exit
					else
						cRet := "BR_VERMELHO"
						exit
					EndIf
				EndIf
			endif
		next nInd

		if oEnch != nil
			oEnch:refresh()
		endif
		FwFreeArray(aAux)
	endif
return cRet

static function fnParametros()
	local aParms as array
	local xAux
	local xConteud
	local cPar as character
	local cDsc as character
	local cBkp := cCadastro
	local aBkp as array
	local nIdx as numeric

	if ! FwIsAdmin()
		return
	endif

	aParms := {}
	xAux := GetMv("FC_NUMDIA1",,2)
	aAdd(aParms,{1,"Dias a Vencer",xAux,"",".T.","",".T.",80,.F.})
	xAux := GetMv("FC_NUMDIA2",,2)
	aAdd(aParms,{1,"Dias Vencidos",xAux,"",".T.","",".T.",80,.F.})
	/* xAux := GetMv("FC_BOLPASS",,"2")
	aAdd(aParms,{1,"FC_BOLPASS",xAux,"",".T.","",".T.",80,.F.})
	xAux := GetMv("FC_ATUEML",,"1")
	aAdd(aParms,{1,"FC_ATUEML",xAux,"",".T.","",".T.",80,.F.})
	xAux := GetMv("FC_FLDMAIL",,"A1_EMAIL")
	aAdd(aParms,{1,"FC_FLDMAIL",xAux,"",".T.","",".T.",80,.F.}) */

	aBkp := {}
	aEval(aParms,{|x,y| aAdd(aBkp,&("MV_PAR"+StrZero(y,2))) })

	if ParamBox(aParms,"Informe os parametros")
		for nIdx := 1 to Len(aParms)
			xConteud := &("MV_PAR"+StrZero(nIdx,2))
			if aParms[nIdx][3] != xConteud
				if nIdx == 1
					cPar := "FC_NUMDIA1"
					cDsc := "Dias a considerar antes de vencer"
				elseif nIdx == 2
					cPar := "FC_NUMDIA2"
					cDsc := "Dias a considerar pos vencimento"
				endif

				if FwSx6Util():existsParam(cPar)
					PutMv(cPar,xConteud)
				else
					RecLock("SX6",.T.)
					SX6->X6_FIL     := xFilial("SX6")
					SX6->X6_VAR     := cPar
					SX6->X6_TIPO    := Valtype(xConteud)
					SX6->X6_DESCRIC := cDsc
					SX6->X6_CONTEUD := cValtochar(xConteud)
					SX6->( msUnLock() )
				endif
			endif
		next nIdx
	endif

	aEval(aBkp,{|x,y| &("MV_PAR"+StrZero(y,2)) := x })
	cCadastro := cBkp ; FwFreeArray(aBkp)
return

static function fnValid()
	local lRet := .T.
	if ! (lRet := lRet .and. fnValid4fin())
		Alert("falha na liberacao do acesso. Contatar o departamento comercial da Fas Solutions")
	endif
	if ! (lRet := lRet .and. SEE->( FieldPos("EE_XCONFIG") > 0 ))
		Alert("campo EE_XCONFIG nao criado")
	endif
	if ! (lRet := lRet .and. SEE->( FieldPos("EE_XTIPAPI") > 0 ))
		Alert("campo EE_XTIPAPI nao criado")
	endif
	if ! (lRet := lRet .and. SA1->( FieldPos("A1_XEMLCOB") > 0 ))
		Alert("campo A1_XEMLCOB nao criado")
	endif
	if ! (lRet := lRet .and. SE1->( FieldPos("E1_XAPI") > 0 ))
		Alert("campo E1_XAPI nao criado")
	endif
return lRet

static function fnValid4fin()
	local cHeadRet	:= ""
	local aHeadOut	:= {'Content-Type: application/json'}
	local nTimeOut	:= 120
	local cUrl		:= "177.76.114.124:8081/rest/4fin/v1/licenca"
	local cRet		:= ""
	local lOk		:= .T.
	local jRet		as json
	local jBody		:= JsonObject():new()

	jBody["cnpj"] := FwSm0Util():getSM0Data(,,{"M0_CGC"})[1,2]

	cRet := HttpPost(cUrl, , jBody:toJson(), nTimeOut, aHeadOut, @cHeadRet)

	if ! Empty(cRet)
		jRet := JsonObject():new()
		if Empty(jRet:fromJson(cRet))
			if (lOk := jRet["success"])
				__aConta := aClone(jRet["contas"])
			endif
		endif
	endif

	FreeObj(jBody) ; FreeObj(jRet) ; FwFreeArray(aHeadOut)
return lOk

static function fnLegBco()
	local cRet as character
	do case
		case E1_PORTADO=='341'
			cRet := "itau"
		case E1_PORTADO=='033'
			cRet := "santander"
		case E1_PORTADO=='001'
			cRet := "bb"
		case E1_PORTADO=='422'
			cRet := "safra"
		case E1_PORTADO=='246'
			cRet := "abc-brasil"
	endcase
return cRet

static function BrowserDef(oPanel)
	local oColuna	as object
	local nInd		as numeric
	local aSE1		:= FwSx3Util():getAllFields("SE1",.F.)
	local aSeek		:= {}
	local aAux		:= {}
	local aFilter	:= {}
	local aBrowse	:= Iif(Right(cModo,2) == "CC",{},{"E1_FILIAL"})
	local cTitSeek	as character
	local cFld		as character

	for nInd := 1 to Len(aSE1)
		aAux := FwSx3Util():getFieldStruct(aSE1[nInd])
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

	aEval(Separa(SE1->(IndexKey(1)),"+",.F.),;
			{|x| cTitSeek += Iif(! "FILIAL" $ x .or. Right(cModo,2) != "CC",Trim(GetSx3Cache(x,"X3_TITULO"))+"+","") })

	aEval(Separa(SE1->(IndexKey(1)),"+",.F.),;
			{|x| aAdd(aAux,{"",;
							GetSx3Cache(x,"X3_TIPO"),;
							GetSx3Cache(x,"X3_TAMANHO"),;
							GetSx3Cache(x,"X3_DECIMAL"),;
							AllTrim(GetSx3Cache(x,"X3_TITULO")),;
							AllTrim(GetSx3Cache(x,"X3_PICTURE"))}) })
	aAdd(aSeek,{cTitSeek,aAux})

	oGrid := FwMBrowse():new()
	oGrid:setDataTable(.T.)
	oGrid:setAlias(cTmp := oTable:getAlias())
	oGrid:setSeek(,aSeek)
	oGrid:setFieldFilter(aFilter)
	oGrid:setUseFilter()
	// oGrid:setTimer({|| RefreshDef(.F.) }, 30000) // 30seg
	oGrid:disableConfig()
	oGrid:disableReport()
	oGrid:disableDetails()

	oGrid:setVldExecFilter({|| fnUpdateTotal() })

	aEval(aFilt,{|x| oGrid:addFilter(x[1],x[2]) })

	oGrid:addMarkColumns({|| Iif(XX_OK=='T',"LBOK","LBNO") }, {|| fnMark(.F.) }, {|| fnMark(.T.) })
	oGrid:addStatusColumns({|| fnLegBco() })
	oGrid:addStatusColumns({|| fnLegenda(.F.) },{|| fnLegenda() })
	oGrid:addStatusColumns({|| fnLegConc(.F.) },{|| fnLegConc() })

	for nInd := 1 to Len(aBrowse)
		cFld := aBrowse[nInd]
		oColuna := FwBrwColumn():new()
		oColuna:setData(&("{||"+cFld+"}"))
		oColuna:setTitle(Alltrim(GetSx3Cache(cFld,"X3_TITULO")))
		oColuna:setSize(TamSx3(cFld)[1])
		oColuna:setAlign(Iif(GetSx3Cache(cFld,"X3_TIPO") == "N",2,1))
		oColuna:setPicture(GetSx3Cache(cFld,"X3_PICTURE"))
		oGrid:setColumns({oColuna})
	next nInd

	oGrid:activate(oPanel)

return

static function StructDef()
	local aHeader := {}

	aEval(FwSx3Util():getAllFields("SE1",.F.),{|x| aAdd(aHeader,FwSx3Util():getFieldStruct(x)) })
	aAdd(aHeader,{"XX_OK","C",1,0})
	aAdd(aHeader,{"XX_RECNO","N",9,0})
	aAdd(aHeader,{"XX_RECONC","C",1,0})

	oTable := FwTemporaryTable():new(,aHeader)
	oTable:addIndex("1",Separa(SE1->(IndexKey(1)),"+",.F.))
	oTable:addIndex("2",{"XX_OK","E1_CLIENTE","E1_LOJA"})
	oTable:addIndex("3",{"E1_NUMBOR"})
	oTable:addIndex("4",{"XX_RECNO"})

	// criado para performance
	oTable:addIndex("5",{"E1_SALDO","E1_VALOR"})
	oTable:addIndex("6",{"E1_PORTADO"})
	oTable:addIndex("7",{"E1_TIPO"})
	oTable:addIndex("8",{"E1_EMISSAO"})

	oTable:create()

	FwFreeArray(aHeader)
return

static function ButtonDef(oPanel)
	local cCssBtn		as character
	local oTitulo		as object
	local oBoleto		as object
	local oEnviarBol	as object
	local oBaixar		as object
	local oItau			as object
	local oSantander	as object
	local oBB			as object
	local oSafra		as object
	local oABC			as object
	local oCliente		as object
	local oSair			as object
	local oParametros	as object
	local oEstorno		as object
	local oDanfe		as object
	local oOcorrencia	as object
	local oTxtEmail		as object
	local oRetAPI		as object
	local oPosicao		as object
	local oTitAberto	as object
	local oTitReceb		as object
	local oPedidos		as object
	local oFatur		as object
	local oReferenc		as object
	local oNatureza		as object
	local oCompensar	as object
	local oMoeda		as object
	local oSaldoBco		as object
	local oContabil		as object
	local oConcilia		as object

	local bTitulo		:= {|| U_GESTFINC(cTmp) , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bBoleto		:= {|| U_xBOLETO(cTmp) }
	local bEnviarBol	:= {|| U_xEMAIL(cTmp) }
	local bBaixar		:= {|| U_GESTFIN5(cTmp) , RefreshDef(.T.), oGrid:setFocus() }
	local bConcilia		:= {|| U_GESTFINJ(cTmp) , RefreshDef(.T.), oGrid:setFocus() }
	local bItau			:= {|| U_GESTFIN2(cTmp,"341") , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bSantander	:= {|| U_GESTFIN2(cTmp,"033") , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bBB			:= {|| U_GESTFIN2(cTmp,"001") , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bSafra		:= {|| U_GESTFIN2(cTmp,"422") , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bABC			:= {|| U_GESTFIN2(cTmp,"246") , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bCliente		:= {|| U_GESTFIN4(cTmp) }
	local bSair			:= {|| oDlg:deActivate() }
	local bParametros	:= {|| fnParametros() }
	local bEstorno		:= {|| U_GESTFIN3(cTmp) , oGrid:goTo((cTmp)->(Recno()),.T.) , oGrid:setFocus() }
	local bDanfe		:= {|| U_GESTFIN6(cTmp) , oGrid:setFocus() }
	local bOcorrencia	:= {|| U_GESTFIN7(cTmp) , oGrid:setFocus() }
	local bTextoEmail	:= {|| U_GESTFIN8(cTmp) , oGrid:setFocus() }
	local bRetornoAPI	:= {|| U_GESTFIN9(cTmp) , oGrid:setFocus() }
	local bPosicao		:= {|| U_GESTFINA(cTmp) , oGrid:setFocus() }
	local bTitAberto	:= {|| U_GESTFINB(cTmp,1) , oGrid:setFocus() }
	local bTitReceb		:= {|| U_GESTFINB(cTmp,2) , oGrid:setFocus() }
	local bPedidos		:= {|| U_GESTFINB(cTmp,3) , oGrid:setFocus() }
	local bFatur		:= {|| U_GESTFINB(cTmp,4) , oGrid:setFocus() }
	local bReferenc		:= {|| U_GESTFINB(cTmp,5) , oGrid:setFocus() }
	local bNatureza		:= {|| U_GESTFIND(cTmp) , oGrid:setFocus() }
	local bCompensar	:= {|| U_GESTFINE(cTmp) , RefreshDef(.T.), oGrid:setFocus() }
	local bMoeda		:= {|| U_GESTFINF(cTmp) , oGrid:setFocus() }
	local bSaldoBco		:= {|| U_GESTFING(cTmp) , oGrid:setFocus() }
	local bContabil		:= {|| U_GESTFINH(cTmp) , oGrid:setFocus() }

	cCssBtn := "QPushButton {"
	cCssBtn += " background-image: url(rpo:##BANCO##.png);background-repeat: none; margin: 2px;"
	cCssBtn += " border-style: outset;"
	cCssBtn += " border-width: 2px;"
	cCssBtn += " border: 1px solid #C0C0C0;"
	cCssBtn += " border-radius: 5px;"
	cCssBtn += " border-color: #C0C0C0;"
	cCssBtn += " font: bold 12px Arial;"
	cCssBtn += " padding: 6px;"
	cCssBtn += "}"
	cCssBtn += "QPushButton:pressed {"
	cCssBtn += " background-color: #e6e6f9;"
	cCssBtn += " border-style: inset;"
	cCssBtn += "}"

	oTitulo := TButton():new(1,202,'Titulo',oPanel,bTitulo,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oTitulo:setCss(StrTran(cCssBtn,"##BANCO##","AGENDA"))
	oTitulo:align := CONTROL_ALIGN_TOP

	oBoleto := TButton():new(1,202,'Gerar Boleto',oPanel,bBoleto,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBoleto:setCss(StrTran(cCssBtn,"##BANCO##","SUMARIO"))
	oBoleto:align := CONTROL_ALIGN_TOP

	oEnviarBol := TButton():new(1,202,'Enviar Boleto',oPanel,bEnviarBol,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oEnviarBol:setCss(StrTran(cCssBtn,"##BANCO##","BMPPOST"))
	oEnviarBol:align := CONTROL_ALIGN_TOP

	oBaixar := TButton():new(1,202,'Baixar Titulo',oPanel,bBaixar,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBaixar:setCss(StrTran(cCssBtn,"##BANCO##","LIQCHECK"))
	oBaixar:align := CONTROL_ALIGN_TOP

	oConcilia := TButton():new(1,202,'Conciliar',oPanel,bConcilia,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oConcilia:setCss(StrTran(cCssBtn,"##BANCO##","LIQCHECK"))
	oConcilia:align := CONTROL_ALIGN_TOP

	oItau := TButton():new(1,202,'Itau',oPanel,bItau,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oItau:setCss(StrTran(cCssBtn,"##BANCO##","itau"))
	oItau:align := CONTROL_ALIGN_TOP

	oSantander := TButton():new(1,202,'Santander',oPanel,bSantander,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSantander:setCss(StrTran(cCssBtn,"##BANCO##","santander"))
	oSantander:align := CONTROL_ALIGN_TOP

	oBB := TButton():new(1,202,'Banco do Brasil',oPanel,bBB,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oBB:setCss(StrTran(cCssBtn,"##BANCO##","bb"))
	oBB:align := CONTROL_ALIGN_TOP

	oSafra := TButton():new(1,202,'Safra',oPanel,bSafra,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSafra:setCss(StrTran(cCssBtn,"##BANCO##","safra"))
	oSafra:align := CONTROL_ALIGN_TOP

	oABC := TButton():new(1,202,'ABC Brasil',oPanel,bABC,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oABC:setCss(StrTran(cCssBtn,"##BANCO##","abc-brasil"))
	oABC:align := CONTROL_ALIGN_TOP
	oABC:disable()
	oABC:hide()

	oCliente := TButton():new(1,202,'Cliente',oPanel,bCliente,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oCliente:setCss(StrTran(cCssBtn,"##BANCO##","POSCLI"))
	oCliente:align := CONTROL_ALIGN_TOP

	oOcorrencia := TButton():new(1,202,'Ocorrencia',oPanel,bOcorrencia,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oOcorrencia:align := CONTROL_ALIGN_TOP
	oOcorrencia:disable()
	oOcorrencia:hide()

	oRetAPI := TButton():new(1,202,'Retorno API',oPanel,bRetornoAPI,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oRetAPI:setCss(StrTran(cCssBtn,"##BANCO##","WEB"))
	oRetAPI:align := CONTROL_ALIGN_TOP

	oPosicao := TButton():new(1,202,'Posicao Cliente',oPanel,bPosicao,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oPosicao:setCss(StrTran(cCssBtn,"##BANCO##","VENDEDOR"))
	oPosicao:align := CONTROL_ALIGN_TOP

	oTitAberto := TButton():new(1,202,'Tit Aberto',oPanel,bTitAberto,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oTitAberto:setCss(StrTran(cCssBtn,"##BANCO##","VERNOTA"))
	oTitAberto:align := CONTROL_ALIGN_TOP

	oTitReceb := TButton():new(1,202,'Tit Recebidos',oPanel,bTitReceb,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oTitReceb:setCss(StrTran(cCssBtn,"##BANCO##","BSTART"))
	oTitReceb:align := CONTROL_ALIGN_TOP

	oPedidos := TButton():new(1,202,'Pedidos Em Aberto',oPanel,bPedidos,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oPedidos:setCss(StrTran(cCssBtn,"##BANCO##","SELECT"))
	oPedidos:align := CONTROL_ALIGN_TOP

	oFatur := TButton():new(1,202,'Faturamento',oPanel,bFatur,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oFatur:setCss(StrTran(cCssBtn,"##BANCO##","COPYUSER"))
	oFatur:align := CONTROL_ALIGN_TOP

	oReferenc := TButton():new(1,202,'Referencias',oPanel,bReferenc,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oReferenc:setCss(StrTran(cCssBtn,"##BANCO##","GERPROJ"))
	oReferenc:align := CONTROL_ALIGN_TOP
	oReferenc:disable()
	oReferenc:hide()

	oNatureza := TButton():new(1,202,'Natureza',oPanel,bNatureza,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oNatureza:setCss(StrTran(cCssBtn,"##BANCO##","SDUCOUNT"))
	oNatureza:align := CONTROL_ALIGN_TOP

	oCompensar := TButton():new(1,202,'Compensar NCC/RA',oPanel,bCompensar,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oCompensar:setCss(StrTran(cCssBtn,"##BANCO##","SDURECALL"))
	oCompensar:align := CONTROL_ALIGN_TOP

	oMoeda := TButton():new(1,202,'Moedas',oPanel,bMoeda,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oMoeda:setCss(StrTran(cCssBtn,"##BANCO##","TABPRICE"))
	oMoeda:align := CONTROL_ALIGN_TOP

	oSaldoBco := TButton():new(1,202,'Saldos Bancarios',oPanel,bSaldoBco,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSaldoBco:setCss(StrTran(cCssBtn,"##BANCO##","RECALC"))
	oSaldoBco:align := CONTROL_ALIGN_TOP

	oContabil := TButton():new(1,202,'Contabilizar',oPanel,bContabil,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oContabil:setCss(StrTran(cCssBtn,"##BANCO##","PROCESSA"))
	oContabil:align := CONTROL_ALIGN_TOP

	oDanfe := TButton():new(1,202,'DANFE',oPanel,bDanfe,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oDanfe:setCss(StrTran(cCssBtn,"##BANCO##","HISTORIC"))
	oDanfe:align := CONTROL_ALIGN_TOP

	oEstorno := TButton():new(1,202,'Estornar Bordero',oPanel,bEstorno,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oEstorno:setCss(StrTran(cCssBtn,"##BANCO##","DELWEB"))
	oEstorno:align := CONTROL_ALIGN_TOP

	oTxtEmail := TButton():new(1,202,'Texto Email',oPanel,bTextoEmail,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oTxtEmail:setCss(StrTran(cCssBtn,"##BANCO##","GEOEMAIL"))
	oTxtEmail:align := CONTROL_ALIGN_TOP

	oParametros := TButton():new(1,202,'Param. Email',oPanel,bParametros,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oParametros:setCss(StrTran(cCssBtn,"##BANCO##","INSTRUME"))
	oParametros:align := CONTROL_ALIGN_TOP

	oSair := TButton():new(1,202,'Sair',oPanel,bSair,35,15,,,.F.,.T.,.F.,,.F.,,,.F.)
	oSair:setCss(StrTran(cCssBtn,"##BANCO##","ATALHO"))
	oSair:align := CONTROL_ALIGN_TOP
return

static function Filter2Def(oPanel)
	local aItems := {"TODOS"}
	local cCSS	 := "TRadioButtonItem::indicator::checked { image: url(rpo:gestfin-checked.png); }"+;
					"TRadioButtonItem::indicator::unchecked { image: url(rpo:gestfin-unchecked.png); }"+;
					"TRadioButtonItem { spacing: 7px }"
	aEval(oGrid:aFilterDefault,{|x| aAdd(aItems,x[1]) })
	oRadio := TRadMenu():new(2,1,aItems,,oPanel,,,,,,,,80,12,,,,.T.,.T.)
	oRadio:setCss(cCSS)
	oRadio:bSetGet := {|u| Iif(PCount()==0,nRadio,nRadio:=u) }
	oRadio:bChange := {| | fnApplyFilter(nRadio) }
	oRadio:align   := CONTROL_ALIGN_ALLCLIENT
return

Static Function fTcheckbox(oPanel)

    oChkObj0  := TCheckBox():New(2, 1, "Todos", {|u| Iif(PCount() > 0 , lChkObj0 := u, lChkObj0)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
 	oChkObj0:bLClicked := {|| u_fnfinChck(oChkObj0,lChkObj0,0)}
    oChkObj1  := TCheckBox():New(2, 40, aFilt[1][1], {|u| Iif(PCount() > 0 , lChkObj1 := u, lChkObj1)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj1:bLClicked := {|| u_fnfinChck(oChkObj1,lChkObj1,1)}
    oChkObj2  := TCheckBox():New(2, 85, aFilt[2][1], {|u| Iif(PCount() > 0 , lChkObj2 := u, lChkObj2)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj2:bLClicked := {|| u_fnfinChck(oChkObj2,lChkObj2,2)}
    oChkObj3  := TCheckBox():New(2, 145, aFilt[3][1], {|u| Iif(PCount() > 0 , lChkObj3 := u, lChkObj3)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj3:bLClicked := {|| u_fnfinChck(oChkObj3,lChkObj3,3)}
    oChkObj4  := TCheckBox():New(2, 190, aFilt[4][1], {|u| Iif(PCount() > 0 , lChkObj4 := u, lChkObj4)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj4:bLClicked := {|| u_fnfinChck(oChkObj4,lChkObj4,4)}
    oChkObj5  := TCheckBox():New(2, 240, aFilt[5][1], {|u| Iif(PCount() > 0 , lChkObj5 := u, lChkObj5)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj5:bLClicked := {|| u_fnfinChck(oChkObj5,lChkObj5,5)}
    oChkObj6  := TCheckBox():New(2, 290, aFilt[6][1], {|u| Iif(PCount() > 0 , lChkObj6 := u, lChkObj6)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj6:bLClicked := {|| u_fnfinChck(oChkObj6,lChkObj6,6)}
    oChkObj7  := TCheckBox():New(2, 350, aFilt[7][1], {|u| Iif(PCount() > 0 , lChkObj7 := u, lChkObj7)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj7:bLClicked := {|| u_fnfinChck(oChkObj7,lChkObj7,7)}
    oChkObj8  := TCheckBox():New(2, 410, aFilt[8][1], {|u| Iif(PCount() > 0 , lChkObj8 := u, lChkObj8)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj8:bLClicked := {|| u_fnfinChck(oChkObj8,lChkObj8,8)}
    oChkObj9  := TCheckBox():New(2, 470, aFilt[9][1], {|u| Iif(PCount() > 0 , lChkObj9 := u, lChkObj9)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj9:bLClicked := {|| u_fnfinChck(oChkObj9,lChkObj9,9)}
    oChkObj10  := TCheckBox():New(2, 500, aFilt[10][1], {|u| Iif(PCount() > 0 , lChkObj10 := u, lChkObj10)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj10:bLClicked := {|| u_fnfinChck(oChkObj10,lChkObj10,10)}
    oChkObj11  := TCheckBox():New(2, 550, aFilt[11][1], {|u| Iif(PCount() > 0 , lChkObj11 := u, lChkObj11)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj11:bLClicked := {|| u_fnfinChck(oChkObj11,lChkObj11,11)}
    oChkObj12  := TCheckBox():New(2, 600, aFilt[12][1], {|u| Iif(PCount() > 0 , lChkObj12 := u, lChkObj12)}, oPanel, 110, 15, , /*bLClicked*/, oFontPadrao, /*bValid*/, /*nClrText*/, /*nClrPane*/, , .T. )
	oChkObj12:bLClicked := {|| u_fnfinChck(oChkObj12,lChkObj12,12)}

Return

User Function fnfinChck(oCheck, lCHECK, nSet)
  If valType(oCheck) <> "U"
    If oCheck:lModified //Verifica se foi alterado
		fnApplyFilter(nSet)
    EndIf
  Endif
Return

static function fnApplyFilter(nSet)
	// local nItem := nSet -1
	local nItem := nSet
	local nIdx as numeric

	RefreshDef(.T.)
	
	If nItem == 0
		for nIdx := 1 to Len(oGrid:oFwFilter:aFilter)
			oGrid:oFwFilter:aFilter[nIdx][6] := .F.
			oGrid:oFwFilter:aCheckFil[nIdx] := .F.
			// oGrid:aFilterDefault[nIdx][6] := .F.
			lChkObj1	:= .F.
			lChkObj2	:= .F.
			lChkObj3	:= .F.
			lChkObj4	:= .F.
			lChkObj5	:= .F.
			lChkObj6	:= .F.
			lChkObj7	:= .F.
			lChkObj8	:= .F.
			lChkObj9	:= .F.
			lChkObj10	:= .F.
			lChkObj11	:= .F.
			lChkObj12	:= .F.
		next nIdx
	EndIf 

	if nItem > 0
		lChkObj0	:= .F.
		If oGrid:oFwFilter:aFilter[nItem][6]
			oGrid:oFwFilter:aFilter[nItem][6] 	:= .F.
			oGrid:oFwFilter:aCheckFil[nItem] 	:= .F.
		Else
			oGrid:oFwFilter:aFilter[nItem][6] 	:= .T.
			oGrid:oFwFilter:aCheckFil[nItem]	:= .T.
		EndIf
		// oGrid:aFilterDefault[nItem][6] := .T.
	endif

	oGrid:oFwFilter:executeFilter()
	oGrid:refresh(.T.)
	
return

static function TotalDef(oPanel)
	local aField := {}
	local aCpoEnch := {"CTG","VLR","SLD","BXD","CON", "NCO","MKD"}
	local aPos := {000,000,010,010}

	fnUpdateTotal()

	Aadd(aField, {"Contagem",;				// [01] - Titulo
				"CTG",;						// [02] - campo
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
				"VLR",;						// [02] - campo
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
	Aadd(aField, {"Total em Aberto R$",;	// [01] - Titulo
				"SLD",;						// [02] - campo
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
	Aadd(aField, {"Total Baixado R$",;		// [01] - Titulo
				"BXD",;						// [02] - campo
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
	Aadd(aField, {"Total Conciliado R$",;	// [01] - Titulo
				"CON",;						// [02] - campo
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
	Aadd(aField, {"Total Nao Conciliado R$",;	// [01] - Titulo
				"NCO",;						// [02] - campo
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
				"MKD",;						// [02] - campo
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

	oEnch := MsmGet():new(,,2,/*aCRA*/,/*cLetras*/,/*cTexto*/,aCpoEnch,aPos,{},/*nModelo*/,;
	/*nColMens*/,/*cMensagem*/, /*cTudoOk*/,oPanel,/*lF3*/,.T.,/*lColumn*/,/*caTela*/,;
	/*lNoFolder*/,/*lProperty*/,aField)
	oEnch:oBox:align := CONTROL_ALIGN_ALLCLIENT
return

static function fnUpdateTotal()
	local cTql := "%"+cReal+"%"
	local cTbl := GetNextAlias()
	local cExp := "%1=1%" // filtro dumb
	local nIdx as numeric
	local nP   as numeric
	local nAux as numeric
	local aActiveFilt := oGrid:oFwFilter:getFilter()

	if Len(aActiveFilt) == 1 .and. aActiveFilt[1][9] == "XX"
		oGrid:deleteFilter("XX")
	endif

	if oGrid:oFwFilter != nil .and. ! Empty(aActiveFilt := oGrid:oFwFilter:getFilter())
		cExp := ""
		for nIdx := 1 to Len(aActiveFilt)
			nP := aScan(aFilt,{|x| x[1] == aActiveFilt[nIdx][1] .and. x[2] == aActiveFilt[nIdx][2] })
			if nP > 0
				if Empty(cExp)
					cExp += Alltrim(aFilt[nP][3])
				else
					cExp += " AND "+Alltrim(aFilt[nP][3])
				endif
				if nAux == nil
					nAux := nP + 1
				else
					nAux := 0
				endif
			else
				if Empty(cExp)
					cExp += Alltrim(aActiveFilt[nIdx][3])
				else
					cExp += " AND "+Alltrim(aActiveFilt[nIdx][3])
				endif
			endif
		next nIdx
		cExp := "%"+Alltrim(cExp)+"%"
	endif

	// if Empty(aActiveFilt)
	// 	nRadio := 1
	// 	oRadio:refresh()
	// elseif ! Empty(nAux)
	// 	nRadio := nAux
	// 	oRadio:refresh()
	// endif

	BeginSql alias cTbl
		SELECT
			COUNT(E1_SALDO) CTG,
			SUM(E1_SALDO) SLD,
			SUM(CASE WHEN XX_RECONC = 'x' THEN E1_VALOR ELSE 0 END) CON,
			SUM(CASE WHEN XX_RECONC = ' ' THEN E1_VALOR ELSE 0 END) NCO,
			SUM(E1_VALOR) VLR
		FROM %exp:cTql%
		WHERE %exp:cExp%
	EndSql

	M->CTG := (cTbl)->CTG
	M->VLR := (cTbl)->VLR
	M->SLD := (cTbl)->SLD
	M->CON := (cTbl)->CON
	M->NCO := (cTbl)->NCO
	M->BXD := (cTbl)->(VLR-SLD)

	(cTbl)->(dbClosearea())

	if oEnch != nil
		oEnch:refresh()
	endif
return .T.

static function fnAllMark()
	local cTql := "%"+cReal+"%"
	local cTbl := GetNextAlias()

	M->MKD	:= 0

	BeginSql alias cTbl
		SELECT
			XX_RECNO,
			XX_OK
		FROM %exp:cTql%
	EndSql

	(cTbl)->(DbGoTop())
	(cTmp)->( dbSetOrder(4) )

	While (cTbl)->(!EOF())
		If (cTbl)->XX_RECNO > 0 .AND. (cTbl)->XX_RECNO <> Nil
			If (cTmp)->( dbSeek((cTbl)->XX_RECNO) )
				If (cTmp)->XX_OK == "T"
					Reclock(cTmp,.F.)
					(cTmp)->XX_OK := "F"
					(cTmp)->(msUnlock())
				Else
					Reclock(cTmp,.F.)
					(cTmp)->XX_OK := "T"
					M->MKD += (cTmp)->E1_VALOR
					(cTmp)->(msUnlock())
				EndIf
			EndIf
		EndIf
		(cTbl)->(dbSkip())
	EndDo

	(cTbl)->(dbClosearea())

	if oEnch != nil
		oEnch:refresh()
	endif
	oGrid:Refresh(.T.)
	oGrid:setFocus() 

Return
