//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"
  
/*/{Protheus.doc} User Function zVid0046
Teste MarkBrowse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
User Function zVid0046()
    Local aArea := FWGetArea()
    Local aPergs   := {}
    Local xPar0 := Space(6)
    Local xPar1 := Space(6)
      
    //Adicionando os parametros do ParamBox
    aAdd(aPergs, {1, "Pedido De", xPar0,  "", ".T.", "SC7", ".T.", 80,  .F.})
    aAdd(aPergs, {1, "Pedido At�", xPar1,  "", ".T.", "SC7", ".T.", 80,  .T.})
      
    //Se a pergunta for confirma, chama a tela
    If ParamBox(aPergs, "Informe os parametros")
        fMontaTela()
    EndIf
      
    FWRestArea(aArea)
Return
  
/*/{Protheus.doc} fMontaTela
Monta a tela com a marca��o de dados
@author Daniel Atilio
@since 20/07/2022
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
       
    //Adiciona as colunas que ser�o criadas na tempor�ria
    aAdd(aCampos, { 'OK', 'C', 2, 0}) //Flag para marca��o
    aAdd(aCampos, { 'C7_FILIAL', 'C', 2, 0}) //Filial
    aAdd(aCampos, { 'C7_NUM', 'C', 6, 0}) //Pedido
    aAdd(aCampos, { 'C7_FORNECE', 'C', 6, 0}) //Fornecedor
    aAdd(aCampos, { 'C7_PRODUTO', 'C', 15, 0}) //Produto
    aAdd(aCampos, { 'C7_EMISSAO', 'D', 8, 0}) //Data Emiss�o
  
    //Cria a tabela tempor�ria
    oTempTable:= FWTemporaryTable():New(cAliasTmp)
    oTempTable:SetFields( aCampos )
    oTempTable:AddIndex("1", {"C7_FILIAL","C7_NUM"} )
    oTempTable:Create()  
  
    //Popula a tabela tempor�ria
    Processa({|| fPopula()}, 'Processando...')
  
    //Adiciona as colunas que ser�o exibidas no FWMarkBrowse
    aColunas := fCriaCols()
  
    aSeek := {}
    cCampoAux := "C7_NUM"
    aAdd(aSeek,{GetSX3Cache(cCampoAux, "X3_TITULO"), {{"", GetSX3Cache(cCampoAux, "X3_TIPO"), GetSX3Cache(cCampoAux, "X3_TAMANHO"), GetSX3Cache(cCampoAux, "X3_DECIMAL"), AllTrim(GetSX3Cache(cCampoAux, "X3_TITULO")), AllTrim(GetSX3Cache(cCampoAux, "X3_PICTURE"))}} } )
       
    //Criando a janela
    DEFINE MSDIALOG oDlgMark TITLE 'Tela para Marca��o de dados - Autumn Code Maker' FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
        //Dados
        oPanGrid := tPanel():New(001, 001, '', oDlgMark, , , , RGB(000,000,000), RGB(254,254,254), (nJanLarg/2)-1,     (nJanAltu/2 - 1))
        oMarkBrowse:= FWMarkBrowse():New()
        oMarkBrowse:SetDescription("Pedidos de Compra") //Titulo da Janela
        oMarkBrowse:SetAlias(cAliasTmp)
        oMarkBrowse:oBrowse:SetDBFFilter(.T.)
        oMarkBrowse:oBrowse:SetUseFilter(.F.) //Habilita a utiliza��o do filtro no Browse
        oMarkBrowse:oBrowse:SetFixedBrowse(.T.)
        oMarkBrowse:SetWalkThru(.F.) //Habilita a utiliza��o da funcionalidade Walk-Thru no Browse
        oMarkBrowse:SetAmbiente(.T.) //Habilita a utiliza��o da funcionalidade Ambiente no Browse
        oMarkBrowse:SetTemporary(.T.) //Indica que o Browse utiliza tabela tempor�ria
        oMarkBrowse:oBrowse:SetSeek(.T.,aSeek) //Habilita a utiliza��o da pesquisa de registros no Browse
        oMarkBrowse:oBrowse:SetFilterDefault("") //Indica o filtro padr�o do Browse
        oMarkBrowse:SetFieldMark('OK')
        oMarkBrowse:SetFontBrowse(oFontGrid)
        oMarkBrowse:SetOwner(oPanGrid)
        oMarkBrowse:SetColumns(aColunas)
        oMarkBrowse:Activate()
    ACTIVATE MsDialog oDlgMark CENTERED
  
    //Deleta a tempor�ria e desativa a tela de marca��o
    oTempTable:Delete()
    oMarkBrowse:DeActivate()
      
    RestArea(aArea)
Return
  
/*/{Protheus.doc} MenuDef
Bot�es usados no Browse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function MenuDef()
    Local aRotina := {}
       
    //Cria��o das op��es
    ADD OPTION aRotina TITLE 'Continuar'  ACTION 'u_zVid46Ok'     OPERATION 2 ACCESS 0
Return aRotina
  
/*/{Protheus.doc} fPopula
Executa a query SQL e popula essa informa��o na tabela tempor�ria usada no browse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function fPopula()
    Local cQryDados := ''
    Local nTotal := 0
    Local nAtual := 0
  
    //Monta a consulta
    cQryDados += "SELECT C7_FILIAL, C7_NUM, C7_FORNECE, C7_PRODUTO, C7_EMISSAO "        + CRLF
    cQryDados += "FROM SC7990 SC7 "        + CRLF
    cQryDados += "WHERE C7_NUM >= '" + MV_PAR01 + "' AND C7_NUM <= '" + MV_PAR02 + "' AND SC7.D_E_L_E_T_ = ' '"        + CRLF
    PLSQuery(cQryDados, 'QRYDADTMP')
  
    //Definindo o tamanho da r�gua
    DbSelectArea('QRYDADTMP')
    Count to nTotal
    ProcRegua(nTotal)
    QRYDADTMP->(DbGoTop())
  
    //Enquanto houver registros, adiciona na tempor�ria
    While ! QRYDADTMP->(EoF())
        nAtual++
        IncProc('Analisando registro ' + cValToChar(nAtual) + ' de ' + cValToChar(nTotal) + '...')
  
        RecLock(cAliasTmp, .T.)
            (cAliasTmp)->OK := Space(2)
            (cAliasTmp)->C7_FILIAL := QRYDADTMP->C7_FILIAL
            (cAliasTmp)->C7_NUM := QRYDADTMP->C7_NUM
            (cAliasTmp)->C7_FORNECE := QRYDADTMP->C7_FORNECE
            (cAliasTmp)->C7_PRODUTO := QRYDADTMP->C7_PRODUTO
            (cAliasTmp)->C7_EMISSAO := QRYDADTMP->C7_EMISSAO
        (cAliasTmp)->(MsUnlock())
  
        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())
    (cAliasTmp)->(DbGoTop())
Return
  
/*/{Protheus.doc} fCriaCols
Fun��o que gera as colunas usadas no browse (similar ao antigo aHeader)
@author Daniel Atilio
@since 20/07/2022
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
      
    //Adicionando campos que ser�o mostrados na tela
    //[1] - Campo da Temporaria
    //[2] - Titulo
    //[3] - Tipo
    //[4] - Tamanho
    //[5] - Decimais
    //[6] - M�scara
    aAdd(aEstrut, { 'C7_FILIAL', 'Filial', 'C', 2, 0, ''})
    aAdd(aEstrut, { 'C7_NUM', 'Pedido', 'C', 6, 0, ''})
    aAdd(aEstrut, { 'C7_FORNECE', 'Fornecedor', 'C', 6, 0, ''})
    aAdd(aEstrut, { 'C7_PRODUTO', 'Produto', 'C', 15, 0, ''})
    aAdd(aEstrut, { 'C7_EMISSAO', 'Data Emiss�o', 'D', 8, 0, ''})
  
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
  
/*/{Protheus.doc} User Function zVid46Ok
Fun��o acionada pelo bot�o continuar da rotina
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
User Function zVid46Ok()
    Processa({|| fProcessa()}, 'Processando...')
Return
  
/*/{Protheus.doc} fProcessa
Fun��o que percorre os registros da tela
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
  
Static Function fProcessa()
    Local aArea     := FWGetArea()
    Local cMarca    := oMarkBrowse:Mark()
    Local nAtual    := 0
    Local nTotal    := 0
    Local nTotMarc := 0
      
    //Define o tamanho da r�gua
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
              
            /*
            //Aqui dentro voc� pode fazer o seu processamento
            Alert((cAliasTmp)->C7_FILIAL)
            */
        EndIf
           
        (cAliasTmp)->(DbSkip())
    EndDo
      
    //Mostra a mensagem de t�rmino e caso queria fechar a dialog, basta usar o m�todo End()
    FWAlertInfo('Dos [' + cValToChar(nTotal) + '] registros, foram processados [' + cValToChar(nTotMarc) + '] registros', 'Aten��o')
    //oDlgMark:End()
  
    FWRestArea(aArea)
Return
