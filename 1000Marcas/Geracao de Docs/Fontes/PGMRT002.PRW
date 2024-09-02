#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "topconn.ch"
#include "rwmake.ch"
#include "ap5mail.ch"

/*/{Protheus.doc} PGMRT002
Função de envio de email
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/
User Function PGMRT002(cEmailDe,cEmail,cAssunto,cHtml,cArquivo,cTipoMod,aAnexos)
	Local cMsg 			:= " "
	Local xRet
	Local lRet 			:= .T.
	Local oServer, oMessage
	Local lMailAuth		:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta    	:= VAL(RIGHT(ALLTRIM(GETMV("MV_RELSERV")),3))
	Local nX
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL

	If IsBlind()
		lJob := .T.
	Else
		lJob := .F.
	Endif
	cMailConta  :=If(cMailConta  == NIL,GETMV("MV_EMCONTA"),cMailConta)             //Conta utilizada para envio do email -suportetecnico@1000marcasbrasil.com.br
	cMailSenha  :=If(cMailSenha  == NIL,GETMV("MV_EMSENHA"),cMailSenha)             //Senha da conta de e-mail utilizada para envio
	IF ! GetMv("MV_ZWFCOB")
		cMailServer :=If(cMailServer == NIL,"mail.1000marcasbrasil.com.br",cMailServer) //Servidor SMTP - mail.1000marcasbrasil.com.br:587
	Else
		cMailServer :=If(cMailServer == NIL,"smtp.terra.com.br",cMailServer) //Servidor SMTP - mail.1000marcasbrasil.com.br:587
	EndIf

	//vm
	cMailConta := "vanderleimigueljr@gmail.com"
	cMailServer:= "smtp.gmail.com"
	cMailSenha := "erqj ukzm ygij kpdb"
	nPorta     := 587
	
	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate	 	:= cValToChar( Date() )
	oMessage:cFrom 	 	:= cMailConta
	oMessage:cTo 	 	:= cEmail
	oMessage:cSubject	:= cAssunto
	oMessage:cBody 		:= cHtml
	If !Empty(cArquivo)
		oMessage:AttachFile( cArquivo )
	Else
		For nX = 1 to len(aAnexos)
			oMessage:AttachFile( aAnexos[nX] )
		Next nX
	EndIf

	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		If lJob
			CONOUT("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		Else
			MsgAlert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )		
		EndIf
		lRet := .f.
		return
	endif
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		If lJob
			CONOUT("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ) )
		Else
			MsgAlert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))		
		EndIf
		lRet := .f.
	endif

	xRet := oServer:SMTPConnect()
	if xRet <> 0
		If lJob
			CONOUT("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		Else
			MsgAlert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		EndIf
		lRet := .f.
		return
	endif

	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do
		//usuário no servidor de e-mail, verifica a configuração
		//da chave AuthSmtp, na seção [Mail], no arquivo de
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			If lJob
				CONOUT( cMsg )
			Else
				MsgAlert( cMsg )
			EndIf
			oServer:SMTPDisconnect()
			lRet := .f.
			return
		endif
	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0
		If lJob
			CONOUT("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
		Else
			MsgAlert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
		EndIf
		lRet := .f.
	EndIf

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		If lJob
			CONOUT("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		Else
			MsgAlert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		EndIf
		lRet := .f.
	endif

	If lRet .And. cTipoMod=='4'
		If lJob
			CONOUT("E-mail enviado com sucesso")
		Else
			FWAlertSuccess("E-Mail enviado com sucesso.","E-Mail")
		EndIf
	EndIf

Return lRet
