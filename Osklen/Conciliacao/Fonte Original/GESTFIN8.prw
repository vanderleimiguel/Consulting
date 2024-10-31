#include "totvs.ch"
/*/{Protheus.doc} GESTFIN8
	ajuste das mensagens do email
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFIN8(cTmp)
	local oModal	as object
	local oPanel	as object
	local oMemo		as object
	local oFile		as object
	local aButtons	:= {}
	local cFile		as character
	local cMemo		:= ""
	local cBkp		as character
	local lOk		as logical

	if Type("cCadastro") != "U"
		cBkp := cCadastro
	endif

	cCadastro := "TOTVS"
	lOk := ParamBox({{3,"Tipo Texto",1,{"A Vencer","Vencido"},50,"",.F.}},"Parâmetros")

	if lOk
		oModal := FwDialogModal():New()
		oModal:setEscClose(.T.)
		oModal:setTitle("Configurador Email - "+Iif(MV_PAR01 == 1,"A VENCER","VENCIDOS"))
		oModal:setSize(200,400)
		oModal:createDialog()

		aAdd(aButtons,{,"Gravar Nova Mensagem"	,{|| oModal:deActivate() },"",,.T.,.F.})
		aAdd(aButtons,{,"Variaveis"				,{|| fnVariaveis(oMemo) },"",,.T.,.F.})
		aAdd(aButtons,{,"Fechar sem Salvar"		,{|| lOk := .F. , oModal:deActivate() },"",,.T.,.F.})
		oModal:addButtons(aButtons)

		oPanel := TPanel():new(,,,oModal:getPanelMain())
		oPanel:align := CONTROL_ALIGN_ALLCLIENT

		if MV_PAR01 == 1
			cFile := "/system/texto_email_cobranca_avencer.txt"
		else
			cFile := "/system/texto_email_cobranca_vencido.txt"
		endif

		if File(cFile)
			oFile := FwFileReader():New(cFile)
			if oFile:open()
				while oFile:hasLine()
					cMemo += oFile:getLine()+CRLF
				end
				oFile:close()
			endif
		endif

		oMemo := TMultiGet():New(10, 10, {|u| Iif(PCount() > 0 , cMemo := u, cMemo)}, oPanel)
		oMemo:align := CONTROL_ALIGN_ALLCLIENT

		oModal:activate()

		if lOk
			FErase(cFile)
			MemoWrite(cFile,cMemo)
		endif
	endif

	if cBkp != nil
		cCadastro := cBkp
	endif
	FwFreeArray(aButtons)
return

static function fnVariaveis(oMemo)
	local aItems	:= {'LOGOSUPERIOR=insere a imagem do logo superior da empresa',;
						'LOGOINFERIOR=insere a imagem do logo inferior da empresa',;
						'TITULOS=insere a lista de titulos do cliente',;
						'NOMECLI=insere a razao social do cliente'}
	local cTxt		as character
	local lOk		:= .F.
	local nList		:= 1
	local oDlg		as object
	local oList 	as object
	local bDouble	:= {|| lOk := .T. , oDlg:end() }

	DEFINE DIALOG oDlg TITLE "Variaveis" FROM 365,180 TO 550,700 PIXEL
		oList := TListBox():new(1,1,{|u|if(Pcount()>0,nList:=u,nList)},aItems,100,100,,oDlg,,,,.T.,,bDouble)
		oList:align := CONTROL_ALIGN_ALLCLIENT
	ACTIVATE DIALOG oDlg CENTERED

	if lOk .and. nList > 0
		cTxt := Left(aItems[nList],At("=",aItems[nList])-1)
		oMemo:appendText("##"+cTxt+"##")
		oMemo:refresh()
	endif
	FwFreeArray(aItems) ; FreeObj(oDlg) ; FreeObj(oList)
return
