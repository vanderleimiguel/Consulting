#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} VDESTR01
Relatório da Lista de Preço Baseada em Custo Médio
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function VDESTR01()

	Local aSays		:= {}
	Local aButtons	:= {}
	Local nRet		:= 0
	Local cPerg 	:= PadR("VDESTR01",10)
	Local cDirRel	:= ""

	VDGravaSX1(cPerg)

	aAdd(aSays,OemToAnsi("Este programa tem como objetivo gerar o Relatório da Lista de Preço"))
	aAdd(aSays,OemToAnsi("baseada no Custo Médio dos Produtos"))
	aAdd(aSays,OemToAnsi(""))
	aAdd(aSays,OemToAnsi(""))
	aAdd(aSays,OemToAnsi("Clique no botão de OK para iniciar a geração do relatório."))
	aAdd(aButtons, { 1,.T.,{|o| FechaBatch(),nRet:=1						}})
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch()								}})
	FormBatch( OemToAnsi("Relatório da Lista de Preço"), aSays, aButtons )
	If nRet == 1 .And. Pergunte(cPerg,.T.)
		cDirRel := cGetFile("", OemToAnsi("Selecione o Diretório"),0,"SERVIDOR\",.F.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY,.F.,.F. )
		If !Empty(cDirRel)
			Processa({|| CProcesGCT(cDirRel) },"Aguarde...Processando Relatório")
		Else
			MsgInfo("Favor informar o diretório para geração do relatório.")
		EndIf
	EndIf

Return

/*/{Protheus.doc} CProcesGCT
Processo de Carga de Dados - Gestão de Contratos
@author Totvs
@since 13/03/2023
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function CProcesGCT(cDirRel)

	Local cQuery	 	:= ""
	Local cAliasQry	 	:= ""
	Local nTotRegs	 	:= 0
	Local nQtdRegs	 	:= 0
	Local cArqRel 		:= "lista_de_preco_"+DtoS(Date())+SubStr(Time(),1,2)+SubStr(Time(),4,2)+SubStr(Time(),7,2)
	Local cDirArq 	 	:= ""
	Local cTempCSV	 	:= GetNextAlias()+".xlsx"
	Local oFwMsEx	 	:= Nil
	Local cWorkSheet 	:= ""
	Local cTable     	:= ""
	Local cEndLin	 	:= Chr(13)+Chr(10)
	Local nRiscGlobal	:= SuperGetMv("ZZ_RISCGLO",.F.,7)
	Local nPerComissa	:= SuperGetMv("ZZ_PRCOMIS",.F.,2)
	Local cCodProd  	:= ""
	Local cDscProd  	:= ""
	Local cFabrica  	:= ""
	Local cMoedProd 	:= ""
	Local nPerMargem	:= 0
	Local nSB2CMed  	:= 0
	Local nRiscCamb  	:= 0
	Local nPercCusto 	:= 0
	Local nCustoMed  	:= 0
	Local nPerPrcNet  	:= 0
	Local nPrecoNet 	:= 0
	Local nSaldoAtu 	:= 0
	Local nSld15Dias	:= 0
	Local nSld30Dias	:= 0
	Local nSld99Dias	:= 0
	Local nSaldoDisp 	:= 0
	Local nSCPenden		:= 0
	Local nPCPenden		:= 0
	Local cFilProd		:= ""
	Local cLocProd		:= ""
	Local cLotePrd		:= ""
	Local cPisCofins 	:= ""
	Local cIPI 			:= ""
	Local nPosTXT		:= 0
	Local aDadosTXT		:= {}
	Local aGrupa		:= {}
	Local nX			:= 0
	Local nY			:= 0

	cQuery := "SELECT SB8.B8_PRODUTO "
	cQuery += "  	 ,SB8.B8_LOCAL "
	cQuery += "  	 ,SB8.B8_FILIAL "
	cQuery += "		 ,SB8.R_E_C_N_O_ AS RECSB8 "
	cQuery += "      ,SB1.R_E_C_N_O_ AS RECSB1 "
	cQuery += "      ,SB2.R_E_C_N_O_ AS RECSB2 "
	cQuery += "      ,ISNULL(SA2.A2_NOME,'SEM FABRICANTE') AS FABRICANTE "
	cQuery += "  FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "

	cQuery += " INNER JOIN "+RetSqlName("SB2")+" SB2 "
	cQuery += "    ON SB2.B2_FILIAL  = SB8.B8_FILIAL "
	cQuery += "   AND SB2.B2_COD     = SB8.B8_PRODUTO "
	cQuery += "   AND SB2.B2_LOCAL   = SB8.B8_LOCAL "
	cQuery += "   AND SB2.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN "+RetSqlName("SB1")+" SB1 "
	cQuery += "    ON SB1.B1_FILIAL  = '"+xFilial("SB1")+ "' "
	cQuery += "   AND SB1.B1_COD     = SB8.B8_PRODUTO "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN "+RetSqlName("NNR")+" NNR "
	cQuery += "    ON NNR.NNR_FILIAL = '"+xFilial("NNR")+ "' "
	cQuery += "   AND NNR.NNR_CODIGO = SB8.B8_LOCAL "
	cQuery += "   AND NNR.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN "+RetSqlName("Z42")+" Z42 "
	cQuery += "    ON Z42.Z42_FILIAL = '"+xFilial("Z42")+ "' "
	cQuery += "   AND Z42.Z42_PRODUT = SB8.B8_PRODUTO "
	cQuery += "   AND Z42.Z42_LOTE   = SB8.B8_LOTECTL "
	cQuery += "   AND Z42.D_E_L_E_T_ = ' ' "

	cQuery += "  LEFT JOIN "+RetSqlName("SA2")+" SA2 "
	cQuery += "    ON SA2.A2_FILIAL  = '"+xFilial("SA2")+ "' "
	cQuery += "   AND SA2.A2_COD     = Z42.Z42_FABRIC "
	cQuery += "   AND SA2.A2_LOJA    = Z42.Z42_LJFABR "
	cQuery += "   AND SA2.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE SB8.B8_FILIAL  <> '"+Space(TamSx3("B8_FILIAL")[1])+"' "
	cQuery += "   AND SB8.B8_PRODUTO BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "
	cQuery += "   AND SB1.B1_GRUPO   BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cQuery += "   AND NNR.NNR_ZZLIST = 'S' "
	cQuery += "   AND SB8.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SB8.B8_PRODUTO, SB8.B8_LOCAL, SB8.B8_FILIAL "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	(cAliasQry)->(dbEval( {|| nTotRegs++},,{ || (cAliasQry)->(!Eof()) } ))

	If nTotRegs > 0

		ProcRegua(nTotRegs*2)

		oFwMsEx:= FwMsExcelXlsx():New()

		cWorkSheet := "Lista Preco"
		cTable     := "Relatorio Lista de Preco"

		oFwMsEx:AddWorkSheet( cWorkSheet )
		oFwMsEx:AddTable( cWorkSheet, cTable )

		//1-General,2-Number,3-Monetário,4-DateTime )
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Produto"				,1,1) 	//01
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Descricao"				,1,1) 	//02
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Lote"					,1,1) 	//03
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Fabricante"				,1,1) 	//04
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Moeda"					,1,1) 	//05
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Preco Net"				,1,2) 	//06
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Saldo Disponivel"		,1,2) 	//07
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Saldo Atual"			,1,2) 	//08
		oFwMsEx:AddColumn( cWorkSheet, cTable, "15 dias"				,1,2) 	//09
		oFwMsEx:AddColumn( cWorkSheet, cTable, "15 a 30 dias"			,1,2) 	//10
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Maior 30 dias"			,1,2) 	//11
		oFwMsEx:AddColumn( cWorkSheet, cTable, "SC Pendentes"			,1,2) 	//12
		oFwMsEx:AddColumn( cWorkSheet, cTable, "PC Pendentes"			,1,2) 	//13
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Filial"					,1,1) 	//14
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Armazem"				,1,1) 	//15
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Custo Medio"			,1,2) 	//16
		oFwMsEx:AddColumn( cWorkSheet, cTable, "Margem"					,1,2) 	//17
		oFwMsEx:AddColumn( cWorkSheet, cTable, "PIS e COFINS Entrada"	,1,1) 	//18
		oFwMsEx:AddColumn( cWorkSheet, cTable, "IPI"					,1,1) 	//19

		DbSelectArea(cAliasQry)
		(cAliasQry)->(DbGoTop())
		While (cAliasQry)->(!Eof())

			nQtdRegs++
			IncProc("Processando Registros : "+Alltrim(Str(nQtdRegs)) + " de "+Alltrim(Str(nTotRegs))  )

			DbSelectArea("SB8")
			SB8->(DbGoTo((cAliasQry)->RECSB8))

			DbSelectArea("SB1")
			SB1->(DbGoTo((cAliasQry)->RECSB1))

			DbSelectArea("SB2")
			SB2->(DbGoTo((cAliasQry)->RECSB2))

			cCodProd  	:= SB8->B8_PRODUTO
			cDscProd  	:= Rtrim(SB1->B1_DESC)
			cFilProd	:= SB8->B8_FILIAL
			cLocProd	:= SB8->B8_LOCAL
			cLotePrd	:= SB8->B8_LOTECTL
			cFabrica  	:= Rtrim((cAliasQry)->FABRICANTE)
			cMoedProd 	:= Rtrim(SB1->B1_ZZMOECO)
			nSB2CMed  	:= SB2->B2_CM1

			//Calculo Centro de Custo
			nRiscCamb  := SB1->B1_ZZPEVCA
			If nRiscCamb == 0
				nCustoMed := nSB2CMed
			ElseIf nRiscCamb >= 1 .And. nRiscCamb <= 100
				nPercCusto := (1-((nRiscGlobal/100) * (nRiscCamb/100)))
				nCustoMed  := Round(nSB2CMed/nPercCusto,TamSx3("B2_CM1")[2])
			EndIf

			//Calculo Preço Net
			nPerMargem	:= SB1->B1_ZZMBRUT
			If nPerMargem > 0
				nPerPrcNet  := (1-((nPerComissa/100)+(nPerMargem/100)))
			Else
				nPerPrcNet  := (1-((nPerComissa/100)))
			Endif
			nPrecoNet 	:= Round(nCustoMed/nPerPrcNet,TamSx3("B2_CM1")[2])

			nSaldoAtu 	:= SB8->B8_SALDO
			nSld15Dias	:= VDSaldDias(cFilProd,cCodProd,cLotePrd,cLocProd,"1")
			nSld30Dias	:= VDSaldDias(cFilProd,cCodProd,cLotePrd,cLocProd,"2")
			nSld99Dias	:= VDSaldDias(cFilProd,cCodProd,cLotePrd,cLocProd,"3")
			nSaldoDisp 	:= nSaldoAtu - (nSld15Dias+nSld30Dias+nSld99Dias)
			nSCPenden	:= VDSCPenden(cFilProd,cCodProd,cLocProd)
			nPCPenden	:= VDPCPenden(cFilProd,cCodProd,cLocProd)

			cPisCofins 	:= VDPesqImpo(cFilProd,cCodProd,"1")
			cIPI 		:= VDPesqImpo(cFilProd,cCodProd,"2")

			//Agrupa por Produto + Filial + Armazem
			nPosTXT := aScan(aDadosTXT,{|x| AllTrim(x[1]) == AllTrim(cCodProd) .And. ;
				AllTrim(x[2]) == AllTrim(cFilProd) .And. ;
				AllTrim(x[3]) == AllTrim(cLocProd) })
			If nPosTXT == 0

				aAdd(aDadosTXT,{cCodProd,;		//01-Produto
				cFilProd,;		//02-Filial
				cLocProd,;		//03-Armazem
				nSaldoDisp,;	//04-Saldo Disponivel
				nSaldoAtu,;		//05-Saldo Atual
				nSld15Dias,;	//06-Saldo 15 dias
				nSld30Dias,;	//07-Saldo 15 a 30 dias
				nSld99Dias,;	//08-Saldo Maior 30 dias
				{} })			//09-Dados dos Itens

				nPosTXT   := Len(aDadosTXT)
				aGrupa := {}

			Else

				aDadosTXT[nPosTXT][4] += nSaldoDisp
				aDadosTXT[nPosTXT][5] += nSaldoAtu
				aDadosTXT[nPosTXT][6] += nSld15Dias
				aDadosTXT[nPosTXT][7] += nSld30Dias
				aDadosTXT[nPosTXT][8] += nSld99Dias

				aGrupa := aClone(aDadosTXT[nPosTXT][9])

			EndIf

			Aadd(aGrupa,{cCodProd,;		//01-Produto
			cDscProd,;		//02-Descricao
			cLotePrd,;		//03-Lote
			cFabrica,;		//04-Fabricante
			cMoedProd,;	//05-Moeda
			nPrecoNet,;	//06-Preco Net
			nSaldoDisp,;	//07-Saldo Disponivel
			nSaldoAtu,;	//08-Saldo Atual
			nSld15Dias,;	//09-Saldo 15 dias
			nSld30Dias,;	//10-Saldo 15 a 30 dias
			nSld99Dias,;	//11-Saldo Maior 30 dias
			nSCPenden,;	//12-SC Pendentes
			nPCPenden,;	//13-PC Pendentes
			cFilProd,;		//14-Filial
			cLocProd,;		//15-Armazem
			nCustoMed,;	//16-Custo Medio
			nPerMargem,;	//17-Margem
			cPisCofins,;	//18-PIS e COFINS Entrada
			cIPI })		//19-IPI

			aDadosTXT[nPosTXT][9] := aClone(aGrupa)

			(cAliasQry)->(DbSkip())
		EndDo

		nQtdRegs := 0

		For nX:=1 To Len(aDadosTXT)

			For nY:=1 To Len(aDadosTXT[nX][9])

				nQtdRegs++
				IncProc("Processando Registros : "+Alltrim(Str(nQtdRegs)) + " de "+Alltrim(Str(nTotRegs))  )

				oFwMsEx:AddRow( cWorkSheet,cTable,{ aDadosTXT[nX][9][nY][01],;	//01-Produto
				aDadosTXT[nX][9][nY][02],;	//02-Descricao
				aDadosTXT[nX][9][nY][03],;	//03-Lote
				aDadosTXT[nX][9][nY][04],;	//04-Fabricante
				aDadosTXT[nX][9][nY][05],;	//05-Moeda
				aDadosTXT[nX][9][nY][06],;	//06-Preco Net
				aDadosTXT[nX][9][nY][07],;	//07-Saldo Disponivel
				aDadosTXT[nX][9][nY][08],;	//08-Saldo Atual
				aDadosTXT[nX][9][nY][09],;	//09-15 dias
				aDadosTXT[nX][9][nY][10],;	//10-15 a 30 dias
				aDadosTXT[nX][9][nY][11],;	//11-Maior 30 dias
				aDadosTXT[nX][9][nY][12],;	//12-SC Pendentes
				aDadosTXT[nX][9][nY][13],;	//13-PC Pendentes
				aDadosTXT[nX][9][nY][14],;	//14-Filial
				aDadosTXT[nX][9][nY][15],;	//15-Armazem
				aDadosTXT[nX][9][nY][16],;	//16-Custo Medio
				aDadosTXT[nX][9][nY][17],;	//17-Margem
				aDadosTXT[nX][9][nY][18],;	//18-PIS e COFINS Entrada
				aDadosTXT[nX][9][nY][19] })	//19-IPI

			Next

			oFwMsEx:AddRow( cWorkSheet,cTable,{ "",;				//01-Produto
			"",;				//02-Descricao
			"",;				//03-Lote
			"TOTAL",;			//04-Fabricante
			"",;				//05-Moeda
			"",;				//06-Preco Net
			aDadosTXT[nX][4],;	//07-Saldo Disponivel
			aDadosTXT[nX][5],;	//08-Saldo Atual
			aDadosTXT[nX][6],;	//09-15 dias
			aDadosTXT[nX][7],;	//10-15 a 30 dias
			aDadosTXT[nX][8],;	//11-Maior 30 dias
			"",;				//12-SC Pendentes
			"",;				//13-PC Pendentes
			"",;				//14-Filial
			"",;				//15-Armazem
			"",;				//16-Custo Medio
			"",;				//17-Margem
			"",;				//18-PIS e COFINS Entrada
			"" })				//19-IPI

			oFwMsEx:AddRow( cWorkSheet,cTable,{ "",;	//01-Produto
			"",;	//02-Descricao
			"",;	//03-Lote
			"",;	//04-Fabricante
			"",;	//05-Moeda
			"",;	//06-Preco Net
			"",;	//07-Saldo Disponivel
			"",;	//08-Saldo Atual
			"",;	//09-15 dias
			"",;	//10-15 a 30 dias
			"",;	//11-Maior 30 dias
			"",;	//12-SC Pendentes
			"",;	//13-PC Pendentes
			"",;	//14-Filial
			"",;	//15-Armazem
			"",;	//16-Custo Medio
			"",;	//17-Margem
			"",;	//18-PIS e COFINS Entrada
			"" })	//19-IPI

		Next

		cDirArq := cDirRel+cArqRel+".xlsx"

		oFwMsEx:Activate()
		oFwMsEx:GetXMLFile(cTempCSV)

		If __CopyFile( cTempCSV, cDirArq )
			If File(cDirArq)
				FErase(cTempCSV)
				MsgInfo("Favor abrir o relatório no diretório:"+cEndLin+cDirArq)
				//oExcel:= MsExcel():New()       	//Abre uma nova conexão com Excel
				//oExcel:WorkBooks:Open(cDirArq) 	//Abre uma planilha
				//oExcel:SetVisible(.T.)         	//Visualiza a planilha
				//oExcel:Destroy()
			EndIf
		EndIf

	Else
		MsgInfo("Não há dados para geração do relatório.")
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return

/*/{Protheus.doc} VDSaldDias
Retorna o Saldo conforme os Dias
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDSaldDias(cXFilPrd,cXCodPrd,cXLotPrd,cXLocPrd,cXTipo)

	Local cQuery	 	:= ""
	Local cAliasQry	 	:= ""
	Local nRet	 		:= 0
	Local dDataIni 		:= CtoD("")
	Local dDataFim 		:= CtoD("")

	//15 dias
	If cXTipo == "1"
		dDataIni := MV_PAR05
		dDataFim := MV_PAR05+15

	//15 A 30 dias 
	ElseIf cXTipo == "2"
		dDataIni := MV_PAR05+16
		dDataFim := MV_PAR05+30

	//Maior que 30 dias
	ElseIf cXTipo == "3"
		dDataIni := MV_PAR05+31
	EndIf

	cQuery := " SELECT ISNULL(SUM(SC6.C6_QTDVEN),0) AS SLDDIAS "
	cQuery += "   FROM "+RetSqlName("SC6")+" SC6 (NOLOCK) "
	cQuery += "  INNER JOIN "+RetSqlName("SC5")+" SC5 "
	cQuery += "     ON SC5.C5_FILIAL  = SC6.C6_FILIAL "
	cQuery += "    AND SC5.C5_NUM     = SC6.C6_NUM "
	cQuery += "    AND SC5.D_E_L_E_T_ = ' ' "
	cQuery += "  WHERE SC6.C6_FILIAL  = '"+cXFilPrd+"' "
	cQuery += "    AND SC6.C6_PRODUTO = '"+cXCodPrd+"' "
	cQuery += "    AND SC6.C6_LOCAL   = '"+cXLocPrd+"' "
	cQuery += "    AND SC6.C6_LOTECTL = '"+cXLotPrd+"' "
	If cXTipo == "1" .Or. cXTipo == "2"
		cQuery += "    AND ( ( SC5.C5_ZZDTLPR BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"' AND SC5.C5_ZZDTLPR <> '"+Space(8)+"' ) "
		cQuery += "     OR (   SC6.C6_ENTREG  BETWEEN '"+DtoS(dDataIni)+"' AND '"+DtoS(dDataFim)+"' AND SC5.C5_ZZDTLPR = '"+Space(8)+"'  ) ) "
	Else
		cQuery += "    AND ( ( SC5.C5_ZZDTLPR >= '"+DtoS(dDataIni)+"' AND SC5.C5_ZZDTLPR <> '"+Space(8)+"' ) "
		cQuery += "     OR (   SC6.C6_ENTREG >= '"+DtoS(dDataIni)+"'  AND SC5.C5_ZZDTLPR = '"+Space(8)+"'  ) ) "
	EndIf
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->SLDDIAS > 0
		nRet := (cAliasQry)->SLDDIAS
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return(nRet)

/*/{Protheus.doc} VDSCPenden
Retorna SC Pendentes
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDSCPenden(cXFilPrd,cXCodPrd,cXLocPrd)

	Local cQuery	 	:= ""
	Local cAliasQry	 	:= ""
	Local nRet	 		:= 0

	cQuery := " SELECT ISNULL(SUM(SC1.C1_QUANT),0) AS QUANTID "
	cQuery += " 	  ,ISNULL(SUM(SC1.C1_QUJE),0) AS QENTREG "
	cQuery += "   FROM "+RetSqlName("SC1")+" SC1 (NOLOCK) "
	cQuery += "  WHERE SC1.C1_FILIAL  = '"+cXFilPrd+"' "
	cQuery += "    AND SC1.C1_PRODUTO = '"+cXCodPrd+"' "
	cQuery += "    AND SC1.C1_LOCAL   = '"+cXLocPrd+"' "
	cQuery += "    AND SC1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->QUANTID > 0
		nRet := (cAliasQry)->QUANTID - (cAliasQry)->QENTREG
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return(nRet)

/*/{Protheus.doc} VDPCPenden
Retorna PC Pendentes
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPCPenden(cXFilPrd,cXCodPrd,cXLocPrd)

	Local cQuery	 	:= ""
	Local cAliasQry	 	:= ""
	Local nRet	 		:= 0

	cQuery := " SELECT ISNULL(SUM(SC7.C7_QUANT),0) AS QUANTID "
	cQuery += " 	  ,ISNULL(SUM(SC7.C7_QUJE),0) AS QENTREG "
	cQuery += "   FROM "+RetSqlName("SC7")+" SC7 (NOLOCK) "
	cQuery += "  WHERE SC7.C7_FILIAL  = '"+cXFilPrd+"' "
	cQuery += "    AND SC7.C7_PRODUTO = '"+cXCodPrd+"' "
	cQuery += "    AND SC7.C7_LOCAL   = '"+cXLocPrd+"' "
	cQuery += "    AND SC7.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->QUANTID > 0
		nRet := (cAliasQry)->QUANTID - (cAliasQry)->QENTREG
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return(nRet)

/*/{Protheus.doc} VDPesqImpo
Retorna PC Pendentes
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPesqImpo(cXFilPrd,cXCodPrd,cXTipo)

	Local cQuery	 	:= ""
	Local cAliasQry	 	:= ""
	Local cRet	 		:= "NAO"

	cQuery := " SELECT COUNT(SFT.R_E_C_N_O_) AS TOTSFT "
	cQuery += "   FROM "+RetSqlName("SFT")+" SFT (NOLOCK) "
	cQuery += "  WHERE SFT.FT_FILIAL  = '"+cXFilPrd+"' "
	cQuery += "    AND SFT.FT_PRODUTO = '"+cXCodPrd+"' "
	cQuery += "    AND SFT.FT_DTCANC  = '"+Space(8)+"' "
	cQuery += "    AND SFT.FT_TIPOMOV = 'E' "

	If cXTipo == "1"
		cQuery += "    AND SFT.FT_VALPIS > 0 "
		cQuery += "    AND SFT.FT_VALCOF > 0 "
	Else
		cQuery += "    AND SFT.FT_VALIPI > 0 "
	EndIf
	cQuery += "    AND SFT.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->TOTSFT > 0
		cRet := "SIM"
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

Return(cRet)

/*/{Protheus.doc} VDGravaSX1
Cria as Perguntas no SX1
@author Totvs
@since 02/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDGravaSX1(cPerg)

	Local aAreaAtu	:= GetArea()
	Local aAreaSX1	:= SX1->(GetArea())
	Local nJ		:= 0
	Local nY		:= 0
	Local aRegs		:= {}

	aAdd(aRegs,{cPerg,"01","Produto de"			,"Produto de"			,"Produto de"			,"mv_ch1","C",TamSX3("B1_COD")[1]	,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","030","",""})
	aAdd(aRegs,{cPerg,"02","Produto até"		,"Produto até"			,"Produto até"			,"mv_ch2","C",TamSX3("B1_COD")[1]	,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","SB1","","030","",""})
	aAdd(aRegs,{cPerg,"03","Grupo Prod. de"		,"Grupo Prod. de"		,"Grupo Prod. de"		,"mv_ch3","C",TamSX3("B1_GRUPO")[1]	,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","162","",""})
	aAdd(aRegs,{cPerg,"04","Grupo Prod. ate"	,"Grupo Prod. ate"		,"Grupo Prod. ate"		,"mv_ch4","C",TamSX3("B1_GRUPO")[1]	,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SBM","","162","",""})
	aAdd(aRegs,{cPerg,"05","Data de Referencia:","Data de Referencia:"	,"Data de Referencia:"	,"mv_ch5","D",8					 	,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","",""	,"",""   ,"",""})

	DbSelectArea("SX1")
	SX1->(DbSetOrder(1))
	For nY:= 1 To Len(aRegs)
		If !MsSeek(aRegs[nY,1]+aRegs[nY,2])
			SX1->(RecLock("SX1",.T.))
			For nJ := 1 To FCount()
				If nJ <= Len(aRegs[nY])
					FieldPut(nJ,aRegs[nY,nJ])
				EndIf
			Next nJ
			SX1->(MsUnlock())
		EndIf
	Next nY

	RestArea(aAreaSX1)
	RestArea(aAreaAtu)

Return
