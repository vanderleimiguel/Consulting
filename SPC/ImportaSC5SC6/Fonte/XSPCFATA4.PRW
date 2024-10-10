#Include 'Totvs.ch'
#Include "TopConn.ch"
#INCLUDE "PROTHEUS.CH"

/***********************************************************************
--| INFORMAÇÕES PARA DEPLOY EM PRODUÇÃO |-- 
	
-> Criar índice na SE1 para o campo E1_VEND1;
-> Criar campo E1_XIDTRAN na SE1 para armazenar os códigos de transação da Loja Virtual;
-> Criar campo E2_XIDTRAN na SE2 para armazenar os códigos de transação da Loja Virtual na gravação das taxas;
-> Criar o parâmetro LV_TESPF para gravar a TES de Pessoa Física no Pedido de Vendas;
-> Criar o parâmetro LV_TESPJ para gravar a TES de Pessoa Jurídica no Pedido de Vendas;
-> Criar o parâmetro LV_VEND para gravar o código do vendedor Pag Seguro da Loja Virtual no Pedido de Vendas;
-> Criar o parâmetro LV_SERIE para gravar a série da nota fiscal;
-> Criar o parâmetro LV_FORNEC para gravar o código do fornecedor que será gravado no título de taxa no contas a pagar;
-> Criar o parâmetro LV_PREFIX para gravar o Prefixo que será gravado no título de taxa no contas a pagar;
-> Criar o parâmetro LV_NATUR para gravar a natureza que será gravada no título de taxa no contas a pagar;
-> Criar o parâmetro LV_CCUSTO para gravar o centro de custo que será gravado no título de taxa no contas a pagar;
-> Criar o parâmetro LV_COND1 para gravar o código da condição de pagamento de uma única parcela no pedido de vendas;
-> Criar o parâmetro LV_COND2 para gravar o código da condição de pagamento de duas parcelas no pedido de vendas;
-> Criar o parâmetro LV_COND3 para gravar o código da condição de pagamento de três parcelas no pedido de vendas
************************************************************************/
/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 11/03/2022
Consultoria: Prox
Uso: SPC
Tipo: Atualizações
Rotina: Faturamento
Função: SPCFATA4
Info: Integração das compras Loja Virtual - Magento x Protheus
************************************************************************/
User Function XSPCFATA4()

	Private cArqOri 	:= ""
    Private nTxT
    Private cPasta  	:= "c:\temp\
    Private cFile   	:= cPasta + "ErroPed.txt"
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

Static Function fImpCsv()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local aLinha     := {}
    Local aCols      := {}
    Local oArquivo
    Local aLinhas

	Local nPos      := 0
	// Local nX        := 0
	Local lProcesOk := .T.

	Private aRetorno  := {}
	Private aProdutos := {}	
	Private aParams   := {}
	Private cCodMun   := "" 	
	Private cNome     := ""
	Private cCPF      := ""
	Private cEndereco := ""
	Private cBairro   := ""
	Private cCidade   := ""
	Private cEstado   := ""
	Private cComplem  := ""
	Private cCEP      := ""
	Private cDDD      := ""
	Private cTelefone := ""
	Private cEmail    := ""
	Private cIDTrans  := ""
	Private cDebCred  := ""
	Private cTpTrans  := ""
	Private cTpPag    := ""
	Private cBandeira := ""
	Private cNumNota  := ""
	Private cStatus   := ""
	Private cTransp   := ""
	Private cNumEnv   := ""
	Private cRefTran  := ""
	Private cCodUser  := ""
	Private cCodVend  := ""
	Private cSerial   := ""
	Private nRecebim  := 0
	Private nRecebid  := 0
	Private nVlrReceb := 0  
	Private nVlrBruto := 0
	Private nVlrDesc  := 0
	Private nVlrTaxa  := 0
	Private nVlrLiqui := 0
	Private nParcelas := 0  
	Private nVlrTrInt := 0
	Private nVlrTxInt := 0
	Private nVlrTxPar := 0
	Private nVlrTrBol := 0
	Private dDtTrans  := SToD("  /  /    ")
	Private dDtCompen := SToD("  /  /    ")

    Private nLinIni := 0
    Private nLinFin := 0
    Private lImport := .F.

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
                    MSGSTOP("Valores de linha inicial e linha final devem ser maior que 0!", "Importacao de Pedidos")
                    Return                  
                EndIf
            Else
                MSGSTOP("Importação de pedidos cancelada", "Importacao de Pedidos")
                Return
            EndIf

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                aCols := {}
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Pedido linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                If nLinhaAtu >= nLinIni .AND. nLinhaAtu <= nLinFin
				// If nLinhaAtu >= 165 .AND. nLinhaAtu <= 13558

					aRetorno 	:= {}
					aParams 	:= {}
					aProdutos	:= {}

					aadd(aParams, {"Nome"				, aLinha[1]} )
                    aadd(aParams, {"CPF"				, aLinha[2]} )
                    aadd(aParams, {"Endereco"			, aLinha[3]} )
                    aadd(aParams, {"Bairro"				, aLinha[4]} )
					aadd(aParams, {"Cidade"				, aLinha[5]} )
                    aadd(aParams, {"Estado"				, aLinha[6]} )
                    aadd(aParams, {"Complemento"		, aLinha[9]} )
                    aadd(aParams, {"CEP"				, aLinha[8]} )
					aadd(aParams, {"DDD"				, aLinha[7]} )
                    aadd(aParams, {"Telefone"			, aLinha[10]} )
                    aadd(aParams, {"Email"				, aLinha[11]} )
                    aadd(aParams, {"Transacao_ID"		, aLinha[12]} )
					aadd(aParams, {"Debito_Credito"		, aLinha[13]} )
                    aadd(aParams, {"Tipo_Transacao"		, aLinha[14]} )
                    aadd(aParams, {"Tipo_Pagamento"		, aLinha[15]} )
                    aadd(aParams, {"Valor_Bruto"		, aLinha[16]} )
					aadd(aParams, {"Valor_Desconto"		, aLinha[17]} )
                    aadd(aParams, {"Valor_Taxa"			, aLinha[18]} )
                    aadd(aParams, {"Valor_Liquido"		, aLinha[19]} )
                    aadd(aParams, {"Data_Transacao"		, aLinha[20]} )
					aadd(aParams, {"Data_Compensacao"	, aLinha[21]} )
                    aadd(aParams, {"Parcelas"			, aLinha[22]} )
                    aadd(aParams, {"Valor_Tarifa_Int"	, aLinha[23]} )
                    aadd(aParams, {"Valor_Taxa_Int"		, aLinha[24]} )
					aadd(aParams, {"Valor_Taxa_Parce"	, aLinha[25]} )
                    aadd(aParams, {"Valor_Tarifa_Bol"	, aLinha[26]} )
                    aadd(aParams, {"Bandeira"			, aLinha[27]} )
                    aadd(aParams, {"Status"				, aLinha[28]} )
                    aadd(aParams, {"Ref_Transacao"		, aLinha[29]} )
                    aadd(aParams, {"Recebimentos"		, aLinha[32]} )
                    aadd(aParams, {"Recebidos"			, aLinha[33]} )
					aadd(aParams, {"Valor_Recebido"		, aLinha[34]} )
                    aadd(aParams, {"Codigo_Usuario"		, aLinha[30]} )
                    aadd(aParams, {"Codigo_Venda"		, aLinha[31]} )
					aadd(aParams, {"Produto"			, aLinha[35]} )
                    aadd(aParams, {"Valor"				, aLinha[36]} )
                    aadd(aParams, {"Quantidade"			, aLinha[37]} )
                    // aadd(aParams, {"Transportadora"	, ""} )
					// aadd(aParams, {"Num_Envio"		, ""} )
                    // aadd(aParams, {"Serial_Leitor"	, ""} )

					//Entidades do Cliente
					cNome     := StrTran(xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Nome"          } ) ) > 0 , aParams[nPos,2], "")),"'", "" ) //Nome do Cliente	
					cCPF      := IIf(( nPos := aScan( aParams, { |x| x[1] == "CPF"           } ) ) > 0 , aParams[nPos,2], "") //CPF do Cliente
					cEndereco := StrTran(xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Endereco"      } ) ) > 0 , aParams[nPos,2], "")),"'", "" ) //Endereço do Cliente
					cBairro   := xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Bairro"        } ) ) > 0 , aParams[nPos,2], "")) //Bairro do Cliente
					cCidade   := xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Cidade"        } ) ) > 0 , aParams[nPos,2], "")) //Cidade do Cliente
					cEstado   := xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Estado"        } ) ) > 0 , aParams[nPos,2], "")) //Estado do Cliente	 
					cComplem  := xNoAccent(IIf(( nPos := aScan( aParams, { |x| x[1] == "Complemento"   } ) ) > 0 , aParams[nPos,2], "")) //Complemento do endereço do Cliente
					cCEP      := IIf(( nPos := aScan( aParams, { |x| x[1] == "CEP"           } ) ) > 0 , aParams[nPos,2], "") //CEP do endereço do Cliente	
					cCodMun   := xCodMun() //Código do municipio (IBGE)
					cDDD      := IIf(( nPos := aScan( aParams, { |x| x[1] == "DDD"           } ) ) > 0 , aParams[nPos,2], "") //DDD do telefone do Cliente
					cTelefone := IIf(( nPos := aScan( aParams, { |x| x[1] == "Telefone"      } ) ) > 0 , aParams[nPos,2], "") //Telefone ou Celular do Cliente
					cEmail    := IIf(( nPos := aScan( aParams, { |x| x[1] == "Email"         } ) ) > 0 , aParams[nPos,2], "") //E-mail do Cliente
					
					//Entidades do pagamento 
					cIDTrans  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Transacao_ID"         } ) ) > 0 , aParams[nPos,2], "") //ID da Transação do PagSeguro
					cDebCred  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Debito_Credito"       } ) ) > 0 , aParams[nPos,2], "") //Tipo do pagamento se for cartão de Débito ou Crédito
					cTpTrans  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Tipo_Transacao"       } ) ) > 0 , aParams[nPos,2], "") //Tipo da Transação do PagSeguro	
					cTpPag    := IIf(( nPos := aScan( aParams, { |x| x[1] == "Tipo_Pagamento"       } ) ) > 0 , aParams[nPos,2], "") //Tipo do Pagamento no PagSeguro
					nVlrBruto := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Bruto"      } ) ) > 0 , aParams[nPos,2], "0"))	//Valor Bruto
					nVlrDesc  := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Desconto"   } ) ) > 0 , aParams[nPos,2], "0"))	//Valor de Desconto
					nVlrTaxa  := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Taxa"       } ) ) > 0 , aParams[nPos,2], "0"))	//Valor da Taxa
					nVlrLiqui := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Liquido"    } ) ) > 0 , aParams[nPos,2], "0"))	//Valor Líquido
					dDtTrans  := SToD(IIf(( nPos := aScan( aParams,{ |x| x[1] == "Data_Transacao"   } ) ) > 0 , aParams[nPos,2], "19990101")) //Data da Transação
					dDtCompen := SToD(IIf(( nPos := aScan( aParams,{ |x| x[1] == "Data_Compensacao" } ) ) > 0 , aParams[nPos,2], "19990101")) //Data da Compensação
					nParcelas := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Parcelas"         } ) ) > 0 , aParams[nPos,2], "0"))	//Quantidade de Parcelas	
					nVlrTrInt := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Tarifa_Int" } ) ) > 0 , aParams[nPos,2], "0"))	//Valor da Tarifa de Intermediação
					nVlrTxInt := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Taxa_Int"   } ) ) > 0 , aParams[nPos,2], "0"))	//Valor da Taxa de intermediação
					nVlrTxPar := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Taxa_Parce" } ) ) > 0 , aParams[nPos,2], "0")) //Valor da Taxa de Parcelamento		
					nVlrTrBol := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Tarifa_Bol" } ) ) > 0 , aParams[nPos,2], "0"))	//Valor da Tarifa do Boleto
					cBandeira := IIf(( nPos := aScan( aParams, { |x| x[1] == "Bandeira"             } ) ) > 0 , aParams[nPos,2], "") //Bandeira do Cartão
					cStatus   := IIf(( nPos := aScan( aParams, { |x| x[1] == "Status"               } ) ) > 0 , aParams[nPos,2], "") //Status
					cRefTran  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Ref_Transacao"        } ) ) > 0 , aParams[nPos,2], "") //Ref. Transação
					
					//Entidade da transportadora
					cTransp   := IIf(( nPos := aScan( aParams, { |x| x[1] == "Transportadora" } ) ) > 0 , aParams[nPos,2], "") //Transportadora
					cNumEnv   := IIf(( nPos := aScan( aParams, { |x| x[1] == "Num_Envio"      } ) ) > 0 , aParams[nPos,2], "") //Número de Envio
					cSerial   := IIf(( nPos := aScan( aParams, { |x| x[1] == "Serial_Leitor"        } ) ) > 0 , aParams[nPos,2], "") //Serial Leitor
					nRecebim  := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Recebimentos"     } ) ) > 0 , aParams[nPos,2], "0")) //Recebimentos
					nRecebid  := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Recebidos"        } ) ) > 0 , aParams[nPos,2], "0")) //Recebidos
					nVlrReceb := Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor_Recebido"   } ) ) > 0 , aParams[nPos,2], "0")) //Valor Recebido	
					
					//Entidades da compra
					cCodUser  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Codigo_Usuario"       } ) ) > 0 , aParams[nPos,2], "") //Código do Usuário
					cCodVend  := IIf(( nPos := aScan( aParams, { |x| x[1] == "Codigo_Venda"         } ) ) > 0 , aParams[nPos,2], "") //Código da Venda
									
					aAdd(aProdutos,{;
						IIf(( nPos := aScan( aParams, { |x| x[1] == "Produto"        } ) ) > 0 , aParams[nPos,2], ""),;
						Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Valor"      } ) ) > 0 , aParams[nPos,2], "0")),;
						Val(IIf(( nPos := aScan( aParams, { |x| x[1] == "Quantidade" } ) ) > 0 , aParams[nPos,2], "0"))};
						)
					
					//Validações 
					If Empty(cCPF) 
						
						aAdd(aRetorno,{{'Key',"CPF nao foi informado!"},{'Value','0'}})			
					
					Elseif Empty(cNome)
					
						aAdd(aRetorno,{{'Key',"Nome nao foi informado!"},{'Value','0'}})	
						
					Elseif Empty(cEndereco)
					
						aAdd(aRetorno,{{'Key',"Endereco nao foi informado!"},{'Value','0'}})			
					
					Elseif Empty(cBairro)	
							
						aAdd(aRetorno,{{'Key',"Bairro nao foi informado!"},{'Value','0'}})					
					
					Elseif Empty(cCidade)	
							
						aAdd(aRetorno,{{'Key',"Cidade nao foi informada!"},{'Value','0'}})			
					
					Elseif Empty(cDDD)	
							
						aAdd(aRetorno,{{'Key',"DDD nao foi informado!"},{'Value','0'}})		
					
					Elseif Empty(cTelefone)	
							
						aAdd(aRetorno,{{'Key',"Telefone nao foi informado!"},{'Value','0'}})				
					
					Elseif Empty(cEmail)	
						
						aAdd(aRetorno,{{'Key',"E-mail nao foi informado!"},{'Value','0'}})		
					
					Elseif Len(aProdutos) == 0		
					
						aAdd(aRetorno,{{'Key',"Produto nao foi informado!"},{'Value','0'}})	

					Elseif dDtTrans == StoD("19990101")	
					
						aAdd(aRetorno,{{'Key',"Data da transacao informada invalida!"},{'Value','0'}})			
					
					Elseif dDtCompen == StoD("19990101")	
							
						aAdd(aRetorno,{{'Key',"Data da compensacao informada invalida!"},{'Value','0'}})	

					Elseif Empty(cCodMun)
					
						aAdd(aRetorno,{{"Key","Municipio nao foi encontrado no Protheus!"},{"Value","0"}})
						
					Endif 
					
					If Len(aRetorno) == 0
						lProcesOk := xIncCli() //Inclusão de Cadastro de Cliente
					Endif 		
					
					//Caso a variável aRetorno estiver vazia significa que o processo ocorreu sem inconsistências
					If Len(aRetorno) == 0
					
						aAdd(aRetorno,{{'Numero',cNumNota},{'Serie',"RPS"},{'Emissao',AllToChar(dDataBase)},{'Value','1'}})
						
					Endif 
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
 
Return(aRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 14/03/2022
Consultoria: Prox
Uso: SPC
Info: Inclusão do Cadastro de Cliente
*==================================================================*/
Static Function xIncCli()
	
	Local aArea     := GetArea()  
	Local aAI0Auto  := {}
	Local aSA1Auto  := {}
	Local aLog      := {}
	Local nOpcAuto  := 0
	Local nX        := 0
	Local cMsg      := ""
	Local cCodCli   := ""
	Local cLoja     := ""
	Local lProcesOk := .T.
	Local nCPFE     := 0
	Local nCPFQtd   := 0
	Local nPosErr1  := 0
	Local nPosErr2 	:= 0
	Local cMsgErr   := ""

	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile	:= .T.
	
	//Tratativa para CEP e CPF
	cCPF := AllTrim(StrTran(cCPF,".",""))
	cCPF := AllTrim(StrTran(cCPF,"/","")) 
	cCPF := AllTrim(StrTran(cCPF,",","")) 
	cCPF := AllTrim(StrTran(cCPF,"-",""))
	cCEP := AllTrim(StrTran(cCEP,"-",""))
	cCEP := PADL(cCEP ,8, "0")
	
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

	CONOUT("CPFPESQUISADO->" + cCPF)

	DbSelectArea("SA1")
	
	SA1->(DbSetOrder(3))
	CONOUT( SA1->(Indexkey()))
	//Verifico se o cliente é existente na base do Protheus
	If !SA1->(DbSeek(xFilial("SA1")+Alltrim(cCPF)))
		nOpcAuto := 3
		conout("[SPCFATA4]-INCLUSAO DO CLIENTE")
	Else 	
		cCodCli  := SA1->A1_COD
		cLoja    := SA1->A1_LOJA
		conout("[SPCFATA4]-ENCONTROU CLIENTE " + cCodCli + " - " +cLoja )
		nOpcAuto := 4
	Endif 
	
	aAdd(aSA1Auto,{"A1_FILIAL"  , xFilial("SA1")                           , Nil}) //Filial
	
	If nOpcAuto == 4
		
		aAdd(aSA1Auto,{"A1_COD" , cCodCli                                  , Nil}) //Código
		aAdd(aSA1Auto,{"A1_LOJA", cLoja                                    , Nil}) //Loja
	Else
		cCodCli	:= GetSxeNum("SA1","A1_COD")  
		ConfirmSX8()
		cLoja   := "03" 
		aAdd(aSA1Auto,{"A1_COD" , cCodCli				                  , Nil}) //Código VM
		aAdd(aSA1Auto,{"A1_LOJA", cLoja                                   , Nil}) //Loja VM
	Endif 

	aAdd(aSA1Auto,{"A1_NOME"    , SubStr(cNome,1,40)                       , Nil}) //Nome
	aAdd(aSA1Auto,{"A1_NREDUZ"  , SubStr(cNome,1,20)                       , Nil}) //Nome Reduzido
	aAdd(aSA1Auto,{"A1_TIPO"    , "F"                                      , Nil}) //Tipo (F = Consumidor Final) 
	aAdd(aSA1Auto,{"A1_PESSOA"  , IIf(Len(AllTrim(cCPF)) == 14,"J","F")    , Nil}) //Tipo de Pessoa (F = Física)
	aAdd(aSA1Auto,{"A1_CGC"     , cCPF                                     , Nil}) //CPF / CNPJ
	aAdd(aSA1Auto,{"A1_END"     , SubStr(cEndereco,1,80)                   , Nil}) //Endereço
	aAdd(aSA1Auto,{"A1_BAIRRO"  , SubStr(cBairro,1,40)                     , Nil}) //Bairro
	aAdd(aSA1Auto,{"A1_COMPLEM" , SubStr(cComplem,1,40)                    , Nil}) //Complemento do Endereço
	aAdd(aSA1Auto,{"A1_EST"     , cEstado                                  , Nil}) //Estado (UF)
	aAdd(aSA1Auto,{"A1_COD_MUN" , cCodMun                                  , Nil}) //Código do Município (IBGE)
	aAdd(aSA1Auto,{"A1_CEP"     , cCEP                                     , Nil}) //CEP
	aAdd(aSA1Auto,{"A1_NATUREZ" , "R18004"                                 , Nil}) //Natureza
	aAdd(aSA1Auto,{"A1_EMAIL"   , AllTrim(SubStr(cEmail,1,250))            , Nil}) //E-mail
	aAdd(aSA1Auto,{"A1_CODPAIS" , "01058"                                  , Nil}) //Código País (IBGE)
	aAdd(aSA1Auto,{"A1_RECISS"  , "2"                                      , Nil}) //Recolhe ISS (2 = Não)
	aAdd(aSA1Auto,{"A1_XTPENT"  , "7"                                      , Nil}) //Tipo de Entidade (7 = Cliente)
	
	Begin Transaction
	
		//------------------------------------
		// Chamada para cadastrar o cliente.
		//------------------------------------
		MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aSA1Auto, nOpcAuto, aAI0Auto)
		
		If lMsErroAuto 
		
			lProcesOk := .F.
			aLog := GetAutoGRLog()
		
			For nX := 1 To Len(aLog)
				cMsg += aLog[nX] + Chr(10)
			Next nX
			
			//cMsg := xIdentaMsg(cMsg)

			aAdd(aRetorno,{{'Key',cMsg},{'Value','0'}})

			nPosErr1	:= AT("Mensagem do erro:",cMsg) + 18
			nPosErr2	:= AT("Mensagem da solucao:",cMsg)
			cMsgErr		:= SubStr(cMsg, (nPosErr1), (nPosErr2-nPosErr1))
			If nTxT > -1
           		fWrite(nTxT,"Cadastro de Cliente: erro na Linha: " + cValToChar(nLinhaAtu) + ", " + cMsgErr + ", Cnpj: " + cCPF + chr(13)+chr(10) )
    		EndIf
			
			DisarmTransaction()
			
		Endif 
	
	End Transaction

	If lProcesOk
		
		DbSelectArea("SA1")
		
		SA1->(DbSetOrder(1))		
		//Verifico se o cliente é existente na base do Protheus
		If SA1->(DbSeek(xFilial("SA1") +  cCodCli + cLoja /*Alltrim(cCPF)*/))
			//conout("[SPCFATA4]-ENCONTROU CLIENTE " + cCodCli + " - " +cLoja )
			conout("[SPCFATA4]-ENCONTROU CLIENTE " + SA1->A1_COD + " - " + SA1->A1_LOJA )
			//Inclusão do pedido de vendas
			lProcesOk := xIncPed(cCodCli,cLoja)
			// If AllTrim(aProdutos[1,1]) <> "321-11" .AND. AllTrim(aProdutos[1,1]) <> "537-3" .AND. AllTrim(aProdutos[1,1]) <>  "18";
			// .AND. AllTrim(aProdutos[1,1]) <> "CONSULTE-STORE" .AND. AllTrim(aProdutos[1,1]) <> "321-5";
			// .AND. AllTrim(aProdutos[1,1]) <> "321-6" .AND. AllTrim(aProdutos[1,1]) <> "531-2" .AND. AllTrim(aProdutos[1,1]) <> "677-1";
			// .AND. AllTrim(aProdutos[1,1]) <> "55" .AND. AllTrim(aProdutos[1,1]) <> "674-1" .AND. AllTrim(aProdutos[1,1]) <> "678-1";
			// .AND. AllTrim(aProdutos[1,1]) <> "332-1" .AND. AllTrim(aProdutos[1,1]) <> "293.79" .AND. AllTrim(aProdutos[1,1]) <> "676-1"
			// 	lProcesOk := xIncPed(cCodCli,cLoja)
			// EndIf
		 
		Else 	
			lProcesOk := .F.
			aAdd(aRetorno,{{'Key',"Cadastro do cliente nao foi realizado!"},{'Value','0'}})	

			If nTxT > -1
           		fWrite(nTxT,"Linha: " + cValToChar(nLinhaAtu) + " não encontrou cliente: " + cCodCli + ", para cadastrar pedido" + chr(13)+chr(10) )
    		EndIf
		Endif 
		
	Endif 
	
	RestArea(aArea)
	
Return(lProcesOk) 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Inclusão do Pedido de Vendas
*==================================================================*/
Static Function xIncPed(cCodCli,cLoja)

	Local nOpc      := 3
	Local nX        := 0
	Local nVlrTotal := 0
	Local aHeader   := {}
	Local aLine     := {}
	Local aItems    := {}
	Local aLog      := {}
	Local cCondPag  := xCondPag() 
	Local cTesPF    := GetMV("LV_TESPF",.F.,"501")
	Local cTesPJ    := GetMV("LV_TESPJ",.F.,"502")
	Local cVendedor := GetMV("LV_VEND",.F.,"000003")
	Local cMsg      := ""
	Local lProcesOk := .T.	
	Local nPosErr1  := 0
	Local nPosErr2 	:= 0
	Local cMsgErr   := ""
	
	Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
	
	//Conversão dos valores nas strings para adequar aos campos do Protheus no pedido de vendas
	cDebCred := IIf(AllTrim(cDebCred) == "Crédito","2","1")
	cTpTrans := IIf(AllTrim(cTpTrans) == "Pagamento","1",IIf(AllTrim(cTpTrans) == "Assinatura","2","3"))
	cTpPag   := IIf(AllTrim(cTpPag) == "Boleto","1",IIf(AllTrim(cTpPag) == "Saldo","3","2"))
	cStatus  := IIf(AllTrim(cStatus) == "Aprovada","1","2")
	conout("[SPCFATA4]-ENCONTROU CLIENTE " + SA1->A1_COD + " - " + SA1->A1_LOJA )
	conout("[SPCFATA4]-ENCONTROU CLIENTE " + cCodCli + " - " + cLoja )	
    //Dados do Cabeçalho
    aAdd(aHeader, {"C5_TIPO"    , "N"      , Nil}) //Tipo do Pedido de Vendas
    aAdd(aHeader, {"C5_CLIENTE" , cCodCli  , Nil}) //Código do Cliente
    aAdd(aHeader, {"C5_LOJACLI" , cLoja    , Nil}) //Loja do Cliente
    aAdd(aHeader, {"C5_LOJAENT" , cLoja    , Nil}) //Loja de Entrega do Cliente
    aAdd(aHeader, {"C5_CONDPAG" , cCondPag , Nil}) //Condição de Pagamento 
	aAdd(aHeader, {"C5_EMISSAO" , dDtTrans , Nil}) //Data da Transação 
	aAdd(aHeader, {"C5_VEND1"   , cVendedor, Nil}) //Loja Online - PagSeguro 
	aAdd(aHeader, {"C5_NATUREZ"   , "R18004", Nil}) //Loja Online - PagSeguro 
	
	//Dados do Cabeçalho - Customizados - Pag Seguro
    aAdd(aHeader, {"C5_XIDTRAN" , cIDTrans  , Nil}) //ID Transação
	aAdd(aHeader, {"C5_XDEBCRE" , cDebCred  , Nil}) //Débito ou Crédito
	aAdd(aHeader, {"C5_XTPTRAN" , cTpTrans  , Nil}) //Tipo da Transação
	aAdd(aHeader, {"C5_XTPPAGA" , cTpPag    , Nil}) //Tipo do Pagamento
	aAdd(aHeader, {"C5_XVLBRUT" , nVlrBruto , Nil}) //Valor Bruto
	aAdd(aHeader, {"C5_XVLDESC" , nVlrDesc  , Nil}) //Valor do Desconto
	aAdd(aHeader, {"C5_XVLTAXA" , nVlrTaxa  , Nil}) //Valor da Taxa
	aAdd(aHeader, {"C5_XVLLIQU" , nVlrLiqui , Nil}) //Valor Líquido
	aAdd(aHeader, {"C5_XDTCOMP" , dDtCompen , Nil}) //Data da Compensação
	aAdd(aHeader, {"C5_XPARCEL" , nParcelas , Nil}) //Parcelas
	aAdd(aHeader, {"C5_XTARINT" , nVlrTrInt , Nil}) //Tarifa de Intermediação
	aAdd(aHeader, {"C5_XTAXINT" , nVlrTxInt , Nil}) //Taxa de Intermediação
	aAdd(aHeader, {"C5_XTAXPAR" , nVlrTxPar , Nil}) //Taxa de Parcelamento
	aAdd(aHeader, {"C5_XTARBOL" , nVlrTrBol , Nil}) //Tarifa do Boleto
	aAdd(aHeader, {"C5_XBANDEI" , cBandeira , Nil})	//Bandeira Cartão
	aAdd(aHeader, {"C5_XSTATUS" , cStatus   , Nil})	//Status
	aAdd(aHeader, {"C5_XTRANSP" , cTransp   , Nil})	//Transportadora
	aAdd(aHeader, {"C5_XNUMENV" , cNumEnv   , Nil})	//Número do Envio
	aAdd(aHeader, {"C5_XREFTRA" , cRefTran  , Nil})	//Ref. Transação
	aAdd(aHeader, {"C5_XCODUSE" , cCodUser  , Nil})	//Código do Usuário
	aAdd(aHeader, {"C5_XCODVEN" , cCodVend  , Nil})	//Código da Venda
	aAdd(aHeader, {"C5_XSERIAL" , cSerial   , Nil})	//Serial Leitor
	aAdd(aHeader, {"C5_XRECEB1" , nRecebim  , Nil})	//Recebimentos
	aAdd(aHeader, {"C5_XRECEB2" , nRecebid  , Nil})	//Recebidos
	aAdd(aHeader, {"C5_XRECEB3" , nVlrReceb , Nil})	//Valor Recebido
		
    //Dados dos Itens
	
	For nX := 1 To Len(aProdutos)

		aLine     := {}
		nVlrTotal := aProdutos[nX,2] * aProdutos[nX,3]
		If aProdutos[1,2] < 0
			aProdutos[1,2] := aProdutos[1,2]*-1
		EndIf
		If aProdutos[1,2] = 0
			aProdutos[1,2] := 1
		EndIf

		aAdd(aLine, {"C6_ITEM"    , AllTrim(cValToChar(StrZero(nX,2))) , Nil}) //Código do Produto
		aAdd(aLine, {"C6_PRODUTO" , aProdutos[nX,1]                    , Nil}) //Código do Produto 
		aAdd(aLine, {"C6_QTDVEN"  , aProdutos[nX,3]                    , Nil}) //Quantidade 
		aAdd(aLine, {"C6_PRUNIT"  , aProdutos[nX,2]                    , Nil}) //Valor Unitário
		aAdd(aLine, {"C6_PRCVEN"  , aProdutos[nX,2]                    , Nil}) //Preço de Venda 
		aAdd(aLine, {"C6_VALOR"   , nVlrTotal                          , Nil}) //Valor Total
		aAdd(aLine, {"C6_CC"   	  , "R00101001"                        , Nil}) //Centro de Custo
		aAdd(aLine, {"C6_TES"     , IIf(Len(cCPF) == 14,cTesPJ,cTesPF) , Nil}) //TES
		
		aAdd(aItems,aLine)
		
	Next nX	
	
	Begin Transaction 

		MsExecAuto({|x,y,z| MATA410(x,y,z)}, aHeader, aItems, nOpc)
	
		If lMsErroAuto	
		
			lProcesOk := .F.
			aLog      := GetAutoGRLog()	
			
			For nX := 1 To Len(aLog)
				cMsg += aLog[nX] + Chr(10)
			Next nX
			
			//cMsg := xIdentaMsg(cMsg)
		
			aAdd(aRetorno,{{'Key',cMsg},{'Value','0'}})

			// nPosErr1	:= AT("Mensagem do erro:",cMsg) + 18
			// nPosErr2	:= AT("Mensagem da solucao:",cMsg)
			cMsgErr		:= SubStr(cMsg, 1, 50)
			If nTxT > -1
           		fWrite(nTxT,"Cadastro de Pedido: erro na Linha: " + cValToChar(nLinhaAtu) + ", " + cMsgErr + ", produto: " + AllTrim(aProdutos[1,1] + chr(13)+chr(10)))
    		EndIf
			
			DisarmTransaction()	
			
		Endif
		
	End Transaction 

	If lProcesOk
		//Gero a liberação do pedido de vendas e a nota fiscal de serviço
		// lProcesOk := xGeraFat(nVlrTaxa,cRefTran,dDtCompen)
	Endif 
	
	//Processo comentado conforme solicitado pela SPC - Simone
	/*If lProcesOk
		//Gero o contas a pagar referente ao valor da tarifa
		lProcesOk := xGeraTxPag(nVlrTaxa,dDtCompen,cRefTran)	
	Endif*/

Return(lProcesOk) 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Inicio do processo de faturamento
*==================================================================*/
Static Function xGeraFat(nVlrTaxa,cRefTran,dDtCompen)

	Local cPedido   := ""
	Local cFilEmp   := ""
	Local lCredito  := .T.
	Local lEstoque  := .T.
	Local lAvCred   := .F.
	Local lAvEst    := .T.
	Local lProcesOk := .T.
	Local nRecnoSC5 := 0
	
	cFilEmp   := SC5->C5_FILIAL
	cPedido   := SC5->C5_NUM
	nRecnoSC5 := SC5->(Recno())
	
	DbSelectArea("SC9")	

	DbSelectArea("SC6")
	SC6->(DbSetOrder(1))
	
	If SC6->(DbSeek(cFilEmp+cPedido))
	
		While !SC6->(Eof()) .And. SC6->(C6_FILIAL+C6_NUM) == cFilEmp+cPedido
		
			SC9->(DbSetOrder(1))
		
			If !SC9->(DbSeek(cFilEmp+cPedido+SC6->C6_ITEM))	

				MaLibDoFat(SC6->(RecNo()),SC6->C6_QTDVEN,lCredito,lEstoque,lAvCred,lAvEst)	
			
			Endif 
		
			SC6->(DbSkip())
		
		EndDo
		
		SC6->(MaLiberOk({cPedido}))
		
	Endif 	
	
	lProcesOk := xGeraNF(nRecnoSC5,nVlrTaxa,cRefTran,dDtCompen)

Return(lProcesOk)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Gera as Notas fiscais para os Pedidos Liberados 
*==================================================================*/
Static Function xGeraNF(nRecnoSC5,nVlrTaxa,cRefTran,dDtCompen)

	Local nNotas   	:= 0
	Local cFilEmp  	:= ""
	Local cPedido  	:= "" 
	Local cCondPag 	:= ""
	Local cTES     	:= ""
	Local cSerie   	:= GetMV("LV_SERIE",.F.,"RPS")
	Local cCliente 	:= ""
	Local cLojaCli 	:= ""
	Local aPvlNFs  	:= {}
	Local lProcesOk := .T.

	DbSelectArea("SC5")
	SC5->(DbGoTo(nRecnoSC5))
	
	cFilEmp  := SC5->C5_FILIAL
	cPedido  := SC5->C5_NUM
	cCliente := SC5->C5_CLIENTE
	cLojaCli := SC5->C5_LOJACLI
	
	DbSelectArea("SC9")	
	SC9->(DbSetOrder(1))
	
	If SC9->(DbSeek(cFilEmp+cPedido))

		While !SC9->(Eof()) .And. SC9->(C9_FILIAL+C9_PEDIDO) == cFilEmp+cPedido
	
			cTES     := Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,"C6_TES")
			cCondPag := Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,"C5_CONDPAG")
			
			//Abertura das áreas de trabalho na inclusão da nota fiscal de saída
			DbSelectArea("SF4")
			DbSelectArea("SB1")
			DbSelectArea("SB2")
			DbSelectArea("SE4")
			// ---
			
			// aAdd(aPvlNFs,{;
			// 	SC9->C9_PEDIDO,;
			// 	SC9->C9_ITEM,;
			// 	SC9->C9_SEQUEN,;
			// 	SC9->C9_QTDLIB,;
			// 	SC9->C9_PRCVEN,;
			// 	SC9->C9_PRODUTO,;
			// 	SF4->F4_ISS == "S",;
			// 	SC9->(RecNo()),;
			// 	SC5->(Recno(Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,""))),;
			// 	SC6->(Recno(Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,""))),;
			// 	SE4->(Recno(Posicione("SE4",1,xFilial("SE4")+cCondPag,""))),;
			// 	SB1->(Recno(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,""))),;
			// 	SB2->(Recno(Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,""))),;
			// 	SF4->(Recno(Posicione("SF4",1,xFilial("SF4")+cTes,""))),;
			// 	Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,"B2_LOCAL"),;
			// 	1,;
			// 	SC9->C9_QTDLIB2;
				// })

			SC9->(DbSkip())			
		
		EndDo
		
		If Len(aPvlNFs) > 0
		
			DbSelectArea("SA1")
			SA1->(DbSetOrder(1))
			
			If SA1->(DbSeek(xFilial("SA1")+cCliente+cLojaCli))
     	
				cNumNota := MAPVLNFS(aPvlNFs,cSerie,.F.,.F.,.F.,.F.,.F.,1,1,.T.,.F.,,,)
		
				If Empty(cNumNota)
					
					lProcesOk := .F.
					
					aAdd(aRetorno,{{'Key',"Ocorreu um problema ao gerar a nota fiscal de saida!"},{'Value','0'}})		
					
				Else				
					
					nNotas ++
					
					//Gravo informações no título que foi criado na tabela SE1
					xGravaInfSE1(cNumNota,cSerie,nVlrTaxa,cFilEmp,cCliente,cLojaCli,cRefTran,dDtCompen)
				
				Endif
				
			Endif 	
				
		Endif 	
		
	Else

		lProcesOk := .F.
	
		aAdd(aRetorno,{{'Key',"Pedido de vendas com itens nao liberados!"},{'Value','0'}})	
	
	Endif
	
	//Limpo as variáveis para um novo processamento
	aPvlNFs := {}	

	//Mensagem de término de excução do Job 
	If nNotas == 0
	
		lProcesOk := .F.
	
		aAdd(aRetorno,{{'Key',"Termino de processamento nenhuma nota foi gerada!"},{'Value','0'}})
	
	Endif 

Return(lProcesOk)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 24/10/2022
Consultoria: Prox
Uso: SPC
Info: Gravo informações complementares no título do Contas a Receber
*==================================================================*/
Static Function xGravaInfSE1(cNumNota,cSerie,nVlrTaxa,cFilEmp,cCliente,cLojaCli,cRefTran,dDtCompen)
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
	
	If SE1->(DbSeek(AvKey(cFilEmp,"E1_FILIAL")+AvKey(cCliente,"E1_CLIENTE")+AvKey(cLojaCli,"E1_LOJA")+AvKey(cSerie,"E1_PREFIXO")+AvKey(cNumNota,"E1_NUM")))

		//Validação criada para impedir a não criação do titulo no contas a pagar por conta da data conforme alinhado com a SPC no dia 02/01/2023
		If dDtCompen < dDataBase
			dDtCompen := DaySum(dDtCompen,10)
			dDtCompen := DataValida(dDtCompen,.T.)
		Endif 
		// ---

		RecLock("SE1",.F.)
		SE1->E1_DECRESC := nVlrTaxa
		SE1->E1_SDDECRE := nVlrTaxa
		SE1->E1_XIDTRAN := cRefTran
		SE1->E1_VENCTO  := dDtCompen
		SE1->E1_VENCREA := DataValida(dDtCompen,.T.) 
		SE1->(MsUnlock())	
	
	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/09/2022
Consultoria: Prox
Uso: SPC
Info: 
*==================================================================*/
/*Static Function xGeraTxPag(nVlrTaxa,dDtCompen,cRefTran)

	Local cFornecedor := GetMV("LV_FORNEC",.F.,"000075")
	Local cPrefixo    := GetMV("LV_PREFIX",.F.,"PAG")
	Local cTipo       := GetMV("LV_TPTIT",.F.,"BOL")
	Local cNatureza   := GetMV("LV_NATUR",.F.,"D06026")
	Local cCCusto     := GetMV("LV_CCUSTO",.F.,"D03601001")
	Local cNumero     := xNumero(cPrefixo,cTipo)
	Local cMsg        := ""
	Local aTitulo     := {}
	Local aLog        := {}
	Local nX          := 0
	
	Private lMsErroAuto := .F.
	
	//Validação criada para impedir a não criação do titulo no contas a pagar por conta da data conforme alinhado com a SPC no dia 02/01/2023
	If dDtCompen < dDataBase
		dDtCompen := DaySum(dDtCompen,10)
		dDtCompen := DataValida(dDtCompen,.T.)
	Endif 
	// ---
	
	aTitulo := {{"E2_FILIAL" 	, xFilial("SE2")             ,Nil},;
			    {"E2_PREFIXO" 	, cPrefixo                   ,Nil},;    
			    {"E2_NUM"     	, cNumero   	             ,Nil},;
			    {"E2_TIPO"    	, cTipo     	             ,Nil},;
			    {"E2_NATUREZ" 	, cNatureza		             ,Nil},;
			    {"E2_FORNECE" 	, cFornecedor	             ,Nil},;
			    {"E2_LOJA"    	, "01"      	             ,Nil},;		           
			    {"E2_EMISSAO" 	, dDataBase                  ,Nil},;
			    {"E2_VENCTO" 	, dDtCompen                  ,Nil},;
			    {"E2_VENCREA" 	, DataValida(dDtCompen,.T.)  ,Nil},;
				{"E2_CC"        , cCCusto                    ,Nil},;
			    {"E2_VALOR"   	, nVlrTaxa		             ,Nil},;
			    {"E2_VLCRUZ"   	, nVlrTaxa                   ,Nil},;
				{"E2_XIDTRAN"   , cRefTran                   ,Nil}} //ID do Magento

	MsExecAuto( { |x,y,z| FINA050(x,y,z)},aTitulo,,3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	
	If lMsErroAuto
		
		lProcesOk := .F.

		aLog := GetAutoGRLog()	
			
		For nX := 1 To Len(aLog)
			cMsg += aLog[nX] + Chr(10)
		Next nX
	
		Conout(cMsg)
		ConOut("["+AllTrim(AllToChar(Date()))+" - "+AllTrim(Time())+"] ->>>> SPCFATA4 - Erro na inclusao da taxa no contas a pagar")
		ConOut("["+AllTrim(AllToChar(Date()))+" - "+AllTrim(Time())+"] -------------------------------------------------------------------")
		ConOut("["+AllTrim(AllToChar(Date()))+" - "+AllTrim(Time())+"] ->>>> SPCFATA4 - Detalhes do Erro da inclusao da Taxa: ")
		ConOut(cMsg)
		ConOut("["+AllTrim(AllToChar(Date()))+" - "+AllTrim(Time())+"] -------------------------------------------------------------------")
		
	Else 
		lProcesOk := .T.
	Endif 

Return(lProcesOk)*/

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/09/2022
Consultoria: Prox
Uso: SPC
Info: 
*==================================================================*/
Static Function xNumero(cPrefixo,cTipo)

	Local cNumero := ""
	Local cQuery  := ""
	Local cTemp   := GetNextAlias()

	cQuery := " SELECT MAX(E2_NUM) AS NUMERO FROM "+RetSQLName("SE2")
	cQuery += "	WHERE E2_FILIAL = '"+xFilial("SE2")+"'"
	cQuery += "		AND E2_PREFIXO = '"+cPrefixo+"'"
	cQuery += "		AND E2_TIPO = '"+cTipo+"'"
	cQuery += "		AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

	DbUseArea(.F., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T.)

	DbSelectArea(cTemp)

	cNumero := Soma1((cTemp)->NUMERO)	

	(cTemp)->(DbCloseArea())

Return(cNumero)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 26/04/2022
Consultoria: Prox
Uso: SPC
Info: 
*==================================================================*/
Static Function xCodMun()

    Local cQuery   := ""
    Local cTemp    := GetNextAlias()
    Local cRetorno := ""
    
	If AllTrim(cCidade) == "ALTA FLORESTA D'OESTE"
		cRetorno := "00015"
	ElseIf AllTrim(cCidade) == "ALVORADA D'OESTE"
		cRetorno := "00346"
	ElseIf AllTrim(cCidade) == "APARECIDA D'OESTE"
		cRetorno := "02606"
	ElseIf AllTrim(cCidade) == "BARRA D'ALCANTARA"
		cRetorno := "01176"
	ElseIf AllTrim(cCidade) == "DIAMANTE D'OESTE"
		cRetorno := "07157"
	ElseIf AllTrim(cCidade) == "DIAS D'AVILA"
		cRetorno := "10057"
	ElseIf AllTrim(cCidade) == "ESPIGAO D'OESTE"
		cRetorno := "00098"
	ElseIf AllTrim(cCidade) == "ESTRELA D'OESTE"
		cRetorno := "15202"
	ElseIf AllTrim(cCidade) == "FIGUEIROPOLIS D'OESTE"
		cRetorno := "03809"
	ElseIf AllTrim(cCidade) == "GLORIA D'OESTE"
		cRetorno := "03957"
	ElseIf AllTrim(cCidade) == "GUARANI D'OESTE"
		cRetorno := "18008"
	ElseIf AllTrim(cCidade) == "HERVAL D'OESTE"
		cRetorno := "06702"
	ElseIf AllTrim(cCidade) == "ITAPEJARA D'OESTE"
		cRetorno := "11209"
	ElseIf AllTrim(cCidade) == "ITAPORANGA D'AJUDA"
		cRetorno := "03203"
	ElseIf AllTrim(cCidade) == "LAGOA D'ANTA"
		cRetorno := "06205"
	ElseIf AllTrim(cCidade) == "LAMBARI D'OESTE"
		cRetorno := "05234"
	ElseIf AllTrim(cCidade) == "MACHADINHO D'OESTE"
		cRetorno := "00130"
	ElseIf AllTrim(cCidade) == "MAE D'AGUA"
		cRetorno := "08703"
	ElseIf AllTrim(cCidade) == "MIRASSOL D'OESTE"
		cRetorno := "05622"
	ElseIf AllTrim(cCidade) == "NOVA BRASILANDIA D'OESTE"
		cRetorno := "00148"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA"
		cRetorno := "10402"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA DAS CUNHAS"
		cRetorno := "07407"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA DAS FLORES"
		cRetorno := "05705"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA DO CASADO"
		cRetorno := "05804"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA DO PIAUI"
		cRetorno := "07108"
	ElseIf AllTrim(cCidade) == "OLHO D'AGUA GRANDE"
		cRetorno := "05903"
	ElseIf AllTrim(cCidade) == "OLHO-D'AGUA DO BORGES"
		cRetorno := "08409"
	ElseIf AllTrim(cCidade) == "OLHOS-D'AGUA"
		cRetorno := "45455"
	ElseIf AllTrim(cCidade) == "OLHOS D'AGUA"
		cRetorno := "45455"
	ElseIf AllTrim(cCidade) == "PALMEIRA D'OESTE"
		cRetorno := "35200"
	ElseIf AllTrim(cCidade) == "PAU D'ARCO"
		If AllTrim(cEstado) == "PA"
			cRetorno := "05551"
		ElseIf AllTrim(cEstado) == "TO"
			cRetorno := "16307"
		EndIf
	ElseIf AllTrim(cCidade) == "PEROLA D'OESTE"
		cRetorno := "19004"
	ElseIf AllTrim(cCidade) == "PINGO D'AGUA"
		cRetorno := "50539"
	ElseIf AllTrim(cCidade) == "RANCHO ALEGRE D'OESTE"
		cRetorno := "21356"
	ElseIf AllTrim(cCidade) == "SANTA BARBARA D'OESTE"
		cRetorno := "45803"
	ElseIf AllTrim(cCidade) == "SANTA CLARA D'OESTE"
		cRetorno := "46108"
	ElseIf AllTrim(cCidade) == "SANTA LUZIA D'OESTE"
		cRetorno := "00296"
	ElseIf AllTrim(cCidade) == "SANTA RITA D'OESTE"
		cRetorno := "47403"
	ElseIf AllTrim(cCidade) == "SAO FELIPE D'OESTE"
		cRetorno := "01484"
	ElseIf AllTrim(cCidade) == "SAO JOAO D'ALIANCA"
		cRetorno := "20009"
	ElseIf AllTrim(cCidade) == "SAO JOAO DO PAU D'ALHO"
		cRetorno := "49300"
	ElseIf AllTrim(cCidade) == "SAO JORGE D'OESTE"
		cRetorno := "25209"
	ElseIf AllTrim(cCidade) == "SITIO D'ABADIA"
		cRetorno := "20702"
	ElseIf AllTrim(cCidade) == "TANQUE D'ARCA"
		cRetorno := "09004"
	ElseIf AllTrim(cCidade) == "CONQUISTA D'OESTE"
		cRetorno := "03361"
	ElseIf AllTrim(cCidade) == "PINGO-D'AGUA"
		cRetorno := "50539"
	EndIf

	If Empty(cRetorno) 
		cQuery := "SELECT CC2_CODMUN, CC2_MUN FROM " + RetSQLName("CC2") 
		cQuery += " WHERE CC2_EST = '" + AllTrim(cEstado) + "'" 
		cQuery += " 	AND CC2_MUN = '" + cCidade + "'" 
		cQuery += "		AND D_E_L_E_T_ = ' '"

		cQuery := ChangeQuery(cQuery)

		DbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cTemp,  .F., .T.)

		If (cTemp)->(!EOF())
			cRetorno := (cTemp)->CC2_CODMUN
		EndIf

		(cTemp)->(DbCloseArea())
	EndIf
	
Return(cRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/04/2022
Consultoria: Prox
Uso: SPC
Info: Condições de pagamento conforme a parcela
*==================================================================*/
Static Function xCondPag()

	Local cCondPag  := ""
	Local cUmaParc  := AllTrim(GetMV("LV_COND1",.F.,"000"))
	Local cDuasParc := AllTrim(GetMV("LV_COND2",.F.,"002"))
	Local cTresParc := AllTrim(GetMV("LV_COND3",.F.,"001"))

	If nParcelas == 1 //À vista
		cCondPag := cUmaParc   
	Elseif nParcelas == 2 //Duas Parcelas
		cCondPag := cDuasParc
	Elseif nParcelas == 3  //Três Parcelas
		cCondPag := cTresParc
	Else 
		cCondPag := cUmaParc //Caso não caia em nenhuma das opções aloco à vista	
	Endif

Return(cCondPag)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Tratativa para extração de caracteres especiais
*==================================================================*/
Static Function xNoAccent(cConteudo)

	//Retirando caracteres
    cConteudo := StrTran(cConteudo, " ", "" )
    cConteudo := StrTran(cConteudo, "#", "" )
    cConteudo := StrTran(cConteudo, "%", "" )
    cConteudo := StrTran(cConteudo, "*", "" )
    cConteudo := StrTran(cConteudo, "&", "E")
    cConteudo := StrTran(cConteudo, ">", "" )
    cConteudo := StrTran(cConteudo, "<", "" )
    cConteudo := StrTran(cConteudo, "!", "" )
    cConteudo := StrTran(cConteudo, "@", "" )
    cConteudo := StrTran(cConteudo, "$", "" )
    cConteudo := StrTran(cConteudo, "(", "" )
    cConteudo := StrTran(cConteudo, ")", "" )
    cConteudo := StrTran(cConteudo, "_", "" )
    cConteudo := StrTran(cConteudo, "=", "" )
    cConteudo := StrTran(cConteudo, "+", "" )
    cConteudo := StrTran(cConteudo, "{", "" )
    cConteudo := StrTran(cConteudo, "}", "" )
    cConteudo := StrTran(cConteudo, "[", "" )
    cConteudo := StrTran(cConteudo, "]", "" )
    cConteudo := StrTran(cConteudo, "/", "" )
    cConteudo := StrTran(cConteudo, "?", "" )
    cConteudo := StrTran(cConteudo, ".", "" )
    cConteudo := StrTran(cConteudo, "\", "" )
    cConteudo := StrTran(cConteudo, "|", "" )
    cConteudo := StrTran(cConteudo, ":", "" )
    cConteudo := StrTran(cConteudo, ";", "" )
    cConteudo := StrTran(cConteudo, '"', '' )
    cConteudo := StrTran(cConteudo, "??", "" )
    cConteudo := StrTran(cConteudo, "??", "" )
	cConteudo := StrTran(cConteudo, "	","") //Tab

    cConteudo := StrTran(cConteudo, "??", "a")
    cConteudo := StrTran(cConteudo, "??", "a")
    cConteudo := StrTran(cConteudo, "??", "a")
    cConteudo := StrTran(cConteudo, "? ", "a")
    cConteudo := StrTran(cConteudo, "??", "a")
    cConteudo := StrTran(cConteudo, "??", "e")
    cConteudo := StrTran(cConteudo, "??", "e")
    cConteudo := StrTran(cConteudo, "??", "e")
    cConteudo := StrTran(cConteudo, "??", "e")
    cConteudo := StrTran(cConteudo, "??", "i")
    cConteudo := StrTran(cConteudo, "??", "i")
    cConteudo := StrTran(cConteudo, "??", "i")
    cConteudo := StrTran(cConteudo, "??", "i")
    cConteudo := StrTran(cConteudo, "??", "o")
    cConteudo := StrTran(cConteudo, "??", "o")
    cConteudo := StrTran(cConteudo, "??", "o")
    cConteudo := StrTran(cConteudo, "??", "o")
    cConteudo := StrTran(cConteudo, "?", "o")
    cConteudo := StrTran(cConteudo, "??", "u")
    cConteudo := StrTran(cConteudo, "??", "u")
    cConteudo := StrTran(cConteudo, "??", "u")
    cConteudo := StrTran(cConteudo, "??", "u")
    cConteudo := StrTran(cConteudo, "?", "c")
 
    cConteudo := StrTran(cConteudo, "??", "A")
    cConteudo := StrTran(cConteudo, "??", "A")
    cConteudo := StrTran(cConteudo, "?,", "A")
    cConteudo := StrTran(cConteudo, "?€", "A")
    cConteudo := StrTran(cConteudo, "?" , "A")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "?“", "O")
    cConteudo := StrTran(cConteudo, "?’", "O")
    cConteudo := StrTran(cConteudo, "?•", "O")
    cConteudo := StrTran(cConteudo, "?”", "O")
    cConteudo := StrTran(cConteudo, "?–", "O")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "C")
	cConteudo := StrTran(cConteudo, "ç",  "c")
    cConteudo := StrTran(cConteudo, "Ç",  "C")
	cConteudo := StrTran(cConteudo, "Á",  "A")
    cConteudo := StrTran(cConteudo, "Ã",  "A")
    cConteudo := StrTran(cConteudo, "É",  "E")
    cConteudo := StrTran(cConteudo, "Í",  "I")
    cConteudo := StrTran(cConteudo, "Ó",  "O")
    cConteudo := StrTran(cConteudo, "Õ",  "O")
    cConteudo := StrTran(cConteudo, "Ú",  "U")
    cConteudo := StrTran(cConteudo, "Ç",  "C")
	cConteudo := NoAcento(cConteudo)

Return(Upper(AllTrim(cConteudo)))

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/10/2022
Consultoria: Prox
Uso: SPC
Info: Tratativa para identar a mensagem de erro do execauto da TOTVS
*==================================================================*/
Static Function xIdentaMsg(cMensagem)
	
	Local aMensagem := StrTokArr(cMensagem,Chr(10))
	Local nX        := 0
	Local cTexto    := "Invalido"
	Local cMsgBkp   := ""
	
	cMsgBkp   := cMensagem
	cMensagem := ""
	
	For nX := 1 To Len(aMensagem)

		If nX == 1
			cMensagem += AllTrim(aMensagem[nX])+" - "
		Elseif nX == 2
			cMensagem += AllTrim(xNoAccent(aMensagem[nX]))+" - "
		Elseif cTexto $ AllTrim(aMensagem[nX])
			cMensagem += AllTrim(aMensagem[nX])
		Endif 		
	
	Next nX

	//Caso a mensagem venha em branco utilizo a original 
	If Empty(cMensagem)
		cMensagem := cMsgBkp
	Endif 

Return(cMensagem)


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
