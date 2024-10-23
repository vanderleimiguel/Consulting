#Include 'Totvs.ch'
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"

#Define STR_PULA    Chr(13)+Chr(10)
#DEFINE ITENSSC6 300

/*/{Protheus.doc} XCOPMUL
Fun��o para copiar multiplos pedidos de venda
@author Wagner Neves
@since 25/09/2024
@version 1.0
@type function
/*/
User Function XCOPMUL()
	Private nCopiado    := 0
	Private nQtdCop		:= 0
	Private lCopia		:= .F.

	//Chama tela de quantidade
	fTelaQtd()

	//Verifica confirma��o e quantidade de copias
	If lCopia .AND. nQtdCop > 0
	
		Processa({|| fCopPedV('SC5',SC5->(RecNo()),3, nQtdCop)}, "Copia de Pedidos")
	
		MsgInfo("Foram copiados: " +cValToChar(nCopiado)+ " pedidos de venda com sucesso!", "Copia Multipla")
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fTelaQtd                                                     |
 | Desc:  Fun��o que mostra tela de quantidade de pedidos a copiar     |
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
 | Desc:  Fun��o que executa a copia dos pedidos de venda              |
 *---------------------------------------------------------------------*/
Static function fCopPedV(cAlias,nReg,nOpc,_nQtdCop)
	Local nI
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

	//������������������������������������������������������Ŀ
	//� Variaveis utilizadas na LinhaOk                      �
	//��������������������������������������������������������
	PRIVATE aCols      := {}
	PRIVATE aHeader    := {}
	PRIVATE aHeadFor   := {}
	PRIVATE aColsFor   := {}
	PRIVATE N          := 1
	PRIVATE oGetPV		:= Nil

	PRIVATE aGEMCVnd :={"",{},{}} //Template GEM - Condicao de Venda

	//������������������������������������������������������Ŀ
	//� Monta a entrada de dados do arquivo                  �
	//��������������������������������������������������������
	PRIVATE aTELA[0][0],aGETS[0]

	//�������������������������������������������������������������������������Ŀ
	//�Array para controlar relacionamento com SD4 (Remessa para Beneficiamento �
	//���������������������������������������������������������������������������
	PRIVATE aColsBn := {}

	PRIVATE aHeadAGG    := {}
	PRIVATE aColsAGG    := {}
	If Type("lRetNat") == "U"
		Private lRetNat := Nil
	EndIf

	ProcRegua(_nQtdCop)

	For nI := 1 To _nQtdCop
		
		IncProc("Copiando Pedido: " + cValToChar(nI) + " de " + cValToChar(_nQtdCop) + "...")

		aPosObj   	:= {}
		aObjects  	:= {}
		aSize     	:= {}
		aPosGet   	:= {}
		aRegSC6   	:= {}
		aRegSCV   	:= {}
		aInfo		:= {}
		lLiber 		:= .F.
		lTransf		:= .F.
		lGrade		:= MaGrade()
		lQuery    	:= .F.
		lContinua 	:= .T.
		lFreeze   	:= (SuperGetMv("MV_PEDFREZ",.F.,0) <> 0)
		nOpcA		:= 0
		nTotalPed 	:= 0
		nTotalDes 	:= 0
		nNumDec   	:= 0
		nGetLin   	:= 0
		nStack    	:= GetSX8Len()
		nColFreeze	:= SuperGetMv("MV_PEDFREZ",.F.,0)
		lContTPV  	:= SuperGetMv("MV_TELAPVX",.F.,.F.)
		cArqQry   	:= "SC6"
		cCadastro 	:= ""
		cTipoDat  	:= SuperGetMv("MV_TIPCPDT",.F.,"1")
		oDlg 		:= Nil
		oGetd 		:= Nil
		dOrig     	:= Ctod("//")
		dCopia    	:= Ctod("//")
		oSAY1  		:= Nil
		oSAY2 		:= Nil
		oSAY3 		:= Nil
		oSAY4 		:= Nil
		lMt410Ace 	:= Existblock("MT410ACE")

		cSeek     	:= ""
		aNoFields 	:= {"C6_NUM","C6_QTDEMP","C6_QTDENT","C6_QTDEMP2","C6_QTDENT2"}		// Campos que nao devem entrar no aHeader e aCols
		bWhile    	:= {|| }
		cQuery    	:= ""
		bCond     	:= {|| .T. }
		lCopia    	:= .T.
		bAction1  	:= {|| Mta410Cop(cArqQry,@nTotalPed,@nTotalDes,lGrade, lCopia) }
		bAction2  	:= {|| .T. }
		aRecnoSE1RA := {} // Array com os titulos selecionados pelo Adiantamento
		nPosTpCompl := 0

		aCols      	:= {}
		aHeader    	:= {}
		aHeadFor   	:= {}
		aColsFor   	:= {}
		N          	:= 1
		oGetPV		:= Nil
		aGEMCVnd 	:={"",{},{}} //Template GEM - Condicao de Venda
		aColsBn 	:= {}
		aHeadAGG    := {}
		aColsAGG    := {}

		If Type("lRetNat") == "U"
			lRetNat := Nil
		EndIf

		lRetNat 	:= .T.

		//���������������������������������������������������Ŀ
		//�Verifica se o campo de codigo de lancamento cat 83 �
		//�deve estar visivel no acols                        �
		//�����������������������������������������������������

		If !SuperGetMV("MV_CAT8309",,.F.)
			aAdd(aNoFields,"C6_CODLAN")
		EndIf

		//�����������������������������������������������������������Ŀ
		//� Ponto de entrada para validar acesso do usuario na funcao �
		//�������������������������������������������������������������
		If lMt410Ace
			lContinua := Execblock("MT410ACE",.F.,.F.,{nOpc})
		Endif

		//���������������������������������������������������������������Ŀ
		//� Agroindustria  									              �
		//�����������������������������������������������������������������
		If !( Type("l410Auto") <> "U" .And. l410Auto ) .AND. OGXUtlOrig()
			lContinua := OGX220("")
		EndIf

		//������������������������������������������������������Ŀ
		//� Cria Ambiente/Objeto para tratamento de grade        �
		//��������������������������������������������������������
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

		//������������������������������������������������������������������������Ŀ
		//�Carrega perguntas do MATA440 e MATA410                                  �
		//��������������������������������������������������������������������������
		INCLUI := .T.
		ALTERA := .F.

		Pergunte("MTA440",.F.)
		lLiber := MV_PAR02 == 1
		lTransf:= MV_PAR01 == 1
		Pergunte("MTA410",.F.)
		//Carrega as variaveis com os parametros da execauto
		Ma410PerAut()

		//������������������������������������������������������Ŀ
		//� Variavel utilizada p/definir Op. Triangulares.       �
		//��������������������������������������������������������
		IsTriangular( MV_PAR03==1 )
		//������������������������������������������������������Ŀ
		//� Salva a integridade dos campos de Bancos de Dados    �
		//��������������������������������������������������������
		dbSelectArea(cAlias)
		IF ( (ExistBlock("M410ALOK")) )
			lContinua := ExecBlock("M410ALOK",.F.,.F.)
		EndIf
		IF ( SC5->C5_FILIAL <> xFilial("SC5") )
			Help(" ",1,"A000FI")
			lContinua := .F.
		EndIf
		//������������������������������������������������������Ŀ
		//| Se o Pedido foi originado no SIGATMS - Nao Copia     |
		//��������������������������������������������������������
		If !Empty(SC5->C5_SOLFRE)
			Help(" ",1,"A410TMSNAO")
			lContinua := .F.
		EndIf

		//���������������������������������������������������������������������������Ŀ
		//� Inicializa desta forma para criar uma nova instancia de variaveis private �
		//�����������������������������������������������������������������������������
		RegToMemory( "SC5", .F., .F. )

		dOrig  := M->C5_EMISSAO
		dCopia := CriaVar("C5_EMISSAO",.T.)

		//���������������������������������������������������������������������������Ŀ
		//� Limpa as variaveis que possuem amarracoes do pedido anterior              �
		//�����������������������������������������������������������������������������
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

			//������������������������������������������������������Ŀ
			//� Montagem do aHeader e aCols                          �
			//��������������������������������������������������������
			FillGetDados(7,"SC6",1,cSeek,bWhile,{{bCond,bAction1,bAction2}},aNoFields,/*aYesFields*/,/*lOnlyYes*/,cQuery,/*bMontCols*/,.F.,/*aHeaderAux*/,/*aColsAux*/,{|| AfterCols(cArqQry,cTipoDat,dCopia,dOrig,lCopia) },/*bBeforeCols*/,/*bAfterHeader*/,"SC6")

			//Limpa o cache para n�o repetir a mensagem do mesmo produto durante a copia caso o mesmo estiver bloqueado.
			A410ClrPCpy()

			//��������������������������Ŀ
			//�Carrega os dados do rateio�
			//����������������������������
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

				//vm
		If lContinua
			//�����������������������������������������������Ŀ
			//�Inicializa ambiente de integra��o com Planilha �
			//�������������������������������������������������
			A410RvPlan("","",.T.)

			//�����������������������������������������������Ŀ
			//�Monta o array com as formas de pagamento do SX5�
			//�������������������������������������������������
			Ma410MtFor(@aHeadFor,@aColsFor)
		EndIf
		//������������������������������������������������������Ŀ
		//� Caso nao ache nenhum item , abandona rotina.         �
		//��������������������������������������������������������
		If lContinua .AND. Len(aCols) == 0
			lContinua := .F.
		EndIf
		//���������������������������������������������������������������������������Ŀ
		//� Ajusta as variaveis para copia                                            �
		//�����������������������������������������������������������������������������
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
			nOpca := 1 //VM
			If ( nOpcA == 1 )
				A410Bonus(1)
				If Type("lOnUpDate") == "U" .Or. lOnUpdate
					//�����������������������������������������������������������Ŀ
					//� Inicializa a gravacao dos lancamentos do SIGAPCO          �
					//�������������������������������������������������������������
					PcoIniLan("000100")

					If !A410Grava(lLiber,lTransf,1,aHeadFor,aColsFor,aRegSC6,aRegSCV,nStack,aColsBn,aRecnoSE1RA,aHeadAGG,aColsAGG)
						Help(" ",1,"A410NAOREG")
					Else
						// ======================================================================
						// Integra��o GRR - Gest�o de Receita Recorrente 
						// Avalia se a integra��o com o GRR est� ativa e cria a rela��o do novo 
						// pedido com os dados adicionais da subscri��o se a condi��o de pagamento
						// usada for do GRR e o pedido n�o for originado por um contrato.
						// ======================================================================
						If FindFunction( "GRRIsActive" ) .And. FindFunction( "IsGRRPayment" ) .And. FindFunction( "GRRSetHRHInfo" ) ;
							.And. GRRIsActive() .And. IsGRRPayment( M->C5_CONDPAG ) .And. Empty( Alltrim( M->C5_MDCONTR ) )
								GRRSetHRHInfo( 'SC5', SC5->C5_NUM, "MATA410" )
						EndIf
					EndIf
					If ( (ExistBlock("M410STTS") ) )
						ExecBlock("M410STTS",.F.,.F.,{6})	// 6- Identificar a opera��o da c�pia
					EndIf

					//�����������������������������������������������������������Ŀ
					//� Finaliza a gravacao dos lancamentos do SIGAPCO            �
					//�������������������������������������������������������������
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
		//������������������������������������������������������������������������Ŀ
		//�Destrava Todos os Registros                                             �
		//��������������������������������������������������������������������������
		MsUnLockAll()
		nCopiado++
	Next

Return Nil

