#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT103FIM
Ponto de entrada Operação após gravação da NFE MATA103 - DOCUMENTO DE ENTRADA
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT103FIM()

	Local aArea		:= GetArea()
	Local nOpcao	:= Paramixb[1]	//3-Inclusão/5-Exclusão
	Local nConfirm	:= Paramixb[2]	//1-Confirma/0-Fechar

	If nOpcao == 3 .And. nConfirm == 1
		VDFabriZ42()
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} VDFabriZ42
Atualiza dados da tabela Z42
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDFabriZ42()

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""

	cQuery := "SELECT SD1.D1_ITEM "
	cQuery += "      ,SD1.R_E_C_N_O_ AS RECSD1 "
	cQuery += "      ,DKD.R_E_C_N_O_ AS RECDKD "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("DKD")+" DKD "
	cQuery += "    ON DKD.DKD_FILIAL = SD1.D1_FILIAL "
	cQuery += "   AND DKD.DKD_DOC    = SD1.D1_DOC "
	cQuery += "   AND DKD.DKD_SERIE  = SD1.D1_SERIE "
	cQuery += "   AND DKD.DKD_FORNEC = SD1.D1_FORNECE "
	cQuery += "   AND DKD.DKD_LOJA   = SD1.D1_LOJA "
	cQuery += "   AND DKD.DKD_ITEM   = SD1.D1_ITEM "
	cQuery += "   AND DKD.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SD1.D1_FILIAL  = '"+SF1->F1_FILIAL+ "' "
	cQuery += "   AND SD1.D1_DOC     = '"+SF1->F1_DOC+ "' "
	cQuery += "   AND SD1.D1_SERIE   = '"+SF1->F1_SERIE+ "' "
	cQuery += "   AND SD1.D1_FORNECE = '"+SF1->F1_FORNECE+ "' "
	cQuery += "   AND SD1.D1_LOJA    = '"+SF1->F1_LOJA+ "' "
	cQuery += "   AND SD1.D1_LOTECTL <> '"+Space(TamSx3("D1_LOTECTL")[1])+"' "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SD1.D1_ITEM "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())

		DbSelectArea("SD1")
		SD1->(DbGoTo((cAliasQry)->RECSD1))

		DbSelectArea("DKD")
		DKD->(DbGoTo((cAliasQry)->RECDKD))

		//Verifica se já existe o registro com a Chave Primária PRODUTO + LOTE na tabela Z42
		nRecZ42 := VDRecnoZ42(SD1->D1_COD,SD1->D1_LOTECTL)
		If nRecZ42 > 0
			DbSelectArea("Z42")
			Z42->(DbGoTo(nRecZ42))
			Z42->(RecLock("Z42",.F.))
			Z42->Z42_FABRIC	:= DKD->DKD_ZZFABR
			Z42->Z42_LJFABR	:= DKD->DKD_ZZLJFA
			Z42->(MsUnlock())
		EndIf

		(cAliasQry)->(DbSkip())
	EndDo

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} VDRecnoZ42
Retorna Recno da Z42 - Rastreabilidade dos Lotes
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoZ42(cXCodPrd,cXLotCTL)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT Z42.R_E_C_N_O_ AS RECZ42 "
	cQuery += "  FROM "+RetSqlName("Z42")+" Z42 (NOLOCK) "
	cQuery += " WHERE Z42.Z42_FILIAL = '"+xFilial("Z42")+ "' "
	cQuery += "   AND Z42.Z42_PRODUT = '"+cXCodPrd+"' "
	cQuery += "   AND Z42.Z42_LOTE   = '"+cXLotCTL+"' "
	cQuery += "   AND Z42.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECZ42 > 0
		nRet := (cAliasQry)->RECZ42
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)
