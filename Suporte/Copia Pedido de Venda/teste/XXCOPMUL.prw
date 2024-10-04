//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#DEFINE ITENSSC6 300

/*/{Protheus.doc} XCOPMUL
Função para copiar pedidos de venda
@author Wagner Neves
@since 25/09/2024
@version 1.0
@type function
/*/
User Function XXCOPMUL()
	Local aArea 	    := GetArea()
	Local nI
	Local nCopiado      := 0
	Private nQtdCop		:= 0
	Private lCopia		:= .F.

	//Chama tela de quantidade
	fTelaQtd()

	//Verifica confirmação e quantidade de copias
	If lCopia .AND. nQtdCop > 0
	Processa({|| teste('SC5',SC5->(RecNo()),3,nQtdCop)}, "Copia de Pedidos")
		For nI := 1 To nQtdCop
			nRet	:= 0
			//Copia pedidos solicitados
			// fCopPedV('SC5',SC5->(RecNo()),3,nQtdCop)
			If nRet = 1
				nCopiado++
			EndIf
		Next
		MsgInfo("Foram copiados: " +cValToChar(nCopiado)+ " pedidos de venda com sucesso!", "Copia Multipla")
	EndIf

	RestArea(aArea)
Return

Static Function teste(cAlias,nReg,nOpc,_nQtdCop)
	Local nI

	ProcRegua(_nQtdCop)

	For nI := 1 To _nQtdCop

		IncProc("Copiando Pedido: " + cValToChar(nI) + " de " + cValToChar(_nQtdCop) + "...")
		fCopPedV(cAlias,nReg,nOpc)
	Next

Return

/*---------------------------------------------------------------------*
 | Func:  fTelaQtd                                                     |
 | Desc:  Função que mostra tela de quantidade de pedidos a copiar     |
 *---------------------------------------------------------------------*/
Static Function fTelaQtd()
	Local oSay1
	Local oSay2
	Local btnOut
	Local btnGrv
    Private cFontUti    := "Tahoma"
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontSay    := TFont():New(cFontUti, , -12)
	Private oDlg1

	DEFINE MsDialog oDlg1 TITLE "Copia Multipla de Pedidos de Venda" STYLE DS_MODALFRAME FROM 0,0 TO 250,500 PIXEL

	@ 10,010 SAY oSay1 PROMPT 'Insira a quantidade de Pedidos a copiar' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
    
    @ 40,010 SAY oSay1 PROMPT 'Quantidade: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 35,060 MSGET oSay2 VAR nQtdCop PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL
                
	@ 100,030 BUTTON btnGrv PROMPT "Copiar" SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End(),iif(!lCopia,lCopia := .T.,lCopia := .F.)) OF oDlg1  PIXEL
	@ 100,135 BUTTON btnOut PROMPT "Sair" 	SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL
	
	ACTIVATE DIALOG oDlg1 CENTERED

Return

/*---------------------------------------------------------------------*
 | Func:  fCopPedV                                                     |
 | Desc:  Função que executa a copia dos pedidos de venda              |
 *---------------------------------------------------------------------*/
Static Function fCopPedV(cAlias,nReg,nOpc)

	Local aArea     := GetArea()
	Local aPosObj   := {}
	Local aObjects  := {}
	Local aSize     := {}
	Local aPosGet   := {}
	Local aRegSC6   := {}
	Local aRegSCV   := {}
	Local aInfo     := {}
	Local lLiber 	:= .F.
	Local lTransf	:= .F.
	Local lGrade	:= MaGrade()
	Local lQuery    := .F.
	Local lContinua := .T.
	Local lFreeze   := (SuperGetMv("MV_PEDFREZ",.F.,0) <> 0)
	Local nOpcA		:= 0
	Local nTotalPed := 0
	Local nTotalDes := 0
	Local nNumDec   := 0
	Local nGetLin   := 0
	Local nStack    := GetSX8Len()
	Local nColFreeze:= SuperGetMv("MV_PEDFREZ",.F.,0)
	Local lContTPV  := SuperGetMv("MV_TELAPVX",.F.,.F.)
	Local cArqQry   := "SC6"
	Local cCadastro := ""
	Local cTipoDat  := SuperGetMv("MV_TIPCPDT",.F.,"1")
	Local oDlg
	Local oGetd
	Local dOrig     := Ctod("//")
	Local dCopia    := Ctod("//")
	Local oSAY1
	Local oSAY2
	Local oSAY3
	Local oSAY4
	Local lMt410Ace := Existblock("MT410ACE")

	Local cSeek     := ""
	Local aNoFields := {"C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2"}		// Campos que nao devem entrar no aHeader e aCols
	Local bWhile    := {|| }
	Local cQuery    := ""
	Local bCond     := {|| .T. }
	Local lCopia    := .T.
	Local bAction1  := {|| Mta410Cop(cArqQry,@nTotalPed,@nTotalDes,lGrade, lCopia) }
	Local bAction2  := {|| .T. }
	Local aRecnoSE1RA := {} // Array com os titulos selecionados pelo Adiantamento
	Local nPosTpCompl := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis utilizadas na LinhaOk                      ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aCols      := {}
	PRIVATE aHeader    := {}
	PRIVATE aHeadFor   := {}
	PRIVATE aColsFor   := {}
	PRIVATE N          := 1
	PRIVATE oGetPV		:= Nil

	PRIVATE aGEMCVnd :={"",{},{}} //Template GEM - Condicao de Venda

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta a entrada de dados do arquivo                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aTELA[0][0],aGETS[0]

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Array para controlar relacionamento com SD4 (Remessa para Beneficiamento ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE aColsBn := {}

	PRIVATE aHeadAGG    := {}
	PRIVATE aColsAGG    := {}

	If Type("lRetNat") == "U"
		Private lRetNat := Nil
	EndIf

	lRetNat := .T.

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se o campo de codigo de lancamento cat 83 ³
	//³deve estar visivel no acols                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !SuperGetMV("MV_CAT8309",,.F.)
		aAdd(aNoFields,"C6_CODLAN")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ponto de entrada para validar acesso do usuario na funcao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lMt410Ace
		lContinua := Execblock("MT410ACE",.F.,.F.,{nOpc})
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Agroindustria  									              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !( Type("l410Auto") <> "U" .And. l410Auto ) .AND. OGXUtlOrig()
		lContinua := OGX220("")
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria Ambiente/Objeto para tratamento de grade        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PRIVATE oGrade	  := MsMatGrade():New('oGrade',,"C6_QTDVEN",,"a410GValid()",;
										{{VK_F4,{|| A440Saldo(.T.,oGrade:aColsAux[oGrade:nPosLinO][aScan(oGrade:aHeadAux,{|x| AllTrim(x[2])=="C6_LOCAL"})])}} },;
										{{"C6_QTDVEN",.T.,{{"C6_UNSVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),aCols[nLinha][nColuna],0,2) } }} },;
										{"C6_QTDLIB",NIL,NIL},;
										{"C6_QTDENT",NIL,NIL},;
										{"C6_ITEM",NIL,NIL},;
										{"C6_UNSVEN",{{"C6_QTDVEN",{|| ConvUm(AllTrim(oGrade:GetNameProd(,nLinha,nColuna)),0,aCols[nLinha][nColuna],1) }}} },;
										{"C6_OPC",NIL,NIL},;
										{"C6_NUMOP",NIL,NIL},;
										{"C6_ITEMOP",NIL,NIL},;
										{"C6_BLQ",NIL,NIL};
										})

	//-- Inicializa grade multicampo
	A410InGrdM(.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Carrega perguntas do MATA440 e MATA410                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	INCLUI := .T.
	ALTERA := .F.

	Pergunte("MTA440",.F.)
	lLiber := MV_PAR02 == 1
	lTransf:= MV_PAR01 == 1
	Pergunte("MTA410",.F.)
	//Carrega as variaveis com os parametros da execauto
	Ma410PerAut()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variavel utilizada p/definir Op. Triangulares.       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IsTriangular( MV_PAR03==1 )
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Salva a integridade dos campos de Bancos de Dados    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAlias)
	IF ( (ExistBlock("M410ALOK")) )
		lContinua := ExecBlock("M410ALOK",.F.,.F.)
	EndIf
	IF ( SC5->C5_FILIAL <> xFilial("SC5") )
		Help(" ",1,"A000FI")
		lContinua := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//| Se o Pedido foi originado no SIGATMS - Nao Copia     |
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(SC5->C5_SOLFRE)
		Help(" ",1,"A410TMSNAO")
		lContinua := .F.
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa desta forma para criar uma nova instancia de variaveis private ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "SC5", .F., .F. )

	dOrig  := M->C5_EMISSAO
	dCopia := CriaVar("C5_EMISSAO",.T.)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Limpa as variaveis que possuem amarracoes do pedido anterior              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	M->C5_NOTA  := Space(Len(SC5->C5_NOTA))
	M->C5_SERIE := Space(Len(SC5->C5_SERIE))
	M->C5_OS    := Space(Len(SC5->C5_OS))
	M->C5_PEDEXP:= Space(Len(SC5->C5_PEDEXP))
	M->C5_DTLANC:= Ctod("")

	//Limpa as variaveis que tem referencia com o contrato GCT
	M->C5_MDCONTR  	:= Space(Len(M->C5_MDCONTR))
	M->C5_MDNUMED 	:= Space(Len(SC5->C5_MDNUMED))
	M->C5_MDPLANI   := Space(Len(SC5->C5_MDPLANI))

	If lContinua
		lContinua := If(lGrade.And.MatOrigGrd()=="SB4",VldDocGrd(1,SC5->C5_NUM),.T.)
	EndIf

	If ( lContinua )
		dbSelectArea("SC6")
		dbSetOrder(1)
		#IFDEF TOP
			If TcSrvType()<>"AS/400" .And. !InTransact() .And. Ascan(aHeader,{|x| x[8] == "M"}) == 0
				lQuery  := .T.
				cQuery := "SELECT SC6.*,SC6.R_E_C_N_O_ SC6RECNO "
				cQuery += "FROM "+RetSqlName("SC6")+" SC6 "
				cQuery += "WHERE SC6.C6_FILIAL='"+xFilial("SC6")+"' AND "
				cQuery += "SC6.C6_NUM='"+SC5->C5_NUM+"' AND "
				cQuery += "SC6.D_E_L_E_T_ = ' ' "
				cQuery += "ORDER BY "+SqlOrder(SC6->(IndexKey()))
				dbSelectArea("SC6")
				dbCloseArea()
			EndIf
		#ENDIF
		cSeek  := xFilial("SC6")+SC5->C5_NUM
		bWhile := {|| C6_FILIAL+C6_NUM }

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Montagem do aHeader e aCols                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		FillGetDados(7,"SC6",1,cSeek,bWhile,{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,{|| AfterCols(cArqQry,cTipoDat,dCopia,dOrig,lCopia) },/*bBeforeCols*/,/*bAfterHeader*/,"SC6")

		//Limpa o cache para não repetir a mensagem do mesmo produto durante a copia caso o mesmo estiver bloqueado.
		A410ClrPCpy()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Carrega os dados do rateio³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A410FRat(@aHeadAGG,@aColsAGG)

		nTotalDes  += A410Arred(nTotalPed*M->C5_PDESCAB/100,"C6_VALOR")
		nTotalPed  -= A410Arred(nTotalPed*M->C5_PDESCAB/100,"C6_VALOR")
		nTotalPed  -= M->C5_DESCONT
		nTotalDes  += M->C5_DESCONT

		If ( lQuery )
			dbSelectArea(cArqQry)
			dbCloseArea()
			ChkFile("SC6",.F.)
			dbSelectArea("SC6")
		EndIf
	EndIf

	If lContinua
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Inicializa ambiente de integração com Planilha ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		A410RvPlan("","",.T.)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Monta o array com as formas de pagamento do SX5³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		Ma410MtFor(@aHeadFor,@aColsFor)
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Caso nao ache nenhum item , abandona rotina.         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua .AND. Len(aCols) == 0
		lContinua := .F.
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta as variaveis para copia                                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lContinua
		M->C5_NUM := CriaVar("C5_NUM",.T.)
		M->C5_EMISSAO := CriaVar("C5_EMISSAO",.T.)
		aRegSC6 := {}
		aRegSCV := {}
		//
		// Template GEM - Gestao de Empreendimentos Imobiliarios
		//
		// Carrega a condicao de venda se a mesma tiver
		// uma vinculacao com a pedido/condicao de pagamento
		//
		If ExistBlock("GEM410PV")
			aGEMCVnd := ExecBlock("GEM410PV",.F.,.F.,{ SC5->C5_NUM ,SC5->C5_CONDPAG ,M->C5_EMISSAO ,nTotalPed })
		ElseIf ExistTemplate("GEM410PV")
			// Copia a condicao de venda
			aGEMCVnd := ExecTemplate("GEM410PV",.F.,.F.,{ SC5->C5_NUM ,SC5->C5_CONDPAG ,M->C5_EMISSAO ,nTotalPed })
		EndIf
		//Initializing MatXFis arrays
		If (cPaisLoc == "RUS")
			RU05XFN007(aHeader,@aCols)
		Endif

		If ExistBlock("MT410CPY")
			ExecBlock("MT410CPY",.F.,.F.)
		EndIf
	EndIf
	If ( lContinua )
		If ( Type("l410Auto") == "U" .OR. !l410Auto )
			nNumDec := IIf(cPaisLoc <> "BRA",MsDecimais(M->C5_MOEDA),TamSX3("C6_VALOR")[2])
			cCadastro := IIF(cCadastro == Nil,OemToAnsi("Atualização de Pedidos de Venda"),cCadastro) //"Atualização de Pedidos de Venda"
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Faz o calculo automatico de dimensoes de objetos     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aSize := MsAdvSize()
			aObjects := {}
			aAdd( aObjects, { 100, 100, .t., .t. } )
			aAdd( aObjects, { 100, 100, .t., .t. } )
			aAdd( aObjects, { 100, 020, .t., .f. } )
			aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
			aPosObj := MsObjSize( aInfo, aObjects )
			aPosGet := MsObjGetPos(aSize[3]-aSize[1],315,{{003,033,160,200,240,263}} )
			nGetLin := aPosObj[3,1]
			If lContTPV
				DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL STYLE nOR( WS_VISIBLE ,DS_MODALFRAME )
			Else
				DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Armazenar dados do Pedido anterior.                  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF M->C5_TIPO $ "DB"
				aTrocaF3 := {{"C5_CLIENTE","SA2"}}
			Else
				aTrocaF3 := {}
			EndIf
			oGetPV:=MSMGet():New( "SC5", nReg, nOpc, , , , , aPosObj[1],,3,,,"A415VldTOk")
	//		@ nGetLin,aPosGet[1,1]  SAY OemToAnsi(IIF(M->C5_TIPO$"DB",STR0008,STR0009)) SIZE 020,09 PIXEL	//"Fornec.:"###"Cliente: "
			@ nGetLin,aPosGet[1,2]  SAY oSAY1 VAR Space(40)						SIZE 120,09 PICTURE "@!"	OF oDlg PIXEL
			@ nGetLin,aPosGet[1,3]  SAY OemToAnsi("Total :")						SIZE 020,09 OF oDlg PIXEL	//"Total :"
			@ nGetLin,aPosGet[1,4]  SAY oSAY2 VAR 0 							SIZE 060,09 PICTURE IIf(cPaisloc $ "CHI|PAR",Nil,TM(0,22,nNumDec)) OF oDlg PIXEL
			@ nGetLin,aPosGet[1,5]  SAY OemToAnsi("Desc. :")						SIZE 035,09 OF oDlg PIXEL 	//"Desc. :"
			@ nGetLin,aPosGet[1,6]  SAY oSAY3 VAR 0 							SIZE 060,09 PICTURE IIf(cPaisloc $ "CHI|PAR",Nil,TM(0,22,nNumDec)) OF oDlg PIXEL RIGHT
			@ nGetLin+10,aPosGet[1,5]  SAY OemToAnsi("=")						SIZE 020,09 OF oDlg PIXEL
			If cPaisLoc == "BRA"
				@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 060,09 PICTURE TM(0,22,2) OF oDlg PIXEL RIGHT
			Else
				@ nGetLin+10,aPosGet[1,6]  SAY oSAY4 VAR 0								SIZE 060,09 PICTURE IIf(cPaisloc $ "CHI|PAR",Nil,TM(0,22,nNumDec)) OF oDlg PIXEL RIGHT
			EndIf
			oDlg:Cargo	:= {|c1,n2,n3,n4| oSay1:SetText(c1),;
				oSay2:SetText(n2),;
				oSay3:SetText(n3),;
				oSay4:SetText(n4) }
			Set Key VK_F4 to A440Stok(NIL,"A410")

			If cPaisLoc == "BRA" .And. !(M->C5_TIPO $ "C")
				nPosTpCompl := Ascan(oGetPV:aEntryCtrls,{|x| UPPER(TRIM(x:cReadVar))=="M->C5_TPCOMPL"})
				If nPosTpCompl > 0
					oGetPV:aEntryCtrls[nPosTpCompl]:lReadOnly := .T.
				EndIf
			EndIf

			oGetd:=MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpc,"A410LinOk","A410TudOk","+C6_ITEM/C6_Local/C6_TES/C6_CF/C6_PEDCLI",.T.,,nColFreeze,,ITENSSC6*IIF(MaGrade(),1,3.33),"A410Blq()",,,"A410ValDel(.F.)",,lFreeze)
			Private oGetDad:=oGetd
			A410Bonus(2)
			Ma410Rodap(oGetD,nTotalPed,nTotalDes)

			A410Limpa(.F.,M->C5_TIPO)

			// ACTIVATE MSDIALOG oDlg ON INIT (Ma410Bar(oDlg,{||nOpcA:=1,if(A410VldTOk(nOpc, aRecnoSE1RA).And.oGetd:TudoOk(),If(!obrigatorio(aGets,aTela),nOpcA := 0,oDlg:End()),nOpcA := 0)},{||oDlg:End()},nOpc,oGetD,nTotalPed,@aRecnoSE1RA,@aHeadAGG,@aColsAGG))
			nOpcA:=1
			SetKey(VK_F4,)
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ validando dados pela rotina automatica                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Type("aRotina") <> "U"
				If EnchAuto(cAlias,aAutoCab,{|| Obrigatorio(aGets,aTela)},aRotina[nOpc][4]) .and. MsGetDAuto(aAutoItens,"A410LinOk",{|| A410VldTOk(nOpc) .and. A410TudOk()},aAutoCab)
					nOpcA := 1
					If cPaisloc == "BRA" .And. ValType(aAposEsp) <> Nil .And. !Empty(aAposEsp) .And. FindFunction("a410INSS")
						a410INSS()
					Endif
				EndIf
			Else
				nOpca := 1
			EndIf
		EndIf
		If ( nOpcA == 1 )
			A410Bonus(1)
			If Type("lOnUpDate") == "U" .Or. lOnUpdate
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoIniLan("000100")

				If !A410Grava(lLiber,lTransf,1,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,aColsBn,aRecnoSE1RA,aHeadAGG,aColsAGG)
					Help(" ",1,"A410NAOREG")
				Else
					// ======================================================================
					// Integração GRR - Gestão de Receita Recorrente 
					// Avalia se a integração com o GRR está ativa e cria a relação do novo 
					// pedido com os dados adicionais da subscrição se a condição de pagamento
					// usada for do GRR e o pedido não for originado por um contrato.
					// ======================================================================
					If FindFunction( "GRRIsActive" ) .And. FindFunction( "IsGRRPayment" ) .And. FindFunction( "GRRSetHRHInfo" ) ;
						.And. GRRIsActive() .And. IsGRRPayment( M->C5_CONDPAG ) .And. Empty( Alltrim( M->C5_MDCONTR ) )
							GRRSetHRHInfo( 'SC5', SC5->C5_NUM, "MATA410" )
					EndIf
				EndIf
				If ( (ExistBlock("M410STTS") ) )
					ExecBlock("M410STTS",.F.,.F.,{6})	// 6- Identificar a operação da cópia
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PcoFinLan("000100")

			Else
				aAutoCab := MsAuto2Ench("SC5")
				aAutoItens := MsAuto2Gd(aHeader,aCols)
			EndIf
		Else
			While GetSX8Len() > nStack
				RollBackSX8()
			EndDo
			If ( (ExistBlock("M410ABN")) )
				ExecBlock("M410ABN",.f.,.f.)
			EndIf
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Destrava Todos os Registros                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	MsUnLockAll()
	RestArea(aArea)
Return( nOpcA )
