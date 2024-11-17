#include "totvs.ch"
/*/{Protheus.doc} OKCTBM03
	Puxa os lancamentos financeiros do RM e inclui os titulos no Protheus
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 20/01/2024
/*/
user function OKCTBM03()
	local dUlt	as date
	local cData as character
	local lFim	:= .F.
	local aPar	as array

	if Type("cEmpant") == "U"
		RpcSetEnv("01")
	endif

	if ! ValidDic()
		Alert("Atualize o dicionario")
		return
	endif

	dUlt  := FirstDay(dDatabase)-1
	cData := Month2Str(dUlt)+Year2Str(dUlt)

	// variavel private utilizada no parambox
	cCadastro := "TOTVS"

	aPar := {{1,"Informe a competencia",cData,"@R 99/9999","","","",50,.T.}}

	if ParamBox(aPar,"Lancamentos financeiros da folha",,,,,,,,,.F.)
		dUlt := LastDay(CtoD("01/"+Left(MV_PAR01,2)+"/"+Substr(MV_PAR01,3)))
		Processa({|| ProcMain(dUlt,@lFim) },"Integracao dos lancamentos financeiros da folha")
		if lFim
			FwAlertSuccess("Processamento finalizado com sucesso","Integracao Lancamentos Folha")
		endif
	endif

	FwFreeArray(aPar)
return
/*/{Protheus.doc} ProcMain
	Rotina principal
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 20/01/2024
/*/
static function ProcMain(dUltDia,lFim)
	local cEndpoint	:= GetMv("TI_ENDPTRM",,"35.199.84.68:8051")
	local cCredenc	:= GetMv("TI_CREDCRM",,"mestre1:472914")
	local cMsgErro	as character
	local oRest		as object
	local jReturn	as json
	local lContinua	:= .T.
	local aHeader	:= {'Accept: application/json; charset=utf-8',;
		'Authorization: Basic '+Encode64(cCredenc)}

	private oTable
	private lExec := .F.

	oRest := FwRest():new(cEndpoint)
	oRest:setPath("/api/framework/v1/consultaSQLServer/RealizaConsulta/titulos/0/p/?parameters=CODCOLIGADA=1;DATA="+GravaData(dUltDia,.F.,5))
	lContinua := oRest:get(aHeader)

	if lContinua
		jReturn := JsonObject():new()
		jReturn:fromJson(DecodeUTF8(oRest:getResult(),"cp1252"))

		if Len(jReturn) > 0
			ProcRegua(0)
			TelaVerificacao(jReturn)
		else
			FwAlertInfo("Nao ha dados","TOTVS")
		endif
	else
		cMsgErro := Iif(Empty(cMsgErro := oRest:getLastError()), "", cMsgErro)
		Alert("Erro ao realizar a consulta no RM: "+cMsgErro)
	endif

	oRest := nil ; FreeObj(oRest)
	jReturn := nil ; FreeObj(jReturn)
	if oTable != nil ; oTable:delete() ; FreeObj(oTable) ; endif
		FwFreeArray(aHeader)
		return
/*/{Protheus.doc} TelaVerificacao
	Tela de funcionalidades e conferencia
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 20/01/2024
/*/
static function TelaVerificacao(jDados)
	local cTmp		as character
	local cFld		as character
	local cTp		as character
	local bOk		:= {|| MsgRun("Gravando titulos ...","Aguarde",{|| fnGrava(aFields) }) , oGrid:refresh(.T.) }
	local bSair		:= {|| oDialog:deActivate() }
	local oDialog	as object
	local oColuna	as object
	local oGrid		as object
	local nInd		as numeric
	local aAux		as array
	local aSeek		:= {}
	local aStruct	:= {}
	local aFields	:= {"E2_FILIAL","E2_PREFIXO","E2_NUM","E2_PARCELA","E2_TIPO",;
		"E2_NATUREZ","E2_FORNECE","E2_LOJA","E2_EMISSAO","E2_VENCTO",;
		"E2_VALOR","E2_HIST","E2_XIDRM","E2_CCUSTO","E2_MULTNAT"}

	aEval(aFields,{|x| aAdd(aStruct,FwSx3Util():getFieldStruct(x)) })
	aAdd(aStruct,{"XX_OKM","L",01,0})
	aAdd(aStruct,{"XX_OKI","C",01,0})
	aAdd(aStruct,{"XX_LOG","M",10,0})
	aAdd(aStruct,{"XX_RATEIO","M",10,0})

	oTable := FwTemporaryTable():new(,aStruct)
	oTable:addIndex("01",{"E2_NUM"})
	oTable:addIndex("02",{"E2_XIDRM"})
	oTable:create()
	cTmp := oTable:getAlias()

	oDialog := FwDialogModal():new()
	oDialog:setTitle("RM x Protheus - Lançamentos Financeiros")
	oDialog:setSize(300,600)
	oDialog:setCloseButton(.F.)
	oDialog:setEscClose(.F.)
	oDialog:createDialog()

	oDialog:addButton('Gravar', bOk  , 'Gravar',,.T.,.F.,.T.)
	oDialog:addButton('Sair'  , bSair, 'Sair'  ,,.T.,.F.,.T.)

	aAux := {}
	aAdd(aAux,"")
	aAdd(aAux,GetSx3Cache("E2_NUM","X3_TIPO"))
	aAdd(aAux,GetSx3Cache("E2_NUM","X3_TAMANHO"))
	aAdd(aAux,GetSx3Cache("E2_NUM","X3_DECIMAL"))
	aAdd(aAux,AllTrim(GetSx3Cache("E2_NUM","X3_TITULO")))
	aAdd(aAux,AllTrim(GetSx3Cache("E2_NUM","X3_PICTURE")))

	aAdd(aSeek,{AllTrim(GetSx3Cache("E2_NUM","X3_TITULO")),{aAux}})

	aAux := {}
	aAdd(aAux,"")
	aAdd(aAux,GetSx3Cache("E2_XIDRM","X3_TIPO"))
	aAdd(aAux,GetSx3Cache("E2_XIDRM","X3_TAMANHO"))
	aAdd(aAux,GetSx3Cache("E2_XIDRM","X3_DECIMAL"))
	aAdd(aAux,AllTrim(GetSx3Cache("E2_XIDRM","X3_TITULO")))
	aAdd(aAux,AllTrim(GetSx3Cache("E2_XIDRM","X3_PICTURE")))

	aAdd(aSeek,{AllTrim(GetSx3Cache("E2_XIDRM","X3_TITULO")),{aAux}})

	oGrid := FwBrowse():new(oDialog:getPanelMain())
	oGrid:setDataTable(.T.)
	oGrid:setAlias(cTmp)
	oGrid:setDoubleClick({|oGrid| fnDblClk(oGrid) })
	oGrid:setSeek(,aSeek)
	oGrid:disableConfig()
	oGrid:disableReport()

	oGrid:addMarkColumns({||Iif(XX_OKM,"LBOK","LBNO")},{||fnMark(.F.,oGrid)},{||fnMark(.T.,oGrid)})
	oGrid:addStatusColumns({||Iif(XX_OKI=="1","OK",Iif(XX_OKI=="2","UPDERROR",""))})

	for nInd := 1 to Len(aFields)
		cFld := aFields[nInd]
		cTp := GetSx3Cache(cFld,"X3_TIPO")
		oColuna := FwBrwColumn():new()
		oColuna:setData(&("{||"+cFld+"}"))
		oColuna:setTitle(Alltrim(GetSx3Cache(cFld,"X3_TITULO")))
		oColuna:setSize(TamSx3(cFld)[1])
		oColuna:setAlign(Iif(cTp == "N",2,1))
		if cTp == "N"
			oColuna:setPicture(GetSx3Cache(cFld,"X3_PICTURE"))
		endif
		oGrid:setColumns({oColuna})
	next nInd

	InsereDados(jDados,cTmp)

	oGrid:activate(.T.) ; oDialog:activate()

	FreeObj(oColuna) ; FreeObj(oGrid) ; FreeObj(oDialog)
	FwFreeArray(aFields) ; FwFreeArray(aStruct) ; FwFreeArray(aSeek) ; FwFreeArray(aAux)
return

static function fnDblClk(oGrid)
	if lExec .and. (oGrid:alias())->XX_OKI == "2"
		AutoGrLog((oGrid:alias())->XX_LOG)
		MostraErro()
	endif
return

static function fnGrava(aFields)
	local nInd		as numeric
	local cAux		as character
	local cErr		as character
	local dDtBkp	:= DDATABASE
	local cFilBkp	:= CFILANT
	local cTbl		:= oTable:getAlias()
	local aVetSE2	as array
	local lExibeCtb	:= .F.

	if lExec
		return
	endif
	lExec := .T.

	(cTbl)->(dbGotop())

	while (cTbl)->( ! Eof() )
		if (cTbl)->XX_OKM
			aVetSE2 := {}
			for nInd := 1 to Len(aFields)
				cAux := aFields[nInd]
				aAdd(aVetSE2,{cAux,(cTbl)->&cAux,nil})
				if Alltrim(cAux) == "E2_FILIAL"
					CFILANT := (cTbl)->&cAux
				elseif Alltrim(cAux) == "E2_EMISSAO"
					DDATABASE := (cTbl)->&cAux
				elseif Alltrim(cAux) == "E2_CCUSTO"
					if Empty((cTbl)->&cAux) .and. ! Empty((cTbl)->XX_RATEIO)
						fnAddRateio(aVetSE2,cTbl)
					endif
				endif
			next nInd

			lMsErroAuto := .F. ; lMsHelpAuto := .T. ; lAutoErrNoFile := .T.
			msExecAuto({|x| FINA050(x,3,,,,lExibeCtb)}, aVetSE2)

			cErr := ""
			if lMsErroAuto
				aEval(GetAutoGrLog(),{|x| cErr += Iif(Empty(x),"",x+Chr(13)+Chr(10)) })
			else
				Reclock("SE2",.F.)
				SE2->E2_XIDRM := (cTbl)->E2_XIDRM
				SE2->(msUnlock())
			endif

			Reclock(cTbl,.F.)
			(cTbl)->XX_OKI := Iif(lMsErroAuto,"2","1")
			(cTbl)->XX_LOG := cErr
			(cTbl)->(msUnlock())
		endif

		(cTbl)->( dbSkip() )
	end

	DDATABASE := dDtBkp
	CFILANT := cFilBkp

	FwFreeArray(aVetSE2)
return

static function fnMark(lMarkAll,oGrid)
	local cTmp := oGrid:alias()
	local nAt := oGrid:at()

	if lExec
		return
	endif

	if lMarkAll
		(cTmp)->(dbGotop())
		(cTmp)->(dbEval({|| Reclock(cTmp,.F.) , (cTmp)->XX_OKM := ! (cTmp)->XX_OKM , (cTmp)->(msUnlock()) }))
		oGrid:goTo(nAt,.T.)
	else
		Reclock(cTmp,.F.)
		(cTmp)->XX_OKM := ! (cTmp)->XX_OKM
		(cTmp)->(msUnlock())
		oGrid:lineRefresh()
	endif
return
/*/{Protheus.doc} InsereDados
	Insere Dados na temporaria
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 20/01/2024
	@obs	 a consulta que vem do RM precisa estar ordenada por idlan
/*/
static function InsereDados(jDados,cTmp)
	local nIdx	 := 1
	local lAny	 := .F.
	local aSE2	 := SE2->(GetArea())
	local nTam	 := TamSx3("E2_HIST")[1]
	local nTotal := Len(jDados)
	local oInfo	 as json
	local aAux	 as array
	local nValor as numeric

/* local x, y
for x := 1 to nTotal
	for y := 1 to nTotal
		if x != y
			if jDados[x]["IDLAN"] == jDados[y]["IDLAN"]
				Alert("idlan repetido")
			endif
		endif
	next y
next x */

	SE2->(dbSetOrder(RetOrder("SE2","E2_XIDRM")))

	while nIdx <= nTotal
		if SE2->( msSeek(cValtochar(jDados[nIdx]["IDLAN"])) )
			nIdx++ ; loop
		endif

		if oInfo == nil
			oInfo := JsonObject():new()
			oInfo["filial"] := U_OKCTBM02(jDados[nIdx]["CODFILIAL"])
			oInfo["documento"] := cValtochar(jDados[nIdx]["NUMERODOCUMENTO"])
			oInfo["natureza"] := Alltrim(jDados[nIdx]["COD_NATUREZA_FINANCEIRA"])
			oInfo["codfor"] := jDados[nIdx]["CODCFO"]
			oInfo["lojafor"] := "0001" //SUBS(jDados[nIdx]["CODLOJA"],3,4)
			oInfo["emissao"] := FwDateTimeToLocal(jDados[nIdx]["DATAEMISSAO"])[1]
			oInfo["vencto"] := FwDateTimeToLocal(jDados[nIdx]["DATAVENCIMENTO"])[1]
			oInfo["valor"] := jDados[nIdx]["VALORORIGINAL"]
			oInfo["historico"] := Left(FwNoAccent(Upper(Alltrim(jDados[nIdx]["HISTORICO"]))),nTam)
			oInfo["idlan"] := cValtochar(jDados[nIdx]["IDLAN"])

			aAux := { JsonObject():new() }
			aAux[1]["codigo"] := Strtran(jDados[nIdx]["CENTRO_CUSTO_RATEIO"],".")
			aAux[1]["valor"]  := jDados[nIdx]["VALOR_RATEIO"]
			oInfo["ccusto"]	  := aClone(aAux)
		else
			aAdd(oInfo["ccusto"],JsonObject():new())
			aTail(oInfo["ccusto"])["codigo"] := Strtran(jDados[nIdx]["CENTRO_CUSTO_RATEIO"],".")
			aTail(oInfo["ccusto"])["valor"]  := jDados[nIdx]["VALOR_RATEIO"]
		endif

		nIdx ++

		if nIdx > nTotal .or. oInfo["idlan"] != cValtochar(jDados[nIdx]["IDLAN"])
			lAny := .T.

			Reclock(cTmp,.T.)
			(cTmp)->XX_OKM		:= .T.
			(cTmp)->XX_OKI		:= "0"
			(cTmp)->E2_FILIAL	:= oInfo["filial"]
			(cTmp)->E2_PREFIXO	:= "FPG"
			(cTmp)->E2_NUM		:= oInfo["documento"]
			(cTmp)->E2_PARCELA	:= "A"
			(cTmp)->E2_TIPO		:= "FOL"
			(cTmp)->E2_NATUREZ	:= oInfo["natureza"] 
			(cTmp)->E2_FORNECE	:= oInfo["codfor"]
			(cTmp)->E2_LOJA		:= oInfo["lojafor"]
			(cTmp)->E2_EMISSAO	:= oInfo["emissao"]
			(cTmp)->E2_VENCTO	:= oInfo["vencto"]
			(cTmp)->E2_HIST		:= oInfo["historico"]
			(cTmp)->E2_XIDRM	:= oInfo["idlan"]

			if Len(oInfo["ccusto"]) > 1
				nValor := 0
				aEval(oInfo["ccusto"],{|x| nValor += x["valor"] })
				(cTmp)->E2_MULTNAT	:= "1"
				(cTmp)->E2_VALOR	:= nValor
				(cTmp)->XX_RATEIO	:= oInfo:getJsonText("ccusto")
			else
				(cTmp)->E2_MULTNAT	:= "2"
				(cTmp)->E2_VALOR	:= oInfo["ccusto"][1]["valor"]
				(cTmp)->E2_CCUSTO	:= oInfo["ccusto"][1]["codigo"]
			endif
			(cTmp)->( MsUnlock() )

			FreeObj(oInfo)
		endif
	end

	(cTmp)->( dbGoTop() )

	SE2->(RestArea(aSE2))

	FwFreeArray(aAux)

	if ! lAny
		ApMsgInfo("A requisicao retornou itens porem todos ja estao integrados")
	endif
return
/*/{Protheus.doc} fnAddRateio
	adiciona os dados de rateio no execauto
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 26/6/2024
/*/
static function fnAddRateio(aVetSE2,cTbl)
	local aRatEvEz	:= {}
	local aAuxEv	:= {}
	local aAuxEz	as array
	local aRatEz	:= {}
	local cNat		:= aVetSE2[aScan(aVetSE2,{|x| Alltrim(x[1]) == "E2_NATUREZ" })][2]
	local nVal		:= aVetSE2[aScan(aVetSE2,{|x| Alltrim(x[1]) == "E2_VALOR" })][2]
	local nInd		as numeric
	local oRateio	:= JsonObject():new()

	oRateio:fromJson((cTbl)->XX_RATEIO)

	aadd(aAuxEv,{"EV_NATUREZ", PadR(cNat,TamSx3("EV_NATUREZ")[1]),nil})
	aadd(aAuxEv,{"EV_VALOR"	 , nVal	,nil})
	aadd(aAuxEv,{"EV_PERC"	 , "100",nil})
	aadd(aAuxEv,{"EV_RATEICC", "1"	,nil})

	for nInd := 1 to Len(oRateio)
		aAuxEz := {}
		aadd(aAuxEz,{"EZ_CCUSTO",oRateio[nInd]["codigo"],nil})
		aadd(aAuxEz,{"EZ_VALOR"	,oRateio[nInd]["valor"],nil})
		aadd(aRatEz,aClone(aAuxEz))
	next nInd

	aadd(aAuxEv,{"AUTRATEICC",aClone(aRatEz),nil})
	aAdd(aRatEvEz,aClone(aAuxEv))

	aAdd(aVetSE2,{"AUTRATEEV",aClone(aRatEvEz),nil})

	FwFreeArray(aRatEvEz) ; FwFreeArray(aAuxEv) ; FwFreeArray(aAuxEz) ; FwFreeArray(aRatEz)
return
/*/{Protheus.doc} ValidDic
	valida se os dicionarios estao criados
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 20/01/2024
/*/
static function ValidDic
	local lOk := .T.

	if CTD->( FieldPos("CTD_XCODRM") <= 0 )
		Alert("Campo CTD_XCODRM nao existe")
		lOk := .F.
	endif

	if RetOrder("CTD","CTD_FILIAL+CTD_XCODRM") <= 0
		Alert("Indice CTD_FILIAL+CTD_XCODRM nao criado na tabela CTD")
		lOk := .F.
	endif

	if SE2->( FieldPos("E2_XIDRM") <= 0 )
		Alert("Campo E2_XIDRM nao existe")
		lOk := .F.
	endif

	if ! FwSIXUtil():existIndex("SE2","E2_XIDRM")
		Alert("Indice E2_XIDRM nao criado na tabela SE2")
		lOk := .F.
	endif

	if ! GetMv("MV_MULNATP",,.F.)
		Alert("Parametro MV_MULNATP precisa existir e ter o conteudo .T.")
		lOk := .F.
	endif
return lOk
