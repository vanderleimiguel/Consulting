#Include 'Protheus.ch'
#INCLUDE "topconn.ch"
#INCLUDE "RWMAKE.CH"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"

/*/{Protheus.doc} AGRBOL01
Rotina de impressão de Boleto
@author Rodrigo Guerra
@since 07/03/2024
/*/
User Function AGRBOL01(lFat)
	Local lRet         := .F.

	Default lFat       := .F.

	Private lPosFat    := lFat
	Private nOpc       := 0
	Private cTitulo    := "Impressao do Boleto Laser"
	Private aDesc      := {"Este programa imprime os boletos de","cobranca bancaria de acordo com","os parametros informados"}
	Private cIndexName := ''
	Private cIndexKey  := ''
	Private cFilter    := ''
	Private cPerg      := IIF(lPosFat,PADR('IMPRBOLFAT',10),PADR('IMPRBOL',10))
	Private cLogoBanco := ""
	Private cLogoItabom:= "LogoAgroFoods.BMP" //AJUSTAR
	Private Nlinha     := ""

	ValidPerg()
	If Pergunte(cPerg,.T.)
		lRet := .T.
		If cPerg $ 'IMPRBOLFAT'
			If !SA6->(DbSeek(xFilial("SA6")+mv_par01))
				lRet := .F.
			EndIf
		EndIf
	EndIf

	if lRet
		Processa({|| BolLsr()}, "Gerando Boleto(s)")
	EndIf

Return


Static Function BolLsr()
	Local cBcoAtual := ''
	Local cBco      := ''
	Local lImpresso := .F.
	Local lImpBol	  := .F.
	Local cMsgLog	  := ''
	Local cPath     := "\spool\"
	Local cFile		:= " "
	Local lRet    := .T.
	Private nPBonif   := 0
	Private nVlrBonif := 0
	Private nCntReg   := 0
	Private nCB1Linha	:= 14.5   //GETMV("PV_BOL_LI1") //14.5
	Private nCB2Linha	:= 26.1   //GETMV("PV_BOL_LI2") //26.1
	Private nCBColuna	:= 1.3    //GETMV("PV_BOL_COL") //1.3
	Private nCBLargura	:= 0.0280 //GETMV("PV_BOL_LAR") //0.0280
	Private nCBAltura	:= 1.4    //GETMV("PV_BOL_ALT") //1.4
	Private cAliasSE1  := GetNextAlias()
	Private cFileOrig := " "
	Private cChvBcoCC := ''
	Private cNossoPad := ''
	Private cNosso    := ''
	Private cBenefic  := ''

// ----------------------------------------------------------------+
// Busca Títulos                                                   |
// ----------------------------------------------------------------+	
	cQuery := " SELECT *, SE1.R_E_C_N_O_ AS REG  "
	cQuery += " FROM " + RetSqlName("SE1") + " SE1 "
	cQuery += "  LEFT JOIN " + RetSqlName("SA1") + " SA1 "
	cQuery += "  ON A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_='' "
	cQuery += " WHERE E1_FILIAL='"+xFilial('SE1')+"' "
	if lPosFat
		cBcoAtual := mv_par01
		cQuery += "  AND E1_NUM >= '"+SE1->E1_NUM+"' "
		cQuery += "  AND E1_PREFIXO='"+SE1->E1_PREFIXO+"' "
		cQuery += "  AND E1_CLIENTE = '"+SE1->E1_CLIENTE+"' "
		cQuery += "  AND E1_EMISSAO = '"+DTOS(SE1->E1_EMISSAO)+"' "
		cQuery += "  AND E1_VENCREA = '"+DTOS(SE1->E1_VENCREA)+"' "
	else
		cBcoAtual := mv_par14
		cQuery += "  AND E1_NUM >= '"+MV_PAR01+"' AND E1_NUM <= '"+MV_PAR02+"' "
		cQuery += "  AND E1_PREFIXO='"+MV_PAR03+"' "
		cQuery += "  AND E1_CLIENTE >= '"+MV_PAR04+"' AND E1_CLIENTE <='"+MV_PAR05+"' "
		cQuery += "  AND E1_EMISSAO >= '"+DTOS(MV_PAR06)+"' AND E1_EMISSAO <='"+DTOS(MV_PAR07)+"' "
		cQuery += "  AND E1_VENCREA >= '"+DTOS(MV_PAR08)+"' AND E1_VENCREA <='"+DTOS(MV_PAR09)+"' "
		cQuery += "  AND A1_GRPVEN  >= '"+MV_PAR15+"'       AND A1_GRPVEN  <='"+MV_PAR16+"' "
	EndIf
	cQuery += "  AND SE1.E1_TIPO <> 'AB-'  "
	cQuery += "  AND SE1.D_E_L_E_T_='' "
	cQuery += " ORDER BY E1_NUM, E1_PARCELA	"

	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasSE1, .F., .T.)

	if lPosFat
		// ------------------------------------------------------------------------+
		// Valida se Banco escolhido esta contido no cadastro de bancos do Cliente |
		// ------------------------------------------------------------------------+
		aBco := {}
		AADD(aBco,{(cAliasSE1)->A1_BCO1,(cAliasSE1)->A1_BCO2,;
			(cAliasSE1)->A1_BCO3,(cAliasSE1)->A1_BCO4,;
			(cAliasSE1)->A1_BCO5,(cAliasSE1)->A1_BCO6,;
			(cAliasSE1)->A1_BCO7,(cAliasSE1)->A1_BCO8,;
			(cAliasSE1)->A1_BCO9,(cAliasSE1)->A1_BCO10,;
			(cAliasSE1)->A1_X_BCO11,(cAliasSE1)->A1_X_BCO12,;
			(cAliasSE1)->A1_X_BCO13,(cAliasSE1)->A1_X_BCO14,;
			(cAliasSE1)->A1_X_BCO15,(cAliasSE1)->A1_X_BCO16,;
			(cAliasSE1)->A1_X_BCO17,(cAliasSE1)->A1_X_BCO18,;
			(cAliasSE1)->A1_X_BCO19,(cAliasSE1)->A1_X_BCO20,;
			(cAliasSE1)->A1_X_BCO21,(cAliasSE1)->A1_X_BCO22,;
			(cAliasSE1)->A1_X_BCO23,(cAliasSE1)->A1_X_BCO24,;
			(cAliasSE1)->A1_X_BCO25,(cAliasSE1)->A1_X_BCO26,;
			(cAliasSE1)->A1_X_BCO27,(cAliasSE1)->A1_X_BCO28})

		nPosBco := aScan(aBco[1],{|x|AllTrim(x) == SubStr(cBcoAtual,1,3)})
		//Se banco não for encontrado, exibe mensagem
		If nPosBco == 0
			MessageBox("Cliente: "+Alltrim((cAliasSE1)->E1_CLIENTE)+"-"+Alltrim((cAliasSE1)->E1_LOJA)+" "+Alltrim((cAliasSE1)->A1_NOME)+" sem banco cadastrado!","Aviso!",32)
			(cAliasSE1)->(DbCloseArea())
			Return
		EndIf

		// ----------------------------------------------------------------+
		// Atualiza Titulo com banco selecionado na rotina de faturamento  |
		// ----------------------------------------------------------------+
		While (cAliasSE1)->(!EOF())

			cQuery := " UPDATE " + RETSQLNAME("SE1")
			cQuery += " SET "
			cQuery += "   E1_PORTADO = '"+SubStr(mv_par01,1,3)+"', "
			cQuery += "   E1_AGEDEP  = '"+SubStr(mv_par01,4,5)+"', "
			cQuery += "   E1_CONTA   = '"+SubStr(mv_par01,9)+"' "
			cQuery += " WHERE R_E_C_N_O_ = " +AllTrim(Str((cAliasSE1)->REG))+ " "
			TcSqlExec(cQuery)
			(cAliasSE1)->(DbSkip())
			nCntReg++
		EndDo

	else
		//Chamado em reimpressao de boleto
		Count to nCntReg
	EndIf
	ProcRegua(nCntReg)

	(cAliasSE1)->(DbGoTop())
	// if nCntReg > 0
	// 		IncProc("Gerando Boleto(s)")
	// EndIf

	While !(cAliasSE1)->(Eof())
// ----------------------------------------------------------------+
// Valida Banco escolhido se esta nos cadastros de banco do Cliente|
// ----------------------------------------------------------------+
		if !lPosFat
			IncProc()
			aBco := {}
			AADD(aBco,{(cAliasSE1)->A1_BCO1,(cAliasSE1)->A1_BCO2,;
				(cAliasSE1)->A1_BCO3,(cAliasSE1)->A1_BCO4,;
				(cAliasSE1)->A1_BCO5,(cAliasSE1)->A1_BCO6,;
				(cAliasSE1)->A1_BCO7,(cAliasSE1)->A1_BCO8,;
				(cAliasSE1)->A1_BCO9,(cAliasSE1)->A1_BCO10,;
				(cAliasSE1)->A1_X_BCO11,(cAliasSE1)->A1_X_BCO12,;
				(cAliasSE1)->A1_X_BCO13,(cAliasSE1)->A1_X_BCO14,;
				(cAliasSE1)->A1_X_BCO15,(cAliasSE1)->A1_X_BCO16,;
				(cAliasSE1)->A1_X_BCO17,(cAliasSE1)->A1_X_BCO18,;
				(cAliasSE1)->A1_X_BCO19,(cAliasSE1)->A1_X_BCO20,;
				(cAliasSE1)->A1_X_BCO21,(cAliasSE1)->A1_X_BCO22,;
				(cAliasSE1)->A1_X_BCO23,(cAliasSE1)->A1_X_BCO24,;
				(cAliasSE1)->A1_X_BCO25,(cAliasSE1)->A1_X_BCO26,;
				(cAliasSE1)->A1_X_BCO27,(cAliasSE1)->A1_X_BCO28})

			nPosBco := aScan(aBco[1],{|x|AllTrim(x) == SubStr(cBcoAtual,1,3)})
			//Caso não, preenche variavel que sera exibida ao final do processo
			If nPosBco == 0
				cMsgLog += "Cliente: "+Alltrim((cAliasSE1)->E1_CLIENTE)+"-"+Alltrim((cAliasSE1)->E1_LOJA)+" "+Alltrim((cAliasSE1)->A1_NOME)+" sem banco cadastrado!"
				(cAliasSE1)->(DbSkip())
				Loop
			EndIf
		EndIf
// ----------------------------------------------------------------+
// Nomeia Arquivo                                                  |
// ----------------------------------------------------------------+
		cFile     := (cAliasSE1)->(AllTrim(E1_PREFIXO)+AllTrim(E1_NUM)+AllTrim(E1_PARCELA)+AllTrim(E1_TIPO) )
		cFileOrig := cPath + cFile +".pdf"
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
//Verifica se caminho existe                                       |
// ----------------------------------------------------------------+
		If ! file(Substr(cPath,1,len(cPath)-1))
			MAKEDIR(cPath)
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

			// If Empty(cBcoAtual)//SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA))	// Se já foi impresso (Banco preenchido), não passa pelas validações e "vai" direto para a impressão
			// 	cBcoAtual := SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)
			// EndIf

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

		// If !IsInCallStack('U_ITOMSM06')	// Se não foi "chamado" pelo faturamento, deve verificar se o título está em borderô ou não
		// 	If Empty(SE1->E1_NUMBOR)
		// 		cMsgLog += AllTrim(SE1->E1_FILIAL) +' - '+SE1->E1_PREFIXO + ' / ' + SE1->E1_NUM + ' / ' + SE1->E1_PARCELA + ' / ' + SE1->E1_TIPO + Chr(13)+Chr(10)
		// 	EndIf
		// EndIf

// ----------------------------------------------------------------+
// Chama rotina de Geração de Boleto                               |
// ----------------------------------------------------------------+
		if lRet
			lImpresso := U_AGRBOL02(cBcoAtual)


			If lImpresso
				lImpBol := .T.
				// oPrint:Preview()
// ----------------------------------------------------------------+
/// Chama função de envio de email                                 |
// ----------------------------------------------------------------+
				U_AGRBOL03()
// ----------------------------------------------------------------+
/// Apaga pdf da 'Spool' pós envio de email                        |
// ----------------------------------------------------------------+
				// if lPosFat
				// 	If file( cFileOrig )
				// 		ferase( cFileOrig )
				// 	EndIf
				// EndIf
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
	(cAliasSE1)->(DbCloseArea())


// ----------------------------------------------------------------+
// Cria Dialog com informações de títulos sem Borderô              |
// ----------------------------------------------------------------+
	If !Empty(cMsgLog)
		oFntTxt := TFont():New("Calibri",,-015,,.F.,,,,,.F.,.F.)
		DEFINE MSDIALOG oDlgMens TITLE 'ATENÇÃO!!!' FROM 000, 000  TO 295, 395 COLORS 0, 16777215 PIXEL

		cMsgLog := 'Clinte(s) estao sem Banco Cadastrado:' + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cMsgLog
		// cMsgLog := 'Os seguintes títulos estão sem Borderô:' + Chr(13)+Chr(10) + Chr(13)+Chr(10) + cMsgLog

		@ 002, 004 GET oMsg VAR cMsgLog OF oDlgMens MULTILINE SIZE 191, 121 FONT oFntTxt COLORS 0, 16777215 HSCROLL PIXEL
		oMsg:lReadOnly := .T.

		@ 127, 144 BUTTON oBtnOk  PROMPT 'Ok'   SIZE 051, 015 ACTION oDlgMens:End() OF oDlgMens PIXEL

		ACTIVATE MSDIALOG oDlgMens CENTERED

	EndIf

	If !lImpBol
		MsgBox ("Nenhum boleto gerado!!!","Informação","INFO")
	EndIf

Return Nil



Static Function ValidPerg()
	Private _sAlias,i,j
	_sAlias := Alias()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg := PADR(cPerg,10)
	aRegs:={}

	if lPosFat
		AADD(aRegs,{cPerg,"01","Banco Emissão Boleto    ?",Space(18),Space(18),"mv_ch1","C",18,0,0,"G","","mv_par01",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SA6PNF","","",""})
	else
		AADD(aRegs,{cPerg,"01","Número De               ?",Space(20),Space(20),"mv_ch1","C",09,0,0,"G","","mv_par01",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"02","Número Ate              ?",Space(20),Space(20),"mv_ch2","C",09,0,0,"G","","mv_par02",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"03","Série                   ?",Space(20),Space(20),"mv_ch3","C",03,0,0,"G","","mv_par03",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"04","Cliente De              ?",Space(20),Space(20),"mv_ch4","C",06,0,0,"G","","mv_par04",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SA1","","",""})
		AADD(aRegs,{cPerg,"05","Cliente Ate             ?",Space(20),Space(20),"mv_ch5","C",06,0,0,"G","","mv_par05",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SA1","","",""})
		AADD(aRegs,{cPerg,"06","Emissão De              ?",Space(20),Space(20),"mv_ch6","D",08,0,0,"G","","mv_par06",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"07","Emissão Ate             ?",Space(20),Space(20),"mv_ch7","D",08,0,0,"G","","mv_par07",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"08","Vencimento Real De      ?",Space(20),Space(20),"mv_ch8","D",08,0,0,"G","","mv_par08",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"09","Vencimento Real Ate     ?",Space(20),Space(20),"mv_ch9","D",08,0,0,"G","","mv_par09",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"10","Mensagem 1              ?",Space(20),Space(20),"mv_cha","C",03,0,0,"G","","mv_par10",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SM4","","",""})
		AADD(aRegs,{cPerg,"11","Mensagem 2              ?",Space(20),Space(20),"mv_chb","C",03,0,0,"G","","mv_par11",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SM4","","",""})
		AADD(aRegs,{cPerg,"12","Mensagem 3              ?",Space(20),Space(20),"mv_chc","C",03,0,0,"G","","mv_par12",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","","SM4","","",""})
		AADD(aRegs,{cPerg,"13","Número de Cópias        ?",Space(20),Space(20),"mv_chd","N",01,0,0,"G","","mv_par13",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"14","Banco Padrão            ?",Space(20),Space(20),"mv_che","C",03,0,0,"G","","mv_par14",""				,"","","","",""				,"","","","","","","","","","","","","","","","","","",""	,"","",""})
		AADD(aRegs,{cPerg,"15","Grupo De  	            ?",Space(20),Space(20),"mv_ch15","C",06,0,0,"G","","mv_par15",""			,"","","","",""				,"","","","","","","","","","","","","","","","","","","" ,"","",""})
		AADD(aRegs,{cPerg,"16","Grupo Ate               ?",Space(20),Space(20),"mv_ch16","C",06,0,0,"G","","mv_par16",""			,"","","","",""				,"","","","","","","","","","","","","","","","","","","   ","","",""})
	EndIf

	For i := 1 to Len(aRegs)
		If dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.F.)
		else
			RecLock("SX1",.T.)
		Endif
			For j := 1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next j
			MsUnlock()
			dbCommit()
		EndIf
	Next i

	dbSelectArea(_sAlias)

Return


