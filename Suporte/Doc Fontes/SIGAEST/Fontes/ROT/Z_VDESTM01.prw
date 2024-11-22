#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VDESTM01
Rotina de Importacao do Inventário Mestre através de um Arquivo CSV
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function VDESTM01()

	Local aArea			:= GetArea()
	Local aSays     	:= {}
	Local aButtons  	:= {}
	Local cCadastro 	:= OemToAnsi("Importação Mestre de Inventário")
	Local nRet 			:= 0

	Private cArquivo	:= Space(200)

	aAdd(aSays,OemToAnsi("Este programa tem como objetivo a Importação do Mestre de Inventário"	))
	aAdd(aSays,OemToAnsi("conforme seleção de uma Planilha no formato CSV."				 		))
	aAdd(aSays,OemToAnsi(""																		))
	aAdd(aSays,OemToAnsi("Clique no botão OK para iniciar o processamento."	))
	aAdd(aSays,OemToAnsi(""													))
	aAdd(aButtons, { 1,.T.,{|o| FechaBatch(),nRet:=1	}})
	aAdd(aButtons, { 2,.T.,{|o| FechaBatch()			}})
	FormBatch( cCadastro, aSays, aButtons)
	If nRet == 1
		VDPrcESTM1()
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} VDPrcESTM1
Seleciona Arquivo CSV e Define os Parâmetros da Rotina
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPrcESTM1()

	Local oProcess	:= Nil
	Local cType		:= "Arquivo CSV |*.CSV"
	Local cPerg		:= PadR("VDESTM01",10)
	Local lRet		:= .T.
	Local nRecCBA	:= 0

	VDGravaSX1(cPerg)

	cArquivo := cGetFile(cType, OemToAnsi("Selecione o Arquivo"),0,"SERVIDOR\",.T.,GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE)

	If !File(cArquivo)
		FWAlertWarning("Planilha de Importação não selecionada","Z_VDESTM01")
	Else

		If Pergunte(cPerg,.T.)

			If Empty(DtoS(MV_PAR01))
				FWAlertWarning("Favor Informar a Data do Inventário","Z_VDESTM01")
				lRet := .F.
			Else
				If MV_PAR01 < dDataBase
					FWAlertWarning("Data do Inventário menor que a DataBase do Sistema","Z_VDESTM01")
					lRet := .F.
				EndIf
			EndIf

			If Empty(AllTrim(MV_PAR02))
				FWAlertWarning("Favor Informar o Armazém do Inventário","Z_VDESTM01")
				lRet := .F.
			EndIf

			If Empty(AllTrim(MV_PAR03))
				FWAlertWarning("Favor Informar o Operador do Inventário","Z_VDESTM01")
				lRet := .F.
			EndIf

			//Validação do Inventário
			nRecCBA := VDRecnoCBA(MV_PAR01,MV_PAR02)
			If nRecCBA > 0
				FWAlertWarning("Já existe um Inventario com a Data "+DtoC(MV_PAR01)+" e o Armazem "+MV_PAR02,"Z_VDESTM01")
				lRet := .F.
			EndIf

			If lRet
				oProcess := MsNewProcess():New({|lEnd| VDPrcCSV01(@oProcess,@lEnd,cArquivo) },"Processando Importação...","",.F.)
				oProcess:Activate()
			EndIf

		EndIf

	EndIf

Return

/*/{Protheus.doc} VDPrcCSV01
Processa Planilha CSV
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDPrcCSV01(oProcess,lEnd,cArquivo)

	Local oFile 		:= Nil
	Local aLinhas		:= {}
	Local aCamposCSV	:= {}
	Local aDadosCSV		:= {}
	Local nTotProc		:= 3
	Local nTotRegs		:= 0
	Local lRet			:= .T.

	Private nPCodProd	:= 0
	Private nPLocaliz	:= 0
	Private nPLoteCTL	:= 0
	Private nPQuantid	:= 0

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

			If ( nPCodProd := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "PRODUTO"}) ) == 0
				FWAlertWarning("Campo PRODUTO não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM01")
				lRet := .F.
			EndIf

			If ( nPLocaliz := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "ENDERECO"}) ) == 0
				FWAlertWarning("Campo ENDERECO não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM01")
				lRet := .F.
			EndIf

			If ( nPLoteCTL := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "LOTE"}) ) == 0
				FWAlertWarning("Campo LOTE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM01")
				lRet := .F.
			EndIf

			If ( nPQuantid := aScan(aCamposCSV, {|x| AllTrim(Upper(x)) == "QUANTIDADE"}) ) == 0
				FWAlertWarning("Campo QUANTIDADE não foi localizado na Planilha. Favor seguir o layout proposto pela equipe Totvs","Z_VDESTM01")
				lRet := .F.
			EndIf

			If lRet

				If Len(aCamposCSV) > 0 .And. Len(aDadosCSV) > 0
					VDVldCSV01(@oProcess,@lEnd,aCamposCSV,aDadosCSV,cArquivo)
				Else
					MsgStop("Arquivo com conteudo inválido. Campos e Linhas!")
				EndIf

			EndIf

		Else
			MsgStop("Arquivo com conteudo inválido!")
		EndIf

	EndIf

Return

/*/{Protheus.doc} VDVldCSV01
Validação da Planilha CSV para depois inicar a Gravação das Tabelas
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDVldCSV01(oProcess,lEnd,aCamposCSV,aDadosCSV,cArquivo)

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
	Local nRecSB1		:= 0
	Local nRecSBZ		:= 0
	Local nRecSBE		:= 0
	Local aDadosINV		:= {}
	Local cCodProd		:= ""
	Local cEnderec		:= ""
	Local cLoteCTL		:= ""
	Local cQuantid		:= ""
	Local nQuantid		:= 0

	cDirArq := SubStr(AllTrim(cArquivo),1,Len(AllTrim(cArquivo))-4)+"_log.xlsx"
	If File(cDirArq)
		FErase(cDirArq)
	EndIf

	oFwMsEx:= FwMsExcelXlsx():New()
	cWorkSheet := "Log"
	cTable     := "Log de Processamento - Data Inventario "+DtoC(MV_PAR01)+" - Armazem "+MV_PAR02+" - Operador "+MV_PAR03

	oFwMsEx:AddWorkSheet( cWorkSheet )
	oFwMsEx:AddTable( cWorkSheet, cTable )

	oProcess:IncRegua1("Validando Conteudo da Planilha...")
	oProcess:SetRegua2(nTotRegs)

	For nX:=1 To Len(aDadosCSV)

		If Len(aDadosCSV[nX]) >= 4

			oProcess:IncRegua2("Processando Linha: "+Alltrim(Str(nX)) + " de "+Alltrim(Str(nTotRegs))  )

			aMsgLog 	:= {}
			cMsgLog 	:= "OK"
			cCodProd	:= ""
			cEnderec	:= ""
			cLoteCTL	:= ""
			cQuantid	:= ""
			nQuantid	:= 0
			cLoteCTL	:= ""
			lLoteProd 	:= .F.
			lContrWMS 	:= .F.
			lContrEnd 	:= .F.
			nRecSB1 	:= 0
			nRecSBZ 	:= 0
			nRecSBE		:= 0

			//Primeira Linha na Planilha é o Cabeçalho
			If nX == 1

				//1-General,2-Number,3-Monetário,4-DateTime )
				oFwMsEx:AddColumn( cWorkSheet, cTable, "PRODUTO"	,1,1)
				oFwMsEx:AddColumn( cWorkSheet, cTable, "ENDERECO"	,1,1)
				oFwMsEx:AddColumn( cWorkSheet, cTable, "LOTE"		,1,1)
				oFwMsEx:AddColumn( cWorkSheet, cTable, "QUANTIDADE"	,1,1)
				oFwMsEx:AddColumn( cWorkSheet, cTable, "MENSAGEM"	,1,1)

			Else

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

						nRecSBZ := VDRecnoSBZ(cCodProd)
						If nRecSBZ == 0
							aAdd(aMsgLog,"Indicador do Produto "+cCodProd+" nao encontrado")
						Else
							DbSelectArea("SBZ")
							SBZ->(DbGoTo(nRecSBZ))
							lContrWMS := IF(SBZ->BZ_CTRWMS=="1",.T.,.F.)
							lContrEnd := IF(SBZ->BZ_LOCALIZ=="S",.T.,.F.)
						EndIf

					EndIf
				EndIf

				//Somente se Controla Endereço
				If lContrEnd .And. Len(aMsgLog) == 0

					//Validação Endereço
					cEnderec := AllTrim(aDadosCSV[nX][nPLocaliz])
					If Empty(cEnderec)
						aAdd(aMsgLog,"O campo ENDERECO é obrigatorio")
					Else
						nRecSBE := VDRecnoSBE(MV_PAR02,cEnderec)
						If nRecSBE == 0
							aAdd(aMsgLog,"Endereco "+cEnderec+" nao encontrado")
						EndIf
					EndIf

				EndIf

				//Validacao Quantidade
				cQuantid := AllTrim(aDadosCSV[nX][nPQuantid])
				If Empty(cQuantid)
					aAdd(aMsgLog,"O campo QUANTIDADE é obrigatorio")
				Else
					nQuantid := Val(cQuantid)
					//If nQuantid <= 0
					//	aAdd(aMsgLog,"Favor informar uma Quantidade maior que zero")
					//EndIf
				EndIf

				//Somente se Controla Lote
				If lLoteProd .And. Len(aMsgLog) == 0

					//Validação Lote
					cLoteCTL := AllTrim(aDadosCSV[nX][nPLoteCTL])
					If Empty(cLoteCTL)
						aAdd(aMsgLog,"O campo LOTE é obrigatorio")
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

				aAdd(aDadosINV,{cCodProd,;	//01-Produto
				cEnderec,;	//02-Endereço
				cLoteCTL,;	//03-Lote
				nQuantid,;	//04-Quantidade
				cMsgLog,;	//05-Mensagem Log
				nRecSB1,;	//06-Recno SB1
				nRecSBE,;	//07-Recno SBE
				nRecSBZ }) 	//08-Recno SBF

				oFwMsEx:AddRow( cWorkSheet,cTable,{ cCodProd,;
					cEnderec,;
					cLoteCTL,;
					cQuantid,;
					cMsgLog })

			EndIf

		EndIf

	Next

	If nCountLog == 0
		VDGravaInv(@oProcess,@lEnd,aDadosINV)
	EndIf

	oFwMsEx:Activate()
	oFwMsEx:GetXMLFile(cTempCSV)

	If __CopyFile( cTempCSV, cDirArq )
		If File(cDirArq)
			FErase(cTempCSV)
			FWAlertInfo("Importação realizada com sucesso. Verifique o arquivo de log: "+cEndLin+cDirArq,"Z_VDESTM01")
		EndIf
	EndIf

Return

/*/{Protheus.doc} VDRecnoCBA
Retorna Recno da CBA - Mestre de Inventário
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoCBA(dXDatInv,cXCodArm)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT CBA.R_E_C_N_O_ AS RECCBA "
	cQuery += "  FROM "+RetSqlName("CBA")+" CBA (NOLOCK) "
	cQuery += " WHERE CBA.CBA_FILIAL = '"+xFilial("CBA")+ "' "
	cQuery += "   AND CBA.CBA_DATA   = '"+DtoS(dXDatInv)+"' "
	cQuery += "   AND CBA.CBA_LOCAL  = '"+cXCodArm+"' "
	cQuery += "   AND CBA.CBA_STATUS NOT IN ('4','5') "  //0-Nao Iniciado;1-Em Andamento;2-Em Pausa;3-Contado;4-Finalizado;5-Processado;6-Endereco Sem Saldo;7-Parcialmente Processado
	cQuery += "   AND CBA.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECCBA > 0
		nRet := (cAliasQry)->RECCBA
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)

/*/{Protheus.doc} VDRecnoSB1
Retorna Recno da SB1 - Produtos
@author TOTVS Protheus
@since 26/07/2024
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
@since 26/07/2024
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
Retorna Recno da SB1 - Endereços
@author TOTVS Protheus
@since 26/07/2024
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

/*/{Protheus.doc} VDGravaINV
Gravação das Tabelas do Mestre de Inventário
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDGravaINV(oProcess,lEnd,aDadosINV)

	Local aArea 	:= GetArea()
	Local nX		:= 0
	Local nTotRegs	:= Len(aDadosINV)
	Local cCodInv	:= ""
	Local cCBBNum	:= ""

	oProcess:IncRegua1("Gravando Mestre de Inventário...")
	oProcess:SetRegua2(nTotRegs)

	Begin Transaction

		cCodInv := GetSXENum("CBA","CBA_CODINV")

		DbSelectArea("CBA")
		CBA->(RecLock("CBA",.T.))
		CBA->CBA_FILIAL := xFilial("CBA")
		CBA->CBA_CODINV := cCodInv
		CBA->CBA_DATA   := MV_PAR01
		CBA->CBA_LOCAL  := MV_PAR02
		CBA->CBA_LOCALI := ""
		CBA->CBA_PROD	:= ""
		CBA->CBA_CONTS  := 1
		CBA->CBA_TIPINV := "1"	//1-Produto;2-Endereço
		CBA->CBA_CONTR  := 1
		CBA->CBA_STATUS := "1" //0-Nao Iniciado;1-Em Andamento;2-Em Pausa;3-Contado;4-Finalizado;5-Processado;6-Endereco Sem Saldo;7-Parcialmente Processado
		CBA->CBA_AUTREC	:= "1"
		CBA->CBA_CLASSA := "2"
		CBA->CBA_CLASSB := "2"
		CBA->CBA_CLASSC := "2"
		CBA->CBA_INVGUI := "1"
		CBA->CBA_RECINV := "2"
		CBA->(MsUnlock())

		cCBBNum := CBPROXCOD("MV_USUINV")
		DbSelectArea("CBB")
		CBB->(RecLock("CBB",.T.))
		CBB->CBB_FILIAL := xFilial("CBB")
		CBB->CBB_NUM	:= cCBBNum
		CBB->CBB_CODINV := cCodInv
		CBB->CBB_USU 	:= MV_PAR03
		CBB->CBB_NCONT	:= 0
		CBB->CBB_STATUS := "1"	//0=Nao iniciado;1=Em andamento;2=Finalizado
		CBB->(MsUnlock())

		ConfirmSX8()

		For nX:= 1 To Len(aDadosINV)

			oProcess:IncRegua2("Processando Gravação: "+Alltrim(Str(nX)) + " de "+Alltrim(Str(nTotRegs))  )

			lLoteProd := .F.
			lContrEnd := .F.

			DbSelectArea("SB1")
			SB1->(DbGoTo(aDadosINV[nX][6]))
			If Rastro(SB1->B1_COD,"L")
				lLoteProd := .T.
			EndIf

			DbSelectArea("SBZ")
			SBZ->(DbGoTo(aDadosINV[nX][8]))
			lContrEnd := IF(SBZ->BZ_LOCALIZ=="S",.T.,.F.)

			If aDadosINV[nX][7] > 0
				DbSelectArea("SBE")
				SBE->(DbGoTo(aDadosINV[nX][7]))
			EndIf

			DbSelectArea("CBC")
			CBC->(RecLock("CBC",.T.))
			CBC->CBC_FILIAL := xFilial("CBC")
			CBC->CBC_CODINV := cCodInv
			CBC->CBC_NUM 	:= cCBBNum
			CBC->CBC_COD 	:= SB1->B1_COD
			CBC->CBC_LOCAL 	:= MV_PAR02
			CBC->CBC_QUANT 	:= aDadosINV[nX][4]
			CBC->CBC_QTDORI	:= aDadosINV[nX][4]
			If aDadosINV[nX][7] > 0
				CBC->CBC_LOCALI	:= SBE->BE_LOCALIZ
			EndIf
			CBC->CBC_LOTECT	:= PadR(AllTrim(aDadosINV[nX][3]),TamSX3("CBC_LOTECT")[1])
			CBC->CBC_AJUST	:= "2"
			CBC->(MsUnlock())

			DbSelectArea("CBM")
			CBM->(RecLock("CBM",.T.))
			CBM->CBM_FILIAL := xFilial("CBM")
			CBM->CBM_CODINV := cCodInv
			CBM->CBM_COD 	:= SB1->B1_COD
			CBM->CBM_LOCAL 	:= MV_PAR02
			If aDadosINV[nX][7] > 0
				CBM->CBM_LOCALI	:= SBE->BE_LOCALIZ
			EndIf
			CBM->CBM_LOTECT	:= PadR(AllTrim(aDadosINV[nX][3]),TamSX3("CBM_LOTECT")[1])
			CBM->CBM_QTDORI	:= aDadosINV[nX][4]
			CBM->CBM_AJUST	:= "2"
			CBM->(MsUnlock())

		Next

	End Transaction

	RestArea(aArea)

Return

/*/{Protheus.doc} VDRetEspec
Retira Carateres Especiais
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRetEspec(cConteudo)

	Local aArea	:= GetArea()
	Local cRet	:= ""

//Retirando caracteres
	cConteudo := StrTran(cConteudo, "Ã", "A")
	cConteudo := StrTran(cConteudo, "ã", "a")
	cConteudo := StrTran(cConteudo, "Â", "A")
	cConteudo := StrTran(cConteudo, "â", "a")
	cConteudo := StrTran(cConteudo, "Á", "A")
	cConteudo := StrTran(cConteudo, "á", "a")
	cConteudo := StrTran(cConteudo, "À", "A")
	cConteudo := StrTran(cConteudo, "à", "a")
	cConteudo := StrTran(cConteudo, "Ê", "E")
	cConteudo := StrTran(cConteudo, "É", "E")
	cConteudo := StrTran(cConteudo, "È", "E")
	cConteudo := StrTran(cConteudo, "ê", "e")
	cConteudo := StrTran(cConteudo, "é", "e")
	cConteudo := StrTran(cConteudo, "è", "e")
	cConteudo := StrTran(cConteudo, "Î", "I")
	cConteudo := StrTran(cConteudo, "Í", "I")
	cConteudo := StrTran(cConteudo, "Ì", "I")
	cConteudo := StrTran(cConteudo, "î", "i")
	cConteudo := StrTran(cConteudo, "í", "i")
	cConteudo := StrTran(cConteudo, "ì", "i")
	cConteudo := StrTran(cConteudo, "Õ", "O")
	cConteudo := StrTran(cConteudo, "Ô", "O")
	cConteudo := StrTran(cConteudo, "Ó", "O")
	cConteudo := StrTran(cConteudo, "Ò", "O")
	cConteudo := StrTran(cConteudo, "õ", "o")
	cConteudo := StrTran(cConteudo, "ô", "o")
	cConteudo := StrTran(cConteudo, "ó", "o")
	cConteudo := StrTran(cConteudo, "ò", "o")
	cConteudo := StrTran(cConteudo, "Û", "U")
	cConteudo := StrTran(cConteudo, "Ú", "U")
	cConteudo := StrTran(cConteudo, "Ù", "U")
	cConteudo := StrTran(cConteudo, "Ç", "C")
	cConteudo := StrTran(cConteudo, "ç", "c")
	cConteudo := StrTran(cConteudo, "¨", "")
	cConteudo := StrTran(cConteudo, "'", "")
	cConteudo := StrTran(cConteudo, '"', "")
	cConteudo := StrTran(cConteudo, "#", "")
	cConteudo := StrTran(cConteudo, "*", "")
	cConteudo := StrTran(cConteudo, "&", "")
	cConteudo := StrTran(cConteudo, ">", "")
	cConteudo := StrTran(cConteudo, "<", "")
	cConteudo := StrTran(cConteudo, "!", "")
	cConteudo := StrTran(cConteudo, "@", "")
	cConteudo := StrTran(cConteudo, "$", "")
	cConteudo := StrTran(cConteudo, "(", "")
	cConteudo := StrTran(cConteudo, ")", "")
	cConteudo := StrTran(cConteudo, "_", "")
	cConteudo := StrTran(cConteudo, "=", "")
	cConteudo := StrTran(cConteudo, "+", "")
	cConteudo := StrTran(cConteudo, "{", "")
	cConteudo := StrTran(cConteudo, "}", "")
	cConteudo := StrTran(cConteudo, "[", "")
	cConteudo := StrTran(cConteudo, "]", "")
	cConteudo := StrTran(cConteudo, "\", "")
	cConteudo := StrTran(cConteudo, "/", "")
	cConteudo := StrTran(cConteudo, "?", "")
	cConteudo := StrTran(cConteudo, ".", "")
	cConteudo := StrTran(cConteudo, "|", "")
	cConteudo := StrTran(cConteudo, ":", "")
	cConteudo := StrTran(cConteudo, ";", "")
	cConteudo := StrTran(cConteudo, '"', '')
	cConteudo := StrTran(cConteudo, ",", "")
	cConteudo := StrTran(cConteudo, "-", "")

	cRet := AllTrim(cConteudo)

	RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} VDGravaSX1
Grava as Perguntas no SX1 da rotina de Importação
@author TOTVS Protheus
@since 30/06/2024
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

	aAdd(aRegs,{cPerg,"01","Data Inventario:"	,"Data Inventario:"	,"Data Inventario:" ,"mv_ch1","D",8						 ,0,0,"G","NAOVAZIO()"					,"MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","",""	 ,"","","",""})
	aAdd(aRegs,{cPerg,"02","Armazem"			,"Armazem"			,"Armazem"			,"mv_ch2","C",TamSX3("NNR_CODIGO")[1],0,0,"G","EXISTCPO('NNR',MV_PAR02,1)"	,"MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","NNR","","","",""})
	aAdd(aRegs,{cPerg,"03","Operador"			,"Operador"			,"Operador"			,"mv_ch3","C",TamSX3("CB1_CODOPE")[1],0,0,"G","EXISTCPO('CB1',MV_PAR03,1)"	,"MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","CB1","","","",""})

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
