#INCLUDE "PROTHEUS.CH"
#include "FWMVCDEF.CH"
#include "TOTVS.CH"

Static lFWCodFil := FindFunction("FWCodFil")
Static lAtuSldNat := FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
Static dLastPcc  := CTOD("22/06/2015")

/*/{Protheus.doc} XMATA530
Fun��o para pagar comissao baseada no padrao MATA530
@author Wagner Neves
@since 22/10/2024
@version 1.0
@type function
/*/
User Function XMATA530()
	Local cCadastro 	:= OemToAnsi("Atual. Pag. de Comiss�o     ")
	LOCAL nOpca 		:= 0
	Local aSays			:={}, aButtons:={}
	Local lReturn 		:= .F.
	Local lPanelFin 	:= If (FindFunction("IsPanelFin"),IsPanelFin(),.F.)

	Private cCodDiario	:= ""
	Private cAliasTmp 	:= GetNextAlias()
	Private lIRProg		:= "2"
	Private cFilSE3		:= xFilial("SE3")
	Private lCpoProcCo	:= SE3->(ColumnPos("E3_PROCCOM")) > 0
	Private lCpoMoeda	:= SE3->(ColumnPos("E3_MOEDA")) > 0

	/*
	---------------------------------------------------------------------------
	Variaveis utilizadas para parametros                     
	mv_par01            // Gerar pela(Emissao/Baixa/Ambos)   
	mv_par02            // Considera da data                 
	mv_par03            // ate a data                        
	mv_par04            // Do Vendedor                       
	mv_par05            // Ate o vendedor                    
	mv_par06            // Data de Pagamento                 
	mv_par07            // Gera ctas a Pagar (Sim/Nao)       
	mv_par08            // Contabiliza on-line               
	mv_par09            // Mostra lcto Contabil              
	mv_par10            // Vencimento de                     
	mv_par11            // Vencimento Ate                    
	mv_par12            // Considera data (Vencto/Pagamento) 
	mv_par13            // Seleciona Filial					 
	mv_par14            // Filial De? 						 
	mv_par15            // Filial At�?						 
	---------------------------------------------------------------------------
	*/

	Pergunte("MTA530",.F.)
	AADD(aSays,OemToAnsi( "Este programa tem como objetivo solicitar e atualizar" ) )
	AADD(aSays,OemToAnsi( "a data para pagamento das comiss�es dos Vendedores.        " ) )

	If lPanelFin  //Chamado pelo Painel Financeiro
		aButtonTxt := {}
		AADD(aButtonTxt,{"Par�metros","Par�metros", {||Pergunte("MTA530",.T. )}})
		FaMyFormBatch(aSays,aButtonTxt,{||nOpca:= 1,If(CA530Ok(),,nOpca:=0 )},{||nOpca:=0})
	Else
		AADD(aButtons, { 5,.T.,{|| Pergunte("MTA530",.T. ) } } )
		AADD(aButtons, { 1,.T.,{|o| nOpca:= 1, If( CA530Ok(), o:oWnd:End(), nOpca:=0 ) }} )
		AADD(aButtons, { 2,.T.,{|o| o:oWnd:End() }} )
		FormBatch( cCadastro, aSays, aButtons ,,220,380)
	Endif

	If nOpca == 1 .Or. lReturn
		If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
			cCodDiario := CTBAVerDia()
		EndIf

		If MV_PAR13 == 1 .And. FWModeAccess("SE3",3)=="E" .And. FWModeAccess("SE2",3)=="E"  // Seleciona filiais
			Processa( { |lEnd| fMontaTela() })
		Else
			Processa( { |lEnd| fMontaTela() })
		EndIf

	EndIf

Return(.T.)

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Desc:  Fun��o para montar tela    							       |
 *---------------------------------------------------------------------*/
Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos 		:= {}
	Local oTempTable 	:= Nil
	Local aColunas 		:= {}
	Local cFontPad    	:= 'Tahoma'
	Local oFontGrid   	:= TFont():New(cFontPad,,-14)
	Local aSeek   		:= {}
	//Janela e componentes
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp 	:= GetNextAlias()
	Private aRotina   	:= MenuDef()
	//Tamanho da janela
	Private aTamanho 	:= MsAdvSize()
	Private nJanLarg 	:= aTamanho[5]
	Private nJanAltu 	:= aTamanho[6]
	Private lVoltar		:= .F.
	Private nMarcado	:= 0
	Private nValorMar	:= 0
	Private cFontUti    := "Tahoma"
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)

	//Adiciona as colunas que ser�o criadas na tempor�ria
	aAdd(aCampos, { 'OK'		, 'C', 2						, 0})
	aAdd(aCampos, { 'E3_FILIAL'	, 'C', TamSX3("E3_FILIAL")[1]	, 0})
	aAdd(aCampos, { 'E3_VEND'	, 'C', TamSX3("E3_VEND")[1]		, 0})
	aAdd(aCampos, { 'E3_NUM'	, 'C', TamSX3("E3_NUM")[1]		, 0})
	aAdd(aCampos, { 'E3_PARCELA', 'C', TamSX3("E3_PARCELA")[1]  , 0})
	aAdd(aCampos, { 'E3_TIPO'	, 'C', TamSX3("E3_TIPO")[1]		, 0})
	aAdd(aCampos, { 'E3_BAIEMI'	, 'C', TamSX3("E3_BAIEMI")[1]	, 0})
	aAdd(aCampos, { 'E3_VENCTO'	, 'D', TamSX3("E3_VENCTO")[1]	, 0})
	aAdd(aCampos, { 'E3_DATA'	, 'D', TamSX3("E3_DATA")[1]		, 0})
	aAdd(aCampos, { 'E3_COMIS'	, 'N', TamSX3("E3_COMIS")[1]	, 2})
	aAdd(aCampos, { 'E3_MOEDA'	, 'C', TamSX3("E3_MOEDA")[1]	, 0})
	aAdd(aCampos, { 'E3_PROCCOM', 'C', TamSX3("E3_PROCCOM")[1]	, 0})
	aAdd(aCampos, { 'E3_PREFIXO', 'C', TamSX3("E3_PREFIXO")[1]	, 0})
	aAdd(aCampos, { 'E3_PEDIDO',  'C', TamSX3("E3_PEDIDO")[1]	, 0})
	aAdd(aCampos, { 'E3_SERIE',   'C', TamSX3("E3_SERIE")[1]	, 0})
	aAdd(aCampos, { 'A3_NOME',    'C', TamSX3("A3_NOME")[1]		, 0})
	aAdd(aCampos, { 'E3_CODCLI',  'C', TamSX3("E3_CODCLI")[1]	, 0})
	aAdd(aCampos, { 'E3_LOJA',    'C', TamSX3("E3_LOJA")[1]		, 0})
	aAdd(aCampos, { 'A1_NREDUZ',  'C', TamSX3("A1_NREDUZ")[1]	, 0})
	aAdd(aCampos, { 'E3_BASE',    'N', TamSX3("E3_BASE")[1]		, 2})
	aAdd(aCampos, { 'E3_PORC',    'N', TamSX3("E3_PORC")[1]		, 2})
	aAdd(aCampos, { 'E3Recno'	, 'N', 20	, 0})

	//Cria a tabela tempor�ria
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"E3_FILIAL", "E3_NUM"})
	oTempTable:Create()

	//Popula a tabela tempor�ria
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que ser�o exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//Criando a janela

    cCampoAux := "E3_NUM"
    aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}}}  )

	DEFINE MSDIALOG oDlgMark TITLE 'Pagamento de Comiss�es' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
	@ 300,010 SAY oSay1 PROMPT "T�tulos Marcados:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 300,070 SAY oSay2 VAR nMarcado PICTURE "@E 999,999" SIZE 030, 015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 320,010 SAY oSay3 PROMPT "Valor Marcado R$"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 320,070 SAY oSay4 VAR nValorMar PICTURE '@E 999,999.99' SIZE 030, 015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, 290)
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetDescription('T�tulos de Comiss�es')
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:oBrowse:SetDBFFilter(.T.)
    oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utiliza��o do filtro no Browse
    oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
    oMarkBrowse:SetWalkThru(.F.) //Habilita a utiliza��o da funcionalidade Walk-Thru no Browse
    oMarkBrowse:SetAmbiente(.T.) //Habilita a utiliza��o da funcionalidade Ambiente no Browse
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:oBrowse:SetSeek(.T.,aSeek)
	oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padr�o do Browse
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:SetColumns(aColunas)
	oMarkBrowse:SetAfterMark({|| fMarcado()})
	// oMarkBrowse:SetAllMark({|| oMarkBrowse:AllMark() })
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a tempor�ria e desativa a tela de marca��o
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMarcado                                                     |
 | Desc:  Fun��o para atualizar valores							       |
 *---------------------------------------------------------------------*/
Static Function fMarcado()
	Local cMarca    	:= oMarkBrowse:Mark()

	If oMarkBrowse:IsMark(cMarca)
		nMarcado++
		nValorMar	+= (cAliasTmp)->E3_COMIS
	Else
		nMarcado--
		nValorMar	-= (cAliasTmp)->E3_COMIS
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Fun��o para botoes do menu							       |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}

	//Cria��o das op��es do menu
	ADD OPTION aRotina TITLE 'Baixar Comiss�o'  	ACTION 'U_fPagComis'	OPERATION 2 ACCESS 0	

Return aRotina

/*---------------------------------------------------------------------*
 | Func:  fPopula                                                      |
 | Desc:  Fun��o para popular tabela temporaria					       |
 *---------------------------------------------------------------------*/
Static Function fPopula()
	Local cQryDados := ''
	Local nTotal 	:= 0
	Local nAtual 	:= 0

	//Busca titulos atraves dos parametros
	cQryDados := " SELECT E3_PREFIXO,E3_NUM,E3_PARCELA,E3_VEND,E3_PEDIDO,E3_TIPO,E3_BAIEMI,E3_FILIAL,E3_VENCTO,E3_DATA,E3_COMIS,E3_SERIE,A3_NOME,E3_CODCLI,E3_LOJA,A1_NREDUZ,E3_BASE,E3_PORC,"
	If lCpoMoeda
		cQryDados += " E3_MOEDA, "
	Endif
	If lCpoProcCo
		cQryDados += " E3_PROCCOM, "
	Endif
	cQryDados += " SE3.R_E_C_N_O_ "
	cQryDados += " FROM "+RetSqlName("SE3")+" SE3"
	cQryDados += " INNER JOIN "+RETSQLNAME("SA1") +" SA1 ON SE3.E3_CODCLI=SA1.A1_COD AND SE3.E3_LOJA=SA1.A1_LOJA AND SA1.D_E_L_E_T_=' '"
	cQryDados += " INNER JOIN "+RETSQLNAME("SA3") +" SA3 ON SE3.E3_VEND=SA3.A3_COD AND SA3.D_E_L_E_T_=' '"
	If MV_PAR13 == 2
		cQryDados += " WHERE SE3.E3_FILIAL = '"+ cFilSE3 + "' "
	Else
		cQryDados += " WHERE SE3.E3_FILIAL BETWEEN '"+MV_PAR14+"' AND '"+MV_PAR15+"' "
	EndIf
	
	cQryDados += " AND SE3.E3_TIPO='NF' AND SE3.E3_PEDIDO <> ' '"

	cQryDados += " AND SE3.E3_VEND BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
	cQryDados += " AND SE3.E3_VENCTO BETWEEN '"+DTOS(mv_par10)+"' AND '"+DTOS(mv_par11)+"' "
	cQryDados += " AND SE3.E3_DATA = '"+Dtos(Ctod(""))+"' "
	cQryDados += " AND SE3.E3_EMISSAO BETWEEN '"+DTOS(mv_par02)+"' AND '"+DTOS(mv_par03)+"' "
	If mv_par01 <> 3//Caso a geracao for diferente da opcao TODOS, filtrar por EMISSAO, BAIXA ou MANUAL.
		If mv_par01 == 1
			cQryDados += " AND SE3.E3_BAIEMI = 'E' "
		Elseif mv_par01 == 2
			cQryDados += " AND (SE3.E3_BAIEMI = 'B' OR (SE3.E3_TIPO = 'NCC' AND SE3.E3_BAIEMI = 'E')) "
		ElseIf mv_par01 == 4
			cQryDados += " AND SE3.E3_BAIEMI = '"+Space(GetSx3Cache("SE3.E3_DATA","X3_TAMANHO"))+"' "
		EndIf
	EndIf
	cQryDados += " AND SE3.D_E_L_E_T_=' ' ORDER BY E3_FILIAL,E3_VEND,E3_VENCTO "
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da r�gua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na tempor�ria
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Carregando registro: ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		(cAliasTmp)->E3_FILIAL	:= QRYDADTMP->E3_FILIAL
		(cAliasTmp)->E3_VEND 	:= QRYDADTMP->E3_VEND
		(cAliasTmp)->A3_NOME	:= QRYDADTMP->A3_NOME
		(cAliasTmp)->E3_PREFIXO	:= QRYDADTMP->E3_PREFIXO
		(cAliasTmp)->E3_NUM 	:= QRYDADTMP->E3_NUM
		(cAliasTmp)->E3_PARCELA := QRYDADTMP->E3_PARCELA
		(cAliasTmp)->E3_SERIE	:= QRYDADTMP->E3_SERIE
		(cAliasTmp)->E3_TIPO 	:= QRYDADTMP->E3_TIPO
		(cAliasTmp)->E3_CODCLI	:= QRYDADTMP->E3_CODCLI
		(cAliasTmp)->E3_LOJA	:= QRYDADTMP->E3_LOJA
		(cAliasTmp)->A1_NREDUZ	:= QRYDADTMP->A1_NREDUZ
		(cAliasTmp)->E3_BAIEMI 	:= QRYDADTMP->E3_BAIEMI
		(cAliasTmp)->E3_VENCTO 	:= QRYDADTMP->E3_VENCTO
		(cAliasTmp)->E3_DATA 	:= QRYDADTMP->E3_DATA
		(cAliasTmp)->E3_PEDIDO	:= QRYDADTMP->E3_PEDIDO
		(cAliasTmp)->E3_BASE	:= QRYDADTMP->E3_BASE
		(cAliasTmp)->E3_PORC	:= QRYDADTMP->E3_PORC
		(cAliasTmp)->E3_COMIS 	:= QRYDADTMP->E3_COMIS
		(cAliasTmp)->E3_MOEDA 	:= QRYDADTMP->E3_MOEDA
		(cAliasTmp)->E3_PROCCOM := QRYDADTMP->E3_PROCCOM
		(cAliasTmp)->E3Recno 	:= QRYDADTMP->R_E_C_N_O_	
		(cAliasTmp)->(MsUnlock())
		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

/*---------------------------------------------------------------------*
 | Func:  fCriaCols                                                    |
 | Desc:  Fun��o para criar colunas do browse    				       |
 *---------------------------------------------------------------------*/
Static Function fCriaCols()
	Local nAtual       := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que ser�o mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - M�scara

	aAdd(aEstrut, { 'E3_FILIAL'	, 'Filial'			, 'C', TamSX3("E3_FILIAL")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_VEND'	, 'Vendedor'		, 'C', TamSX3("E3_VEND")[1]		, 0, ''})
	aAdd(aEstrut, { 'A3_NOME'	, 'Nome Vendedor'	, 'C', TamSX3("A3_NOME")[1]		, 0, ''})
	aAdd(aEstrut, { 'E3_PREFIXO', 'Prefixo'			, 'C', TamSX3("E3_PREFIXO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_NUM'	, 'Titulo'			, 'C', TamSX3("E3_NUM")[1]		, 0, ''})
	aAdd(aEstrut, { 'E3_PARCELA', 'Parcela'			, 'C', TamSX3("E3_PARCELA")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_SERIE'	, 'Serie'			, 'C', TamSX3("E3_SERIE")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_TIPO'	, 'Tipo'			, 'C', TamSX3("E3_TIPO")[1]		, 0, ''})
	aAdd(aEstrut, { 'E3_CODCLI'	, 'Cliente'			, 'C', TamSX3("E3_CODCLI")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_LOJA'	, 'Loja'			, 'C', TamSX3("E3_LOJA")[1]		, 0, ''})
	aAdd(aEstrut, { 'A1_NREDUZ'	, 'Nome Cliente'	, 'C', TamSX3("A1_NREDUZ")[1]	, 0, ''})
	aAdd(aEstrut, { 'E3_BAIEMI'	, 'Comissao', 'C', 6, 0, ''})
	aAdd(aEstrut, { 'E3_VENCTO'	, 'Vencimento'	, 'D', 10, 0, ''})
	aAdd(aEstrut, { 'E3_DATA'	, 'Data Pag.'	, 'D', 10, 0, ''})
	aAdd(aEstrut, { 'E3_PEDIDO'	, 'Pedido'		, 'C', TamSX3("E3_PEDIDO")[1]		, 0, ''})
	aAdd(aEstrut, { 'E3_BASE'	, 'Valor Base'	, 'N', TamSX3("E3_BASE")[1], 2, '@E 99,999,999,999.99'})
	aAdd(aEstrut, { 'E3_PORC'	, '(%) Comiss�o', 'N', TamSX3("E3_PORC")[1], 2, '@E 999.99'})
	aAdd(aEstrut, { 'E3_COMIS'	, 'Valor'		, 'N', TamSX3("E3_COMIS")[1], 2, '@E 99,999,999,999.99'})
	aAdd(aEstrut, { 'E3_MOEDA'	, 'Moeda'		, 'C', 2, 0, ''})

	//Percorrendo todos os campos da estrutura
	For nAtual := 1 To Len(aEstrut)
		//Cria a coluna
		oColumn := FWBrwColumn():New()
		oColumn:SetData(&('{|| ' + cAliasTmp + '->' + aEstrut[nAtual][1] +'}'))
		oColumn:SetTitle(aEstrut[nAtual][2])
		oColumn:SetType(aEstrut[nAtual][3])
		oColumn:SetSize(aEstrut[nAtual][4])
		oColumn:SetDecimal(aEstrut[nAtual][5])
		oColumn:SetPicture(aEstrut[nAtual][6])

		//Adiciona a coluna
		aAdd(aColunas, oColumn)
	Next
Return aColunas

/*---------------------------------------------------------------------*
 | Func:  fVoltar                                                      |
 | Desc:  Fun��o do bot�o voltar    		    				       |
 *---------------------------------------------------------------------*/
User Function fVoltar()
	(eval({||oDlgMark:End(),iif(!lVoltar,lVoltar := .T.,lVoltar := .F.)}))	
Return

/*---------------------------------------------------------------------*
 | Func:  fPagComis                                                    |
 | Desc:  Fun��o do bot�o pagar comissao	    				       |
 *---------------------------------------------------------------------*/
User Function fPagComis()
	Processa({|| fProcessa()}, 'Selecionando t�tulos...')
Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Fun��o que processa titulos marcados    				       |
 *---------------------------------------------------------------------*/
Static Function fProcessa()
	Local aArea     	:= FWGetArea()
	Local cMarca    	:= oMarkBrowse:Mark()
	Local nAtual    	:= 0
	Local nTotal    	:= 0
	Local nTotMarc 		:= 0
	Local nTotProc		:= 0
	Local aRecnos   	:= {}
	Local aRecSE3   	:= {}
	Local aDadosRet 	:= {}
	Local nRegistro 	:= 0
	Local cVendAnt  	:= ""
	Local cVerbaFol 	:= ""
	Local cDocFol   	:= ""
	Local nVlrComis 	:= 0
	Local cSequencia	:= ""
	Local nHdlPrv   	:= 0
	Local cArquivo  	:= ""
	Local nRecSE3   	:= 0
	Local cPadrao   	:= "510"
	Local lPadrao   	:= VerPadrao(cPadrao)
	Local lDigita   	:= If(mv_par09==1,.T.,.F.)
	Local lMSE2530	 	:= (existblock("MSE2530"))
	Local lContrRet  	:= !Empty( SE2->( ColumnPos( "E2_VRETPIS" ) ) ) .And. !Empty( SE2->( ColumnPos( "E2_VRETCOF" ) ) ) .And. ;
						   !Empty( SE2->( ColumnPos( "E2_VRETCSL" ) ) ) .And. !Empty( SE2->( ColumnPos( "E2_PRETPIS" ) ) ) .And. ;
						   !Empty( SE2->( ColumnPos( "E2_PRETCOF" ) ) ) .And. !Empty( SE2->( ColumnPos( "E2_PRETCSL" ) ) )
	Local lRestValImp 	:= .F.
	Local lRetParc    	:= .T.
	Local lBlqFor		:= .F.
	Local dVencto
	Local lFiltro	 	:= .T.
	Local cFilterUser	:= " "
	Local nIrrf	     	:= 0
	Local nIss	     	:= 0
	Local cCodIss		:= ""
	Local nInss	     	:= 0
	Local nRecCtb    	:= 0
	Local aTps       	:= {}
	Local aParc      	:= {}
	Local aCodFol    	:= {}
	Local nX         	:= 0
	Local nCofins    	:= 0
	Local nPIS       	:= 0
	Local nCSLL      	:= 0
	Local nLoop      	:= 0
	Local nRetOriPIS 	:= 0
	Local nRetOriCOF 	:= 0
	Local nRetOriCSLL	:= 0
	Local nVlRetPIS  	:= 0
	Local nVlRetCOF  	:= 0
	Local nVlRetCSLL  	:= 0
	Local nTotARet   	:= 0
	Local nValMinRet 	:= GetNewPar("MV_VL10925", 0 )
	Local nSobra     	:= 0
	Local nIndexSE2  	:= 0
	Local nSavRec    	:= 0
	Local nFatorRed		:= 0
	Local lBaseSE2 		:= SuperGetMv("MV_BS10925",.T.,"1") == "1"  .AND. ;
		(!Empty(SE2->(ColumnPos("E2_BASEPIS"))) .AND.;
		!Empty(SE2->(ColumnPos("E2_BASECOF"))) .AND. ;
		!Empty(SE2->(ColumnPos("E2_BASECSL"))))
	Local cModRetPIS	:= GetNewPar( "MV_RT10925", "1" )
	Local cPrefOri   	:= ""
	Local cNumOri    	:= ""
	Local cParcOri   	:= ""
	Local cTipoOri   	:= ""
	Local cCfOri     	:= ""
	Local cLojaOri   	:= ""
	Local lM530AGL  	:= Existblock("M530AGL")
	Local lM530TIT	  	:= Existblock("M530TIT")
	Local lM530FIM   	:= Existblock("M530FIM")
	Local lM530DIRF  	:= Existblock("M530DIRF")
	Local cCodRet		:= ""
	Local lNaoAglutina 	:= .F.
	Local aVenctos	  	:= {}
	Local aRoteiro       := {}
	Local nPos		  	:= 0
	Local nY		  	:= 0
	Local cLastPer   	:= ""
	Local cProcesso  	:= ""
	Local cRoteiro   	:= ""
	Local lMsg       	:= .T.
	Local cMatFunc   	:= ""
	Local cFilFun	   	:= ""
	Local cLastNroPagto := ""
	Local lPCCBaixa 	:= SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( ColumnPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_VRETCOF" ) ) ) .And. ;
		                   !Empty( SE5->( ColumnPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_PRETPIS" ) ) ) .And. ;
		                   !Empty( SE5->( ColumnPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_PRETCSL" ) ) ) .And. ;
		                   !Empty( SE2->( ColumnPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( ColumnPos( "FQ_SEQDES"  ) ) ) )
	Local cNatCom    	:= PADR(&(GetNewPar("MV_NATCOM","")),TamSx3("E2_NATUREZ")[1])
	Local nLimInss   	:= GetMv("MV_LIMINSS",.F.,0)
	Local lAtuSldNat  	:= FindFunction("AtuSldNat") .AND. AliasInDic("FIV") .AND. AliasInDic("FIW")
	Local lItemClVl   	:= SuperGetMv("MV_ITMCLVL",.F.,"2") $ "13"	//Informe 1 para utiliza��o do Item Contabil e Classe de Valor
	Local nTotDados    	:= 0
	Local nVlrMin	   	:= SuperGetMv("MV_VL13137", .T., 10 ) // Parametro do minimo
	Local nForn 		:= TAMSX3("A2_COD")[1]
	Local nLoja 		:= TAMSX3("A2_LOJA")[1]
	Local nTamNum		:= TamSX3("E2_NUM")[1]
	Local cChaveSA2 	:= GetMv("MV_FORNCOM")
	Local cForn 		:= SubStr(cChaveSA2,1,6)
	Local cLoja 		:= SubStr(cChaveSA2,7,2)
	Local lVenPadr 		:= (Alltrim(cChaveSA2) == "VENDER00" .OR. Len(Alltrim(cChaveSA2)) == 6)
	Local nIndSRK		:= ""
	Local cAuxDocum 	:= ""
	Local cItem			:= ""
	Local cClVl			:= ""
	Local cQuery		:= ""
	Local cAliasAux 	:= ""
	Local cFornec		:= SubStr(GetMV("MV_FORNCOM"),1,6)
	Local cLjFor		:= SubStr(GetMV("MV_FORNCOM"),7,2)
	Local cMV_ESTADO	:= SuperGetMv("MV_ESTADO")
	Local cMacPref		:= GetMv("MV_3DUPREF")
	Local cCatFunc		:= ""
	Local lCpoFilFun	:= SA3->(ColumnPos("A3_FILFUN")) > 0
	Local cMVBX10925	:= SuperGetMv("MV_BX10925")
	Local cAliasSE3 	:= GetNextAlias()
	Local cFilSA3		:= xFilial("SA3")
	Local cFilSA2		:= xFilial("SA2")
	Local cFilSED 		:= xFilial("SED")
	Local cFilSE2 		:= xFilial("SE2")
	Local cFilSFQ 		:= xFilial("SFQ")
	Local cFilSRA 		:= xFilial("SRA")
	Local cFilSRK 		:= xFilial("SRK")
	Local lCpoIrProg	:= SA2->(ColumnPos("A2_IRPROG")) > 0
	Local lCpoDirf		:= SE2->(ColumnPos("E2_DIRF")) > 0
	Local lCpoFilOri	:= SE2->(ColumnPos("E2_FILORIG")) > 0
	Local nTotReg		:= 0
	Local lIRFBaixa 	:= .F.
	Local cFilIni       := xFilial("SA3")
	Local cFilTit       := ""
	Local lTrocaFil     := .F.
	Private cPrefixo    := ""
	Private cNumero     := ""
	Private cParcela    := GetMv("MV_1DUP")
	Private cNatureza   := ""
	Private cTipo       := ""
	Private cLote  	    := ""

	LoteCont( "FIN" )

	//��������������������������������������������������������������Ŀ
	//� Ponto de entrada para Filtrar os vendedores conforme parame- �
	//� tros dos clientes (Empresa)                                  �
	//����������������������������������������������������������������
	IF EXISTBLOCK("M530FIL")
		cFilterUser	:=	EXECBLOCK("M530FIL",.f.,.f.)
	ENDIF

	//*********************************
	// Inicio da integra��o com o PCO *
	//*********************************
	PcoIniLan("000104")
	//Define o tamanho da r�gua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	//Percorrendo os registros
	(cAliasTmp)->(DbGoTop())
	While ! (cAliasTmp)->(EoF())

		cVendAnt := (cAliasTmp)->E3_VEND

		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		//��������������������������������������������������������������Ŀ
		//� Considera filtro do usuario                                  �
		//����������������������������������������������������������������
		If !Empty(cFilterUser)
			DbSelectArea("SE3")
			SE3->(dbGoto((cAliasTmp)->E3Recno))
			If !(&cFilterUser)
				lFiltro := .F.
			Endif
		Endif

		//��������������������������������������������������������������Ŀ
		//� Filtrar as condicoes selecionadas e marcadas                 �
		//����������������������������������������������������������������
		IF lFiltro .AND. oMarkBrowse:IsMark(cMarca)
			aadd(aRecSE3,{(cAliasTmp)->E3Recno,(cAliasTmp)->E3_COMIS,IIF(lCpoMoeda,(cAliasTmp)->E3_MOEDA,"01"),(cAliasTmp)->E3_VENCTO,(cAliasTmp)->E3_FILIAL})
			nTotMarc++
		EndIf

		(cAliasTmp)->(dbSkip())

		If lM530AGL
			lNaoAglutina := ExecBlock("M530AGL",.f.,.f.)
		EndIf

		If !Empty(aRecSE3) .And. (!Empty(cVendAnt) .And. (lNaoAglutina .Or. cVendAnt != (cAliasTmp)->E3_VEND ))

			Begin Transaction

				//��������������������������������������������������������������Ŀ
				//� Atualiza a data de pagamento da comissao                     �
				//����������������������������������������������������������������
				nRecSE3 := (cAliasTmp)->E3Recno

				For nX := 1 To Len(aRecSE3)
					
					//Verifica Filial
					cFilTit	:= aRecSE3[nX][5]
					If cFilTit <> cFilAnt
						cFilIni	:= cFilAnt
						fTrocaFil(cFilIni,cFilTit,.T.)
						lTrocaFil	:= .T.
					EndIf

					cFilSA3		:= xFilial("SA3")
					cFilSA2		:= xFilial("SA2")
					cFilSED 	:= xFilial("SED")
					cFilSE2 	:= xFilial("SE2")
					cFilSFQ 	:= xFilial("SFQ")
					cFilSRA 	:= xFilial("SRA")
					cFilSRK 	:= xFilial("SRK")

					SE3->(MsGoTo(aRecSE3[nX][1]))
					dVencto := If( mv_par12 == 1,aRecSE3[nX][4],mv_par06)//Valida qual data deve considerar(1=Vencimento/2=Pagamento)

					If SE3->(Recno()) == aRecSE3[nX][1]
						RecLock("SE3",.F.)
						SE3->E3_DATA := dVencto
						SE3->(MsUnlock())
					EndIf

					nVlrComis += aRecSE3[nX][2]//Soma as comissoes por vendedor

					//Controle de Saldo de Naturezas
					If lAtuSldNat .and. cNatCom != NIL .And. !IntCPSE2(cVendAnt)
						//Atualizo o valor atual para o saldo da natureza
						AtuSldNat(cNatCom,;
							dVencto,;
							IIf(lCpoMoeda,aRecSE3[nX][3],"01"),;
							"3",;
							"P",;
							aRecSE3[nX][2],;
							aRecSE3[nX][2],;
							"+",;
							,;
							FunName(),;
							"SE3",;
							aRecSE3[nX][1])
					Endif

					//***********************
					// integra��o com o PCO *
					//***********************
					PcoDetLan("000104","01","MATA530")

					nPos := Ascan(aVenctos, {|x| x[1] == dVencto})
					If nPos == 0
						aAdd(aVenctos,{dVencto, aRecSE3[nX][2]})
					Else
						aVenctos[nPos][2] += aRecSE3[nX][2]
					EndIf
					nTotProc++
				Next nX

				If nVlrComis > 0 .And. MV_PAR07 == 1
					dbSelectArea("SA3")
					dbSetOrder(1)
					MsSeek(cFilSA3+cVendAnt,.F.)

					Do Case
						//��������������������������������������������������������������Ŀ
						//� Pagamento de Comissao para Representantes PJ                 �
						//����������������������������������������������������������������
					Case SA3->A3_GERASE2 == "S"
						//��������������������������������������������������������������Ŀ
						//� Identifica o fornecedor                                      �
						//����������������������������������������������������������������
						dbSelectArea("SA2")
						dbSetOrder(1)

						If (!MsSeek(cFilSA2+SA3->A3_FORNECE+SA3->A3_LOJA,.F.) )
							dbSelectArea("SA2")
							dbSetOrder(1)

							//Vld p/ � ocorrer error de chave duplicada, caso seja alter o grupo de campos Cod.forn ou Loja
							If (nForn > 6 .OR. nLoja > 2)
								If lVenPadr
									cChaveSA2 := Padr(cForn, nForn)+Padr(cLoja, nLoja)
								Else//Alterado tamanho da string do par�metro MV_FORNCOM
									cForn := SubStr(cChaveSA2, 1, nForn)
									cLoja := SubStr(cChaveSA2, (nForn+1), nLoja)
									cChaveSA2 := cForn + cLoja
								EndIf
							EndIf

							If (!MsSeek(cFilSA2+cChaveSA2,.F.) )
								dbSelectArea("SA2")
								RecLock("SA2",.T.)
								SA2->A2_FILIAL := cFilSA2
								SA2->A2_COD    := cFornec
								SA2->A2_LOJA   := cLjFor
								SA2->A2_NOME   := "VENDER"
								SA2->A2_NREDUZ := "VENDER"
								SA2->A2_BAIRRO := "."
								SA2->A2_MUN    := "."
								SA2->A2_EST    := cMV_ESTADO
								SA2->A2_END    := "."
								MsUnlock()
							EndIf
							MsSeek(cFilSA2+cChaveSA2,.F.)
						EndIf
						lIRProg := IIf(lCpoIrProg, IIf(!Empty(SA2->A2_IRPROG), SA2->A2_IRPROG, "2"), "2")
						//��������������������������������������������������������������Ŀ
						//� Identifica a natureza do fornecedor                          �
						//����������������������������������������������������������������
						dbSelectArea("SED")
						dbSetOrder(1)
						MsSeek(cFilSED+SA2->A2_NATUREZ,.F.)
						If ( Found() )
							cNatureza := SA2->A2_NATUREZ
						Else
							cNatureza := ""
						EndIf

						//�����������������������������������������������������������������Ŀ
						// Verifica se o Fornecedor relacionado ao vendedor est� bloqueado  �
						// (SA2->A2_MSBLQL == "1") nao � gerado o t�tulo                   �
						//�������������������������������������������������������������������
						lBlqFor := .F.
						If (SA2->(Found()) .And. SA2->A2_MSBLQL == '1' )
							lBlqFor := .T.
						EndIf

						If SA3->(Found()) .And. SA2->(Found() .And. !lBlqFor) .and. SA3->A3_GERASE2 == "S"
							For nY := 1 To Len(aVenctos)
								cSequencia := "01"
								cNumero    := Padr( SubStr( Dtos(MV_PAR06), 3, 4 ) + cSequencia, nTamNum )
								cTipo      := If (Abs(aVenctos[nY][2]) > 0 , "DP " , left(MV_CPNEG,3) )
								cUltParc   := TamParcela("E2_PARCELA","Z","ZZ","ZZZ")

								//��������������������������������������������������������������Ŀ
								//� PE para manipulacao dos dados do titulo a ser gerado         �
								//����������������������������������������������������������������
								If lM530TIT
									ExecBlock("M530TIT",.f.,.f.)
								EndIf
								cPrefixo := &(cMacPref)
								dbSelectArea("SE2")
								dbSetOrder(1)
								MsSeek(cFilSE2 + cPrefixo + cNumero + cParcela,.F.)
								While ( SE2->(Found()) )
									If ( cParcela == cUltParc )
										cNumero  := Soma1(cNumero,Len(SE2->E2_NUM))
									Else
										cParcela	:= Soma1(cParcela,Len(SE2->E2_PARCELA))
									EndIf
									MsSeek(cFilSE2 + cPrefixo + cNumero + cParcela,.F.)
								EndDo
								//��������������������������������������������������������������Ŀ
								//� Aqui s�o calculados os impostos sobre a comiss�o do Vendedor.�
								//� Para tal, � necess�rio que, no fornecedor utilizado para o   �
								//� titulo de comiss�o esteja cadastrada natureza que calcule    �
								//� impostos.                                                    �
								//����������������������������������������������������������������
								nIrrf	:= 0
								nIss	:= 0
								cCodIss	:= ""
								nInss 	:= 0
								nCofins := 0
								nPIS    := 0
								nCSLL   := 0
								//Funcao para calculo de impostos
								If !Empty(cNatureza) .and. cTipo == "DP "
									MT530NAT(Abs(aVenctos[nY][2]),@nIrrf,@nIss,@cCodIss,@nInss,@nCofins,@nPIS,@nCSLL)
								Endif
								RecLock("SE2",.T.)
								SE2->E2_FILIAL    	:= cFilSE2
								SE2->E2_PREFIXO   	:= cPrefixo
								SE2->E2_NUM       	:= cNumero
								SE2->E2_PARCELA   	:= cParcela
								SE2->E2_TIPO      	:= cTipo
								SE2->E2_FORNECE   	:= SA2->A2_COD
								SE2->E2_LOJA      	:= SA2->A2_LOJA
								SE2->E2_NOMFOR    	:= SA2->A2_NREDUZ
								SE2->E2_VALOR     	:= Abs(aVenctos[nY][2])
								SE2->E2_EMIS1     	:= dDataBase
								SE2->E2_EMISSAO   	:= dDataBase
								SE2->E2_VENCTO    	:= aVenctos[nY][1]
								SE2->E2_VENCREA   	:= DataValida(SE2->E2_VENCTO,.T.)
								SE2->E2_VENCORI   	:= SE2->E2_VENCTO
								SE2->E2_SALDO     	:= Abs(aVenctos[nY][2])
								SE2->E2_NATUREZ   	:= cNatureza
								SE2->E2_VLCRUZ    	:= Abs(aVenctos[nY][2])
								SE2->E2_IRRF      	:= nIrrf
								If cPaisLoc == "BRA"
									If SED->ED_BASEIRF > 0
										SE2->E2_BASEIRF	:= Abs(aVenctos[nY][2]) * (SED->ED_BASEIRF/100)
									Else
										SE2->E2_BASEIRF	:= Abs(aVenctos[nY][2])
									EndIf
								EndIf
								If lCpoDirf
									SE2->E2_DIRF	:= "2"
								Endif
								If nIrrf > 0 .And. !Empty(GetNewPar("MV_CRF_SE3",""))
									SE2->E2_CODRET    := GetNewPar("MV_CRF_SE3","")
								EndIf
								SE2->E2_ISS       	:= nIss
								SE2->E2_CODISS		:= cCodIss
								//Verifico se utiliza o par�metro MV_LIMINSS e utilizo o seu valor se
								//o fornecedor for PF e o valor do INSS for superior ao valor do
								//par�metro
								If SA2->A2_TIPO == "F"
									If nLimInss > 0 .And. nInss > nLimInss
										nInss := nLimInss
									EndIf
								EndIf
								SE2->E2_INSS		:= nInss
								SE2->E2_COFINS    	:= nCofins
								SE2->E2_PIS       	:= nPIS
								SE2->E2_CSLL      	:= nCSLL
								SE2->E2_ORIGEM    	:= "FINA050"
								SE2->E2_MOEDA     	:= 1
								SE2->E2_RATEIO    	:= "N"
								SE2->E2_FLUXO     	:= "S"
								SE2->E2_MULTNAT		:= "2"
								SE2->E2_DESDOBR		:= "N"
								If cPaisLoc == "BRA"
									SE2->E2_FRETISS		:= SA2->A2_FRETISS
									SE2->E2_MODSPB		:= "1"
								Endif
								If lCpoFilOri
									SE2->E2_FILORIG  := If(Empty(SE2->E2_FILORIG),cFilAnt,SE2->E2_FILORIG)
								EndIf

								dbSelectArea("SE3")
								If lCpoProcCo
									For nX := 1 To Len(aRecSE3)
										SE3->(MsGoto(aRecSE3[nX][1]))
										RecLock("SE3",.F.)
										SE3->E3_PROCCOM := cFilSE3 + cPrefixo + cNumero + cParcela
									Next
								Endif
								dbSelectArea("SE2")

								nRegistro := Recno()

								cCodRet	:=	" "
								If lM530DIRF  .And. lCpoDirf
									cCodRet	:= ExecBlock("M530DIRF")
									If !Empty(cCodRet)
										If nIrrf == 0 .And. nCofins =0 .And. nPis = 0 .And. nCsll = 0 //Qdo nao retenho impostos.
											SE2->E2_DIRF      := "1"
										Endif
										SE2->E2_CODRET	:=	cCodRet
									Endif
								Endif

								If lContrRet .AND. lBaseSE2
									//�������������������������������������������������������������������Ŀ
									//� Grava a base do PIS                                               �
									//���������������������������������������������������������������������
									SE2->E2_BASEPIS := Abs(aVenctos[nY][2])
									//�������������������������������������������������������������������Ŀ
									//� Grava a base do COFINS                                            �
									//���������������������������������������������������������������������
									SE2->E2_BASECOF := Abs(aVenctos[nY][2])
									//�������������������������������������������������������������������Ŀ
									//� Grava a base do CSLL                                              �
									//���������������������������������������������������������������������
									SE2->E2_BASECSL := Abs(aVenctos[nY][2])
								Endif

								If lContrRet
									//������������������������������������������������������������������Ŀ
									//� Grava a Marca de "pendente recolhimento" dos demais registros    �
									//��������������������������������������������������������������������
									If ( !Empty( SE2->E2_PIS ) .Or. !Empty( SE2->E2_COFINS ) .Or. !Empty( SE2->E2_CSLL ) )
										SE2->E2_PRETPIS := "1"
										SE2->E2_PRETCOF := "1"
										SE2->E2_PRETCSL := "1"
									EndIf
									Do Case
									Case cModRetPIS == "1"
										aDadosRet := CalcRetPag( SE2->E2_VENCREA, nIndexSE2, SE2->E2_FORNECE, SE2->E2_LOJA )
										nTotDados := aDadosRet[2]+aDadosRet[3]+aDadosRet[4]
										If Iif( SE2->E2_EMISSAO > dLastPcc , nTotDados > nVlrMin ,;
												aDadosRet[1] > nValMinRet)
											// Nao abater PIS/COFINS/CSLL se MV_BV10925 for na baixa
											If !lPCCBaixa
												lRetParc := .T.
											Else
												lRetParc := .F.
											EndIf
											nVlRetPIS  := aDadosRet[ 2 ]
											nVlRetCOF  := aDadosRet[ 3 ]
											nVlRetCSLL := aDadosRet[ 4 ]
											nTotARet := nVlRetPIS + nVlRetCOF + nVlRetCSLL
											nSobra := SE2->E2_VALOR - nTotARet
											If nSobra < 0
												nSavRec := SE2->( Recno() )
												nFatorRed := 1 - ( Abs( nSobra ) / nTotARet )
												nVlRetPIS  := NoRound( nVlRetPIS * nFatorRed, 2 )
												nVlRetCOF  := NoRound( nVlRetCOF * nFatorRed, 2 )
												nVlRetCSLL := SE2->E2_VALOR - ( nVlRetPIS + nVlRetCOF )
												//���������������������������������������������������Ŀ
												//� Grava o valor de NDF caso a retencao seja maior   �
												//� que o valor do titulo                             �
												//�����������������������������������������������������
												If FindFunction("ADUPCREDRT")
													ADupCredRt(Abs(nSobra),"501",SE2->E2_MOEDA)
												Endif
												//���������������������������������������������������Ŀ
												//� Restaura o registro do titulo original            �
												//�����������������������������������������������������
												SE2->( MsGoto( nSavRec ) )
												Reclock( "SE2", .F. )
											EndIf
											lRestValImp := .T.
											//�������������������������������������������������������Ŀ
											//� Guarda os valores originais                           �
											//���������������������������������������������������������
											nRetOriPIS  := SE2->E2_PIS
											nRetOriCOF  := SE2->E2_COFINS
											nRetOriCSLL := SE2->E2_CSLL
											//�������������������������������������������������������Ŀ
											//� Grava os novos valores de retencao para este registro �
											//���������������������������������������������������������
											SE2->E2_PIS    := nVlRetPIS
											SE2->E2_COFINS := nVlRetCOF
											SE2->E2_CSLL   := nVlRetCSLL
											nSavRec := SE2->( Recno() )
											//������������������������������������������������������������������Ŀ
											//� Exclui a Marca de "pendente recolhimento" dos demais registros   �
											//��������������������������������������������������������������������
											aRecnos := aClone( aDadosRet[ 5 ] )
											cPrefOri  := SE2->E2_PREFIXO
											cNumOri   := SE2->E2_NUM
											cParcOri  := SE2->E2_PARCELA
											cTipoOri  := SE2->E2_TIPO
											cCfOri    := SE2->E2_FORNECE
											cLojaOri  := SE2->E2_LOJA
											For nLoop := 1 to Len( aRecnos )
												SE2->( dbGoto( aRecnos[ nLoop ] ) )
												RecLock( "SE2", .F. )

												If cMVBX10925 == "1"
													SE2->E2_PRETPIS := "1"
													SE2->E2_PRETCOF := "1"
													SE2->E2_PRETCSL := "1"
												Else
													SE2->E2_PRETPIS := "2"
													SE2->E2_PRETCOF := "2"
													SE2->E2_PRETCSL := "2"
												Endif

												SE2->( MsUnlock() )

												If AliasIndic("SFQ")
													If nSavRec <> aRecnos[ nLoop ]
														dbSelectArea("SFQ")
														RecLock("SFQ",.T.)
														SFQ->FQ_FILIAL  := cFilSFQ
														SFQ->FQ_ENTORI  := "SE2"
														SFQ->FQ_PREFORI := cPrefOri
														SFQ->FQ_NUMORI  := cNumOri
														SFQ->FQ_PARCORI := cParcOri
														SFQ->FQ_TIPOORI := cTipoOri
														SFQ->FQ_CFORI   := cCfOri
														SFQ->FQ_LOJAORI := cLojaOri
														SFQ->FQ_ENTDES  := "SE2"
														SFQ->FQ_PREFDES := SE2->E2_PREFIXO
														SFQ->FQ_NUMDES  := SE2->E2_NUM
														SFQ->FQ_PARCDES := SE2->E2_PARCELA
														SFQ->FQ_TIPODES := SE2->E2_TIPO
														SFQ->FQ_CFDES   := SE2->E2_FORNECE
														SFQ->FQ_LOJADES := SE2->E2_LOJA
														MsUnlock()
													Endif
												Endif
											Next nLoop
											//���������������������������������������������������Ŀ
											//� Retorna do ponteiro do SE1 para a parcela         �
											//�����������������������������������������������������
											SE2->( MsGoto( nSavRec ) )
											Reclock( "SE2", .F. )
										Else
											lRetParc := .F.

											//Caso n�o atinja o minimo de retencao zera os impostos
											SE2->E2_PIS    := 0
											SE2->E2_COFINS := 0
											SE2->E2_CSLL   := 0
										EndIf
									Case cModRetPIS == "2"
										//�������������������������������������������������������������������Ŀ
										//� Efetua a retencao                                                 �
										//���������������������������������������������������������������������
										If !lPCCBaixa
											lRetParc := .T.
										Else
											lRetParc := .F.
										EndIf
									Case cModRetPIS == "3"
										//���������������������������������������������������Ŀ
										//� Nao efetua a retencao                             �
										//�����������������������������������������������������
										lRetParc := .F.
									EndCase
								Else
									lRetParc := .T.
								EndIf
								//���������������������������������������������������Ŀ
								//� Abate as retencoes do valor pago                  �
								//�����������������������������������������������������
								If lRetParc
									SE2->E2_VALOR -= ( SE2->E2_PIS + SE2->E2_COFINS + SE2->E2_CSLL )
									SE2->E2_SALDO -= ( SE2->E2_PIS + SE2->E2_COFINS + SE2->E2_CSLL )
								EndIf
								//���������������������������������������������������Ŀ
								//� Abate os valores de IR, INSS e ISS                �
								//�����������������������������������������������������

								If cPaisLoc == "BRA"
									lIRFBaixa 	:= SA2->A2_CALCIRF == "2"
								Endif

								If !lIRFBaixa
									SE2->E2_VALOR -= SE2->E2_IRRF
									SE2->E2_SALDO -= SE2->E2_IRRF
								EndIf

								SE2->E2_VALOR -= (SE2->E2_ISS + SE2->E2_INSS )
								SE2->E2_SALDO -= (SE2->E2_ISS + SE2->E2_INSS )
								//���������������������������������������������������Ŀ
								//� Executa ponto de entrada                          �
								//�����������������������������������������������������
								If lMSE2530
									ExecBlock("MSE2530",.F.,.F.)
								Endif
								dbSelectArea("SE2")
								dbSetOrder(1)  // Acerto a ordem do SE2 para a grava��o dos impostos
								a050DupPag("FINA050",NIL,NIL,NIL,lRetParc)
								If lRestValImp
									//�������������������������������������������������������Ŀ
									//� Restaura os valores originais de PIS / COFINS / CSLL  �
									//���������������������������������������������������������
									SE2->E2_PIS    := nRetOriPIS
									SE2->E2_COFINS := nRetOriCOF
									SE2->E2_CSLL   := nRetOriCSLL
								EndIf

								dbSelectArea("SE2")
								dbSetOrder(6)
								dbGoto(nRegistro)
								If ( mv_par08 == 1 .And. lPadrao ) // Contabiliza On-Line
									nHdlPrv:=HeadProva(cLote,"MATA530",cUserName,@cArquivo)
									nTotal+=DetProva(nHdlPrv,cPadrao,"FINA050",cLote)
									RodaProva(nHdlPrv,nTotal)
									//�����������������������������������������������������Ŀ
									//� Envia para Lan�amento Cont�bil						�
									//�������������������������������������������������������

									If ( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
										aDiario := {}
										aDiario := {{"SE2",SE2->(recno()),cCodDiario,"E2_NODIA","E2_DIACTB"}}
									Else
										aDiario := {}
									EndIf

									If !( FindFunction( "UsaSeqCor" ) .And. UsaSeqCor() )
										cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.)
									Else
										cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,.F.,,,,,,aDiario)
									EndIf
									dbSelectArea("SE2")
									//��������������������������������������������Ŀ
									//� Atualiza flag de Lan�amento Cont�bil	   �
									//����������������������������������������������
									Reclock("SE2")
									Replace E2_LA With "S"
									MsUnlock()
								Endif
								//������������������������������������������������������������������������Ŀ
								//� Atualiza flag de Lan�amento Cont�bil dos titulos de impostos, para nao �
								//� duplicar o lancamento na contabilizacao off-line, pois os valores      �
								//� destes impostos estao disponiveis no mesmo registro do titulo principal�
								//��������������������������������������������������������������������������
								dbSelectArea("SE2")
								dbSetOrder(1)
								nRecCtb := Recno()
								aTps := {"TX ","INS","ISS"}
								aParc := {SE2->E2_PARCIR,SE2->E2_PARCINS,SE2->E2_PARCISS}
								For nX := 1 to Len(aTps)
									If MsSeek(cFilSE2+SE2->E2_PREFIXO+SE2->E2_NUM+aParc[nX]+aTps[nX])
										Reclock("SE2")
										Replace E2_LA With "S"
										MsUnlock()
									Endif
									dbGoto(nRecCtb)
								Next

								//Controle de Saldo de Naturezas
								If lAtuSldNat .And. !IntCPSE2(cVendAnt)
									//Atualizo o valor atual para o saldo da natureza (titulo principal)
									AtuSldNat(SE2->E2_NATUREZ, SE2->E2_VENCREA, SE2->E2_MOEDA, "2", "P", SE2->E2_VALOR, SE2->E2_VLCRUZ,"+",,FunName(),"SE2",SE2->(Recno()))
								Endif

							Next nY
						ElseIf lBlqFor
							//Caso o fornecedor estiver bloqueado n�o atualiza o pagamento da comiss�o
							For nX := 1 To Len(aRecSE3)
								SE3->(MsGoto(aRecSE3[nX][1]))
								RecLock("SE3",.F.)
								SE3->E3_DATA := cToD("")
							Next
							SE3->(MsGoto(nRecSE3))
						EndIf
						//��������������������������������������������������������������Ŀ
						//� Pagamento de Comissao para Representantes PF                 �
						//����������������������������������������������������������������
					Case SA3->A3_GERASE2 == "F"
						//��������������������������������������������������������������Ŀ
						//� Identifica o funcionario                                     �
						//����������������������������������������������������������������
						If lCpoFilFun
							cFilFun := IIf(!Empty(SA3->A3_FILFUN),SA3->A3_FILFUN,cFilSRA)
							cFilSRK := IIf(!Empty(SA3->A3_FILFUN),SA3->A3_FILFUN,cFilSRK)
						Else
							cFilFun := cFilSRA
						EndIf

						dbSelectArea("SRA")
						dbSetOrder(1)
						If MsSeek(cFilFun+SA3->A3_NUMRA) .And. IIf(Empty(aCodFol),FP_CODFOL(@aCodFol,SRA->RA_FILIAL),.T.)
							cProcesso := SRA->RA_PROCES
							cMatFunc  := SRA->RA_MAT
							cFilFun   := SRA->RA_FILIAL

							cCatFunc := SRA->RA_CATFUNC
							aRoteiro  := If( cCatFunc $ "A*P", fGetRotTipo("9") , fGetRotTipo("1"))
							cRoteiro  := IIf(Len(aRoteiro)>0,aRoteiro[1], If( cCatFunc $ "A*P", "AUT" , "FOL")  )

							fGetLastPer(@cLastPer,@cLastNroPagto,@cProcesso,cRoteiro,.F.,lMsg)
							//��������������������������������������������������������������Ŀ
							//� Obtem o c�digo da verba                                      �
							//����������������������������������������������������������������
							cVerbaFol := aCodFol[165,001] //Verba de Comissao
							If !Empty(cVerbaFol)
								nIndSRK := RetOrder("SRK","RK_FILIAL+RK_MAT+RK_PD+RK_CC+RK_ITEM+RK_CLVL")
								For nY := 1 To Len(aVenctos)
									//��������������������������������������������������������������Ŀ
									//� Obtem o proximo numero de documento                          �
									//����������������������������������������������������������������
									cAuxDocum := ""
									If !lItemClVl
										cItem := Space(Len(SRA->RA_ITEM))
										cClVl := Space(Len(SRA->RA_CLVL))
									Else
										cItem := SRA->RA_ITEM
										cClVl := SRA->RA_CLVL
									EndIf

									cAliasAux := GetNextAlias()

									cQuery := "SELECT MAX(SRK.RK_DOCUMEN) ULTNUM"
									cQuery += "  FROM " + RetSqlName("SRK") + " SRK"
									cQuery += " WHERE SRK.RK_FILIAL = '" + cFilSRK + "' AND"
									cQuery += "  SRK.RK_MAT = '" + SA3->A3_NUMRA + "' AND"
									cQuery += "  SRK.RK_PD  = '" + cVerbaFol  + "' AND"
									cQuery += "  SRK.RK_CC  = '" + SRA->RA_CC + "' AND"
									If nIndSRK <> 1
										cQuery += "  SRK.RK_ITEM  = '" + cItem + "' AND"
										cQuery += "  SRK.RK_CLVL  = '" + cClVl + "' AND"
									EndIf
									cQuery += "  SRK.D_E_L_E_T_ = ' '"
									cQuery := ChangeQuery(cQuery)

									If Select(cAliasAux) > 0
										dbSelectArea(cAliasAux)
										(cAliasAux)->(dbCloseArea())
									EndIf

									dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasAux,.T.,.T.)

									If Select(cAliasAux) > 0
										If !Empty((cAliasAux)->ULTNUM)
											cDocFol := Soma1((cAliasAux)->ULTNUM)
										Else
											cDocFol := StrZero(1,Len((cAliasAux)->ULTNUM))
										EndIf
										dbSelectArea(cAliasAux)
										(cAliasAux)->(dbCloseArea())
									EndIf

									RecLock("SRK",.T.)
									SRK->RK_FILIAL  := cFilSRK
									SRK->RK_MAT     := SA3->A3_NUMRA
									SRK->RK_PD      := cVerbaFol
									SRK->RK_VALORTO := aVenctos[nY][2]
									SRK->RK_PARCELA := 1
									SRK->RK_VALORPA := aVenctos[nY][2]
									SRK->RK_DTMOVI  := dDataBase
									SRK->RK_DTVENC  := aVenctos[nY][1]
									SRK->RK_DOCUMEN := cDocFol
									SRK->RK_CC      := SRA->RA_CC
									SRK->RK_ITEM 	:= cItem
									SRK->RK_CLVL  	:= cClVl
									SRK->RK_PERINI  := cLastPer
									SRK->RK_NUMPAGO := cLastNroPagto
									SRK->RK_PROCES  := cProcesso
									SRK->RK_STATUS  := "2"
									SRK->RK_NUMID   := "SRK"+cFilFun+cMatFunc+cVerbaFol+cDocFol
									MsUnLock()
								Next nY
							EndIf
						EndIf
					EndCase

				Elseif nVlrComis <= 0

					//*****************************************************************
					// Caso a soma das comiss�es seja valor negativo, limpa o E3_DATA,*
					// pois n�o foi gerada comiss�o no contas a pagar para o vendedor.*
					//*****************************************************************
					nRecSe3 := SE3->(RECNO())
					For nX := 1 To Len(aRecSE3)
						SE3->(MsGoto(aRecSE3[nX][1]))
						RecLock("SE3",.F.)
						SE3->E3_DATA := cToD("")
						MsUnLock()
					Next nX
					SE3->(MsGoto(nRecSe3))

				EndIf

			End Transaction
			nVlrComis := 0
			aRecSE3	  := {}
			aVenctos  := {}
			
			//Retorna Filial
			If lTrocaFil
				fTrocaFil(cFilIni,"",.F.)
				lTrocaFil	:= .F.
			EndIf
		EndIf
		dbSelectArea("SE3")
		lFiltro := .T.


	EndDo

	//********************************
	// Final da integra��o com o PCO *
	//********************************
	PcoFinLan("000104")

	If lM530FIM
		ExecBlock("M530FIM",.F.,.F.)
	Endif

	dbSelectArea("SE3")
	dbSetOrder(1)

	//Mostra a mensagem de t�rmino e caso queria fechar a dialog, basta usar o m�todo End()
	FWAlertInfo('Dos [' + cValToChar(nTotMarc) + '] t�tulos marcados, foram processados [' + cValToChar(nTotProc) + '] titulos', 'Aten��o !!!')
	oDlgMark:End()

	FWRestArea(aArea)

Return

Static Function ca530Ok()

	Local lRet := .T.

	If mv_par06 < dDataBase
		Help(" ",1,"NOVENCREA")
		lRet := .F.
	Endif

	If lRet .And. Existblock("M530OK")
		lRet := ExecBlock("M530OK",.F.,.F.)
	Endif

	If lRet
		// lRet := (MsgYesNo(OemToAnsi("Confirma a Atual. Pag. de Comissao?"),OemToAnsi("Atencao")))  //"Confirma a Atual. Pag. de Comiss�o?"###"Aten��o"
	Endif

Return lRet

/*/
	�����������������������������������������������������������������������������
	�������������������������������������������������������������������������Ŀ��
	���Fun��o	 �MT530NAT	� Autor � Mauricio Pequim Jr	� Data � 28/11/00 ���
	�������������������������������������������������������������������������Ĵ��
	���Descri��o � Calcula os impostos se a natureza assim o mandar			  ���
	�������������������������������������������������������������������������Ĵ��
	���Sintaxe	 � MT530Nat()																  ���
	�������������������������������������������������������������������������Ĵ��
	��� Uso		 � MATA530																	  ���
	��������������������������������������������������������������������������ٱ�
	�����������������������������������������������������������������������������
	�����������������������������������������������������������������������������
/*/
Static Function MT530Nat(nVlrComis,nIrrf,nIss,cCodIss,nInss,nCofins,nPIS,nCSLL)

	Local nValMinIs  := GetMV("MV_VRETISS")
	Local lConValMin := Iif(cPaisLoc == "BRA", (SA2->A2_FRETISS == "1"), .F.)
	Local lRndVlIss  := SuperGetMv("MV_RNDISS",.F.,.F.)
	Local nPercIss   := 0


//-- IRF Emiss�o
	Local lIRFEmiss := SA2->A2_CALCIRF == "1"

//������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do IRRF            �
//��������������������������������������������������������
	If SED->ED_CALCIRF == "S" .and. !(SE2->E2_TIPO $ MV_CPNEG) .And. SA2->A2_CALCIRF $ "1|2"
		//������������������������������������������������������Ŀ
		//� Verifica se Pessoa Fisica ou Juridica, para fins de  �
		//� calculo do irrf                                    	�
		//��������������������������������������������������������
		IF lIRFEmiss .And. (SA2->A2_TIPO == "F" .OR. (SA2->A2_TIPO == "J" .AND. lIRProg == "1"))
			nIrrf := FCalcIr(nVlrComis,"F",.T.,.F.,.T.,.T.)
		Else
			nIrrf := FCalcIr(nVlrComis,"J",.T.,.T.,.T.,.T.)
		EndIF
	EndIf
	If (nIrrf <= GetMv("MV_VLRETIR") ) // Se Vlr. for Baixo nao considera
		nIrrf := 0
	EndIf

//�������������������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do ISS (FORNECEDOR N�O RECOLHE) �
//���������������������������������������������������������������������
	If SED->ED_CALCISS == "S" .and. SA2->A2_RECISS != "S"
		nPercIss := GetMV("MV_ALIQISS")
		// Obtem a aliquota de ISS da tabela FIM - Multiplos Vinculos de ISS
		If SA3->( ColumnPos( "A3_CODISS" ) ) > 0 .AND. AliasInDic( "FIM" )
			If !Empty( SA3->A3_CODISS )
				DbSelectArea( "FIM" )
				FIM->( DbSetOrder( 1 ) )
				If FIM->( DbSeek( xFilial( "FIM" ) + SA3->A3_CODISS ) )
					nPercIss := FIM->FIM_ALQISS
					cCodIss  := FIM->FIM_CODISS
				EndIf
			EndIf
		EndIf
		If SA2->A2_RECISS == "N"
			If lRndVlIss
				nIss := Round(((nVlrComis * nPercIss)/100),2)
			Else
				nIss := NoRound(((nVlrComis * nPercIss)/100),2)
			EndIf
		EndIf
		If lConValMin .and. (nIss < nValMinIs)
			nIss := 0
		Endif
	Endif

//�������������������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do INSS (RECOLHE INSS P/ FORNEC)�
//���������������������������������������������������������������������
	If SED->ED_CALCINS == "S" .and. SA2->A2_RECINSS == "S"
		nInss := Round((nVlrComis * (SED->ED_PERCINS/100)),2)
		If ( nInss < GetMv("MV_VLRETIN") ) // Tratamento de Dispensa de Ret. de Inss.
			nInss := 0
		EndIf
	EndIf

//���������������������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do COFINS (FORNECEDOR N�O RECOLHE)�
//�����������������������������������������������������������������������
	If SED->ED_CALCCOF == "S" .and. SA2->A2_RECCOFI != "S"
		nCofins := Round((nVlrComis * IIF(SED->ED_PERCCOF>0,SED->ED_PERCCOF,GetMV("MV_TXCOFIN"))/100),2)
		If ( nCofins < GetMv("MV_VRETCOF") ) // Tratamento do Valor minimo para Ret. da Cofins.
			nCofins := 0
		EndIf
	Endif

//�������������������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do PIS (FORNECEDOR N�O RECOLHE) �
//���������������������������������������������������������������������
	If SED->ED_CALCPIS == "S" .and. SA2->A2_RECPIS != "S"
		nPIS := Round((nVlrComis * IIF(SED->ED_PERCPIS>0,SED->ED_PERCPIS,GetMV("MV_TXPIS"))/100),2)
		If ( nPIS < GetMv("MV_VRETPIS") ) // Tratamento do Valor minimo para Ret. do PIS.
			nPIS := 0
		EndIf
	Endif

//�������������������������������������������������������������������Ŀ
//� Verifica se Natureza pede calculo do CSLL (FORNECEDOR N�O RECOLHE)�
//���������������������������������������������������������������������
	If SED->ED_CALCCSL == "S" .and. SA2->A2_RECCSLL != "S"
		nCSLL := Round((nVlrComis * IIF(SED->ED_PERCCSL>0,SED->ED_PERCCSL,0)/100),2)
		If ( nCSLL < GetMv("MV_VRETCSL") ) // Tratamento do Valor minimo para Ret. do CSLL.
			nCSLL := 0
		EndIf
	Endif

Return .T.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �CalcRetPag� Autor �Sergio Silveira        � Data �05/08/2004���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Efetua o calculo do valor de titulos financeiros que        ���
���          �calcularam a retencao do PIS / COGINS / CSLL e nao          ���
���          �criaram os titulos de retencao                              ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �ExpA1 := CalcRetPag( ExpD1 )                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpD1 - Data de referencia                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpA1 -> Array com os seguintes elementos                   ���
���          �       1 - Valor dos titulos                                ���
���          �       2 - Valor do PIS                                     ���
���          �       3 - Valor do COFINS                                  ���
���          �       4 - Valor da CSLL                                    ���
���          �       5 - Array contendo os recnos dos registos processados���
�������������������������������������������������������������������������Ĵ��
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function CalcRetPag( dReferencia, nIndexSE2, cCodFor, cLojaFor )

	Local aAreaSE2  := SE2->( GetArea() )
	Local aDadosRef := Array( 8 )
	Local aRecnos   := {}

//Local dDataIni  := FirstDay( dReferencia ) 
//Local dDataFim  := LastDay( dReferencia ) 

	Local dDataIni  := mv_par10
	Local dDataFim  := mv_par11

	Local nAdic     := 0
//Controla o Pis Cofins e Csll na baixa (1 = Baixa   2 = Emissao)
	Local lPCCBaixa := SuperGetMv("MV_BX10925",.T.,"2") == "1"  .and. (!Empty( SE5->( ColumnPos( "E5_VRETPIS" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_VRETCOF" ) ) ) .And. ;
		!Empty( SE5->( ColumnPos( "E5_VRETCSL" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_PRETPIS" ) ) ) .And. ;
		!Empty( SE5->( ColumnPos( "E5_PRETCOF" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_PRETCSL" ) ) ) .And. ;
		!Empty( SE2->( ColumnPos( "E2_SEQBX"   ) ) ) .And. !Empty( SFQ->( ColumnPos( "FQ_SEQDES"  ) ) ) )
	Local	lIRPFBaixa := IIf( ! Empty( SA2->( ColumnPos( "A2_CALCIRF" ) ) ), SA2->A2_CALCIRF == "2", .F.) .And. ;
		!Empty( SE2->( ColumnPos( "E2_VRETIRF" ) ) ) .And. !Empty( SE2->( ColumnPos( "E2_PRETIRF" ) ) ) .And. ;
		!Empty( SE5->( ColumnPos( "E5_VRETIRF" ) ) ) .And. !Empty( SE5->( ColumnPos( "E5_PRETIRF" ) ) )
	Local lCalcIssBx := !Empty( SE5->( ColumnPos( "E5_VRETISS" ) ) ) .and. !Empty( SE2->( ColumnPos( "E2_SEQBX"   ) ) ) .and. ;
		!Empty( SE2->( ColumnPos( "E2_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"  //Retencao do ISS pela emissao (1) ou baixa (2)

	Local aStruct   := {}
	Local aCampos   := {}

	Local cAliasQry := ""
	Local cSepNeg   := If("|"$MV_CPNEG,"|",",")
	Local cSepProv  := If("|"$MVPROVIS,"|",",")
	Local cSepRec   := If("|"$MVPAGANT,"|",",")
	Local cQuery    := ""
	Local nLoop     := 0

	AFill( aDadosRef, 0 )

	aCampos := { "E2_VALOR","E2_NATUREZ","E2_IRRF","E2_ISS","E2_INSS","E2_PIS","E2_COFINS","E2_CSLL","E2_VRETPIS","E2_VRETCOF","E2_VRETCSL" }
	aStruct := SE2->( dbStruct() )

	SE2->( dbCommit() )

	cAliasQry := GetNextAlias()

	cQuery := "SELECT E2_VALOR,E2_NATUREZ,E2_PIS,E2_COFINS,E2_EMISSAO,E2_CSLL,E2_ISS,E2_INSS,E2_IRRF,E2_VRETPIS,E2_VRETCOF,E2_VRETCSL,E2_PRETPIS,E2_PRETCOF,E2_PRETCSL,R_E_C_N_O_ RECNO "

	If SE2->(ColumnPos("E2_BASEPIS")) > 0 .And. SE2->(ColumnPos("E2_BASECOF")) > 0 .And. SE2->(ColumnPos("E2_BASECSL")) > 0
		cQuery += ",E2_BASEPIS,E2_BASECOF,E2_BASECSL "
		Aadd(aCampos,"E2_BASEPIS")
		Aadd(aCampos,"E2_BASECOF")
		Aadd(aCampos,"E2_BASECSL")
	Endif

	cQuery += "FROM "+RetSqlName( "SE2" ) + " SE2 "
	cQuery += "WHERE "
	cQuery += "E2_FILIAL='"    + xFilial("SE2")       + "' AND "
	cQuery += "E2_FORNECE='"   + cCodFor              + "' AND "
	cQuery += "E2_LOJA='"      + cLojaFor              + "' AND "
	cQuery += "E2_VENCREA>= '" + DToS( dDataIni )      + "' AND "
	cQuery += "E2_VENCREA<= '" + DToS( dDataFim )      + "' AND "
	cQuery += "E2_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
	cQuery += "E2_TIPO NOT IN " + FormatIn(MV_CPNEG,cSepNeg)  + " AND "
	cQuery += "E2_TIPO NOT IN " + FormatIn(MVPROVIS,cSepProv) + " AND "
	cQuery += "E2_TIPO NOT IN " + FormatIn(MVPAGANT,cSepRec)  + " AND "

	cQuery += "D_E_L_E_T_=' '"

	cQuery := ChangeQuery( cQuery )

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )

	For nLoop := 1 To Len( aStruct )
		If !Empty( AScan( aCampos, AllTrim( aStruct[nLoop,1] ) ) )
			TcSetField( cAliasQry, aStruct[nLoop,1], aStruct[nLoop,2],aStruct[nLoop,3],aStruct[nLoop,4])
		EndIf
	Next nLop

	While !( cAliasQRY )->( Eof())

		nAdic := 0
		If !lPCCBaixa
			nAdic += ( cAliasQRY )->E2_VALOR +;
				If(lIRPFBaixa,0,( cAliasQRY )->E2_IRRF)+;
					If(!lCalcIssBx,( cAliasQRY )->E2_ISS,0)+;
						( cAliasQRY )->E2_INSS
				Else
					nAdic += ( cAliasQRY )->E2_VALOR
				EndIF


				If Empty( ( cAliasQRY )->E2_PRETPIS )
					nAdic += If( Empty( ( cAliasQRY )->E2_VRETPIS ), ( cAliasQRY )->E2_PIS, ( cAliasQRY )->E2_VRETPIS )
				EndIf

				If Empty( ( cAliasQRY )->E2_PRETCOF )
					nAdic += If( Empty( ( cAliasQRY )->E2_VRETCOF ), ( cAliasQRY )->E2_COFINS, ( cAliasQRY )->E2_VRETCOF )
				EndIf

				If Empty( ( cAliasQRY )->E2_PRETCSL )
					nAdic += If( Empty( ( cAliasQRY )->E2_VRETCSL ), ( cAliasQRY )->E2_CSLL, ( cAliasQRY )->E2_VRETCSL )
				EndIf

				aDadosRef[1] += nAdic

				If ( Empty( ( cAliasQRY )->E2_VRETPIS ) .Or. Empty( ( cAliasQry )->E2_VRETCOF ) .Or. Empty( ( cAliasQry )->E2_VRETCSL ) ) ;
						.And. ( ( cAliasQRY )->E2_PRETPIS == "1" .Or. ( cAliasQry )->E2_PRETCOF == "1" .Or. ( cAliasQry )->E2_PRETCSL == "1" )

					If SED->( dbSeek(xFilial("SED")+( cAliasQRY )->E2_NATUREZ) )

						If Empty( ( cAliasQRY )->E2_VRETPIS ) .And. ( cAliasQRY )->E2_PRETPIS == "1"
							aDadosRef[2] += Round((( cAliasQRY )->E2_BASEPIS * IIF(SED->ED_PERCPIS>0,SED->ED_PERCPIS,GetMV("MV_TXPIS"))/100),2)
						EndIf

						If Empty( ( cAliasQRY )->E2_VRETCOF ) .And. ( cAliasQRY )->E2_PRETCOF == "1"
							aDadosRef[3] += Round((( cAliasQRY )->E2_BASEPIS * IIF(SED->ED_PERCCOF>0,SED->ED_PERCCOF,GetMV("MV_TXCOFIN"))/100),2)
						EndIf

						If Empty( ( cAliasQRY )->E2_VRETCSL ) .And. ( cAliasQRY )->E2_PRETCSL == "1"
							aDadosRef[4] += Round((( cAliasQRY )->E2_BASEPIS * IIF(SED->ED_PERCCSL>0,SED->ED_PERCCSL,0)/100),2)
						EndIf
						AAdd( aRecnos, ( cAliasQRY )->RECNO )
					EndIf
				EndIf

				If SE2->(ColumnPos("E2_BASEPIS")) > 0 .And. SE2->(ColumnPos("E2_BASECOF")) > 0 .And. SE2->(ColumnPos("E2_BASECLS")) > 0

					If SE2->E2_BASEPIS > 0 .Or. SE2->E2_BASECOF > 0 .Or. SE2->E2_BASECSL > 0
						aDadosRef[6] += ( cAliasQRY )->E2_BASEPIS
						aDadosRef[7] += ( cAliasQRY )->E2_BASECOF
						aDadosRef[8] += ( cAliasQRY )->E2_BASECSL
					Else
						aDadosRef[6] += nAdic
						aDadosRef[7] += nAdic
						aDadosRef[8] += nAdic
					EndIf

				Else

					aDadosRef[6] += nAdic
					aDadosRef[7] += nAdic
					aDadosRef[8] += nAdic

				EndIf

				( cAliasQRY )->( dbSkip())

			EndDo

// Fecha a area de trabalho da query 
			( cAliasQRY )->( dbCloseArea() )
			dbSelectArea( "SE2" )


			aDadosRef[ 5 ] := AClone( aRecnos )

			SE2->( RestArea( aAreaSE2 ) )

			Return( aDadosRef )

/*/
			����������������������������������������������������������������������������������
			����������������������������������������������������������������������������������
			���Funcao    �IntCPSE2�Autor  �       					    � Data �13/05/2014 ���
			������������������������������������������������������������������������������Ĵ��
			���Descri��o �Verifica se o vendedor tem interface com o CP                    ���
			����������������������������������������������������������������������������������
			����������������������������������������������������������������������������������
/*/                     

Static Function IntCPSE2(cVendAnt)

	Local lRet 		:= .F.
	Local aArea		:= GetArea()
	Local cAlsAux	:= GetNextAlias()
	Local cNatCom	:= SuperGetMv("MV_NATCOM",.F.,"COMISSOES")

	BeginSql alias cAlsAux
	SELECT SA3.A3_COD, SA3.A3_GERASE2, SA2.A2_NATUREZ
	FROM %Table:SA3% SA3
	JOIN %Table:SA2% SA2 ON SA2.A2_FILIAL = %xFilial:SA2%
	 AND SA3.A3_FORNECE = SA2.A2_COD 
	 AND SA2.%NotDel%
	where SA3.A3_FILIAL = %xFilial:SA3% 
	 AND SA3.A3_COD = %Exp:cVendAnt%
	 AND SA3.%NotDel%
	EndSql

	lRet := (cAlsAux)->(A3_GERASE2) == 'S' .And. (!Empty(AllTrim((cAlsAux)->(A2_NATUREZ))) .And. AllTrim((cAlsAux)->(A2_NATUREZ)) $ cNatCom )

	(cAlsAux)->(DbCloseArea())
	RestArea(aArea)

Return lRet

/*---------------------------------------------------------------------*
 | Func:  fTrocaFil                                                    |
 | Desc:  Fun��o para trocar filial    							       |
 *---------------------------------------------------------------------*/
Static Function fTrocaFil(_cFilIni,_cFilTit,lTroca)
	Local aArea		:= GetArea()
	Local aAreaSM0 := SM0->(GetArea())

	If lTroca
		SM0->(dbSetOrder(1))
		SM0->(MsSeek(cEmpAnt + _cFilTit ,.T.))

		cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	Else
		cFIlAnt := _cFilIni
	EndIf
	RestArea(aAreaSM0)
	RestArea(aArea)

Return
