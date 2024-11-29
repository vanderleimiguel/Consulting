#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TBICODE.CH"
#INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} MTA270MNU
Ponto de Entrada Adiciona botões ao Menu Principal do aviso de recebimento - MATA270 - Digitação do Inventário
@author Totvs
@since 30/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MTA270MNU()

	Local aArea := GetArea()

	aAdd( aRotina, {"Importação CSV" ,"U_VDESTM03()",0,3,,.F.})

	RestArea(aArea)

Return

