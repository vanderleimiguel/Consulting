#Include 'Totvs.ch'
#Include 'RWMAKE.CH'
#Include 'TOPCONN.CH'
#Include 'Protheus.Ch'
#include 'TbiConn.ch'

/*/{Protheus.doc} Z_VDFIN2
Monitor de Integracao Expense Mobi - ZZA 
Este programa buscar as informações na API da Expense Mobi e grava na tela do Monitor de Integração (ZZA)
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_VDFIN2()
	//User Function Z_VDFIN2(cCliente, cLoja, cCodProd, dEmissao, cDoc, cCodGat, nValor, cTipo)

	Local aHeader  	:= {}
	Local aPergs   	:= {}
	Local nTenta    := 0
	Local cUrlRet   := SuperGetMV("ES_XURL",,"https://wsv.expensemobi.com.br/ExpenseMobilityFinal/v2/integracao/")
	Local cRet      := ""
	Local cToken    := "FB75CD57-C9E7-44CE-BB7B-A281E040B553"
	Local cKey 		:= SuperGetMV("MV_XAUT",,"p3qwASw6L7NZhhxhWNRD009Ljq6A0w4k")
	Local cErro     := ""
	Local cMsgErro  := ""
	Local cStatus   := ""
	//Local cIdDesp   := ""
	Local dDataDe  	:= MsDate()
	Local dDataAte	:= MsDate()
	//Local cFilDe	:= " "//Space(Len(xFilial("SZ2")))
	//Local cFilAte	:= " " //Replicate("Z",Len(xFilial("SZ2")))
	Local cDtMilDe
	Local cDtMilAt

	Private oJsonData  := JsonObject():New()
	Private lProcessou := .F.
	//	Private nX 		:= 0
	/*
	DbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(DbSeek(xFilial("SA1")+cCliente+cLoja))

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	SB1->(DbSeek(xFilial("SB1")+cCodProd))

	cAno := SubStr(DTOS(dEmissao), 1, 4)
	cMes := SubStr(DTOS(dEmissao), 5, 2)
	cDia := SubStr(DTOS(dEmissao), 7, 2)
	*/

	aAdd(aPergs, {1, "Data De :",  dDataDe,  "", ".T.", "", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Data Ate :", dDataAte,  "", ".T.", "", ".T.", 60,  .F.})
	//aAdd(aPergs, {1, "Filial De :",  cFilDe,  "", ".T.", "SM0", ".T.", 50,  .F.})
	//aAdd(aPergs, {1, "Filial Ate :", cFilAte,  "", ".T.", "SM0", ".T.", 50,  .F.})

	If ParamBox(aPergs, "Informe os parâmetros -")
		dDataDe    := Mv_Par01
		dDataAte   := Mv_Par02
		//cFilDe     := Mv_Par03
		//cFilAte    := Mv_Par04
	Else
		Return .T.
	EndIf

	dTimeDe := "00:00:01"
	cDtMilDe := FWTimeStamp(4, dDataDe, dTimeDe )+"000"

	dTimeAte := "23:59:59"
	cDtMilAt:= FWTimeStamp(4, dDataAte, dTimeAte )+"000"

	// OBS: A data para o filtro utilizado pela Expense Mobi é a data da DEspesa e não a data da aprovação da despesa.

	cRet += '{'
	cRet +=        '"method": "listarDespesas",
	cRet +=            '"key": "'+cKey+'",'
	cRet +=            '"param": {'
	cRet +=            '"chaveempresa": "'+cToken+'",'
	cRet +=            '"listarfiliais": true,
	cRet +=            '"statusdespesa": 3,
	cRet +=            '"tipodata": "DATADESPESA",
	cRet +=            '"datainicio": "'+cDtMilDe+'",'
	cRet +=            '"datafim": "'+cDtMilAt+'"'
	//cRet +=            '"iddespesa": 41720664
	//cRet +=            '"productServiceCode": "'+Alltrim(SB1->B1_CODISS)+'",'
	//cRet +=            '"transactionDate": "'+cAno+"-"+cMes+"-"+cDia+'",'
	//cRet +=            '"receiptValue": "'+AllTrim(Str(nValor))+'"'
	//cRet +=        '}'
	cRet +=                     '}'
	cRet += '}'

	For nTenta := 1 To 1
		aHeader := {}
		oRest := FWRest():New(cUrlRet)
		oRest:setPath("")
		//AAdd( aHeader, "Content-Type: application/json" )
		//AAdd( aHeader, "Authorization: Bearer " + cToken)
		AAdd( aHeader, "Key: " + cKey)

		oRest:SetPostParams(cRet)
		oRest:post(aHeader)

		cStatus := Alltrim(oRest:GetLastError())

		If "200" $ cStatus
			lProcessou := .T.

			FwJSONDeserialize(oREST:cResult, @oJsonData)

			Exit

		ElseIf "200" <> cStatus

			If Valtype(oRest) == 'J' .OR. Valtype(oRest) == 'O'
				FromJson(oRest:cResult)
				oJsonData:FromJson(oRest:cResult)
				cErro := oJsonData["errorcode"]
				cMsgErro := oJsonData["message"]
			EndIf

			//Consulta novo Token
			//cToken := GeraToken()
		EndIf
		Sleep(3000)
		//FreeObj(oRest)
		//FreeObj(oJsonData)
	Next

	//Processa({|| ProcInt()}, "Realizando integração da API Expense Mobi x Protheus...")
	RptStatus({|| ProcInt()}, "Aguarde...", "Realizando integração da API Expense Mobi ...")
Return

/*/{Protheus.doc} ProcInt
Grava dados na tabela ZZA
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function ProcInt()

	Local nX

	//cRetorno := oJsonData:ERRORCODE
	//cretorno := decodeUTF8(cretorno, "cp1252")

	//IF cRetorno <> "10013" //"Dados não encontrados"
	If LEN(oRest:CRESULT) > 56 // Até 56 é mensagem que não foi localizado nenhum registro.
		If !lProcessou

			If !IsBlind()
				//eszFWAlertError("Não foi possivel realizar o envio do recibo!", "Envio de Recibo")
			EndIf

		Else
			If !IsBlind()

				//==================================================================================
				//ATRIBUIÇÃO DAS VARIAVEIS DE ACORDO COM O CAONTEUDO DO JSON
				//===================================================================================

				//if Len(oJsonData) > 0

				ProcRegua(Len(oJsonData))
				//oRest:SetRegua1(Len(oJsonData))
				//IncProc("Integrando Titulo Expense Mobi ... ")

				For nX := 1 To Len(oJsonData)

					cIdDesp		:= Alltrim(str(oJsonData[nX]["iddespesa"]))
					cCodEmpE	:= Alltrim(oJsonData[nX]["codigoempresa"])
					cCodNatu	:= Alltrim(oJsonData[nX]["codigocontacontabil"])
					//	cDesCtaC	:= Alltrim(oJsonData[nX]["desccontacontabil"])
					//cIdCcust	:= Alltrim(oJsonData[nX]["idcentrodecustousuario"])
					//cNomCCus	:= Alltrim(oJsonData[nX]["nomecentrodecustousuario"])
					cIdCcust	:= Substr(Alltrim(oJsonData[nX]["desccentrodecustousuario"]),2,5)
					cNomUsua	:= Alltrim(oJsonData[nX]["nomeusuario"])
					//	cIdDepUs	:= Alltrim(oJsonData[nX]["iddepartamentousuario"])
					//	cDescDep	:= Alltrim(oJsonData[nX]["descdepartamentousuario"])
					cDescFoP	:= Alltrim(oJsonData[nX]["descformapagamento"])
					dDtDespe	:= Stod(StrTran(Substr(oJsonData[nX]["datadespesa"],1,10),"-","")) 		//oJsonData[nX]["datadespesa"]
					dDtLanDe	:= Stod(StrTran(Substr(oJsonData[nX]["datalancamentodespesa"],1,10),"-",""))
					dDtEnvAp	:= Stod(StrTran(Substr(oJsonData[nX]["dataenviodespesaaprovacao"],1,10),"-",""))
					dDtAproD	:= Stod(StrTran(Substr(oJsonData[nX]["datadespesaaprovacao"],1,10),"-",""))
					cStatDes	:= Alltrim(oJsonData[nX]["statusdespesa"])
					cTipoDes	:= Alltrim(oJsonData[nX]["tipodespesa"])
					cObsDes	:= Alltrim(oJsonData[nX]["observacao"])
					nVlrDespe	:= oJsonData[nX]["valordespesa"]
					cCpf		:= oJsonData[nX]["cpf"]

					//Se o ["idtiporeembolso"]=="3" significa que é "Não Reembolsavél", ou seja, foi utilizado Cartão corporativo, observamos isso na tag "descformapagamento": "Cartao Corporativo"
					// Ou seja, tudo que for <> ["idtiporeembolso"]=="3" será RDE (Despesa Reembolsável).
					CPrefExp	:= If(oJsonData[nX]["idtiporeembolso"]==3, "CCE", "RDE" )

					//==================================================================================
					//PREPARA PARA A GRAVAÇÃO DA DESPESA LOCALIZADA NA API NA TABELA ZZA NO PROTHEUS
					//===================================================================================
					DbSelectArea("ZZA")
					DbSetOrder(1)
					DbGotop()

					If !DbSeek(xFilial("ZZA")+cIdDesp)

						RecLock("ZZA",.T.)
						ZZA->ZZA_FILIAL  := FwxFilial("ZZA")
						ZZA->ZZA_VDTDES	:= dDtDespe				//Ctod(oJsonData[nX]["datalancamentodespesaformatada"])
						ZZA->ZZA_VDTLAN	:= dDtLanDe
						ZZA->ZZA_VDTENV	:= dDtEnvAp
						ZZA->ZZA_VDTAPR	:= dDtAproD
						ZZA->ZZA_VIDDES := cIdDesp 				//Alltrim(str(oJsonData[nX]["iddespesa"])) 	//oJsonData[nX]["iddespesa"]
						ZZA->ZZA_VVALOR 	:= nVlrDespe
						ZZA->ZZA_VCCUST	:= cIdCcust 			//If(Empty(cIdCcust), "72065",  cIdCcust)
						ZZA->ZZA_VPERCE	:= 100
						ZZA->ZZA_VOBSER	:= NoAcento(cObsDes)
						ZZA->ZZA_VFORPA	:= cDescFoP
						ZZA->ZZA_VTPPAG	:= cTipoDes
						ZZA->ZZA_VNOME	:= cNomUsua
						ZZA->ZZA_STADES	:= cStatDes
						ZZA->ZZA_VCPFCN	:= cCpf
						ZZA->ZZA_VNATUR	:= StrTran(cCodNatu,".","")
						ZZA->ZZA_PREFIX	:= CPrefExp
						ZZA->ZZA_STATUS 	:= "0"
						ZZA->ZZA_OBSERV	:= "Mov. Integ. com sucesso API Expense Mobi"
						//ZZA->ZZA_OBSMEM	:= "Mov. Integ. com sucesso API Expense Mobi"
						//cObservacao		:=  "Mov. Integ. com sucesso API Expense Mobi"
						//MSMM("ZZA_OBSMEM",,, cObservacao, 1, , , "ZZA", "ZZA_OBSMEM")
						MsUnlock()

						//eszFWAlertSuccess("Realizado a importação da Despesa "+Alltrim(str(oJsonData[nX]["iddespesa"]))+" com sucesso!", "Gravação da Despesa")

						IncProc("Importando Despesa: "+cIdDesp+" .....")
						//IncRegua("Importando Despesa: "+cIdDesp+" .....")
						//IncRegua()

						//u_GravaSE2()

						//Conout("Esta despesa já foi integrada - Filial:"+xFilial("ZZA")+" Despesa:"+cIdDesp+".")
						//Loop

					else
						If IsBlind()
							//Tratar aqui o schedule
						Else//Conout("Importando despesa - Filial:"+xFilial("ZZA")+" Despesa:"+cIdDesp+".")
							//eszFWAlertError("A Despesa "+Alltrim(str(oJsonData[nX]["iddespesa"]))+" não será gravada pois já foi integrada do Expense Mobi para o Protheus (ZZA)!", "Gravação da Despesa")
						Endif

					Endif
				Next
			EndIf
		EndIf
		FWAlertSuccess("Integrado movimentações na rotina 'Monitor de Integração Expense Mobi' com sucesso!", "Z_VDFIN2")
	Else
		Help( ,, 'Z_VDFIN2',, "Não existem movimentações para serem integradas do Expense Mobi para o Protheus com os parâmetros informados!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os parâmetros informados e tente novamente."})

	EndIf

	FreeObj(oRest)
	FreeObj(oJsonData)

Return



