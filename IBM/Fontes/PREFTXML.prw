#INCLUDE "totvs.ch"

/*/{Protheus.doc} User Function prefeitura
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
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '1501402'
                //Belém qual ?
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3106200'
                //Belo Horizonte
                cRet = BH_MG(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '5300108'
                //Brasilia
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3509502'
                //Campinas
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '5103403'
                //Cuiabá
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '4106902'
                //Curitiba
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '4205407'
                //Florianópolis
                FWAlertWarning('Em desenvolvimento')
                cRet = FL_SC(lHml, @cURLPost, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '2304400'
                //Fortaleza
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '5208707'
                //Goiânia
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3519071'
                //Hortolândia
                //FWAlertWarning('Em desenvolvimento')
                cRet = HO_SP(lHml, @cAction, @cURLPost, @cEnvelopIn, @cEnvelopFi, @lCertif, @aCertif, @cMetodo)
            case cCodMunic == '3525904'
                //Jundiaí
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '1302603'
                //Manaus
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '2111300'
                //São Luís
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '4115200'
                //Maringá
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3530805'
                //Mogi Mirim
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3534401'
                //Osasco
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '4314902'
                //Porto Alegre
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '2611606'
                //Recife
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3304557'
                //Rio de Janeiro
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3549805'
                //São José do Rio Preto
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '2927408'
                //Salvador
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3547304'
                //Santana de Parnaíba
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3548708'
                //São Bernardo do Campo
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3550308'
                //São Paulo
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3205200'
                //Vila Velha
                FWAlertWarning('Em desenvolvimento')
            case cCodMunic == '3556701'
                //Vinhedo
                FWAlertWarning('Em desenvolvimento')
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
    Local lComProtoc := .F.
    Local lConsultarNfse := .F.

    Local cCNPJ := AllTrim(SM0->M0_CGC)
    Local cInscMum :=  AllTrim(SM0->M0_INSCM)
    Local cNFSe := AllTrim(SF2->F2_NFELETR)
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
    
    if lComProtoc //Protocolo
        cEnvelopIn := ''
        cXML := ''
        cEnvelopFi := ''
        cAction := 'ConsultarSituacaoLoteRpsRequest'

        cEnvelopIn += '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
        cEnvelopIn += '    <S:Body>
        cEnvelopIn += '        <ns2:ConsultarSituacaoLoteRpsRequest xmlns:ns2="http://ws.bhiss.pbh.gov.br">
        cEnvelopIn += '        
        cEnvelopIn += '            <nfseCabecMsg>
        cEnvelopIn += '                <![CDATA[
        cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
        cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
        cEnvelopIn += '                </cabecalho>
        cEnvelopIn += '                ]]>
        cEnvelopIn += '            </nfseCabecMsg>
        cEnvelopIn += '            <nfseDadosMsg>
        cEnvelopIn += '                <![CDATA[

        cXML +='                <ConsultarSituacaoLoteRpsEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">
        cXML +='                    <Prestador>
        cXML +='                        <Cnpj>' + AllTrim(SM0->M0_CGC) +'</Cnpj>
        cXML +='                        <InscricaoMunicipal>' + AllTrim(SM0->M0_INSCM) +'</InscricaoMunicipal>
        cXML +='                    </Prestador>
        cXML +='                    <Protocolo>'+ AllTrim(SM0->M0_INSCM) +'</Protocolo>
        cXML +='                </ConsultarSituacaoLoteRpsEnvio>

        cEnvelopFi += '                ]]>
        cEnvelopFi += '                
        cEnvelopFi += '            </nfseDadosMsg>
        cEnvelopFi += '        </ns2:ConsultarSituacaoLoteRpsRequest>
        cEnvelopFi += '    </S:Body>
        cEnvelopFi += '</S:Envelope>
    ENDIF

    if lConsultarNfse 
        cEnvelopIn := ''
        cXML := ''
        cEnvelopFi := ''
        cAction := 'ConsultarNfseRequest'

        cEnvelopIn += '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
        cEnvelopIn += '    <S:Body>
        cEnvelopIn += '        <ns2:ConsultarNfseRequest xmlns:ns2="http://ws.bhiss.pbh.gov.br">
        cEnvelopIn += '            <nfseCabecMsg>
        cEnvelopIn += '                <![CDATA[
        cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
        cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
        cEnvelopIn += '                </cabecalho>
        cEnvelopIn += '                ]]>
        cEnvelopIn += '            </nfseCabecMsg>
        cEnvelopIn += '            <nfseDadosMsg>
        cEnvelopIn += '                <![CDATA[

        cXML +='                <ConsultarNfseEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">
        cXML +='                    <Prestador>
        cXML +='                        <Cnpj>'+ cCNPJ +'</Cnpj>
        cXML +='                        <InscricaoMunicipal>'+ cInscMum +'</InscricaoMunicipal>
        cXML +='                    </Prestador>
        cXML +='                        <NumeroNfse>'+ cNFSe +'</NumeroNfse>
        cXML +='                </ConsultarNfseEnvio>

        cEnvelopFi += '                ]]>
        cEnvelopFi += '            </nfseDadosMsg>
        cEnvelopFi += '        </ns2:ConsultarNfseRequest>
        cEnvelopFi += '    </S:Body>
        cEnvelopFi += '</S:Envelope>
    ENDIF

Return cXML

Static Function HO_SP(lHml, cAction, cURLPost, cEnvelopIn, cEnvelopFi, lCertif, aCertif, cMetodo)
    Local cXML := ''
    Local lComProtoc := .F.

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
    cXML +='                        <Numero>'+IIF( lHml, '1', AllTrim(Str(Val(SF2->F2_DOC))) )+'</Numero>
    cXML +='                        <Serie>'+IIF( lHml, 'P38', AllTrim(SF2->F2_SERIE) )+'</Serie>
    cXML +='                        <Tipo>1</Tipo>
    cXML +='                    </IdentificacaoRps>
    cXML +='                    <Prestador>
    cXML +='                        <Cnpj>'+IIF( lHml, '17469701000177',  AllTrim(SM0->M0_CGC) )+'</Cnpj>
    cXML +='                        <InscricaoMunicipal>'+IIF( lHml, '4056360099',  AllTrim(SM0->M0_INSCM) )+'</InscricaoMunicipal>
    cXML +='                    </Prestador>
    cXML +='                </ConsultarNfseRpsEnvio>

    cEnvelopFi += '                ]]>
    cEnvelopFi += '            </nfseDadosMsg>
    cEnvelopFi += '        </ns2:ConsultarNfsePorRpsRequest>
    cEnvelopFi += '    </S:Body>
    cEnvelopFi += '</S:Envelope>
    
    if lComProtoc //Protocolo
        cEnvelopIn := ''
        cXML := ''
        cEnvelopFi := ''
        cAction := 'ConsultarSituacaoLoteRpsRequest'

        cEnvelopIn += '<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
        cEnvelopIn += '    <S:Body>
        cEnvelopIn += '        <ns2:ConsultarSituacaoLoteRpsRequest xmlns:ns2="http://ws.bhiss.pbh.gov.br">
        cEnvelopIn += '        
        cEnvelopIn += '            <nfseCabecMsg>
        cEnvelopIn += '                <![CDATA[
        cEnvelopIn += '                <cabecalho xmlns="http://www.abrasf.org.br/nfse.xsd" versao="1.00">
        cEnvelopIn += '                    <versaoDados>1.00</versaoDados>
        cEnvelopIn += '                </cabecalho>
        cEnvelopIn += '                ]]>
        cEnvelopIn += '            </nfseCabecMsg>
        cEnvelopIn += '            <nfseDadosMsg>
        cEnvelopIn += '                <![CDATA[

        cXML +='                <ConsultarSituacaoLoteRpsEnvio xmlns="http://www.abrasf.org.br/nfse.xsd">
        cXML +='                    <Prestador>
        cXML +='                        <Cnpj>'+IIF( lHml, '17469701000177',  AllTrim(SM0->M0_CGC) )+'</Cnpj>
        cXML +='                        <InscricaoMunicipal>'+IIF( lHml, '4056360099',  AllTrim(SM0->M0_INSCM) )+'</InscricaoMunicipal>
        cXML +='                    </Prestador>
        cXML +='                    <Protocolo>'+IIF( lHml, '57ffb7bb',  AllTrim(SM0->M0_INSCM) )+'</Protocolo>
        cXML +='                </ConsultarSituacaoLoteRpsEnvio>

        cEnvelopFi += '                ]]>
        cEnvelopFi += '                
        cEnvelopFi += '            </nfseDadosMsg>
        cEnvelopFi += '        </ns2:ConsultarSituacaoLoteRpsRequest>
        cEnvelopFi += '    </S:Body>
        cEnvelopFi += '</S:Envelope>
    ENDIF

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
