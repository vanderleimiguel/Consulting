#include "totvs.ch"
#include 'fwmvcdef.ch'
/*/{Protheus.doc} GESTFIND
	permite realizar manutencao nas naturezas financeiras
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFIND(cTmp)
	local cMsg as character
	local nOpc as numeric
	local oDlg as object
	local oBrowse as object

	cMsg := "Escolha a opção desejada"+CRLF
	cMsg += ""
	nOpc := Aviso("Central 4Fin - Natureza",cMsg,{"Incluir","Visualizar "+Alltrim((cTmp)->E1_NATUREZ),"Listar Todas","Cancelar"},2)

	if nOpc == 1
		FwExecView("Central 4Fin","FINA010",3,,,,30)
	elseif nOpc == 2
		SED->( dbSetOrder(1) )
		SED->( dbSeek(xFilial()+(cTmp)->E1_NATUREZ) )
		FwExecView("Central 4Fin","FINA010",,,,,30)
	elseif nOpc == 3
		oDlg := FwDialogModal():new()
		oDlg:setCloseButton(.F.)
		oDlg:setEscClose(.F.)
		oDlg:enableAllClient()
		oDlg:nBottom *= 0.7 // diminui em 30% a tela
		oDlg:nRight  *= 0.7 // diminui em 30% a tela
		oDlg:enableFormBar(.F.)
		oDlg:createDialog()

		oBrowse := FwMBrowse():new()
		oBrowse:setAlias("SED")
		oBrowse:setDescription("Central 4Fin - Naturezas")
		oBrowse:setProfileId("NAT")
		oBrowse:addLegend("ED_MSBLQL!='1'","BR_VERDE")
		oBrowse:addLegend("ED_MSBLQL=='1'","BR_VERMELHO")
		oBrowse:setMainProc("U_GESTFIND")
		oBrowse:setMenudef("GESTFIND")
		oBrowse:disableConfig()
		oBrowse:disableReport()
		oBrowse:disableDetails()
		oBrowse:forceQuitButton()
		oBrowse:activate(oDlg:getPanelMain())

		oDlg:activate()
		oBrowse:deActivate() ; FreeObj(oBrowse)
		FreeObj(oDlg)
	endif
return

static function MenuDef
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.GESTFIND' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.GESTFIND' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.GESTFIND' OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.GESTFIND' OPERATION 5 ACCESS 0
return aRotina

static function ModelDef
return FwLoadModel("FINA010")

static function ViewDef
return FwLoadView("FINA010")
