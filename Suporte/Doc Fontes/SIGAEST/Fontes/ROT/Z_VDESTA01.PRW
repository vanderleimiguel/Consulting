#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "TBICONN.CH"

/*/{Protheus.doc} VDESTA01
Cadastro de Rastreabilidade dos Lotes
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User function VDESTA01()

	Local oBrowse   := Nil

	Private aRotina		:= MenuDef()
	Private cCadastro 	:= OemToAnsi("Rastreabilidade dos Lotes")

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias("Z42")
	oBrowse:SetDescription(cCadastro)
	oBrowse:Activate()

Return(.T.)

/*/{Protheus.doc} MenuDef
Menu da rotina de Rastreabilidade dos Lotes
@author TOTVS Protheus
@since 26/07/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function MenuDef()

	Local aRotina 	:= {{ "Pesquisar"	,"AxPesqui"		,0,1},;
		{ "Visualizar"	,"AxVisual"		,0,2},;
		{ "Alterar"		,"AxAltera"		,0,4,}}

Return aRotina
