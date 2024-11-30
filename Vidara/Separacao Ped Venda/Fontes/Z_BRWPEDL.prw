#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} Z_BRWPEDL
Função para gerar separacao de pedidos de venda
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function Z_BRWPEDL()
	Local aArea := FWGetArea()
	PRIVATE nConfLote
	PRIVATE nEmbSimul
	PRIVATE nEmbalagem
	PRIVATE nGeraNota
	PRIVATE nImpNota
	PRIVATE nImpEtVol
	PRIVATE nEmbarque
	PRIVATE nAglutPed
	PRIVATE nAglutArm
	private cModo		:= FwModeAccess("SC5", 1) + FwModeAccess("SC5", 2) + FwModeAccess("SC5", 3)

	//Chama a tela
	fMontaTela()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos := {}
	// Local oTempTable := Nil
	Local aColunas := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
	Local aSeek   		:= {}
	Local aSC5			:= FwSx3Util():getAllFields("SC5",.F.)
	local nInd			as numeric
	local aAux			:= {}
	local aFilter		:= {}
	local aBrowse		:= Iif(Right(cModo,2) == "CC",{},{"C5_FILIAL"})
	local cTitSeek		as character
	//Janela e componentes
	pRIVATE oTempTable
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp := GetNextAlias()
	Private aRotina   := MenuDef()
	//Tamanho da janela
	Private aTamanho := MsAdvSize()
	Private nJanLarg := aTamanho[5]
	Private nJanAltu := aTamanho[6]

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK'    		, 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'C5_FILIAL'		, 'C', 10, 0})
	aAdd(aCampos, { 'C5_NUM'   		, 'C', 10, 0})
	aAdd(aCampos, { 'C5_CLIENTE'   	, 'C', 10, 0})
	aAdd(aCampos, { 'C5_LOJACLI'  	, 'C', 10, 0})
	aAdd(aCampos, { 'RSOC'  , 'C', 10, 0})
	aAdd(aCampos, { 'DATAI' , 'D', 8 , 0})
	aAdd(aCampos, { 'VALOR' , 'N', 10, 0})
	aAdd(aCampos, { 'USRL'  , 'C', 10, 0})
	aAdd(aCampos, { 'DATAL' , 'D', 8 , 0})
	aAdd(aCampos, { 'HRL'   , 'C', 10, 0})
	aAdd(aCampos, { 'USRS'  , 'C', 10, 0})
	aAdd(aCampos, { 'DATAS' , 'D', 8 , 0})
	aAdd(aCampos, { 'HRS'   , 'C', 10, 0})
	aAdd(aCampos, { 'C6R'   , 'N', 10, 0})
	aAdd(aCampos, { 'C5R'   , 'N', 10, 0})
	aAdd(aCampos, { 'C9R'   , 'N', 10, 0})

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"C5_FILIAL", "C5_NUM", "C5_CLIENTE", "C5_LOJACLI" })
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	for nInd := 1 to Len(aSC5)
		aAux := FwSx3Util():getFieldStruct(aSC5[nInd])
		if GetSx3Cache(aAux[1],"X3_BROWSE") == "S"
			aAdd(aBrowse,aAux[1])
		endif
		aAdd(aFilter,{	aAux[1],;
			AllTrim(GetSx3Cache(aAux[1],"X3_TITULO")),;
			aAux[2],;
			aAux[3],;
			aAux[4],;
			""})
	next nInd

	aAux := {} ; cTitSeek := ""

	aEval(Separa(SC5->(IndexKey(1)),"+",.F.),;
		{|x| cTitSeek += Iif(! "FILIAL" $ x .or. Right(cModo,2) != "CC",Trim(GetSx3Cache(x,"X3_TITULO"))+"+","") })

	aEval(Separa(SC5->(IndexKey(1)),"+",.F.),;
		{|x| aAdd(aAux,{"",;
		GetSx3Cache(x,"X3_TIPO"),;
		GetSx3Cache(x,"X3_TAMANHO"),;
		GetSx3Cache(x,"X3_DECIMAL"),;
		AllTrim(GetSx3Cache(x,"X3_TITULO")),;
		AllTrim(GetSx3Cache(x,"X3_PICTURE"))}) })
	aAdd(aSeek,{cTitSeek,aAux})

	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Pedidos Liberados' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 1, (nJanAltu/2) - 1)
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:oBrowse:SetDBFFilter(.T.)
    oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
    oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
    oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
    oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oMarkBrowse:oBrowse:SetSeek(,aSeek)
	oMarkBrowse:oBrowse:setFieldFilter(aFilter)//teste
	oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
	oMarkBrowse:SetDescription('Separacao de pedidos de venda')
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:AddLegend("Empty((cAliasTmp)->DATAS)","GREEN"	,"Item Liberado")
	oMarkBrowse:AddLegend("!Empty((cAliasTmp)->DATAS)","BLUE"  ,"Item Separado")
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()

	//³ Ativa tecla F12 para acionar perguntas                         ³
	SetKey(VK_F12,{||AtivaF12(1)})

	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE 'Confirmar Separacao'  			ACTION 'u_XBWRPEDO(1)'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Romaneio de Embarque'  	ACTION 'u_XBWRPEDO(2)'     OPERATION 2 ACCESS 0
Return aRotina

/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fPopula()
	Local cQryDados := ''
	Local nI     := 0
	Local nTotal := 0
	Local nAtual := 0
	Local nC6Rec := 0
	Local cFilmv := GETMV( "ZZ_FILWMS" )
	Local aFilMv := StrTokArr( cFilmv, ";" )
	Local aDados := {}

	//Monta a consulta
	cQryDados :=  "SELECT" + CRLF
	cQryDados +=  " C5.C5_FILIAL," + CRLF
	cQryDados +=  " C5.C5_NUM," + CRLF
	cQryDados +=  " C5.C5_CLIENTE," + CRLF
	cQryDados +=  " C5.C5_LOJACLI," + CRLF
	cQryDados +=  " (SELECT A1.A1_NOME FROM " + RetSqlName("SA1") + " A1 WHERE A1.A1_COD = C5.C5_CLIENTE) AS C5_NOME," + CRLF
	cQryDados +=  " C5.C5_EMISSAO," + CRLF
	cQryDados +=  " C6.C6_VALOR," + CRLF
	cQryDados +=  " C9.C9_ZZDTLIB," + CRLF
	cQryDados +=  " C9.C9_ZZHRLIB," + CRLF
	cQryDados +=  " C9.C9_ZZUSLIB," + CRLF
	cQryDados +=  " C9.C9_ZZDTSEP," + CRLF
	cQryDados +=  " C9.C9_ZZHRSEP," + CRLF
	cQryDados +=  " C9.C9_ZZUSSEP," + CRLF
	cQryDados +=  " C6.R_E_C_N_O_ AS C6_R_E_C_N_O_," + CRLF
	cQryDados +=  " C5.R_E_C_N_O_ AS C5_R_E_C_N_O_," + CRLF
	cQryDados +=  " C9.R_E_C_N_O_ AS C9_R_E_C_N_O_" + CRLF
	cQryDados +=  "FROM" + CRLF
	cQryDados +=  " " + RetSqlName("SC5") + " C5 (NOLOCK)" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC6") + " C6 (NOLOCK) " + CRLF
	cQryDados +=  " ON C6.C6_FILIAL = C5.C5_FILIAL" + CRLF
	cQryDados +=  " AND C6.C6_NUM = C5.C5_NUM" + CRLF
	cQryDados +=  " AND C6.C6_QTDEMP <> 0" + CRLF
	cQryDados +=  " AND C6.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC9") + " C9 (NOLOCK) " + CRLF
	cQryDados +=  " ON C9.C9_FILIAL = C5.C5_FILIAL" + CRLF
	cQryDados +=  " AND C9.C9_PEDIDO = C5.C5_NUM" + CRLF
	cQryDados +=  " AND C9.C9_NFISCAL = ' '" + CRLF
	cQryDados +=  " AND C9.C9_BLCRED = ' '" + CRLF
	cQryDados +=  " AND C9.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "WHERE" + CRLF
	cQryDados +=  " C5.C5_FILIAL Not In ("
	For nI := 1 To Len(aFilMv)
		cQryDados += "'" + aFilMv[nI] + "'"
		If !nI + 1 > Len(aFilMv)
			cQryDados += ","
		Endif
	Next
	cQryDados +=  ")" + CRLF
	cQryDados +=  " AND C5.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "GROUP BY" + CRLF
	cQryDados +=  " C5.C5_FILIAL," + CRLF
	cQryDados +=  " C5.C5_NUM," + CRLF
	cQryDados +=  " C5.C5_CLIENTE," + CRLF
	cQryDados +=  " C5.C5_LOJACLI," + CRLF
	cQryDados +=  " C5.C5_EMISSAO," + CRLF
	cQryDados +=  " C6.C6_VALOR," + CRLF
	cQryDados +=  " C9.C9_ZZDTLIB," + CRLF
	cQryDados +=  " C9.C9_ZZHRLIB," + CRLF
	cQryDados +=  " C9.C9_ZZUSLIB," + CRLF
	cQryDados +=  " C9.C9_ZZDTSEP," + CRLF
	cQryDados +=  " C9.C9_ZZHRSEP," + CRLF
	cQryDados +=  " C9.C9_ZZUSSEP," + CRLF
	cQryDados +=  " C6.R_E_C_N_O_," + CRLF
	cQryDados +=  " C5.R_E_C_N_O_," + CRLF
	cQryDados +=  " C9.R_E_C_N_O_"
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Analisando registro ...')

		If nC6Rec <> QRYDADTMP->C6_R_E_C_N_O_
			aAdd(aDados,{QRYDADTMP->C5_FILIAL,;        //1
			QRYDADTMP->C5_NUM,;           //2
			QRYDADTMP->C5_CLIENTE,;       //3
			QRYDADTMP->C5_LOJACLI,;       //4
			QRYDADTMP->C5_NOME,;          //5
			QRYDADTMP->C5_EMISSAO,;       //6
			QRYDADTMP->C6_VALOR,;         //7
			QRYDADTMP->C9_ZZDTLIB,;       //8
			QRYDADTMP->C9_ZZHRLIB,;        //9
			QRYDADTMP->C9_ZZUSLIB,;        //10
			QRYDADTMP->C9_ZZDTSEP,;       //11
			QRYDADTMP->C9_ZZHRSEP,;        //12
			QRYDADTMP->C9_ZZUSSEP,;        //13
			QRYDADTMP->C6_R_E_C_N_O_,;    //14
			QRYDADTMP->C5_R_E_C_N_O_,;	  //15
			QRYDADTMP->C9_R_E_C_N_O_})    //16
		Endif

		nC6Rec := QRYDADTMP->C6_R_E_C_N_O_
		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())

	For nI := 1 To Len(aDados)
		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK     := Space(2)
		(cAliasTmp)->C5_FILIAL 	:= aDados[nI][1]
		(cAliasTmp)->C5_NUM    	:= aDados[nI][2]
		(cAliasTmp)->C5_CLIENTE := aDados[nI][3]
		(cAliasTmp)->C5_LOJACLI := aDados[nI][4]
		(cAliasTmp)->RSOC   := aDados[nI][5]
		(cAliasTmp)->DATAI  := aDados[nI][6]
		(cAliasTmp)->VALOR  := aDados[nI][7]
		(cAliasTmp)->USRL   := aDados[nI][10]
		(cAliasTmp)->DATAL  := aDados[nI][8]
		(cAliasTmp)->HRL    := aDados[nI][9]
		(cAliasTmp)->USRS   := aDados[nI][13]
		(cAliasTmp)->DATAS  := aDados[nI][11]
		(cAliasTmp)->HRS    := aDados[nI][12]
		(cAliasTmp)->C6R    := aDados[nI][14]
		(cAliasTmp)->C5R    := aDados[nI][15]
		(cAliasTmp)->C9R    := aDados[nI][16]
		(cAliasTmp)->(MsUnlock())
	Next

	(cAliasTmp)->(DbGoTop())
Return

/*/{Protheus.doc} fCriaCols
Função que gera as colunas usadas no browse
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fCriaCols()
	Local nAtual       := 0
	Local aColunas := {}
	Local aEstrut  := {}
	Local oColumn

	//Adicionando campos que serão mostrados na tela
	//[1] - Campo da Temporaria
	//[2] - Titulo
	//[3] - Tipo
	//[4] - Tamanho
	//[5] - Decimais
	//[6] - Máscara
	aAdd(aEstrut, { 'C5_FILIAL'	, 'Filial'  , 'C', 04, 0, ''})
	aAdd(aEstrut, { 'C5_NUM'   	, 'Pedido'  , 'C', 06, 0, ''})
	aAdd(aEstrut, { 'C5_CLIENTE', 'Cliente' , 'C', 30, 0, ''})
	aAdd(aEstrut, { 'C5_LOJACLI', 'Loja'    , 'C', 02, 0, ''})
	aAdd(aEstrut, { 'RSOC'  , 'Nome'    , 'C', 50, 0, ''})
	aAdd(aEstrut, { 'DATAI' , 'Dt Inc'  , 'D', 8 , 0, ''})
	aAdd(aEstrut, { 'VALOR' , 'Valor'   , 'N', 11, 2, '@E 999,999,999.99'})
	aAdd(aEstrut, { 'USRL'  , 'Usr Lib' , 'C', 30, 0, ''})
	aAdd(aEstrut, { 'DATAL' , 'Dt Lib'  , 'D', 8 , 0, ''})
	aAdd(aEstrut, { 'HRL'   , 'Hr Lib'  , 'C', 8, 0, ''})
	aAdd(aEstrut, { 'USRS'  , 'Usr Sep' , 'C', 30, 0, ''})
	aAdd(aEstrut, { 'DATAS' , 'Dt Sep'  , 'D', 8 , 0, ''})
	aAdd(aEstrut, { 'HRS'   , 'Hr Sep'  , 'C', 8, 0, ''})

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

		//Muda o alinhamento conforme o tipo, Data será Centralizado
		If aEstrut[nAtual][3] == 'D'
			oColumn:nAlign := 0

			//Numérico, direita
		ElseIf aEstrut[nAtual][3] == 'N'
			oColumn:nAlign := 2

			//Senão, esquerda (caractere)
		Else
			oColumn:nAlign := 1
		EndIf

		//Adiciona a coluna
		aAdd(aColunas, oColumn)
	Next
Return aColunas

/*/{Protheus.doc} User Function XBWRPEDO
Função acionada pelo botão continuar da rotina
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function XBWRPEDO(nButt)
	Processa({|| fProcessa(nButt)}, 'Criando Ordens de Separacao...')
Return

/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fProcessa(_nButt)
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc 	:= 0
	Local aMDados	:= {}

	//Define o tamanho da régua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	//Percorrendo os registros
	(cAliasTmp)->(DbGoTop())
	While ! (cAliasTmp)->(EoF())
		nAtual++
		IncProc('Verificando pedidos marcados...')

		//Caso esteja marcado
		If oMarkBrowse:IsMark(cMarca) .AND. Empty((cAliasTmp)->DATAS)
			nTotMarc++
			aAdd(aMDados,{(cAliasTmp)->C5_FILIAL,;	//1
			(cAliasTmp)->C5_NUM,;				//2
			(cAliasTmp)->C5_CLIENTE,;				//3
			(cAliasTmp)->C5_LOJACLI,;				//4
			(cAliasTmp)->RSOC,;				//5
			(cAliasTmp)->DATAI,;			//6
			(cAliasTmp)->VALOR,;			//7
			(cAliasTmp)->USRL,;				//8
			(cAliasTmp)->DATAL,;			//9
			(cAliasTmp)->HRL,;				//10
			(cAliasTmp)->USRS,;				//11
			(cAliasTmp)->DATAS,;			//12
			(cAliasTmp)->HRS,;				//13
			(cAliasTmp)->C6R,;				//14
			(cAliasTmp)->C5R,;				//15
			(cAliasTmp)->C9R})				//16
		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	If !Empty(aMDados)
		If _nButt == 1
			fSepara(aMDados)
			FWAlertInfo('Foram processados [' + cValToChar(nTotMarc) + '] registros', "Z_BRWPEDL - Mensagem ...")
			oMarkBrowse:Refresh()
			oDlgMark:End()
		ElseIf _nButt == 2
			FWAlertInfo("Pendente nome do relatorio para chamada", "Z_BRWPEDL - Mensagem ...")
			Return
		Endif
	Else
		FWAlertInfo("Selecione pelo menos 1 pedido que nao possua ordem de separacao", "Z_BRWPEDL - Mensagem ...")
		Return
	Endif

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fSepara
Função que inicia separacao de pedidos
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fSepara(aMDados)
	Local aArea 	:= GetArea()
	Local nI 		:= 0
	Local lPedSep	:= .F.
	Local cFrom     := SuperGetMV("MV_RELFROM",,"" )
	Local cTo       := SuperGetMV("ZZ_MAILPED",,"" )
	Local cSubject  := ""
	Local cBody     := ""
	Local cFilNome  := ""

	DbSelectArea("SC9")

	For nI := 1 To Len(aMDados)
		If Empty(aMDados[nI][12])
			SC9->(DbGoTo(aMDados[nI][16]))
			If Empty(SC9->(C9_BLEST+C9_BLCRED+C9_BLOQUEI))
				lPedSep	:= fGeraSepP()
				If lPedSep
					SC9->(DbGoTo(aMDados[nI][16]))
					RecLock("SC9", .F.)
					SC9->C9_ZZDTSEP := Date()
					SC9->C9_ZZHRSEP := Time()
					SC9->C9_ZZUSSEP := UsrRetName(RetCodUsr())
					SC9->(MsUnlock())

					//Envia email
					If ExistBlock("Z_EnvMail") .AND. !Empty(cFrom) .AND. !Empty(cTo)
						cFilNome    := FwFilialName( cEmpAnt, cFilAnt, 1 )
						cSubject    := "Pedido de Venda "+Alltrim(SC9->C9_PEDIDO)+" criado ordem de separacao"

						cBody   := '<body>'
						cBody   += '<table width="100%" border="0"> '
						cBody   += ' <br>'
						cBody   += '  <tr>'
						cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Pedido de venda '+Alltrim(SC9->C9_PEDIDO)+' criado ordem de separacao</font></td>'
						cBody   += '  </tr>'
						cBody   += '<table width="100%" border="0"> '
						cBody   += ' <br>'
						cBody   += '  <tr>'
						cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
						cBody   += '  </tr>'
						cBody   += ' <br>'
						cBody   += '  <tr>'
						cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Vidara '+cFilNome+'</font></td>'
						cBody   += '  </tr>'
						cBody   += ' <br>'
						cBody   += '</table>'

						U_Z_EnvMail(cFrom,cTo,cSubject,cBody)

					EndIf
				EndIf
			EndIf
		Else
			FWAlertInfo("O pedido "+AllTrim(aMDados[nI][2])+" ja possui ordem de separacao", "Z_BRWPEDL - Mensagem ...")
		EndIf
	Next

	RestArea(aArea)
Return

/*/{Protheus.doc} fGeraSepP
Função que gera a separacao
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
STATIC Function fGeraSepP()
	Local nI
	Local cCodOpe
	Local aRecSC9	:= {}
	Local aOrdSep	:= {}
	Local nNumItens	:= 0
	Local cArm		:= Space(Tamsx3("B1_LOCPAD")[1])
	Local cPedido	:= Space(Tamsx3("C9_PEDIDO")[1])
	Local cCliente	:= Space(Tamsx3("C6_CLI")[1])
	Local cLoja		:= Space(Tamsx3("C6_LOJA")[1])
	Local cCondPag	:= Space(Tamsx3("C5_CONDPAG")[1])
	Local cLojaEnt	:= Space(Tamsx3("C5_LOJAENT")[1])
	Local cAgreg	:= Space(Tamsx3("C9_AGREG")[1])
	Local cOrdSep	:= Space(Tamsx3("CB7_ORDSEP")[1])
	Local cForn		:= ""
	Local cLojaForn	:= ""
	Local cTipExp	:= ""
	Local nPos      := 0
	Local nMaxItens	:= GETMV("MV_NUMITEN")			//Numero maximo de itens por nota (neste caso por ordem de separacao)- by Erike
	Local lConsNumIt:= SuperGetMV("MV_CBCNITE",.F.,.T.) //Parametro que indica se deve ou nao considerar o conteudo do MV_NUMITEN
	// Local lFilItens	:= ExistBlock("ACDA100I")  //Ponto de Entrada para filtrar o processamento dos itens selecionados
	Local lLocOrdSep:= .F.
	Local lA100CABE := ExistBlock("A100CABE")
	Local lACD100GI := ExistBlock("ACD100GI")
	Local lACDA100F := ExistBlock("ACDA100F")
	Local lACD100G1 := ExistBlock("ACD100G1")
	Local aSc9Aux	:= {}
	Local aAux		:= {}
	Local aItens	:= {}
	Local aPvVet	:= {}
	Local aAuxUsr	:= {}
	Local nInd		:= 0
	Local nXnd		:= 0
	Local cTransp	:= Nil
	Local cCondPg	:= Nil
	Local cSeparador:= ""
	Local nPreSep   := 2
	Local lRet      := .F.

	Private aLogOS	:= {}
	Default oBrwMrk	:= Nil
	Default cPedidoPar	:= Nil

	//VERIFICAR PERGUNTA
	cSeparador 	:= "000001"

	AtivaF12(2)

	nMaxItens := If(Empty(nMaxItens),99,nMaxItens)

	// analisar a pergunta '00-Separacao,01-Separacao/Embalagem,02-Embalagem,03-Gera Nota,04-Imp.Nota,05-Imp.Volume,06-embarque,07-Aglutina Pedido,08-Aglutina Local,09-Pre-Separacao'
	If nEmbSimul == 1 // Separacao com Embalagem Simultanea
		cTipExp := "01*"
	Else
		cTipExp := "00*" // Separacao Simples
	EndIF
	If nEmbalagem == 1 // Embalagem
		cTipExp += "02*"
	EndIF
	If nGeraNota == 1 // Gera Nota
		cTipExp += "03*"
	EndIF
	If nImpNota == 1 // Imprime Nota
		cTipExp += "04*"
	EndIF
	If nImpEtVol == 1 // Imprime Etiquetas Oficiais de Volume
		cTipExp += "05*"
	EndIF
	If nEmbarque == 1 // Embarque
		cTipExp += "06*"
	EndIF
	If nAglutPed == 1 // Aglutina pedido
		cTipExp +="11*"
	EndIf
	If nAglutArm == 1 // Aglutina armazem
		cTipExp +="08*"
	EndIf
	If nPreSep == 1 // pre-separacao - Trocar MV_PAR10 para nPreSep
		cTipExp +="09*"
	EndIf
	If nConfLote == 1 // confere lote
		cTipExp +="10*"
	EndIf

	/*Ponto de entrada, permite que o usuário realize o processamento conforme suas particularidades.*/
	If	ExistBlock("ACD100VG")
		If ! ExecBlock("ACD100VG",.F.,.F.,)
			Return
		EndIf
	EndIf

	cCodOpe	 := cSeparador

	SC5->(DbSetOrder(1))
	SC6->(DbSetOrder(1))
	SDC->(DbSetOrder(1))
	CB7->(DbSetOrder(2))
	CB8->(DbSetOrder(2))

	//pesquisa se este item tem saldo a separar, caso tenha, nao gera ordem de separacao
	If CB8->(DbSeek(xFilial('CB8')+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN+SC9->C9_PRODUTO)) .and. CB8->CB8_SALDOS > 0
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Existe saldo a separar deste item","NAO_GEROU_OS"}) //"Pedido"###"Existe saldo a separar deste item"
	EndIf

	If ! SC5->(DbSeek(xFilial('SC5')+SC9->C9_PEDIDO))
		// neste caso a base tem sc9 e nao tem sc5, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC5 x SC9)","NAO_GEROU_OS"}) //"Pedido"###"Inconsistencia de base (SC5 x SC9)"
	EndIf
	If ! SC6->(DbSeek(xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_PRODUTO))
		// neste caso a base tem sc9,sc5 e nao tem sc6,, problema de incosistencia de base
		//Grava o historico das geracoes:
		aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Inconsistencia de base (SC6 x SC9)","NAO_GEROU_OS"}) //"Pedido"###"Inconsistencia de base (SC6 x SC9)"
	EndIf

	If !("08*" $ cTipExp)  // gera ordem de separacao por armazem
		cArm :=SC6->C6_LOCAL
	Else  // gera ordem de separa com todos os armazens
		cArm :=Space(Tamsx3("B1_LOCPAD")[1])
	EndIf
	If "11*" $ cTipExp //AGLUTINA TODOS OS PEDIDOS DE UM MESMO CLIENTE
		cPedido := Space(Tamsx3("C9_PEDIDO")[1])
	Else   // Nao AGLUTINA POR PEDIDO
		cPedido := SC9->C9_PEDIDO
	EndIf
	If "09*" $ cTipExp // AGLUTINA PARA PRE-SEPARACAO
		cPedido  := Space(Tamsx3("C9_PEDIDO")[1]) // CASO SEJA PRE-SEPARACAO TEM QUE CONSIDERAR TODOS OS PEDIDOS
		cCliente := Space(Tamsx3("C6_CLI")[1])
		cLoja    := Space(Tamsx3("C6_LOJA")[1])
		cCondPag := Space(Tamsx3("C5_CONDPAG")[1])
		cLojaEnt := Space(Tamsx3("C5_LOJAENT")[1])
		cAgreg   := Space(Tamsx3("C9_AGREG")[1])
		cForn 		:= SC6->C6_CLI
		cLojaForn	:= SC6->C6_LOJA
		cArmazem	:= SC6->C6_LOCAL
	Else   // NAO AGLUTINA PARA PRE-SEPARACAO
		cCliente 	:= SC6->C6_CLI
		cLoja    	:= SC6->C6_LOJA
		cCondPag 	:= SC5->C5_CONDPAG
		cLojaEnt 	:= SC5->C5_LOJAENT
		cAgreg   	:= SC9->C9_AGREG
		cForn 		:= Space(Tamsx3("C6_CLI")[1])
		cLojaForn	:= Space(Tamsx3("C6_LOJA")[1])
		cArmazem 	:= SC6->C6_LOCAL

	EndIf

	lLocOrdSep := .F.
	If CB7->(DbSeek(xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg))
		While CB7->(!Eof() .and. CB7_FILIAL+CB7_PEDIDO+CB7_LOCAL+CB7_STATUS+CB7_CLIENT+CB7_LOJA+CB7_COND+CB7_LOJENT+CB7_AGREG==;
				xFilial("CB7")+cPedido+cArm+" "+cCliente+cLoja+cCondPag+cLojaEnt+cAgreg)
			If Ascan(aOrdSep, CB7->CB7_ORDSEP) > 0
				lLocOrdSep := .T.
				Exit
			EndIf
			CB7->(DbSkip())
		EndDo
	EndIf

	If Localiza(SC9->C9_PRODUTO)
		If ! SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
			// neste caso nao existe composicao de empenho
			//Grava o historico das geracoes:
			aadd(aLogOS,{"2","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,SC9->C9_ITEM,SC9->C9_PRODUTO,SC9->C9_LOCAL,"Nao existe composicao de empenho (SDC)","NAO_GEROU_OS"}) //"Pedido"###"Nao existe composicao de empenho (SDC)"
		EndIf
	EndIf

	aPvVet := GetAdvFVal( 'SC5', { 'C5_TRANSP', 'C5_CONDPAG' }, FWxFilial( 'SC5' ) + SC9->C9_PEDIDO, 1 )
	Aadd( aAux,{ 	IIf( "09*" $ cTipExp, cForn, cCliente  ),; 	//01-Cliente/Fornecedor
	IIf( "09*" $ cTipExp, cLojaForn, cLoja ),; 	//02-Loja Cliente/Fornecedor
	cCondPag,; 									//03-Condp Pagto
	cLojaEnt,; 									//04-Loja Entrada
	cAgreg	,; 									//05-Agrega
	cArmazem,; 									//06-Armazem
	SC9->( Recno() ),; 							//07-Recno SC9
	SC9->C9_PEDIDO	,; 							//08-Codigo Ped Venda SC9
	cPedido	,; 									//09-Cod. Ped Venda
	aPvVet[ 01 ],; 								//10-Transportadora Ped venda SC5
	aPvVet[ 02 ]  } )							//11-Cond. Pagto Ped venda SC5

	If lACD100G1
		aAuxUsr := ExecBlock("ACD100G1", .F., .F., aTail(aAux) )
		If ValType(aAuxUsr) == "A"
			aTail(aAux) := aClone(aAuxUsr)
		EndIf
	EndIf

	aItens := A100ItGrp( aAux, nAglutPed, nAglutArm, nPreSep )

	Begin Transaction

		For nInd := 1 To Len( aItens )
			nNumItens := 0
			cCliente  := aItens[ nInd ][ 01 ]
			cLoja	  := aItens[ nInd ][ 02 ]
			cArm	  := aItens[ nInd ][ 03 ]
			cPedido	  := aItens[ nInd ][ 06 ]
			cLojaEnt  := aItens[ nInd ][ 07 ]
			cTransp	  := aItens[ nInd ][ 08 ]
			cCondPg   := aItens[ nInd ][ 09 ]
			cAgreg	  := aItens[ nInd ][ 10 ]

			aSc9Aux	  := AClone( aItens[ nInd ][ 05 ] )

			For nXnd := 1 To Len( aSc9Aux )
				SC9->( dbGoto( aSc9Aux[ nXnd ] ) )
				If !lLocOrdSep .or. (("03*" $ cTipExp) .and. !("09*" $ cTipExp) .and. lConsNumIt )
					If ( nNumItens == 0 ) .Or. ( nNumItens >= nMaxItens )
						nNumItens	:= 0
						cOrdSep 	:= CB_SXESXF("CB7","CB7_ORDSEP",,1)
						ConfirmSX8()

						CB7->(RecLock( "CB7",.T.))
						CB7->CB7_FILIAL := xFilial( "CB7" )
						CB7->CB7_ORDSEP := cOrdSep
						CB7->CB7_PEDIDO := cPedido
						CB7->CB7_CLIENT := cCliente
						CB7->CB7_LOJA   := cLoja
						CB7->CB7_COND   := cCondPg
						CB7->CB7_LOJENT := cLojaEnt
						CB7->CB7_LOCAL  := cArm
						CB7->CB7_DTEMIS := dDataBase
						CB7->CB7_HREMIS := Time()
						CB7->CB7_STATUS := " "
						CB7->CB7_CODOPE := cCodOpe
						CB7->CB7_PRIORI := "1"
						CB7->CB7_ORIGEM := "1"
						CB7->CB7_TIPEXP := cTipExp
						CB7->CB7_TRANSP := cTransp
						CB7->CB7_AGREG  := cAgreg
						If	lA100CABE
							ExecBlock("A100CABE",.F.,.F.)
						EndIf
						CB7->(MsUnlock())

						aadd(aOrdSep, cOrdSep )
					EndIf
				EndIf
				//Grava o historico das geracoes:
				nPos := Ascan(aLogOS,{|x| x[01]+x[02]+x[03]+x[04]+x[05]+x[10] == ("1"+"Pedido"+SC9->(C9_PEDIDO+C9_CLIENTE+C9_LOJA)+CB7->CB7_ORDSEP)})
				If nPos == 0
					aadd(aLogOS,{"1","Pedido",SC9->C9_PEDIDO,SC9->C9_CLIENTE,SC9->C9_LOJA,"","",cArm,"",CB7->CB7_ORDSEP}) //"Pedido"
				Endif

				If Localiza(SC9->C9_PRODUTO)
					SDC->( dbSeek(xFilial("SDC")+SC9->C9_PRODUTO+SC9->C9_LOCAL+"SC6"+SC9->C9_PEDIDO+SC9->C9_ITEM+SC9->C9_SEQUEN))
					While SDC->( !Eof() ) .And. SDC->DC_FILIAL == FWxFilial( "SDC" ) .And. SDC->DC_PRODUTO == SC9->C9_PRODUTO .And. SDC->DC_LOCAL == SC9->C9_LOCAL .And. SDC->DC_ORIGEM == 'SC6' .And. SDC->DC_PEDIDO == SC9->C9_PEDIDO .And. SDC->DC_ITEM == SC9->C9_ITEM .And. SDC->DC_SEQ == SC9->C9_SEQUEN
						SB1->(DBSetOrder(1))
						If SB1->(DbSeek(xFilial("SB1")+SDC->DC_PRODUTO)) .And. IsProdMOD(SDC->DC_PRODUTO)
							SDC->(DbSkip())
							// Loop
						Endif
						CB7->( dbSetOrder( 1 ) )
						CB7->( dbSeek( xFilial( "CB7" ) + cOrdSep ) )
						CB8->(RecLock("CB8",.T.))
						CB8->CB8_FILIAL := xFilial("CB8")
						CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
						CB8->CB8_ITEM   := SC9->C9_ITEM
						CB8->CB8_PEDIDO := SC9->C9_PEDIDO
						CB8->CB8_PROD   := SDC->DC_PRODUTO
						CB8->CB8_LOCAL  := SDC->DC_LOCAL
						CB8->CB8_QTDORI := SDC->DC_QUANT
						If "09*" $ cTipExp
							CB8->CB8_SLDPRE := SDC->DC_QUANT
						EndIf
						CB8->CB8_SALDOS := SDC->DC_QUANT
						If ! "09*" $ cTipExp .AND. nEmbalagem == 1
							CB8->CB8_SALDOE := SDC->DC_QUANT
						EndIf
						CB8->CB8_LCALIZ := SDC->DC_LOCALIZ
						CB8->CB8_NUMSER := SDC->DC_NUMSERI
						CB8->CB8_SEQUEN := SC9->C9_SEQUEN
						CB8->CB8_LOTECT := SC9->C9_LOTECTL
						CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
						CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
						CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
						If	lACD100GI
							ExecBlock("ACD100GI",.F.,.F.)
						EndIf
						CB8->(MsUnLock())
						//Atualizacao do controle do numero de itens a serem impressos
						nNumItens ++
						RecLock("CB7",.F.)
						CB7->CB7_NUMITE := nNumItens
						CB7->(MsUnLock())
						SDC->( dbSkip() )
					EndDo
				Else
					CB7->( dbSetOrder( 1 ) )
					CB7->( dbSeek( xFilial( "CB7" ) + cOrdSep ) )

					CB8->(RecLock("CB8",.T.))
					CB8->CB8_FILIAL := xFilial("CB8")
					CB8->CB8_ORDSEP := CB7->CB7_ORDSEP
					CB8->CB8_ITEM   := SC9->C9_ITEM
					CB8->CB8_PEDIDO := SC9->C9_PEDIDO
					CB8->CB8_PROD   := SC9->C9_PRODUTO
					CB8->CB8_LOCAL  := SC9->C9_LOCAL
					CB8->CB8_QTDORI := SC9->C9_QTDLIB

					If "09*" $ cTipExp
						CB8->CB8_SLDPRE := SC9->C9_QTDLIB
					EndIf

					CB8->CB8_SALDOS := SC9->C9_QTDLIB
					If ! "09*" $ cTipExp .AND. nEmbalagem == 1
						CB8->CB8_SALDOE := SC9->C9_QTDLIB
					EndIf

					CB8->CB8_LCALIZ := ""
					CB8->CB8_NUMSER := SC9->C9_NUMSERI
					CB8->CB8_SEQUEN := SC9->C9_SEQUEN
					CB8->CB8_LOTECT := SC9->C9_LOTECTL
					CB8->CB8_NUMLOT := SC9->C9_NUMLOTE
					CB8->CB8_CFLOTE := If("10*" $ cTipExp,"1","2")
					CB8->CB8_TIPSEP := If("09*" $ cTipExp,"1"," ")
					If	lACD100GI
						ExecBlock("ACD100GI",.F.,.F.)
					EndIf
					CB8->(MsUnLock())

					//Atualizacao do controle do numero de itens a serem impressos
					nNumItens ++
					RecLock("CB7",.F.)
					CB7->CB7_NUMITE := nNumItens
					CB7->(MsUnLock())
				EndIf
				Aadd(aRecSC9,{ SC9->(Recno() ), cOrdSep } )
			Next nXnd
		Next nInd

		CB7->(DbSetOrder(1))
		For nI := 1 to len( aOrdSep )
			CB7->(DbSeek(xFilial("CB7")+aOrdSep[nI]))
			CB7->(RecLock("CB7"))
			CB7->CB7_STATUS := "0"  // nao iniciado
			CB7->(MsUnlock())

			If	lACDA100F
				ExecBlock("ACDA100F",.F.,.F.,{aOrdSep[nI]})
			EndIf
		Next

		For nI := 1 to len(aRecSC9)
			SC9->(DbGoto(aRecSC9[nI,1]))
			SC9->(RecLock("SC9"))
			SC9->C9_ORDSEP := aRecSC9[nI,2]
			SC9->(MsUnlock())
			If !Empty(aRecSC9[nI,2])
				lRet	:= .T.
			EndIf
		Next

		If !Empty(aLogOS)
			LogACDA100()
		Endif

	End Transaction
Return lRet

/*/{Protheus.doc} A100ItGrp
Funcao Responsavel por Preencher o Vetor de Itens Respeitando a Configuracao 
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function A100ItGrp( aAux, nAglutPed, nAglutArm, nPreSep )
	Local nInd		:= 0
	Local nPosSc9	:= 0
	Local nAuxVet 	:= 0
	Local aItens	:= {}
	Local aAuxVet	:= {}
	Local aItensUsr	:= {}
	Local bAscVet	:= Nil
	Local bAuxVet1	:= Nil
	Local bAuxVet2	:= Nil
	Local bAuxVet3	:= Nil
	Local lAglut    := .F.
	Local lAglutArm := .F.
	Local lACD100G2 := ExistBlock("ACD100G2")
	Local lACD100G3 := ExistBlock("ACD100G3")

	// O bloco de codigo bAscVet determina a regra para efetuar a quebra das Ordens de Separacao (Por cliente e loja, por cliente, loja e armazem, etc.)
	// As regras estao descritas no documento: https://tdn.totvs.com/pages/viewpage.action?pageId=619129430
	// Os demais blocos contem os mesmos campos e sao utilizados para efetuar as comparacoes para efeito de aglutinacao de pedidos em uma mesma O.S.

	Do Case

	Case nAglutPed == 2 .And. nAglutArm == 2

		// Aglutina Pedido = Nao; Aglutina Armazem = Nao
		// Sera gerada uma Ordem de Separacao para cada pedido de vendas
		// Caso um pedido de venda possua itens com armazens diferentes, sera gerada uma Ordem de Separacao diferente para cada item/armazem

		bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.; // Pedido
		AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
		AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.; // Loja
		AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }  // Armazem

		bAuxVet1 := { || Aadd( aAuxVet, {		AllTrim( aAux[ nInd ][ 08 ] ),;
			AllTrim( aAux[ nInd ][ 01 ] ),;
			AllTrim( aAux[ nInd ][ 02 ] ),;
			AllTrim( aAux[ nInd ][ 06 ] ),;
			{ AllTrim( aAux[ nInd ][ 08 ] ) },;
			{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

		bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.;
			AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }

		bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 04 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) .And.;
			AllTrim( x[ 04 ] ) == AllTrim( aItens[ nInd ][ 03 ] ) } ) }

	Case nAglutPed == 2 .And. nAglutArm == 1

		// Aglutina Pedido = Nao; Aglutina Armazem = Sim
		// Sera gerada uma Ordem de Separacao para cada pedido de vendas
		// Mesmo que o pedido de venda possua itens com armazens diferentes, todos os itens do pedido serao considerados na mesma Ordem de Separacao

		bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 04 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.; // Pedido
		AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
		AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }  // Loja

		bAuxVet1 := { || Aadd( aAuxVet, {		AllTrim( aAux[ nInd ][ 08 ] ),;
			AllTrim( aAux[ nInd ][ 01 ] ),;
			AllTrim( aAux[ nInd ][ 02 ] ),;
			{ AllTrim( aAux[ nInd ][ 08 ] ) },;
			{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

		bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 08 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }

		bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 04 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) } ) }

	Case nAglutPed == 1 .And. nAglutArm == 2

		// Aglutina Pedido = Sim; Aglutina Armazem = Nao
		// Pedidos de venda serao aglutinados em uma mesma Ordem de Separacao desde que sejam do mesmo cliente/loja
		// Caso um pedido de venda possua itens com armazens diferentes, sera gerada uma Ordem de Separacao diferente para cada item/armazem

		bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
		AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.; // Loja
		AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }  // Armazem

		bAuxVet1 := { || Aadd( aAuxVet, { 		AllTrim( aAux[ nInd ][ 01 ] ),;
			AllTrim( aAux[ nInd ][ 02 ] ),;
			AllTrim( aAux[ nInd ][ 06 ] ),;
			{ AllTrim( aAux[ nInd ][ 08 ] ) },;
			{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

		bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aAux[ nInd ][ 06 ] ) } ) }

		bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) .And.;
			AllTrim( x[ 03 ] ) == AllTrim( aItens[ nInd ][ 03 ] ) } ) }

	Case nAglutPed == 1 .And. nAglutArm == 1

		// Aglutina Pedido = Sim; Aglutina Armazem = Sim
		// Pedidos de venda serao aglutinados em uma mesma Ordem de Separacao desde que sejam do mesmo cliente/loja
		// Mesmo que o pedido de venda possua itens com armazens diferentes, todos os itens do pedido serao considerados na mesma Ordem de Separacao

		bAscVet := { || Ascan( aItens ,{ | x |  AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.; // Cliente
		AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }  // Loja

		bAuxVet1 := { || Aadd( aAuxVet, { 		AllTrim( aAux[ nInd ][ 01 ] ),;
			AllTrim( aAux[ nInd ][ 02 ] ),;
			{ AllTrim( aAux[ nInd ][ 08 ] ) },;
			{ AllTrim( aAux[ nInd ][ 06 ] ) } } ) }

		bAuxVet2 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aAux[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aAux[ nInd ][ 02 ] ) } ) }

		bAuxVet3 := { || Ascan( aAuxVet,{ | x | AllTrim( x[ 01 ] ) == AllTrim( aItens[ nInd ][ 01 ] ) .And.;
			AllTrim( x[ 02 ] ) == AllTrim( aItens[ nInd ][ 02 ] ) } ) }

	EndCase

	If lACD100G2
		bAscVet := ExecBlock("ACD100G2", .F., .F., {bAscVet,nAglutPed,nAglutArm} )
	EndIf

	For nInd := 1 to Len( aAux )
		nPosSc9 := Eval( bAscVet )
		If nPosSc9 == 0
			Aadd( aItens, { AllTrim( aAux[ nInd ][ 01 ] ),; 	//01-Cliente/Fornecedor
			AllTrim( aAux[ nInd ][ 02 ] ),; 	//02-Loja Cliente/Fornecedor
			AllTrim( aAux[ nInd ][ 06 ] ),; 	//03-Armazem
			AllTrim( aAux[ nInd ][ 08 ] ),; 	//04-Codigo Ped Venda SC9
			{ aAux[ nInd ][ 07 ] }		 ,; 	//05-Vetor Recno SC9
			AllTrim( aAux[ nInd ][ 09 ] ),; 	//06-Cod. Ped Venda
			AllTrim( aAux[ nInd ][ 04 ] ),; 	//07-Loja Entrada
			AllTrim( aAux[ nInd ][ 10 ] ),; 	//08-Transportadora Ped venda SC5
			AllTrim( aAux[ nInd ][ 11 ] ),; 	//09-Cond. Pagto Ped venda SC5
			allTrim( aAux[ nInd ][ 05 ] ) } )	//10-Agreg

			Eval( bAuxVet1 )

			If lACD100G3
				aItensUsr := ExecBlock("ACD100G3", .F., .F., {aTail(aItens),aAux[nInd]} )
				If ValType(aItensUsr) == "A"
					aTail(aItens) := aClone(aItensUsr)
				EndIf
			EndIf

		Else
			Aadd( aItens[ nPosSc9 ][ 05 ], aAux[ nInd ][ 07 ] ) //05-Vetor Recno SC9
			nPosAglt := Eval( bAuxVet2 )
			If nPosAglt > 0
				If Ascan( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] )-1 ], AllTrim( aAux[ nInd ][ 08 ] ) ) == 0
					Aadd( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] )-1 ], AllTrim( aAux[ nInd ][ 08 ] ) )
				EndIf
				If Ascan( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] ) ], AllTrim( aAux[ nInd ][ 06 ] ) ) == 0
					Aadd( aAuxVet[ nPosAglt ][ Len( aAuxVet[ nPosAglt ] ) ], AllTrim( aAux[ nInd ][ 06 ] ) )
				EndIf
			EndIf

		EndIf

	Next nInd

	For nInd := 1 To Len( aItens )
		nAuxVet := Eval( bAuxVet3 )
		lAglut	:=   Len( aAuxVet[ nAuxVet ][ Len( aAuxVet[ nAuxVet ] )-1 ] ) > 1
		lAglutArm := Len( aAuxVet[ nAuxVet ][ Len( aAuxVet[ nAuxVet ] ) ] ) > 1

		Do Case
		Case nAglutPed == 2 .And. nAglutArm == 2 // Aglutina Pedido = Nao; Aglutina Armazem = Nao
			aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
			aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
			aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
			aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
			aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

		Case nAglutPed == 2 .And. nAglutArm == 1 // Aglutina Pedido = Nao; Aglutina Armazem = Sim
			aItens[ nInd ][ 03 ] := IIf( lAglutArm .Or. nPreSep == 1, CriaVar( 'CB7_LOCAL' , .F. ), aItens[ nInd ][ 03 ] )
			aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
			aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
			aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
			aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
			aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

		Case nAglutPed == 1 .And. nAglutArm == 2 // Aglutina Pedido = Sim; Aglutina Armazem = Nao
			aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
			aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
			aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
			aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
			aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

		Case nAglutPed == 1 .And. nAglutArm == 1 // Aglutina Pedido = Sim; Aglutina Armazem = Sim
			aItens[ nInd ][ 03 ] := IIf( lAglutArm .Or. nPreSep == 1, CriaVar( 'CB7_LOCAL' , .F. ), aItens[ nInd ][ 03 ] )
			aItens[ nInd ][ 06 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_PEDIDO', .F. ), aItens[ nInd ][ 04 ] )
			aItens[ nInd ][ 07 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_LOJENT', .F. ), aItens[ nInd ][ 07 ] )
			aItens[ nInd ][ 08 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_TRANSP', .F. ), aItens[ nInd ][ 08 ] )
			aItens[ nInd ][ 09 ] := IIf( lAglut .Or. nPreSep == 1, CriaVar( 'CB7_COND'  , .F. ), aItens[ nInd ][ 09 ] )
			aItens[ nInd ][ 10 ] := IIf( nPreSep == 1, CriaVar( 'CB7_AGREG' , .F. ), aItens[ nInd ][ 10 ] )

		EndCase

	Next nInd
Return aItens


Static Function LogACDA100()
	Local i, j, k
	Local cChaveAtu, cPedCli, cOPAtual

//Cabecalho do Log de processamento:
	AutoGRLog(Replicate("=",75))
	AutoGRLog("                         I N F O R M A T I V O") //"                         I N F O R M A T I V O"
	AutoGRLog("               H I S T O R I C O   D A S   G E R A C O E S") //"               H I S T O R I C O   D A S   G E R A C O E S"

//Detalhes do Log de processamento:
	AutoGRLog(Replicate("=",75))
	AutoGRLog("I T E N S   P R O C E S S A D O S :") //"I T E N S   P R O C E S S A D O S :"
	AutoGRLog(Replicate("=",75))
	If aLogOS[1,2] == "Pedido" //"Pedido"
		aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[10]+x[03]+x[04]+x[05]+x[06]+x[07]+x[08]<y[01]+y[10]+y[03]+y[04]+y[05]+y[06]+y[07]+y[08]})
		// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Pedido + Cliente + Loja + Item + Produto + Local
		cChaveAtu := ""
		cPedCli   := ""
		For i:=1 to len(aLogOs)
			If aLogOs[i,10] <> cChaveAtu .OR. (aLogOs[i,03]+aLogOs[i,04] <> cPedCli)
				If !Empty(cChaveAtu)
					AutoGRLog(Replicate("-",75))
				Endif
				j:=0
				k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
					cChaveAtu := aLogOs[i,10]
				For j:=k to len(aLogOs)
					If aLogOs[j,10] <> cChaveAtu
						Exit
					Endif
					If Empty(aLogOs[j,08]) //Aglutina Armazem
						AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]) //"Pedido: "###" - Cliente: "
					Else
						AutoGRLog("Pedido: "+aLogOs[j,03]+" - Cliente: "+aLogOs[j,04]+"-"+aLogOs[j,05]+" - Local: "+aLogOs[j,08]) //"Pedido: "###" - Cliente: "###" - Local: "
					Endif
					cPedCli := aLogOs[j,03]+aLogOs[j,04]
					If aLogOs[j,10] == "NAO_GEROU_OS"
						Exit
					Endif
					i:=j
				Next
				AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,10],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
				If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
					AutoGRLog("Motivo: ") //"Motivo: "
				Endif
			Endif
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog("Item: "+aLogOs[i,06]+" - Produto: "+AllTrim(aLogOs[i,07])+" - Local: "+aLogOs[i,08]+" ---> "+aLogOs[i,09]) //"Item: "###" - Produto: "###" - Local: "
			Endif
		Next
	Elseif aLogOS[1,2] == "Nota" //"Nota"
		aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[08]+x[03]+x[04]+x[05]+x[06]<y[01]+y[08]+y[03]+y[04]+y[05]+y[06]})
		// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Nota + Serie + Cliente + Loja
		cChaveAtu := ""
		For i:=1 to len(aLogOs)
			If aLogOs[i,08] <> cChaveAtu
				If !Empty(cChaveAtu)
					AutoGRLog(Replicate("-",75))
				Endif
				cChaveAtu := aLogOs[i,08]
				AutoGRLog("Nota: "+aLogOs[i,3]+"/"+aLogOs[i,04]+" - Cliente: "+aLogOs[i,05]+"-"+aLogOs[i,06]) //"Nota: "###" - Cliente: "
				AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,08],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
				If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
					AutoGRLog("Motivo: ") //"Motivo: "
				Endif
			Endif
		Next
	Else  //Ordem de Producao
		aLogOS := aSort(aLogOS,,,{|x,y| x[01]+x[07]+x[03]+x[04]<y[01]+y[07]+y[03]+y[04]})
		// Status Ord.Sep(1=Gerou;2=Nao Gerou) + Ordem Separacao + Ordem Producao + Produto
		cChaveAtu := ""
		cOPAtual  := ""
		For i:=1 to len(aLogOs)
			If aLogOs[i,07] <> cChaveAtu .OR. aLogOs[i,03] <> cOPAtual
				If !Empty(cChaveAtu)
					AutoGRLog(Replicate("-",75) )
				Endif
				j:=0
				k:=i  //Armazena o conteudo do contador do laco logico principal (i) pois o "For" j altera o valor de i;
					cChaveAtu := aLogOs[i,07]
				For j:=k to len(aLogOs)
					If aLogOs[j,07] <> cChaveAtu
						Exit
					Endif
					If Empty(aLogOs[j,05]) //Aglutina Armazem
						AutoGRLog("Ordem de Producao: "+aLogOs[i,03]) //"Ordem de Producao: "
					Else
						AutoGRLog("Ordem de Producao: "+aLogOs[i,03]+" - Local: "+aLogOs[j,05]) //"Ordem de Producao: "###" - Local: "
					Endif
					cOPAtual := aLogOs[j,03]
					If aLogOs[j,07] == "NAO_GEROU_OS"
						Exit
					Endif
					i:=j
				Next
				AutoGRLog("Ordem de Separacao: "+If(aLogOs[i,01]=="1",aLogOs[i,07],"N A O  G E R A D A")) //"Ordem de Separacao: "###"N A O  G E R A D A"
				If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
					AutoGRLog("Motivo: ") //"Motivo: "
				Endif
			Endif
			If aLogOs[i,01] == "2"  //Ordem Sep. NAO gerada
				AutoGRLog(" ---> "+aLogOs[i,06])
			Endif
		Next
	Endif
Return

/*/{Protheus.doc} AtivaF12
Função executa F12
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function AtivaF12(nOrigExp)
	Local lPerg := .F.
	Local lRet  := .T.
	If	nOrigExp == 1
		lPerg := .T.
	EndIf
	If	lRet
		If	Pergunte("AIA106",lPerg) .Or. !lPerg
			nConfLote	:= MV_PAR01
			nEmbSimul	:= MV_PAR02
			nEmbalagem	:= MV_PAR03
			If cPaisLoc == "BRA"
				nGeraNota	:= MV_PAR04
				nImpNota	:= MV_PAR05
				nImpEtVol	:= MV_PAR06
				nEmbarque	:= MV_PAR07
				nAglutPed	:= MV_PAR08
				nAglutArm	:= MV_PAR09
			Else
				nImpEtVol	:= MV_PAR04
				nEmbarque	:= MV_PAR05
				nAglutPed	:= MV_PAR06
				nAglutArm	:= MV_PAR07
			EndIf
		EndIf
	EndIf
Return

