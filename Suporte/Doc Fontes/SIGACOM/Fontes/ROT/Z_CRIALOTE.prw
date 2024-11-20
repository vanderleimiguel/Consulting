#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} Z_CRIALOTE
Ponto de entrada Manipula o acols do pedido de compras MATA120 - PEDIDO DE COMPRA
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_CRIALOTE()

	Local cNumlote  := ""
	Local cProxLote := Alltrim(GetMV('ZZ_PRXLOTC'))
	Local cCodEstFi := Alltrim(GetMV('ZZ_CODESTF'))
	Local lachou    := .F.

	cAnoLote := ""
	cSemLote := ""
	cSeqLote := ""

	cSemana:= RETSEM(DDATABASE)
	cAno:= substr(cvaltochar(Year(DDATABASE)),3,2)
	cSeq:=substr(cProxLote,5,3)

	SBZ->(dbSeek(FwxFilial("SB1") + SD1->D1_COD))
	IF SBZ->BZ_ZZDRV == '1'
		IF !Empty(SD1->D1_TPESTR) .AND. SD1->D1_TPESTR $ cCodEstFi
			lachou := U_Z_BusLote(SD1->D1_COD,SD1->D1_LOTEFOR,SD1->D1_DTVALID)
		Endif
	Endif

	If cAno == substr(cProxLote,1,2)
		cAnoLote := substr(cProxLote,1,2)
	Else
		cAnoLote := cAno
	Endif


	If cSemana <= substr(cProxLote,3,2)
		cSemLote:= substr(cProxLote,3,2)
		IF lachou
			cSeqLote:= cSeq
		Else
			cSeqLote := soma1(cSeq)
		Endif
	Else
		cSemLote:=cSemana
		cSeqLote:= "001"
	Endif

	cNumlote := cAnoLote + cSemLote + cSeqLote
	PutMV('ZZ_PRXLOTC',cNumlote)

Return(cNumlote)

/*/{Protheus.doc} Z_BusLote
Verifica se existe lote na SB8
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_BusLote(cCodPro,cLoteFor,dDtValid)

	Local lRet:= .F.
	Local cAliasQry	:= ""
	Local cQuery	:= ""

	cQuery := "SELECT SB8.R_E_C_N_O_ RECB8 "
	cQuery += "  FROM "+RetSqlName("SB8")+" SB8 (NOLOCK) "
	cQuery += " WHERE "
	cQuery += " SB8.D_E_L_E_T_= ' ' "
	cQuery += " AND SB8.B8_PRODUTO = '" + cCodPro + "' "
	cQuery += " AND SB8.B8_LOTEFOR = '" + cLoteFor + "' "
	cQuery += " AND SB8.B8_DTVALID = '" + DtoS(dDtValid) + "' "

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())

	If (cAliasQry)->(!Eof())
		lRet := .T.
	Endif

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf


Return(lRet)
