#include "totvs.ch"
/*/{Protheus.doc} xEMAIL
	envio do boleto por email
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function xEMAIL(cTmp)
	MsgRun("Gerando boletos e enviando ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV		:= (cTmp)->(getArea())
	local cBkp		:= CFILANT
	local lOk		as logical
	local cAssunto	:= "BOLETO"
	local cCorpo	:= getHtml()
	local cPara		as character
	local cCliente	as character
	local lSenha	:= GetMv("FC_BOLPASS",,"2") == "1" // 1=sim;2=nao
	local lAtuMail	:= GetMv("FC_ATUEML",,"1") == "1" // 1=sim;2=nao
	local cCpoMail	:= GetMv("FC_FLDMAIL",,"A1_EMAIL")
	local nOpc		as numeric
	local c2xEnter	:= Chr(13)+Chr(10)+Chr(13)+Chr(10)
	local cNewFile	as character
	
	private oPrint
	
	(cTmp)->(dbSetOrder(2))
	
	if (cTmp)->(dbSeek("T"))
		SA1->( dbSetOrder(RetOrder("SA1","A1_FILIAL+A1_COD+A1_LOJA")) )
		while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
			cCliente := (cTmp)->(E1_CLIENTE+E1_LOJA)
			U_xBOLEXEC((cTmp)->XX_RECNO)

			(cTmp)->(dbSkip())

			if (cTmp)->( Eof() .or. XX_OK == 'F' .or. cCliente != E1_CLIENTE+E1_LOJA )
				SA1->( msSeek(xFilial()+cCliente) )

				cPara := FwInputBox("Informe email "+Alltrim(SA1->A1_NOME),SA1->&cCpoMail)

				if lAtuMail .and. Upper(Alltrim(cPara)) != Upper(Alltrim(SA1->&cCpoMail))
					nOpc := Aviso("Ação","Email diferente do cadastro"+c2xEnter+;
										"Cadastro: "+Lower(Alltrim(SA1->&cCpoMail))+c2xEnter+;
										"Informado: "+Lower(Alltrim(cPara)),{"Atualizar","Adicionar","Cancelar"},2)
					if nOpc == 1
						Reclock("SA1",.F.)
						SA1->&cCpoMail := Lower(Alltrim(cPara))
						SA1->(msUnlock())
					elseif nOpc == 2
						cAux := Lower(Alltrim(SA1->&cCpoMail))+";"+Lower(Alltrim(cPara))
						if Len(cAux) > TamSx3(cCpoMail)[1]
							Alert("nao e possivel adicionar o email informado pois ultrapassa o tamanho do campo")
						else
							Reclock("SA1",.F.)
							SA1->&cCpoMail := Lower(Alltrim(SA1->&cCpoMail))+";"+Lower(Alltrim(cPara))
							SA1->(msUnlock())
						endif
					endif
				endif

				if lSenha .and. MethIsMemberOf(oPrint,"setPassword") // senha sao os 6 primeiros digitos do cpf/cnpj
					oPrint:setPassword(Left(SA1->A1_CGC,6))
				endif
				oPrint:lInJob := .T.
				oPrint:cPathPdf := "C:\Temp\"
				MakeDir(oPrint:cPathPdf)
				oPrint:lServer := .F.
				oPrint:setViewPdf(.F.)
				oPrint:print()

				cNewFile := StrTran(oPrint:cFilePrint,".rel",".pdf")
				CpyT2S("C:\Temp\"+StrTran(oPrint:cFileName,".rel",".pdf"),"/spool/",.T.)

				lOk := U_xEMAIL2(cAssunto, cCorpo, cPara, {cNewFile})
				if lOk
					FwAlertSuccess("boleto enviado com sucesso","Sucesso")
				else
					Alert("erro ao enviar email")
				endif

				FErase(cNewFile) ; FErase(oPrint:cFilePrint) ; FErase("C:\Temp\"+StrTran(oPrint:cFileName,".rel",".pdf"))
				FreeObj(oPrint)
			endif
		end
	endif

	CFILANT := cBkp
	(cTmp)->(restArea(aSv))
return

static function getHtml
	local cHtml := ""
	cHtml += "<html>"
	cHtml += "<body>"
	cHtml += "Prezados,</br>"
	cHtml += "</br>"
	cHtml += "Seguem boletos"
	cHtml += "</body>"
	cHtml += "</html>"
return cHtml

user function xEMAIL2(cAssunto, cCorpo, cPara, aAnexo)
    local nIdx		 as numeric
    local oMsg		 as object
    local oSrv		 as object
    local nRet		 as numeric
    local cFrom		 := GetMv("MV_RELACNT")
    local cUser		 := SubStr(cFrom, 1, At('@', cFrom)-1)
    local cPass		 := GetMv("MV_RELPSW")
    local cSrvFull	 := GetMv("MV_RELSERV")
    local cServer	 as character
    local nPort		 as numeric
    local nTimeOut	 := 120
    local cContaAuth := GetMv("MV_RELAUSR")
    local cPassAuth	 := GetMv("MV_RELAPSW")

    default cPara	 := ""
    default cAssunto := ""
    default cCorpo	 := ""
    default aAnexo	 := {}

    if Empty(cPara) .or. Empty(cAssunto) .or. Empty(cCorpo)
        return .F.
    endif

	cServer	:= Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
	nPort	:= Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 587)

	oMsg := tMailMessage():new()
	oMsg:clear()
	oMsg:cFrom    := cFrom
	oMsg:cTo      := cPara
	oMsg:cBCC     := "vinicius.arruda@agrofauna.com.br"
	oMsg:cSubject := cAssunto
	oMsg:cBody    := cCorpo
	oMsg:msgBodyType("text/html")

	for nIdx := 1 To Len(aAnexo)
		if ! File(aAnexo[nIdx]) .or. oMsg:attachFile(aAnexo[nIdx]) != 0
			return .F.
		endif
	next nIdx

	oSrv := tMailManager():new()
	oSrv:setUseTLS(GetMv("MV_RELTLS")) ; oSrv:setUseSSL(GetMv("MV_RELSSL"))

	nRet := oSrv:init("", cServer, cUser, cPass, 0, nPort)
	if nRet != 0
		return .F.
	endif

	oSrv:setSMTPTimeout(nTimeOut)

	nRet := oSrv:smtpConnect()
	if nRet != 0
		return .F.
	EndIf

	if GetMv("MV_RELAUTH")
		nRet := oSrv:smtpAuth(cContaAuth, cPassAuth)
		If nRet != 0
			return .F.
		EndIf
	EndIf

	nRet := oMsg:send(oSrv)
	if nRet != 0
		return .F. // oSrv:GetErrorString(nRet)
	endif

	oSrv:smtpDisconnect()
return .T.
