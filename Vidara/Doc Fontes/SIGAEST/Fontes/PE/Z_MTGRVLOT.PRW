#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MTGRVLOT
Ponto de entrada altera informações do lote - SIGACUSA
@author TOTVS Protheus
@since 24/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MTGRVLOT()

	Local aArea		:= GetArea()
	Local aAreaSB8	:= SB8->(GetArea())
	Local cPrdForn 	:= ""
	Local cLotForn 	:= ""
	Local cNumDoc  	:= ""
	Local cSerDoc  	:= ""
	Local cItemDoc 	:= ""
	Local cCodForn 	:= ""
	Local cLojForn 	:= ""
	Local cCodFabr 	:= ""
	Local cLojFabr 	:= ""
	Local cPrefere 	:= ""
	Local cFilOrig 	:= ""
	Local cOrigem  	:= AllTrim(FunName())
	Local nRecZ42 	:= 0

	//Verifica se vem dos Movimentos Internos Ou Movimentos de Transferencia
	If cOrigem == "MATA241" .Or. cOrigem == "MATA261"
		cFilOrig := SD3->D3_FILIAL
	//Documento de Entrada
	ElseIf AllTrim(FunName()) $ "MATA103"
		cPrdForn := VDProdForn(SB8->B8_PRODUTO,SD1->D1_FORNECE,SD1->D1_LOJA)
		cLotForn := SD1->D1_LOTEFOR
		cNumDoc  := SD1->D1_DOC
		cSerDoc  := SD1->D1_SERIE
		cItemDoc := SD1->D1_ITEM
		cCodForn := SD1->D1_FORNECE
		cLojForn := SD1->D1_LOJA
		cFilOrig := SD1->D1_FILIAL
		//A Gravação do Fabricante é feita no PE MT103FIM porque a DKD ainda não existe neste ponto
		cCodFabr := ""
		cLojFabr := ""
	EndIf

	//Verifica se já existe o registro com a Chave Primária PRODUTO + LOTE na tabela Z42
	nRecZ42 := VDRecnoZ42(SB8->B8_PRODUTO,SB8->B8_LOTECTL)
	If nRecZ42 == 0
		DbSelectArea("Z42")
		Z42->(RecLock("Z42",.T.))
		Z42->Z42_FILIAL	:= xFilial("Z42")
		Z42->Z42_PRODUT	:= SB8->B8_PRODUTO
		Z42->Z42_LOTE  	:= SB8->B8_LOTECTL
		Z42->Z42_CODPRF	:= cPrdForn
		Z42->Z42_LOTEFO	:= cLotForn
		Z42->Z42_DOC 	:= cNumDoc
		Z42->Z42_SERIE 	:= cSerDoc
		Z42->Z42_ITEMNF	:= cItemDoc
		Z42->Z42_FORNEC	:= cCodForn
		Z42->Z42_LOJA 	:= cLojForn
		Z42->Z42_FABRIC	:= cCodFabr
		Z42->Z42_LJFABR	:= cLojFabr
		Z42->Z42_PREFER	:= cPrefere
		Z42->Z42_DTVLD 	:= SB8->B8_DTVALID
		Z42->Z42_DTVLD1	:= CtoD("")
		Z42->Z42_DTVLD2 := CtoD("")
		Z42->Z42_DTVLD3 := CtoD("")
		Z42->Z42_DTVLD4 := CtoD("")
		Z42->Z42_DTVLD5 := CtoD("")
		Z42->Z42_TEOR   := 0
		Z42->Z42_DATA 	:= Date()
		Z42->Z42_HORA  	:= SubStr(Time(),1,8)
		Z42->Z42_FILORI	:= cFilOrig
		Z42->Z42_ORIGEM	:= cOrigem
		Z42->Z42_USER	:= cUserName
		Z42->(MsUnlock())
	EndIf

	RestArea(aArea)
	RestArea(aAreaSB8)

Return

/*/{Protheus.doc} VDProdForn
Retorna Se Existe Cadastro de Produto do Fornecedor
@author TOTVS Protheus
@since 25/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDProdForn(cXCodPrd,cXCodFor,cXLojFor)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local cRet		:= ""

	cQuery := "SELECT SA5.A5_CODPRF "
	cQuery += "  FROM "+RetSqlName("SA5")+" SA5 (NOLOCK) "
	cQuery += " WHERE SA5.A5_FILIAL  = '"+xFilial("SA5")+ "' "
	cQuery += "   AND SA5.A5_PRODUTO = '"+cXCodPrd+ "' "
	cQuery += "   AND SA5.A5_FORNECE = '"+cXCodFor+ "' "
	cQuery += "   AND SA5.A5_LOJA    = '"+cXLojFor+ "' "
	cQuery += "   AND SA5.A5_CODPRF  <> '"+Space(TamSX3("A5_CODPRF")[1])+ "' "
	cQuery += "   AND SA5.D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If !Empty(AllTrim((cAliasQry)->A5_CODPRF))
		cRet := RTrim((cAliasQry)->A5_CODPRF)
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(cRet)

/*/{Protheus.doc} VDRecnoZ42
Retorna Recno da Z42
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
