#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF   6

/*/{Protheus.doc} MARDOC01
MARDOC01 - Geracao de Documentos
@author Wagner Neves / Vanderlei Miguel
@since 17/06/2024
@version 1.0
@type function
/*/
User Function MARDOC01()
	Local aArea     := GetArea()
	Local cBcoAtual := ""
	Local cCodBanco := PadR("237"		, TamSX3('EE_CODIGO')[1])
	Local cCodAgenc := PadR("3393"		, TamSX3('EE_AGENCIA')[1])
	Local cCodConta := PadR("3510"		, TamSX3('EE_CONTA')[1])
	Local cDoc      := PadR("000295240"	, TamSX3('F2_DOC')[1])
	Local cSerie    := PadR("001"		, TamSX3('F2_SERIE')[1])
	Local cFileXML  := ""
	Local cFileBOL  := ""
	Local cFileNFE  := ""
	Local cParc     := ""
	Local cData     := ""
	Private cPath   := ""
	Private lPosFat := .T.

	//Gera banco atual (Codigo + agencia + conta)
	cBcoAtual := cCodBanco + cCodAgenc + cCodConta

	//Busca dados da SE1 e SA1 para gerar boleto, xml e NFE
	SE1->(dbsetorder(1))
	If SE1->(dbSeek(xFilial('SE1') + cSerie + cDoc))
		cParc	:= SE1->E1_PARCELA
		cData   := StrTran(DTOC(SE1->E1_EMISSAO), "/", "")
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek( xFilial("SA1") + SE1->(E1_CLIENTE+E1_LOJA)))
			cCGC	:= AllTrim(SA1->A1_CGC)

			//Define path para guardar arquivos
			cPath	:= "\Anexos\" + cCGC + "\" + xFilial('SE1') + "\" + cData + "\NF" +  cDoc + cSerie + "\"
			cPath   := GetTempPath()

			//Verifica se caminho existe
			If !file(Substr(cPath,1,len(cPath)-1))
				MAKEDIR(cPath)
			Endif

			//Gera XML
			cFileXML   	:= "XML" + AllTrim(cDoc) + AllTrim(cParc)
			fGeraXML(cDoc, cSerie, cFileXML)

			//Gera Boleto
			cFileBOL   	:= "BOL" + AllTrim(cDoc) + AllTrim(cParc)
			fGerBol(cDoc, cSerie, cBcoAtual, cFileBOL)

			//Gera Danfe
			cFileNFE   	:= "NFE" + AllTrim(cDoc) + AllTrim(cParc)
			fGerDanfe(cDoc, cSerie, cFileNFE)
		EndIf
	EndIf

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fGerBol                                                      |
 | Desc:  Função que gera boleto 				                       |
 *---------------------------------------------------------------------*/
Static Function fGerBol(cDoc, cSerie, cBcoAtual, cFile)
	Local aArea     := GetArea()
	Local lImpresso		:= .F.
	Local lImpBol	  	:= .F.
	Local lRet    		:= .T.
	Private nPBonif   	:= 0
	Private nVlrBonif 	:= 0
	Private nCntReg   	:= 0
	Private nCB1Linha	:= 14.5   //GETMV("PV_BOL_LI1") //14.5
	Private nCB2Linha	:= 26.1   //GETMV("PV_BOL_LI2") //26.1
	Private nCBColuna	:= 1.3    //GETMV("PV_BOL_COL") //1.3
	Private nCBLargura	:= 0.0280 //GETMV("PV_BOL_LAR") //0.0280
	Private nCBAltura	:= 1.4    //GETMV("PV_BOL_ALT") //1.4
	Private cAliasSE1  	:= GetNextAlias()
	Private cFileOrig 	:= " "
	Private cChvBcoCC 	:= ''
	Private cNossoPad 	:= ''
	Private cNosso    	:= ''
	Private cBenefic  	:= ''
	Private nOpc       := 0
	Private cTitulo    := "Impressao do Boleto Laser"
	Private aDesc      := {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
	Private cIndexName := ''
	Private cIndexKey  := ''
	Private cFilter    := ''
	Private cLogoBanco := ""
	Private Nlinha     := ""
	Private cLogoItabom:= "LogoAgroFoods.BMP" //AJUSTAR

	// ----------------------------------------------------------------+
	// Busca Títulos                                                   |
	// ----------------------------------------------------------------+	
	cQuery := " SELECT *, SE1.R_E_C_N_O_ AS REG  "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += "  LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "  ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_='' "
	cQuery += " WHERE E1_FILIAL='"+xFilial('SE1')+"' "
	cQuery += " AND E1_NUM = '"+cDoc+"' AND E1_PREFIXO = '"+cSerie+"' "
	cQuery += "  AND SE1.E1_TIPO <> 'AB-'  "
	cQuery += "  AND SE1.D_E_L_E_T_='' "
	cQuery += " ORDER BY E1_NUM, E1_PARCELA	"
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSE1, .F., .T.)

	// ----------------------------------------------------------------+
	// Atualiza Titulo com banco selecionado na rotina de faturamento  |
	// ----------------------------------------------------------------+
	(cAliasSE1)->(DbGoTop())
	If lPosFat
		While !(cAliasSE1)->(EOF())

			cQuery := " UPDATE " + RETSQLNAME("SE1")
			cQuery += " SET "
			cQuery += "   E1_PORTADO = '"+SubStr(cBcoAtual,1,3)+"', "
			cQuery += "   E1_AGEDEP  = '"+SubStr(cBcoAtual,4,5)+"', "
			cQuery += "   E1_CONTA   = '"+SubStr(cBcoAtual,9)+"' "
			cQuery += " WHERE R_E_C_N_O_ = " +AllTrim(Str((cAliasSE1)->REG))+ " "
			TcSqlExec(cQuery)

			// ----------------------------------------------------------------+
			// Nomeia Arquivo                                                  |
			// ----------------------------------------------------------------+
			cFileOrig 	:= cPath + cFile +".pdf"
			// ----------------------------------------------------------------+
			// Instanciando classe FWMSPrinter                                 |
			// ----------------------------------------------------------------+
			oPrint := FWMSPrinter():New(cFile,IMP_PDF,.F.,cPath,.T.,,@oPrint, "",.T.,,,.F.,1)
			// ----------------------------------------------------------------+
			// Define saida de impressão                                       |
			// ----------------------------------------------------------------+
			oPrint:SetResolution(78)
			// oPrint:SetPaperSize(9)
			oPrint:SetMargin(60,60,60,60)
			oPrint:SetPortrait()
			oPrint:cPathPDF := cPath
			If oPrint:CPRINTER == NIL
				Return( "" )
			Endif

			// ----------------------------------------------------------------+
			///Verifica se arquivo já existe                                   |
			// ----------------------------------------------------------------+
			If file( cFileOrig )
				ferase( cFileOrig )
			Endif

			// Posiciona no título a ser impresso
			SE1->(dbSetOrder(1))
			If SE1->(dbSeek( xFilial("SE1") + (cAliasSE1)->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)))

				If Alltrim(SE1->E1_TIPO) == 'AB-'
					(cAliasSE1)->(DbSkip())
					Loop
				EndIf

				If Empty(cBcoAtual)//SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))	// Se já foi impresso (Banco preenchido), não passa pelas validações e "vai" direto para a impressão
					cBcoAtual := SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)
				EndIf

			EndIf

			//Validacoes
			SEE->(dbSetOrder(1)) //EE_CODIGO + EE_AGENCIA + EE_CONTA + EE_SUBCTA
			if SEE->(DbSeek(xFilial("SEE")+cBcoAtual))
				cNossoPad := StrZero(Val(SEE->EE_FAXATU),11)
				cChvBcoCC := SEE->EE_CODIGO + SEE->EE_AGENCIA + SEE->EE_CONTA + SEE->EE_SUBCTA //3 + 5 + 10 + 3

				SA6->(DbSetOrder(1))
				If SA6->(dbSeek(xFilial("SA6")+Substr(cChvBcoCC,1,18)))
					cBenefic	:= AllTrim(SA6->A6_NOME)

				Else
					MsgInfo('Banco '+AllTrim(SEE->EE_CODIGO)+' nao encontrado, operacao cancelada.')
					lRet := .F.
				Endif

			Else
				MsgInfo('Nao encontrado parametros do banco nesta filial, operacao cancelada')
				lRet := .F.

				If SEE->EE_FAXATU<SEE->EE_FAXINI .or. SEE->EE_FAXATU>SEE->EE_FAXFIM
					MsgInfo('BCO '+AllTrim(SEE->EE_CODIGO)+' - Nosso Numero fora da faixa padrao, favor verificar')
					lRet := .F.
				Endif
			EndIf
			// Não imprime boleto para bonificacao/doacao - Thiago Saggioro - 17/09/07
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial()+SE1->E1_NUM+SE1->E1_PREFIXO))
				If SF2->F2_COND == "901" .or. SF2->F2_COND == "902"
					lRet := .F.
				EndIf
			EndIf

			If !Empty(SE1->E1_NUMBCO)
				cNosso:=Left(SE1->E1_NUMBCO,11) // sem digito
			Else
				cNosso:= cNossoPad
			Endif

			// ----------------------------------------------------------------+
			// Chama rotina de Geração de Boleto                               |
			// ----------------------------------------------------------------+
			if lRet
				lImpresso := U_MARDOC02(cBcoAtual)
				If lImpresso
					lImpBol := .T.
				EndIf
			else
				Exit
			EndIf

			// ----------------------------------------------------------------+
			/// Libera Objeto                                                  |
			// ----------------------------------------------------------------+
			FreeObj(oPrint)
			(cAliasSE1)->(DbSkip())
		EndDo
	EndIf
	(cAliasSE1)->(DbCloseArea())

	If !lImpBol
		MsgBox ("Nenhum boleto gerado!!!","Informação","INFO")
	EndIf

	RestArea(aArea)
Return Nil

/*---------------------------------------------------------------------*
 | Func:  fGerDanfe                                                    |
 | Desc:  Função que gera Danfe 				                       |
 *---------------------------------------------------------------------*/
Static Function fGerDanfe(_cNota, _cSerie, cFile)
	Local aArea     := GetArea()
	Local cIdent    := ""
	Local oDanfe    := Nil
	Local lEnd      := .F.
	Local nTamNota  := TamSX3('F2_DOC')[1]
	Local nTamSerie := TamSX3('F2_SERIE')[1]
	Local cCliCNPJ  := ""
	Local _i
	Local nI
	Local _lRet     := .F.
	Private PixelX
	Private PixelY
	Private nConsNeg
	Private nConsTex
	Private oRetNF
	Private lPtImpBol
	Private aNotasBol
	Private nColAux

	//  Acha nota fiscal
	aStNotas := {}
	SF2->(dbsetorder(1))
	SF2->(dbSeek(xFilial('SF2') + _cNota + _cSerie))
	While SF2->(!eof()) .and. SF2->F2_FILIAL == xFilial("SF2") .and. Alltrim(sf2->f2_doc) == Alltrim(_cNota) .and. Alltrim(sf2->f2_serie) == Alltrim(_cSerie)
		
		If !Empty(SF2->F2_CHVNFE)
			aadd( aStNotas, {SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_EMISSAO, SF2->( Recno() )} )
		Endif
		
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek( xFilial("SA1") + SF2->(F2_CLIENTE + F2_LOJA)))
			cCliCNPJ	:= SA1->A1_CGC
		EndIf
		Exit
	End

	If Empty(Len(aStNotas))
		MsgAlert('Este PEDIDO nao possui DANFE transmitida. Verifique !!!', 'ATENCAO')
		_lRet := .F.
	Else
		_nTipo  := 2     		// 2= Saida
		cIdent := RetIdEnti()	// Pega o IDENT da empresa
		For _i := 1 to Len(aStNotas)
			_cSerie   	:= aStNotas[_i][1]
			_cDoc     	:= aStNotas[_i][2]
			_dEmis    	:= aStNotas[_i][3]
			SF2->(dbsetorder(1))
			SF2->(dbSeek(xFilial('SF2') + _cDoc + _cSerie))
			_lExibe   	:= .F.
			//Pega o IDENT da empresa
			cIdent 		:= RetIdEnti() //->Entidade

			//Define as perguntas da DANFE
			//Pergunte("NFSIGW",.F.)
			MV_PAR01 := PadR(_cNota,  nTamNota)     //Nota Inicial
			MV_PAR02 := PadR(_cNota,  nTamNota)     //Nota Final
			MV_PAR03 := PadR(_cSerie, nTamSerie)    //Série da Nota
			MV_PAR04 := 2                          //NF de Saida
			MV_PAR05 := 2                          //Frente e Verso = Nao
			MV_PAR06 := 2                          //DANFE simplificado = Nao
			MV_PAR07 := _dEmis
			MV_PAR08 := _dEmis

			//Define local para gravar arquivo
			cFileOrig 	:= cPath + cFile +".pdf"

			aImpressora := GetImpWindows(.F.)

			For nI := 1 to Len(aImpressora)
				IF Alltrim(aImpressora[nI]) $ "Microsoft Print to PDF|PDFCreator|Cute PDF Writer|PDF"
					oDanfe := FWMSPrinter():New(cFile, IMP_PDF, .F.,cPath , .T.)
					oDanfe:nDevice  := 6
					Exit
				EndIf
			Next

			oDanfe:SetResolution(78)
			oDanfe:SetPortrait()
			oDanfe:SetPaperSize(DMPAPER_A4)
			oDanfe:SetMargin(60, 60, 60, 60)

			//Força a impressão em PDF
//			oDanfe:nDevice  := 6
			oDanfe:cPathPDF := cPath
			oDanfe:lServer  := .F.
			oDanfe:lViewPDF := .F. //.T.

			// ----------------------------------------------------------------+
			///Verifica se arquivo já existe                                   |
			// ----------------------------------------------------------------+
			If file( cFileOrig )
				ferase( cFileOrig )
			Endif

			//Variáveis obrigatórias da DANFE
			PixelX    := oDanfe:nLogPixelX()
			PixelY    := oDanfe:nLogPixelY()
			nConsNeg  := 0.4
			nConsTex  := 0.5
			oRetNF    := Nil
			lPtImpBol := .F.
			aNotasBol := {}
			nColAux   := 0

			//Chamando a impressão da danfe no RDMAKE
			If RptStatus( {|lEnd| U_DANFEProc(@oDanfe, @lEnd, cIDEnt, Nil, Nil, .F., nil, nil)}, "Imprimindo DANFE..." )
				_lRet := .t.
				SF2->(dbsetorder(1))
				If SF2->(dbSeek(xFilial('SF2') + _cNota + _cSerie))
					Reclock("SF2",.f.)
					SF2->F2_ZIMP := 'S'
					MsUnlock("SF2")
				EndIf
			EndIf
			oDanfe:Print()
		Next
	EndIf

	FreeObj(oDanfe)
	oDanfe := Nil

	RestArea(aArea)

RETURN ()

/*---------------------------------------------------------------------*
 | Func:  fGeraXML                                                     |
 | Desc:  Função que gera xml    				                       |
 *---------------------------------------------------------------------*/
Static Function fGeraXML(cDocumento, cSerie, cFile)
    Local aArea        := GetArea()
    Local cURLTss      := PadR(GetNewPar("MV_SPEDURL","http://"),250)  
    Local oWebServ
    Local cIdEnt       := RetIdEnti()
    Local cTextoXML    := ""
    Local oFileXML
	Local lMostra      := .F.

	//Arquivo que sera gerado
	cArqXML	:= cPath + AllTrim(cFile) + ".xml"

    //Se tiver documento
    If !Empty(cDocumento)
        cDocumento := PadR(cDocumento, TamSX3('F2_DOC')[1])
        cSerie     := PadR(cSerie,     TamSX3('F2_SERIE')[1])
            
        //Instancia a conexão com o WebService do TSS    
        oWebServ:= WSNFeSBRA():New()
        oWebServ:cUSERTOKEN        := "TOTVS"
        oWebServ:cID_ENT           := cIdEnt
        oWebServ:oWSNFEID          := NFESBRA_NFES2():New()
        oWebServ:oWSNFEID:oWSNotas := NFESBRA_ARRAYOFNFESID2():New()
        aAdd(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2,NFESBRA_NFESID2():New())
        aTail(oWebServ:oWSNFEID:oWSNotas:oWSNFESID2):cID := (cSerie+cDocumento)
        oWebServ:nDIASPARAEXCLUSAO := 0
        oWebServ:_URL              := AllTrim(cURLTss)+"/NFeSBRA.apw"
            
        //Se tiver notas
        If oWebServ:RetornaNotas()
            
            //Se tiver dados
            If Len(oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3) > 0
                
                //Se tiver sido cancelada
                If oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA != Nil
                    cTextoXML := oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFECANCELADA:cXML
                        
                //Senão, pega o xml normal (foi alterado abaixo conforme dica do Jorge Alberto)
                Else
                    cTextoXML := '<?xml version="1.0" encoding="UTF-8"?>'
                    cTextoXML += '<nfeProc xmlns="http://www.portalfiscal.inf.br/nfe" versao="4.00">'
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXML
                    cTextoXML += oWebServ:oWsRetornaNotasResult:OWSNOTAS:oWSNFES3[1]:oWSNFE:cXMLPROT
                    cTextoXML += '</nfeProc>'
                EndIf
                    
                //Gera o arquivo
                oFileXML := FWFileWriter():New(cArqXML, .T.)
                oFileXML:SetEncodeUTF8(.T.)
                oFileXML:Create()
                oFileXML:Write(cTextoXML)
                oFileXML:Close()
                    
                //Se for para mostrar, será mostrado um aviso com o conteúdo
                If lMostra
                    Aviso("fGeraXML", cTextoXML, {"Ok"}, 3)
                EndIf
                    
            //Caso não encontre as notas, mostra mensagem
            Else
                ConOut("fGeraXML > Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...")
                    
                If lMostra
                    Aviso("fGeraXML", "Verificar parâmetros, documento e série não encontrados ("+cDocumento+"/"+cSerie+")...", {"Ok"}, 3)
                EndIf
            EndIf
            
        //Senão, houve erros na classe
        Else
            ConOut("fGeraXML > "+IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3))+"...")
                
            If lMostra
                Aviso("fGeraXML", IIf(Empty(GetWscError(3)), GetWscError(1), GetWscError(3)), {"Ok"}, 3)
            EndIf
        EndIf
    EndIf
    RestArea(aArea)
Return

