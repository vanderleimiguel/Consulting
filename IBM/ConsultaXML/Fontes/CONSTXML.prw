#INCLUDE "totvs.ch"

/*/{Protheus.doc} CONSTXML
Função para gerar xml, nfse e envio de email
@author Wagner Neves
@since 09/10/2024
@version 1.0
@type function
/*/
User Function CONSTXML()
    Local aArea         := GetArea()
    Local cQuery        := ""
    Local cAliasSF2     := GetNextAlias()
    Local cDataIni      := SuperGetMv("MV_XNFSE1",.F.,"20240101")
    Private cCaminho    := '/NFSERVICO/'+cfilant
    Private cFileXML    := ""
    Private lJob	    := ( GetRemoteType() == -1 )	// Identifica que não foi iniciado por SMARTCLIENT

	IF lJob
		cEmpInt := "01"
		cFilInt := "01"

		RpcClearEnv()
		RpcSetEnv(cEmpInt,cFilInt)
		CONOUT("["+LEFT(DTOC(Date()),5)+"]["+LEFT(Time(),5)+"][CONSTXML] Iniciando processamento via schedule.")
		nOpca:= 1
    EndIf

    if !ChkFile("SF2")
        If lJob
            ConOut('Tabela SF2 não encontrada')
        Else
            MsgStop('Tabela SF2 não encontrada')
        EndIf
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

    If !ExistBlock("XML_PDF")
        If lJob
            ConOut('Função não compilada XML_PDF')
        Else
            MsgStop('Função não compilada XML_PDF')
        EndIf
		Return
    ENDIF

    If lJob
        //Query busca notas
        cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_CHVNFE, F2_HAUTNFE, F2_XENMAIL "
        cQuery += " FROM "+RetSqlName("SF2") + " SF2 "
        cQuery += " WHERE F2_CHVNFE <> '' "
        cQuery += " AND F2_HAUTNFE <> '' "
        cQuery += " AND F2_XENMAIL <> '1' "
        cQuery += " AND E1_EMISSAO>= '"+cDataIni+"' "
        cQuery += " AND SF2.D_E_L_E_T_=' ' "
        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.F.,.T.)
        (cAliasSF2)->(DbGoTop())

        While (cAliasSF2)->(!Eof())
            SF2->(dbSetOrder(1))
		    If SF2->(dbSeek( (cAliasSF2)->(F2_FILIAL + F2_DOC + F2_SERIE + F2_CLIENTE + F2_LOJA)))
                fProcDocs()
            EndIf
            (cAliasSF2)->(DbSkip())
        EndDo
    Else
        If SF2->(EoF())
            MsgStop('Não está posicionado em uma NF')
            Return
        EndIf

        fProcDocs()
    EndIf

    IF lJob
		RpcClearEnv()
	EndIf

    FWRestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  fProcDocs                                                    |
 | Desc:  Função que processa documentos                               |
 *---------------------------------------------------------------------*/
Static Function fProcDocs()
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

    cDoc    := SF2->F2_DOC
    cSerie  := SF2->F2_SERIE
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
        If lJob
            ConOut('Cliente não encontrado')
        Else
            MsgStop('Cliente não encontrado')
        EndIf
    ENDIF

    if EMPTY( cEmail )
        If lJob
            ConOut('Cliente não tem e-mail')
        Else
            FWAlertWarning('Cliente não tem e-mail')
        EndIf
    ENDIF

    If !Empty(cNumFNSe)
        //Gera XML
        If lJob
            nTipoXML := fGeraXML(cDoc, cSerie, cNomeClien, cCodMun)
        Else
            FwMsgRun( ,{|| nTipoXML := fGeraXML(cDoc, cSerie, cNomeClien, cCodMun) }, , "Gerando XML, por favor aguarde..." )
        EndIf
        //Define se é arquivo xml ou JSON
        If cCodMun <> "3556701"
            cTipoArq := 'XML'
        Else
            cTipoArq := 'JSON'
        EndIf
        
        //Gera PDF
        if file(cFileXML)
            If lJob
                U_XML_PDF(cFileXML, cTipoArq, nTipoXML, cCodMun)
            Else
                FwMsgRun( ,{|| U_XML_PDF(cFileXML, cTipoArq, nTipoXML, cCodMun) }, , "Gerando PDF, por favor aguarde..." )
            EndIf
        else
            If lJob
                ConOut("Arquivo XML não encontrado")
            Else
                MsgStop("Arquivo XML não encontrado") 
            EndIf
            Return
        ENDIF
    else
        If lJob
            ConOut("Nota nao possui numero RPS, nao é possivel gerar XML")
        Else
            MsgStop("Nota nao possui numero RPS, nao é possivel gerar XML") 
        EndIf
        Return
    ENDIF

    cArquivPDF  := 'C:\TEMP\NFSERVICO\'+cFilAnt+'\PDF\' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.pdf'
    if file(cArquivPDF)

        if file(cCaminho + '/PDF/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.pdf')
            FErase(cCaminho + '/PDF/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.pdf')
        ENDIF

        //Copia arquivos para servidor
        __CopyFile(cArquivPDF, cCaminho + '/PDF/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.pdf')
        If cTipoArq = 'XML'
            __CopyFile(cFileXML  , cCaminho + '/XML/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.xml')
        Else
            __CopyFile(cFileXML  , cCaminho + '/JSON/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien +'.json')
        EndIf

        cArquivPDF := cCaminho + '/PDF/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien
        If cTipoArq = 'XML'
            cArquivXML := cCaminho + '/XML/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien
        Else
            cArquivXML := cCaminho + '/JSON/' + cFilAnt + "_" + AllTrim(cDoc) + '_'  + cNomeClien
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

            //Verifica se esta em modo teste
            If GetMv("MV_XNFSE2")
                cEmail := Alltrim(GetMv("MV_XNFSE3"))
            Endif
            cAssunto := "IBM Filial " +AllTrim(cFilNome)+ " NFS-e: " + cNumFNSe  
            If lJob
                lEnvio := U_ENV_NFSE(cEmail, cArquivXML, cArquivPDF, cAssunto, cHtml, cTipoArq)
            Else
                FwMsgRun( ,{|| lEnvio := U_ENV_NFSE(cEmail, cArquivXML, cArquivPDF, cAssunto, cHtml, cTipoArq) }, , "Enviando e-mail, por favor aguarde..." )//VM
            EndIf
        ENDIF

    else
        If lJob
            ConOut("Arquivo PDF não encontrado")
        Else
            MsgStop("Arquivo PDF não encontrado") 
        EndIf
        Return
    ENDIF

    if lEnvio
        If lJob
            ConOut("E-mail enviado para o cliente contendo a NFS-e")
        Else
            FWAlertSuccess("E-mail enviado para o cliente contendo a NFS-e")
        EndIf
    ENDIF

Return

/*---------------------------------------------------------------------*
 | Func:  fGeraXML                                                     |
 | Desc:  Função que gera xml                                          |
 *---------------------------------------------------------------------*/
Static Function fGeraXML(_cDoc, _cSerie, _cNomeClien, _cCodMun)
    Local cXML      := ''
    Local cXmlERP   := ""
    Local _cCaminho := 'C:\TEMP\NFSERVICO\'+cFilAnt
    Local cIdflush  := _cSerie+_cDoc
    Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cIdEnt    := RetIdEnti()
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
                        cFileXML := _cCaminho + '\XML\' + cFilAnt + "_" + AllTrim(_cDoc) + '_'  + _cNomeClien +'.xml'
                    Else
                        cFileXML := _cCaminho + '\JSON\' + cFilAnt + "_" + AllTrim(_cDoc) + '_'  + _cNomeClien +'.json'
                    EndIf

                    if file(cFileXML)
                        FErase(cFileXML)
                    ENDIF                                       
                    nHdl  :=	MsFCreate(cFileXML)
        
                    If ( nHdl >= 0 )
                        If !Empty(cXml) .AND. _cCodMun <> "1302603" .AND. _cCodMun <> "3556701" .AND. _cCodMun <> "1501402";
                        .AND. _cCodMun <> "3547304" .AND. _cCodMun <> "2111300" .AND. _cCodMun <> "3509502"
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

	FreeObj(oWS)
	oWS := nil
	delClassIntF()
    
Return nRet
