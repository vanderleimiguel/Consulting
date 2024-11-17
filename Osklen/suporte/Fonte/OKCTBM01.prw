#include "totvs.ch"
#include "fwbrowse.ch"

#define AMARR(nP) aAmarr[aScan(aAmarr,{|x| x[1] == oFolder:getCaption() })][nP]

/*/{Protheus.doc} OKCTBM01
	Puxa os lancamentos contabeis da folha do RM e os inclui no Protheus
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
	@obs	 precisa existir o LP, o campo CTD_XCODRM e o novo indice
/*/
user function OKCTBM01()
	local dUlt	as date
	local cData as character
	local lFim	:= .F.
	local aPar	as array

	if Type("cEmpant") == "U"
		RpcSetEnv("01")
	endif
	
	dUlt  := FirstDay(dDatabase)-1
	cData := Month2Str(dUlt)+Year2Str(dUlt)

	// variavel private utilizada no parambox
	cCadastro := "TOTVS"

	aPar := {{1,"Informe a competencia",cData,"@R 99/9999","","","",50,.T.}}

	if ParamBox(aPar,"Integracao dos lancamentos da folha",,,,,,,,,.F.)
		dUlt := LastDay(CtoD("01/"+Left(MV_PAR01,2)+"/"+Substr(MV_PAR01,3)))
		Processa({|| ProcMain(dUlt,@lFim) },"Integracao dos lancamentos da folha")
		if lFim
			FwAlertSuccess("Processamento finalizado com sucesso","Integracao Lancamentos Folha")
		endif
	endif
return
/*/{Protheus.doc} ProcMain
	Rotina principal
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ProcMain(dUltDia,lFim)
	local cEndpoint	:= GetMv("TI_ENDPTRM",,"35.199.84.68:8051")
	local cCredenc	:= GetMv("TI_CREDCRM",,"mestre1:472914")
	local cLP		:= "RMX"
	local cLote		:= "000001"
	local cDocto	as character
	local cArquivo	as character
	local cMsgErro	as character
	local cBkp		as character
	local cAux		as character
	local nCnt		as numeric
	local nTotal	as numeric
	local nHdlPrv	as numeric
	local nValor	as numeric
	local oRest		as object
	local jReturn	as json
	local jLotes	:= JsonObject():new()
	local dDtBkp	as date
	local lNew		:= .T.
	local lContinua	:= .T.
	local aLotes	as array
	local aHeader	:= {'Accept: application/json; charset=utf-8',;
						'Authorization: Basic '+Encode64(cCredenc)}

	// variavel utilizada para controlar quais lotes nao devem ser integrados
	private cLoteNeg := ""

	// variavel utilizada no lancamento padrao
	private jInfo as json

	oRest := FwRest():new(cEndpoint)
	oRest:setPath("/api/framework/v1/consultaSQLServer/RealizaConsulta/LOTECONTABIL/0/P/?parameters=DATA="+GravaData(dUltDia,.F.,5)+";CODCOLIGADA=1")
	lContinua := oRest:get(aHeader)

	if lContinua
		jReturn := JsonObject():new()
		jReturn:fromJson(DecodeUTF8(oRest:getResult(),"cp1252"))
		// jReturn:fromJson(DecodeUTF8(MemoRead("c:\temp\teste.json"),"cp1252"))

		if ( nTotal := Len(jReturn) ) > 0
			if ! ValidDic(nTotal,cLP)
				return
			endif
			
			ProcRegua(0)
			for nCnt := 1 to nTotal
				jLotes[cValtochar(jReturn[nCnt]["CODLOTE"])] := .T.
			next nCnt
			aLotes := jLotes:getNames()

			// Tela de funcionalidades e conferencia
			if ! TelaVerificacao(aLotes,jReturn)
				Alert("Processamento cancelado")
				lContinua := .F.
			endif

			if lContinua
				// variavel private alterada para a data da contabilizacao
				dDtBkp := DDATABASE ; DDATABASE := FwDateTimeToLocal(jReturn[1]["DATA"])[1]
				cBkp := cFilant

				nCnt := 1
				while nCnt <= nTotal
					if cValtochar(jReturn[nCnt]["CODLOTE"]) $ cLoteNeg
						nCnt ++ ; loop
					endif

					cAux := U_OKCTBM02(jReturn[nCnt]["CODFILIAL"])
					if ! Empty(cAux)
						cFilant := cAux
					endif

					if lNew
						nHdlPrv := HeadProva(cLote,"OKCTBM01",__cUserid,@cArquivo)
						nValor := 0
						lNew := .F.
					endif
					
					cDocto := cValtochar(jReturn[nCnt]["CODLOTE"])
					jInfo  := jReturn[nCnt]
					nValor += DetProva(nHdlPrv,cLP,"OKCTBM01",cLote)
					
					nCnt ++

					if nCnt > nTotal .or. cDocto != cValtochar(jReturn[nCnt]["CODLOTE"])
						RodaProva(nHdlPrv,nValor)
						cA100Incl(cArquivo,nHdlPrv,3,cLote,.F.,.F.)
						lFim := .T. ; lNew := .T.
					endif
				end
			endif
		else
			FwAlertInfo("Nao ha dados","TOTVS")
		endif
	else
		cMsgErro := Iif(Empty(cMsgErro := oRest:getLastError()), "", cMsgErro)
		Alert("Erro ao realizar a consulta no RM: "+cMsgErro)
	endif

	if dDtBkp != nil
		DDATABASE := dDtBkp
	endif

	if cBkp != nil
		cFilant := cBkp
	endif

	oRest := nil ; FreeObj(oRest)
	jReturn := nil ; FreeObj(jReturn)
return
/*/{Protheus.doc} OKCTBM02
	Retorna o item contabil com base no codigo da filial RM informada
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
user function OKCTBM02(cCodFilRM)
	local aCTD := CTD->( GetArea() )
	local cItem := Space(TamSx3("CTD_ITEM")[1])
	CTD->( dbSetOrder(RetOrder("CTD","CTD_FILIAL+CTD_XCODRM")) )
	if CTD->( dbSeek(xFilial()+cValtochar(cCodFilRM)) )
		cItem := CTD->CTD_ITEM
	endif
	CTD->( RestArea(aCTD) )
return cItem
/*/{Protheus.doc} TelaVerificacao
	Tela de funcionalidades e conferencia
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function TelaVerificacao(aLotes,jDados)
	local oDialog	as object
	local oTela		as object
	local oPanel1	as object
	local oPanel2	as object
	local oColumn	as object
	local oBrowse0	as object
	local oTmp		as object
	local oFolder	as object
	local cIdCab	as character
	local cIdGrid	as character
	local cBlock	as character
	local cVarBrw	as character
	local cVarTmp	as character
	local cFld		as character
	local cSql		as character
	local cTbl		as character
	local cTblM		as character
	local cTitulo	:= "Conferência de lançamentos contábeis"
	local nIdx		as numeric
	local nInd		as numeric
	local nRet		as numeric
	local nPos		as numeric
	local lConfirma	:= .F.
	local jTitulos	as json
	local bOk		:= {|| lConfirma := .T. , oDialog:End() }
	local bCancelar	:= {|| oDialog:End() }
	local aCoors	:= FwGetDialogSize()
	local aBrw1		:= {}
	local aAmarr	:= {}
	local aButton	:= {{"BITMAP",{|| ManutCad(1,AMARR(2),AMARR(3)) },"Conta Contabil"},;
						{"BITMAP",{|| ManutCad(2,AMARR(2),AMARR(3)) },"Centro de Custo"},;
						{"BITMAP",{|| ManutCad(3,AMARR(2),AMARR(3)) },"Item Contabil"}}

	private cCadastro := "Conferência de lançamentos contábeis"

	DEFINE MSDIALOG oDialog FROM aCoors[1],aCoors[2] TO aCoors[3],aCoors[4] TITLE cTitulo PIXEL STYLE nOr(WS_VISIBLE,WS_POPUP)
		oDialog:lEscClose := .F.
		
		// dimensionamento da tela
		oTela := FwFormContainer():new(oDialog)
		cIdCab := oTela:createHorizontalBox(30)
		cIdGrid := oTela:createHorizontalBox(64) // foi retirado -6 para devido a enchoicebar
		oTela:activate(oDialog,.F.)
		oPanel1 := oTela:geTPanel(cIdCab)
		oPanel2 := oTela:geTPanel(cIdGrid)

		// monta browse de cima
		oBrowse0 := FwBrowse():new()
		oBrowse0:setDataArray()
		oBrowse0:setArray(aBrw1)
		oBrowse0:setOwner(oPanel1)
		oBrowse0:disableConfig()
		oBrowse0:disableReport()

		for nIdx := 1 to Len(aLotes)
			aAdd(aBrw1,{.T.,aLotes[nIdx],0,0,"",.T.}) // ultima posicao indica se o status pode ser alterado pelo usuario
		next nIdx

		cBlock := "{|| Iif(aBrw1[oBrowse0:nAt,1], 'BR_VERDE', 'BR_VERMELHO') }"
		// oBrowse0:addStatusColumns(&cBlock,{|oBrowse| xFunDblClk(oBrowse,aBrw1) })
		oBrowse0:addMarkColumns(&cBlock,{|oBrowse| xFunDblClk(oBrowse,aBrw1) },{|oBrowse| xFunDblClk(oBrowse,aBrw1,.T.) })
		oBrowse0:setDoubleClick({|oBrowse| fnDblClk(oBrowse,aBrw1,oFolder) })

		for nIdx := 2 to Len(aBrw1[1])-1 // ultima posicao indica se o status pode ser alterado pelo usuario
			cBlock := "{|| aBrw1[oBrowse0:nAt,"+cValtochar(nIdx)+"] }"
			oColumn := FwBrwColumn():new()
			oColumn:setData(&cBlock)
			do case
				case nIdx == 2
					oColumn:setTitle("Documento")
				case nIdx == 3
					oColumn:setTitle("Total Débitos")
					oColumn:setAlign(2)
					oColumn:setPicture("@E 99,999,999,999.99")
				case nIdx == 4
					oColumn:setTitle("Total Créditos")
					oColumn:setAlign(2)
					oColumn:setPicture("@E 99,999,999,999.99")
				case nIdx == 5
					oColumn:setTitle("Mensagem")
			endcase
			oBrowse0:setColumns({oColumn})
		next nIdx

		oBrowse0:activate()

		// monta as pastas para cada lote
		@ 10,15 FOLDER oFolder SIZE 260,200 OF oPanel2 PIXEL
		aEval(aLotes,{ |x| oFolder:addItem(x,.T.) })
		oFolder:setOption(1)
		oFolder:align := CONTROL_ALIGN_ALLCLIENT

		// cria a tabela e insere os dados nela
		oTmp := CriaTemporaria()
		InsereDados(jDados,oTmp:getAlias())

		// titulos
		jTitulos := JsonObject():new()
		jTitulos["XX_SEQ"]		:= "Seq"
		jTitulos["XX_CODLOTE"]	:= "Cod.Lote"
		jTitulos["XX_CREDITO"]	:= "C.Credito"
		jTitulos["XX_DEBITO"]	:= "C.Debito"
		jTitulos["XX_VALOR"]	:= "Valor"
		jTitulos["XX_COMPL"]	:= "Complemento"
		jTitulos["XX_DOCTO"]	:= "Documento"
		jTitulos["XX_CCUSTO"]	:= "C.Custo"
		jTitulos["XX_ITEM"]		:= "Item Ctb"
		jTitulos["XX_FILRM"]	:= "Filial RM"
		jTitulos["XX_MSG"]		:= "Mensagem"

		CT2->( dbSetOrder(RetOrder("CT2","CT2_XRMLOT")) )

		// monta os browses de baixo
		for nIdx := 1 to Len(aLotes)

			cVarTmp := "oTmp"+cValtochar(nIdx)
			&cVarTmp := CriaTemporaria()

			cFld := ""
			aEval(oTmp:oStruct:aFields,{|x| cFld += x[1] + "," })
			cFld := Left(cFld,Len(cFld)-1)

			cSql := "INSERT INTO "+&cVarTmp:getRealName()+" ("+cFld+") "
			cSql += "SELECT "+cFld+" FROM "+oTmp:getRealName()+" WHERE XX_CODLOTE = '"+aLotes[nIdx]+"'"

			nRet := TcSqlExec(cSql)

			cTbl := "__TMPTOT__" ; cTblM := "%"+&cVarTmp:getRealName()+"%"
			if Select(cTbl) > 0 ; (cTbl)->( dbCloseArea() ) ; endif

			BeginSql alias cTbl
				SELECT SUM(CASE WHEN XX_DEBITO != '' THEN XX_VALOR ELSE 0 END) XX_DEBITO,
						SUM(CASE WHEN XX_CREDITO != '' THEN XX_VALOR ELSE 0 END) XX_CREDITO
				FROM %Exp:cTblM%
				WHERE XX_CODLOTE = %Exp:aLotes[nIdx]%
			EndSql

			nPos := aScan(aBrw1,{|x| x[2] == aLotes[nIdx] })
			aBrw1[nPos][3] := (cTbl)->XX_DEBITO
			aBrw1[nPos][4] := (cTbl)->XX_CREDITO

			(cTbl)->( dbCloseArea() )

			if Round(aBrw1[nPos][3],2) != Round(aBrw1[nPos][4],2)
				aBrw1[nPos][1] := .F.
				aBrw1[nPos][5] := "Débito e crédito não batem"
				// bloqueia para que o usuario nao possa alterar
				aTail(aBrw1[nPos]) := .F.
				cLoteNeg += "/"+aBrw1[nPos][2]
			endif

			if CT2->( dbSeek(aBrw1[nPos][2]) )
				aBrw1[nPos][1] := .F.
				aBrw1[nPos][5] := "Lote "+aBrw1[nPos][2]+" já incluído anteriormente "
				// bloqueia para que o usuario nao possa alterar
				aTail(aBrw1[nPos]) := .F.
				cLoteNeg += "/"+aBrw1[nPos][2]
			endif

			oBrowse0:refresh(.T.)

			cVarBrw := "oBrowse"+cValtochar(nIdx)

			// faz a amarracao entre o lote, a temporaria criada e o browse
			// usado na manutencao do cadastro para posicionamento
			aAdd(aAmarr,{aLotes[nIdx],&cVarTmp:getAlias(),cVarBrw})

			&cVarBrw := FwBrowse():new()
			&cVarBrw:setDataTable(.T.)
			&cVarBrw:setAlias(&cVarTmp:getAlias())
			&cVarBrw:setOwner(oFolder:aDialogs[nIdx])
			&cVarBrw:disableConfig()
			&cVarBrw:disableReport()

			for nInd := 1 to Len(oTmp:oStruct:aFields)
				cBlock := "{|| "+oTmp:oStruct:aFields[nInd][1]+" }"

				oColumn := FwBrwColumn():new()
				oColumn:setData(&cBlock)
				oColumn:setTitle(jTitulos[oTmp:oStruct:aFields[nInd][1]])
				oColumn:setSize(oTmp:oStruct:aFields[nInd][3])
				oColumn:setType(oTmp:oStruct:aFields[nInd][2])
				if oTmp:oStruct:aFields[nInd][2] == "N"
					oColumn:setAlign(2)
					if oTmp:oStruct:aFields[nInd][1] == "XX_VALOR"
						oColumn:setPicture("@E 99,999,999,999.99")
					endif
				endif
				&cVarBrw:setColumns({oColumn})
			next nInd

			&cVarBrw:activate()
		next nIdx

	ACTIVATE MSDIALOG oDialog ON INIT EnchoiceBar(oDialog,bOk,bCancelar,,aButton)

	// destroy all objects
	FwFreeArray(aLotes) ; FwFreeArray(aCoors) ; FwFreeArray(aBrw1) ; FwFreeArray(aAmarr) ; FwFreeArray(aButton)
	oTmp:delete() ; FreeObj(oTmp)
	FreeObj(oTela) ; FreeObj(oColumn) ; FreeObj(oBrowse0)
	FreeObj(jTitulos)

	for nInd := 1 to 100
		if Type("oBrowse"+cValtochar(nInd)) != "U"
			FreeObj(&("oBrowse"+cValtochar(nInd)))
		else
			exit
		endif
		if Type("oTmp"+cValtochar(nInd)) != "U"
			&("oTmp"+cValtochar(nInd)):delete()
			FreeObj(&("oTmp"+cValtochar(nInd)))
		endif
	next nInd
return lConfirma
/*/{Protheus.doc} CriaTemporaria
	Cria tabela temporaria
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function CriaTemporaria()
	local oTmp as object
	local aFld := {}

	aAdd(aFld,{"XX_SEQ"		,"N",6						,0})
	aAdd(aFld,{"XX_CODLOTE"	,"C",TamSx3("CT2_XRMLOT")[1],0})
	aAdd(aFld,{"XX_DEBITO"	,"C",TamSx3("CT1_CONTA")[1]	,0})
	aAdd(aFld,{"XX_CREDITO"	,"C",TamSx3("CT1_CONTA")[1]	,0})
	aAdd(aFld,{"XX_VALOR"	,"N",TamSx3("CT2_VALOR")[1]	,TamSx3("CT2_VALOR")[2]})
	aAdd(aFld,{"XX_COMPL"	,"C",40						,0})
	aAdd(aFld,{"XX_DOCTO"	,"C",15						,0})
	aAdd(aFld,{"XX_CCUSTO"	,"C",TamSx3("CTT_CUSTO")[1]	,0})
	aAdd(aFld,{"XX_ITEM"	,"C",TamSx3("CTD_ITEM")[1]	,0})
	aAdd(aFld,{"XX_FILRM"	,"C",TamSx3("CTD_XCODRM")[1],0})
	aAdd(aFld,{"XX_MSG"		,"C",250					,0})

	oTmp := FwTemporaryTable():new(,aFld)
	oTmp:addindex("01",{"XX_SEQ"})
	oTmp:addindex("02",{"XX_CODLOTE","XX_SEQ"})
	oTmp:create()
return oTmp
/*/{Protheus.doc} InsereDados
	Insere Dados na temporaria
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function InsereDados(jDados,cAlias)
	local nIdx as numeric
	local cMsg as character
	for nIdx := 1 to Len(jDados)
		Reclock(cAlias,.T.)
		(cAlias)->XX_SEQ		:= nIdx
		(cAlias)->XX_CODLOTE	:= cValtochar(jDados[nIdx]["CODLOTE"])
		(cAlias)->XX_CREDITO	:= StrTran(cValtochar(jDados[nIdx]["CREDITO"]),".")
		(cAlias)->XX_DEBITO		:= StrTran(cValtochar(jDados[nIdx]["DEBITO"]),".")
		(cAlias)->XX_VALOR		:= jDados[nIdx]["VALOR"]
		(cAlias)->XX_COMPL		:= jDados[nIdx]["COMPLEMENTO"]
		(cAlias)->XX_DOCTO		:= jDados[nIdx]["DOCUMENTO"]
		(cAlias)->XX_CCUSTO		:= StrTran(cValtochar(jDados[nIdx]["CODCCUSTO"]),".")
		(cAlias)->XX_ITEM		:= U_OKCTBM02(jDados[nIdx]["CODFILIAL"])
		(cAlias)->XX_FILRM		:= cValtochar(jDados[nIdx]["CODFILIAL"])
		(cAlias)->XX_MSG		:= ""

		if ! ValidCt1((cAlias)->XX_DEBITO,@cMsg)
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := Strtran(cMsg,"%tipo%","débito")
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + Strtran(cMsg,"%tipo%","débito")
			endif
		endif

		if ! ValidCt1((cAlias)->XX_CREDITO,@cMsg)
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := Strtran(cMsg,"%tipo%","crédito")
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + Strtran(cMsg,"%tipo%","crédito")
			endif
		endif
		
		if ! ValidCtt((cAlias)->XX_CCUSTO,@cMsg)
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := cMsg
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + cMsg
			endif
		endif
		
		if ! ValidCtd((cAlias)->XX_ITEM,@cMsg)
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := cMsg
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + cMsg
			endif
		endif
		(cAlias)->( MsUnlock() )
	next nIdx
return
/*/{Protheus.doc} ValidCt1
	valida conta contabil
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ValidCt1(cConta,cMsg)
	if ! Empty(cConta)
		if CT1->(IndexOrd() != 1) ; CT1->( dbSetOrder(1) ) ; endif
		
		if ! CT1->( MsSeek(xFilial()+cConta) )
			cMsg := "Conta %tipo% não encontrada"
			return .F.
		endif
		if CT1->CT1_CLASSE != "2"
			cMsg := "Conta %tipo% nao e analitica"
			return .F.
		endif
		if CT1->( FieldPos("CT1_MSBLQL") > 0 .and. CT1_MSBLQL == "1" )
			cMsg := "Conta %tipo% bloqueada"
			return .F.
		endif
		// validacao do padrao ctbxvld.prw
		if ! ValidaBloq(cConta,dDatabase,"CT1",.F.)
			cMsg := "Conta %tipo% bloqueada por data"
			return .F.
		endif
	endif
return .T.
/*/{Protheus.doc} ValidCtt
	valida centro de custo
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ValidCtt(cCusto,cMsg)
	if Empty(cCusto)
		cMsg := "Centro de custo em branco"
		return .F.
	endif

	if CTT->(IndexOrd() != 1) ; CTT->( dbSetOrder(1) ) ; endif
	
	if ! CTT->( MsSeek(xFilial()+cCusto) )
		cMsg := "Centro de custo não encontrado"
		return .F.
	endif
	if CTT->CTT_CLASSE != "2"
		cMsg := "Centro de custo nao e analitico"
		return .F.
	endif
	if CTT->( FieldPos("CTT_MSBLQL") > 0 .and. CTT_MSBLQL == "1" )
		cMsg := "Centro de custo bloqueado"
		return .F.
	endif
	// validacao do padrao ctbxvld.prw
	if ! ValidaBloq(cCusto,dDatabase,"CTT",.F.)
		cMsg := "Centro de custo bloqueado por data"
		return .F.
	endif
return .T.
/*/{Protheus.doc} ValidCtd
	valida item contabil
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ValidCtd(cItem,cMsg)
	if Empty(cItem)
		cMsg := "Item contábil em branco"
		return .F.
	endif

	if CTD->(IndexOrd() != 1) ; CTD->( dbSetOrder(1) ) ; endif
	
	if ! CTD->( MsSeek(xFilial()+cItem) )
		cMsg := "Item contábil não encontrado"
		return .F.
	endif
	if CTD->CTD_CLASSE != "2"
		cMsg := "Item contábil nao e analitico"
		return .F.
	endif
	if CTD->( FieldPos("CTD_MSBLQL") > 0 .and. CTD_MSBLQL == "1" )
	endif
	// validacao do padrao ctbxvld.prw
	if ! ValidaBloq(cItem,dDatabase,"CTD",.F.)
		cMsg := "Item contábil bloqueado por data"
		return .F.
	endif
return .T.
/*/{Protheus.doc} ManutCad
	facilitador para realizar manutencao nas entidades contabeis
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ManutCad(nTp,cAlias,cVarBrw)
	local cConta as character
	local cCusto := (cAlias)->XX_CCUSTO
	local cItem  := (cAlias)->XX_ITEM
	local cMsg	 as character
	local lRet	 as logical
	local lVld	 := .F.

	if nTp == 1

		if ! Empty((cAlias)->XX_CREDITO) .and. ! Empty((cAlias)->XX_DEBITO)
			if Aviso("Conta","Indique a conta",{"Débito","Crédito"},1) == 1
				cConta := (cAlias)->XX_DEBITO
			else
				cConta := (cAlias)->XX_CREDITO
			endif
		elseif ! Empty((cAlias)->XX_CREDITO)
			cConta := (cAlias)->XX_CREDITO
		elseif ! Empty((cAlias)->XX_DEBITO)
			cConta := (cAlias)->XX_DEBITO
		endif

		if Empty(cConta)
			Alert("Nao ha conta")
			return
		endif

		if CT1->(IndexOrd() != 1) ; CT1->( dbSetOrder(1) ) ; endif

		if CT1->( MsSeek(xFilial()+cConta) )
			lVld := FwExecView("Conta contabil","CTBA020",4,,,,20) == 0
		else
			Alert("Conta nao encontrada")
		endif

	elseif nTp == 2

		if Empty(cCusto)
			Alert("Nao ha centro de custo")
			return
		endif

		if CTT->(IndexOrd() != 1) ; CTT->( dbSetOrder(1) ) ; endif

		if CTT->( MsSeek(xFilial()+cCusto) )
			lVld := FwExecView("Centro de custo","CTBA030",4,,,,20) == 0
		else
			Alert("Centro de custo nao encontrado")
		endif

	elseif nTp == 3

		if Empty(cItem)
			Alert("Nao ha item contabil")
			return
		endif

		if CTD->(IndexOrd() != 1) ; CTD->( dbSetOrder(1) ) ; endif

		if CTD->( MsSeek(xFilial()+cItem) )
			CTBA040Alt("CTD",CTD->(Recno()),4) // funcao padrao de alteracao - CTBA040
			lVld := .T.
		else
			Alert("Item nao encontrado")
		endif

	endif

	if lVld
		// verifica conta contabil
		lRet := ValidCt1(cConta,@cMsg)
		Reclock(cAlias,.F.)
		(cAlias)->XX_MSG := "" // zera antes de comecar a colocar as mensagens
		if ! lRet
			(cAlias)->XX_MSG := Strtran(cMsg,"%tipo%","")
		endif
		(cAlias)->( MsUnlock() )
		
		// verifica centro de custo
		lRet := ValidCtt(cCusto,@cMsg)
		Reclock(cAlias,.F.)
		if ! lRet
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := cMsg
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + cMsg
			endif
		endif
		(cAlias)->( MsUnlock() )

		// verifica item contabil
		lRet := ValidCtd(cItem,@cMsg)
		Reclock(cAlias,.F.)
		if ! lRet
			if Empty((cAlias)->XX_MSG)
				(cAlias)->XX_MSG := cMsg
			else
				(cAlias)->XX_MSG := Alltrim((cAlias)->XX_MSG) + " / " + cMsg
			endif
		endif
		(cAlias)->( MsUnlock() )

		// atualiza a linha
		&cVarBrw:lineRefresh()
	endif
return
/*/{Protheus.doc} xFunDblClk
	Duplo clique na grid de cima
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function xFunDblClk(oBrowse,aBrw1,lAll)
	local nIni as numeric
	local nFim as numeric
	local nIdx as numeric

	default lAll := .F.

	nIni := Iif(!lAll,oBrowse:nAt,1)
	nFim := Iif(!lAll,oBrowse:nAt,Len(aBrw1))

	for nIdx := nIni to nFim
		if aTail(aBrw1[nIdx]) // se permitir a troca
			aBrw1[nIdx,1] := ! aBrw1[nIdx,1]
			if aBrw1[nIdx,1] // se foi marcado para integrar, retira o lote na negacao
				cLoteNeg := Strtran(cLoteNeg,"/"+aBrw1[nIdx][2],"")
			else // se foi marcado para NAO integrar, adiciona o lote na negacao
				cLoteNeg += "/"+aBrw1[nIdx][2]
			endif
		endif
	next nIdx

	oBrowse:goTo(oBrowse:nAt,.T.)
return

static function fnDblClk(oBrowse,aBrw1,oFolder)
	local cLt := aBrw1[oBrowse:nAt,2]
	local nP := aScan(oFolder:APROMPTS,cLt)
	oFolder:setOption(nP)
	oFolder:refresh()
return

/*/{Protheus.doc} ValidDic
	valida se os dicionarios estao criados
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
static function ValidDic(nTotal,cLP)
	local lOk := .T.
	if nTotal > GetMV("MV_NUMLIN") .or. nTotal > GetMV("MV_NUMMAN")
		Alert("Total de linhas maior que os parametros MV_NUMLIN e MV_NUMMAN")
		lOk := .F.
	endif

	if ! VerPadrao(cLP)
		Alert("Lancamento padrao "+cLP+" nao cadastrado")
		lOk := .F.
	endif

	if CTD->( FieldPos("CTD_XCODRM") <= 0 )
		Alert("Campo CTD_XCODRM nao existe")
		lOk := .F.
	endif

	if RetOrder("CTD","CTD_FILIAL+CTD_XCODRM") <= 0
		Alert("Indice CTD_FILIAL+CTD_XCODRM nao criado na tabela CTD")
		lOk := .F.
	endif

	if CT2->( FieldPos("CT2_XRMLOT") <= 0 )
		Alert("Campo CT2_XRMLOT nao existe")
		lOk := .F.
	endif

	if ! FwSIXUtil():existIndex("CT2","CT2_XRMLOT")
		Alert("Indice CT2_XRMLOT nao criado na tabela CT2")
		lOk := .F.
	endif
return lOk
