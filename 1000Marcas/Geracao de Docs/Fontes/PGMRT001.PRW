#include "Protheus.ch"
#include "FWMVCDEF.CH"

/*/{Protheus.doc} PGMRT001
Função de geração de tela de Envio Manual de WorkFlows
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/
User Function PGMRT001()
	Local aArea 	:= FWGetArea()
	Private lVoltar := .F.

	//Chama janela de pergunta
	fPergunta()

	FWRestArea(aArea)

Return

Static Function fPergunta()
	Local aPergs   := {}
	Local CClient := Space(TamSX3('A1_COD')[01])
	Local CLojaDe := Space(TamSX3('A1_LOJA')[01])
	//Local CLojaAt := Space(TamSX3('A1_LOJA')[01])
	Local dDataDe  := FirstDate(Date())
	Local dDataAt  := LastDate(Date())

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Codigo Cliente", CClient,  "", "", "SA1", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Loja", CLojaDe,  "", "", "", ".T.", 10,  .F.})
//	aAdd(aPergs, {1, "Até a Loja", CLojaAt,  "", "", "", ".T.", 10,  .F.})
	aAdd(aPergs, {1, "Vencimento De",  dDataDe,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Vencimento Até", dDataAt,  "", ".T.", "", ".T.", 80,  .F.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, "Informe os Parametros")
		fMontaTela()
	EndIf

Return

Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos := {}
	Local oTempTable := Nil
	Local aColunas := {}
	Local cFontPad    := 'Tahoma'
	Local oFontGrid   := TFont():New(cFontPad,,-14)
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
	aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marcação
	//aAdd(aCampos, { 'E1_FILIAL', 'C', 2, 0})//Filial
	aAdd(aCampos, { 'E1_PREFIXO', 'C', 3, 0})//Prefixo
	aAdd(aCampos, { 'E1_NUM', 'C', 15, 0}) //Num. Titulo
	aAdd(aCampos, { 'E1_PARCELA', 'C', 2, 0}) //Parcela
	aAdd(aCampos, { 'E1_CLIENTE', 'C', 6, 0}) //Cliente
	aAdd(aCampos, { 'E1_LOJA', 'C', 2, 0}) //Loja
	aAdd(aCampos, { 'E1_NOMCLI', 'C', 20, 0}) //Nome Cliente
	aAdd(aCampos, { 'E1_VENCREA', 'D', 10, 0}) //Venc. Real
	aAdd(aCampos, { 'E1_VALOR', 'N', 16, 4}) //Val. Titulo
	aAdd(aCampos, { 'E1_SALDO', 'N', 16, 4}) //Saldo Titulo
	aAdd(aCampos, { 'E1_HIST', 'C', 50, 0}) //Hist. Título

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	//Criando a janela
	DEFINE MSDIALOG oDlgMark TITLE 'Envio Manual de WorkFlows' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
	oMarkBrowse := FWMarkBrowse():New()
	oMarkBrowse:SetAlias(cAliasTmp)
	oMarkBrowse:SetDescription('Titulos a Receber')
	oMarkBrowse:DisableFilter()
	oMarkBrowse:DisableConfig()
	oMarkBrowse:DisableSeek()
	oMarkBrowse:DisableSaveConfig()
	oMarkBrowse:SetFontBrowse(oFontGrid)
	oMarkBrowse:SetFieldMark('OK')
	oMarkBrowse:SetTemporary(.T.)
	oMarkBrowse:SetColumns(aColunas)
	//oMarkBrowse:AllMark()
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	//Verifica se é para voltar a pergunta ou fechar
	If lVoltar
		lVoltar	:= .F.
		fPergunta()
	EndIf

	RestArea(aArea)
Return

Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções
	ADD OPTION aRotina TITLE 'Envia WorkFlow'  ACTION 'U_ENVWKFLW'     OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Voltar'  ACTION 'U_ENVWKFL'     OPERATION 3 ACCESS 0

Return aRotina

Static Function fPopula()
	Local cQryDados := ''
	Local nTotal := 0
	Local nAtual := 0
	Local cDataDe := Dtos(MV_PAR03)
	Local cDataAt := Dtos(MV_PAR04)

	//Monta a consulta
	cQryDados += "SELECT SE1.E1_FILIAL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_NOMCLI, SE1.E1_VENCREA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_HIST " + CRLF
	cQryDados += " FROM "+RetSQLName('SE1')+" SE1 " + CRLF
	cQryDados += " WHERE SE1.E1_FILIAL = '"+cFilAnt+"'" + CRLF
	cQryDados += " AND SE1.E1_CLIENTE = '" + MV_PAR01 + "'" + CRLF
	cQryDados += " AND SE1.E1_LOJA = '" + MV_PAR02 + "' " + CRLF
	//cQryDados += " AND SE1.E1_LOJA <= '" + MV_PAR03 + "' " + CRLF
	cQryDados += " AND SE1.E1_VENCREA >= '" + cDataDe + "'" + CRLF
	cQryDados += " AND SE1.E1_VENCREA <= '" + cDataAt + "'" + CRLF
	// cQryDados += " AND SE1.E1_SALDO > 0 " + CRLF
	cQryDados += " ORDER BY SE1.E1_VENCREA" + CRLF
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	ProcRegua(nTotal)
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While ! QRYDADTMP->(EoF())
		nAtual++
		IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		//(cAliasTmp)->E1_FILIAL := QRYDADTMP->E1_FILIAL
		(cAliasTmp)->E1_PREFIXO := QRYDADTMP->E1_PREFIXO
		(cAliasTmp)->E1_NUM := QRYDADTMP->E1_NUM
		(cAliasTmp)->E1_PARCELA := QRYDADTMP->E1_PARCELA
		(cAliasTmp)->E1_CLIENTE := QRYDADTMP->E1_CLIENTE
		(cAliasTmp)->E1_LOJA := QRYDADTMP->E1_LOJA
		(cAliasTmp)->E1_NOMCLI := QRYDADTMP->E1_NOMCLI
		(cAliasTmp)->E1_VENCREA := QRYDADTMP->E1_VENCREA
		(cAliasTmp)->E1_VALOR := QRYDADTMP->E1_VALOR
		(cAliasTmp)->E1_SALDO := QRYDADTMP->E1_SALDO
		(cAliasTmp)->E1_HIST := QRYDADTMP->E1_HIST
		(cAliasTmp)->(MsUnlock())

		QRYDADTMP->(DbSkip())
	EndDo
	QRYDADTMP->(DbCloseArea())
	(cAliasTmp)->(DbGoTop())
Return

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

	//aAdd(aEstrut, { 'E1_FILIAL', 'Filial', 'C', 2, 0, ''})
	aAdd(aEstrut, { 'E1_PREFIXO', 'Prefixo', 'C', 3, 0, ''})
	aAdd(aEstrut, { 'E1_NUM', 'N° Titulo', 'C', 15, 0, ''})
	aAdd(aEstrut, { 'E1_PARCELA', 'Parcela', 'C', 2, 0, ''})
	aAdd(aEstrut, { 'E1_CLIENTE', 'Cód. Cliente', 'C', 6, 0, ''})
	aAdd(aEstrut, { 'E1_LOJA', 'Loja', 'C', 2, 0, ''})
	aAdd(aEstrut, { 'E1_NOMCLI', 'Nome do Cliente', 'C', 20, 0, ''})
	aAdd(aEstrut, { 'E1_VENCREA', 'Venc. Real Titulo', 'D', 10, 0, ''})
	aAdd(aEstrut, { 'E1_VALOR', 'Vlr. Titulo', 'N', 16, 4, '@E 99,999,999,999.99'})
	aAdd(aEstrut, { 'E1_SALDO', 'Saldo Titulo', 'N', 16, 4, '@E 99,999,999,999.99'})
	aAdd(aEstrut, { 'E1_HIST', 'Hist. Titulo', 'C', 50, 0, ''})

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

User Function ENVWKFL()
	(eval({||oDlgMark:End(),iif(!lVoltar,lVoltar := .T.,lVoltar := .F.)}))	
Return

User Function ENVWKFLW()
	Processa({|| fProcessa()}, 'Selecionando Titulos...')
Return

Static Function fProcessa()
	Local aArea     := FWGetArea()
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc := 0

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

			U_PGMRT004(XFilial("SE1"), (cAliasTmp)->E1_NUM, (cAliasTmp)->E1_PREFIXO)

		EndIf

		(cAliasTmp)->(DbSkip())
	EndDo

	//Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
	FWAlertInfo('Dos [' + cValToChar(nTotal) + '] registros, foram processados [' + cValToChar(nTotMarc) + '] registros', 'Atenção')
	//oDlgMark:End()

	FWRestArea(aArea)

Return
