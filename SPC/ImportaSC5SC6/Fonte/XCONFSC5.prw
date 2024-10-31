#Include 'Totvs.ch'
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} XCONFSC5
Função para verificarpedidos importados
@author Wagner Neves
@since 11/10/2024
@version 1.0
@type function
/*/
User Function XCONFSC5()

	Private cArqOri 	:= ""
    Private nTxT
    Private cPasta  	:= "c:\temp\"
    Private cFile   	:= cPasta + "ConfImp.txt"
	Private nLinhaAtu  := 0

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
   	Local cQuery        := ""
	Local cAlias 		:= GetNextAlias()
    Local cCpf          := ""
    Local nCPFE         := 0
    Local cCodCli       := ""
    Local cLoja         := ""
    Local aCabec        := {}
    Local aDados        := {}
	Private cRefTran    := ""
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

            //Verifica linhas iniciais
            // LinhasCSV()
            // If lImport
            //     If nLinIni < 1 .OR. nLinFin < 1
            //         MSGSTOP("Valores de linha inicial e linha final devem ser maior que 0!", "Importacao de Pedidos")
            //         Return                  
            //     EndIf
            // Else
            //     MSGSTOP("Importação de pedidos cancelada", "Importacao de Pedidos")
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
                
                If nLinhaAtu = 1
                    aCabec := {aLinha[1], aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6], aLinha[7], aLinha[8], aLinha[9], aLinha[10],;
                               aLinha[11], aLinha[12], aLinha[13], aLinha[14], aLinha[15], aLinha[16], aLinha[17], aLinha[18], aLinha[19], aLinha[20],;
                               aLinha[21], aLinha[22], aLinha[23], aLinha[24], aLinha[25], aLinha[26], aLinha[27], aLinha[28], aLinha[29], aLinha[30],;
                               aLinha[31], aLinha[32], aLinha[33], aLinha[34], aLinha[35], aLinha[36], aLinha[37]}
                EndIf
                
                // If nLinhaAtu >= nLinIni .AND. nLinhaAtu <= nLinFin
				If nLinhaAtu >= 2 .AND. nLinhaAtu <= nTotLinhas
                    cCodCli   := ""
                    cLoja     := ""
					cRefTran  := PadR(aLinha[29], TamSX3("C5_XREFTRA")[1], " ")
                    cCpf      := aLinha[2]

                    cCPF := AllTrim(StrTran(cCPF,".",""))
                    cCPF := AllTrim(StrTran(cCPF,"/","")) 
                    cCPF := AllTrim(StrTran(cCPF,",","")) 
                    cCPF := AllTrim(StrTran(cCPF,"-",""))
                    //Efetua tratamento de CPF
                    nCPFE	:= At('E+', cCPF)
                    If nCPFE > 0
                        nCPFQtd	:= Val(SubStr(cCPF,(nCPFE+2)))  
                        cCPF	:= SubStr(cCPF,1,(nCPFE-1)) 
                        If nCPFQtd >= 11
                            cCPF	:= PADR(cCPF ,14, "0")
                        Else
                            cCPF	:= PADR(cCPF ,11, "0")
                        EndIf 
                    EndIf

                    //Verifica colocar zeros a esquerda no cpf
                    If Len(cCPF) <> 14 .AND. Len(cCPF) <> 11
                        If Len(cCPF) > 11
                            cCPF	:= PADL(cCPF ,14, "0")
                        Else
                            cCPF	:= PADL(cCPF ,11, "0")
                        EndIf
                    EndIf

                    cQuery := " SELECT C5_NUM "
                    cQuery += " FROM "+RetSqlName('SC5')+" SC5 "
                    cQuery += " WHERE C5_XREFTRA  = '"+cRefTran+"'"
                    cQuery += " AND SC5.D_E_L_E_T_ = ' '"
                    cQuery := ChangeQuery(cQuery)
                    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	                (cAlias)->(DbGoTop())

	                If (cAlias)->(EOF())
						If nTxT > -1
           					fWrite(nTxT,"Linha: " + cValToChar(nLinhaAtu) + ", Referencia: " +AllTrim(cRefTran)+ ", CPF: " +cCPF+ ", pedido nao encontrado!" + chr(13)+chr(10) )
    					    aAdd(aDados, {aLinha[1], aLinha[2], aLinha[3], aLinha[4], aLinha[5], aLinha[6], aLinha[7], aLinha[8], aLinha[9], aLinha[10],;
                               aLinha[11], aLinha[12], aLinha[13], aLinha[14], aLinha[15], aLinha[16], aLinha[17], aLinha[18], aLinha[19], aLinha[20],;
                               aLinha[21], aLinha[22], aLinha[23], aLinha[24], aLinha[25], aLinha[26], aLinha[27], aLinha[28], aLinha[29], aLinha[30],;
                               aLinha[31], aLinha[32], aLinha[33], aLinha[34], aLinha[35], aLinha[36], aLinha[37]})
                        EndIf
					EndIf

                    (cAlias)->(DbCloseArea())
					
                EndIf
            EndDo

            DlgToExcel({ {"ARRAY", "Exportacao de dados de um Array", aCabec, aDados} })
        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf
 
        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf
 
Return()

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

	DEFINE MsDialog oDlg1 TITLE "Importa de Pedidos" STYLE DS_MODALFRAME FROM 0,0 TO 250,500 PIXEL

	@ 10,010 SAY oSay1 PROMPT 'Defina a linha inicial e linha final do CSV' SIZE 290,20 COLORS CLR_BLACK FONT oFontSubN OF oDlg1 PIXEL
    
    @ 40,010 SAY oSay1 PROMPT 'Linha Inicial: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 35,060 MSGET oSay2 VAR nLinIni PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL

    @ 70,010 SAY oSay1 PROMPT 'Linha Final: ' SIZE 100,20 COLORS CLR_BLACK FONT oFontBtn OF oDlg1 PIXEL
    @ 65,060 MSGET oSay3 VAR nLinFin PICTURE "@E 999,999" SIZE 050, 20 OF oDlg1 PIXEL
                 
	@ 100,030 BUTTON btnGrv PROMPT "Importar" SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End(),iif(!lImport,lImport := .T.,lImport := .F.)) OF oDlg1  PIXEL
	@ 100,135 BUTTON btnOut PROMPT "Sair" 	SIZE 100, 017 FONT oFontBtn ACTION (oDlg1:End()) OF oDlg1  PIXEL
	
	ACTIVATE DIALOG oDlg1 CENTERED

Return
