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
User Function XML_PDF(cArquiv, cTipoArq, nTipoXML, cCodMun)

	Local cCaminho  := 'C:\TEMP\NFSERVICO\'+cFilAnt
	Local cArquivo  := ''
	Local aArquivo  := {}

	Local oPrintPvt := NIL
	Local oFile := NIL
	Local oXML  := NIL
	Local oJson := NIL
	Local oResult   as Object
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

	// if at('.', cArquiv) > 0
	// 	cTipoArq := SUBSTR( cArquiv, at('.', cArquiv) + 1)
	// ENDIF

	if UPPER( cTipoArq ) == 'XML'
		oXML := XmlParser(cTextArq,"_", @cError, @cWarning) // Validar XML
		If (oXml == NIL )
			MsgStop("Falha ao gerar Objeto XML arquivo: "+cError+" / "+cWarning)
			Return
		Endif
	ELSEIF UPPER( cTipoArq ) == 'JSON'
	// 	oJson   := JsonObject():New()
	// 	oResult  := oJson:FromJson(cTextArq)

	// 	if !EMPTY( cError )
	// 		MsgStop("Falha ao gerar Objeto JSON resposta: " + cError)
	// 		Return
	// 	endif
	// ELSE
	// 	MsgStop('Arquivo não identificado')
	// 	Return
	ENDIF

	//seta variaveis
	if UPPER( cTipoArq ) == 'XML'
		If nTipoXML = 1
			cCaminInfo := '_CONSULTARLOTERPSRESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:'
			oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )

			if oXmlCaminh == NIL
				cCaminInfo := '_CONSULTARLOTERPSRESULT:_LISTANFSE:_COMPNFSE:_TCCOMPNFSE:_NFSE:_INFNFSE:'
				oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminInfo := '_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NFSE:_INFNFSE:'
				oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminInfo := '_CONSULTARNFSERPSRESPOSTA:_COMPNFSE:_NS4_NFSE:_NS4_INFNFSE:'
				oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminInfo := '_CONSULTARLOTERPSRESPOSTA:_LISTANFSE:_COMPNFSE:_NS4_NFSE:_NS4_INFNFSE:'
				oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminInfo := '_S_ENVELOPE:_S_BODY:_RECEPCIONARLOTERPSSINCRONORESPONSE:_ENVIARLOTERPSSINCRONORESPOSTA:_LISTANFSE:_COMPNFSE:_NFSE:_INFNFSE:'
				oXmlCaminh := WSAdvValue( oXml, cCaminInfo + "TEXT","string" )
			ENDIF

			If cCodMun = "3525904" .OR. cCodMun = "3519071"  //Jundiai ou Hortolandia
				cDataEmiss := WSAdvValue( oXml, cCaminInfo + "_NS4_DATAEMISSAO:TEXT","string" )
				if !EMPTY(cDataEmiss)
					cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
					cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
					cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				ENDIF

				cNumFNSe   := WSAdvValue( oXml, cCaminInfo + "_NS4_NUMERO:TEXT","string" )
				cCodVerf   := WSAdvValue( oXml, cCaminInfo + "_NS4_CODIGOVERIFICACAO:TEXT","string" )
				cCpfCnpj   := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_IDENTIFICACAOPRESTADOR:_NS4_CNPJ:TEXT","string" )

				if EMPTY( cCpfCnpj )
					cCpfCnpj    := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_IDENTIFICACAOPRESTADOR:_NS4_CPF:TEXT","string" )
					if !EMPTY( cCpfCnpj )
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
					ENDIF
				else
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				ENDIF

				If EMPTY( cCpfCnpj )
					cCpfCnpj    := SM0->M0_CGC
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				EndIf

				cInscMunic := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_IDENTIFICACAOPRESTADOR:_NS4_INSCRICAOMUNICIPAL:TEXT","string" )
				If Empty(cInscMunic)
					cInscMunic  := SM0->M0_INSCM
				EndIf
				cRazaoSoci := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_RAZAOSOCIAL:TEXT","string" )
				cBairro    := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_ENDERECO:_NS4_BAIRRO:TEXT","string" )
				cEndereco  := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_ENDERECO:_NS4_ENDERECO:TEXT","string" )
				cUF        := WSAdvValue( oXml, cCaminInfo + "_NS4_PRESTADORSERVICO:_NS4_ENDERECO:_NS4_UF:TEXT","string" )
			Else
				cDataEmiss := WSAdvValue( oXml, cCaminInfo + "_DATAEMISSAO:TEXT","string" )
				if !EMPTY(cDataEmiss)
					cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
					cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
					cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				ENDIF

				cNumFNSe   := WSAdvValue( oXml, cCaminInfo + "_NUMERO:TEXT","string" )
				cCodVerf   := WSAdvValue( oXml, cCaminInfo + "_CODIGOVERIFICACAO:TEXT","string" )
				cCpfCnpj   := WSAdvValue( oXml, cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_CPFCNPJ:_CNPJ:TEXT","string" )

				if EMPTY( cCpfCnpj )
					cCpfCnpj    := WSAdvValue( oXml, cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_CPFCNPJ:_CPF:TEXT","string" )
					if !EMPTY( cCpfCnpj )
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
					ENDIF
				else
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				ENDIF

				If EMPTY( cCpfCnpj )
					cCpfCnpj    := SM0->M0_CGC
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				EndIf

				cInscMunic := WSAdvValue( oXml, cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
				If Empty(cInscMunic)
					cInscMunic  := SM0->M0_INSCM
				EndIf
				cRazaoSoci := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_RAZAOSOCIAL:TEXT","string" )
				cBairro    := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_BAIRRO:TEXT","string" )
				cEndereco  := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_ENDERECO:TEXT","string" )
				cUF        := WSAdvValue( oXml, cCaminInfo + "_PRESTADORSERVICO:_ENDERECO:_UF:TEXT","string" )
			EndIf
		elseIf nTipoXML = 2
			Do Case
			Case cCodMun = "4205407"  //Florianopolis
				cDataEmiss  := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_DATAEMISSAO:TEXT","string" )
				cDataEmiss 	:= DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				cHoraEmiss  := SF2->F2_HORA
				cNumFNSe    := AllTrim(SF2->F2_NFELETR)
				cCodVerf    := AllTrim(SF2->F2_CODNFE)
				cCpfCnpj    := SM0->M0_CGC
				cInscMunic  := SM0->M0_INSCM
				cRazaoSoci  := SM0->M0_NOMECOM
				cBairro     := SM0->M0_BAIRCOB
				cEndereco   := SM0->M0_ENDCOB
				cUF         := SM0->M0_ESTCOB
			Case cCodMun = "5300108" //Brasilia
				cDataEmiss  := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_RPS:_DATAEMISSAO:TEXT","string" )
				cDataEmiss  := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				cHoraEmiss  := SF2->F2_HORA
				cNumFNSe    := AllTrim(SF2->F2_NFELETR)
				cCodVerf    := AllTrim(SF2->F2_CODNFE)
				cCpfCnpj    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
				cInscMunic  := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_PRESTADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
				cRazaoSoci  := SM0->M0_NOMECOM
				cBairro     := SM0->M0_BAIRCOB
				cEndereco   := SM0->M0_ENDCOB
				cUF         := SM0->M0_ESTCOB
			Case cCodMun = "2611606" .OR. cCodMun = "3106200" //Recife e Belo Horizonte
				cDataEmiss  := WSAdvValue( oXml, "_INFRPS:_DATAEMISSAO:TEXT","string" )
				if !EMPTY(cDataEmiss)
					cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
					cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
					cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				ENDIF
				cNumFNSe    := AllTrim(SF2->F2_NFELETR)
				cCodVerf    := AllTrim(SF2->F2_CODNFE)
				cCpfCnpj    := WSAdvValue( oXml, "_INFRPS:_PRESTADOR:_CNPJ:TEXT","string" )
				cInscMunic  := WSAdvValue( oXml, "_INFRPS:_PRESTADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
				cRazaoSoci  := SM0->M0_NOMECOM
				cBairro     := SM0->M0_BAIRCOB
				cEndereco   := SM0->M0_ENDCOB
				cUF         := SM0->M0_ESTCOB
			Case cCodMun = "1302603" //Manaus
				cDataEmiss  := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_DATAEMISSAO:TEXT","string" )
				if !EMPTY(cDataEmiss)
					cHoraEmiss := SUBSTR( cDataEmiss, at('T', cDataEmiss) + 1, 5)
					cDataEmiss := SUBSTR( cDataEmiss, 1, at('T', cDataEmiss) -1 )
					cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				ENDIF
				cNumFNSe    := AllTrim(SF2->F2_NFELETR)
				cCodVerf    := AllTrim(SF2->F2_CODNFE)
				cCpfCnpj    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_PRESTADOR:_TIPOS_CNPJ:TEXT","string" )
				cInscMunic  := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_PRESTADOR:_TIPOS_INSCRICAOMUNICIPAL:TEXT","string" )
				cRazaoSoci  := SM0->M0_NOMECOM
				cBairro     := SM0->M0_BAIRCOB
				cEndereco   := SM0->M0_ENDCOB
				cUF         := SM0->M0_ESTCOB
			EndCase
		EndIf
	ELSEIF UPPER( cTipoArq ) == 'JSON'
		If nTipoXML = 2
			Do Case
				Case cCodMun = "3556701" //Vinhedo
			    cDataEmiss  := SUBSTR( cTextArq, AT("DataEmissao", cTextArq) + 14, 10) 
				if !EMPTY(cDataEmiss)
					cDataEmiss := DTOC(STOD(REPLACE(cDataEmiss, '-', '')))
				ENDIF
				cHoraEmiss  := SF2->F2_HORA
				cNumFNSe    := AllTrim(SF2->F2_NFELETR)
				cCodVerf    := AllTrim(SF2->F2_CODNFE)
				cCpfCnpj    := SM0->M0_CGC
				cInscMunic  := SM0->M0_INSCM
				cRazaoSoci  := SM0->M0_NOMECOM
				cBairro     := SM0->M0_BAIRCOB
				cEndereco   := SM0->M0_ENDCOB
				cUF         := SM0->M0_ESTCOB
			EndCase
		EndIf
	ENDIF

	if at('/', cArquiv) > 0
		aArquivo := strtokarr(cArquiv, "/")
	elseif at('\', cArquiv) > 0
		aArquivo := strtokarr(cArquiv, "\")
	ENDIF

	cArquivo := aArquivo[len(aArquivo)]
	cArquivo := SUBSTR( cArquivo, 1, at('.', cArquivo) - 1)
	cArquivo := cArquivo + '.pdf'

	cCaminho := 'C:\TEMP\NFSERVICO\'+cfilant+'\PDF\'
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
		If nTipoXML = 1
			cCaminToma := cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADOR:"
			oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )

			if oXmlCaminh == NIL
				cCaminToma := cCaminInfo + "_DECLARACAOPRESTACAOSERVICO:_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:"
				oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminToma := cCaminInfo + "_TOMADORSERVICO:"
				oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )
			ENDIF

			if oXmlCaminh == NIL
				cCaminToma := cCaminInfo + "_NS4_TOMADORSERVICO:"
				oXmlCaminh := WSAdvValue( oXml, cCaminToma + "TEXT","string" )
			ENDIF
			
			If cCodMun = "3525904" .OR. cCodMun = "3519071"  //Jundiai ou Hortolandia
				cCpfCnpj   := WSAdvValue( oXml, cCaminToma + "_NS4_IDENTIFICACAOTOMADOR:_NS4_CPFCNPJ:_NS4_CNPJ:TEXT","string" )
				if EMPTY( cCpfCnpj )
					cCpfCnpj    := WSAdvValue( oXml, cCaminToma + "_NS4_IDENTIFICACAOTOMADOR:_NS4_CPFCNPJ:_NS4_CPF:TEXT","string" )
					if !EMPTY( cCpfCnpj )
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
					ENDIF
				else
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				ENDIF
				cInscMunic := WSAdvValue( oXml, cCaminToma + "_NS4_IDENTIFICACAOTOMADOR:_NS4_INSCRICAOMUNICIPAL:TEXT","string" )
				cRazaoSoci := WSAdvValue( oXml, cCaminToma + "_NS4_RAZAOSOCIAL:TEXT","string" )
				cBairro    := WSAdvValue( oXml, cCaminToma + "_NS4_ENDERECO:_NS4_BAIRRO:TEXT","string" )
				cEndereco  := WSAdvValue( oXml, cCaminToma + "_NS4_ENDERECO:_NS4_ENDERECO:TEXT","string" )
				cUF        := WSAdvValue( oXml, cCaminToma + "_NS4_ENDERECO:_NS4_UF:TEXT","string" )
			Else
				cCpfCnpj   := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
				if EMPTY( cCpfCnpj )
					cCpfCnpj    := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT","string" )
					if !EMPTY( cCpfCnpj )
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
					ENDIF
				else
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
				ENDIF
				If cCodMun = "3205200"  //Vila Velha
					cInscMunic := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
					cRazaoSoci := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_RAZAOSOCIAL:TEXT","string" )
					cBairro    := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_ENDERECO:_BAIRRO:TEXT","string" )
					cEndereco  := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_ENDERECO:_ENDERECO:TEXT","string" )
					cUF        := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_ENDERECO:_UF:TEXT","string" )
				Else
					cInscMunic := WSAdvValue( oXml, cCaminToma + "_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
					cRazaoSoci := WSAdvValue( oXml, cCaminToma + "_RAZAOSOCIAL:TEXT","string" )
					cBairro    := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_BAIRRO:TEXT","string" )
					cEndereco  := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_ENDERECO:TEXT","string" )
					cUF        := WSAdvValue( oXml, cCaminToma + "_ENDERECO:_UF:TEXT","string" )
				EndIf
			EndIf
		ElseIf nTipoXML = 2
            Do Case
                Case cCodMun = "4205407"  //Florianopolis
					cCpfCnpj    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_IDENTIFICACAOTOMADOR:TEXT","string" )
					cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
					cInscMunic  := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_INSCRICAOMUNICIPALTOMADOR:TEXT","string" )
					cRazaoSoci  := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_RAZAOSOCIALTOMADOR:TEXT","string" )
					cBairro     := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_BAIRROTOMADOR:TEXT","string" )
					cEndereco   := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_LOGRADOUROTOMADOR:TEXT","string" )
					cUF         := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_UFTOMADOR:TEXT","string" )
                Case cCodMun = "5300108" //Brasilia
					cCpfCnpj    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
					if EMPTY( cCpfCnpj )
						cCpfCnpj    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT","string" )
						if !EMPTY( cCpfCnpj )
							cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
						ENDIF
					else
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
					ENDIF
					cInscMunic  := ""
					cRazaoSoci  := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_RAZAOSOCIAL:TEXT","string" )
					cBairro     := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_ENDERECO:_BAIRRO:TEXT","string" )
					cEndereco   := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_ENDERECO:_ENDERECO:TEXT","string" )
					cUF         := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_TOMADORSERVICO:_ENDERECO:_UF:TEXT","string" )
                Case cCodMun = "2611606" .OR. cCodMun = "3106200" //Recife e Belo Horizonte
					cCpfCnpj    := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CNPJ:TEXT","string" )
					if EMPTY( cCpfCnpj )
						cCpfCnpj    := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_IDENTIFICACAOTOMADOR:_CPFCNPJ:_CPF:TEXT","string" )
						if !EMPTY( cCpfCnpj )
							cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
						ENDIF
					else
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
					ENDIF
					cInscMunic  := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_IDENTIFICACAOTOMADOR:_INSCRICAOMUNICIPAL:TEXT","string" )
					cRazaoSoci  := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_RAZAOSOCIAL:TEXT","string" )
					cBairro     := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_ENDERECO:_BAIRRO:TEXT","string" )
					cEndereco   := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_ENDERECO:_ENDERECO:TEXT","string" )
					cUF         := WSAdvValue( oXml, "_INFRPS:_TOMADOR:_ENDERECO:_UF:TEXT","string" )
                Case cCodMun = "1302603" //Manaus
					cCpfCnpj    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_IDENTIFICACAOTOMADOR:_TIPOS_CPFCNPJ:_TIPOS_CNPJ:TEXT","string" )
					if EMPTY( cCpfCnpj )
						cCpfCnpj    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_IDENTIFICACAOTOMADOR:_TIPOS_CPFCNPJ:_TIPOS_CPF:TEXT","string" )
						if !EMPTY( cCpfCnpj )
							cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 999.999.999-99"))
						ENDIF
					else
						cCpfCnpj    := Alltrim(Transform(cCpfCnpj, "@R 99.999.999/9999-99"))
					ENDIF
					cInscMunic  := ""
					cRazaoSoci  := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_RAZAOSOCIAL:TEXT","string" )
					cBairro     := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_ENDERECO:_TIPOS_BAIRRO:TEXT","string" )
					cEndereco   := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_ENDERECO:_TIPOS_ENDERECO:TEXT","string" )
					cUF         := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_TOMADOR:_TIPOS_ENDERECO:_TIPOS_UF:TEXT","string" )
            EndCase
		EndIf
	ELSEIF UPPER( cTipoArq ) == 'JSON'
		If nTipoXML = 2
			Do Case
				Case cCodMun = "3556701" //Vinhedo
					cCpfCnpj    := SUBSTR( cTextArq, AT("documentoTomador", cTextArq) + 19) 
					cCpfCnpj  	:= SUBSTR( cCpfCnpj, 1, AT('"', cCpfCnpj)-1)
					cInscMunic  := ""
					cRazaoSoci  := SUBSTR( cTextArq, AT("NomeTomador", cTextArq) + 14) 
					cRazaoSoci  := SUBSTR( cRazaoSoci, 1, AT('"', cRazaoSoci)-1) 
					cBairro     := SUBSTR( cTextArq, AT("bairroTomador", cTextArq) + 16) 
					cBairro     := SUBSTR( cBairro, 1, AT('"', cBairro)-1) 
					cEndereco   := SUBSTR( cTextArq, AT("logradouroTomador", cTextArq) + 20) 
					cEndereco   := SUBSTR( cEndereco, 1, AT('"', cEndereco)-1) 
					cUF         := SUBSTR( cTextArq, AT("ufTomador", cTextArq) + 12, 2) 
			EndCase
		EndIf
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

	if oXmlCaminh == NIL
		cCaminServ := cCaminInfo + '_NS4_SERVICO:'
		oXmlCaminh := WSAdvValue( oXml, cCaminServ + "TEXT","string" )
	ENDIF

	IF UPPER( cTipoArq ) == 'XML'
		If nTipoXML = 1
			If cCodMun = "3525904" .OR. cCodMun = "3519071"  //Jundiai ou Hortolandia
				cDescServi := WSAdvValue( oXml, cCaminServ + "_NS4_DISCRIMINACAO:TEXT","string" )
			Else
				cDescServi := WSAdvValue( oXml, cCaminServ + "_DISCRIMINACAO:TEXT","string" )
			EndIf
		ElseIf nTipoXML = 2
            Do Case
                Case cCodMun = "4205407"  //Florianopolis
					cDescServi	:= WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_ITENSSERVICO:_ITEMSERVICO:_DESCRICAOSERVICO:TEXT","string" )
                Case cCodMun = "5300108" //Brasilia
					cDescServi	:= WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_DISCRIMINACAO:TEXT","string" )
                Case cCodMun = "2611606" .OR. cCodMun = "3106200" //Recife e Belo Horizonte
					cDescServi	:= WSAdvValue( oXml, "_INFRPS:_SERVICO:_DISCRIMINACAO:TEXT","string" )
                Case cCodMun = "1302603" //Manaus
					cDescServi	:= WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_DISCRIMINACAO:TEXT","string" )
            EndCase
		EndIf
	ELSEIF UPPER( cTipoArq ) == 'JSON'
		If nTipoXML = 2
			Do Case
				Case cCodMun = "3556701" //Vinhedo
				    cDescServi  := SUBSTR( cTextArq, AT("observacao", cTextArq) + 14) 
					cDescServi 	:= SUBSTR( cDescServi, 1, AT('"', cDescServi)-1)
			EndCase
		EndIf
	ENDIF

	if !EMPTY( cDescServi )
		oPrintPvt:SayAlign(nLinAtu, nColIni,  cDescServi, oFontDetN, nColFin - 10, (nTamLin * 10), COR_PRETO, PAD_LEFT, 0)
	ENDIF

	nLinAtu += (nTamLin * 53)
	oPrintPvt:Line(nLinAtu, nColIni, nLinAtu, nColFin, COR_PRETO)

	IF UPPER( cTipoArq ) == 'XML'
		If nTipoXML = 1
		    If cCodMun = "3525904" .OR. cCodMun = "3519071"  //Jundiai ou Hortolandia
				cValorServ := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORSERVICOS:TEXT","string" )
				if !EMPTY( cValorServ )
					cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cINSS   := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORINSS:TEXT","string" )
				if !EMPTY( cINSS )
					cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cIRRF   := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORIR:TEXT","string" )
				if !EMPTY( cIRRF )
					cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cCSLL   := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORCSLL:TEXT","string" )
				if !EMPTY( cCSLL )
					cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cCOFINS := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORCOFINS:TEXT","string" )
				if !EMPTY( cCOFINS )
					cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cPIS    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORPIS:TEXT","string" )
				if !EMPTY( cPIS )
					cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
			Else
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
			EndIf
		ElseIf nTipoXML = 2
            Do Case
                Case cCodMun = "4205407"  //Florianopolis
					cValorServ := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORTOTALSERVICOS:TEXT","string" )
					if !EMPTY( cValorServ )
						cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
					Else
						cValorServ    := ""
					ENDIF
					cINSS   := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORINSS:TEXT","string" )
					if !EMPTY( cINSS )
						cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cINSS    := ""
					ENDIF
					cIRRF   := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORIRRF:TEXT","string" )
					If cIRRF == NIL
						cIRRF	:= SUBSTR( cDescServi, at('IRRF:', cDescServi) + 6, 10)
						cIRRF	:= SUBSTR( cIRRF,  1, at('|', cIRRF)-1)
						cIRRF	:= STRTRAN( cIRRF, ',', '.' )
					EndIf
					if !EMPTY( cIRRF )
						cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
					Else
						cIRRF    := ""
					ENDIF
					cCSLL   := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORCSLL:TEXT","string" )
					If cCSLL == NIL
						cCSLL	:= SUBSTR( cDescServi, at('CSLL:', cDescServi) + 6, 10)
						cCSLL	:= SUBSTR( cCSLL,  1, at('|', cCSLL)-1)
						cCSLL	:= STRTRAN( cCSLL, ',', '.' )
					EndIf
					if !EMPTY( cCSLL )
						cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCSLL    := ""
					ENDIF
					cCOFINS := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORCOFINS:TEXT","string" )
					If cCOFINS == NIL
						cCOFINS	:= SUBSTR( cDescServi, at('COFINS:', cDescServi) + 8, 10)
						cCOFINS	:= SUBSTR( cCOFINS,  1, at('|', cCOFINS)-1)
						cCOFINS	:= STRTRAN( cCOFINS, ',', '.' )
					EndIf
					if !EMPTY( cCOFINS )
						cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCOFINS    := ""
					ENDIF
					cPIS    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORPIS:TEXT","string" )
					If cPIS == NIL
						cPIS	:= SUBSTR( cDescServi, at('PIS:', cDescServi) + 5, 10)
						cPIS	:= SUBSTR( cPIS,  1, at('|', cPIS)-1)
						cPIS	:= STRTRAN( cPIS, ',', '.' )
					EndIf
					if !EMPTY( cPIS )
						cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cPIS    := ""
					ENDIF
                Case cCodMun = "5300108" //Brasilia
					cValorServ := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORSERVICOS:TEXT","string" )
					if !EMPTY( cValorServ )
						cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
					Else
						cValorServ    := ""
					ENDIF
					cINSS   := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORINSS:TEXT","string" )
					if !EMPTY( cINSS )
						cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cINSS    := ""
					ENDIF
					cIRRF   := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORIRRF:TEXT","string" )
					if !EMPTY( cIRRF )
						cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
					Else
						cIRRF    := ""
					ENDIF
					cCSLL   := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCSLL:TEXT","string" )
					if !EMPTY( cCSLL )
						cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCSLL    := ""
					ENDIF
					cCOFINS := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCOFINS:TEXT","string" )
					if !EMPTY( cCOFINS )
						cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCOFINS    := ""
					ENDIF
					cPIS    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORPIS:TEXT","string" )
					if !EMPTY( cPIS )
						cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cPIS    := ""
					ENDIF
                Case cCodMun = "2611606" .OR. cCodMun = "3106200" //Recife e Belo Horizonte
					cValorServ := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORSERVICOS:TEXT","string" )
					if !EMPTY( cValorServ )
						cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
					Else
						cValorServ    := ""
					ENDIF
					cINSS   := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORINSS:TEXT","string" )
					if !EMPTY( cINSS )
						cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cINSS    := ""
					ENDIF
					cIRRF   := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORIRRF:TEXT","string" )
					if !EMPTY( cIRRF )
						cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
					Else
						cIRRF    := ""
					ENDIF
					cCSLL   := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORCSLL:TEXT","string" )
					if !EMPTY( cCSLL )
						cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCSLL    := ""
					ENDIF
					cCOFINS := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORCOFINS:TEXT","string" )
					if !EMPTY( cCOFINS )
						cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCOFINS    := ""
					ENDIF
					cPIS    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORPIS:TEXT","string" )
					if !EMPTY( cPIS )
						cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cPIS    := ""
					ENDIF
                Case cCodMun = "1302603" //Manaus
					cValorServ := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORSERVICOS:TEXT","string" )
					if !EMPTY( cValorServ )
						cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
					Else
						cValorServ    := ""
					ENDIF
					cINSS   := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORINSS:TEXT","string" )
					if !EMPTY( cINSS )
						cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cINSS    := ""
					ENDIF
					cIRRF   := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORIRRF:TEXT","string" )
					if !EMPTY( cIRRF )
						cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
					Else
						cIRRF    := ""
					ENDIF
					cCSLL   := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORCSLL:TEXT","string" )
					if !EMPTY( cCSLL )
						cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCSLL    := ""
					ENDIF
					cCOFINS := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORCOFINS:TEXT","string" )
					if !EMPTY( cCOFINS )
						cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCOFINS    := ""
					ENDIF
					cPIS    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORPIS:TEXT","string" )
					if !EMPTY( cPIS )
						cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cPIS    := ""
					ENDIF
            EndCase
		EndIf
	ELSEIF UPPER( cTipoArq ) == 'JSON'
		If nTipoXML = 2
			Do Case
				Case cCodMun = "3556701" //Vinhedo
				    cValorServ  := SUBSTR( cTextArq, AT("valorTotalNota", cTextArq) + 17) 
					cValorServ 	:= SUBSTR( cValorServ, 1, AT('"', cValorServ)-1)
					if !EMPTY( cValorServ )
						cValorServ := Alltrim(Transform(val(cValorServ), PesqPict("SF2","F2_VALBRUT")))
					Else
						cValorServ    := ""
					ENDIF
				    cINSS  		:= SUBSTR( cTextArq, AT("INSS", cTextArq) + 7) 
					cINSS 		:= SUBSTR( cINSS, 1, AT('"', cINSS)-1)
					if !EMPTY( cINSS )
						cINSS := Alltrim(Transform(val(cINSS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cINSS    := ""
					ENDIF
				    cIRRF  		:= SUBSTR( cTextArq, AT("IRRF", cTextArq) + 7) 
					cIRRF 		:= SUBSTR( cIRRF, 1, AT('"', cIRRF)-1)
					if !EMPTY( cIRRF )
						cIRRF := Alltrim(Transform(val(cIRRF), PesqPict("SF2","F2_VALBRUT")))
					Else
						cIRRF    := ""
					ENDIF
				    cCSLL  		:= SUBSTR( cTextArq, AT("CSLL", cTextArq) + 7) 
					cCSLL 		:= SUBSTR( cCSLL, 1, AT('"', cCSLL)-1)
					if !EMPTY( cCSLL )
						cCSLL := Alltrim(Transform(val(cCSLL), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCSLL    := ""
					ENDIF
				    cCOFINS  	:= SUBSTR( cTextArq, AT("COFINS", cTextArq) + 9) 
					cCOFINS 	:= SUBSTR( cCOFINS, 1, AT('"', cCOFINS)-1)
					if !EMPTY( cCOFINS )
						cCOFINS := Alltrim(Transform(val(cCOFINS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCOFINS    := ""
					ENDIF
				    cPIS  		:= SUBSTR( cTextArq, AT("PISPASEP", cTextArq) + 11) 
					cPIS 		:= SUBSTR( cPIS, 1, AT('"', cPIS)-1)
					if !EMPTY( cPIS )
						cPIS := Alltrim(Transform(val(cPIS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cPIS    := ""
					ENDIF
			EndCase
		EndIf
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
		If nTipoXML = 1
			If cCodMun = "3525904" .OR. cCodMun = "3519071"  //Jundiai ou Hortolandia
				cDeducoes    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORDEDUCOES:TEXT","string" )
				if !EMPTY( cDeducoes )
					cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cBaseCalc    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_BASECALCULO:TEXT","string" )
				if !EMPTY( cBaseCalc )
					cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cAliquota    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_ALIQUOTA:TEXT","string" )
				if !EMPTY( cAliquota )
					cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cISS    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORISS:TEXT","string" )
				if !EMPTY( cISS )
					cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cCredito    := WSAdvValue( oXml, cCaminServ + "_NS4_VALORES:_NS4_VALORCREDITO:TEXT","string" )
				if !EMPTY( cCredito )
					cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
			ElseIf cCodMun = "5300108"
				cDeducoes    := WSAdvValue( oXml, cCaminInfo + "_VALORESNFSE:_VALORDEDUCOES:TEXT","string" )
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
				cCredito    := WSAdvValue( oXml, cCaminInfo + "_VALORESNFSE:_VALORCREDITO:TEXT","string" )
				if !EMPTY( cCredito )
					cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
            Else
				cDeducoes    := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORDEDUCOES:TEXT","string" )
				if !EMPTY( cDeducoes )
					cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cBaseCalc    := WSAdvValue( oXml, cCaminServ + "_VALORES:_BASECALCULO:TEXT","string" )
				if !EMPTY( cBaseCalc )
					cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cAliquota    := WSAdvValue( oXml, cCaminServ + "_VALORES:_ALIQUOTA:TEXT","string" )
				if !EMPTY( cAliquota )
					cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cISS    := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORISS:TEXT","string" )
				if !EMPTY( cISS )
					cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
				cCredito    := WSAdvValue( oXml, cCaminServ + "_VALORES:_VALORCREDITO:TEXT","string" )
				if !EMPTY( cCredito )
					cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
				ENDIF
			EndIf
		ElseIf nTipoXML = 2
            Do Case
                Case cCodMun = "4205407"  //Florianopolis
					cDeducoes    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORDEDUCOES:TEXT","string" )
					if !EMPTY( cDeducoes )
						cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
					ENDIF
					cBaseCalc    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_ITENSSERVICO:_ITEMSERVICO:_BASECALCULO:TEXT","string" )
					if !EMPTY( cBaseCalc )
						cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
					ENDIF
					cAliquota    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_ITENSSERVICO:_ITEMSERVICO:_ALIQUOTA:TEXT","string" )
					if !EMPTY( cAliquota )
						cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
					ENDIF
					cISS    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORISS:TEXT","string" )
					if !EMPTY( cISS )
						cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
					ENDIF
					cCredito    := WSAdvValue( oXml, "_XMLPROCESSAMENTONFPSE:_VALORCREDITO:TEXT","string" )
					if !EMPTY( cCredito )
						cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
					ENDIF
                Case cCodMun = "5300108" //Brasilia
					cDeducoes    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORDEDUCOES:TEXT","string" )
					if !EMPTY( cDeducoes )
						cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
					Else
						cDeducoes    := ""
					ENDIF
					cBaseCalc    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_BASECALCULO:TEXT","string" )
					if !EMPTY( cBaseCalc )
						cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
					Else
						cBaseCalc    := ""
					ENDIF
					cAliquota    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_ALIQUOTA:TEXT","string" )
					if !EMPTY( cAliquota )
						cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
					Else
						cAliquota    := ""
					ENDIF
					cISS    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORISS:TEXT","string" )
					if !EMPTY( cISS )
						cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cISS    := ""
					ENDIF
					cCredito    := WSAdvValue( oXml, "_INFDECLARACAOPRESTACAOSERVICO:_SERVICO:_VALORES:_VALORCREDITO:TEXT","string" )
					if !EMPTY( cCredito )
						cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCredito    := ""
					ENDIF
                Case cCodMun = "2611606" .OR. cCodMun = "3106200" //Recife e Belo Horizonte
					cDeducoes    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORDEDUCOES:TEXT","string" )
					if !EMPTY( cDeducoes )
						cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
					Else
						cDeducoes    := ""
					ENDIF
					cBaseCalc    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_BASECALCULO:TEXT","string" )
					if !EMPTY( cBaseCalc )
						cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
					Else
						cBaseCalc    := ""
					ENDIF
					cAliquota    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_ALIQUOTA:TEXT","string" )
					if !EMPTY( cAliquota )
						cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
					Else
						cAliquota    := ""
					ENDIF
					cISS    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORISS:TEXT","string" )
					if !EMPTY( cISS )
						cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cISS    := ""
					ENDIF
					cCredito    := WSAdvValue( oXml, "_INFRPS:_SERVICO:_VALORES:_VALORCREDITO:TEXT","string" )
					if !EMPTY( cCredito )
						cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCredito    := ""
					ENDIF
                Case cCodMun = "1302603" //Manaus
					cDeducoes    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORDEDUCOES:TEXT","string" )
					if !EMPTY( cDeducoes )
						cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
					Else
						cDeducoes    := ""
					ENDIF
					cBaseCalc    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_BASECALCULO:TEXT","string" )
					if !EMPTY( cBaseCalc )
						cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
					Else
						cBaseCalc    := ""
					ENDIF
					cAliquota    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_ALIQUOTA:TEXT","string" )
					if !EMPTY( cAliquota )
						cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
					Else
						cAliquota    := ""
					ENDIF
					cISS    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORISS:TEXT","string" )
					if !EMPTY( cISS )
						cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cISS    := ""
					ENDIF
					cCredito    := WSAdvValue( oXml, "_TIPOS_INFRPS:_TIPOS_SERVICO:_TIPOS_VALORES:_TIPOS_VALORCREDITO:TEXT","string" )
					if !EMPTY( cCredito )
						cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCredito    := ""
					ENDIF
            EndCase
		EndIf
	ELSEIF UPPER( cTipoArq ) == 'JSON'
		If nTipoXML = 2
			Do Case
				Case cCodMun = "3556701" //Vinhedo
				    cDeducoes  := SUBSTR( cTextArq, AT("valorDeducao", cTextArq) + 15) 
					cDeducoes 	:= SUBSTR( cDeducoes, 1, AT('"', cDeducoes)-1)
					if !EMPTY( cDeducoes )
						cDeducoes := Alltrim(Transform(val(cDeducoes), PesqPict("SF2","F2_VALBRUT")))
					Else
						cDeducoes    := ""
					ENDIF
				    cBaseCalc  		:= SUBSTR( cTextArq, AT("baseCalculo", cTextArq) + 14) 
					cBaseCalc 		:= SUBSTR( cBaseCalc, 1, AT('"', cBaseCalc)-1)
					if !EMPTY( cBaseCalc )
						cBaseCalc := Alltrim(Transform(val(cBaseCalc), PesqPict("SF2","F2_VALBRUT")))
					Else
						cBaseCalc    := ""
					ENDIF
				    cAliquota  		:= SUBSTR( cTextArq, AT("aliquota", cTextArq) + 11) 
					cAliquota 		:= SUBSTR( cAliquota, 1, AT('"', cAliquota)-1)
					if !EMPTY( cAliquota )
						cAliquota := Alltrim(Transform(val(cAliquota), PesqPict("SF2","F2_VALBRUT")))
					Else
						cAliquota    := ""
					ENDIF
				    cISS  		:= SUBSTR( cTextArq, AT("valorIss", cTextArq) + 11) 
					cISS 		:= SUBSTR( cISS, 1, AT('"', cISS)-1)
					if !EMPTY( cISS )
						cISS := Alltrim(Transform(val(cISS), PesqPict("SF2","F2_VALBRUT")))
					Else
						cISS    := ""
					ENDIF
				    cCredito  	:= SUBSTR( cTextArq, AT("valorCredito", cTextArq) + 15) 
					cCredito 	:= SUBSTR( cCredito, 1, AT('"', cCredito)-1)
					if !EMPTY( cCredito )
						cCredito := Alltrim(Transform(val(cCredito), PesqPict("SF2","F2_VALBRUT")))
					Else
						cCredito    := ""
					ENDIF
			EndCase
		EndIf
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
