#INCLUDE "totvs.ch"

/*/{Protheus.doc} User Function prefeitura
    (long_description)
    @type  Function
    @author Wagner Neves
    @since 01/06/2024
    @version 1.0
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function PREFTXML(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cRet := ''
    Local cPathPfx := '/certificado digital/certificado ibm 2023-2024.pfx'
    Local cPathPem := ''
    Local cPathKey := ''
    Local cPassword := 'ibmfiscalops1'
    Local cError := ''
    Local cCodMunic := SM0->M0_CODMUN

    IF !file('/certificado digital')
        MAKEDIR( '/certificado digital' )
    ENDIF

    if !EMPTY( SM0->M0_CGC ) .AND. !EMPTY( SM0->M0_INSCM )
        lHml := .F.
    endif

    if EMPTY( cPassword )
        cPassword := FWInputBox("Insira a senha do certificado:", cPassword)
    ENDIF

    if EMPTY( cCodMunic )
        FWAlertWarning('Código do munício não identificado')
        Return cRet
    else
        do case
            case cCodMunic == '3506003'
                //Bauru
                cRet = BR_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '1501402'
                //Belém qual ?
                cRet = BL_PA(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3106200'
                //Belo Horizonte
                cRet = BH_MG(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '5300108'
                //Brasilia
                cRet = BR_DF(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3509502'
                //Campinas
                cRet = CP_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '5103403'
                //Cuiabá
                cRet = CB_MT(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '4106902'
                //Curitiba
                cRet = CT_PR(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '4205407'
                //Florianópolis
                cRet = FL_SC(lHml, @cURLPost, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '2304400'
                //Fortaleza
                cRet = FT_CE(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '5208707'
                //Goiânia
                cRet = GN_GO(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3519071'
                //Hortolândia
                cRet = HO_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3525904'
                //Jundiaí
                cRet = JD_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '1302603'
                //Manaus
                cRet = MU_AM(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '2111300'
                //São Luís
                cRet = SL_MA(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '4115200'
                //Maringá
                cRet = MG_PR(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3530805'
                //Mogi Mirim
                cRet = MM_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3534401'
                //Osasco
                cRet = OC_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '4314902'
                //Porto Alegre
                cRet = PA_RS(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '2611606'
                //Recife
                cRet = RF_PE(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3304557'
                //Rio de Janeiro
                cRet = RJ_RJ(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3549805'
                //São José do Rio Preto
                cRet = SJ_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '2927408'
                //Salvador
                cRet = SD_BH(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3547304'
                //Santana de Parnaíba
                cRet = ST_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3548708'
                //São Bernardo do Campo
                cRet = SB_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3550308'
                //São Paulo
                cRet = SP_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3205200'
                //Vila Velha
                cRet = VV_ES(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3556701'
                //Vinhedo
                cRet = VD_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            otherwise
                FWAlertWarning('Código do munício '+cCodMunic+' não está na lista de consultas')
		endCase
    ENDIF

    if lCertif .AND. EMPTY( aCertif )
        if file(cPathPfx)

            cPathPem := REPLACE(cPathPfx, '.pfx', '_cert.pem')
            if !file(cPathPem)
                if !PFXCert2PEM( cPathPfx, cPathPem, @cError, cPassword )
                    MSGSTOP(cError, "Erro ao extrair certificado de autorização" )
                ENDIF
            ENDIF

            cPathKey := REPLACE(cPathPfx, '.pfx', '_key.pem')
            if !file(cPathKey)
                if !PFXKey2PEM( cPathPfx, cPathKey, @cError, cPassword )
                    MSGSTOP(cError, "Erro ao extrair a chave privada do arquivo" )
                ENDIF
            ENDIF

            aCertif := {cPathPem, cPathKey, cPassword}

        else
            FWAlertWarning( "Certificado PFX não encontrado em:" + CRLF + 'Protheus_Data' + cPathPfx)
            Return cXML
        ENDIF
    ENDIF
    
Return cRet

Static Function TG_RJ(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    cMetodo := 'POST'
    lCertif := .F.
    cAction := ''
    if lHml
        cURLPost := 'https://186.248.197.69:8443/nfe/snissdigitalsvc'
    else
        cURLPost := 'https://186.248.197.69:8443/nfe/snissdigitalsvc'
    ENDIF

    //Envelope
    cEnvelopIn += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.supernova.com.br/"><soapenv:Header/><soapenv:Body><ws:ConsultarLoteRps><xml><![CDATA['
    
    //Body
    cXML += '<ConsultarLoteRpsEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">'
    cXML += '    <Prestador> '
    cXML += '    <CpfCnpj> '
    cXML += '            <Cnpj>14892124000303</Cnpj>'
    cXML += '    </CpfCnpj> '
    cXML += '        <InscricaoMunicipal>100021809</InscricaoMunicipal>'
    cXML += '        <Senha>INOVAMAQ</Senha>'
    cXML += '        <FraseSecreta>INOVAMAQ03</FraseSecreta>'
    cXML += '    </Prestador> '
    cXML += '    <Protocolo>20230005951</Protocolo>'
    cXML += '</ConsultarLoteRpsEnvio> '

    //Envelope
    cEnvelopFi +=']]></xml></ws:ConsultarLoteRps></soapenv:Body></soapenv:Envelope>'

Return cXML

Static Function BH_MG(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.
      
    if lHml
        cURLPost := 'https://bhisshomologaws.pbh.gov.br:443/bhiss-ws/nfse'
    else
        cURLPost := 'https://bhissdigitalws.pbh.gov.br:443/bhiss-ws/nfse'
    ENDIF

    //Documento + Serie
    cAction := 'ConsultarNfseRequest'

    cEnvelopIn += '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '    <S:Body>
    cEnvelopIn += '        <ns2:ConsultarNfsePorRpsRequest xmlns:ns2="http://ws.bhiss.pbh.gov.br">
    cEnvelopIn += '            <nfseCabecMsg>
    cEnvelopIn += '                <![CDATA[
    cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
    cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
    cEnvelopIn += '                </cabecalho>
    cEnvelopIn += '                ]]>
    cEnvelopIn += '            </nfseCabecMsg>
    cEnvelopIn += '            <nfseDadosMsg>
    cEnvelopIn += '                <![CDATA[

    cXML +='                <ConsultarNfseRpsEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">
    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>
    cXML +='                </ConsultarNfseRpsEnvio>

    cEnvelopFi += '                ]]>
    cEnvelopFi += '            </nfseDadosMsg>
    cEnvelopFi += '        </ns2:ConsultarNfsePorRpsRequest>
    cEnvelopFi += '    </S:Body>
    cEnvelopFi += '</S:Envelope>
    

Return cXML

Static Function HO_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://homologacao.ginfes.com.br/ServiceGinfesImpl'
    else
        cURLPost := 'https://producao.ginfes.com.br/ServiceGinfesImpl'
    ENDIF

    //Documento + Serie
    cAction := 'ConsultarNfsePorRps'

    cEnvelopIn += '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '    <S:Body>
    cEnvelopIn += '        <ns2:ConsultarNfsePorRpsRequest xmlns:ns2="http://ws.bhiss.pbh.gov.br">
    cEnvelopIn += '            <nfseCabecMsg>
    cEnvelopIn += '                <![CDATA[
    cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
    cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
    cEnvelopIn += '                </cabecalho>
    cEnvelopIn += '                ]]>
    cEnvelopIn += '            </nfseCabecMsg>
    cEnvelopIn += '            <nfseDadosMsg>
    cEnvelopIn += '                <![CDATA[

    cXML +='                <ConsultarNfseRpsEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">
    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>'+cDoc+'</Numero>
    cXML +='                        <Serie>'+cSerie+'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>'+cCNPJ+'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+cInscMum+'</InscricaoMunicipal>
    cXML +='                    </Prestador>
    cXML +='                </ConsultarNfseRpsEnvio>

    cEnvelopFi += '                ]]>
    cEnvelopFi += '            </nfseDadosMsg>
    cEnvelopFi += '        </ns2:ConsultarNfsePorRpsRequest>
    cEnvelopFi += '    </S:Body>
    cEnvelopFi += '</S:Envelope>

Return cXML

Static Function FL_SC(lHml, cURLGet, lCertif, aCertif, cMetodo)    
    cMetodo := 'GET'
    lCertif := .T.

    if lHml
        cURLGet := 'https://nfps-e-hml.pmf.sc.gov.br/api/v1/consultas/notas/numero/' + AllTrim(SF2->F2_NFELETR)
    else
        cURLGet := 'https://nfps-e.pmf.sc.gov.br/api/v1/consultas/notas/numero/' + AllTrim(SF2->F2_NFELETR)
    ENDIF

Return ''

Static Function SL_MA(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://stm.semfaz.saoluis.ma.gov.br:80/WsNFe2/LoteRps'
    else
        cURLPost := 'https://stm.semfaz.saoluis.ma.gov.br:80/WsNFe2/LoteRps'
    ENDIF

    //Documento + Serie
    cAction := 'consultarLote'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarLote>
    cEnvelopIn += '    <mensagemXml>
    cEnvelopIn += '    <![CDATA[

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '                ]]>
    cEnvelopFi += '    </mensagemXml>
    cEnvelopFi += '    </consultarLote>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function VV_ES(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://tributacao.vilavelha.es.gov.br:443/tbw/services/Abrasf24'
    else
        cURLPost := 'https://tributacao.vilavelha.es.gov.br:443/tbw/services/Abrasf24'
    ENDIF

    //Documento + Serie
    cAction := 'consultarLoteRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarLoteRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>


    cEnvelopFi += '    </consultarLoteRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function BR_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'http://tributario.bauru.sp.gov.br:80/services/Abrasf23'
    else
        cURLPost := 'http://tributario.bauru.sp.gov.br:80/services/Abrasf23'
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

//Duvidadas WSDL
Static Function BL_PA(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function BR_DF(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function CP_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function CB_MT(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function CT_PR(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://srv2-isscuritiba.curitiba.pr.gov.br/Iss.NfseWebService/nfsews.asmx'
    else
        cURLPost := 'hhttps://srv2-isscuritiba.curitiba.pr.gov.br/Iss.NfseWebService/nfsews.asmx'
    ENDIF

    //Documento + Serie
    cAction := 'ConsultarNfseRpsEnvio'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <ConsultarNfseRpsEnvio xmlns="http://www.abrasf.org.br/ABRASF/arquivos/nfse.xsd">

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </ConsultarNfseRpsEnvio>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function FT_CE(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    // cMetodo := 'POST'
    // lCertif := .T.

    // if lHml
    //     cURLPost := 'https://iss.fortaleza.ce.gov.br/grpfor-iss/ServiceGinfesImplService'
    // else
    //     cURLPost := 'https://iss.fortaleza.ce.gov.br/grpfor-iss/ServiceGinfesImplService'
    // ENDIF

    // //Documento + Serie
    // cAction := 'ConsultarNfsePorRpsV3'

    // cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    // cEnvelopIn += '<soap:Body>
    // cEnvelopIn += '    <ConsultarNfsePorRpsV3>
    // cEnvelopIn += '         <Cabecalho>
    // cEnvelopIn += '                <![CDATA[
    // cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
    // cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
    // cEnvelopIn += '                </cabecalho>
    // cEnvelopIn += '                ]]>
    // cEnvelopIn += '         </Cabecalho>

    // cXML += '               <ConsultarNfseRpsEnvio>
    // cXML += '                   <![CDATA[
    // cXML +='                    <IdentificacaoRps xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd">>
    // cXML +='                        <tipos:Numero>' + cDoc +'</tipos:Numero>
    // cXML +='                        <tipos:Serie>'+ cSerie +'</tipos:Serie>
    // cXML +='                        <tipos:Tipo>1</tipos:Tipo>
    // cXML +='                    </IdentificacaoRps>
    // cXML +='                    <Prestador xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd">
    // cXML +='                        <tipos:Cnpj>' + cCNPJ +'</tipos:Cnpj>
    // cXML +='                        <tipos:InscricaoMunicipal>'+  cInscMum +'</tipos:InscricaoMunicipal>
    // cXML +='                    </Prestador>
    // cXML += '                   ]]>
    // cXML += '               </ConsultarNfseRpsEnvio>

    // cEnvelopFi += '    </ConsultarNfsePorRpsV3>
    // cEnvelopFi += '</soap:Body>
    // cEnvelopFi += '</soap:Envelope>
    
   // -----------------------------------------------------------------------------------------------------------
    // cAction := 'ConsultarNfseRpsEnvio'

    // cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    // cEnvelopIn += '<soap:Body>
    // cEnvelopIn += '    <ConsultarNfseRpsEnvio xmlns="http://www.ginfes.com.br/servico_consultar_nfse_rps_envio_v03.xsd">

    // cXML +='                    <IdentificacaoRps xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd">
    // cXML +='                        <tipos:Numero>' + cDoc +'</tipos:Numero>
    // cXML +='                        <tipos:Serie>'+ cSerie +'</tipos:Serie>
    // cXML +='                        <tipos:Tipo>1</tipos:Tipo>
    // cXML +='                    </IdentificacaoRps>
    // cXML +='                    <Prestador xmlns:tipos="http://www.ginfes.com.br/tipos_v03.xsd">
    // cXML +='                        <tipos:Cnpj>' + cCNPJ +'</tipos:Cnpj>
    // cXML +='                        <tipos:InscricaoMunicipal>'+  cInscMum +'</tipos:InscricaoMunicipal>
    // cXML +='                    </Prestador>

    // cEnvelopFi += '    </ConsultarNfseRpsEnvio>
    // cEnvelopFi += '</soap:Body>
    // cEnvelopFi += '</soap:Envelope>

//------------------------------------------------------------------------------------

    Local cCodMun	:= "2304400"//if( type( "oSigamatX" ) == "U",SM0->M0_CODMUN,oSigamatX:M0_CODMUN )
    Local cDestino 	:= ""
    Local cDrive   	:= ""
    Local cPath     := GetTempPath()
    Local cDirDest  := GetTempPath()//cPath + cDoc + ".xml"
    Local cIdflush  := cSerie+cDoc
    Local cURL     	:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
    Local cXml		:= ""
    Local cNota 	:= cDoc // Recebe a nota inicial
    Local cFile	:= "" // Recebe o caminho e o arquivo a ser gravado
    Local cProc	:= ""
    Local cIdEnt := GetIdEnt()
    Local nHdl 	:= 0


    Default cNotaIni:=""
    Default cNotaFim:=""


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Corrigi diretorio de destino                                           ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    SplitPath(cDirDest,@cDrive,@cDestino,"","")
    cDestino := cDrive+cDestino


    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
    //³ Inicia processamento                                                   ³
    //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    Do While Val(cNota) <= Val(cNotaFim)

        ProcRegua(Val(cNota))
        
        cIdflush  := cSerie+cNota
        
        oWS := WsNFSE001():New()
        oWS:cUSERTOKEN            := "TOTVS"
        oWS:cID_ENT               := cIdEnt
        oWS:cCodMun               := cCodMun
        oWS:_URL                  := AllTrim(cURL)+"/NFSE001.apw"
        oWS:nDIASPARAEXCLUSAO     := 0
        oWS:OWSNFSEID:OWSNOTAS    := NFSe001_ARRAYOFNFSESID1():New()
            
        aadd(oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1,NFSE001_NFSES1():New())
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CCODMUN  := cCodMun
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cID      := cIdflush
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:cXML     := " "
        oWS:OWSNFSEID:OWSNOTAS:OWSNFSESID1[1]:CNFSECANCELADA := " "               
        
        If ExecWSRet(oWS,"RETORNANFSE")
        
            If Len(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5) > 0
            
                cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFE:cXMLPROT)
                If !Empty(cXml)
                
                    cFile := cDirDest + "NFSe_" + Alltrim(cSerie) + AllTrim(cNota) + ".XML"
                                        
                    nHdl  :=	MsFCreate (cFile)
        
                    If ( nHdl >= 0 )
                        FWrite (nHdl, cXml)
                        FClose (nHdl)					
                        cProc += AllTrim(cNota) +" Série: " + AllTrim(cSerie) +" | XML - Emissão." + CRLF	
                    EndIf						
                    
                EndIf

                //Tratamento para geração do XML Cancelado.FDL.

                If Type( "oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT" ) <> "U"
                    cXml  := encodeUTF8(oWs:oWsRetornaNfseResult:OWSNOTAS:OWSNFSES5[1]:oWSNFECANCELADA:cXMLPROT)
                    If !Empty(cXml)
                    
                        cFile := cDirDest + "NFSe_Cancelada_" + Alltrim(cSerie) + AllTrim(cNota) + ".XML"
                                            
                        nHdl  :=	MsFCreate (cFile)
            
                        If ( nHdl >= 0 )
                            FWrite (nHdl, cXml)
                            FClose (nHdl)					
                            cProc += AllTrim(cNota) +" Série: " + AllTrim(cSerie) +" | XML - Cancelado." + CRLF	
                        EndIf						
                        
                    EndIf
                EndIf	
            EndIf
        
        EndIf
        
        cNota := soma1(alltrim(cNota))
        
    EndDo	

// If !Empty(cProc)

// 	Aviso(STR0247,STR0248 + CRLF + cProc,{"OK"},3) //"XML de Retorno da Prefeitura"-"XML gerado das notas:"
	
// EndIf

	FreeObj(oWS)
	oWS := nil
	delClassIntF()

Return cXML

Static Function GN_GO(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML      := ''

    Local cCNPJ     := AllTrim(SM0->M0_CGC)
    Local cInscMum  :=  AllTrim(SM0->M0_INSCM)
    Local cDoc      := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie    := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://nfse.goiania.go.gov.br/ws/nfse.asmx'
    else
        cURLPost := 'https://nfse.goiania.go.gov.br/ws/nfse.asmx'
    ENDIF

    //Documento + Serie
    cAction := 'ConsultarNfseRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <ConsultarNfseRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </ConsultarNfseRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function JD_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function MU_AM(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function MG_PR(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function MM_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function OC_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function PA_RS(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function RF_PE(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://nfse.recife.pe.gov.br/WSNacional/nfse_v01.asmx'
    else
        cURLPost := 'https://nfse.recife.pe.gov.br/WSNacional/nfse_v01.asmx'
    ENDIF

    //Documento + Serie
    cAction := 'ConsultarNfseRpsEnvio'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <ConsultarNfseRpsEnvio xmlns="http://www.abrasf.org.br/ABRASF/arquivos/nfse.xsd">

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </ConsultarNfseRpsEnvio>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function RJ_RJ(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function SJ_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function SD_BH(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := 'https://nfse.salvador.ba.gov.br/rps/CONSULTANFSERPS/ConsultaNfseRPS.svc'
    else
        cURLPost := 'https://nfse.salvador.ba.gov.br/rps/CONSULTANFSERPS/ConsultaNfseRPS.svc'
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function ST_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function SB_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function SP_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML

Static Function VD_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cDoc := AllTrim(Str(Val(SF2->F2_DOC)))
    Local cSerie := AllTrim(SF2->F2_SERIE)

    cMetodo := 'POST'
    lCertif := .T.

    if lHml
        cURLPost := ''
    else
        cURLPost := ''
    ENDIF

    //Documento + Serie
    cAction := 'consultarNfsePorRps'

    cEnvelopIn += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
    cEnvelopIn += '<soap:Body>
    cEnvelopIn += '    <consultarNfsePorRps>

    cXML +='                    <IdentificacaoRps>
    cXML +='                        <Numero>' + cDoc +'</Numero>
    cXML +='                        <Serie>'+ cSerie +'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>' + cCNPJ +'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+  cInscMum +'</InscricaoMunicipal>
    cXML +='                    </Prestador>

    cEnvelopFi += '    </consultarNfsePorRps>
    cEnvelopFi += '</soap:Body>
    cEnvelopFi += '</soap:Envelope>
    

Return cXML
