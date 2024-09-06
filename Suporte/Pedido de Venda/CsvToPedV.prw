//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToPedV
Função para gravar dados de CSV para CsvToSB1
@author Vanderlei
@since 26/07/2024
@version 1.0
@type function
/*/
User Function CsvToPedV()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImpCsv() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImpCsv                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function fImpCsv()
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local aCols      := {}
    Local oArquivo
    Local aLinhas
    Local aCabec     := {}
    Local aItens     := {}
    Local aLinha     := {}
    Local aErroAuto  := {}
    Local lOk        := .T.
    
    Private nLinIni := 0
    Private nLinFin := 0
    Private lImport := .F.
    Private lMsErroAuto    := .F.
    Private lAutoErrNoFile := .F.

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            //Verifica linhas iniciais
            LinhasCSV()
            If lImport
                If nLinIni < 1 .OR. nLinFin < 1
                    MSGSTOP("Valores de linha inicial e linha final devem ser maior que 0!", "Define linhas de Importação")
                    Return                  
                EndIf
            Else
                MSGSTOP("Importação cancelada", "Define linhas de Importação")
                Return
            EndIf

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                aCols := {}
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                If nLinhaAtu >= nLinIni .AND. nLinhaAtu <= nLinFin

                    cDoc := GetSxeNum("SC5", "C5_NUM")
                    RollBAckSx8()
                    aCabec   := {}
                    aItens   := {}
                    aLinha   := {}
                    aadd(aCabec, {"C5_NUM"    , cDoc     , Nil})
                    aadd(aCabec, {"C5_TIPO"   , "N"      , Nil})
                    aadd(aCabec, {"C5_CLIENTE", cA1Cod   , Nil})
                    aadd(aCabec, {"C5_LOJACLI", cA1Loja  , Nil})
                    aadd(aCabec, {"C5_LOJAENT", cA1Loja  , Nil})
                    aadd(aCabec, {"C5_CONDPAG", cE4Codigo, Nil})                

                    If cPaisLoc == "PTG"
                        aadd(aCabec, {"C5_DECLEXP", "TESTE", Nil})
                    Endif

                    CONOUT("Passou pelo Array do Cabecalho")                

                    For nX := 1 To 1  //Quantidade de Itens
                        aLinha := {}
                        aadd(aLinha,{"C6_ITEM"   , StrZero(nX,2), Nil})
                        aadd(aLinha,{"C6_PRODUTO", cB1Cod       , Nil})
                        aadd(aLinha,{"C6_QTDVEN" , 1            , Nil})
                        aadd(aLinha,{"C6_PRCVEN" , 1000         , Nil})
                        aadd(aLinha,{"C6_PRUNIT" , 1000         , Nil})
                        aadd(aLinha,{"C6_VALOR"  , 1000         , Nil})
                        aadd(aLinha,{"C6_TES"    , cF4TES       , Nil})
                        aadd(aItens, aLinha)
                        CONOUT("Passou pelo Array dos itens")
                    Next nX

                    CONOUT("Iniciando a gravacao")
                    MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 3, .F.)

                    If !lMsErroAuto
                        nPed := nPed + 1
                        ConOut("Incluido com sucesso! Pedido " + AllTrim(str(nPed)) + ": " + cDoc)
                    Else
                        ConOut("Erro na inclusao!")
                        MOSTRAERRO()
                    EndIf       
                    
                EndIf
            EndDo

        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
 
    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  fStrToNum                                                    |
 | Desc:  Função que transforma string em numero                       |
 *---------------------------------------------------------------------*/
Static Function fStrToNum(_cNum)
    Local nNum  := 0

    If _cNum == "" .OR. AllTrim(_cNum) = "-"
        nNum := 0
    Else
        _cNum   := StrTran(_cNum, '.', '')
        nNum    := VAL(AllTrim(StrTran(_cNum, ',', '.')))
    EndIf

Return nNum

/*---------------------------------------------------------------------*
 | Func:  LinhasCSV                                                    |
 | Desc:  Funcao para escolher linhas de inicio e fim de leitura       |
 *---------------------------------------------------------------------*/
Static Function LinhasCSV()
	Local oSay1
	Local oSay2
	Local btnOut
	Local btnGrv
    Private cFontUti    := "Tahoma"
    Private oFontSubN   := TFont():New(cFontUti, , -20, , .T.)
    Private oFontBtn    := TFont():New(cFontUti, , -14)
	Private oFontSay    := TFont():New(cFontUti, , -12)
	Private oDlg1

	DEFINE MsDialog oDlg1 TITLE "Define Linhas a serem Importadas" STYLE DS_MODALFRAME FROM 0,0 TO 250,500 PIXEL

	@ 10,010 SAY oSay1 PROMPT 'Defina a linha inicial e linha final do CSV' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
    
    @ 40,010 SAY oSay1 PROMPT 'Linha Inicial: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 35,060 MSGET oSay2 VAR nLinIni PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL

    @ 70,010 SAY oSay1 PROMPT 'Linha Final: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 65,060 MSGET oSay3 VAR nLinFin PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL
                 
	@ 100,030 BUTTON btnGrv PROMPT "Importar" SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End(),iif(!lImport,lImport := .T.,lImport := .F.)) OF oDlg1  PIXEL
	@ 100,135 BUTTON btnOut PROMPT "Sair" 	SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL
	
	ACTIVATE DIALOG oDlg1 CENTERED

Return
