#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VDProcCust
Tratar o cálculo da quantidade nas unidades de medida
@author TOTVS Protheus
@since 18/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function CONVUM()

	Local aArea		:= GetArea()
	Local nQtd1		:= ParamIxb[1]
	Local nQtd2		:= ParamIxb[2]
	Local nUnid  	:= ParamIxb[3]
	Local nBack     := ParamIxb[4]
	Local nRecSA5	:= 0
	Local cCodPrd	:= ""
	Local cCodFor 	:= ""
	Local cLojFor 	:= ""
	Local nPCodPrd 	:= 0

	//Pedido de Compra
	If FunName() == "MATA121"

		nPCodPrd := aScan(aHeader,{|x| AllTrim(x[2]) == "C7_PRODUTO"})
		If nPCodPrd > 0
			cCodPrd := aCols[n][nPCodPrd]
			cCodFor := CA120FORN
			cLojFor := CA120LOJ
			nRecSA5 := VDRecnoSA5(cCodPrd,cCodFor,cLojFor)
		EndIf

	//Pré Nota ou Documento de Entrada 
	ElseIf FunName() == "MATA103" .Or. FunName() == "MATA140"

		nPCodPrd := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
		If nPCodPrd > 0
			cCodPrd := aCols[n][nPCodPrd]
			cCodFor := cA100For
			cLojFor := cLoja
			nRecSA5 := VDRecnoSA5(cCodPrd,cCodFor,cLojFor)
		EndIf

	EndIf

	//Verifica se Fornecedor tem a 3ª UM no Cadastro de Produto x Fornecedor
	If nRecSA5 > 0

		DbSelectArea("SA5")
		SA5->(DbGoTo(nRecSA5))

		If ( SA5->A5_ZZTPCON != "D" )
			If ( nUnid == 1 )
				nBack := (nQtd2 / SA5->A5_ZZCONV)
			Else
				nBack := (nQtd1 * SA5->A5_ZZCONV)
			EndIf
		Else
			If ( nUnid == 1 )
				nBack := (nQtd2 * SA5->A5_ZZCONV)
			Else
				nBack := (nQtd1 / SA5->A5_ZZCONV)
			EndIf
		EndIf

	EndIf

	RestArea(aArea)

Return(nBack)

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
