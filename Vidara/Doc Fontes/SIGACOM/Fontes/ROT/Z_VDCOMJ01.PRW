#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VDProcCust
Job para Envio de E-mail do Custo Médio dos Produtos
@author TOTVS Protheus
@since 18/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function VDCOMJ01(aParams)
	Local nFil
	Local nEmp
	Local cFilBck       := cFilAnt
	Local cEmpBck       := cEmpAnt
	Local aSays			:= {}
	Local aButtons		:= {}
	Local nRet			:= 0
	Local lJob 			:= IsBlind() .Or. Empty(AllTrim(FunName()))
	Local cUseCode		:= ""
	Private aEmpAux   	:= FWAllGrpCompany()
	Private aFilAux   	:= {}

	Default aParams     := {"01","0101"}

	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			aParams	:= {aEmpAux[nEmp], aFilAux[nFil] }

			If lJob

				cCodEmp	:= aParams[01]
				cCodFil	:= aParams[02]

				//Chamado Via Debuge
				If Empty(AllTrim(FunName()))
					RpcSetEnv(cCodEmp,cCodFil,"","","COM","U_VDCOMJ01",{"SF1","SD1","SB1"},)
				EndIf

				cUseCode := "VDCOMJ01"+cEmpAnt

				ConOut( "VDCOMJ01 - Inicio - Ambiente Empresa: "+cEmpAnt+" Filial: "+cFilAnt+" "+DtoC(Date())+" "+Time() )

				//Verifica se a Rotina está em Uso
				If LockByName(cUseCode,.F.,.F.,.T.)
					VDProcCust(lJob)
					UnLockByName(cUseCode,.F.,.F.,.T.) //Destrava o Uso da Rotina
				Else
					ConOut("VDCOMJ01 - A Rotina sendo utilizada por Outro Usuário.")
				EndIf

				ConOut( "VDCOMJ01 - Fim    - Ambiente Empresa: "+cEmpAnt+" Filial: "+cFilAnt+" "+DtoC(Date())+" "+Time() )

			Else

				cUseCode := "VDCOMJ01"+cEmpAnt

				//Verifica se a Rotina está em Uso
				If LockByName(cUseCode,.F.,.F.,.T.)

					aAdd(aSays,OemToAnsi("Este programa tem como objetivo enviar um e-mail aos responsaveis sobre os "))
					aAdd(aSays,OemToAnsi("valores do custo médios dos produtos conforme classificação do documento de"))
					aAdd(aSays,OemToAnsi("entrada."))
					aAdd(aSays,OemToAnsi(""))
					aAdd(aSays,OemToAnsi("Clique no botão de OK para iniciar o processo."	))
					aAdd(aButtons, { 1,.T.,{|o| FechaBatch(),nRet:=1						}})
					aAdd(aButtons, { 2,.T.,{|o| FechaBatch()								}})
					FormBatch( OemToAnsi("E-mail - Custo Médio"), aSays, aButtons )
					If nRet == 1
						Processa({|| VDProcCust(lJob) },"Aguarde...Processando Marcações")
					EndIf

					UnLockByName(cUseCode,.F.,.F.,.T.) //Destrava o Uso da Rotina

				Else
					MsgStop("A Rotina sendo utilizada por Outro Usuário. Favor aguardar." )
				EndIf

			EndIf
		Next
		nFil	:= 1
	Next

	cEmpAnt := cEmpBck
	cFilAnt := cFilBck
Return

/*/{Protheus.doc} VDProcCust
Processo de Geração de Marcações
@author TOTVS Protheus
@since 02/03/2023
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDProcCust(lJob)

	Local cQuery		:= ""
	Local cAliasQry		:= ""
	Local nTotRegs		:= 0
	Local nQtdRegs		:= 0
	Local nRecSF1 		:= 0
	Local nRecSA2 		:= 0
	Local cFilDoc 		:= ""
	Local cNumDoc 		:= ""
	Local cSerDoc 		:= ""
	Local cCodFor 		:= ""
	Local cLojFor 		:= ""
	Local aDadosSD1		:= {}
	Local cPara			:= AllTrim(GetMv("ZZ_CMEMAIL",.T.,"vendas@vidara.com.br"))
	Local cCopia		:= NIL
	Local cAssunto		:= "Novo Custo"
	Local cMsgMail		:= ""
	Local lEnvMail		:= .F.
	Local aAnexos 		:= {}

	//Documentos de Entrada Nacional com Frete
	cQuery += "SELECT SF1.F1_FILIAL "
	cQuery += "		 ,SF1.F1_EMISSAO "
	cQuery += "		 ,SF1.R_E_C_N_O_ AS RECSF1 "
	cQuery += "		 ,SA2.R_E_C_N_O_ AS RECSA2 "
	cQuery += "  FROM "+RetSqlName("SF1")+" SF1 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 "
	cQuery += "    ON SA2.A2_FILIAL  = '"+xFilial("SA2")+ "' "
	cQuery += "   AND SA2.A2_COD     = SF1.F1_FORNECE "
	cQuery += "   AND SA2.A2_LOJA    = SF1.F1_LOJA "
	cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SF1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SF1.F1_TIPO    = 'N' "
	cQuery += "   AND SF1.F1_EST     <> 'EX' "
	cQuery += "   AND SF1.F1_STATUS  <> '"+Space(TamSx3("F1_STATUS")[1])+"' "
	cQuery += "   AND SF1.F1_IDNF    <> '"+Space(TamSx3("F1_IDNF")[1])+"' "
	cQuery += "   AND SF1.F1_FRETE   > 0 "
	cQuery += "   AND SF1.F1_ZZMAIL  = ' ' "

	cQuery += " UNION ALL "

	//Documentos de Entrada Internacional com NF Complementar (CD5)
	cQuery += "SELECT SF1.F1_FILIAL "
	cQuery += "		 ,SF1.F1_EMISSAO "
	cQuery += "		 ,SF1.R_E_C_N_O_ AS RECSF1 "
	cQuery += "		 ,SA2.R_E_C_N_O_ AS RECSA2 "
	cQuery += "  FROM "+RetSqlName("SF1")+" SF1 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("SA2")+" SA2 "
	cQuery += "    ON SA2.A2_FILIAL  = '"+xFilial("SA2")+ "' "
	cQuery += "   AND SA2.A2_COD     = SF1.F1_FORNECE "
	cQuery += "   AND SA2.A2_LOJA    = SF1.F1_LOJA "
	cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SF1.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SF1.F1_TIPO    = 'N' "
	cQuery += "   AND SF1.F1_EST     = 'EX' "
	cQuery += "   AND SF1.F1_STATUS  <> '"+Space(TamSx3("F1_STATUS")[1])+"' "
	cQuery += "   AND SF1.F1_IDNF    <> '"+Space(TamSx3("F1_IDNF")[1])+"' "
	cQuery += "   AND SF1.F1_ZZMAIL  = ' ' "
	cQuery += "   AND EXISTS ( SELECT 'CD5' "
	cQuery += "  			     FROM "+RetSqlName("CD5")+" CD5 "
	cQuery += "   				WHERE CD5.CD5_FILIAL = SF1.F1_FILIAL "
	cQuery += "   				  AND CD5.CD5_DOC    = SF1.F1_DOC "
	cQuery += "   				  AND CD5.CD5_SERIE  = SF1.F1_SERIE "
	cQuery += "   				  AND CD5.CD5_FORNEC = SF1.F1_FORNECE"
	cQuery += "   				  AND CD5.CD5_LOJA   = SF1.F1_LOJA"
	cQuery += "                   AND CD5.D_E_L_E_T_ = ' ' ) "

	cQuery += " ORDER BY SF1.F1_FILIAL, SF1.F1_EMISSAO "

	cAliasQry := MPSysOpenQuery(cQuery)

	(cAliasQry)->(dbEval( {|| nTotRegs++},,{ || (cAliasQry)->(!Eof()) } ))

	If nTotRegs > 0

		ConOut("VDCOMJ01 - Quantidades de Notas: "+AllTrim(Str(nTotRegs)) )

		If lJob
			lContinua := .T.
		Else
			lContinua := MsgYesNo("Confirma o Envio de E-mail de Novo Custo de  Produtos de "+AllTrim(Str(nTotRegs))+" Nota(s) ?")
		EndIf

		If lContinua

			If !lJob
				ProcRegua(nTotRegs)
			EndIf

			DbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			While (cAliasQry)->(!Eof())

				If !lJob
					nQtdRegs++
					IncProc("Processando Notas : "+Alltrim(Str(nQtdRegs)) + " de "+Alltrim(Str(nTotRegs))  )
				EndIf

				nRecSF1 := (cAliasQry)->RECSF1
				nRecSA2 := (cAliasQry)->RECSA2

				DbSelectArea("SF1")
				SF1->(DbGoTo(nRecSF1))

				cFilDoc  := SF1->F1_FILIAL
				cNumDoc  := SF1->F1_DOC
				cSerDoc  := SF1->F1_SERIE
				cCodFor  := SF1->F1_FORNECE
				cLojFor  := SF1->F1_LOJA
				lEnvMail := .F.
				cMsgMail := ""

				aDadosSD1 := VDRecnoSD1(cFilDoc,cNumDoc,cSerDoc,cCodFor,cLojFor)
				If Len(aDadosSD1) > 0
					cMsgMail := VDMsgEMail(nRecSF1,nRecSA2,aDadosSD1)
					lEnvMail := U_VDEVMAIL(cPara,cCopia,cAssunto,cMsgMail,aAnexos)
					If lEnvMail
						DbSelectArea("SF1")
						SF1->(DbGoTo(nRecSF1))
						SF1->(RecLock("SF1",.F.))
						SF1->F1_ZZMAIL	:= "S"
						SF1->(MsUnLock())
					EndIf
				EndIf

				(cAliasQry)->(DbSkip())
			EndDo

		EndIf

	Else
		If !lJob
			MsgInfo("Não há dados para geração das Marcações do sistema Henry!")
		Else
			ConOut("VDCOMJ01 - Não há dados para geração das Marcações do sistema Henry!")
		EndIf
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return

/*/{Protheus.doc} VDRecnoSD1
Retorna Itens do Documento de Entrada
@author TOTVS Protheus
@since 17/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSD1(cXFilDoc,cXNumDoc,cXSerDoc,cXCodFor,cXLojFor)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local aRet		:= {}

	cQuery := "SELECT SD1.D1_ITEM "
	cQuery += "      ,SD1.R_E_C_N_O_ AS RECSD1 "
	cQuery += "      ,SB1.R_E_C_N_O_ AS RECSB1 "
	cQuery += "      ,ISNULL(DKD.R_E_C_N_O_,0) AS RECDKD "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 "
	cQuery += "    ON SB1.B1_FILIAL  = '"+xFilial("SB1")+ "' "
	cQuery += "   AND SB1.B1_COD     = SD1.D1_COD "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery += " LEFT JOIN "+RetSqlName("DKD")+" DKD "
	cQuery += "    ON DKD.DKD_FILIAL = SD1.D1_FILIAL "
	cQuery += "   AND DKD.DKD_DOC    = SD1.D1_DOC "
	cQuery += "   AND DKD.DKD_SERIE  = SD1.D1_SERIE "
	cQuery += "   AND DKD.DKD_FORNEC = SD1.D1_FORNECE "
	cQuery += "   AND DKD.DKD_LOJA   = SD1.D1_LOJA "
	cQuery += "   AND DKD.DKD_ITEM   = SD1.D1_ITEM "
	cQuery += "   AND DKD.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SD1.D1_FILIAL  = '"+cXFilDoc+ "' "
	cQuery += "   AND SD1.D1_DOC     = '"+cXNumDoc+ "' "
	cQuery += "   AND SD1.D1_SERIE   = '"+cXSerDoc+ "' "
	cQuery += "   AND SD1.D1_FORNECE = '"+cXCodFor+ "' "
	cQuery += "   AND SD1.D1_LOJA    = '"+cXLojFor+ "' "
	cQuery += "   AND SD1.D1_TES    <> '"+Space(TamSx3("D1_TES")[1])+"' "
	cQuery += "   AND SD1.D1_CF     <> '"+Space(TamSx3("D1_CF")[1])+"' "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SD1.D1_ITEM "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		aAdd(aRet,{ (cAliasQry)->RECSD1,;
			(cAliasQry)->RECSB1,;
			(cAliasQry)->RECDKD})
		(cAliasQry)->(DbSkip())
	EndDo

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(aRet)

/*/{Protheus.doc} VDMsgEMail
Gera Mensagem do Email
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDMsgEMail(nXRecSF1,nXRecSA2,aXDadosSD1)

	Local aArea			:= GetArea()
	Local cRet 			:= ""
	Local cEndLin 		:= Chr(10)+Chr(13)
	Local nRiscGlobal	:= SuperGetMv("ZZ_RISCGLO",.F.,7)
	Local nX			:= 0
	Local cNumDoc 		:= ""
	Local cSerDoc 		:= ""
	Local cFornec 		:= ""
	Local cDtEmis 		:= ""
	Local nRecSD1 		:= 0
	Local nRecSB1 		:= 0
	Local cCodProd 		:= ""
	Local cDscProd 		:= ""
	Local cMoedProd 	:= ""
	Local cFilProd   	:= ""
	Local cLocalProd 	:= ""
	Local nRiscProd  	:= 0
	Local nPercCusto 	:= 0
	Local nAdicCusto	:= 0
	Local nNovoCusto 	:= 0
	Local cNovoCusto 	:= ""
	Local cFabricant 	:= ""
	Local nCustoAnt  	:= 0
	Local cCustoAnt  	:= ""
	Local nCustRepos 	:= 0
	Local cCustRepos 	:= ""
	Local nPercVaria 	:= 0
	Local cPercVaria 	:= ""
	Local cCodFabr 		:= ""
	Local cLojFabr	 	:= ""
	Local cNomFabr 		:= ""

	DbSelectArea("SF1")
	SF1->(DbGoTo(nXRecSF1))

	DbSelectArea("SA2")
	SA2->(DbGoTo(nXRecSA2))

	cNumDoc := SF1->F1_DOC
	cSerDoc := SF1->F1_SERIE
	cFornec := SA2->A2_COD+"-"+Rtrim(SA2->A2_NOME)
	cDtEmis := DtoC(SF1->F1_EMISSAO)

	cRet += '<html>'+cEndLin
	cRet += '<html>'+cEndLin
	cRet += '<head>'+cEndLin
	cRet += '<meta http-equiv="Content-Language" content="pt-br">'+cEndLin
	cRet += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'+cEndLin
	cRet += '<title>custo de produtos</title>'+cEndLin
	cRet += '</head>'+cEndLin
	cRet += '<body>'+cEndLin
	cRet += '<font face="Arial" style="font-size: 22pt">Novo Custo de Produtos.</font>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<font face="Arial"><b>Documento: </b>'+cNumDoc+'</font>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<font face="Arial"><b>Serie: </b>'+cSerDoc+'</font>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<font face="Arial"><b>Fornecedor: </b>'+cFornec+'</font>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<font face="Arial"><b>Emissão: </b>'+cDtEmis+'</font>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<hr align="left" width="82%" color="#000080">'+cEndLin
	cRet += '<i><font color="#000080" face="Arial" style="font-size: 16pt; font-weight: 700">Produtos</font></i>'+cEndLin
	cRet += '<table border="1" width="82%" cellspacing="1">'+cEndLin
	cRet += '<tr>'+cEndLin
	cRet += '		<td width="72"  align="center"><b><font face="Arial" style="font-size: 11pt">Código</font></b></td>'+cEndLin
	cRet += '		<td width="270" align="center"><b><font face="Arial" style="font-size: 11pt">Descrição</font></b></td>'+cEndLin
	cRet += '		<td width="65"  align="center"><b><font face="Arial" style="font-size: 11pt">Moeda</font></b></td>'+cEndLin
	cRet += '		<td width="33"  align="center"><b><font face="Arial" style="font-size: 11pt">Filial</font></b></td>'+cEndLin
	cRet += '		<td width="45"  align="center"><b><font face="Arial" style="font-size: 11pt">Local</font></b></td>'+cEndLin
	cRet += '		<td width="124" align="center"><b><font face="Arial" style="font-size: 11pt">Novo Custo</font></b></td>'+cEndLin
	cRet += '		<td width="168" align="center"><b><font face="Arial" style="font-size: 11pt">Fabricante</font></b></td>'+cEndLin
	cRet += '		<td width="121" align="center"><b><font face="Arial" style="font-size: 11pt">Custo Anterior</font></b></td>'+cEndLin
	cRet += '		<td width="106" align="center"><b><font face="Arial" style="font-size: 11pt">Custo Repos</font></b></td>'+cEndLin
	cRet += '		<td width="103" align="center"><b><font face="Arial" style="font-size: 11pt">Perc Variação</font></b></td>'+cEndLin
	cRet += '	</tr>'+cEndLin

	For nX:=1 To Len(aXDadosSD1)

		nRecSD1 := aXDadosSD1[nX][1]
		nRecSB1 := aXDadosSD1[nX][2]
		nRecDKD := aXDadosSD1[nX][3]

		DbSelectArea("SD1")
		SD1->(DbGoTo(nRecSD1))

		DbSelectArea("SB1")
		SB1->(DbGoTo(nRecSB1))

		cCodProd   := Rtrim(SD1->D1_COD)
		cDscProd   := Rtrim(SB1->B1_DESC)
		cMoedProd  := Rtrim(SB1->B1_ZZMOECO)
		cFilProd   := SD1->D1_FILIAL
		cLocalProd := SD1->D1_LOCAL
		nRiscProd  := SB1->B1_ZZPEVCA
		If nRiscProd == 0
			nNovoCusto := SD1->D1_CUSTO
		Else
			nPercCusto := nRiscGlobal * (nRiscProd/100)
			nAdicCusto := SD1->D1_CUSTO * (nPercCusto/100)
			nNovoCusto := SD1->D1_CUSTO
		EndIf

		cNovoCusto := AllTrim(Transform(nNovoCusto, PesqPict("SD1","D1_CUSTO")) )

		cFabricant := ""
		nCustoAnt  := 0
		cCustoAnt  := ""

		cCodFabr := ""
		cLojFabr := ""
		cNomFabr := ""

		If nRecDKD > 0
			DbSelectArea("DKD")
			DKD->(DbGoTo(nRecDKD))

			cCodFabr := DKD->DKD_ZZFABR
			cLojFabr := DKD->DKD_ZZLJFA
			If !Empty(AllTrim(cCodFabr)) .And. !Empty(AllTrim(cLojFabr))
				cNomFabr := VDNomeFabr(cCodFabr,cLojFabr)
				If !Empty(AllTrim(cNomFabr))
					cFabricant := SubStr(cNomFabr,1,25)
				EndIf
			EndIf

			nCustoAnt  := DKD->DKD_ZZCMAN
			cCustoAnt  := AllTrim(Transform(nCustoAnt, PesqPict("SD1","D1_CUSTO")) )

		EndIf

		nCustRepos := 0
		cCustRepos := AllTrim(Transform(nCustRepos, PesqPict("SD1","D1_CUSTO")) )

		If nNovoCusto == nCustoAnt
			nPercVaria := 0
		Else
			nPercVaria := 100 - ((nCustoAnt*100)/nNovoCusto)
		EndIf
		cPercVaria := AllTrim(Transform(nPercVaria,"@E 999.99") )

		cRet += '	<tr>'+cEndLin
		cRet += '		<td width="72"  align="center"><font face="Arial" style="font-size: 11pt">'+cCodProd+'</font></td>'+cEndLin
		cRet += '		<td width="270" align="center"><font face="Arial" style="font-size: 11pt">'+cDscProd+'</font></td>'+cEndLin
		cRet += '		<td width="65"  align="center"><font face="Arial" style="font-size: 11pt">'+cMoedProd+'</font></td>'+cEndLin
		cRet += '		<td width="33"  align="center"><font face="Arial" style="font-size: 11pt">'+cFilProd+'</font></td>'+cEndLin
		cRet += '		<td width="45"  align="center"><font face="Arial" style="font-size: 11pt">'+cLocalProd+'</font></td>'+cEndLin
		cRet += '		<td width="124" align="right"> <font face="Arial" style="font-size: 11pt">'+cNovoCusto+'</font></td>'+cEndLin
		cRet += '		<td width="168" align="center"><font face="Arial" style="font-size: 11pt">'+cFabricant+'</font></td>'+cEndLin
		cRet += '		<td width="121" align="right"> <font face="Arial" style="font-size: 11pt">'+cCustoAnt+'</font></td>'+cEndLin
		cRet += '		<td width="106" align="right"> <font face="Arial" style="font-size: 11pt">'+cCustRepos+'</font></td>'+cEndLin
		cRet += '		<td width="103" align="right"> <font face="Arial" style="font-size: 11pt">'+cPercVaria+'</font></td>'+cEndLin
		cRet += '	</tr>'+cEndLin

	Next

	cRet += '</table>'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<hr align="left" width="82%" color="#000080">'+cEndLin
	cRet += '</br>'+cEndLin
	cRet += '<b><font face="Arial" size="2">Mensagem automática, favor não responder esse e-mail.</font></b>'+cEndLin
	cRet += '</body>'+cEndLin
	cRet += '</html>'+cEndLin

	RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} VDNomeFabr
Retorna Nome do Fabricante
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDNomeFabr(cXCodFabr,cXLojFabr)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local cRet		:= ""

	cQuery := "SELECT SA2.A2_NOME "
	cQuery += "  FROM "+RetSqlName("SA2")+" SA2 (NOLOCK) "
	cQuery += " WHERE SA2.A2_FILIAL  = '"+xFilial("SA2")+ "' "
	cQuery += "   AND SA2.A2_COD     = '"+cXCodFabr+ "' "
	cQuery += "   AND SA2.A2_LOJA    = '"+cXLojFabr+ "' "
	cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If !Empty(AllTrim((cAliasQry)->A2_NOME))
		cRet := AllTrim((cAliasQry)->A2_NOME)
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(cRet)
