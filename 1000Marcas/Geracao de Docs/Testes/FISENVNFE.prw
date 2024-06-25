#include "rwmake.ch"

/*/{Protheus.doc} FISENVNFE
Ponto de entrada executado logo após a transmissão da NF-e
@author Wagner Neves
@since 17/06/2024
@version 1.0
@type function
/*/
User Function FISENVNFE()
	Local aArea 	:= GetArea()
	Local aIdNfe 	:= PARAMIXB
	Local ncont		:= 0

	If Len(aIdNfe) > 0
		For ncont := 1 To Len(aIdNfe[1])
			DbSelectArea("SF2")
			DbSetOrder(1)
			DbSeek(xFilial("SF2")+Subs(aIdNfe[1,ncont],4,9)+Subs(aIdNfe[1,ncont],1,3))
			//Verifica se gravou campos
			If !Empty(SF2->F2_CHVNFE) .AND. !Empty(SF2->F2_HAUTNFE)	
				If ExistBlock("MARDOC01")
					U_MARDOC01(SF2->F2_FILIAL, SF2->F2_DOC,SF2->F2_SERIE)
				EndIf
			EndIf
		Next
	EndIf
	RestArea(aArea)
Return .T.
