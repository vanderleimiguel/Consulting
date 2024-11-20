#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} VDCOMG02
Retorna Custo Médio ou Data Anterior
@author TOTVS Protheus
@since 17/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function VDCOMG02(cXTipo)

	Local aArea		:= GetArea()
	Local aAreaSB1	:= SB1->(GetArea())
	Local xRet		:= Nil
	Local cCodPrd 	:= ""
	Local aDadosCM 	:= {}
	Local nPosDKD	:= 0

	If cXTipo == "1"
		xRet := 0
	Else
		xRet := CtoD("")
	EndIf

	If AllTrim(ReadVar()) == "M->D1_COD"
		cCodPrd := M->D1_COD
		aDadosCM := VDRecnoSD1(cCodPrd)
		If Len(aDadosCM) > 0
			If cXTipo == "1"
				xRet := aDadosCM[1]
				nPosDKD	:= GdFieldPos("DKD_ZZCMAN",aHeadDKD)
				If nPosDKD > 0
					oGetDKD:aCols[oGetDKD:nAt,nPosDKD] := aDadosCM[1]
					oGetDKD:Refresh()
					oGetDKD:oBrowse:Refresh()
				Endif
			Else
				xRet := aDadosCM[2]
				nPosDKD	:= GdFieldPos("DKD_ZZDTAN",aHeadDKD)
				If nPosDKD > 0
					oGetDKD:aCols[oGetDKD:nAt,nPosDKD] := aDadosCM[2]
					oGetDKD:Refresh()
					oGetDKD:oBrowse:Refresh()
				Endif
			EndIf
		EndIf
	EndIf

	RestArea(aArea)
	RestArea(aAreaSB1)

Return(xRet)

/*/{Protheus.doc} VDRecnoSD1
Busca recno na SD1 e retorna custo e data de emissao
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function VDRecnoSD1(cXCodPrd)

	Local aArea		:= GetArea()
	Local cQuery 	:= ""
	Local cAliasQry	:= ""
	Local aRet		:= {}

	cQuery := "SELECT TOP 1 SD1.R_E_C_N_O_ AS RECSD1 "
	cQuery += "  FROM "+RetSqlName("SD1")+" SD1 (NOLOCK) "
	cQuery += " WHERE SD1.D1_FILIAL  = '"+xFilial("SD1")+ "' "
	cQuery += "   AND SD1.D1_COD     = '"+cXCodPrd+ "' "
	cQuery += "   AND SD1.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY SD1.D1_EMISSAO DESC "
	cQuery := ChangeQuery(cQuery)

	cAliasQry := MPSysOpenQuery(cQuery)

	DbSelectArea(cAliasQry)
	(cAliasQry)->(DbGoTop())
	If (cAliasQry)->RECSD1 > 0
		DbSelectArea("SD1")
		SD1->(DbGoTo((cAliasQry)->RECSD1))
		aAdd(aRet,SD1->D1_CUSTO)
		aAdd(aRet,SD1->D1_EMISSAO)
	EndIf

	If Select(cAliasQry)>0
		(cAliasQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)

Return(aRet)
