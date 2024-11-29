#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MA261EXC
Ponto de entrada Atualização de algum campo ou variável no estorno - MATA261 - Transferencia Multipla
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MA261EXC()

	Local aArea		:= GetArea()

	//Exclui tabela de Rastreabilidade dos Lotes
	If SD3->D3_TM == "999"
		VDDeletZ42()
	EndIf

	RestArea(aArea)

Return

/*/{Protheus.doc} VDDeletZ42
Exclusão da Rastreabilidade dos Lotes
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDDeletZ42()

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local cNumDoc  	:= SD3->D3_DOC
	Local cCodPrd  	:= SD3->D3_COD

	//Verifica se foi uma Transferencia de Lote de Produtos diferentes
	cQuery := "SELECT Z42.R_E_C_N_O_ AS RECZ42 "
	cQuery += "  FROM "+RetSqlName("SD3")+" SD3 (NOLOCK) "

	cQuery += " INNER JOIN "+RetSqlName("SB8")+" SB8 (NOLOCK) "
	cQuery += "    ON SB8.B8_FILIAL  = '"+xFilial("SB8")+ "' "
	cQuery += "   AND SB8.B8_PRODUTO = SD3.D3_COD "
	cQuery += "   AND SB8.B8_LOCAL   = SD3.D3_LOCAL "
	cQuery += "   AND SB8.B8_LOTECTL = SD3.D3_LOTECTL "
	cQuery += "   AND SB8.B8_QTDORI  = SD3.D3_QUANT "
	cQuery += "   AND SB8.D_E_L_E_T_ = ' ' "

	cQuery += " INNER JOIN "+RetSqlName("Z42")+" Z42 "
	cQuery += "    ON Z42.Z42_FILIAL = '"+xFilial("Z42")+ "' "
	cQuery += "   AND Z42.Z42_PRODUT = SB8.B8_PRODUTO "
	cQuery += "   AND Z42.Z42_LOTE   = SB8.B8_LOTECTL "
	cQuery += "   AND Z42.Z42_ORIGEM = 'MATA261 ' "
	cQuery += "   AND Z42.D_E_L_E_T_ = ' ' "

	cQuery += " WHERE SD3.D3_FILIAL  = '"+xFilial("SD1")+ "' "
	cQuery += "   AND SD3.D3_DOC     = '"+cNumDoc+ "' "
	cQuery += "   AND SD3.D3_COD     = '"+cCodPrd+ "' "
	cQuery += "   AND SD3.D3_ESTORNO = 'S' "
	cQuery += "   AND SD3.D3_TM      = '999' "
	cQuery += "   AND SD3.D_E_L_E_T_ = ' ' "
	cQuery += "   AND EXISTS ( SELECT 'TRANSF' "
	cQuery += "  			     FROM "+RetSqlName("SD3")+" TRF (NOLOCK) "
	cQuery += "   				WHERE TRF.D3_FILIAL  = SD3.D3_FILIAL "
	cQuery += "   				  AND TRF.D3_DOC     = SD3.D3_DOC "
	cQuery += "   				  AND TRF.D3_NUMSEQ  = SD3.D3_NUMSEQ "
	cQuery += "   				  AND TRF.D3_COD     <> SD3.D3_COD "
	cQuery += "   				  AND TRF.D3_TM      = '499' "
	cQuery += "   				  AND TRF.D3_ESTORNO = 'S' "
	cQuery += "                   AND TRF.D_E_L_E_T_ = ' ' ) "
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
