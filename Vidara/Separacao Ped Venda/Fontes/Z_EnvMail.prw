#include 'protheus.ch'
#include 'parmtype.ch'

#define	_ENTER	Chr(13)+Chr(10)

/*/{Protheus.doc} Z_EnvMail
Fun็ใo que envia e-mail
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
user function Z_EnvMail(_cFrom,_cTo,_cSubject,cBody,aFiles,_cBcc,_cCc)

   Local lMailAuth   := SuperGetMv("MV_RELAUTH",,.T.)
   Local cMailServer := SuperGetMv("MV_RELSERV",, "")
   Local cMailConta  := SuperGetMV("MV_RELACNT",, "")
   Local cMailSenha  := SuperGetMV("MV_RELPSW" ,, "")
   Local lUseSSL     := SuperGetMV("MV_RELSSL" ,,.F.)
   Local lUseTLS     := SuperGetMV("MV_RELTLS" ,,.F.)
   Local oMail       := NIL
   Local nErro       := 0
   Local cMsgErro    := ""
   Local cUsuario    := SubStr(cMailConta,1,At("@",cMailConta)-1)
   Local oMessage    := NIL
   Local nPort       := 0
   Local nAt         := 0
   Local cServer     := ""
   
   //-- Inicializa Parametros 
   default _cFrom    := SuperGetMV("MV_RELFROM",,"" )
   default _cTo      := ""
   default _cSubject := ""
   default cBody     := ""
   default aFiles    := {}
   default _cBcc	 := ""
   default _cCc		 := ""
   
   private cFrom     := _cFrom
   private cTo       := _cTo
   private cSubject  := _cSubject
   private cBcc	   := _cBcc
   private cCc		   := _cCc
   
   //-- Valida se possui "FROM" 
   If Empty(cFrom)
      If At("@",cMailConta) > 0
         cFrom := cMailConta
      Else
         CONOUT("Remetente nใo definido!")
         Return .F.
      EndIf
   EndIf

   //-- So prossegue se os parametros de conexao SMTP estao definidos
   If !Empty(cMailServer) .AND. !Empty(cMailConta) .AND. !Empty(cMailSenha)
	
      oMail	:= TMailManager():New()
      oMail:SetUseSSL(lUseSSL)
      oMail:SetUseTLS(lUseTLS)
      nAt := At(':' , cMailServer)
	
      // Para autenticacao, a porta deve ser enviada como parametro[nSmtpPort] na chamada do m?odo oMail:Init().
      // A documentacao de TMailManager pode ser consultada por aqui : http://tdn.totvs.com/x/moJXBQ
	  If nAt > 0
         cServer := SubStr(cMailServer,1,nAt-1)
         nPort   := Val(AllTrim(SubStr(cMailServer , (nAt + 1) , Len(cMailServer) )) )
      Else
         cServer := cMailServer
         nPort   := GetNewPar("MV_PORSMTP",25)
      EndIf
	
      //-- Init( < cMailServer >, < cSmtpServer >, < cAccount >, < cPassword >, [ nMailPort ], [ nSmtpPort ] )
      oMail:Init("", cServer, cMailConta, cMailSenha , 0 , nPort)	
	
      nErro := oMail:SMTPConnect()
		
      If ( nErro == 0 )

         If lMailAuth

            // try with account and pass
            nErro := oMail:SMTPAuth(cMailConta, cMailSenha)
			If nErro != 0
               // try with user and pass
               nErro := oMail:SMTPAuth(cUsuario, cMailSenha)
               If nErro != 0
               
                  CONOUT("Falha na conexใo com servidor de e-mail:" + _ENTER + oMail:GetErrorString(nErro) )		
                  Return .F.
               EndIf
            EndIf
         Endif
		
         oMessage := TMailMessage():New()
		
         //Limpa o objeto
         oMessage:Clear()
		
         //Popula com os dados de envio
         oMessage:cFrom 	:= cFrom
         oMessage:cTo 		:= cTo
         oMessage:cCc 		:= cCc
         oMessage:cBcc 		:= cBcc
         oMessage:cSubject := cSubject
         oMessage:cBody 	:= cBody
         
         //-- Adiciona anexos
         For nAt := 1 to Len(aFiles) 
            oMessage:AttachFile( aFiles[nAt] )
         Next nAt

         //Envia o e-mail
         nErro := oMessage:Send( oMail )
         
         If !(nErro == 0)
            cMsgErro := oMail:GetErrorString(nErro)
			CONOUT("Falha no envio do e-mail: " + _ENTER + cMsgErro)
			Return .F.
 		EndIf

		//Desconecta do servidor
		oMail:SmtpDisconnect()
		
		//Msg("E-mail enviado com Sucesso!",.F.)
		Return .T.
		
      Else
	
	     cMsgErro := oMail:GetErrorString(nErro)
		 Msg("Falha na conexใo com servidor de e-mail:" + _ENTER + cMsgErro ,.T.)
		 Return .F.	
		
	  EndIf
	
   Else
      Msg("Parโmetro de conexใo SMTP nใo definidos!",.T.)
      Return .F.
   EndIf

	
return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออปฑฑ
ฑฑบPrograma  ณMSG                                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ Exibicao de msg                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function Msg(cTexto,lErro)

   Local lConsole := IsBlind()												//-- Indica msg via console
   Local cMsg     := ""														//-- Msg Exibida

   //-- Inicializa Parametros 
   default lErro     := .F.
   default cFrom     := ""
   default cTo       := ""
   default cSubject  := ""
   
   If lConsole
      
      //-- Msg via Console
      cMsg := "--[ @ Envio de E-mail ]---------------------------------------------------------"	+ _ENTER
      cMsg += "Empresa/Filial: " + cEmpAnt + "/" + cFilAnt											+ _ENTER
      cMsg += "Data/Hora.....: " + DtoC(Date()) + " - " + Time()									+ _ENTER
      cMsg += "Remetente.....: " + cFrom															+ _ENTER
      cMsg += "Destinatarios.: " + cTo																+ _ENTER
      cMsg += "Assunto.......: " + cSubject															+ _ENTER
      cMsg += "Status........: " + Iif(lErro,"ERRO NO ENVIO","SUCESSO NO ENVIO")					+ _ENTER
      If lErro
         cMsg += NoAcento(cTexto)																	+ _ENTER
      EndIf
      cMsg += "--------------------------------------------------------------------------------"	+ _ENTER
      
      QOUT(cMsg)
   
   Else
   
      //-- Msg via interface ERP
      If lErro
         MsgStop(cTexto)
      Else
         Aviso("Aviso",cTexto,{"Ok"})      
      EndIf
   
   EndIf

Return nil


