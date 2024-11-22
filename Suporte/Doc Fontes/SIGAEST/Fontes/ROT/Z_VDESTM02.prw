#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VDESTM02
Rotina de Importação dos Saldos Iniciais por Endereço através de um arquivo CSV
@author TOTVS Protheus
@since 16/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function VDESTM02()

	Local aArea			:= GetArea()
	Local aSays     	:= {}
	Local aButtons  	:= {}
	Local cCadastro 	:= OemToAnsi("Importação Saldos Iniciais")
	Local nRet 			:= 0

	Private cArquivo	:= Space(200)

	aAdd(aSays,OemToAnsi("Este programa tem como objetivo a Importação do Saldos Iniciais por Endereço"	))
	aAdd(aSays,OemToAnsi("conforme seleção de uma Planilha no formato CSV."	 		))
	aAdd(aSays,OemToAnsi(""																		))
	aAdd(aSays,OemToAnsi("Clique no botão OK para iniciar o processamento."	))
	aAdd(aSays,OemToAnsi(""													))
	aAdd(aButtons, { 1,.T.,{|o| FechaBatch(),nRet:=1	}})
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch()			}})
	FormBatch( cCadastro, aSays, aButtons)
	If nRet == 1
		VDPrcPLSM2()
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} VDPrcPLSM2
Seleciona Arquivo CSV e Define os Parâmetros da Rotina
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPrcPLSM2()

	Local oProcess	:= Nil
	Local cType		:= "Arquivo CSV |*.CSV"
	Local cPerg		:= PadR("VDESTM02",10)
	Local lRet		:= .T.
	Local nRecSF5	:= 0

	VDGravaSX1(cPerg)

	cArquivo := cGetFile(cType, OemToAnsi("Selecione o Arquivo"),0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	If !File(cArquivo)
		FWAlertWarning("Planilha de Importação não selecionada","Z_VDESTM02")
	Else

		If Pergunte(cPerg,.T.)

			If Empty(AllTrim(MV_PAR01))
				FWAlertWarning("Favor Informar o Tipo de Movimento","Z_VDESTM02")
				lRet := .F.
			Else
				nRecSF5 := VDRecnoSF5(MV_PAR01)
				If nRecSF5 == 0
					FWAlertWarning("Tipo de Movimento não localizado.","Z_VDESTM02")
					lRet := .F.
				EndIf
			EndIf

			If lRet
				oProcess := MsNewProcess():New({|lEnd| VDPrcCSV02(@oProcess,@lEnd,cArquivo,nRecSF5) },"Processando Importação...","",.F.)
				oProcess:Activate()
			EndIf

		EndIf

	EndIf

Return

/*/{Protheus.doc} VDPrcCSV02
Processa Planilha CSV
@author TOTVS Protheus
@since 16/08/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPrcCSV02(oProcess,lEnd,cArquivo,nRecSF5)

	Local oFile 		:= Nil
	Local aLinhas		:= {}
	Local aCamposCSV	:= {}
	Local aDadosCSV		:= {}
	Local nTotProc		:= 3
	Local nTotRegs		:= 0
	Local lRet			:= .T.

	Private nPCodArm	:= 0
	Private nPCodProd	:= 0
	Private nPQuantid	:= 0
	Private nPLocaliz	:= 0
	Private nPLoteCTL	:= 0
	Private nPSubLote	:= 0
	Private nPDtValid	:= 0
	Private nPCusto		:= 0

	oProcess:SetRegua1(nTotProc)
	oProcess:IncRegua1("Validando Campos da Planilha...")

	oFile := FwFileReader():New(cArquivo)
	If (oFile:Open())

		aLinhas := oFile:GetAllLines()
		If Len(aLinhas) > 0

			aCamposCSV := StrTokArr2(aLinhas[1],";",.T.)
			AEval(aLinhas, {|x| AAdd(aDadosCSV, StrTokArr2(x,";",.T.)) })
			oFile:Close()

			nTotRegs := Len(aCamposCSV)

			oProcess:SetRegua2(nTotRegs)

			If ( nPCodArm := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "ARMAZEM"}) ) == 0
				FWAlertWarning("Campo ARMAZEM não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPCodProd := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "PRODUTO"}) ) == 0
				FWAlertWarning("Campo PRODUTO não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPQuantid := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "QUANTIDADE"}) ) == 0
				FWAlertWarning("Campo QUANTIDADE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPLocaliz := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "ENDERECO"}) ) == 0
				FWAlertWarning("Campo ENDERECO não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPLoteCTL := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "LOTE"}) ) == 0
				FWAlertWarning("Campo LOTE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPSubLote := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "SUBLOTE"}) ) == 0
				FWAlertWarning("Campo SUBLOTE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPDtValid := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "VALIDADE"}) ) == 0
				FWAlertWarning("Campo VALIDADE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If ( nPCusto := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "CUSTO"}) ) == 0
				FWAlertWarning("Campo SERIE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM02")
				lRet := .F.
			EndIf

			If lRet

				If Len(aCamposCSV) > 0 .And. Len(aDadosCSV) > 0
					VDVldCSV02(@oProcess,@lEnd,aCamposCSV,aDadosCSV,cArquivo,nRecSF5)
				Else
					MsgStop("Arquivo com conteudo inválido. Campos e Linhas!")
				EndIf

			EndIf

		Else
			MsgStop("Arquivo com conteudo inválido!")
		EndIf

	EndIf

Return

/*/{Protheus.doc} VDVldCSV02
Validação da Planilha CSV para depois inicar as Gravações das Tabelas
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDVldCSV02(oProcess,lEnd,aCamposCSV,aDadosCSV,cArquivo,nRecSF5)

	Local nTotRegs		:= Len(aDadosCSV)
	Local nX 			:= 0
	Local nZ			:= 0
	Local aMsgLog		:= {}
	Local cMsgLog		:= ""
	Local nCountLog		:= 0
	Local cTempCSV	 	:= GetNextAlias()+".xlsx"
	Local oFwMsEx	 	:= Nil
	Local cWorkSheet 	:= ""
	Local cTable     	:= ""
	Local cEndLin		:= Chr(13)+Chr(10)
	Local nRecNNR		:= 0
	Local nRecSB1		:= 0
	Local nRecSBZ		:= 0
	Local nRecSBE		:= 0
	Local nRecSB8		:= 0
	Local nRecSBF		:= 0
	Local aDadosSLD		:= {}
	Local cCodArm		:= ""
	Local cCodProd		:= ""
	Local cQuantid		:= 0
	Local nQuantid		:= 0
	Local cEnderec		:= ""
	Local cLoteCTL		:= ""
	Local cSubLote		:= ""
	Local cDtValid		:= ""
	Local dDtValid		:= CtoD("")
	Local cVlrCust		:= ""
	Local nVlrCust		:= 0
	Local lGravaSLD		:= .T.
	Local lLoteProd 	:= .F.
	Local lContrWMS 	:= .F.
	Local lContrEnd 	:= .F.
	Local lCusto 		:= .F.

	cDirArq := SubStr(AllTrim(cArquivo),1,Len(AllTrim(cArquivo))-4)+"_log.xlsx"
	If File(cDirArq)
		FErase(cDirArq)
	EndIf

	DbSelectArea("SF5")
	SF5->(DbGoTo(nRecSF5))
	lCusto := IF(SF5->F5_VAL=="S",.T.,.F.)

	oFwMsEx:= FwMsExcelXlsx():New()
	cWorkSheet := "Log"
	cTable     := "Log de Processamento - Saldos Iniciais SBF - Filial: "+cFilAnt +"- TM "+MV_PAR01

	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	oProcess:IncRegua1("Validando Conteudo da Planilha...")
	oProcess:SetRegua2(nTotRegs)

	For nX:=1 To Len(aDadosCSV)

		If Len(aDadosCSV[nX]) >= 8

			oProcess:IncRegua2("Processando Linha: "+Alltrim(Str(nX)) + " de "+Alltrim(Str(nTotRegs))  )

			aMsgLog 	:= {}
			cMsgLog 	:= "OK"
			cCodArm		:= ""
			cCodProd	:= ""
			cQuantid	:= 0
			nQuantid	:= 0
			cEnderec	:= ""
			cLoteCTL	:= ""
			cSubLote	:= ""
			cDtValid	:= ""
			dDtValid	:= CtoD("")
			cVlrCust	:= ""
			nVlrCust	:= 0
			lLoteProd 	:= .F.
			lContrWMS 	:= .F.
			lContrEnd 	:= .F.
			nRecNNR		:= 0
			nRecSB1 	:= 0
			nRecSBZ 	:= 0
			nRecSBE		:= 0
			nRecSB8		:= 0
			nRecSBF		:= 0

			//Primeira Linha na Planilha é o Cabeçalho
			If nX == 1

				//1-General,2-Number,3-Monetário,4-DateTime )
				oFwMsEx:AddColumn( cWorkSheet, cTable, "ARMAZEM"	,1,1)	//01
				oFwMsEx:AddColumn( cWorkSheet, cTable, "PRODUTO"	,1,1)	//02
				oFwMsEx:AddColumn( cWorkSheet, cTable, "QUANTIDADE"	,1,1)	//03
				oFwMsEx:AddColumn( cWorkSheet, cTable, "ENDERECO"	,1,1)	//04
				oFwMsEx:AddColumn( cWorkSheet, cTable, "LOTE"		,1,1)	//05
				oFwMsEx:AddColumn( cWorkSheet, cTable, "SUBLOTE"	,1,1)	//06
				oFwMsEx:AddColumn( cWorkSheet, cTable, "VALIDADE"	,1,1)	//07
				oFwMsEx:AddColumn( cWorkSheet, cTable, "CUSTO"		,1,1)	//08
				oFwMsEx:AddColumn( cWorkSheet, cTable, "MENSAGEM"	,1,1)	//09

			Else

				//Validação Armazem
				cCodArm := AllTrim(aDadosCSV[nX][nPCodArm])
				If Empty(cCodArm)
					aAdd(aMsgLog,"O campo ARMAZEM é obrigatorio")
				Else
					nRecNNR := VDRecnoNNR(cCodArm)
					If nRecNNR == 0
						aAdd(aMsgLog,"Armazem "+cCodArm+" nao encontrado")
					EndIf
				EndIf

				//Validação Produto
				cCodProd := AllTrim(aDadosCSV[nX][nPCodProd])
				If Empty(cCodProd)
					aAdd(aMsgLog,"O campo PRODUTO é obrigatorio")
				Else
					nRecSB1 := VDRecnoSB1(cCodProd)
					If nRecSB1 == 0
						aAdd(aMsgLog,"Produto "+cCodProd+" nao encontrado")
					Else

						DbSelectArea("SB1")
						SB1->(DbGoTo(nRecSB1))
						If Rastro(SB1->B1_COD,"L")
							lLoteProd := .T.
						EndIf

						If SuperGetMV("MV_INTWMS",.F.,.F.)

							nRecSBZ := VDRecnoSBZ(cCodProd)
							If nRecSBZ == 0
								aAdd(aMsgLog,"Indicador do Produto "+cCodProd+" nao encontrado")
							Else
								DbSelectArea("SBZ")
								SBZ->(DbGoTo(nRecSBZ))
								lContrWMS := IF(SBZ->BZ_CTRWMS=="1",.T.,.F.)
								lContrEnd := IF(SBZ->BZ_LOCALIZ=="S",.T.,.F.)
								If lContrWMS
									aAdd(aMsgLog,"Produto "+cCodProd+" controlado por WMS nao pode ser processado por essa rotina.")
								EndIf
							EndIf
						Endif
					EndIf
				EndIf

				//Validacao Quantidade
				cQuantid := AllTrim(aDadosCSV[nX][nPQuantid])
				If Empty(cQuantid)
					aAdd(aMsgLog,"O campo QUANTIDADE é obrigatorio")
				Else
					nQuantid := Val(cQuantid)
					If nQuantid <= 0
						aAdd(aMsgLog,"Favor informar uma Quantidade maior que zero")
					EndIf
				EndIf

				//Somente se Controla Rastro e Endereço
				If lContrEnd .And. lLoteProd .And. Len(aMsgLog) == 0

					//Validação Endereço
					cEnderec := AllTrim(aDadosCSV[nX][nPLocaliz])
					If Empty(cEnderec)
						aAdd(aMsgLog,"O campo ENDERECO é obrigatorio")
					Else
						nRecSBE := VDRecnoSBE(cCodArm,cEnderec)
						If nRecSBE == 0
							aAdd(aMsgLog,"Endereco "+cEnderec+" nao encontrado no Armazem " +cCodArm )
						EndIf
					EndIf

				EndIf

				//Somente se Controla Rastro e Endereço
				If lContrEnd .Or. lLoteProd .And. Len(aMsgLog) == 0

					//Validação Lote
					cLoteCTL := AllTrim(aDadosCSV[nX][nPLoteCTL])
					If Len(aMsgLog) == 0

						If Empty(cLoteCTL)
							aAdd(aMsgLog,"O campo LOTE é obrigatorio")
						Else

							If lLoteProd
								nRecSB8 := VDRecnoSB8(cCodArm,cCodProd,cLoteCTL)
								If nRecSB8 > 0
									aAdd(aMsgLog,"Saldo Inicial (SB8) ja existente no Lote "+cLoteCTL )
								EndIf
							EndIf

							If lLoteProd .And. lContrEnd
								nRecSBF := VDRecnoSBF(cCodArm,cCodProd,cLoteCTL,cEnderec)
								If nRecSBF > 0
									aAdd(aMsgLog,"Saldo Inicial (SBF) ja existente no Lote "+cLoteCTL+" e Endereco " +cEnderec )
								EndIf
							EndIf

						EndIf

					EndIf

				EndIf

				//Somente se Controla Rastro
				If lLoteProd .And. Len(aMsgLog) == 0

					//Validacao Data de Validade
					cDtValid := AllTrim(aDadosCSV[nX][nPDtValid])
					If Empty(cDtValid)
						aAdd(aMsgLog,"O campo VALIDADE é obrigatorio")
					Else
						dDtValid := StoD(cDtValid)
						If Empty(DtoS(dDtValid))
							aAdd(aMsgLog,"Favor informar uma data de VALIDADE no formato AAAAMMDD")
						EndIf
					EndIf

				EndIf

				If lCusto

					//Validacao Custo
					cVlrCust := AllTrim(aDadosCSV[nX][nPCusto])
					If Empty(cVlrCust)
						aAdd(aMsgLog,"O campo CUSTO é obrigatorio")
					Else
						nVlrCust := Val(cVlrCust)
						If nVlrCust <= 0
							aAdd(aMsgLog,"Favor informar um valor de CUSTO maior que zero")
						EndIf
					EndIf

				EndIf

				//Ajusta Array de Logs para formar a mensagem
				If Len(aMsgLog) > 0
					nCountLog++
					cMsgLog := ""
					For nZ:=1 To Len(aMsgLog)
						cMsgLog += aMsgLog[nZ] + IF(nZ==Len(aMsgLog),""," | ")
					Next
				EndIf

				aAdd(aDadosSLD,{cCodArm,;	//01-Armazem
				cCodProd,;	//02-Produto
				nQuantid,;	//03-Quantidade
				cEnderec,;	//04-Endereço
				cLoteCTL,;	//05-Lote
				cSubLote,;	//06-SubLote
				dDtValid,;	//07-Data de Validade
				"",;		//08-Numero Serie
				nVlrCust,;	//09-Valor Custo
				cMsgLog,;	//10-Mensagem Log
				nRecNNR,;	//11-Recno NNR
				nRecSB1,;	//12-Recno SB1
				nRecSBE,;	//13-Recno SBE
				nRecSBZ,; 	//14-Recno SBZ
				.F.}) 		//15-Endereçado? (True/Falso)

				oFwMsEx:AddRow( cWorkSheet,cTable,{ cCodArm,;	//01-Armazem
				cCodProd,;	//02-Produto
				cQuantid,;	//03-Quantidade
				cEnderec,;	//04-Endereço
				cLoteCTL,;	//05-Lote
				cSubLote,;	//06-SubLote
				cDtValid,;	//07-Data de Validade
				cVlrCust,;	//08-Numero Serie
				cMsgLog })	//09-Mensagem Log

			EndIf

		EndIf

	Next

	If nCountLog == 0
		lGravaSLD := VDGravaSLD(@oProcess,@lEnd,aDadosSLD,lCusto)
	EndIf

	If lGravaSLD

		oFwMsEx:Activate()
		oFwMsEx:GetXMLFile(cTempCSV)

		If __CopyFile( cTempCSV, cDirArq )
			If File(cDirArq)
				FErase(cTempCSV)
				FWAlertInfo("Importação realizada com sucesso. Verifique o arquivo de log: "+cEndLin+cDirArq,"Z_VDESTM02")
			EndIf
		EndIf

	Else
		oFwMsEx := Nil
	EndIf

Return

/*/{Protheus.doc} VDRecnoSF5
Retorna Recno da SF5 - Tipos de Movimentos TM
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSF5(cXCodTM)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SF5.R_E_C_N_O_ AS RECSF5 "
	cQuery += "  FROM "+RetSqlName("SF5")+" SF5 (NOLOCK) "
	cQuery += " WHERE SF5.F5_FILIAL = '"+xFilial("SF5")+ "' "
	cQuery += "   AND SF5.F5_CODIGO = '"+PadR(AllTrim(cXCodTM),TamSX3("F5_CODIGO")[1])+"' "
	cQuery += "   AND SF5.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSF5 > 0
		nRet := (cAliasQry)->RECSF5
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoNNR
Retorna Recno da NNR - Armazem
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoNNR(cXCodArm)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT NNR.R_E_C_N_O_ AS RECNNR "
	cQuery += "  FROM "+RetSqlName("NNR")+" NNR (NOLOCK) "
	cQuery += " WHERE NNR.NNR_FILIAL = '"+xFilial("NNR")+ "' "
	cQuery += "   AND NNR.NNR_CODIGO = '"+PadR(AllTrim(cXCodArm),TamSX3("NNR_CODIGO")[1])+"' "
	cQuery += "   AND NNR.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECNNR > 0
		nRet := (cAliasQry)->RECNNR
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)


/*/{Protheus.doc} VDRecnoSB1
Retorna Recno da SB1 - Produtos
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSB1(cXCodPrd)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SB1.R_E_C_N_O_ AS RECSB1 "
	cQuery += "  FROM "+RetSqlName("SB1")+" SB1 (NOLOCK) "
	cQuery += " WHERE SB1.B1_FILIAL  = '"+xFilial("SB1")+ "' "
	cQuery += "   AND SB1.B1_COD     = '"+PadR(AllTrim(cXCodPrd),TamSX3("B1_COD")[1])+"' "
	cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSB1 > 0
		nRet := (cAliasQry)->RECSB1
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoSBZ
Retorna Recno da SBZ - Indicadores de Produtos
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSBZ(cXCodPrd)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SBZ.R_E_C_N_O_ AS RECSBZ "
	cQuery += "  FROM "+RetSqlName("SBZ")+" SBZ (NOLOCK) "
	cQuery += " WHERE SBZ.BZ_FILIAL  = '"+xFilial("SBZ")+ "' "
	cQuery += "   AND SBZ.BZ_COD     = '"+PadR(AllTrim(cXCodPrd),TamSX3("BZ_COD")[1])+"' "
	cQuery += "   AND SBZ.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSBZ > 0
		nRet := (cAliasQry)->RECSBZ
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoSBE
Retorna Recno da SBE - Endereços
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSBE(cXCodArm,cXLocaliz)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SBE.R_E_C_N_O_ AS RECSBE "
	cQuery += "  FROM "+RetSqlName("SBE")+" SBE (NOLOCK) "
	cQuery += " WHERE SBE.BE_FILIAL  = '"+xFilial("SBE")+ "' "
	cQuery += "   AND SBE.BE_LOCAL   = '"+cXCodArm+"' "
	cQuery += "   AND SBE.BE_LOCALIZ = '"+PadR(AllTrim(cXLocaliz),TamSX3("BE_LOCALIZ")[1])+"' "
	cQuery += "   AND SBE.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSBE > 0
		nRet := (cAliasQry)->RECSBE
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoSB8
Retorna Recno da SB8 - Saldos por Lote
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSB8(cXCodArm,cXCodPrd,cXLoteCTL)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SBF.R_E_C_N_O_ AS RECSBF "
	cQuery += "  FROM "+RetSqlName("SBF")+" SBF (NOLOCK) "
	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+ "' "
	cQuery += "   AND SBF.BF_PRODUTO = '"+PadR(AllTrim(cXCodPrd),TamSX3("BF_PRODUTO")[1])+"' "
	cQuery += "   AND SBF.BF_LOCAL   = '"+cXCodArm+"' "
	cQuery += "   AND SBF.BF_LOTECTL = '"+PadR(AllTrim(cXLoteCTL),TamSX3("BF_LOTECTL")[1])+"' "
	cQuery += "   AND SBF.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSBF > 0
		nRet := (cAliasQry)->RECSBF
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoSBF
Retorna Recno da SBF - Saldos por Endereço
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSBF(cXCodArm,cXCodPrd,cXLoteCTL,cXEnderec)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SBF.R_E_C_N_O_ AS RECSBF "
	cQuery += "  FROM "+RetSqlName("SBF")+" SBF (NOLOCK) "
	cQuery += " WHERE SBF.BF_FILIAL  = '"+xFilial("SBF")+ "' "
	cQuery += "   AND SBF.BF_PRODUTO = '"+PadR(AllTrim(cXCodPrd),TamSX3("BF_PRODUTO")[1])+"' "
	cQuery += "   AND SBF.BF_LOCAL   = '"+cXCodArm+"' "
	cQuery += "   AND SBF.BF_LOTECTL = '"+PadR(AllTrim(cXLoteCTL),TamSX3("BF_LOTECTL")[1])+"' "
	cQuery += "   AND SBF.BF_LOCALIZ = '"+PadR(AllTrim(cXEnderec),TamSX3("BF_LOCALIZ")[1])+"' "
	cQuery += "   AND SBF.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSBF > 0
		nRet := (cAliasQry)->RECSBF
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDGravaSLD
Gravação das Tabelas de Saldo
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDGravaSLD(oProcess,lEnd,aDadosSLD,lCusto)

	Local aArea 		:= GetArea()
	Local lRet 			:= .T.
	Local nX			:= 0
	Local nTotRegs		:= Len(aDadosSLD)
	Local aCabecSD3		:= {}
	Local aItemSD3		:= {}
	Local aItensSD3		:= {}
	Local cNumDoc		:= ""
	Local aDadosSDA		:= {}
	Local nQuantSD3 	:= 0
	Local nCustoSD3 	:= 0
	Local cLoteSD3  	:= ""
	Local cSubLotSD3  	:= ""
	Local dValidSD3 	:= CtoD("")
	Local aCabecSDA		:= {}
	Local aItemSDB		:= {}
	Local nQuantSDB		:= 0
	Local lLoteProd 	:= .F.
	Local lContrEnd 	:= .F.

	oProcess:IncRegua1("Gerando Saldos Iniciais...")
	oProcess:SetRegua2(nTotRegs)

	Begin Transaction

		//Retorna Proximo Numero da SD3
		cNumDoc := NextNumero("SD3",2,"D3_DOC",.T.)

		aCabecSD3 := {	{"D3_DOC"		,cNumDoc	,NIL},;
			{"D3_TM"		,MV_PAR01	,NIL},;
			{"D3_EMISSAO"	,dDataBase	,NIL}}

		For nX:= 1 To Len(aDadosSLD)

			oProcess:IncRegua2("Processando Saldos: "+Alltrim(Str(nX)) + " de "+Alltrim(Str(nTotRegs))  )

			lLoteProd := .F.
			lContrEnd := .F.

			DbSelectArea("NNR")
			NNR->(DbGoTo(aDadosSLD[nX][11]))

			DbSelectArea("SB1")
			SB1->(DbGoTo(aDadosSLD[nX][12]))

			DbSelectArea("SBZ")
			SBZ->(DbGoTo(aDadosSLD[nX][14]))

			If Rastro(SB1->B1_COD,"L")
				lLoteProd := .T.
			EndIf

			lContrEnd := IF(SBZ->BZ_LOCALIZ=="S",.T.,.F.)

			If aDadosSLD[nX][13] > 0
				DbSelectArea("SBE")
				SBE->(DbGoTo(aDadosSLD[nX][13]))
			EndIf

			DbSelectArea("SB2")
			SB2->(DbSetOrder(1))
			If !SB2->(DbSeek(xFilial("SB2")+SB1->B1_COD+NNR->NNR_CODIGO))
				CriaSB2(SB1->B1_COD,NNR->NNR_CODIGO)
			EndIf

			nQuantSD3 	:= aDadosSLD[nX][03]
			nCustoSD3 	:= aDadosSLD[nX][09]
			cLoteSD3  	:= PadR(AllTrim(aDadosSLD[nX][05]),TamSX3("D3_LOTECTL")[1])
			cSubLotSD3  := PadR(AllTrim(aDadosSLD[nX][06]),TamSX3("D3_NUMLOTE")[1])
			dValidSD3 	:= aDadosSLD[nX][07]

			aItemSD3 := {}
			aAdd(aItemSD3,{"D3_COD"		,SB1->B1_COD		,NIL}) //Produto
			aAdd(aItemSD3,{"D3_UM"		,SB1->B1_UM			,NIL}) //Unidade de Medida
			aAdd(aItemSD3,{"D3_QUANT"	,nQuantSD3			,NIL}) //Quantidade
			aAdd(aItemSD3,{"D3_LOCAL"	,NNR->NNR_CODIGO	,NIL}) //Local

			If lCusto
				aAdd(aItemSD3,{"D3_CUSTO1"	,nCustoSD3		,NIL}) //Custo Moeda 1
			EndIf

			If lLoteProd
				aAdd(aItemSD3,{"D3_LOTECTL"	,cLoteSD3		,NIL}) //Lote
				aAdd(aItemSD3,{"D3_DTVALID"	,dValidSD3		,NIL}) //Validade do Lote
			EndIf

			If lContrEnd
				aAdd(aItemSD3,{"D3_LOCALIZ"	,SBE->BE_LOCALIZ	,NIL}) //Endereço
			EndIf

			aAdd(aItemSD3,{"D3_POTENCI"	,0					,NIL}) //Potência

			aAdd(aItensSD3,aItemSD3)

		Next

		lMsErroAuto := .F.

		MSExecAuto({|x,y,z| MATA241(x,y,z)},aCabecSD3,aItensSD3,3)

		If lMsErroAuto
			lRet := .F.
			DisarmTransaction()
			Mostraerro()
		Else

			aDadosSDA := VDDadosSDA(cNumDoc)
			For nX:=1 To Len(aDadosSDA)

				DbSelectArea("SDA")
				SDA->(DbGoTo(aDadosSDA[nX]))

				nPos := Ascan(aDadosSLD,{|x| Alltrim(x[1]) == AllTrim(SDA->DA_LOCAL) .And.;
					Alltrim(x[2]) == AllTrim(SDA->DA_PRODUTO) .And.;
					x[3] == SDA->DA_QTDORI .And.;
					Alltrim(x[5]) == AllTrim(SDA->DA_LOTECTL) .And.;
					x[15] == .F. })

				If nPos > 0

					DbSelectArea("SBE")
					SBE->(DbGoTo(aDadosSLD[nPos][13]))

					nQuantSDB 	:= aDadosSLD[nPos][03]

					aCabecSDA := {{"DA_PRODUTO"	,SDA->DA_PRODUTO   	,NIL},;
						{"DA_LOCAL"	,SDA->DA_LOCAL	    ,Nil},;
						{"DA_NUMSEQ"	,SDA->DA_NUMSEQ	 	,Nil},;
						{"DA_DOC"		,SDA->DA_DOC	    ,Nil}}

					aItemSDB := {{	{"DB_ITEM"   	,"0001"     		,Nil},;
						{"DB_ESTORNO"	,Space(1)			,Nil},;
						{"DB_LOCALIZ"	,SBE->BE_LOCALIZ	,Nil},;
						{"DB_DATA"		,dDataBase	  		,Nil},;
						{"DB_QUANT"		,nQuantSDB			,Nil}}}

					lMsErroAuto := .F.

					MATA265(aCabecSDA,aItemSDB,3)

					If lMsErroAuto
						lRet := .F.
						DisarmTransaction()
						Mostraerro()
						Exit
					Else
						aDadosSLD[nPos][15] := .T. //Marca como Endereçado
					EndIf

				EndIf

			Next

		EndIf

	End Transaction

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} VDDadosSDA
Retorna Recnos da SDA - Saldos a Endereçar
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDDadosSDA(cXNumDoc)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local aRet		:= {}

	cQuery := "SELECT SDA.R_E_C_N_O_ AS RECSDA "
	cQuery += "  FROM "+RetSqlName("SDA")+" SDA (NOLOCK) "
	cQuery += " WHERE SDA.DA_FILIAL  = '"+xFilial("SDA")+ "' "
	cQuery += "   AND SDA.DA_DOC     = '"+PadR(AllTrim(cXNumDoc),TamSX3("DA_DOC")[1])+"' "
	cQuery += "   AND SDA.DA_DATA    = '"+DtoS(dDataBase)+"' "
	cQuery += "   AND SDA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		aAdd(aRet,(cAliasQry)->RECSDA)
		(cAliasQry)->(DbSkip())
	EndDo

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(aRet)

/*/{Protheus.doc} VDGravaSX1
Grava as Perguntas no SX1 da rotina de Importação
@author TOTVS Protheus
@since 16/08/2024
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

	aAdd(aRegs,{cPerg,"01","Tipo Movimento","Tipo Movimento","Tipo Movimento","mv_ch1","C",TamSX3("D3_TM")[1],0,0,"G","EXISTCPO('SF5',MV_PAR01,1)","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","SF5","","","",""})

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
