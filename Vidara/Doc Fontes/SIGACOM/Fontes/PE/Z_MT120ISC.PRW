#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT120ISC
Ponto de entrada Manipula o acols do pedido de compras MATA120 - PEDIDO DE COMPRA
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT120ISC()

	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local nRecSA5	:= 0
	Local cCodPrd	:= ""
	Local cCodFor 	:= ""
	Local cLojFor 	:= ""
	Local nPCodPrd 	:= 0
	Local nPSegUM	:= 0

	nPCodPrd := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
	nPSegUM  := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_SEGUM"})
	If nPCodPrd > 0 .And. nPSegUM > 0

		cCodPrd := aCols[n][nPCodPrd]
		nRecSB1 := VDRecnoSB1(cCodPrd)
		If nRecSB1 > 0

			DbSelectArea("SB1")
			SB1->(DbGoTo(nRecSB1))

			cCodFor := CA120FORN
			cLojFor := CA120LOJ
			nRecSA5 := VDRecnoSA5(cCodPrd,cCodFor,cLojFor)

			//Verifica se Fornecedor tem a 3ª UM no Cadastro de Produto x Fornecedor
			If nRecSA5 > 0
				DbSelectArea("SA5")
				SA5->(DbGoTo(nRecSA5))
				aCols[n][nPSegUM] := SA5->A5_ZZUNID
			Else
				aCols[n][nPSegUM] := SB1->B1_SEGUM
			EndIf

		EndIf

	EndIf

	RestArea(aArea)
	RestArea(aAreaSB1)

Return

/*/{Protheus.doc} VDRecnoSB1
Retorna Recno do Cadastro de Produto
@author TOTVS Protheus
@since 26/06/2024
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
	cQuery += "   AND SB1.B1_COD     = '"+cXCodPrd+ "' "
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

/*/{Protheus.doc} VDRecnoSA5
Retorna Recno da amarracao produto x fornecedor
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSA5(cXCodPrd,cXCodFor,cXLojFor)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local nRet		:= 0

	cQuery := "SELECT SA5.R_E_C_N_O_ AS RECSA5 "
	cQuery += "  FROM "+RetSqlName("SA5")+" SA5 (NOLOCK) "
	cQuery += " WHERE SA5.A5_FILIAL  = '"+xFilial("SA5")+ "' "
	cQuery += "   AND SA5.A5_PRODUTO = '"+cXCodPrd+ "' "
	cQuery += "   AND SA5.A5_FORNECE = '"+cXCodFor+ "' "
	cQuery += "   AND SA5.A5_LOJA    = '"+cXLojFor+ "' "
	cQuery += "   AND SA5.A5_ZZUNID  <> '"+Space(TamSX3("A5_ZZUNID")[1])+ "' "
	cQuery += "   AND SA5.A5_ZZCONV  > 0 "
	cQuery += "   AND SA5.A5_ZZTPCON <> '"+Space(TamSX3("A5_ZZTPCON")[1])+ "' "
	cQuery += "   AND SA5.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSA5 > 0
		nRet := (cAliasQry)->RECSA5
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(nRet)
