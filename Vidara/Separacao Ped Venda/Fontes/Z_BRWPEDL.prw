#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.CH"
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} Z_BRWPEDL
Função para gerar separacao de pedidos de venda
@author Wagner Neves
@since 05/12/2024
@version 1.0
@type function
/*/
User Function Z_BRWPEDL()
	Local aArea 		:= FWGetArea()
	Local nIntWMS		:= GETMV( "MV_INTWMS" )
	Private nTotalPed	:= 0
	Private cModo		:= FwModeAccess("SC5", 1) + FwModeAccess("SC5", 2) + FwModeAccess("SC5", 3)

	If nIntWMS
		FWAlertInfo('Filial não habilitada para esta rotina, verifique o parametro MV_INTWMS', "Z_BRWPEDL - Mensagem ...")
		Return
	Else
		//Chama a tela
		fMontaTela()
	EndIf

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
	Local aArea     := GetArea()
	Local aCampos 	:= {}
	// Local oTempTable := Nil
	Local aColunas 	:= {}
	Local cFontPad  := 'Tahoma'
	Local oFontGrid := TFont():New(cFontPad, /*uPar2*/, -14)
	Local aSeek   	:= {}
	Local aSC5		:= FwSx3Util():getAllFields("SC5",.F.)
	local nInd		as numeric
	local aAux		:= {}
	local aFilter	:= {}
	local aBrowse	:= Iif(Right(cModo,2) == "CC",{},{"C5_FILIAL"})
	local cTitSeek	as character
	//Janela e componentes
	pRIVATE oTempTable
	Private oDlgMark
	Private oPanGrid
	Private oMarkBrowse
	Private cAliasTmp	:= GetNextAlias()
	Private aRotina   	:= MenuDef()
	//Tamanho da janela
	Private aTamanho	:= MsAdvSize()
	Private nJanLarg 	:= aTamanho[5]
	Private nJanAltu 	:= aTamanho[6]

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK'    		, 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'C5_FILIAL'		, 'C', TamSX3("C5_FILIAL")[1], 0})
	aAdd(aCampos, { 'C5_NUM'   		, 'C', TamSX3("C5_NUM")[1], 0})
	aAdd(aCampos, { 'C5_CLIENTE'   	, 'C', TamSX3("C5_CLIENTE")[1], 0})
	aAdd(aCampos, { 'C5_LOJACLI'  	, 'C', TamSX3("C5_LOJACLI")[1], 0})
	aAdd(aCampos, { 'RSOC'  		, 'C', TamSX3("A1_NOME")[1], 0})
	aAdd(aCampos, { 'DATAI' 		, 'D', TamSX3("C5_EMISSAO")[1] , 0})
	aAdd(aCampos, { 'VALOR' 		, 'N', TamSX3("C6_VALOR")[1], 2})
	aAdd(aCampos, { 'USRL'  		, 'C', TamSX3("C9_ZZUSLIB")[1], 0})
	aAdd(aCampos, { 'DATAL' 		, 'D', TamSX3("C9_ZZDTLIB")[1] , 0})
	aAdd(aCampos, { 'HRL'   		, 'C', TamSX3("C9_ZZHRLIB")[1], 0})
	aAdd(aCampos, { 'USRS'  		, 'C', TamSX3("C9_ZZUSSEP")[1], 0})
	aAdd(aCampos, { 'DATAS' 		, 'D', TamSX3("C9_ZZDTSEP")[1] , 0})
	aAdd(aCampos, { 'HRS'   		, 'C', TamSX3("C9_ZZHRSEP")[1], 0})
	aAdd(aCampos, { 'C5R'   		, 'N', 20, 0})
	aAdd(aCampos, { 'DATAEN'		, 'D', TamSX3("C6_ENTREG")[1] , 0})

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
	oMarkBrowse:AddLegend("Empty((cAliasTmp)->DATAL) .AND. Empty((cAliasTmp)->DATAS)","GRAY"	,"Item Bloqueado")
	oMarkBrowse:AddLegend("!Empty((cAliasTmp)->DATAL) .AND. Empty((cAliasTmp)->DATAS)","GREEN"	,"Item Liberado")
	oMarkBrowse:AddLegend("!Empty((cAliasTmp)->DATAL) .AND. !Empty((cAliasTmp)->DATAS)","BLUE"  ,"Item Separado")
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()

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
	ADD OPTION aRotina TITLE 'Liberacao de Pedidos'  			ACTION 'u_XBWRPEDO(1)'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Separacao de Pedidos'  			ACTION 'u_XBWRPEDO(2)'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Romaneio de Embarque'  	ACTION 'u_XBWRPEDO(3)'     OPERATION 2 ACCESS 0
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
	Local nI     	:= 0
	Local nTotal 	:= 0
	Local nAtual 	:= 0
	Local aDados 	:= {}
	Local nValTot 	:= 0
	Local dEntreg 	:= CTOD("  /  /  ")
	Local dDtLib	:= CTOD("  /  /  ")
	Local cHrLib  	:= ""
	Local cUsLib  	:= ""
	Local dDtSep  	:= CTOD("  /  /  ")
	Local cHrSep  	:= ""
	Local cUsSep  	:= ""
	Local nDadosLib	:= 0
	Local nDadosSep := 0

	//Monta a consulta
	cQryDados :=  "SELECT DISTINCT" + CRLF
	cQryDados +=  " C5.C5_FILIAL," + CRLF
	cQryDados +=  " C5.C5_NUM," + CRLF
	cQryDados +=  " C5.C5_CLIENTE," + CRLF
	cQryDados +=  " C5.C5_LOJACLI," + CRLF
	cQryDados +=  " C5.C5_TIPO," + CRLF
	cQryDados +=  " (SELECT A1.A1_NOME FROM " + RetSqlName("SA1") + " A1 WHERE A1.A1_COD = C5.C5_CLIENTE) AS C5_NOME," + CRLF
	cQryDados +=  " C5.C5_EMISSAO," + CRLF	
	cQryDados +=  " C5.R_E_C_N_O_ AS C5_R_E_C_N_O_" + CRLF
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
	cQryDados +=  " AND C9.C9_BLEST = ' '" + CRLF
	cQryDados +=  " AND C9.C9_BLCRED = ' '" + CRLF
	cQryDados +=  " AND (C9.C9_ZZFASE <> ' ' AND C9.C9_ZZFASE <> 'A') " + CRLF
	cQryDados +=  " AND C9.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SB1") + " B1 (NOLOCK) " + CRLF
	cQryDados +=  " ON B1.B1_COD = C9.C9_PRODUTO" + CRLF
	// cQryDados +=  " AND B1.B1_RASTRO <> 'N'" + CRLF
	// cQryDados +=  " AND B1.B1_LOCALIZ = 'N'" + CRLF
	cQryDados +=  " AND B1.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  " INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SF4") + " F4 (NOLOCK) " + CRLF
	cQryDados +=  " ON F4.F4_FILIAL = '"+xFilial("SF4")+"'" + CRLF
	cQryDados +=  " AND F4.F4_CODIGO = C6.C6_TES" + CRLF		
	cQryDados +=  " WHERE C5.C5_FILIAL = '" + xFilial("SC5") + "' AND " + CRLF
	cQryDados +=  " F4.F4_ESTOQUE = 'S' AND " + CRLF
	cQryDados +=  " C5.C5_TIPO = 'N' AND " + CRLF
	cQryDados +=  " C5.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  " GROUP BY" + CRLF
	cQryDados +=  " C5.C5_FILIAL," + CRLF
	cQryDados +=  " C5.C5_NUM," + CRLF
	cQryDados +=  " C5.C5_CLIENTE," + CRLF
	cQryDados +=  " C5.C5_LOJACLI," + CRLF
	cQryDados +=  " C5.C5_EMISSAO," + CRLF
	cQryDados +=  " C5.C5_TIPO," + CRLF
	cQryDados +=  " C9.C9_ZZDTLIB," + CRLF
	cQryDados +=  " C9.C9_ZZHRLIB," + CRLF
	cQryDados +=  " C9.C9_ZZUSLIB," + CRLF
	cQryDados +=  " C9.C9_ZZDTSEP," + CRLF
	cQryDados +=  " C9.C9_ZZHRSEP," + CRLF
	cQryDados +=  " C9.C9_ZZUSSEP," + CRLF
	cQryDados +=  " C5.R_E_C_N_O_"
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	nTotalPed	:= nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Analisando registro ...')

		aAdd(aDados,{QRYDADTMP->C5_FILIAL,;        //1
		QRYDADTMP->C5_NUM,;           //2
		QRYDADTMP->C5_CLIENTE,;       //3
		QRYDADTMP->C5_LOJACLI,;       //4
		QRYDADTMP->C5_NOME,;          //5
		QRYDADTMP->C5_EMISSAO,;       //6
		QRYDADTMP->C5_R_E_C_N_O_})

		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())

	For nI := 1 To Len(aDados)
		nValTot := 0
		dEntreg := CTOD("  /  /  ")
		dDtLib	:= CTOD("  /  /  ")
		cHrLib  := ""
		cUsLib  := ""
		dDtSep  := CTOD("  /  /  ")
		cHrSep  := ""
		cUsSep  := ""
		SC6->(DbSetOrder(1))
		If SC6->(DbSeek(xFilial("SC6")+aDados[nI][2]))
			While aDados[nI][2] = SC6->C6_NUM
				nValTot	+= SC6->C6_VALOR
				If Empty(dEntreg)
					dEntreg := SC6->C6_ENTREG
				Else
					If dEntreg > SC6->C6_ENTREG
						dEntreg := SC6->C6_ENTREG
					EndIf
				EndIf
				SC6->(DbSkip())
			EndDo
		EndIf
		SC9->(DbSetOrder(1))
		If SC9->(DbSeek(xFilial("SC9")+aDados[nI][2]))
			nDadosLib  := 0
			nDadosSep  := 0
			While aDados[nI][2] = SC9->C9_PEDIDO		
				If nDadosLib = 0
					dDtLib	:= SC9->C9_ZZDTLIB
					cHrLib  := SC9->C9_ZZHRLIB
					cUsLib  := SC9->C9_ZZUSLIB
					nDadosLib  := 1
				ElseIf nDadosLib  = 1
					If Empty(SC9->C9_ZZDTLIB)
						dDtLib  := CTOD("  /  /  ")
						cHrLib  := ""
						cUsLib  := ""	
						nDadosLib  := 2
					EndIf
				EndIf
				If nDadosSep = 0
					dDtSep  := SC9->C9_ZZDTSEP
					cHrSep  := SC9->C9_ZZHRSEP
					cUsSep  := SC9->C9_ZZUSSEP
					nDadosSep  := 1
				ElseIf nDadosSep  = 1
					If Empty(SC9->C9_ZZDTSEP)
						dDtSep  := CTOD("  /  /  ")
						cHrSep  := ""
						cUsSep  := ""	
						nDadosSep  := 2
					EndIf
				EndIf
				SC9->(DbSkip())
			EndDo
		EndIf
		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK     := Space(2)
		(cAliasTmp)->C5_FILIAL 	:= aDados[nI][1]
		(cAliasTmp)->C5_NUM    	:= aDados[nI][2]
		(cAliasTmp)->C5_CLIENTE := aDados[nI][3]
		(cAliasTmp)->C5_LOJACLI := aDados[nI][4]
		(cAliasTmp)->RSOC   	:= aDados[nI][5]
		(cAliasTmp)->DATAI 		:= aDados[nI][6]
		(cAliasTmp)->USRL   	:= cUsLib
		(cAliasTmp)->DATAL  	:= dDtLib
		(cAliasTmp)->HRL    	:= cHrLib
		(cAliasTmp)->USRS   	:= cUsSep
		(cAliasTmp)->DATAS  	:= dDtSep
		(cAliasTmp)->HRS    	:= cHrSep
		(cAliasTmp)->C5R    	:= aDados[nI][7]
		(cAliasTmp)->VALOR  	:= nValTot
		(cAliasTmp)->DATAEN 	:= dEntreg
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
	aAdd(aEstrut, { 'C5_FILIAL'	, 'Filial'  , 'C', TamSX3("C5_FILIAL")[1], 0, ''})
	aAdd(aEstrut, { 'C5_NUM'   	, 'Pedido'  , 'C', TamSX3("C5_NUM")[1], 0, ''})
	aAdd(aEstrut, { 'C5_CLIENTE', 'Cliente' , 'C', TamSX3("C5_CLIENTE")[1], 0, ''})
	aAdd(aEstrut, { 'C5_LOJACLI', 'Loja'    , 'C', TamSX3("C5_LOJACLI")[1], 0, ''})
	aAdd(aEstrut, { 'RSOC'  	, 'Nome'    , 'C', TamSX3("A1_NOME")[1], 0, ''})
	aAdd(aEstrut, { 'DATAI' 	, 'Dt Inc'  , 'D', TamSX3("C5_EMISSAO")[1] , 0, ''})
	aAdd(aEstrut, { 'DATAEN' 	, 'Dt Entr'  , 'D',TamSX3("C6_ENTREG")[1] , 0, ''})
	aAdd(aEstrut, { 'VALOR' 	, 'Valor Total'   , 'N', TamSX3("C6_VALOR")[1], 2, '@E 999,999,999.99'})
	aAdd(aEstrut, { 'USRL'  	, 'Usr Lib' , 'C', TamSX3("C9_ZZUSLIB")[1], 0, ''})
	aAdd(aEstrut, { 'DATAL' 	, 'Dt Lib'  , 'D', TamSX3("C9_ZZDTLIB")[1] , 0, ''})
	aAdd(aEstrut, { 'HRL'   	, 'Hr Lib'  , 'C', TamSX3("C9_ZZHRLIB")[1], 0, ''})
	aAdd(aEstrut, { 'USRS'  	, 'Usr Sep' , 'C', TamSX3("C9_ZZUSSEP")[1], 0, ''})
	aAdd(aEstrut, { 'DATAS' 	, 'Dt Sep'  , 'D', TamSX3("C9_ZZDTSEP")[1] , 0, ''})
	aAdd(aEstrut, { 'HRS'   	, 'Hr Sep'  , 'C', TamSX3("C9_ZZHRSEP")[1], 0, ''})

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
			(cAliasTmp)->C5_NUM})				//16

		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	If !Empty(aMDados)
		If _nButt == 1 //Libera Pedidos
			u_Z_BRWLIBE(aMDados)
			(cAliasTmp)->(DbGoTop())
			While !(cAliasTmp)->(EoF())
				RecLock(cAliasTmp, .F.)
            	DbDelete()
        		(cAliasTmp)->(MsUnlock())
			    (cAliasTmp)->(DbSkip())
    	    EndDo
			fPopula()
		ElseIf _nButt == 2 //Separar pedidos
			u_Z_BRWSEPA(aMDados)
			(cAliasTmp)->(DbGoTop())
			While !(cAliasTmp)->(EoF())
				RecLock(cAliasTmp, .F.)
            	DbDelete()
        		(cAliasTmp)->(MsUnlock())
			    (cAliasTmp)->(DbSkip())
    	    EndDo
			fPopula()
		ElseIf _nButt == 3
			FWAlertInfo("Pendente nome do relatorio para chamada", "Z_BRWPEDL - Mensagem ...")
			Return
		Endif
	Else
		FWAlertInfo("Selecione pelo menos 1 pedido que nao possua ordem de separacao", "Z_BRWPEDL - Mensagem ...")
		Return
	Endif

	FWRestArea(aArea)
Return


