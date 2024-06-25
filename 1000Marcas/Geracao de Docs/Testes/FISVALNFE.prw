#include "rwmake.ch"

/*/{Protheus.doc} FISENVNFE
Ponto de entrada executado logo após a transmissão da NF-e
@author Wagner Neves
@since 17/06/2024
@version 1.0
@type function
/*/
User Function FISVALNFE()

	Local _aArea  := GetArea()
	Local _lOk	  := .T.

		_Ret	:= Posicione("SF3",5,PARAMIXB[2]+PARAMIXB[5]+PARAMIXB[4]+PARAMIXB[6]+PARAMIXB[7],"SF3->F3_CHVNFE") <> ""
		If _Ret
			If ExistBlock("MARDOC01")
				U_MARDOC01(SF2->F2_FILIAL, SF2->F2_DOC,SF2->F2_SERIE)
			EndIf
		EndIf

	RestArea(_aArea)

Return(_lOk)

uSER Function  TRANSCIF()
    Local _lOk	  := .T.
Return _lOk
