#Include 'Totvs.ch'
#Include 'Parmtype.ch'

/***********************************************************************
--| INFORMA��ES PARA DEPLOY EM PRODU��O |-- 
	
-> Criar �ndice na SE1 para o campo E1_VEND1;
-> Criar campo E1_XIDTRAN na SE1 para armazenar os c�digos de transa��o da Loja Virtual;
-> Criar campo E2_XIDTRAN na SE2 para armazenar os c�digos de transa��o da Loja Virtual na grava��o das taxas;
-> Criar o par�metro LV_TESPF para gravar a TES de Pessoa F�sica no Pedido de Vendas;
-> Criar o par�metro LV_TESPJ para gravar a TES de Pessoa Jur�dica no Pedido de Vendas;
-> Criar o par�metro LV_VEND para gravar o c�digo do vendedor Pag Seguro da Loja Virtual no Pedido de Vendas;
-> Criar o par�metro LV_SERIE para gravar a s�rie da nota fiscal;
-> Criar o par�metro LV_FORNEC para gravar o c�digo do fornecedor que ser� gravado no t�tulo de taxa no contas a pagar;
-> Criar o par�metro LV_PREFIX para gravar o Prefixo que ser� gravado no t�tulo de taxa no contas a pagar;
-> Criar o par�metro LV_NATUR para gravar a natureza que ser� gravada no t�tulo de taxa no contas a pagar;
-> Criar o par�metro LV_CCUSTO para gravar o centro de custo que ser� gravado no t�tulo de taxa no contas a pagar;
-> Criar o par�metro LV_COND1 para gravar o c�digo da condi��o de pagamento de uma �nica parcela no pedido de vendas;
-> Criar o par�metro LV_COND2 para gravar o c�digo da condi��o de pagamento de duas parcelas no pedido de vendas;
-> Criar o par�metro LV_COND3 para gravar o c�digo da condi��o de pagamento de tr�s parcelas no pedido de vendas
************************************************************************/
/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 11/03/2022
Consultoria: Prox
Uso: SPC
Tipo: Atualiza��es
Rotina: Faturamento
Fun��o: SPCFATA4
Info: Integra��o das compras Loja Virtual - Magento x Protheus
************************************************************************/
User Function SPCFATA4(aParams)
    
	Local nPos      := 0
	Local nX        := 0
	Local lProcesOk := .T.

	Private aRetorno  := {}
	Private aProdutos := {}	
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

	//Entidades do Cliente
	cNome     := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Nome"          } ) ) > 0 , aParams[1,nPos,2], "")) //Nome do Cliente	
	cCPF      := IIf(( nPos := aScan( aParams[1], { |x| x[1] == "CPF"           } ) ) > 0 , aParams[1,nPos,2], "") //CPF do Cliente
	cEndereco := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Endereco"      } ) ) > 0 , aParams[1,nPos,2], "")) //Endere�o do Cliente
	cBairro   := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Bairro"        } ) ) > 0 , aParams[1,nPos,2], "")) //Bairro do Cliente
	cCidade   := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Cidade"        } ) ) > 0 , aParams[1,nPos,2], "")) //Cidade do Cliente
	cEstado   := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Estado"        } ) ) > 0 , aParams[1,nPos,2], "")) //Estado do Cliente	 
	cComplem  := xNoAccent(IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Complemento"   } ) ) > 0 , aParams[1,nPos,2], "")) //Complemento do endere�o do Cliente
	cCEP      := IIf(( nPos := aScan( aParams[1], { |x| x[1] == "CEP"           } ) ) > 0 , aParams[1,nPos,2], "") //CEP do endere�o do Cliente	
	cCodMun   := xCodMun() //C�digo do municipio (IBGE)
	cDDD      := IIf(( nPos := aScan( aParams[1], { |x| x[1] == "DDD"           } ) ) > 0 , aParams[1,nPos,2], "") //DDD do telefone do Cliente
	cTelefone := IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Telefone"      } ) ) > 0 , aParams[1,nPos,2], "") //Telefone ou Celular do Cliente
	cEmail    := IIf(( nPos := aScan( aParams[1], { |x| x[1] == "Email"         } ) ) > 0 , aParams[1,nPos,2], "") //E-mail do Cliente
	
	//Entidades do pagamento 
	cIDTrans  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Transacao_ID"         } ) ) > 0 , aParams[2,nPos,2], "") //ID da Transa��o do PagSeguro
	cDebCred  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Debito_Credito"       } ) ) > 0 , aParams[2,nPos,2], "") //Tipo do pagamento se for cart�o de D�bito ou Cr�dito
	cTpTrans  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Tipo_Transacao"       } ) ) > 0 , aParams[2,nPos,2], "") //Tipo da Transa��o do PagSeguro	
	cTpPag    := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Tipo_Pagamento"       } ) ) > 0 , aParams[2,nPos,2], "") //Tipo do Pagamento no PagSeguro
	nVlrBruto := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Bruto"      } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor Bruto
	nVlrDesc  := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Desconto"   } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor de Desconto
	nVlrTaxa  := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Taxa"       } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor da Taxa
	nVlrLiqui := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Liquido"    } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor L�quido
	dDtTrans  := SToD(IIf(( nPos := aScan( aParams[2],{ |x| x[1] == "Data_Transacao"   } ) ) > 0 , aParams[2,nPos,2], "19990101")) //Data da Transa��o
	dDtCompen := SToD(IIf(( nPos := aScan( aParams[2],{ |x| x[1] == "Data_Compensacao" } ) ) > 0 , aParams[2,nPos,2], "19990101")) //Data da Compensa��o
	nParcelas := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Parcelas"         } ) ) > 0 , aParams[2,nPos,2], "0"))	//Quantidade de Parcelas	
	nVlrTrInt := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Tarifa_Int" } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor da Tarifa de Intermedia��o
	nVlrTxInt := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Taxa_Int"   } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor da Taxa de intermedia��o
	nVlrTxPar := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Taxa_Parce" } ) ) > 0 , aParams[2,nPos,2], "0")) //Valor da Taxa de Parcelamento		
	nVlrTrBol := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Tarifa_Bol" } ) ) > 0 , aParams[2,nPos,2], "0"))	//Valor da Tarifa do Boleto
	cBandeira := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Bandeira"             } ) ) > 0 , aParams[2,nPos,2], "") //Bandeira do Cart�o
	cStatus   := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Status"               } ) ) > 0 , aParams[2,nPos,2], "") //Status
	cRefTran  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Ref_Transacao"        } ) ) > 0 , aParams[2,nPos,2], "") //Ref. Transa��o
	
	//Entidade da transportadora
	cTransp   := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Transportadora" } ) ) > 0 , aParams[2,nPos,2], "") //Transportadora
	cNumEnv   := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Num_Envio"      } ) ) > 0 , aParams[2,nPos,2], "") //N�mero de Envio
	cSerial   := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Serial_Leitor"        } ) ) > 0 , aParams[2,nPos,2], "") //Serial Leitor
	nRecebim  := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Recebimentos"     } ) ) > 0 , aParams[2,nPos,2], "0")) //Recebimentos
	nRecebid  := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Recebidos"        } ) ) > 0 , aParams[2,nPos,2], "0")) //Recebidos
	nVlrReceb := Val(IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Valor_Recebido"   } ) ) > 0 , aParams[2,nPos,2], "0")) //Valor Recebido	
	
	//Entidades da compra
	cCodUser  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Codigo_Usuario"       } ) ) > 0 , aParams[2,nPos,2], "") //C�digo do Usu�rio
	cCodVend  := IIf(( nPos := aScan( aParams[2], { |x| x[1] == "Codigo_Venda"         } ) ) > 0 , aParams[2,nPos,2], "") //C�digo da Venda
	
	//Verifico se h� mais de um �nico produto
	If Len(aParams) >= 3
	
		For nX := 3 To Len(aParams)

			If nX >= 3
		
				aAdd(aProdutos,{;
				IIf(( nPos := aScan( aParams[nX], { |x| x[1] == "Produto"        } ) ) > 0 , aParams[nX,nPos,2], ""),;
				Val(IIf(( nPos := aScan( aParams[nX], { |x| x[1] == "Valor"      } ) ) > 0 , aParams[nX,nPos,2], "0")),;
				Val(IIf(( nPos := aScan( aParams[nX], { |x| x[1] == "Quantidade" } ) ) > 0 , aParams[nX,nPos,2], "0"))};
				)

			Endif 

		Next nX	
		
	Endif 
	
	//Valida��es 
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
		lProcesOk := xIncCli() //Inclus�o de Cadastro de Cliente
	Endif 		
	
	//Caso a vari�vel aRetorno estiver vazia significa que o processo ocorreu sem inconsist�ncias
	If Len(aRetorno) == 0
	
		aAdd(aRetorno,{{'Numero',cNumNota},{'Serie',"RPS"},{'Emissao',AllToChar(dDataBase)},{'Value','1'}})
		
	Endif 

Return(aRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 14/03/2022
Consultoria: Prox
Uso: SPC
Info: Inclus�o do Cadastro de Cliente
*==================================================================*/
Static Function xIncCli()
	
	Local aArea     := fwGetArea()    
	Local aAI0Auto  := {}
	Local aSA1Auto  := {}
	Local aLog      := {}
	Local nOpcAuto  := 0
	Local nX        := 0
	Local cMsg      := ""
	Local cCodCli   := ""
	Local cLoja     := ""
	Local lProcesOk := .T.

	Private lMsErroAuto     := .F.
	Private lAutoErrNoFile	:= .T.
	
	//Tratativa para CEP e CPF
	cCPF := AllTrim(StrTran(cCPF,".",""))
	cCPF := AllTrim(StrTran(cCPF,"/","")) 
	cCPF := AllTrim(StrTran(cCPF,"-",""))
	cCEP := AllTrim(StrTran(cCEP,"-",""))
	CONOUT("CPFPESQUISADO->" + cCPF)
	
	DbSelectArea("SA1")
	
	SA1->(DbSetOrder(3))
	CONOUT( SA1->(Indexkey()))
	//Verifico se o cliente � existente na base do Protheus
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
		
		aAdd(aSA1Auto,{"A1_COD" , cCodCli                                  , Nil}) //C�digo
		aAdd(aSA1Auto,{"A1_LOJA", cLoja                                    , Nil}) //Loja
		
	Endif 
	
	aAdd(aSA1Auto,{"A1_NOME"    , SubStr(cNome,1,40)                       , Nil}) //Nome
	aAdd(aSA1Auto,{"A1_NREDUZ"  , SubStr(cNome,1,20)                       , Nil}) //Nome Reduzido
	aAdd(aSA1Auto,{"A1_TIPO"    , "F"                                      , Nil}) //Tipo (F = Consumidor Final) 
	aAdd(aSA1Auto,{"A1_PESSOA"  , IIf(Len(AllTrim(cCPF)) == 14,"J","F")    , Nil}) //Tipo de Pessoa (F = F�sica)
	aAdd(aSA1Auto,{"A1_CGC"     , cCPF                                     , Nil}) //CPF / CNPJ
	aAdd(aSA1Auto,{"A1_END"     , SubStr(cEndereco,1,80)                   , Nil}) //Endere�o
	aAdd(aSA1Auto,{"A1_BAIRRO"  , SubStr(cBairro,1,40)                     , Nil}) //Bairro
	aAdd(aSA1Auto,{"A1_COMPLEM" , SubStr(cComplem,1,40)                    , Nil}) //Complemento do Endere�o
	aAdd(aSA1Auto,{"A1_EST"     , cEstado                                  , Nil}) //Estado (UF)
	aAdd(aSA1Auto,{"A1_COD_MUN" , cCodMun                                  , Nil}) //C�digo do Munic�pio (IBGE)
	aAdd(aSA1Auto,{"A1_CEP"     , cCEP                                     , Nil}) //CEP
	aAdd(aSA1Auto,{"A1_NATUREZ" , "R18004"                                 , Nil}) //Natureza
	aAdd(aSA1Auto,{"A1_EMAIL"   , AllTrim(SubStr(cEmail,1,250))            , Nil}) //E-mail
	aAdd(aSA1Auto,{"A1_CODPAIS" , "01058"                                  , Nil}) //C�digo Pa�s (IBGE)
	aAdd(aSA1Auto,{"A1_RECISS"  , "2"                                      , Nil}) //Recolhe ISS (2 = N�o)
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
			
			DisarmTransaction()
			
		Endif 
	
	End Transaction

	If lProcesOk
		
		DbSelectArea("SA1")
		
		SA1->(DbSetOrder(1))		
		//Verifico se o cliente � existente na base do Protheus
		If SA1->(DbSeek(xFilial("SA1") +  cCodCli + cLoja /*Alltrim(cCPF)*/))
			//conout("[SPCFATA4]-ENCONTROU CLIENTE " + cCodCli + " - " +cLoja )
			conout("[SPCFATA4]-ENCONTROU CLIENTE " + SA1->A1_COD + " - " + SA1->A1_LOJA )
			//Inclus�o do pedido de vendas
			lProcesOk := xIncPed(cCodCli,cLoja)
		
		Else 	
			lProcesOk := .F.
			aAdd(aRetorno,{{'Key',"Cadastro do cliente nao foi realizado!"},{'Value','0'}})	
		Endif 
		
	Endif 
	
	fwRestArea(aArea)
	
Return(lProcesOk) 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Inclus�o do Pedido de Vendas
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
	
	Private lMsErroAuto := .F.
    Private lMsHelpAuto := .T.
	
	//Convers�o dos valores nas strings para adequar aos campos do Protheus no pedido de vendas
	cDebCred := IIf(AllTrim(cDebCred) == "Cr�dito","2","1")
	cTpTrans := IIf(AllTrim(cTpTrans) == "Pagamento","1",IIf(AllTrim(cTpTrans) == "Assinatura","2","3"))
	cTpPag   := IIf(AllTrim(cTpPag) == "Boleto","1",IIf(AllTrim(cTpPag) == "Saldo","3","2"))
	cStatus  := IIf(AllTrim(cStatus) == "Aprovada","1","2")
	conout("[SPCFATA4]-ENCONTROU CLIENTE " + SA1->A1_COD + " - " + SA1->A1_LOJA )
	conout("[SPCFATA4]-ENCONTROU CLIENTE " + cCodCli + " - " + cLoja )	
    //Dados do Cabe�alho
    aAdd(aHeader, {"C5_TIPO"    , "N"      , Nil}) //Tipo do Pedido de Vendas
    aAdd(aHeader, {"C5_CLIENTE" , cCodCli  , Nil}) //C�digo do Cliente
    aAdd(aHeader, {"C5_LOJACLI" , cLoja    , Nil}) //Loja do Cliente
    aAdd(aHeader, {"C5_LOJAENT" , cLoja    , Nil}) //Loja de Entrega do Cliente
    aAdd(aHeader, {"C5_CONDPAG" , cCondPag , Nil}) //Condi��o de Pagamento 
	aAdd(aHeader, {"C5_EMISSAO" , dDtTrans , Nil}) //Data da Transa��o 
	aAdd(aHeader, {"C5_VEND1"   , cVendedor, Nil}) //Loja Online - PagSeguro 
	
	//Dados do Cabe�alho - Customizados - Pag Seguro
    aAdd(aHeader, {"C5_XIDTRAN" , cIDTrans  , Nil}) //ID Transa��o
	aAdd(aHeader, {"C5_XDEBCRE" , cDebCred  , Nil}) //D�bito ou Cr�dito
	aAdd(aHeader, {"C5_XTPTRAN" , cTpTrans  , Nil}) //Tipo da Transa��o
	aAdd(aHeader, {"C5_XTPPAGA" , cTpPag    , Nil}) //Tipo do Pagamento
	aAdd(aHeader, {"C5_XVLBRUT" , nVlrBruto , Nil}) //Valor Bruto
	aAdd(aHeader, {"C5_XVLDESC" , nVlrDesc  , Nil}) //Valor do Desconto
	aAdd(aHeader, {"C5_XVLTAXA" , nVlrTaxa  , Nil}) //Valor da Taxa
	aAdd(aHeader, {"C5_XVLLIQU" , nVlrLiqui , Nil}) //Valor L�quido
	aAdd(aHeader, {"C5_XDTCOMP" , dDtCompen , Nil}) //Data da Compensa��o
	aAdd(aHeader, {"C5_XPARCEL" , nParcelas , Nil}) //Parcelas
	aAdd(aHeader, {"C5_XTARINT" , nVlrTrInt , Nil}) //Tarifa de Intermedia��o
	aAdd(aHeader, {"C5_XTAXINT" , nVlrTxInt , Nil}) //Taxa de Intermedia��o
	aAdd(aHeader, {"C5_XTAXPAR" , nVlrTxPar , Nil}) //Taxa de Parcelamento
	aAdd(aHeader, {"C5_XTARBOL" , nVlrTrBol , Nil}) //Tarifa do Boleto
	aAdd(aHeader, {"C5_XBANDEI" , cBandeira , Nil})	//Bandeira Cart�o
	aAdd(aHeader, {"C5_XSTATUS" , cStatus   , Nil})	//Status
	aAdd(aHeader, {"C5_XTRANSP" , cTransp   , Nil})	//Transportadora
	aAdd(aHeader, {"C5_XNUMENV" , cNumEnv   , Nil})	//N�mero do Envio
	aAdd(aHeader, {"C5_XREFTRA" , cRefTran  , Nil})	//Ref. Transa��o
	aAdd(aHeader, {"C5_XCODUSE" , cCodUser  , Nil})	//C�digo do Usu�rio
	aAdd(aHeader, {"C5_XCODVEN" , cCodVend  , Nil})	//C�digo da Venda
	aAdd(aHeader, {"C5_XSERIAL" , cSerial   , Nil})	//Serial Leitor
	aAdd(aHeader, {"C5_XRECEB1" , nRecebim  , Nil})	//Recebimentos
	aAdd(aHeader, {"C5_XRECEB2" , nRecebid  , Nil})	//Recebidos
	aAdd(aHeader, {"C5_XRECEB3" , nVlrReceb , Nil})	//Valor Recebido
		
    //Dados dos Itens
	
	For nX := 1 To Len(aProdutos)

		aLine     := {}
		nVlrTotal := aProdutos[nX,2] * aProdutos[nX,3]

		aAdd(aLine, {"C6_ITEM"    , AllTrim(cValToChar(StrZero(nX,2))) , Nil}) //C�digo do Produto
		aAdd(aLine, {"C6_PRODUTO" , aProdutos[nX,1]                    , Nil}) //C�digo do Produto 
		aAdd(aLine, {"C6_QTDVEN"  , aProdutos[nX,3]                    , Nil}) //Quantidade 
		aAdd(aLine, {"C6_PRUNIT"  , aProdutos[nX,2]                    , Nil}) //Valor Unit�rio
		aAdd(aLine, {"C6_PRCVEN"  , aProdutos[nX,2]                    , Nil}) //Pre�o de Venda 
		aAdd(aLine, {"C6_VALOR"   , nVlrTotal                          , Nil}) //Valor Total
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
			
			DisarmTransaction()	
			
		Endif
		
	End Transaction 

	If lProcesOk
		//Gero a libera��o do pedido de vendas e a nota fiscal de servi�o
		lProcesOk := xGeraFat(nVlrTaxa,cRefTran,dDtCompen)
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
			
			//Abertura das �reas de trabalho na inclus�o da nota fiscal de sa�da
			DbSelectArea("SF4")
			DbSelectArea("SB1")
			DbSelectArea("SB2")
			DbSelectArea("SE4")
			// ---
			
			aAdd(aPvlNFs,{;
				SC9->C9_PEDIDO,;
				SC9->C9_ITEM,;
				SC9->C9_SEQUEN,;
				SC9->C9_QTDLIB,;
				SC9->C9_PRCVEN,;
				SC9->C9_PRODUTO,;
				SF4->F4_ISS == "S",;
				SC9->(RecNo()),;
				SC5->(Recno(Posicione("SC5",1,xFilial("SC5")+SC9->C9_PEDIDO,""))),;
				SC6->(Recno(Posicione("SC6",1,xFilial("SC6")+SC9->C9_PEDIDO+SC9->C9_ITEM,""))),;
				SE4->(Recno(Posicione("SE4",1,xFilial("SE4")+cCondPag,""))),;
				SB1->(Recno(Posicione("SB1",1,xFilial("SB1")+SC9->C9_PRODUTO,""))),;
				SB2->(Recno(Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,""))),;
				SF4->(Recno(Posicione("SF4",1,xFilial("SF4")+cTes,""))),;
				Posicione("SB2",1,xFilial("SB2")+SC9->C9_PRODUTO,"B2_LOCAL"),;
				1,;
				SC9->C9_QTDLIB2;
				})

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
					
					//Gravo informa��es no t�tulo que foi criado na tabela SE1
					xGravaInfSE1(cNumNota,cSerie,nVlrTaxa,cFilEmp,cCliente,cLojaCli,cRefTran,dDtCompen)
				
				Endif
				
			Endif 	
				
		Endif 	
		
	Else

		lProcesOk := .F.
	
		aAdd(aRetorno,{{'Key',"Pedido de vendas com itens nao liberados!"},{'Value','0'}})	
	
	Endif
	
	//Limpo as vari�veis para um novo processamento
	aPvlNFs := {}	

	//Mensagem de t�rmino de excu��o do Job 
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
Info: Gravo informa��es complementares no t�tulo do Contas a Receber
*==================================================================*/
Static Function xGravaInfSE1(cNumNota,cSerie,nVlrTaxa,cFilEmp,cCliente,cLojaCli,cRefTran,dDtCompen)
	
	DbSelectArea("SE1")
	SE1->(DbSetOrder(2))
	
	If SE1->(DbSeek(AvKey(cFilEmp,"E1_FILIAL")+AvKey(cCliente,"E1_CLIENTE")+AvKey(cLojaCli,"E1_LOJA")+AvKey(cSerie,"E1_PREFIXO")+AvKey(cNumNota,"E1_NUM")))

		//Valida��o criada para impedir a n�o cria��o do titulo no contas a pagar por conta da data conforme alinhado com a SPC no dia 02/01/2023
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
	
	//Valida��o criada para impedir a n�o cria��o do titulo no contas a pagar por conta da data conforme alinhado com a SPC no dia 02/01/2023
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

	MsExecAuto( { |x,y,z| FINA050(x,y,z)},aTitulo,,3)  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
	
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
    
    cQuery := "SELECT CC2_CODMUN, CC2_MUN FROM " + RetSQLName("CC2") 
	cQuery += " WHERE CC2_EST = '" + AllTrim(cEstado) + "'" 
	cQuery += " 	AND CC2_MUN = '" + cCidade + "'" 
	cQuery += "		AND D_E_L_E_T_ = ' '"

	cQuery := ChangeQuery(cQuery)

    DbUseArea(.F., "TOPCONN", TcGenQry(,,cQuery), cTemp, .T., .T.)

    If (cTemp)->(!EOF())
        cRetorno := (cTemp)->CC2_CODMUN
    EndIf

    (cTemp)->(DbCloseArea())
	
Return(cRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 27/04/2022
Consultoria: Prox
Uso: SPC
Info: Condi��es de pagamento conforme a parcela
*==================================================================*/
Static Function xCondPag()

	Local cCondPag  := ""
	Local cUmaParc  := AllTrim(GetMV("LV_COND1",.F.,"000"))
	Local cDuasParc := AllTrim(GetMV("LV_COND2",.F.,"002"))
	Local cTresParc := AllTrim(GetMV("LV_COND3",.F.,"001"))

	If nParcelas == 1 //� vista
		cCondPag := cUmaParc   
	Elseif nParcelas == 2 //Duas Parcelas
		cCondPag := cDuasParc
	Elseif nParcelas == 3  //Tr�s Parcelas
		cCondPag := cTresParc
	Else 
		cCondPag := cUmaParc //Caso n�o caia em nenhuma das op��es aloco � vista	
	Endif

Return(cCondPag)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 25/02/2022
Consultoria: Prox
Uso: SPC
Info: Tratativa para extra��o de caracteres especiais
*==================================================================*/
Static Function xNoAccent(cConteudo)

	//Retirando caracteres
    cConteudo := StrTran(cConteudo, "�", "" )
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
    cConteudo := StrTran(cConteudo, "?�", "a")
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
    cConteudo := StrTran(cConteudo, "?�", "A")
    cConteudo := StrTran(cConteudo, "?" , "A")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "E")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "??", "I")
    cConteudo := StrTran(cConteudo, "?�", "O")
    cConteudo := StrTran(cConteudo, "?�", "O")
    cConteudo := StrTran(cConteudo, "?�", "O")
    cConteudo := StrTran(cConteudo, "?�", "O")
    cConteudo := StrTran(cConteudo, "?�", "O")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "U")
    cConteudo := StrTran(cConteudo, "??", "C")
	cConteudo := StrTran(cConteudo, "�",  "c")
    cConteudo := StrTran(cConteudo, "�",  "C")
	cConteudo := StrTran(cConteudo, "�",  "A")
    cConteudo := StrTran(cConteudo, "�",  "A")
    cConteudo := StrTran(cConteudo, "�",  "E")
    cConteudo := StrTran(cConteudo, "�",  "I")
    cConteudo := StrTran(cConteudo, "�",  "O")
    cConteudo := StrTran(cConteudo, "�",  "O")
    cConteudo := StrTran(cConteudo, "�",  "U")
    cConteudo := StrTran(cConteudo, "�",  "C")
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
