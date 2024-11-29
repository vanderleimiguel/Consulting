#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#Include "TOPCONN.CH"
//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function XBWRPED

@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function XBRWPEDL()
	Local aArea := FWGetArea()

	//Chama a tela
	fMontaTela()

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos := {}
	Local oTempTable := Nil
	Local aColunas := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad, /*uPar2*/, -14)
	//Janela e componentes
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
	aAdd(aCampos, { 'OK'    , 'C', 2, 0}) //Flag para marcação
	aAdd(aCampos, { 'FILIAL', 'C', 10, 0})
	aAdd(aCampos, { 'NUM'   , 'C', 10, 0})
	aAdd(aCampos, { 'CLI'   , 'C', 10, 0})
	aAdd(aCampos, { 'LOJA'  , 'C', 10, 0})
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
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Pedidos Liberados' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, /*oFont*/, /*lCentered*/, /*uParam7*/, RGB(000,000,000), RGB(254,254,254), (nJanLarg/2) - 1, (nJanAltu/2) - 1)
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
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
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*/{Protheus.doc} MenuDef
Botões usados no Browse
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE 'Confirmar Separacao'  			ACTION 'u_XBWRPEDO(1)'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir Romaneio de Embarque'  	ACTION 'u_XBWRPEDO(2)'     OPERATION 2 ACCESS 0
Return aRotina

/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informação na tabela temporária usada no browse
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
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
	cQryDados +=  " C9.C9_DATALIB," + CRLF
	cQryDados +=  " C9.C9_XHRLIB," + CRLF
	cQryDados +=  " C9.C9_XUSLIB," + CRLF
	cQryDados +=  " C9.C9_XDTSEP," + CRLF
	cQryDados +=  " C9.C9_XHRSEP," + CRLF
	cQryDados +=  " C9.C9_XUSSEP," + CRLF
	cQryDados +=  " MAX(C6.R_E_C_N_O_) AS C6_R_E_C_N_O_," + CRLF
	cQryDados +=  " MAX(C5.R_E_C_N_O_) AS C5_R_E_C_N_O_," + CRLF
	cQryDados +=  " MAX(C9.R_E_C_N_O_) AS C9_R_E_C_N_O_" + CRLF
	cQryDados +=  "FROM" + CRLF
	cQryDados +=  " " + RetSqlName("SC5") + " C5" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC6") + " C6" + CRLF
	cQryDados +=  " ON C6.C6_FILIAL = C5.C5_FILIAL" + CRLF
	cQryDados +=  " AND C6.C6_NUM = C5.C5_NUM" + CRLF
	cQryDados +=  " AND C6.C6_QTDEMP <> 0" + CRLF
	cQryDados +=  " AND C6.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC9") + " C9" + CRLF
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
	cQryDados +=  " C9.C9_DATALIB," + CRLF
	cQryDados +=  " C9.C9_XHRLIB," + CRLF
	cQryDados +=  " C9.C9_XUSLIB," + CRLF
	cQryDados +=  " C9.C9_XDTSEP," + CRLF
	cQryDados +=  " C9.C9_XHRSEP," + CRLF
	cQryDados +=  " C9.C9_XUSSEP"
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
			QRYDADTMP->C9_DATALIB,;       //8
			QRYDADTMP->C9_XHRLIB,;        //9
			QRYDADTMP->C9_XUSLIB,;        //10
			QRYDADTMP->C9_XDTSEP,;       //11
			QRYDADTMP->C9_XHRSEP,;        //12
			QRYDADTMP->C9_XUSSEP,;        //13
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
		(cAliasTmp)->FILIAL := aDados[nI][1]
		(cAliasTmp)->NUM    := aDados[nI][2]
		(cAliasTmp)->CLI    := aDados[nI][3]
		(cAliasTmp)->LOJA   := aDados[nI][4]
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
Função que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
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
	aAdd(aEstrut, { 'FILIAL', 'Filial'  , 'C', 04, 0, ''})
	aAdd(aEstrut, { 'NUM'   , 'Pedido'  , 'C', 06, 0, ''})
	aAdd(aEstrut, { 'CLI'   , 'Cliente' , 'C', 30, 0, ''})
	aAdd(aEstrut, { 'LOJA'  , 'Loja'    , 'C', 02, 0, ''})
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
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function XBWRPEDO(nButt)
	Processa({|| fProcessa(nButt)}, 'Processando...')
Return

/*/{Protheus.doc} fProcessa
Função que percorre os registros da tela
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
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
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		//Caso esteja marcado
		If oMarkBrowse:IsMark(cMarca)
			nTotMarc++
			aAdd(aMDados,{(cAliasTmp)->FILIAL,;	//1
			(cAliasTmp)->NUM,;				//2
			(cAliasTmp)->CLI,;				//3
			(cAliasTmp)->LOJA,;				//4
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
			SEPARA(aMDados)
		Endif
	Endif

	FWAlertInfo('Dos [' + cValToChar(nTotal) + '] registros, foram processados [' + cValToChar(nTotMarc) + '] registros', 'Atenção')
	oMarkBrowse:Refresh()
	FWRestArea(aArea)
Return

Static Function SEPARA(aMDados)
	Local aArea := GetArea()
	Local nI := 0

	DbSelectArea("SC9")

	For nI := 1 To Len(aMDados)
		SC9->(DbGoTo(aMDados[nI][16]))
		RecLock("SC9", .F.)
		SC9->C9_XDTSEP := Date()
		SC9->C9_XHRSEP := Time()
		SC9->C9_XUSSEP := UsrRetName(RetCodUsr())
		SC9->(MsUnlock())
	Next

	RestArea(aArea)
Return
