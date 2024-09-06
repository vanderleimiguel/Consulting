#INCLUDE "totvs.ch"

User Function ENV_NFSE(cEmail, cArquivXML, cArquivPDF, cAssunto, cHtml, _cTipoArq)
	Local nX     	:= 0
	Local aEmails 	:= {}
    Local cNomeXML  := ''
    Local cNomePDF  := ''
    Local aArquivo  := {}

	If at(",",cEmail) > 0
		aEmails := strtokarr(cEmail, ",")
	ElseIf at(";",cEmail) > 0
		aEmails := strtokarr(cEmail, ";")
    else
        aEmails := {cEmail}
	EndIf
	
    if at('/', cArquivXML) > 0
        aArquivo := strtokarr(cArquivXML, "/")
    elseif at('\', cArquivXML) > 0
        aArquivo := strtokarr(cArquivXML, "\")
    ENDIF

    cNomeXML := aArquivo[len(aArquivo)]
    cNomeXML := REPLACE(cNomeXML, '.', '_')

    if at('/', cArquivPDF) > 0
        aArquivo := strtokarr(cArquivPDF, "/")
    elseif at('\', cArquivPDF) > 0
        aArquivo := strtokarr(cArquivPDF, "\")
    ENDIF

    cNomePDF := aArquivo[len(aArquivo)]
    cNomePDF := REPLACE(cNomePDF, '.', '_')

    For nX := 1 To Len(aEmails)
	    lRet := SendMail(aEmails[nX],cAssunto,cHTML,cArquivXML,cNomeXML,cArquivPDF, cNomePDF, _cTipoArq)
    NEXT

Return lRet

Static Function SendMail(cEmail,cAssunto,cHtml,cPathXML,cFiNameXML,cPathPDF,cFiNamePDF, cTipoArq)
	Local xRet
	Local lRet := .T.
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("FS_EMAIAUT",.F.,.T.) //AUTENTICACAO AUTOMATICA
	Local nPorta    := 587
	Private cMailConta	:= ''
	Private cMailServer	:= ''
	Private cMailSenha	:= ''
	
	cEmail := ALLTRIM( cEmail )
	cMailConta 	:= GETMV("MV_EMCONTA")   //Conta utilizada para envio do email - email@gmail.com
	cMailServer	:= GETMV("MV_RELSERV") 	 //Servidor SMTP - smtp.gmail.com:587
	nPorta 		:= GETMV("MV_PORSMTP")   //Porta do Servidor SMTP
	cMailSenha 	:= GETMV("MV_EMSENHA")   //Senha da conta de e-mail utilizada para envio

	//vm
	cMailConta := "vanderleimigueljr@gmail.com"
	cMailServer:= "smtp.gmail.com:587"
	cMailSenha := "erqj ukzm ygij kpdb"
	
	if at(":", cMailServer) > 0
		nPorta := VAL(SUBSTR( cMailServer, at(":", cMailServer)+1))
		cMailServer := SUBSTR( cMailServer, 1, at(":", cMailServer)-1)
	ENDIF

	IF EMPTY(cMailConta) .OR. EMPTY(cMailServer) .OR. EMPTY(cMailSenha) .OR. EMPTY(nPorta)
		lRet := .F.
		FWAlertWarning("Verifique se os parâmetros de e-mail estão corretos (MV_EMSENHA, MV_RELSERV, MV_PORSMTP, MV_EMCONTA).")
		Return lRet
	ENDIF

	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate	    := cValToChar( Date() )
	oMessage:cFrom 	    := cMailConta
	oMessage:cTo 	    := cEmail
	oMessage:cSubject   := cAssunto

	If UPPER(cTipoArq) = "XML"
		If File(cPathXML + ".xml")
			If oMessage:AttachFile( cPathXML + ".xml" ) < 0  //"\system\file.pdf"
				lRet := .f.
				return lRet
			Else
				//adiciona uma tag informando que é um attach e o nome do arq
				oMessage:AddAtthTag('Content-Disposition: attachment; filename='+cFiNameXML + ".xml")
			EndIf
		Else
			lRet := .f.
			return lRet
		EndIf
	Else
		If File(cPathXML + ".json")
			If oMessage:AttachFile( cPathXML + ".json" ) < 0  //"\system\file.pdf"
				lRet := .f.
				return lRet
			Else
				//adiciona uma tag informando que é um attach e o nome do arq
				oMessage:AddAtthTag('Content-Disposition: attachment; filename='+cFiNameXML + ".json")
			EndIf
		Else
			lRet := .f.
			return lRet
		EndIf
	EndIf

    If File(cPathPDF + ".pdf")
		If oMessage:AttachFile( cPathPDF + ".pdf" ) < 0  //"\system\file.pdf"
			lRet := .f.
		    return lRet
		Else
			//adiciona uma tag informando que é um attach e o nome do arq
			oMessage:AddAtthTag('Content-Disposition: attachment; filename='+cFiNamePDF + ".pdf")
		EndIf
	Else
		lRet := .f.
		return lRet
	EndIf

	oMessage:cBody      := cHtml
	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)

	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		FWAlertWarning("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ))
		lRet := .f.
		return lRet
	endif

	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		FWAlertWarning("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
		lRet := .f.
        return lRet
	endif

	xRet := oServer:SMTPConnect()
	if xRet <> 0
		FWAlertWarning("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		lRet := .f.
		return lRet
	endif


	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do
		//usuário no servidor de e-mail, verifica a configuração
		//da chave AuthSmtp, na seção [Mail], no arquivo de
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			FWAlertWarning("Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet ))
			oServer:SMTPDisconnect()
			lRet := .f.
			return lRet
		endif
	Endif

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		FWAlertWarning("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
		lRet := .f.
        return lRet
	endif

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		FWAlertWarning("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		lRet := .f.
        return lRet
	endif

Return lRet
