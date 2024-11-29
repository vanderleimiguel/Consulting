#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT140TOK
Ponto de entrada Exclusão do Documento de Entrada MATA103 - DOCUMENTO DE ENTRADA
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT103EXC()

	Local aArea		:= GetArea()
	Local lRet 		:= .T.

	//Exclui tabela de Rastreabilidade dos Lotes
	VDDeletZ42()

	RestArea(aArea)

Return(lRet)

/*/{Protheus.doc} VDDeletZ42
Exclusão da Rastreabilidade dos Lotes - Z42
@author TOTVS Protheus
@since 28/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDDeletZ42()

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local cNumDoc  	:= SF1->F1_DOC
	Local cSerDoc  	:= SF1->F1_SERIE
	Local cCodFor 	:= SF1->F1_FORNECE
	Local cLojFor 	:= SF1->F1_LOJA

	cQuery := "SELECT Z42.R_E_C_N_O_ AS RECZ42 "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
	cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8 "
	cQuery += "    ON SB8.B8_FILIAL  = '"+xFilial("SB8")+ "' "
	cQuery += "   AND SB8.B8_PRODUTO = SD1.D1_COD "
	cQuery += "   AND SB8.B8_LOCAL   = SD1.D1_LOCAL "
	cQuery += "   AND SB8.B8_LOTECTL = SD1.D1_LOTECTL "
	cQuery += "   AND SB8.B8_DOC     = SD1.D1_DOC "
	cQuery += "   AND SB8.B8_SERIE   = SD1.D1_SERIE "
	cQuery += "   AND SB8.B8_CLIFOR  = SD1.D1_FORNECE "
	cQuery += "   AND SB8.B8_LOJA    = SD1.D1_LOJA "
	cQuery += "   AND SB8.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN "+RetSqlName("Z42")+" Z42 "
	cQuery += "    ON Z42.Z42_FILIAL = '"+xFilial("Z42")+ "' "
	cQuery += "   AND Z42.Z42_PRODUT = SB8.B8_PRODUTO "
	cQuery += "   AND Z42.Z42_LOTE   = SB8.B8_LOTECTL "
	cQuery += "   AND Z42.Z42_DOC    = SD1.D1_DOC "
	cQuery += "   AND Z42.Z42_SERIE  = SD1.D1_SERIE "
	cQuery += "   AND Z42.Z42_FORNEC = SD1.D1_FORNECE "
	cQuery += "   AND Z42.Z42_LOJA   = SD1.D1_LOJA "
	cQuery += "   AND Z42.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+ "' "
	cQuery += "   AND SD1.D1_DOC     = '"+cNumDoc+ "' "
	cQuery += "   AND SD1.D1_SERIE   = '"+cSerDoc+ "' "
	cQuery += "   AND SD1.D1_FORNECE = '"+cCodFor+ "' "
	cQuery += "   AND SD1.D1_LOJA    = '"+cLojFor+ "' "
	cQuery += "   AND SD1.D1_LOTECTL <> '"+Space(TamSx3("D1_LOTECTL")[1])+"' "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " GROUP BY Z42.R_E_C_N_O_ "
	cQuery += " ORDER BY Z42.R_E_C_N_O_ "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	While (cAliasQry)->(!Eof())
		DbSelectArea("Z42")
		Z42->(DbGoTo((cAliasQry)->RECZ42))
		Z42->(RecLock("Z42",.F.))
		Z42->(DbDelete())
		Z42->(MsUnlock())
		(cAliasQry)->(DbSkip())
	EndDo

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return
