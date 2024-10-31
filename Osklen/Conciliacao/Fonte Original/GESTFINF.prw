#include "totvs.ch"
#include 'fwmvcdef.ch'
/*/{Protheus.doc} GESTFINF
	permite realizar manutencao nas moedas
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFINF(cTmp,lBacen)
	local oDlg as object
	local oBrowse as object

	default lBacen := .F.

	if lBacen
		updMoedas()
		return
	endif

	oDlg := FwDialogModal():new()
	oDlg:setCloseButton(.F.)
	oDlg:setEscClose(.F.)
	oDlg:enableAllClient()
	oDlg:nBottom *= 0.7 // diminui em 30% a tela
	oDlg:nRight  *= 0.7 // diminui em 30% a tela
	oDlg:enableFormBar(.F.)
	oDlg:createDialog()

	oBrowse := FwMBrowse():new()
	oBrowse:setAlias("SM2")
	oBrowse:setDescription("Central 4Fin - Moedas")
	oBrowse:setProfileId("MOED")
	oBrowse:setMainProc("U_GESTFINF")
	oBrowse:setMenudef("GESTFINF")
	oBrowse:disableConfig()
	oBrowse:disableReport()
	oBrowse:disableDetails()
	oBrowse:forceQuitButton()
	oBrowse:activate(oDlg:getPanelMain())

	oDlg:activate()
	oBrowse:deActivate() ; FreeObj(oBrowse)
	FreeObj(oDlg)
return

static function MenuDef
	local aRotina := {}
	ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.GESTFINF' OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'		ACTION 'VIEWDEF.GESTFINF' OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.GESTFINF' OPERATION 4 ACCESS 0 
	ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.GESTFINF' OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Bacen'		ACTION 'U_GESTFINF(,.T.)' OPERATION 8 ACCESS 0
return aRotina

static function ModelDef
return FwLoadModel("MATA090")

static function ViewDef
return FwLoadView("MATA090")

static function updMoedas()
	local nInd	as numeric
	local cSeq	as character
	local cMv	as character
	local aBkp	as array
	local aInd	:= {}

	for nInd := 2 To MoedFin()
		cSeq := Str(nInd, IIf(nInd <= 9, 1, 2))
		cMv  := SuperGetMV("MV_MOEBC" + cSeq, , "")
		if ! Empty(cMv)
			aAdd(aInd,cMv)
		endif
	next nInd

	if Len(aInd) > 0
		aBkp := {MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04}
		MV_PAR01 := 1 // 1=true - atualiza caso ja exista na sm2
		MV_PAR02 := 1 // atualizar ontem e hoje (database-mv_par02)
		MV_PAR03 := .F. // soma 1 dia na moeda
		MV_PAR04 := .F. // soma 1 dia no indice
		msgRun("atualizando moedas ...","AGUARDE",{|| FINXTAXA() }) // https://www3.bcb.gov.br/sgspub/
		aEval(aBkp,{|x,y| &("MV_PAR"+Strzero(y,2)) := x  })
		FwFreeArray(aBkp)
	else
		ApMsgInfo("Nao e possivel atualizar as moedas. Verifique os parametros MV_MOEBC**")
	endif

	FwFreeArray(aInd)
return
