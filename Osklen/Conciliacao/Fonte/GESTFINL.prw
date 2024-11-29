#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "TOTVS.CH"

/*/{Protheus.doc} GESTFIN5
	Realiza Estorno conciliação
	@type function
	@version 1.0
	@author Wagner Neves
	@since 10/04/2023
/*/
user function GESTFINL(cTmp)
	MsgRun("Realizando Estorno Conciliacao ...","Aguarde",{|| fPergunta() })
return

Static Function fPergunta()
	Local aPergs   	:= {}
	Local dDataDe  	:= FirstDate(Date())
	Local dDataAt  	:= LastDate(Date())
	Private cModo	:= FwModeAccess("SE5", 1) + FwModeAccess("SE5", 2) + FwModeAccess("SE5", 3)

	//Adicionando os parametros do ParamBox
	aAdd(aPergs, {1, "Data De"	, dDataDe	,  "", ".T.", "", ".T.", 80,  .F.})
	aAdd(aPergs, {1, "Data Até"	, dDataAt	,  "", ".T.", "", ".T.", 80,  .F.})

	//Se a pergunta for confirma, chama a tela
	If ParamBox(aPergs, "Informe os Parametros")
		fMontaTela()
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Desc:  Função para montar tela    							       |
 *---------------------------------------------------------------------*/
Static Function fMontaTela()
	Local aArea         := GetArea()
	Local aCampos 		:= {}
	Local oTempTable 	:= Nil
	Local aColunas 		:= {}
	Local cFontPad    	:= 'Tahoma'
	Local oFontGrid   	:= TFont():New(cFontPad,,-14)
	Local aSeek   		:= {}
	local nInd			as numeric
	local aSE5			:= FwSx3Util():getAllFields("SE5",.F.)
	local aAux			:= {}
	local aFilter		:= {}
	local aBrowse		:= Iif(Right(cModo,2) == "CC",{},{"E5_FILIAL"})
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

	//Adiciona as colunas que serão criadas na temporária
	aAdd(aCampos, { 'OK'		, 'C', 2						, 0})
	aAdd(aCampos, { 'E5_FILIAL'	, 'C', TamSX3("E5_FILIAL")[1]	, 0})
	aAdd(aCampos, { 'E5_DTDISPO', 'D', TamSX3("E5_DTDISPO")[1]	, 0})
	aAdd(aCampos, { 'E5_PREFIXO', 'C', TamSX3("E5_PREFIXO")[1]	, 0})
	aAdd(aCampos, { 'E5_NUMERO'	, 'C', TamSX3("E5_NUMERO")[1]	, 0})
	aAdd(aCampos, { 'E5_PARCELA', 'C', TamSX3("E5_PARCELA")[1]  , 0})
	aAdd(aCampos, { 'E5_VALOR'	, 'N', TamSX3("E5_VALOR")[1]	, 2})
	aAdd(aCampos, { 'E5_CLIFOR'	, 'C', TamSX3("E5_CLIFOR")[1]	, 0})
	aAdd(aCampos, { 'E5_LOJA'	, 'C', TamSX3("E5_LOJA")[1]		, 0})
	aAdd(aCampos, { 'E5_BANCO'	, 'C', TamSX3("E5_BANCO")[1]	, 0})
	aAdd(aCampos, { 'E5_AGENCIA', 'C', TamSX3("E5_AGENCIA")[1]	, 0})
	aAdd(aCampos, { 'E5_CONTA'	, 'C', TamSX3("E5_CONTA")[1]	, 0})
	aAdd(aCampos, { 'E5_SEQCON'	, 'C', TamSX3("E5_SEQCON")[1]	, 0})
	aAdd(aCampos, { 'E1Recno'	, 'N', 20	, 0})
	aAdd(aCampos, { 'E5Recno'	, 'N', 20	, 0})

	//Cria a tabela temporária
	oTempTable:= FWTemporaryTable():New(cAliasTmp)
	oTempTable:SetFields( aCampos )
	oTempTable:AddIndex("1", {"E5_FILIAL", "E5_PREFIXO", "E5_NUMERO", "E5_PARCELA"})
	oTempTable:addIndex("2", {"E1Recno"})
	oTempTable:Create()

	//Popula a tabela temporária
	Processa({|| fPopula()}, 'Processando...')

	//Adiciona as colunas que serão exibidas no FWMarkBrowse
	aColunas := fCriaCols()

	for nInd := 1 to Len(aSE5)
		aAux := FwSx3Util():getFieldStruct(aSE5[nInd])
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

	aEval(Separa(SE5->(IndexKey(7)),"+",.F.),;
			{|x| cTitSeek += Iif(! "FILIAL" $ x .or. Right(cModo,2) != "CC",Trim(GetSx3Cache(x,"X3_TITULO"))+"+","") })

	aEval(Separa(SE5->(IndexKey(7)),"+",.F.),;
			{|x| aAdd(aAux,{"",;
							GetSx3Cache(x,"X3_TIPO"),;
							GetSx3Cache(x,"X3_TAMANHO"),;
							GetSx3Cache(x,"X3_DECIMAL"),;
							AllTrim(GetSx3Cache(x,"X3_TITULO")),;
							AllTrim(GetSx3Cache(x,"X3_PICTURE"))}) })
	aAdd(aSeek,{cTitSeek,aAux})

	DEFINE MSDIALOG oDlgMark TITLE 'Estorno Conciliacao de Titulos' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	
	//Cabecalho
	// @ 002,010 SAY oSay0 PROMPT "Titulos a serem estornados a conciliacao:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	
	//Rodape
	@ 305,010 SAY oSay4 PROMPT "Qtd de Titulos:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,010 MSGET nQtdTot Picture "@E 999,999" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,130 SAY oSay5 PROMPT "Total de Titulos R$:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,130 MSGET nVlrTot Picture "@E 99,999,999.99" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,250 SAY oSay6 PROMPT "Títulos Marcados:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,250 MSGET nMarcado Picture "@E 999,999" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
	@ 305,370 SAY oSay7 PROMPT "Valor Marcado R$:"  SIZE 150,20 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL
    @ 315,370 MSGET nValorMar Picture "@E 99,999,999.99" WHEN .F. Size 080,015 COLORS CLR_BLACK FONT oFontBtn OF oDlgMark PIXEL

	//Dados
	oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1, 250)
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
	oMarkBrowse:SetOwner(oPanGrid)
	oMarkBrowse:SetColumns(aColunas)
	oMarkBrowse:SetAfterMark({|| fMarcado()})
	// oMarkBrowse:SetAllMark({|| oMarkBrowse:AllMark() })
	oMarkBrowse:Activate()
	ACTIVATE MsDialog oDlgMark CENTERED

	//Deleta a temporária e desativa a tela de marcação
	oTempTable:Delete()
	oMarkBrowse:DeActivate()

	RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fMarcado                                                     |
 | Desc:  Função para atualizar valores							       |
 *---------------------------------------------------------------------*/
Static Function fMarcado()
	Local cMarca    	:= oMarkBrowse:Mark()

	If oMarkBrowse:IsMark(cMarca)
		nMarcado++
		nValorMar	+= (cAliasTmp)->E5_VALOR
	Else
		nMarcado--
		nValorMar	-= (cAliasTmp)->E5_VALOR
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  MenuDef                                                      |
 | Desc:  Função para botoes do menu							       |
 *---------------------------------------------------------------------*/
Static Function MenuDef()
	Local aRotina := {}

	//Criação das opções do menu
	ADD OPTION aRotina TITLE 'Voltar'  ACTION 'U_fFinlVolt'     OPERATION 6 ACCESS 0	
	ADD OPTION aRotina TITLE 'Estornar Conciliacao'  ACTION 'U_fBtnEstC'     OPERATION 3 ACCESS 0

Return aRotina

/*---------------------------------------------------------------------*
 | Func:  fPopula                                                      |
 | Desc:  Função para popular tabela temporaria					       |
 *---------------------------------------------------------------------*/
Static Function fPopula()
	Local cQryDados := ''
	Local nTotal 	:= 0
	Local nAtual 	:= 0

	nQtdTot	:= 0
	nVlrTot	:= 0
	
	//Busca titulos atraves dos parametros
	cQryDados := " SELECT E5_SEQCON,E5_RECPAG,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_VALOR,E5_DTDISPO,E5_CLIFOR,E5_LOJA,E5_FILIAL,E5_BANCO,E5_AGENCIA,E5_CONTA,"
	cQryDados += " SE1.E1_SALDO, SE5.R_E_C_N_O_ AS E5RECNO, SE1.R_E_C_N_O_ AS E1RECNO "
	cQryDados += " FROM "+RetSqlName("SE5")+" SE5 "
	cQryDados += " INNER JOIN "+RetSqlName("SE1")+" SE1 ON SE1.E1_PREFIXO = SE5.E5_PREFIXO AND SE1.E1_NUM = SE5.E5_NUMERO AND SE1.E1_PARCELA = SE5.E5_PARCELA AND SE1.E1_CLIENTE = SE5.E5_CLIFOR AND SE1.E1_LOJA = SE5.E5_LOJA AND SE1.D_E_L_E_T_ = ' '"
	cQryDados += " WHERE " + CRLF
	cQryDados += " E5_DTDISPO BETWEEN '"+dtoS(MV_PAR01)+"' AND '"+dtoS(MV_PAR02)+"' AND " + CRLF
	cQryDados += " E5_RECONC = 'x' AND " + CRLF
	cQryDados += " E5_RECPAG = 'R' AND " + CRLF
	cQryDados += " E5_DTCANBX = ' ' AND " + CRLF
	cQryDados += " E1_SALDO = 0 AND " + CRLF
	cQryDados += " SE5.D_E_L_E_T_ = ' '" 
	cQryDados += " ORDER BY E5_DTDISPO,E5_FILIAL,E5_PREFIXO,E5_NUMERO "
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
		nVlrTot	+= QRYDADTMP->E5_VALOR

		RecLock(cAliasTmp, .T.)
		(cAliasTmp)->OK := Space(2)
		(cAliasTmp)->E5_FILIAL	:= QRYDADTMP->E5_FILIAL
		(cAliasTmp)->E5_PREFIXO := QRYDADTMP->E5_PREFIXO
		(cAliasTmp)->E5_NUMERO	:= QRYDADTMP->E5_NUMERO
		(cAliasTmp)->E5_PARCELA	:= QRYDADTMP->E5_PARCELA
		(cAliasTmp)->E5_VALOR 	:= QRYDADTMP->E5_VALOR
		(cAliasTmp)->E5_DTDISPO := QRYDADTMP->E5_DTDISPO
		(cAliasTmp)->E5_CLIFOR	:= QRYDADTMP->E5_CLIFOR
		(cAliasTmp)->E5_LOJA 	:= QRYDADTMP->E5_LOJA
		(cAliasTmp)->E5_BANCO	:= QRYDADTMP->E5_BANCO
		(cAliasTmp)->E5_AGENCIA	:= QRYDADTMP->E5_AGENCIA
		(cAliasTmp)->E5_CONTA	:= QRYDADTMP->E5_CONTA
		(cAliasTmp)->E5_SEQCON	:= QRYDADTMP->E5_SEQCON
		(cAliasTmp)->E1Recno 	:= QRYDADTMP->E1RECNO	
		(cAliasTmp)->E5Recno 	:= QRYDADTMP->E5RECNO	
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
	aAdd(aEstrut, { 'E5_FILIAL'	, 'Filial'	, 'C', TamSX3("E5_FILIAL")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_PREFIXO', 'Prefixo'	, 'C', TamSX3("E5_PREFIXO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_NUMERO'	, 'Numero'	, 'C', TamSX3("E5_NUMERO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_PARCELA', 'Parcela'	, 'C', TamSX3("E5_PARCELA")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_VALOR'	, 'Valor'	, 'N', TamSX3("E5_VALOR")[1]	, 2, '@E 9,999,999,999,999.99'})
	aAdd(aEstrut, { 'E5_DTDISPO', 'Data Dispon'	, 'D', 10, 0, ''})
	aAdd(aEstrut, { 'E5_CLIFOR'	, 'Cliente'	, 'C', TamSX3("E5_CLIFOR")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_LOJA'	, 'Loja'	, 'C', TamSX3("E5_LOJA")[1]		, 0, ''})
	aAdd(aEstrut, { 'E5_BANCO'	, 'Banco'	, 'C', TamSX3("E5_BANCO")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_AGENCIA', 'Agencia'	, 'C', TamSX3("E5_AGENCIA")[1]	, 0, ''})
	aAdd(aEstrut, { 'E5_CONTA'	, 'Conta'	, 'C', TamSX3("E5_CONTA")[1]	, 0, ''})

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
 | Func:  fFinlVolt                                                    |
 | Desc:  Função do botão voltar    		    				       |
 *---------------------------------------------------------------------*/
User Function fFinlVolt()
	(eval({||oDlgMark:End()}))	
Return

/*---------------------------------------------------------------------*
 | Func:  fBtnEstC                                                     |
 | Desc:  Função do botão estornar conciliar			               |
 *---------------------------------------------------------------------*/
User Function fBtnEstC()
	Processa({|| fProcessa(), oDlgMark:End()}, 'Selecionando títulos...')
Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função processa conciliacao   				               |
 *---------------------------------------------------------------------*/
static function fProcessa()
	Local aArea     := FWGetArea()
	local nOpc as numeric
	Local cMarca    := oMarkBrowse:Mark()
	Local nAtual    := 0
	Local nTotal    := 0
	Local nTotMarc 	:= 0

	//Define o tamanho da régua
	DbSelectArea(cAliasTmp)
	(cAliasTmp)->(DbGoTop())
	Count To nTotal
	ProcRegua(nTotal)

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Estonar Conciliacao Marcados","Cancelar"},2)

	if nOpc == 2
		return
	endif

	if nOpc == 1
		//Percorrendo os registros
		(cAliasTmp)->(DbGoTop())
		While ! (cAliasTmp)->(EoF())
			nAtual++
			IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')

			//Caso esteja marcado
			If oMarkBrowse:IsMark(cMarca)
				nTotMarc++

				U_XConcilia((cAliasTmp)->E1Recno, (cAliasTmp)->E5Recno, .T., (cAliasTmp)->E5_SEQCON)
								
			EndIf

		(cAliasTmp)->(DbSkip())
		EndDo
	EndIf

	//Mostra a mensagem de término e caso queria fechar a dialog, basta usar o método End()
	FWAlertInfo('Foram estornados a conciliacao de [' + cValToChar(nTotMarc) + '] titulos', 'Atenção')
	//oDlgMark:End()

	FWRestArea(aArea)

return
