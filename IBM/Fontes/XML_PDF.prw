#INCLUDE "totvs.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

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
User Function XML_PDF(cArquiv)

    Local cCaminho  := 'C:\TEMP\NFSERVICO'
    Local cArquivo  := ''
    Local aArquivo  := {}

    Local oPrintPvt := NIL
    Local oFile := NIL
    Local oXML  := NIL
    Local oJson := NIL
    Local cError := ''
    Local cWarning := ''

    //Linhas e colunas
    Local nLinAtu   := 030
    Local nTamLin   := 010
    Local nLinFin   := 820
    Local nColIni   := 010
    Local nColFin   := 550
    Local nColMeio  := (nColFin-nColIni)/2
    Local nColunTab := (nColFin - nColIni) / 5
    Local nLargLogo := 0

    //Fontes
    Local cNomeFont   := "Arial"
    Local oFontDet    := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
    Local oFontDetN   := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
    Local oFontRod    := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
    Local oFontTit    := TFont():New(cNomeFont, 9, -13, .T., .F., 5, .T., 5, .T., .F.)
    Local oFontTitN   := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .T.)

    //Cores
    Local COR_CINZA := RGB(180, 180, 180)
    Local COR_PRETO := RGB(000, 000, 000)

    //Orientação
    Local PAD_LEFT   := 0
    Local PAD_RIGHT  := 1
    Local PAD_CENTER := 2

    Local cLogoEmp  := GetSrvProfString("Startpath","") + "LGMID"+ cEmpAnt+".PNG"
    Local cCaminInfo := ''
    Local cCaminToma := ''
    Local cCaminServ := ''
    Local cDataEmiss := ''
    Local cHoraEmiss := ''
    Local cNumFNSe   := ''
    Local cCodVerf   := ''
    Local cCpfCnpj   := ''  
    Local cInscMunic := ''
    Local cRazaoSoci := ''
    Local cEndereco  := ''
    Local cBairro    := ''
    Local cUF        := ''
    Local cValorServ := ''
    Local cINSS      := ''
    Local cIRRF      := ''
    Local cCSLL      := ''
    Local cCOFINS    := ''
    Local cPIS       := ''
    Local cDeducoes := ''
    Local cBaseCalc := ''
    Local cAliquota := ''
    Local cISS      := ''
    Local cCredito  := ''
    Local cTipoArq  := ''
    Local cTextArq  := ''
    Local cDescServi := ''

    Local oXmlCaminh := NIL

    IF !file('C:\TEMP')
        MAKEDIR( 'C:\TEMP' )
    ENDIF

    IF !file(cCaminho)
        MAKEDIR( cCaminho )
    ENDIF

    IF !file(cCaminho + '/XML')
        MAKEDIR( cCaminho + '/XML')
    ENDIF

    IF !file(cCaminho + '/JSON')
        MAKEDIR( cCaminho + '/JSON')
    ENDIF

    IF !file(cCaminho + '/PDF')
        MAKEDIR( cCaminho + '/PDF')
    ENDIF

    if !file(cArquiv)
        MsgStop('Arquivo não encontrado')
        Return
    ENDIF

    oFile := FWFileReader():New(cArquiv)
 
    If (oFile:Open())
        If ! (oFile:EoF())
            cTextArq  := oFile:FullRead()
        EndIf
        oFile:Close()
    EndIf

    if at('.', cArquiv) > 0
        cTipoArq := SUBSTR( cArquiv, at('.', cArquiv) + 1)
    ENDIF

    if UPPER( cTipoArq ) == 'XML'
        oXML := XmlParser(cTextArq,"_", @cError, @cWarning) // Validar XML
        If (oXml == NIL )
            MsgStop("Falha ao gerar Objeto XML arquivo: "+cError+" / "+cWarning)
            Return
        Endif
    ELSEIF UPPER( cTipoArq ) == 'JSON'
        oJson   := JsonObject():New()
		cError  := oJson:FromJson(cTextArq)

        if !EMPTY( cError )
            MsgStop("Falha ao gerar Objeto JSON resposta: " + cError)
            Return
        endif
    ELSE
        MsgStop('Arquivo não identificado')
        Return
    ENDIF


    //seta variaveis
    if UPPER( cTipoArq ) == 'XML'
        cCaminInfo := '_CONSULTARLOTERPSRESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:'
        oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )

        if oXmlCaminh == NIL
            cCaminInfo := '_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:'
            oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
        ENDIF

        cDataEmiss := WSAdvValue( oXml, cCaminInfo + "_DATAEMISSAO:TEXT","string" )

        if !EMPTY(cDataEmiss)
            cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
            cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
            cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
        ENDIF

        cNumFNSe   := WSAdvValue( oXml, cCaminInfo + "_NUMERO:TEXT","string" )
        cCodVerf   := WSAdvValue( oXml, cCaminInfo + "_CODIGOVERIFICACAO:TEXT","string" )
        cCpfCnpj   := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
    
        if EMPTY( cCpfCnpj )
            cCpfCnpj    := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_CPFCNPJ:_CPF:TEXT","string" )
            if !EMPTY( cCpfCnpj )
                cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
            ENDIF
        else
            cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
        ENDIF
        cInscMunic := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_IDENTIFICACAOPRESTADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
        cRazaoSoci := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT","string" )
        cBairro    := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_BAIRRO:TEXT","string" )
        cEndereco  := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_ENDERECO:TEXT","string" )
        cUF        := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_UF:TEXT","string" )
    ELSEIF UPPER( cTipoArq ) == 'JSON'
        cCaminInfo := ''
        cDataEmiss := oJson['notas'][1]['dataEmissao']

        if !EMPTY( cDataEmiss )
            cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
            cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
            cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
        ENDIF

        cCodVerf   := oJson['notas'][1]['cdVerificacao']
    ENDIF

    if at('/', cArquiv) > 0
        aArquivo := strtokarr(cArquiv, "/")
    elseif at('\', cArquiv) > 0
        aArquivo := strtokarr(cArquiv, "\")
    ENDIF

    cArquivo := aArquivo[len(aArquivo)]
    cArquivo := SUBSTR( cArquivo, 1, at('.', cArquivo) - 1)
    cArquivo := cArquivo + '.pdf'

    cCaminho := 'C:\TEMP\NFSERVICO\PDF\'
    if file(cCaminho + cArquivo)
        FErase(cCaminho + cArquivo)
    ENDIF

    oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., GetTempPath(), .T., , @oPrintPvt, "", , , , .F.)
    oPrintPvt:CPATHPDF := cCaminho

    //Setando os atributos necessários do relatório
    oPrintPvt:SetResolution(72)
    oPrintPvt:SetPortrait()
    oPrintPvt:SetMargin(60, 60, 60, 60)
    oPrintPvt:SetPaperSize(DMPAPER_A4)

    //Iniciando Página
	oPrintPvt:StartPage()

    oPrintPvt:Box( nLinAtu, nColIni         , nLinFin   , nColFin, "-4")
    oPrintPvt:Box( nLinAtu, nColFin  - 090  , 90        , nColFin, "-4")

    oPrintPvt:SayAlign(nLinAtu, nColMeio - 120, UPPER('Nota fiscal eletrônica de serviços - NFS-e'), oFontTitN, 260, 20, COR_PRETO, PAD_LEFT, 0)

    oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, "Número da Nota", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    if !EMPTY( cNumFNSe )
        oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, cNumFNSe, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF
    nLinAtu += nTamLin

    oPrintPvt:Line(nLinAtu, nColFin  - 090, nLinAtu, nColFin, COR_PRETO)

    oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, "Data e hora de Emissão", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    if !EMPTY( cDataEmiss ) .AND. !EMPTY( cHoraEmiss )
        oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, cDataEmiss + "   " + cHoraEmiss, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF
    nLinAtu += nTamLin

    oPrintPvt:Line(nLinAtu, nColFin  - 090, nLinAtu, nColFin, COR_PRETO)

    oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, "Código de verificação", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += nTamLin
    if !EMPTY( cCodVerf )
        oPrintPvt:SayAlign(nLinAtu, nColFin  - 090, cCodVerf, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF
    nLinAtu += nTamLin

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)

    oPrintPvt:SayAlign(nLinAtu, nColMeio - 60, UPPER('Prestador de serviços'), oFontTitN, 240, 20, COR_PRETO, PAD_LEFT, 0)

    nLinAtu += nTamLin

    if file(cLogoEmp)
        nLargLogo = 40
        oPrintPvt:SayBitmap(nLinAtu, nColIni + 5,cLogoEmp,40,nLargLogo)
        nLargLogo += 15
    ENDIF

    oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo, "CPF/CNPJ: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cCpfCnpj )
        oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo + 45,  cCpfCnpj, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    oPrintPvt:SayAlign(nLinAtu, nColMeio + nLargLogo, "Inscrição municipal: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cInscMunic )
        oPrintPvt:SayAlign(nLinAtu, nColMeio + nLargLogo + 70,  cInscMunic, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo, "Nome/Razão social: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cRazaoSoci )
        oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo + 75,  cRazaoSoci, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo, "Endereço: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cEndereco )
        oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo + 40,  cEndereco, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo, "Bairro: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cBairro )
        oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo + 30,  cBairro, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo, "UF: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cUF )
        oPrintPvt:SayAlign(nLinAtu, nColIni + nLargLogo + 15,  cUF, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += (nTamLin * 2)

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)

    oPrintPvt:SayAlign(nLinAtu, nColMeio - 60, UPPER('Tomador de serviços'), oFontTitN, 240, 20, COR_PRETO, PAD_LEFT, 0)

    nLinAtu += nTamLin

    //Seta variaveis
    IF UPPER( cTipoArq ) == 'XML'
        cCaminToma := cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:"
        oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )

        if oXmlCaminh == NIL
            cCaminToma := cCaminInfo + "_TOMADORSERVICO:"
            oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )
        ENDIF
        
        cCpfCnpj   := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
        if EMPTY( cCpfCnpj )
            cCpfCnpj    := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT","string" )
            if !EMPTY( cCpfCnpj )
                cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
            ENDIF
        else
            cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
        ENDIF
        cInscMunic := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
        cRazaoSoci := WSAdvValue( oXml, cCaminToma + "_RAZAOSOCIAL:TEXT","string" )
        cBairro    := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_BAIRRO:TEXT","string" )
        cEndereco  := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_ENDERECO:TEXT","string" )
        cUF        := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_UF:TEXT","string" )
    ELSEIF UPPER( cTipoArq ) == 'JSON'

    ENDIF

    oPrintPvt:SayAlign(nLinAtu, nColIni , "CPF/CNPJ: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cCpfCnpj )
        oPrintPvt:SayAlign(nLinAtu, nColIni  + 45,  cCpfCnpj, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    oPrintPvt:SayAlign(nLinAtu, nColMeio , "Inscrição municipal: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cInscMunic )
        oPrintPvt:SayAlign(nLinAtu, nColMeio  + 70,  cInscMunic, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni , "Nome/Razão social: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cRazaoSoci )
        oPrintPvt:SayAlign(nLinAtu, nColIni  + 75,  cRazaoSoci, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni , "Endereço: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cEndereco )
        oPrintPvt:SayAlign(nLinAtu, nColIni  + 40,  cEndereco, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni , "Bairro: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cBairro )
        oPrintPvt:SayAlign(nLinAtu, nColIni + 30,  cBairro, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += nTamLin

    oPrintPvt:SayAlign(nLinAtu, nColIni , "UF: ", oFontDet, 240, 20, COR_PRETO, PAD_LEFT, 0)
    if !EMPTY( cUF )
        oPrintPvt:SayAlign(nLinAtu, nColIni  + 15,  cUF, oFontDetN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += (nTamLin * 2)

    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)


    oPrintPvt:SayAlign(nLinAtu, nColMeio - 60, UPPER('Discriminação dos serviços'), oFontTitN, 240, 20, COR_PRETO, PAD_LEFT, 0)

    nLinAtu += (nTamLin * 1.5)

    cCaminServ := cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:"

    oXmlCaminh := WSAdvValue( oXml, cCaminServ + "TEXT","string" )

    if oXmlCaminh == NIL
        cCaminServ := cCaminInfo + '_SERVICO:'
        oXmlCaminh := WSAdvValue( oXml, cCaminServ + "TEXT","string" )
    ENDIF

    IF UPPER( cTipoArq ) == 'XML'
        cDescServi := WSAdvValue( oXml, cCaminServ + "_DISCRIMINACAO:TEXT","string" )
    ELSEIF UPPER( cTipoArq ) == 'JSON'

    ENDIF

    if !EMPTY( cDescServi )
        oPrintPvt:SayAlign(nLinAtu, nColIni,  cDescServi, oFontDetN, nColFin - 10, (nTamLin * 10), COR_PRETO, PAD_LEFT, 0)
    ENDIF

    nLinAtu += (nTamLin * 53)
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)

    IF UPPER( cTipoArq ) == 'XML'
        cValorServ := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORSERVICOS:TEXT","string" )
        if !EMPTY( cValorServ )
            cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cINSS   := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORINSS:TEXT","string" )
        if !EMPTY( cINSS )
            cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cIRRF   := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORIR:TEXT","string" )
        if !EMPTY( cIRRF )
            cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cCSLL   := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORCSLL:TEXT","string" )
        if !EMPTY( cCSLL )
            cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cCOFINS := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORCOFINS:TEXT","string" )
        if !EMPTY( cCOFINS )
            cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cPIS    := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORPIS:TEXT","string" )
        if !EMPTY( cPIS )
            cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
    ELSEIF UPPER( cTipoArq ) == 'JSON'

    ENDIF

    oPrintPvt:SayAlign(nLinAtu, nColMeio - 60, UPPER('Valor total do serviço = R$ ' + cValorServ), oFontTitN, 240, 20, COR_PRETO, PAD_LEFT, 0)
    nLinAtu += (nTamLin + 3)
    oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)

    oPrintPvt:Box( nLinAtu , nColIni, nLinAtu + 24 , nColunTab , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 1, nLinAtu + 24 , nColunTab * 2 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 2, nLinAtu + 24 , nColunTab * 3 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 3, nLinAtu + 24 , nColunTab * 4 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 4, nLinAtu + 24 , (nColunTab * 5) + 10 , "-4")

    nLinAtu += 1
    oPrintPvt:SayAlign(nLinAtu, nColIni , "INSS (R$)"           , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 1 , "IRRF (R$)"     , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 2 , "CSLL (R$)"     , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 3 , "COFINS (R$)"   , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 4 , "PIS/PASEP (R$)", oFontDet, nColunTab + 10, 20, COR_PRETO, PAD_CENTER, 0)
    nLinAtu += nTamLin
    if !EMPTY( cINSS )
        oPrintPvt:SayAlign(nLinAtu, nColIni       ,  cINSS  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cIRRF )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 1 ,  cIRRF  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cCSLL )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 2 ,  cCSLL  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cCOFINS )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 3 ,  cCOFINS, oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cPIS )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 4 ,  cPIS   , oFontDetN, nColunTab + 10, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF

    nLinAtu += nTamLin
    oPrintPvt:Box( nLinAtu , nColIni, nLinAtu + 24 , nColunTab , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 1, nLinAtu + 24 , nColunTab * 2 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 2, nLinAtu + 24 , nColunTab * 3 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 3, nLinAtu + 24 , nColunTab * 4 , "-4")
    oPrintPvt:Box( nLinAtu , nColunTab * 4, nLinAtu + 24 , (nColunTab * 5) + 10 , "-4")

    nLinAtu += 1
    oPrintPvt:SayAlign(nLinAtu, nColIni , "Valor Deduções (R$)"     , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 1 , "Base de cálculo (R$)"  , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 2 , "Alíquota (R$)"         , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 3 , "Valor do ISS (R$)"     , oFontDet, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    oPrintPvt:SayAlign(nLinAtu, nColunTab * 4 , "Crédito (R$)"          , oFontDet, nColunTab + 10, 20, COR_PRETO, PAD_CENTER, 0)
    nLinAtu += nTamLin

    if UPPER( cTipoArq ) == 'XML'
        cDeducoes    := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORDEDUCOES:TEXT","string" )
        if !EMPTY( cDeducoes )
            cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cBaseCalc    := WSAdvValue( oXml, cCaminInfo + "_VALORESNFSE:_BASECALCULO:TEXT","string" )
        if !EMPTY( cBaseCalc )
            cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cAliquota    := WSAdvValue( oXml, cCaminInfo + "_VALORESNFSE:_ALIQUOTA:TEXT","string" )
        if !EMPTY( cAliquota )
            cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cISS    := WSAdvValue( oXml, cCaminInfo + "_VALORESNFSE:_VALORISS:TEXT","string" )
        if !EMPTY( cISS )
            cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
        cCredito    := WSAdvValue( oXml, cCaminInfo + "_VALORCREDITO:TEXT","string" )
        if !EMPTY( cCredito )
            cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
        ENDIF
    ELSEIF UPPER( cTipoArq ) == 'JSON'

    ENDIF

    if !EMPTY( cDeducoes )
        oPrintPvt:SayAlign(nLinAtu, nColIni       ,  cDeducoes  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cBaseCalc )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 1 ,  cBaseCalc  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cAliquota )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 2 ,  cAliquota  , oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cISS )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 3 ,  cISS, oFontDetN, nColunTab, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF
    if !EMPTY( cCredito )
        oPrintPvt:SayAlign(nLinAtu, nColunTab * 4 ,  cCredito   , oFontDetN, nColunTab + 10, 20, COR_PRETO, PAD_CENTER, 0)
    ENDIF

    //Mostrando o relatório
    //oPrintPvt:Preview()
    oPrintPvt:Print()
    FreeObj(oPrintPvt)
Return 
