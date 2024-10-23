#Include 'Totvs.ch'
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XATUESTR
Função para atualizar estrutura atraves de um csv
@author Wagner Neves
@since 19/11/2024
@version 1.0
@type function
/*/
User Function XATUESTR()

	Private cArqOri 	:= ""
    Private nTxT
    Private cPasta  	:= "c:\temp\"
    Private cFile   	:= cPasta + "ErroEst.txt"
	Private nLinhaAtu   := 0

    If file( cFile )
		ferase( cFile )
	Endif

    nTxT := fCreate(cFile)
    If nTxT == -1
        MsgStop("Falha ao criar arquivo de log - erro "+str(ferror()))
    Endif

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImpCsv() }, "Importando pedidos...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

    If nTxT > -1
        fClose(nTxT)
    EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fImpCsv                                                      |
 | Desc:  Função para extrair dados do arquivo csv					   |
 *---------------------------------------------------------------------*/
Static Function fImpCsv()
    Local nTotLinhas    := 0
    Local cLinAtu       := ""
    Local aLinha        := {}
    Local aCols         := {}
    Local oArquivo
    Local aLinhas
	Local nQtdBase     	:= 0
	Local cRevAtu       := ""
	Local aCab          := {}
	Local aItem         := {}
	Local nAtualiz      := 0
	Local nLido         := 0
	Local cProduto    	:= "" 	
	Local cCmpRet     	:= ""
	Local cCmpInc     	:= ""
	Local nQtdInc     	:= ""
    
	Private nLinIni     := 0
    Private nLinFin     := 0
    Private lImport     := .F.

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

            //Verifica linhas a serem importadas
            // LinhasCSV()
            // If lImport
            //     If nLinIni < 1 .OR. nLinFin < 1
            //         MSGSTOP("Valores de linha inicial e linha final devem ser maior que 0!", "Atualiza Estrutura")
            //         Return                  
            //     EndIf
            // Else
            //     MSGSTOP("Atualizacao cancelada", "Atualiza Estrutura")
            //     Return
            // EndIf

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                aCols := {}
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Pedido linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                If nLinhaAtu >= 2 .AND. nLinhaAtu <= nTotLinhas
					nLido++

					//Extrai dados das colunas
					cProduto    := PadR(AllTrim(aLinha[1]), TamSx3("G1_COD")[1], " ") 
					cCmpRet     := PadR(AllTrim(aLinha[2]), TamSx3("G1_COMP")[1], " ") 
					cCmpInc     := PadR(AllTrim(aLinha[3]), TamSx3("G1_COMP")[1], " ") 
                    If aLinha[4] == ""
                        nQtdInc := 0
                    Else
                        aLinha[4] 	:= StrTran(aLinha[4], '.', '')
                        nQtdInc		:= VAL(AllTrim(StrTran(aLinha[4], ',', '.')))
                    EndIf

					//Busca produto no cadastro
					SB1->(dbSetOrder(1))
					If SB1->(dbSeek( fwxFilial('SB1') + cProduto ))

						nQtdBase 	:= RetFldProd(cProduto,"B1_QBP") // quantidade base
						cRevAtu		:= SB1->B1_REVATU // revisão atual

						aCab := {}
						aAdd( aCab, {"G1_COD"   , cProduto	, NIL} ) //Código do produto PAI.
						aAdd( aCab, {"G1_QUANT" , nQtdBase  , NIL} ) //Quantidade base do produto PAI.
						aAdd( aCab, {"ATUREVSB1", "S"       , NIL} ) //A variável ATUREVSB1 é utilizada para gerar nova revisão quando MV_REVAUT=.F.
						aAdd( aCab, {"NIVALT"   , "S"       , NIL} ) //A variável NIVALT é utilizada para recalcular ou não os níveis da estrutura.
						aAdd( aCab, {"AUTRECPAI", "   "     , NIL} )

						aLinhas := {}
						dbSelectArea('SG1')
						SG1->(dbSetOrder(1))
						If SG1->(dbSeek( fwxFilial('SG1') + SB1->B1_COD ))

							while !SG1->(EOF()) .and. ((SG1->G1_FILIAL == fwxFilial('SG1')) .and. (SG1->G1_COD == SB1->B1_COD ))

								if ((cRevAtu >= SG1->G1_REVINI) .And. (cRevAtu <= SG1->G1_REVFIM))
									//Encontra produto a deletar na estrutura
									If SG1->G1_COMP = cCmpRet
										//Deleta linha
										aItem := {}
										aadd( aItem, { "G1_COD"    , SG1->G1_COD            , NIL })
										aadd( aItem, { "G1_COMP"   , SG1->G1_COMP           , NIL })
										aadd( aItem, { "G1_TRT"    , SG1->G1_TRT            , NIL })
										aadd( aItem, { "G1_QUANT"  , SG1->G1_QUANT			, NIL })
										aadd( aItem, { "G1_PERDA"  , SG1->G1_PERDA			, NIL })
										aadd( aItem, { "G1_INI"    , SG1->G1_INI			, NIL })
										aadd( aItem, { "G1_FIM"    , SG1->G1_FIM			, NIL })
										aadd( aItem, { "LINPOS"    , "G1_COD+G1_COMP+G1_TRT", SG1->G1_COD, SG1->G1_COMP, SG1->G1_TRT   } )
										aadd( aItem, { "AUTDELETA" , "S"                    , Nil                                      } )							

										aadd( aLinhas, aItem )

										//Adiciona item
										//Verifica quantidade
										If nQtdInc = 0
											nQtdInc := SG1->G1_QUANT
										EndIf
										aItem := {}
										aadd( aItem, { "G1_COD"    , SG1->G1_COD            ,NIL })
										aadd( aItem, { "G1_COMP"   , cCmpInc                ,NIL })
										aadd( aItem, { "G1_TRT"    , SG1->G1_TRT            ,NIL })
										aadd( aItem, { "G1_QUANT"  , nQtdInc        		,NIL })
										aadd( aItem, { "G1_PERDA"  , 0          			,NIL })
										aadd( aItem, { "G1_INI"    , dDataBase       		,NIL })
										aadd( aItem, { "G1_FIM"    , CTOD("31/12/49")       ,NIL })

										aadd( aLinhas, aItem )
									EndIf
								endif

								SG1->(dbSkip())
							enddo
						
							lMsErroAuto		:= .F.
							lMsHelpAuto     := .F.

							MSExecAuto( { |x,y,z| PCPA200(x,y,z)}, aCab, aLinhas, 4 ) //alteracao
							
							If lMsErroAuto
								If nTxT > -1
									fWrite(nTxT,"Erro na Linha: " + cValToChar(nLinhaAtu) + ", Falha no execauto de alteracao!" + chr(13)+chr(10) )
								EndIf
							Else
							    nAtualiz++
							EndIf

						Else
							If nTxT > -1
								fWrite(nTxT,"Erro na Linha: " + cValToChar(nLinhaAtu) + ", Produto: " + cProduto + " nao possui estrutura!" + chr(13)+chr(10) )
							EndIf
						Endif
					Else
						If nTxT > -1
           					fWrite(nTxT,"Erro na Linha: " + cValToChar(nLinhaAtu) + ", Produto: " + cProduto + " nao encontrado no cadastro de produto!" + chr(13)+chr(10) )
    					EndIf
					Endif
                EndIf
            EndDo
			MsgInfo("Lidas: " + cValToChar(nLido) + " linhas e Atualizadas: " + cValToChar(nAtualiz) + " estruturas!")
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
 
Return

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

	DEFINE MsDialog oDlg1 TITLE "Importa planilha para atualizacao de estrutura" STYLE DS_MODALFRAME FROM 0,0 TO 250,500 PIXEL

	@ 10,010 SAY oSay1 PROMPT 'Defina a linha inicial e linha final do CSV' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
    
    @ 40,010 SAY oSay1 PROMPT 'Linha Inicial: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 35,060 MSGET oSay2 VAR nLinIni PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL

    @ 70,010 SAY oSay1 PROMPT 'Linha Final: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 65,060 MSGET oSay3 VAR nLinFin PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL
                 
	@ 100,030 BUTTON btnGrv PROMPT "Importar" SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End(),iif(!lImport,lImport := .T.,lImport := .F.)) OF oDlg1  PIXEL
	@ 100,135 BUTTON btnOut PROMPT "Sair" 	SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL
	
	ACTIVATE DIALOG oDlg1 CENTERED

Return
