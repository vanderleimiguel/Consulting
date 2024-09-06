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
    Local cCaminho      := '/NFSERVICO/'+cfilant
    Local cArquivXML    := ''
    Local cArquivPDF    := ''
    Local cEmail        := ''
    Local lEnvio        := .F.
    Local cDoc          := ''
    Local cNomeClien    := ''
    Local cTipoArq      := ''
    Local nTipoXML      := 0
    Local cCodMun       := ""
    Local cChvNFE       := ""
    Local cNumFNSe      := ""
	Local cCodVerf      := ""
    Local cAssunto      := ""
    Local cFilNome      := ""
    Local cHtml         := ""
    Private cFileXML    := ""

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

    // If !ExistBlock("PREFTXML")
    //     MsgStop('Função não compilada PREFTXML')
	// 	Return
    // ENDIF

    If !ExistBlock("XML_PDF")
        MsgStop('Função não compilada XML_PDF')
		Return
    ENDIF

    If SF2->(EoF())
        MsgStop('Não está posicionado em uma NF')
		Return
    EndIf

    cDoc    := ALLTRIM( SF2->F2_DOC )
    cSerie  := ALLTRIM( SF2->F2_SERIE )
    cCodMun := SM0->M0_CODMUN
    cChvNFE := SF2->F2_CHVNFE
	cNumFNSe    := AllTrim(SF2->F2_NFELETR)
	cCodVerf    := AllTrim(SF2->F2_CODNFE)
    SA1->(DBSETORDER( 1 ))
    if SA1->(DBSEEK( xFilial('SA1') + SF2->F2_CLIENTE + SF2->F2_LOJA ))
        cNomeClien  := ALLTRIM( SA1->A1_NOME )
        cNomeClien  := STRTRAN( cNomeClien, ' ', '_' )
        cNomeClien  := STRTRAN( cNomeClien, '/', '_' )
        cNomeClien  := STRTRAN( cNomeClien, '.', '_' )
        cEmail      := ALLTRIM(SA1->A1_EMAIL)
    else
        MsgStop('Cliente não encontrado')
    ENDIF

    if EMPTY( cEmail )
        FWAlertWarning('Cliente não tem e-mail')
    ENDIF

    If !Empty(cNumFNSe)
        //Gera XML
        FwMsgRun( ,{|| nTipoXML := fGeraXML(cDoc, cSerie, cNomeClien, cCodMun) }, , "Gerando XML, por favor aguarde..." )
        //Define se é arquivo xml ou JSON
        If cCodMun <> "3556701"
            cTipoArq := 'XML'
        Else
            cTipoArq := 'JSON'
        EndIf
        
        //Gera PDF
        if file(cFileXML)
            FwMsgRun( ,{|| U_XML_PDF(cFileXML, cTipoArq, nTipoXML, cCodMun) }, , "Gerando PDF, por favor aguarde..." )
        else
            MsgStop("Arquivo XML não encontrado") 
            Return
        ENDIF
    else
        MsgStop("Nota nao possui numero RPS, nao é possivel gerar XML") 
        Return
    ENDIF

    cArquivPDF  := 'C:\TEMP\NFSERVICO\'+cFilAnt+'\PDF\' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf'
    if file(cArquivPDF)

        if file(cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')
            FErase(cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')
        ENDIF

        //Copia arquivos para servidor
        __CopyFile(cArquivPDF, cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.pdf')
        If cTipoArq = 'XML'
            __CopyFile(cFileXML  , cCaminho + '/XML/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.xml')
        Else
            __CopyFile(cFileXML  , cCaminho + '/JSON/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien +'.json')
        EndIf

        cArquivPDF := cCaminho + '/PDF/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien
        If cTipoArq = 'XML'
            cArquivXML := cCaminho + '/XML/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien
        Else
            cArquivXML := cCaminho + '/JSON/' + cFilAnt + "_" + cDoc + '_'  + cNomeClien
        EndIf

        if file(cArquivPDF + ".pdf")
            cFilNome := FwFilialName( cEmpAnt, cFilAnt, 1 )
            //Gera HTML
            cHtml   := '<body>'
            cHtml   += '<table width="100%" border="0"> '
            cHtml   += ' <br>'
            cHtml   += '  <tr>'
            cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em anexo segue xml e NFS-e</font></td>'
            cHtml   += '  </tr>'
            cHtml   += '<table width="100%" border="0"> '
            cHtml   += ' <br>'
            cHtml   += '  <tr>'
            cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
            cHtml   += '  </tr>'
            cHtml   += ' <br>'
            cHtml   += '  <tr>'
            cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">IBM Filial '+cFilNome+'</font></td>'
            cHtml   += '  </tr>'
            cHtml   += ' <br>'
            cHtml   += '</table>'

            cEmail := "vanderleimiguel@hotmail.com"//VM
            cAssunto := "IBM Filial " +AllTrim(cFilNome)+ " NFS-e: " + cNumFNSe  
            FwMsgRun( ,{|| lEnvio := U_ENV_NFSE(cEmail, cArquivXML, cArquivPDF, cAssunto, cHtml, cTipoArq) }, , "Enviando e-mail, por favor aguarde..." )//VM
        ENDIF

    else
        MsgStop("Arquivo PDF não encontrado")
		Return
    ENDIF

    if lEnvio
        FWAlertSuccess("E-mail enviado para o cliente contando a NFS-e")
    ENDIF

Return

Static Function fGeraXML(_cDoc, _cSerie, _cNomeClien, _cCodMun)
    Local cXML      := ''
    Local cXmlERP   := ""
    Local _cCaminho := 'C:\TEMP\NFSERVICO\'+cFilAnt
    Local cIdflush  := _cSerie+_cDoc
    Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cIdEnt    := RetIdEnti() //GetIdEnt()
    Local nHdl 	    := 0
    Local nRet      := 0

    IF !file('C:\TEMP')
        MAKEDIR( 'C:\TEMP' )
    ENDIF

    IF !file(_cCaminho)
        MAKEDIR( _cCaminho )
    ENDIF

    IF !file(_cCaminho + '/XML')
        MAKEDIR( _cCaminho + '/XML')
    ENDIF

    IF !file(_cCaminho + '/PDF')
        MAKEDIR( _cCaminho + '/PDF')
    ENDIF

    IF !file(_cCaminho + '/JSON')
        MAKEDIR( _cCaminho + '/JSON')
    ENDIF

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Inicia processamento                                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    If !Empty(_cDoc)
              
        oWS := WsNFSE001():New()
        oWS:cUSERTOKEN            := "TOTVS"
        oWS:cID_ENT               := cIdEnt
        oWS:cCodMun               := _cCodMun
        oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
        oWS:nDIASPARAEXCLUSAO     := 0
        oWS:OWSNFSEID:OWSNOTAS    := NFSe001_ARRAYOFNFSESID1():New()
            
        aadd(oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1,NFSE001_NFSES1():New())
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CCODMUN  := _cCodMun
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cID      := cIdflush
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cXML     := " "
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CNFSECANCELADA := " "               
           
        If ExecWSRet(oWS,"RETORNANFSE")
        
            If Len(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5) > 0
            
                cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLPROT)
                cXmlERP := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLERP)
                
                If !Empty(cXml) .OR. !Empty(cXmlERP)
                
                    If _cCodMun <> "3556701"
                        cFileXML := _cCaminho + '\XML\' + cFilAnt + "_" + _cDoc + '_'  + _cNomeClien +'.xml'
                    Else
                        cFileXML := _cCaminho + '\JSON\' + cFilAnt + "_" + _cDoc + '_'  + _cNomeClien +'.json'
                    EndIf

                    if file(cFileXML)
                        FErase(cFileXML)
                    ENDIF                                       
                    nHdl  :=	MsFCreate(cFileXML)
        
                    If ( nHdl >= 0 )
                        If !Empty(cXml) .AND. _cCodMun <> "1302603" .AND. _cCodMun <> "3556701"
                            FWrite (nHdl, cXml)
                            nRet    := 1
                        Else
                            FWrite (nHdl, cXmlERP)
                            nRet    := 2
                        EndIf
                        FClose (nHdl)					
                    EndIf						
                    
                EndIf

                //Tratamento para geração do XML Cancelado.FDL.

                If Type( "oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT" ) <> "U"
                    cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT)
                    cXmlERP := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLERP)
                
                    If !Empty(cXml) .OR. !Empty(cXmlERP)
                    
                        cFileXML := _cCaminho + '\XML\' + cFilAnt + "_" + _cDoc + '_'  + _cNomeClien +'.xml'
                        if file(cFileXML)
                            FErase(cFileXML)
                        ENDIF                
                        nHdl  :=	MsFCreate(cFileXML)
            
                        If ( nHdl >= 0 )
                            If !Empty(cXml)
                                FWrite (nHdl, cXml)
                                nRet    := 1
                            Else
                                FWrite (nHdl, cXmlERP)
                                nRet    := 2
                            EndIf
                            FClose (nHdl)					
                         EndIf						
                    EndIf
                EndIf	
            EndIf
        EndIf       
       
    EndIf	

	FreeObj(oWS)
	oWS := nil
	delClassIntF()
    
Return nRet
