#INCLUDE "totvs.ch"

/*/{Protheus.doc} User Function nomeFunction
    (long_description)
    @type  Function
    @author Victor David
    @since 01/06/2024
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function CONSTXML()
    Local cXML          := ''
    Local cURLPost      := ''
    Local cAction       := ''
    Local cError        := ''
    Local cWarning      := ''
    Local cXMLRet       := ''
    Local cJsonRet      := ''
    Local cEnvelopIn    := ''
    Local cEnvelopFi    := ''
    Local cCaminho      := '/NFSERVICO'
    Local cSoap         := ''
    Local cArquivXML    := ''
    Local cArquivPDF    := ''
    Local cEmail        := ''
    Local lEnvio        := .F.
    Local cCopXMLRet    := ''
    Local cDoc := ''
    Local cNomeClien := ''
    Local lCertif := .F.
    Local aCertif := {}
    Local cMsgAlerta := ''
    Local cMetodo := ''
    Local cTipoArq := ''
    Local cArqJson := ''
    Local cArquivo := ''
    Local lHml     := .T.
    Local oJson    := NIL

    if !ChkFile("SF2")
        MsgStop('Tabela SF2 não encontrada')
		Return
    ENDIF

    IF !file(cCaminho)
        MAKEDIR( cCaminho )
    ENDIF

    IF !file(cCaminho + '/JSON')
        MAKEDIR( cCaminho + '/JSON')
    ENDIF

    IF !file(cCaminho + '/XML')
        MAKEDIR( cCaminho + '/XML')
    ENDIF

    IF !file(cCaminho + '/PDF')
        MAKEDIR( cCaminho + '/PDF')
    ENDIF

    If !ExistBlock("PREFTXML")
        MsgStop('Função não compilada PREFTXML')
		Return
    ENDIF

    If !ExistBlock("XML_PDF")
        MsgStop('Função não compilada XML_PDF')
		Return
    ENDIF

    If SF2->(EoF())
        MsgStop('Não está posicionado em uma NF')
		Return
    EndIf

    cDoc := ALLTRIM( SF2->F2_DOC )
    SA1->(DBSETORDER( 1 ))
    if SA1->(DBSEEK( xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA ))
        cNomeClien := ALLTRIM( SA1->A1_NOME )
        cNomeClien := STRTRAN( cNomeClien, ' ', '_' )
        cEmail := ALLTRIM(SA1->A1_EMAIL)
    else
        MsgStop('Cliente não encontrado')
    ENDIF

    if EMPTY( cEmail )
        FWAlertWarning('Cliente não tem e-mail')
    ENDIF

    cXML := U_preftXML(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)

    if cMetodo == 'GET'
        FwMsgRun( ,{|| cJsonRet := execGet(cURLPost, lCertif, aCertif) }, , "Conectando ao WebService da Prefeitura, por favor aguarde..." )
    elseif cMetodo == 'POST'
        cSoap = cEnvelopIn + cXML + cEnvelopFi
        FwMsgRun( ,{|| cXMLRet := execPost(cURLPost, cAction, cSoap, lCertif, aCertif) }, , "Conectando ao WebService da Prefeitura, por favor aguarde..." )
    else
        MSGSTOP('Método não identificado')
        Return
    ENDIF

    IF !EMPTY( cJsonRet )

        oJson   := JsonObject():New()
		cError  := oJson:FromJson(cJsonRet)

        if !EMPTY( cError )
            MsgStop("Falha ao gerar Objeto JSON resposta: " + cError)
            Return
        endif

        if !EMPTY(oJson['message'])
            MsgStop(oJson['message'])
            Return
        endif

        cArqJson  := cCaminho + '/JSON/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.json'
        MemoWrite(cArqJson, cJsonRet)
        cArquivo := cArqJson
        cTipoArq := 'JSON'

    elseif !EMPTY( cXMLRet )

        cCopXMLRet := cXMLRet
        If At('FAULTSTRING>', Upper(cXMLRet)) > 0
            cMsgAlerta := SUBSTR(cXMLRet, 13 + At("<faultstring>",cXMLRet),At("</faultstring>",cXMLRet) - At("<faultstring>",cXMLRet) - 13)
            FWAlertWarning(cMsgAlerta)
            Return
        ENDIF

        If At('&LT;MENSAGEM&GT;', Upper(cXMLRet)) > 0
            cMsgAlerta := DECODEUTF8(SUBSTR(cXMLRet, 16 + At("&lt;Mensagem&gt;",cXMLRet),At("&lt;/Mensagem&gt;",cXMLRet) - At("&lt;Mensagem&gt;",cXMLRet) - 16))
            FWAlertWarning(cMsgAlerta)
            Return
        ENDIF

        oXML := XmlParser(cXMLRet,"_", @cError, @cWarning) // Validar XML
        If (oXml == NIL )
            MsgStop("Falha ao gerar Objeto XML resposta: "+cError+" / "+cWarning)
            Return
        Endif

        cXMLRet := WSAdvValue( oXml, "_SOAP_ENVELOPE:_SOAP_BODY:_NS2_CONSULTARLOTERPSRESPONSE:_RETURN:TEXT","string" )
        if EMPTY(cXMLRet)
            cXMLRet := WSAdvValue( oXml, "_S_ENVELOPE:_S_BODY:_NS2_CONSULTARNFSERESPONSE:_OUTPUTXML:TEXT","string" )
        ENDIF

        if EMPTY(cXMLRet)
            cXMLRet := WSAdvValue( oXml, "_S_ENVELOPE:_S_BODY:_NS2_CONSULTARNFSEPORRPSRESPONSE:_OUTPUTXML:TEXT","string" )
        ENDIF

        If EMPTY(cXMLRet)
            MsgStop("Falha ao ler Objeto XML WSAdvValue")
            Return
        Endif

        oXML := XmlParser(cXMLRet,"_", @cError, @cWarning) // Validar XML
        If (oXml == NIL )
            MsgStop("Falha ao gerar Objeto XML arquivo: "+cError+" / "+cWarning)
            Return
        Endif

        cArquivXML  := cCaminho + '/XML/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.xml'
        MemoWrite(cArquivXML, cXMLRet)
        cArquivo := cArquivXML
        cTipoArq := 'XML'
    else
        FWAlertWarning('Sem resposta de prefeitura')
        Return
    ENDIF


    if file(cArquivo)
        FwMsgRun( ,{|| U_XML_PDF(cArquivo, cTipoArq) }, , "Gerando PDF, por favor aguarde..." )
    else
        MsgStop("Arquivo XML não encontrado")
		Return
    ENDIF

    cArquivPDF  := 'C:\TEMP\NFSERVICO\PDF\' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf'
    if file(cArquivPDF)

        if file(cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')
            FErase(cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')
        ENDIF

        __CopyFile(cArquivPDF, cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')

        cArquivPDF := cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf'
        if file(cArquivPDF)
            FwMsgRun( ,{|| lEnvio := U_ENV_NFSE(cEmail, cArquivo, cArquivPDF) }, , "Enviando e-mail, por favor aguarde..." )
        ENDIF

    else
        MsgStop("Arquivo PDF não encontrado")
		Return
    ENDIF

    if lEnvio
        FWAlertSuccess("E-mail enviado para o cliente contando a NFS-e")
    ENDIF

Return

Static Function execGet(cURLGet, lCertif, aCertif)
    Local nTimeOut := 240
	Local aHeadOut := {}

	Local cHeadRet := ""
	Local cGetRet := ""
	Local nStatus := 0
	Local cStatusMsg := ""
    Local cCertPem := ''
    Local ckeyPem := ''
    Local cCERTPSW := ''

	AAdd( aHeadOut, 'Content-Type: charset=utf-8' )
	AAdd( aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )

    if lCertif
        if len(aCertif) == 3
            cCertPem    := aCertif[1]
            ckeyPem     := aCertif[2]
            cCERTPSW    := aCertif[3]

            if !file(cCertPem)
                MSGSTOP( "Certificado não encontrado" )
            ENDIF

            if !file(ckeyPem)
                MSGSTOP( "Chave do certificado não encontrada" )
            ENDIF

            cGetRet := HTTPSGet( cURLGet, cCertPem, ckeyPem, cCERTPSW , "" , nTimeOut, aHeadOut, @cHeadRet )
            nStatus := HTTPGetStatus(@cStatusMsg)
        ENDIF
    else
	    cGetRet := HTTPQuote( cURLGet, "GET", "", "", nTimeOut, aHeadOut, @cHeadRet)
        nStatus := HTTPGetStatus(@cStatusMsg)
    ENDIF
return cGetRet

Static Function execPost(cURLPost, cAction, cXml, lCertif, aCertif)
	Local nTimeOut := 240
	Local aHeadOut := {}

	Local cHeadRet := ""
	Local cPostRet := ""
	Local nStatus := 0
	Local cStatusMsg := ""
    Local cCertPem := ''
    Local ckeyPem := ''
    Local cCERTPSW := ''

	AAdd( aHeadOut, 'SOAPAction: ' + cAction )
	AAdd( aHeadOut, 'Content-Type: text/xml; charset=utf-8' )
	AAdd( aHeadOut, 'User-Agent: Mozilla/4.0 (compatible; Protheus ' + GetBuild() + ')' )

    if lCertif
        if len(aCertif) == 3
            cCertPem    := aCertif[1]
            ckeyPem     := aCertif[2]
            cCERTPSW    := aCertif[3]

            if !file(cCertPem)
                MSGSTOP( "Certificado não encontrado" )
            ENDIF

            if !file(ckeyPem)
                MSGSTOP( "Chave do certificado não encontrada" )
            ENDIF

            cPostRet := HTTPSPost( cURLPost, cCertPem, ckeyPem, cCERTPSW , "", cXml , nTimeOut, aHeadOut, @cHeadRet )
            nStatus := HTTPGetStatus(@cStatusMsg)
        ENDIF
    else
	    cPostRet := HTTPQuote( cURLPost, "POST", "", cXml, nTimeOut, aHeadOut, @cHeadRet)
        nStatus := HTTPGetStatus(@cStatusMsg)
    ENDIF

    IF nStatus == 10060 //Connection timed out.
		if FWAlertYesNo("A conexão expirou. Deseja tentar novamente?", "Erro: " + cStatusMsg)
			nTimeOut := nTimeOut * 2
			cPostRet := HTTPQuote(cURLPost, "POST", "", cXml, nTimeOut, aHeadOut, @cHeadRet)
    		nStatus := HTTPGetStatus(@cStatusMsg)
		ENDIF
	ENDIF
	
return cPostRet
