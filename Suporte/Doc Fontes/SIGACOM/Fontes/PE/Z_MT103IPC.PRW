#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MT103IPC
Ponto de entrada para Atualizar campos customizados no Documento de Entrada MATA103 - DOCUMENTO DE ENTRADA
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT103IPC()
	Local lRet      := .T.
	Local nItemNF	:= ParamIxb[1]
	Local nRecSA5	:= 0
	Local cCodPrd	:= ""
	Local cCodFor 	:= ""
	Local cLojFor 	:= ""
	Local nPCodPrd 	:= 0
	Local nPSegUM	:= 0
	Local nPCodFab  := GdFieldPos("DKD_ZZFABR",aHeadDKD)
	Local nPLojFab  := GdFieldPos("DKD_ZZLJFA",aHeadDKD)
	Local nPprodkd  := GdFieldPos("DKD_CODIGO",aHeadDKD)

	nPCodPrd := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
	nPSegUM  := aScan(aHeader,{|x| AllTrim(x[2]) == "D1_SEGUM"})

	If nPCodPrd > 0 .And. nPSegUM > 0

		cCodPrd := aCols[nItemNF][nPCodPrd]
		nRecSB1 := VDRecnoSB1(cCodPrd)
		If nRecSB1 > 0

			DbSelectArea("SB1")
			SB1->(DbGoTo(nRecSB1))

			cCodFor := cA100For
			cLojFor := cLoja
			nRecSA5 := VDRecnoSA5(cCodPrd,cCodFor,cLojFor)

			//Verifica se Fornecedor tem a 3ª UM no Cadastro de Produto x Fornecedor
			If nRecSA5 > 0
				DbSelectArea("SA5")
				SA5->(DbGoTo(nRecSA5))
				aCols[nItemNF][nPSegUM] := SA5->A5_ZZUNID
			Else
				aCols[nItemNF][nPSegUM] := SB1->B1_SEGUM
			EndIf
		EndIf

	EndIf

	/*
	Busca Cod. Fabricante e Loja do PEdido de Compras
	*/

	aColsDKD[nItemNF,nPcodFab] := SC7->C7_ZZCDFAB
	aColsDKD[nItemNf,nPLojFab] := SC7->C7_ZZLJFAB
	aColsDKD[nItemNf,nPProDKD] := cCodPrd

	oGetDKD:refresh()

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
