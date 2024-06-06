#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} EnvMail
Funcao para enviar email
@author Wagner Neves
@since 05/06/2024
@version 1.0
@type function
/*/
User Function EnvMail(cEmail,cAssunto,cHtml)
	Local cMsg := ""
	Local xRet
	Local lRet := .T.
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("FS_EMAIAUT",,.T.)
	Local nPorta    := 587
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL

	cEmail 	:= GETMV("MV_RELFROM")
	cAssunto := "email html"

	cHtml   := '<body>'
	cHtml   += '<table width="100%" border="0"> '
	cHtml   += '  <tr align="center">'
	cHtml   += "   <p><img src=' https://1000marcassafetybrasil.com.br/wp-content/uploads/2020/01/logo-rede-social.png ' width='100' height='100' align='middle' /></p> "
	cHtml   += '  </tr>'
	cHtml   += '</table>'
	cHtml   += ' <br>'
	cHtml   += '<table width="100%" border="0"> '
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Prezado Cliente <strong>CENTRO DE DISTR HORTMIX</strong></font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Vimos por meio desta lembrar que o vencimento da sua Nota Fiscal est� pr�ximo.</font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Estamos enviando a Nota Fiscal elet�nica, XML e o Boleto Banc�rio referente os produtos</font></td>'
	cHtml   += '  </tr>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">adquiridos da 1000Marcas Safety Brasil Ltda.</font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Alternativamento o Boleto Banc�rio poder� estar disponivel em seu DDA, caso possua conv�nio</font></td>'
	cHtml   += '  </tr>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">com seu Banco.</font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de d�vidas ou problemas para realizar o seu pagamento, entre em contato conosco</font></td>'
    cHtml   += '  </tr>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">atrav�s do e-mail financeiro2@1000marcasbrasil.com.br ou</font></td>'
	cHtml   += '  </tr>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">financeiro4@1000marcasbrasil.com.br</font></td>'
	cHtml   += '  </tr>'
	cHtml   += '</table>'
    cHtml   += ' <br>'
	cHtml   += '	<table width="100%" border="1">'
	cHtml   += '<tr align="center" bgcolor="#483D8B">'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>N� T�tulo</strong></font></td>'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Parcela</strong></font></td>'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Emiss�o</strong></font></td>'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Vencimento</strong></font></td>'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Valor</strong></font></td>'
	cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Ordem Compra</strong></font></td>'
	cHtml   += '  </tr>'

		cHtml   += '  <tr align="center">'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">000288710</font></td>'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">001</font></td>'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">17/04/2024</font></td>'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">15/05/2024</font></td>'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">11.730,00</font></td>'
		cHtml   += '    <td><font size="2" face="Arial, Helvetica, sans-serif">C6_PEDCLI</font></td>'
		cHtml   += '  </tr>'
	
	cHtml   += '</table>'
    cHtml   += '<table width="100%" border="0"> '
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda</font></td>'
	cHtml   += '  </tr>'
	cHtml   += ' <br>'
	cHtml   += '  <tr>'
	cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">CNPJ 23.622.391/0001-81</font></td>'
	cHtml   += '  </tr>'
	cHtml   += '</table>'

	cMailConta :=If(EMPTY(cMailConta),GETMV("MV_EMCONTA"),cMailConta)    //Conta utilizada para envio do email
	cMailServer:=If(EMPTY(cMailServer),GETMV("MV_RELSERV"),cMailServer)  //Servidor SMTP - smtp.gmail.com:587
	cMailSenha :=If(EMPTY(cMailSenha),GETMV("MV_EMSENHA"),cMailSenha)    //Senha da conta de e-mail utilizada para envio

	if at(":", cMailServer) > 0
		nPorta := VAL(SUBSTR( cMailServer, at(":", cMailServer)+1))
		cMailServer := SUBSTR( cMailServer, 1, at(":", cMailServer)-1)
	ENDIF

	oMessage:= TMailMessage():New()
	oMessage:Clear()
	oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := cMailConta
	oMessage:cTo 	 := cEmail
	oMessage:cSubject:= cAssunto
	oMessage:cBody := cHtml

	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se ser� utilizar� a comunica��o segura atrav�s de SSL/TLS (.T.) ou n�o (.F.)

	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		CONOUT("O servidor SMTP n�o foi inicializado: " + oServer:GetErrorString( xRet ) )
		lRet := .f.
		return
	endif

	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	if xRet != 0
		CONOUT("N�o foi poss�vel definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
		lRet := .f.
	endif

	xRet := oServer:SMTPConnect()
	if xRet <> 0
		CONOUT("N�o foi poss�vel conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		lRet := .f.
		return
	endif

	if lMailAuth
		//O m�todo SMTPAuth ao tentar realizar a autentica��o do
		//usu�rio no servidor de e-mail, verifica a configura��o
		//da chave AuthSmtp, na se��o [Mail], no arquivo de
		//configura��o (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			CONOUT( cMsg )
			oServer:SMTPDisconnect()
			lRet := .f.
			return
		endif
	Endif

	xRet := oMessage:Send( oServer )
	if xRet <> 0
		CONOUT("N�o foi poss�vel enviar mensagem: " + oServer:GetErrorString( xRet ))
		lRet := .f.
	endif

	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		CONOUT("N�o foi poss�vel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		lRet := .f.
	endif

	If (lRet == .T.)
		CONOUT("E-Mail enviado com sucesso para '" + cEmail + "'.","Envio de E-mail")
	EndIf

Return lRet
