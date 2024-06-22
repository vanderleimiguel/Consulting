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
	Local cCodBanco := PadR("341"		, TamSX3('EE_CODIGO')[1])//237
	Local cCodAgenc := PadR("0002"		, TamSX3('EE_AGENCIA')[1])//3393
	Local cCodConta := PadR("67154"		, TamSX3('EE_CONTA')[1])//3510
	Local cDoc      := PadR("000295240"	, TamSX3('F2_DOC')[1])
	Local cSerie    := PadR("001"		, TamSX3('F2_SERIE')[1])
	Local cFileXML  := ""
	Local cFileBOL  := ""
	Local cFileNFE  := ""
	Local cParc     := ""
	Local cData     := ""
	Private cPath   := ""
	Private lPosFat := .T.
	Private oPrint	:= Nil
	Private oPrint2	:= Nil

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
			// cPath	:= "\Anexos\" + cCGC + "\" + xFilial('SE1') + "\" + cData + "\NF" +  cDoc + cSerie + "\"
			cPath   := GetTempPath()

			//Verifica se caminho existe
			If !file(Substr(cPath,1,len(cPath)-1))
				MAKEDIR(cPath)
			Endif

			//Gera XML
			cFileXML   	:= "XML" + AllTrim(cDoc) + AllTrim(cParc)
			fGeraXML(cDoc, cSerie, cFileXML)

			//Gera Danfe
			cFileNFE   	:= "NFE" + AllTrim(cDoc) + AllTrim(cParc)
			fGerDanfe(cDoc, cSerie, cFileNFE)

			//Gera Boleto
			cFileBOL   	:= "BOL" + AllTrim(cDoc) + AllTrim(cParc)
			fGrBolItau(cDoc, cSerie, cParc, cBcoAtual, cFileBOL)
			
			//Gera Boleto
			// cFileBOL   	:= "BOL" + AllTrim(cDoc) + AllTrim(cParc)
			// fGerBol(cDoc, cSerie, cBcoAtual, cFileBOL)

		EndIf
	EndIf

	RestArea(aArea)
Return

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


Static Function fGrBolItau(cDoc, cSerie, cParc, cBcoAtual, cFile)
	Local cBanco	:= ""
	Local cAgencia  := ""
    Local cConta    := ""
	Local cFileOrig := " "
	// Local lServer	 	  := .T.
	// Local lFormaTMSPrinter:= .T. // Mantem o legado de resolucao com a TMSPrinter
	// Local lDisableSetup   := .T. // Desabilita visualizacao do SETUP
	// Local lViewPDF        := .F. // Mostra o arquivo em tela
	Private nVlrDescAbat := 0
	Private nVlrImpRet   := 0
	Private nVlrCobrado  := 0
	Private aBitmap := {"/system/itau.bmp"}  //Logo do banco
	Private cMsgA   := ""//Alltrim(GetMV("MV_MSGBOLA"))
	// Private cMsgB   := Alltrim(GetMV("MV_MSGBOLB"))
	// Private cMsgC   := Alltrim(GetMV("MV_MSGBOLC"))
	Private lRet    := .T.
	Private oSN
	Private oDlgConsulta
	// Private nCB1Linha	:= 14.5   //GETMV("PV_BOL_LI1") //14.5
	// Private nCB2Linha	:= 26.1   //GETMV("PV_BOL_LI2") //26.1
	// Private nCBColuna	:= 1.3    //GETMV("PV_BOL_COL") //1.3
	// Private nCBLargura	:= 0.0280 //GETMV("PV_BOL_LAR") //0.0280
	// Private nCBAltura	:= 1.4    //GETMV("PV_BOL_ALT") //1.4
	// Posiciona na SZ5
	// dbSelectArea("SZ5")
	// dbSetOrder(1)
	// dbSeek( xFilial("SZ5")+PADR(MV_PAR01,TAMSX3('Z5_NUMSAP')[1])+PADR(MV_PAR02,TAMSX3('Z5_SERIE')[1]),.T. )

	// Variaveis da boleta
	M->DV_NNUM   := SPACE(1)
	M->DV_BARRA  := SPACE(1)
	M->cBARRA    := ""
	M->LineDig   := ""
	M->NumBoleta := ""
	M->nDigito   := ""
	M->Pedaco    := ""

	cBanco 		:= SubStr(cBcoAtual,1,TamSx3("EE_CODIGO")[1])
	cAgencia 	:= SubStr(cBcoAtual,(TamSx3("EE_CODIGO")[1]+1),TamSx3("EE_AGENCIA")[1])
	cConta		:= SubStr(cBcoAtual,9)

	//Paramentros de Impressao
	M->NFi      := cDoc
	M->NFf      := cDoc
	M->Serie    := cSerie
	M->Banco    := cBanco
	M->Ag       := cAgencia
	M->CC       := cConta
	M->Parc     := cParc

	// ----------------------------------------------------------------+
	// Nomeia Arquivo                                                  |
	// ----------------------------------------------------------------+
	cFileOrig 	:= cPath + cFile +".pdf"
	// ----------------------------------------------------------------+
	// Instanciando classe FWMSPrinter                                 |
	// ----------------------------------------------------------------+
	// oPrint := FWMSPrinter():New(cFile,IMP_PDF,.F.,cPath,.T.,,@oPrint, "",lServer,,,lViewPDF,1)
	// ----------------------------------------------------------------+
	// Define saida de impressão                                       |
	// ----------------------------------------------------------------+
	// oPrint:SetResolution(78)
	// // oPrint:SetPaperSize(9)
	// oPrint:SetMargin(60,60,60,60)
	// oPrint:SetPortrait()
	// oPrint:cPathPDF := cPath
	// 			// oPrint:SetPortrait()
	// 		oPrint:SetPaperSize(DMPAPER_A4)		//nota fiscal
	// If oPrint:CPRINTER == NIL
	// 	Return( "" )
	// Endif

		IF oPrint == Nil
			lPreview := .T.
			//http://tdn.totvs.com/display/public/mp/FWMsPrinter;jsessionid=2B0138EC0B28901E0E7F7744C699314F
			oPrint := FWMSPrinter():New(cFile,IMP_PDF,.T.,cPath,.T.,.F.,,,.F.)
			oPrint:cPathPDF := cPath
			oPrint:SetPortrait()
			oPrint:SetPaperSize(DMPAPER_A4)		//nota fiscal
		EndIF
	// ----------------------------------------------------------------+
	///Verifica se arquivo já existe                                   |
	// ----------------------------------------------------------------+
	If file( cFileOrig )
		ferase( cFileOrig )
	Endif

	// IF AllTrim(SM0->M0_CODFIL) == "01" 	//São Paulo
	// 	M->Ag 		:= "1608"
	// 	M->CC 		:= "518005"

	// ElseIF AllTrim(SM0->M0_CODFIL) = "02" 	//Rio de Janeiro
	// 	M->Ag := "3032"
	// 	M->CC := "440004"

	// ElseIF AllTrim(SM0->M0_CODFIL)="03" 	//Brasilia
	// 	M->Ag := "1528"
	// 	M->CC := "520040"

	// ElseIF AllTrim(SM0->M0_CODFIL)="04"     //Porto Alegre
	// 	M->Ag := "8546"
	// 	M->CC := "142400"
	// EndIF

	//Titulos dos Campos
	oFont1 :=     TFont():New("Arial"      		,09,10,,.F.,,,,,.F.)
	//Conteudo dos Campos
	oFont2 :=     TFont():New("Arial"      		,09,14,,.F.,,,,,.F.)
	//Nome do Banco
	oFont3Bold := TFont():New("Arial Black"		,09,10,,.T.,,,,,.F.)
	//Dados do Recibo de Entrega
	oFont4 := 	  TFont():New("Arial"      		,09,19,,.T.,,,,,.F.)
	//Codigo de Compensação do Banco
	oFont5 := 	  TFont():New("Arial"      		,09,22,,.T.,,,,,.F.)
	//Codigo de Compensação do Banco
	oFont6 := 	  TFont():New("Arial"      	    ,09,14,,.T.,,,,,.F.)
	//Conteudo dos Campos em Negrito
	oFont7 := 	  TFont():New("Arial"           ,08,14,,.T.,,,,,.F.)
	//Dados do Cliente
	oFont8 := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)
	//Linha Digitavel
	oFont9 := 	  TFont():New("Arial" 			,09,14,,.T.,,,,,.F.)
	//Box interno texto
	oFont10 :=    TFont():New("Arial" 	     	,09,07,,.F.,,,,,.F.)

	//Busca Ultimo Indice
	nIndice := 0
	// dbSelectArea("SEP")
	// dbgoTop()

	// While !EOF()
	// 	nIndice := SEP->EP_TAXA
	// 	SEP->(dbSkip())
	// End

	dbSelectArea("SE1")
	SE1->(DbSetOrder(1)) // FILIAL + BOLETO
	SE1->(DbGoTop())

	If dbSeek ( xFilial("SE1")+ cSerie + cDoc + Iif(Empty(cParc),"",cParc), .T. )

	// IF AllTrim(SM0->M0_CODFIL) == "01" .AND. SZ5->Z5_EMISSAO >= CTOD("07/08/2017") .AND. SZ5->Z5_SERIE != "NH1"
	// 	M->NFf := SE1->E1_NUM
	// EndIF

	// While SE1->(!Eof())

		//+------------------------------------------------------------------------+
		//| Define se o titulo será impresso de acordo com a condição de pagamento |
		//+------------------------------------------------------------------------+
		dbSelectArea("SE1")

		// IF SE1->E1_NUM > M->NFf .or. SE1->E1_PREFIXO != M->Serie
		// 	Exit
		// EndIF

		IF "-" $SE1->E1_TIPO
			SE1->(dbSkip())
			Return
		EndIF

		IF "RA" $SE1->E1_TIPO
			SE1->(dbSkip())
			Return
		EndIF

		IF "IR-" $SE1->E1_TIPO
			SE1->(dbSkip())
			Return
		EndIF

		IF SE1->E1_MOEDA <> 1
			SE1->(dbSkip())
			Return
		EndIF

		nTxJuros := 1 + nIndice
		cMsgA	:= nTxJuros

		//Posicionar no Cliente
		dbSelectArea("SA1")
		SA1->(dbSetOrder(1))
		SA1->(dbGoTop())
		dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA)

		//Regra para busca o Valor
		nVlrIRRet	:= IF(SE1->E1_IRRF=0.01, 0, SE1->E1_IRRF)
		nVlrImpRet	:= nVlrIRRet + SE1->(E1_PIS+E1_COFINS+E1_CSLL+E1_INSS)
		nBaseCalJ	:= SE1->E1_VALOR-nVlrImpRet

		IF SE1->E1_BAIXA != CTOD("  /  /  ")
			Alert("Titulo ja baixado, não sera possivel gerar Boleto")
			Return()
		EndIF

		Do Case
			Case M->BANCO == "341"
			M->NumBoleta := StrZero( SE1->(Recno()),8) //StrZero((Val(M->NumBoleta)),8)
		EndCase

		M->DV_NNUM := NNumDV()

		//Valor
		nVlrIRRet	:= IF(SE1->E1_IRRF=0.01, 0, SE1->E1_IRRF)
		nVlrImpRet	:= nVlrIRRet + SE1->(E1_PIS+E1_COFINS+E1_CSLL+E1_INSS)

		//Pergunta Alterar Vencimento no Contas a Receber
		// IF mv_par05 = 2

		// 	cDtVenc := CTOD("  /  /  ")

		// 	DEFINE MSDIALOG oDlgX TITLE "Dados da Fatura" FROM 00,00 TO 300,420 PIXEL
		// 	@ 15 ,008 SAY "Cliente: "
		// 	@ 30 ,008 SAY "Valor: "
		// 	@ 45 ,008 SAY "Vencimento: "
		// 	@ 75 ,008 SAY "Novo Vencimento Boleto"

		// 	@ 15 ,060 SAY SA1->A1_NOME
		// 	@ 30 ,060 SAY Transform(SE1->E1_VALOR-nVlrImpRet,"@E 999,999,999.99")
		// 	@ 45 ,060 SAY dtoc(SE1->E1_VENCREA)
		// 	@ 75 ,080 GET cDtVenc valid cDtVenc >= ddatabase  SIZE 50,50
		// 	@ 135,120 BMPBUTTON TYPE 01 ACTION (ALTSE1(),Close(oDlgX))
		// 	@ 135,160 BMPBUTTON TYPE 02 ACTION Close(oDlgX)
		// 	ACTIVATE  DIALOG oDlgX CENTER

		// EndIF

		// Grava no SE1 numero do banco, o nosso numero
		dbSelectArea("SE1")
		RecLock("SE1",.F.)
		SE1->E1_PORTADO := "341"
		SE1->E1_NUMBCO  := AllTrim(M->NumBoleta) + AllTrim(M->DV_NNUM)
		SE1->E1_PORCJUR := 0
		SE1->E1_VALJUR  := 0 // ROUND( ((nBaseCalJ * nTxJuros)/100)/30 ,2)
		// SE1->E1_TIMEKEE := DTOS(dDataBase)
		// SE1->E1_DTBOLET := dDataBase   //Campo Criado para gravar Data da Geração do Boleto, assim facilita o filtro no momento do Bordero para enviar ao Banco
		SE1->E1_IDCNAB  := IF ( Empty(SE1->E1_NUMBOR),"",SE1->E1_IDCNAB )
		DbCommit()
		MsUnlock()

		oPrint:startpage()

		Do Case
			Case M->Banco == "341" //Banco Bradesco
			M->Percentual := cMsgA  //Val(cMsgA)
			cValDia := ((SE1->E1_VALOR * M->Percentual)/100)
			M->Mora_Dia := Round(cValDia/30,2)
		EndCase

		/////////////////////////////
		//Primeira Parte da Boleta  /
		/////////////////////////////
		Do Case

			// Bradesco
			Case M->Banco == "341"
			M->Nome_Bco := "ITAU"
			M->Cod_Comp := "|341-7|"
			M->Ag_Conta := M->Ag+"/"+M->CC
			M->Carteira := "109"
			M->Aceite   := "N"

		EndCase

		oPrint:SayBitmap( 050,0100,aBitMap[1],80,80 ) // LOGO-ITAU
		oPrint:say(122,0450,M->Cod_Comp,oFont5,100)
		oPrint:Say(122,1700,"Comprovante de Entrega",oFont7,100)

		oPrint:Line(130,0100,0130,2200)//Linha 1
		oPrint:Box (130,0890,0210,1230)//Box
		oPrint:say(155,0120,"Beneficiário",oFont1,100)
		oPrint:say(200,0120,SUBSTR(SM0->M0_NOMECOM,1,40) ,oFont2,100)
		oPrint:say(155,0900,"Agência/Código Beneficiário",oFont1,100)
		oPrint:say(200,0900,Subs(M->Ag_Conta,1,Len(Alltrim(M->Ag_Conta))-1)+"-"+AllTrim(Str(Modulo10(Subs(M->Ag_Conta,1,4)+Subs(M->Ag_Conta,6,5)))),oFont7,100)
		oPrint:say(155,1300,"Motivos de não entrega(para uso da empresa entregadora)",oFont1,100)
		oPrint:say(195,1250,"()Mudou-se "				 ,oFont1,100)//Linha 1
		oPrint:say(195,1480,"()Ausente  "				 ,oFont1,100)
		oPrint:say(195,1820,"()Não existe n. indicado ",oFont1,100)

		oPrint:Line(210,0100,0210,1230)//Linha 2
		oPrint:Box (210,0890,0290,1230)//Box
		oPrint:say(230,0120,"Pagador"			,oFont1,100)
		oPrint:say(280,0120,substr(SA1->A1_NOME,1,35),oFont2,100)//CLIENTE
		oPrint:say(230,0900,"Nosso Número"		,oFont1,100)

		Do Case
			Case M->Banco == "341" // Itau
			oPrint:say(280,0900,"109/"+M->NumBoleta+"-"+M->DV_NNUM,oFont7,100)   // Nosso Numero
		EndCase

		oPrint:say(265,1250,"()Recusado 	   "	,oFont1,100)//Linha 2
		oPrint:say(265,1480,"()Não procurado "	,oFont1,100)
		oPrint:say(265,1820,"()Falecido 	   "	,oFont1,100)

		oPrint:Line(290,0100,0290,1230)//Linha 3
		oPrint:Box (290,0360,0370,0690)//Box 1
		oPrint:Box (290,0890,0370,1230)//Box 2
		oPrint:say(310,0120,"Vencimento"			,oFont1,100)
		oPrint:say(360,0120,StrZero(Day(SE1->E1_VENCREA),2)+"/"+StrZero(Month(SE1->E1_VENCREA),2)+"/"+AllTrim(Str(Year(SE1->E1_VENCREA))),oFont7,100)
		oPrint:say(310,0370,"N° do Documento"		,oFont1,100)
		oPrint:say(360,0370,AllTrim(SE1->E1_PEDIDO),oFont2,100)
		oPrint:say(310,0700,"Espécie Moeda"		,oFont1,100)
		oPrint:say(360,0740,"R$",oFont2,100)
		oPrint:say(310,0900,"Valor do Documento"	,oFont1,100)
		oPrint:say(360,0900,Transform(SE1->E1_VALOR-nVlrImpRet,"@E 999,999,999.99"),oFont7,100)
		oPrint:say(335,1250,"()Desconhecido  "		   ,oFont1,100)//Linha 3
		oPrint:say(335,1480,"()Endereço insuficiente    ",oFont1,100)
		oPrint:say(335,1820,"()Outros (anotar no verso) ",oFont1,100)

		oPrint:Line(370,0100,0370,2200)//Linha 4
		oPrint:Box (370,0460,0450,0750)//Box 1
		oPrint:Box (370,1230,0450,1530)//Box 2
		oPrint:say(390,0120,"Recebi(emos) o bloqueto",oFont1,100)
		oPrint:say(390,0470,"Data    "				   ,oFont1,100)
		oPrint:say(390,0760,"Assinatura "				   ,oFont1,100)
		oPrint:say(390,1240,"Data    "				   ,oFont1,100)
		oPrint:say(390,1540,"Entregador    "			   ,oFont1,100)

		oPrint:Line(450,0100,0450,2200)//Linha 5
		oPrint:say(470,0120,"Local de Pagamento "		   ,oFont1,100)
		oPrint:say(480,0410,"BANCO ITAU S.A. "		       ,oFont7,100)
		oPrint:say(515,0410,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA ITAU. " ,oFont7,100)
		oPrint:say(470,1890,"Data de Processamento "	   ,oFont1,100)
		oPrint:say(515,1997,StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+AllTrim(Str(Year(SE1->E1_EMISSAO))),oFont2,100)

		///////////////////////////
		//Segunda Parte da Boleta /
		///////////////////////////
		oPrint:SayBitmap( 0530,0100,aBitMap[1],080,080) // Logo Principal
		//	oPrint:SayBitmap( 0670,1750,aBitMap[2],320,260) // Logo Secundario
		oPrint:say(0602,0450,M->Cod_Comp			,oFont5,100)
		oPrint:Say(0600,1850,"Recibo do Pagador"	,oFont7,100)

		oPrint:Line(0610,0100,0610,2200)//Linha 1
		oPrint:Box (0530,1600,1730,1601)// Box
		oPrint:say(0632,0120,"Local de Pagamento "		   ,oFont1,100)
		oPrint:say(0642,0410,"BANCO ITAU S.A. "		   ,oFont7,100)
		oPrint:say(0677,0410,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA ITAU. " ,oFont7,100)
		oPrint:say(0602,1620,M->Cod_Comp 			,oFont5,100)
		oPrint:say(0640,1810,"Recibo do Pagador" 	,oFont1,100)

		oPrint:Line(0690,0100,0690,1600)//Linha 2
		oPrint:say(0715,0120,"Beneficiário"			,oFont1,100)
		oPrint:say(0760,0120,SUBSTR(SM0->M0_NOMECOM,1,40) + SPACE(10) + "CNPJ "+transform(SM0->M0_CGC,"@R 99.999.999/9999-99")  		,oFont2,100)//CLIENTE SA1->A1_NOME

		oPrint:Line(0770,0100,0770,1600)//Linha 3
		//	oPrint:Box (0770,0370,0850,0710)// Box 1
		oPrint:Box (0770,0370,0850,0710)// Box 1
		oPrint:Box (0770,0890,0850,1070)// Box 2

		oPrint:say(0795,0120,"Data do Documento"	,oFont1,100)
		oPrint:say(0795,0380,"N° do Documento"	,oFont1,100)
		oPrint:say(0795,0720,"Espécie Doc."		,oFont1,100)
		oPrint:say(0795,0900,"Aceite"				,oFont1,100)
		oPrint:say(0795,1080,"Data do Processamento"	,oFont1,100)
		oPrint:say(0840,0140,StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+AllTrim(Str(Year(SE1->E1_EMISSAO))),oFont2,100)
		oPrint:say(0840,0390,AllTrim(SE1->E1_PEDIDO),oFont2,100)
		oPrint:say(0840,0720,"DM"					,oFont2,100)
		oPrint:say(0840,0930,M->Aceite			,oFont2,100)
		oPrint:say(0840,1400,StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+AllTrim(Str(Year(SE1->E1_EMISSAO))),oFont2,100)

		oPrint:Line(0850,0100,0850,1600)//Linha 4
		oPrint:Box (0850,0370,0930,0710)// Box 1
		oPrint:Box (0850,0510,0930,0710)// Box 2
		oPrint:Box (0850,0710,0930,1070)// Box 2

		oPrint:say(0870,0120,"Uso do Banco"	,oFont1,100)
		//	oPrint:say(0870,0320,"Cip"			,oFont1,100)
		//	oPrint:say(0920,0313,"000"			,oFont2,100)
		oPrint:say(0870,0380,"Carteira"		,oFont1,100)
		oPrint:say(0870,0520,"Espécie Moeda"	,oFont1,100)
		oPrint:say(0870,0720,"Quantidade"		,oFont1,100)
		oPrint:say(0870,1100,"Valor"			,oFont1,100)
		oPrint:say(0900,1080," "				,oFont1,100)
		oPrint:say(0920,400,M->Carteira		,oFont2,100)
		oPrint:say(0920,540,"R$"				,oFont2,100)
		oPrint:Line(0930,0100,0930,1600)//Linha 5
		oPrint:say(0950,0120,"Instruções de Responsabilidade do Beneficiário      ***Valores expressos em R$ ***",oFont1,100)

		IF lRet == .T.
			oPrint:say(1000,0120,"Após o Vencimento acesse WWW.ITAU.COM.BR/BOLETOS para atualizar seu boleto.",oFont1,100)
			oPrint:say(1050,0120,"Após o Vencimento mora dia R$ "+AllTrim(Transform(SE1->E1_VALJUR, "@E 999999.99")),oFont1,100)
			oPrint:say(1100,0120,"Valor que corresponde a juros de mora de 1% ao mês acrescido de variação do IGPM",oFont1,100)

			IF !EMPTY(SE1->E1_PARCELA)
				oPrint:say(1150,0120,"Parcela Nr: "+SE1->E1_PARCELA,oFont1,100) //05/12/16
			EndIF

			// IF SE1->E1_FILIAL="02"
			// 	oPrint:say(1200,0120,"Referente a Fatura "+SE1->E1_NUMSAP,oFont1,100)
			// EndIF

		EndIF

		oPrint:Line(1010,1600,1010,2200)//Linha 1 Box
		oPrint:Line(1090,1600,1090,2200)//Linha 2 Box
		oPrint:Line(1170,1600,1170,2200)//Linha 3 Box
		oPrint:Line(1250,1600,1250,2200)//Linha 4 Box
		oPrint:Line(1330,1600,1330,2200)//Linha 5 Box
		oPrint:Line(1410,1600,1410,2200)//Linha 6 Box
		oPrint:Line(1490,1600,1490,2200)//Linha 6 Box
		oPrint:Line(1570,1600,1570,2200)//Linha 6 Box
		oPrint:Line(1650,1600,1650,2200)//Linha 6 Box
		oPrint:say(1035,1620,"Vencimento"						,oFont1,100)
		oPrint:say(1085,2030,StrZero(Day(SE1->E1_VENCREA),2)+"/"+StrZero(Month(SE1->E1_VENCREA),2)+"/"+AllTrim(Str(Year(SE1->E1_VENCREA))),oFont7,100)
		oPrint:say(1115,1620,"Agência/Codigo Beneficiário"			,oFont1,100)
		oPrint:say(1168,1917,Subs(M->Ag_Conta,1,Len(Alltrim(M->Ag_Conta))-1)+"-"+AllTrim(Str(Modulo10(Subs(M->Ag_Conta,1,4)+Subs(M->Ag_Conta,6,5)))),oFont7,100)
		oPrint:say(1195,1620,"Cart./nosso número"				,oFont1,100)

		Do Case

			Case M->Banco == "341" // Itau
			oPrint:say(1245,1910,"109/"+M->NumBoleta+"-"+M->DV_NNUM,oFont7,100)

		EndCase

		oPrint:say(1275,1620,"(=) Valor do Documento"	,oFont1,100)
		oPrint:say(1329,2000,Transform(SE1->E1_VALOR-nVlrImpRet,"@E 999,999,999.99"),oFont7,100)
		oPrint:say(1355,1620,"(-) Desconto/Abatimento"	,oFont1,100)
		IIf(SE1->E1_DECRESC > 0,oPrint:say(1370,2000,Transform(SE1->E1_DECRESC,"@E 999,999,999.99"),oFont7,100),)

		IF SE1->E1_DESCFIN > 0

			IF SE1->E1_VALLIQ > 0
				nVlrDescAbat += SE1->E1_SALDO * (SE1->E1_DESCFIN/100)
			Else
				nVlrDescAbat += SE1->E1_VALOR * (SE1->E1_DESCFIN/100)
			EndIF

		EndIF

		IIf(nVlrDescAbat > 0,oPrint:say(1370,2000,Transform(nVlrDescAbat,"@E 999,999,999.99"),oFont7,100),)

		IF nVlrDescAbat > 0 //exibe mensagem de desconto, caso possua
			oPrint:say(1215,0120,"Considerar Desconto/Abatimento de R$ "+transform(nVlrDescAbat,"@E 999999.99"),oFont1,100)
		EndIF

		oPrint:say(1435,1620,"(-) Outras Deduções"		,oFont1,100)

		//TESTE DESCONTO DO VALOR DE ABATIMENTO NCC(DEVOLUCAO)
		IF SE1->E1_VALLIQ > 0
			oPrint:say(1450,2000,Transform(SE1->E1_VALOR - SE1->E1_SALDO - nVlrImpRet,"@E 999,999,999.99"),oFont7,100)
		EndIF

		oPrint:say(1515,1620,"(+) Mora/Multa"			,oFont1,100)
		oPrint:say(1595,1620,"(+) Outros Acréscimos"		,oFont1,100)
		Iif(SE1->E1_ACRESC > 0, oPrint:Say  (1610,2000,AllTrim(Transform(SE1->E1_ACRESC,"@E 999,999,999.99")),oFont7,100), )

		oPrint:say(1675,1620,"(=) Valor Cobrado"			,oFont1,100)

		IF SE1->E1_VALLIQ > 0
			nVlrCobrado := SE1->E1_SALDO - nVlrDescAbat - SE1->E1_DECRESC + SE1->E1_ACRESC - nVlrImpRet
		Else
			nVlrCobrado := SE1->E1_VALOR - nVlrDescAbat - SE1->E1_DECRESC + SE1->E1_ACRESC - nVlrImpRet
		EndIF

		oPrint:Line(1732,0100,1732,2200)//Linha 6
		oPrint:say(1765,0120,"Pagador"						,oFont2,100)
		oPrint:say(1765,0270,SubStr(SA1->A1_NOME,1,50)	,oFont2,100)

		IF SA1->A1_PESSOA = "F"
			oPrint:say(1765,1450,"CNPJ "+transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont2,100)
		Else
			oPrint:say(1765,1450,"CNPJ "+transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont2,100)
		EndIF

		oPrint:say(1800,0270,IIF(EMPTY(SA1->A1_ENDCOB),AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),SA1->A1_ENDCOB+" - "+SA1->A1_BAIRROC)			,oFont2,100)
		oPrint:say(1835,0270,IIF(EMPTY(SA1->A1_ENDCOB),SA1->A1_CEP+"   "+SA1->A1_MUN+" - "+SA1->A1_EST,SA1->A1_CEPC+"   "+SA1->A1_MUNC+" - "+SA1->A1_ESTC),oFont2,100)
		oPrint:say(1880,0120,"Pagador/Avalista"			,oFont2,100)

		IF "3391" $ M->Ag
			oPrint:say(1860,0320,SUBSTR(SM0->M0_NOMECOM,1,40)  + SPACE(10) + "CNPJ "+transform(SM0->M0_CGC,"@R 99.999.999/9999-99")  ,oFont8,100)
		EndIF

		oPrint:Line(1890,0100,1890,2200)//Linha 7
		oPrint:say(1915,1730,"Autenticação Mecânica"		,oFont1,100)

		/////////////////////////////
		//Terceira parte da Boleta	/
		/////////////////////////////
		M->FatorVcto := Str( ( SE1->E1_VENCREA - Ctod("07/10/1997") ),4 )

		//Montagem do Codigo de Barras da Boleta
		Do Case

			Case M->BANCO == "341"
			M->B_Campo := "341"  + "9" + M->FatorVcto
			M->B_Campo += StrZero(nVlrCobrado*100,10)
			M->B_Campo += "109"
			M->B_Campo += M->Numboleta+M->DV_NNUM
			M->B_Campo += M->Ag
			M->B_Campo += Subs(M->CC,1,5)
			M->B_Campo += AllTrim(Str(Modulo10(M->Ag+SUBS(M->CC,1,5))))
			M->B_Campo +=  "000"

			//Calculo do Digito do Codigo de Barras
			BarraDV()

			//Compor a barra com o Digito verificador
			M->CodBarras := "341"  + "9" + M->DV_BARRA + M->FatorVcto

			//Codigo de barras com a funcao "INT" esta gerando com 0,01 de diferenca, alterado para pegar o valor original
			M->CodBarras += StrZero(nVlrCobrado*100,10)
			M->CodBarras += "109"
			M->CodBarras += M->Numboleta+M->DV_NNUM
			M->CodBarras += M->Ag
			M->CodBarras += Subs(M->CC,1,5)
			M->CodBarras += AllTrim(Str(Modulo10(M->Ag+SUBS(M->CC,1,5))))
			M->CodBarras += "000"

		EndCase

		//Montar a Linha Digitavel da Boleta
		MontaLinha()

		//Terceira Parte da Boleta
		oPrint:SayBitmap( 002020,0100,aBitMap[1],080,080) // Logo Itau
		//	oPrint:SayBitmap( 002920,1900,aBitMap[3],300,090) // Logo ISO da Boleta
		oPrint:say(002090,0450,M->Cod_Comp,oFont5,100)

		//Impressão da Linha Digitavel
		oPrint:Say(002090,0700,M->LineDig,oFont4,100)
		oPrint:Box (002100,1600,2825,1601)// Box Principal

		oPrint:Line(002100,0100,002100,2200)// Linha 1
		oPrint:say(002125,0120,"Local de Pagamento",oFont1,100)
		oPrint:say(002135,0410,"BANCO ITAU S.A "		   ,oFont7,100)
		oPrint:say(002175,0410,"PAGAR PREFERENCIALMENTE EM QUALQUER AGENCIA ITAU. " ,oFont7,100)
		oPrint:say(002125,1620,"Vencimento",oFont1,100)
		oPrint:say(002175,2030,StrZero(Day(SE1->E1_VENCREA),2)+"/"+StrZero(Month(SE1->E1_VENCREA),2)+"/"+AllTrim(Str(Year(SE1->E1_VENCREA))),oFont7,100)

		oPrint:Line(002185,0100,002185,2200)// Linha 2
		oPrint:say(002210,0120,"Beneficiário",oFont1,100)
		oPrint:say(002255,0120,SUBSTR(SM0->M0_NOMECOM,1,40) + SPACE(10) + "CNPJ "+transform(SM0->M0_CGC,"@R 99.999.999/9999-99")   ,oFont2,100)//SA1->A1_NOME
		oPrint:say(002210,1620,"Agência/Código Beneficiário",oFont1,100)
		oPrint:say(002255,1920,Subs(M->Ag_Conta,1,Len(Alltrim(M->Ag_Conta))-1)+"-"+AllTrim(Str(Modulo10(Subs(M->Ag_Conta,1,4)+Subs(M->Ag_Conta,6,5)))),oFont7,100)

		oPrint:Line(002265,0100,002265,2200)// Linha 3
		oPrint:Line(002265,0100,002265,1600)// Linha 4
		oPrint:Box (002265,0370,002345,0710)// Box 1
		oPrint:Box (002265,0890,002345,1070)// Box 2

		oPrint:say(002290,0120,"Data do Documento",oFont1,100)
		oPrint:say(002290,0380,"N° do Documento",oFont1,100)
		oPrint:say(002290,0720,"Espécie Doc.",oFont1,100)
		oPrint:say(002290,0900,"Aceite",oFont1,100)
		oPrint:say(002290,1080,"Data Processamento",oFont1,100)
		oPrint:say(002290,1620,"Cart./Nosso Número",oFont1,100)
		oPrint:say(002335,0140,StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+AllTrim(Str(Year(SE1->E1_EMISSAO))),oFont2,100)
		oPrint:say(002335,0390,AllTrim(SE1->E1_PEDIDO),oFont2,100)
		oPrint:say(002335,0720,"DM",oFont2,100)
		oPrint:say(002335,0930,M->Aceite,oFont2,100)
		oPrint:say(002335,1400,StrZero(Day(SE1->E1_EMISSAO),2)+"/"+StrZero(Month(SE1->E1_EMISSAO),2)+"/"+AllTrim(Str(Year(SE1->E1_EMISSAO))),oFont2,100)

		oPrint:say(002335,1920,"109/"+M->NumBoleta + "-" + DV_NNUM,oFont7,100)

		oPrint:Line(002345,0100,002345,2200)// Linha 3
		oPrint:Line(002345,0100,002345,1600)// Linha 4
		oPrint:Box (002345,0370,002425,0710)// Box 1
		oPrint:Box (002345,0510,002425,0710)// Box 1
		oPrint:Box (002345,0710,002425,1070)// Box 2

		oPrint:say(002370,0120,"Uso do Banco"	,oFont1,100)
		//	oPrint:say(002370,0320,"Cip"			,oFont1,100)
		//	oPrint:say(002415,0320,"000"          ,oFont2,100)
		oPrint:say(002370,0380,"Carteira"		,oFont1,100)
		oPrint:say(002370,0520,"Espécie Moeda"	,oFont1,100)
		oPrint:say(002370,0720,"Quantidade"	,oFont1,100)
		oPrint:say(002370,1100,"Valor"		,oFont1,100)
		//	oPrint:say(002400,1080,"x"			,oFont1,100)
		oPrint:say(002370,1620,"(=) Valor do Documento",oFont1,100)
		oPrint:say(002415,2000,transform(SE1->E1_VALOR-nVlrImpRet,"@E 999,999,999.99"),oFont7,100)
		oPrint:say(002415,0400,M->Carteira,oFont2,100)
		oPrint:say(002415,0520,"R$",oFont2,100)

		oPrint:Line(002420,0100,002420,2200)// Linha 5
		oPrint:Line(002505,1600,002505,2200)//Linha Box 6
		oPrint:Line(002585,1600,002585,2200)//Linha Box 7
		oPrint:Line(002665,1600,002665,2200)//Linha Box 8
		oPrint:Line(002745,1600,002745,2200)//Linha Box 9

		oPrint:say(002450,0120,"Instruções de Responsabilidade do Beneficiário      ***Valores expressos em R$ ***",oFont1,100)
		oPrint:say(002450,1620,"(-) Desconto/Abatimento",oFont1,100)
		Iif(nVlrDescAbat > 0,oPrint:say(002520,2000,Transform(nVlrDescAbat,"@E 999,999,999.99"),oFont7,100),)

		IF nVlrDescAbat > 0 //exibe mensagem de desconto, caso possua
			oPrint:say(02780,0120,"Considerar Desconto/Abatimento de R$ "+transform(nVlrDescAbat,"@E 999999.99"),oFont1,100)
		EndIF

		nVlrDescAbat := 0

		oPrint:say(002560,1620,"(-) Outras Deduções",oFont1,100)

		//TESTE DESCONTO DO VALOR DE ABATIMENTO NCC(DEVOLUCAO)
		IF SE1->E1_VALLIQ > 0
			oPrint:say(2600,2000,Transform(SE1->E1_VALOR - SE1->E1_SALDO-nVlrImpRet,"@E 999,999,999.99"),oFont7,100)
		EndIF

		oPrint:say(002640,1620,"(+) Mora/Multa",oFont1,100)
		oPrint:say(002720,1620,"(+) Outros Acréscimos",oFont1,100)
		Iif(SE1->E1_ACRESC > 0, oPrint:Say  (002760,2000,AllTrim(Transform(SE1->E1_ACRESC,"@E 999,999,999.99")),oFont7,100), )

		oPrint:say(002800,1620,"(=) Valor Cobrado",oFont1,100)
		nVlrCobrado := 0

		oPrint:Line(002825,0100,002825,2200)// Linha 10
		oPrint:Line(003050,0100,003050,2200)// Linha 11

		Do Case
			Case M->Banco == "341"

			IF lRet == .T.
				oPrint:say(02500,0120,"Após o Vencimento acesse WWW.ITAU.COM.BR/BOLETOS para atualizar seu boleto.",oFont1,100)
				oPrint:say(002550,0120,"Após o Vencimento mora dia R$ "+AllTrim(Transform(SE1->E1_VALJUR, "@E 999999.99")),oFont1,100)
				oPrint:say(002600,0120,"Valor que corresponde a juros de mora de 1% ao mês acrescido de variação do IGPM",oFont1,100)

				IF !EMPTY(SE1->E1_PARCELA)
					oPrint:say(002650,0120,"Parcela Nr: "+SE1->E1_PARCELA,oFont1,100) //05/12/16
				EndIF

			EndIF

		EndCase

		oPrint:say(002850,0120,"Pagador",oFont1,100)
		oPrint:say(002850,0250,SubStr(SA1->A1_NOME,1,50),oFont8,100)

		IF SA1->A1_PESSOA = "F"
			oPrint:say(002850,1450,"CNPJ "+transform(SA1->A1_CGC,"@R 999.999.999-99"),oFont8,100)
		Else
			oPrint:say(002850,1450,"CNPJ "+transform(SA1->A1_CGC,"@R 99.999.999/9999-99"),oFont8,100)
		EndIF

		oPrint:say(002875,0250,IIF(EMPTY(SA1->A1_ENDCOB),AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),SA1->A1_ENDCOB+" - "+SA1->A1_BAIRROC)		  ,oFont8,100)
		oPrint:say(002899,0250,IIF(EMPTY(SA1->A1_ENDCOB),SA1->A1_CEP+"   "+SA1->A1_MUN+" - "+SA1->A1_EST,SA1->A1_CEPC+"   "+SA1->A1_MUNC+" - "+SA1->A1_ESTC),oFont8,100)
		oPrint:say(002899,1340,"Autenticação Mecânica",oFont1,100)
		oPrint:say(002899,1760,"Ficha de Compensação",oFont1,100)

		// Impressão do código de barras.
		oPrint:FWMsBar("INT25",68,2,M->CodBarras,oPrint,.F.,,.T.,0.025,1.1,NIL,NIL,NIL,.F.)
		Eject

		// dbSelectarea("SE1")
		// SE1->(DbSkip())

		oPrint:Endpage()
		oPrint:Preview()

		FreeObj(oPrint)

	EndIf

	MS_FLUSH()

Return NIL


//Calculo do Digito Verificador do Nosso Numero
Static Function NNumDV()
	Local i  := 0

	Do Case

		// Bradesco
		Case M->BANCO = "237"

		M->nCont   := 0
		M->cPeso   := 2

		M->nBoleta := "09" + M->NumBoleta

		For i := 13 To 1 Step -1

			M->nCont := M->nCont + (Val(SUBSTR(M->nBoleta,i,1))) * M->cPeso

			M->cPeso := M->cPeso + 1

			IF M->cPeso == 8
				M->cPeso := 2
			EndIF

		Next

		M->Resto := ( M->nCont % 11 )

		Do Case
			Case M->Resto == 1
			M->DV_NNUM := "P"
			Case M->Resto == 0
			M->DV_NNUM := "0"
			OtherWise
			M->Resto   := ( 11 - M->Resto )
			M->DV_NNUM := AllTrim(Str(M->Resto))
		EndCase

		Case M->BANCO = "341"

		M->nBoleta := M->Ag + Subs(M->CC,1,5)+"109" + M->NumBoleta
		M->DV_NNUM := AllTrim(Str(Modulo10(M->nBoleta)))

	EndCase

Return(M->DV_NNUM)


//Calculo do Digito do Codigo de Barras
Static Function BarraDV()
	Local i  := 0

	Do Case

		// Bradesco
		Case M->BANCO = "237"

		M->nCont := 0
		M->cPeso := 2

		For i := 43 To 1 Step -1
			M->nCont := M->nCont + ( Val( SUBSTR( M->B_Campo,i,1 )) * M->cPeso )
			M->cPeso := M->cPeso + 1

			IF M->cPeso >  9
				M->cPeso := 2
			EndIF

		Next

		M->Resto  := ( M->nCont % 11 )
		M->Result := ( 11 - M->Resto )

		Do Case
			Case M->Result == 10 .or. M->Result == 11
			M->DV_BARRA := "1"
			OtherWise
			M->DV_BARRA := Str(M->Result,1)
		EndCase

		Case M->BANCO = "341"
		M->DV_BARRA := Alltrim(Str(Modulo11(M->B_Campo)))
	EndCase

Return NIL

Static Function MontaLinha()

	M->LineDig := ""
	M->nDigito := ""
	M->Pedaco  := ""

	Do Case

		// Bradesco
		Case M->Banco $ "237,341"

		M->LineDig := ""
		M->nDigito := ""
		M->Pedaco  := ""

		//Primeiro Campo
		//Codigo do Banco + Moeda + 5 primeiras posições do campo livre do Cod Barras
		M->Pedaco := Substr(M->CodBarras,01,03) + Substr(M->CodBarras,04,01) + Substr(M->CodBarras,20,5)
		DV_LINHA()
		M->LineDig := Substr(M->CodBarras,1,3)+Substr(M->CodBarras,4,1)+Substr(M->CodBarras,20,1)+"."+;
		Substr(M->CodBarras,21,4) + M->nDigito + Space(2)

		//Segundo Campo
		M->Pedaco  := Substr(M->CodBarras,25,10)
		DV_LINHA()
		M->LineDig := M->LineDig+Substr(M->Pedaco,1,5)+"."+Substr(M->Pedaco,6,5)+;
		M->nDigito+Space(2)

		//Terceiro Campo
		M->Pedaco  := Substr(M->CodBarras,35,10)
		DV_LINHA()
		M->LineDig := M->LineDig + Substr(M->Pedaco,1,5)+"."+Substr(M->Pedaco,6,5)+;
		M->nDigito+Space(2)

		//Quarto Campo
		M->LineDig := M->LineDig + DV_BARRA + Space(2)

		//Quinto Campo
		//funcao INT esta gerando diferenca 0,01, retirado para considerar valor original
		M->LineDig  := M->LineDig + M->FatorVcto + StrZero(nVlrCobrado*100,10)

	EndCase

Return

Static Function Modulo10(cData)
	Local  L,D,P := 0
	Local B     := .F.
	L := Len(cData)
	B := .T.
	D := 0
	While L > 0
		P := Val(SubStr(cData, L, 1))
		If (B)
			P := P * 2
			If P > 9
				P := P - 9
			End
		End
		D := D + P
		L := L - 1
		B := !B
	End
	D := 10 - (Mod(D,10))
	If D = 10
		D := 0
	End
Return D

Static Function Modulo11(cData)

	Local L, D, P := 0
	L := Len(cdata)
	D := 0
	P := 1
	// Some o resultado de cada produto efetuado e determine o total como (D);
	While L > 0
		P := P + 1
		D := D + (Val(SubStr(cData, L, 1)) * P)
		If P = 9
			P := 1
		End
		L := L - 1
	End
	// DAC = 11 - Mod 11(D)
	D := 11 - (mod(D,11))
	// OBS: Se o resultado desta for igual a 0, 1, 10 ou 11, considere DAC = 1.
	If (D == 0 .Or. D == 1 .Or. D == 10 .Or. D == 11)
		D := 1
	End

Return D


//Calculo do Digito da Linha Digitavel
Static Function DV_LINHA()
	Local i  := 0

	Do Case

		Case M->Banco $ "237,341"
		nCont  := 0
		Peso   := 2

		For i := Len(M->Pedaco) to 1 Step -1

			IF M->Peso == 3
				M->Peso := 1
			EndIF

			IF Val(SUBSTR(M->Pedaco,i,1))*M->Peso >= 10
				nVal  := Val(SUBSTR(M->Pedaco,i,1)) * M->Peso
				nCont := nCont+(Val(SUBSTR(Str(nVal,2),1,1))+Val(SUBSTR(Str(nVal,2),2,1)))
			Else
				nCont:=nCont+(Val(SUBSTR(M->Pedaco,i,1))* M->Peso)
			EndIF

			M->Peso := M->Peso + 1

		Next

		M->Dezena  := Substr(Str(nCont,2),1,1)
		M->Resto   := ( (Val(Dezena)+1) * 10) - nCont

		IF M->Resto   == 10
			M->nDigito := "0"
		Else
			M->nDigito := Str(M->Resto,1)
		EndIF

	EndCase

Return NIL

