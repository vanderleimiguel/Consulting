#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} ACD030MNU
Ponto de Entrada Adiciona botoes no menu principal - ACDA030 - Inventario por produto guiado
@author Totvs
@since 30/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function ACD030MNU()

	Local aArea := GetArea()

	aAdd( aRotina, {"Importação CSV" ,"U_VDESTM01()",0,3,,.F.})

	RestArea(aArea)

Return

