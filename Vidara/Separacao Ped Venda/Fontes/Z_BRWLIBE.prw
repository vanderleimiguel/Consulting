#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} Z_BRWLIBE
	Funcao para liberar itens dos pedidos de vendas
	@type function
	@version 1.0
	@author Wagner Neves
	@since 05/12/2024
/*/
user function Z_BRWLIBE(aPedidos)
	MsgRun("Consultando pedidos para liberacao ...","Aguarde",{|| fMontaTela(aPedidos) })
return

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Desc:  Função para montar tela    							       |
 *---------------------------------------------------------------------*/
Static Function fMontaTela(aPedidos)
	Local aArea         := GetArea()
	Local aCampos 		:= {}
	Local oTempTable 	:= Nil
	Local aColunas 		:= {}
	Local cFontPad    	:= 'Tahoma'
	Local oFontGrid   	:= TFont():New(cFontPad,,-14)
	Local aSeek   		:= {}
	local nInd			as numeric
	local aSC9			:= FwSx3Util():getAllFields("SC9",.F.)
	local aAux			:= {}
	local aFilter		:= {}
	local aBrowse		:= Iif(Right(cModo,2) == "CC",{},{"C9_FILIAL"})
	local cTitSeek		as character
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
	Private nQtdTot     := 0
	Private nVlrTot     := 0
	Private cFontUti    := "Tahoma"
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontTitP   := TFont():New(cFontUti, , -10)
	Private nConfLote
	Private nEmbSimul
	Private nEmbalagem
	Private nGeraNota
	Private nImpNota
	Private nImpEtVol
	Private nEmbarque
	Private nAglutPed
	Private nAglutArm

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK'			, 'C', 2						, 0})
	aAdd(aCampos, { 'C9_FILIAL'		, 'C', TamSX3("C9_FILIAL")[1]	, 0})
	aAdd(aCampos, { 'C9_PEDIDO'		, 'C', TamSX3("C9_PEDIDO")[1]	, 0})
	aAdd(aCampos, { 'C9_ITEM'		, 'C', TamSX3("C9_ITEM")[1]	, 0})
	aAdd(aCampos, { 'C9_CLIENTE'	, 'C', TamSX3("C9_CLIENTE")[1]	, 0})
	aAdd(aCampos, { 'C9_LOJA'		, 'C', TamSX3("C9_LOJA")[1]	, 0})
	aAdd(aCampos, { 'C9_PRODUTO'	, 'C', TamSX3("C9_PRODUTO")[1]  , 0})
	aAdd(aCampos, { 'C6_VALOR'		, 'N', TamSX3("C6_VALOR")[1]	, 2})
	aAdd(aCampos, { 'NOME'  		, 'C', TamSX3("A1_NOME")[1], 0})
	aAdd(aCampos, { 'C5_EMISSAO' 	, 'D', TamSX3("C5_EMISSAO")[1] , 0})
	aAdd(aCampos, { 'C6_ENTREG' 	, 'D', TamSX3("C6_ENTREG")[1] , 0})
	aAdd(aCampos, { 'C9_ZZUSLIB'  	, 'C', TamSX3("C9_ZZUSLIB")[1], 0})
	aAdd(aCampos, { 'C9_ZZDTLIB' 	, 'D', TamSX3("C9_ZZDTLIB")[1] , 0})
	aAdd(aCampos, { 'C9_ZZHRLIB'   	, 'C', TamSX3("C9_ZZHRLIB")[1], 0})
	aAdd(aCampos, { 'C9_ZZUSSEP'  	, 'C', TamSX3("C9_ZZUSSEP")[1], 0})
	aAdd(aCampos, { 'C9_ZZDTSEP' 	, 'D', TamSX3("C9_ZZDTSEP")[1] , 0})
	aAdd(aCampos, { 'C9_ZZHRSEP'   	, 'C', TamSX3("C9_ZZHRSEP")[1], 0})
	aAdd(aCampos, { 'C9Recno'		, 'N', 20	, 0})

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"C9_FILIAL", "C9_CLIENTE", "C9_LOJA", "C9_PEDIDO"})
	oTempTable:addIndex("2", {"C9Recno"})
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula(aPedidos)}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	for nInd := 1 to Len(aSC9)
		aAux := FwSx3Util():getFieldStruct(aSC9[nInd])
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

	aEval(Separa(SC9->(IndexKey(2)),"+",.F.),;
			{|x| cTitSeek += Iif(! "FILIAL" $ x .or. Right(cModo,2) != "CC",Trim(GetSx3Cache(x,"X3_TITULO"))+"+","") })

	aEval(Separa(SC9->(IndexKey(2)),"+",.F.),;
			{|x| aAdd(aAux,{"",;
							GetSx3Cache(x,"X3_TIPO"),;
							GetSx3Cache(x,"X3_TAMANHO"),;
							GetSx3Cache(x,"X3_DECIMAL"),;
							AllTrim(GetSx3Cache(x,"X3_TITULO")),;
							AllTrim(GetSx3Cache(x,"X3_PICTURE"))}) })
	aAdd(aSeek,{cTitSeek,aAux})

	DEFINE MSDIALOG oDlgMark TITLE 'Liberacao de Itens dos Pedidos de Venda' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
	//Cabecalho
	// @ 002,010 SAY oSay0 PROMPT "Pedidos a serem separados:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL

	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, 300)
	oMarkBrowse := FWMarkBrowse():New()
	// oMarkBrowse:SetDescription('Títulos de Comissões')
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:oBrowse:SetDBFFilter(.T.)
    oMarkBrowse:oBrowse:SetUseFilter(.T.) //Habilita a utilização do filtro no Browse
    oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
    oMarkBrowse:SetWalkThru(.F.) //Habilita a utilização da funcionalidade Walk-Thru no Browse
    oMarkBrowse:SetAmbiente(.T.) //Habilita a utilização da funcionalidade Ambiente no Browse
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:oBrowse:SetSeek(,aSeek)
	oMarkBrowse:oBrowse:setFieldFilter(aFilter)//teste
	oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padrão do Browse
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:AddLegend("Empty((cAliasTmp)->C9_ZZDTLIB)","GREEN"	,"Item Nao Liberado")
	oMarkBrowse:AddLegend("!Empty((cAliasTmp)->C9_ZZDTLIB)","BLUE"  ,"Item Liberado")
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:SetColumns(aColunas)
	oMarkBrowse:Activate()

	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Função para botoes do menu							       |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções do menu
	ADD OPTION aRotina TITLE 'Liberar Pedidos'  ACTION 'U_fBtnLiber'     OPERATION 3 ACCESS 0

Return aRotina

/*---------------------------------------------------------------------*
 | Func:  fPopula                                                      |
 | Desc:  Função para popular tabela temporaria					       |
 *---------------------------------------------------------------------*/
Static Function fPopula(aPedidos)
	Local cQryDados := ''
	Local nTotal 	:= 0
	Local nAtual 	:= 0
	Local nI		:= 0

	nQtdTot	:= 0
	nVlrTot	:= 0
	
	//Busca titulos atraves dos parametros
	cQryDados := " SELECT SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_CLIENTE,SC9.C9_LOJA,SC9.C9_PRODUTO,SC9.C9_ITEM, "
	cQryDados +=  " SC9.C9_ZZDTLIB," + CRLF
	cQryDados +=  " SC9.C9_ZZHRLIB," + CRLF
	cQryDados +=  " SC9.C9_ZZUSLIB," + CRLF
	cQryDados +=  " SC9.C9_ZZDTSEP," + CRLF
	cQryDados +=  " SC9.C9_ZZHRSEP," + CRLF
	cQryDados +=  " SC9.C9_ZZUSSEP," + CRLF
	cQryDados +=  " C5.C5_EMISSAO," + CRLF
	cQryDados +=  " SC9.R_E_C_N_O_ AS C9RECNO, "
	cQryDados +=  " C6.C6_VALOR," + CRLF
	cQryDados +=  " C6.C6_ENTREG," + CRLF
	cQryDados +=  " (SELECT A1.A1_NOME FROM " + RetSqlName("SA1") + " A1 WHERE A1.A1_COD = SC9.C9_CLIENTE) AS NOME" + CRLF
	cQryDados +=  " FROM "+RetSqlName("SC9")+" SC9 "
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC6") + " C6 (NOLOCK) " + CRLF
	cQryDados +=  " ON C6.C6_FILIAL = SC9.C9_FILIAL" + CRLF
	cQryDados +=  " AND C6.C6_NUM = SC9.C9_PEDIDO" + CRLF
	cQryDados +=  " AND C6.C6_ITEM = SC9.C9_ITEM" + CRLF
	cQryDados +=  " AND C6.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC5") + " C5 (NOLOCK) " + CRLF
	cQryDados +=  " ON C5.C5_FILIAL = SC9.C9_FILIAL" + CRLF
	cQryDados +=  " AND C5.C5_NUM = SC9.C9_PEDIDO" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SB1") + " B1 (NOLOCK) " + CRLF
	cQryDados +=  " ON B1.B1_COD = SC9.C9_PRODUTO" + CRLF
	// cQryDados +=  " AND B1.B1_RASTRO <> 'N'" + CRLF
	// cQryDados +=  " AND B1.B1_LOCALIZ = 'N'" + CRLF
	cQryDados +=  " AND B1.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SF4") + " F4 (NOLOCK) " + CRLF
	cQryDados +=  " ON F4.F4_FILIAL = '"+xFilial("SF4")+"'" + CRLF
	cQryDados +=  " AND F4.F4_CODIGO = C6.C6_TES" + CRLF		
	cQryDados +=  " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND " + CRLF
	cQryDados +=  " F4.F4_ESTOQUE = 'S' AND " + CRLF
	cQryDados +=  " SC9.C9_PEDIDO IN ( "
	For nI := 1 To Len(aPedidos)
		cQryDados += "'" + aPedidos[nI][2] + "'"
		If nI < Len(aPedidos)
			cQryDados += ","
		Endif
	Next
	cQryDados += " ) AND " + CRLF
	cQryDados += " SC9.C9_BLCRED = ' '" + CRLF
	cQryDados += " AND SC9.C9_BLEST = ' '" + CRLF
	cQryDados += " AND SC9.C9_ZZFASE = 'B'" + CRLF
	cQryDados += " AND SC9.D_E_L_E_T_ = ' '" 
	cQryDados += " ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_PRODUTO,SC9.C9_CLIENTE,SC9.C9_LOJA "
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Carregando registro: ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		nQtdTot++

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		(cAliasTmp)->C9_FILIAL	:= QRYDADTMP->C9_FILIAL
		(cAliasTmp)->C9_PEDIDO 	:= QRYDADTMP->C9_PEDIDO
		(cAliasTmp)->C9_ITEM 	:= QRYDADTMP->C9_ITEM
		(cAliasTmp)->C9_CLIENTE	:= QRYDADTMP->C9_CLIENTE
		(cAliasTmp)->C9_LOJA	:= QRYDADTMP->C9_LOJA
		(cAliasTmp)->C9_PRODUTO := QRYDADTMP->C9_PRODUTO
		(cAliasTmp)->C6_VALOR 	:= QRYDADTMP->C6_VALOR
		(cAliasTmp)->NOME		:= QRYDADTMP->NOME
		(cAliasTmp)->C5_EMISSAO := QRYDADTMP->C5_EMISSAO
		(cAliasTmp)->C6_ENTREG  := QRYDADTMP->C6_ENTREG
		(cAliasTmp)->C9_ZZUSLIB	:= QRYDADTMP->C9_ZZUSLIB
		(cAliasTmp)->C9_ZZDTLIB	:= QRYDADTMP->C9_ZZDTLIB
		(cAliasTmp)->C9_ZZHRLIB	:= QRYDADTMP->C9_ZZHRLIB
		(cAliasTmp)->C9_ZZUSSEP	:= QRYDADTMP->C9_ZZUSSEP
		(cAliasTmp)->C9_ZZDTSEP	:= QRYDADTMP->C9_ZZDTSEP
		(cAliasTmp)->C9_ZZHRSEP	:= QRYDADTMP->C9_ZZHRSEP
		(cAliasTmp)->C9Recno 	:= QRYDADTMP->C9RECNO	
		(cAliasTmp)->(MsUnlock())
		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

/*---------------------------------------------------------------------*
 | Func:  fCriaCols                                                    |
 | Desc:  Função para criar colunas do browse    				       |
 *---------------------------------------------------------------------*/
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
	aAdd(aEstrut, { 'C9_FILIAL'		, 'Filial'	, 'C', TamSX3("C9_FILIAL")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_PEDIDO'		, 'Pedido'	, 'C', TamSX3("C9_PEDIDO")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_ITEM'		, 'Item'	, 'C', TamSX3("C9_ITEM")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_PRODUTO'	, 'Produto'	, 'C', TamSX3("C9_PRODUTO")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_CLIENTE'	, 'Cliente'	, 'C', TamSX3("C9_CLIENTE")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_LOJA'		, 'Loja'	, 'C', TamSX3("C9_LOJA")[1]	, 0, ''})
	aAdd(aEstrut, { 'NOME'			, 'Nome'	, 'N', TamSX3("A1_NOME")[1]	, 0, ''})
	aAdd(aEstrut, { 'C5_EMISSAO'	, 'Data Emissao'	, 'D', TamSX3("C5_EMISSAO")[1], 0, ''})
	aAdd(aEstrut, { 'C6_ENTREG'	    , 'Data Entrega'	, 'D', TamSX3("C5_EMISSAO")[1], 0, ''})
	aAdd(aEstrut, { 'C6_VALOR'		, 'Valor'	, 'N', TamSX3("C6_VALOR")[1]	,2, ''})
	aAdd(aEstrut, { 'C9_ZZUSLIB'	, 'Usuario Liberacao'	, 'C', TamSX3("C9_ZZUSLIB")[1]		, 0, ''})
	aAdd(aEstrut, { 'C9_ZZDTLIB'	, 'Data Liberacao'	, 'D', TamSX3("C9_ZZDTLIB")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_ZZHRLIB'	, 'Hora Liberacao'	, 'C', TamSX3("C9_ZZHRLIB")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_ZZUSSEP'	, 'Usuario Separacao'	, 'C', TamSX3("C9_ZZUSSEP")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_ZZDTSEP'	, 'Data Separacao'	, 'D', TamSX3("C9_ZZDTSEP")[1]	, 0, ''})
	aAdd(aEstrut, { 'C9_ZZHRSEP'	, 'Hora Separacao'	, 'C', TamSX3("C9_ZZHRSEP")[1]	, 0, ''})

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
 | Func:  fBtnLiber                                                     |
 | Desc:  Função do botão Separar	    				               |
 *---------------------------------------------------------------------*/
User Function fBtnLiber()
	Processa({|| fProcessa(), oDlgMark:End()}, 'Selecionando títulos...')
Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função processa separacao   				               |
 *---------------------------------------------------------------------*/
static function fProcessa()
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc 	:= 0
	Local aMDados   := {}

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

				aAdd(aMDados,{(cAliasTmp)->C9_ZZDTLIB,;	//1
				(cAliasTmp)->C9Recno,;//2
				(cAliasTmp)->C9_PEDIDO,;//3
				(cAliasTmp)->C9_ITEM})				//4
					
			EndIf

		(cAliasTmp)->(DbSkip())
		EndDo

		If Len(aMDados) > 0
			nLibera	:= fLibera(aMDados)
			If nLibera > 0
				FWAlertInfo('Foram Liberados [' + cValToChar(nLibera) + '] pedidos', "Z_BRWLIBE - Mensagem ...")
			Else
				FWAlertInfo('Nao foram Liberados nenhum pedido', "Z_BRWLIBE - Mensagem ...")
			EndIf
		EndIf

	FWRestArea(aArea)

return

/*/{Protheus.doc} fLibera
Função que inicia liberacao de pedidos
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
Static Function fLibera(aMDados)
	Local aArea 	:= GetArea()
	Local nI 		:= 0
	Local nLibera    := 0

	DbSelectArea("SC9")

	For nI := 1 To Len(aMDados)
		If Empty(aMDados[nI][1])
			SC9->(DbGoTo(aMDados[nI][2]))
			RecLock("SC9", .F.)
			SC9->C9_ZZDTLIB := Date()
			SC9->C9_ZZHRLIB := Time()
			SC9->C9_ZZUSLIB := UsrRetName(RetCodUsr())
			SC9->C9_ZZFASE  := "L"
			SC9->(MsUnlock())

			nLibera++
		Else
			FWAlertInfo("O pedido "+AllTrim(aMDados[nI][3])+", item "+AllTrim(aMDados[nI][4])+" ja esta liberado", "Z_BRWLIBE - Mensagem ...")
		EndIf
	Next

	RestArea(aArea)
Return nLibera
