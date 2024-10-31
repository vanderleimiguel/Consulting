#include "totvs.ch"
/*/{Protheus.doc} GESTFIN7
	registra as ocorrencias
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function GESTFIN7(cTmp)
	local oModal
	local oContainer

	oModal  := FWDialogModal():New()       
	oModal:SetEscClose(.T.)
	oModal:setTitle("título da Janela ")
	oModal:setSubTitle("SubTitulo da Janela")
		
	oModal:setSize(200, 140)

	oModal:createDialog()
	oModal:addCloseButton(nil, "Fechar")
	oContainer := TPanel():New( ,,, oModal:getPanelMain() )
	oContainer:SetCss("TPanel{background-color : red;}")
	oContainer:Align := CONTROL_ALIGN_ALLCLIENT
		
	TSay():New(1,1,{|| "Teste "},oContainer,,,,,,.T.,,,30,20,,,,,,.T.)
			
	oModal:Activate()
return
