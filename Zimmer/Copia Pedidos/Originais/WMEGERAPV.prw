#Include "rwmake.ch"
#Include "topconn.ch"
#Include "protheus.ch"

/*
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณWMEGERAPV บAutor  ณManoel de Sa        บ Data ณ  25/06/09   บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบDesc.     ณFuncao chamada pelo Ponto de Entrada MT415AUT, com a fina-  บฑฑ
	ฑฑบ          ณlidade de gerar Pedido de Venda a partir dos itens da Agendaบฑฑ
	ฑฑบ          ณde Orcamentos.                                              บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบAltera็ใo ณYttalo P. Martins                                 12/03/2014บฑฑ
	ฑฑบDesc.     ณAgenda foi retirada do processo, or็amento gerarแ diretamenteบฑฑ
	ฑฑบDesc.     ณo pedido de venda com os kits "explodidos"                  บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
	*/

User Function WMEGERAPV()

	Processa({|| RunProc() }, "Gerando Pedido de Venda....")

Return

Static Function RunProc

	Local aCabPv    := {}
	Local aLinItPv  := {}
	Local aItensPv  := {}
	Local aAreaAtu  := GetArea()
	Local aAreaSCJ  := SCJ->(GetArea())
	Local aAreaSCK  := SCK->(GetArea())
	Local aAreaSZ8
	Local cVend     := ""
	Local cCompon   := ""

	Local _aArea   	:= {}
	Local _aAlias   := {}
	Local cAliasSCK := GetNextAlias()

	Private lMsErroAuto := .F.
	Private aLoteSel    := {}
	Private xcLocal := "01"

	// Defina aqui a chamada dos Aliases para o GetArea
	CtrlArea(1,@_aArea,@_aAlias,{"SCK","SCJ","SA1","SF4","SB1"}) // GetArea


	//Retirado por Rafael Fernandes - 07/04/2014
	//IF EMPTY(SCJ->CJ_XDTCIRU) .OR. EMPTY(SCJ->CJ_XHORCIR)
	//	Aviso("AVISO!","Efetiva็ใo nใo serแ possํvel, pois o campo da data ou hora da cirurgia estใo vazios!!",{"Ok"})
	//	Return
	//ENDIF

	ProcRegua(0)

	Begin Transaction

		DbSelectArea("SA1")
		DbSelectArea("ZZ6")
		if ZZ6->(dbSeek(xFilial("ZZ6")+SCJ->CJ_XHOSPIT))
			cCliente := ZZ6->ZZ6_CLIREF
			cLoja    := ZZ6->ZZ6_LJCLRE
		else
			cCliente := SCJ->CJ_XHOSPIT
			cLoja    := Posicione("SA1",1,xFilial("SA1") + cCliente,"A1_LOJA")
		endif
		if !SA1->(DBSeek(xFilial("SA1") + cCliente + cLoja))
			FWAlertInfo("Nใo foi possivel localizar o cliente [" + cCliente + "], favor verificar as informa็๕es e tente novamente", "Cliente nใo encontrado")
			Return
		endif
		cVend    := Iif(!Empty(SCJ->CJ_XVENDED),SCJ->CJ_XVENDED,"020")
		cSuper   := SCJ->CJ_XVEND2
		cGeren   := SCJ->CJ_XVEND3

		aAdd( aCabPv , { "C5_TIPO"      ,"N"         	   	,NIL} ) // Obrigatorio - Beneficiamento, utilizara Fornecedor
		aAdd( aCabPv , { "C5_CLIENTE"   ,cCliente		   	,NIL} ) // Obrigatorio - Codigo do Cliente
		aAdd( aCabPv , { "C5_LOJACLI"   ,cLoja			   	,NIL} ) // Obrigatorio - Loja do Cliente
		aAdd( aCabPv , { "C5_CLIENT"    ,cCliente			,NIL} ) // Cliente de Entrega
		aAdd( aCabPv , { "C5_LOJAENT"   ,cLoja				,NIL} ) // Obrigatorio - Loja do Entrega
		aAdd( aCabPv , { "C5_TIPOCLI"   ,"F"  				,NIL} ) // Tipo do Cliente
		aAdd( aCabPv , { "C5_TPFRETE"   ,"C"       			,NIL} ) // Tipo do Frete
		aAdd( aCabPv , { "C5_CONDPAG"   ,SCJ->CJ_CONDPAG 	,NIL} ) // Condicao de pagamento
		aAdd( aCabPv , { "C5_TABELA"    ,SCJ->CJ_TABELA 	,NIL} ) // Tabela de Precos
		aAdd( aCabPv , { "C5_XPACIEN"   ,SCJ->CJ_XPACIEN 	,NIL} ) // Codigo do Paciente
		aAdd( aCabPv , { "C5_XNOMPAC"   ,SCJ->CJ_XNOMPAC 	,NIL} ) // Nome do Paciente
		aAdd( aCabPv , { "C5_XORCAM"    ,SCJ->CJ_NUM		,NIL} ) // Numero do Orcamento
		aAdd( aCabPv , { "C5_XMEDICO"   ,SCJ->CJ_XMEDICO 	,NIL} ) // Codigo do Medico
		aAdd( aCabPv , { "C5_XNOMMED"   ,SCJ->CJ_XNOMMED 	,NIL} ) // Nome do Medico
		aAdd( aCabPv , { "C5_XCONVEN"   ,SCJ->CJ_XCONVEN 	,NIL} ) // Codigo do Convenio
		aAdd( aCabPv , { "C5_XNOMCON"   ,SCJ->CJ_XNOMCON 	,NIL} ) // Nome do Convenio
		aAdd( aCabPv , { "C5_XHOSPIT"   ,SCJ->CJ_XHOSPIT 	,NIL} ) // Codigo do Hospital
		aAdd( aCabPv , { "C5_XNOMHOS"   ,SCJ->CJ_XNOMHOS 	,NIL} ) // Nome do Hospital
		aAdd( aCabPv , { "C5_XDTCIRU"   ,SCJ->CJ_XDTCIRU 	,NIL} ) // Data da Cirurgia
		aAdd( aCabPv , { "C5_XHORCIR"   ,SCJ->CJ_XHORCIR 	,NIL} ) // Hora da Cirurgia
		aAdd( aCabPv , { "C5_MOEDA"     ,1    			   	,NIL} ) // Moeda
		aAdd( aCabPv , { "C5_EMISSAO"   ,dDataBase   		,NIL} ) // Data de emissao
		aAdd( aCabPv , { "C5_PESOL"     ,0.01       	   	,NIL} ) // Peso Liquido
		aAdd( aCabPv , { "C5_PBRUTO"    ,0.01       	   	,NIL} ) // Peso Bruto
		aAdd( aCabPv , { "C5_TXMOEDA"   ,1    			   	,NIL} ) // Taxa da Moeda
		aAdd( aCabPv , { "C5_TPCARGA"   ,"2"        	  	,NIL} ) // Carga no OMS 1-Utiliza - 2-Nao utiliza
		aAdd( aCabPv , { "C5_ORCRES"    ," "		   	  	,NIL} ) // Numero do Orcamento
		aAdd( aCabPv , { "C5_TIPLIB"    ,"1"         		,NIL} ) // 1-Por Item - 2-Por PV
		aAdd( aCabPv , { "C5_VEND1"     ,cVend				,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_VEND2"     ,cSuper				,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_VEND3"     ,cGeren				,NIL} ) // Cod do Vendedor
		//Incluido por Rafael Fernandes - 09/04/2014 - Inicio
		aAdd( aCabPv , { "C5_XUSRINC"   ,UsrFullName(__cUserID),NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_XDATINC"   ,Date()				,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_XHORINC"   ,Time()				,NIL} ) // Cod do Vendedor

		aAdd( aCabPv , { "C5_XNOMVEN"   ,SCJ->CJ_XNOMVEN	,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_VEND4"     ,SCJ->CJ_XVEND4		,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_XINSTRM"   ,SCJ->CJ_XNOMINS	,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_XPROCED"   ,SCJ->CJ_XPROCED	,NIL} ) // Cod do Vendedor
		aAdd( aCabPv , { "C5_XDESPRO"   ,SCJ->CJ_XNOMPRO	,NIL} ) // Cod do Vendedor

		// Alterado por Jos้ de Assun็ใo - Totvs RJ [ 23/11/2017 ]
		// Criado para herdar a informa็ใo do Cod/Desc Projeto
		aAdd( aCabPv , { "C5_XPROJET"  	,SC5->C5_XPROJET     ,NIL} ) // CODIGO DO PROJETO
		aAdd( aCabPv , { "C5_XDESCPR"  	,SC5->C5_XDESCPR     ,NIL} ) // DESCRICAO DO PROJETO

		//Incluido por Rafael Fernandes - 09/04/2014 - Fim
		// aCabPv := U_xOrdVetSX3(aCabPv,"SC5")

		aLinItPv := {}
		aItensPv := {}
		nItem    := "01"

		If Select(cAliasSCK)>0
			DbSelectArea(cAliasSCK)
			DbCloseArea()
		Endif

		cQuery := "SELECT SCK.*,SCK.R_E_C_N_O_ SCKRECNO "
		cQuery += "FROM "+RetSqlName("SCK")+" SCK "
		cQuery += "WHERE "
		cQuery += "SCK.CK_FILIAL='"+xFilial("SCK")+"' AND "
		cQuery += "SCK.CK_NUM='"+SCJ->CJ_NUM+"' AND "
		cQuery += "SCK.D_E_L_E_T_<>'*'"
		cQuery += "ORDER BY "+SqlOrder(SCK->(IndexKey()))

		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSCK , .F., .T.)
		dbselectarea(cAliasSCK)
		(cAliasSCK)->(DBGOTOP())

		While (cAliasSCK)->(!Eof())

			IncProc('Gerando pedido...')
			aLoteSel    := {}

			If !( (cAliasSCK)->CK_XSITUA $ "N|P" )

				// Pontera no Componente para identificar os produtos que o comp๕e
				dbSelectArea("SZ8") // Cadastro de Componentes
				dbSetOrder(1)       // Componentes + Produto
				If dbSeek(xFilial("SZ8") + (cAliasSCK)->CK_PRODUTO) //  Item do Orcamento e um Componente de Procedimento Cirurgico

					While SZ8->Z8_FILIAL + SZ8->Z8_COMPON == xFilial("SZ8") + (cAliasSCK)->CK_PRODUTO .and. !Eof()

						aAreaSZ8  := SZ8->(GetArea())

						dbSelectArea("SB1")
						dbSetOrder(1)
						dbSeek(xFilial("SB1") + SZ8->Z8_PRODUTO)

						xcLocal   := IIF( EMPTY((cAliasSCK)->CK_LOCAL),SB1->B1_LOCPAD,(cAliasSCK)->CK_LOCAL)
						cDesc     := AllTrim(SB1->B1_DESC)
						cUm       := SB1->B1_UM

						cTes	  := U_xTesInt(SZ8->Z8_PRODUTO,"8")

						If Empty (cTes)
							cTes := If(Empty(SuperGetMV("MV_TESEMPS")),"580",SuperGetMV("MV_TESEMPS"))
						Endif

						dbSelectArea("SF4")
						dbSetOrder(1)
						dbSeek(xFilial("SF4") + cTes)

						cCf      := SF4->F4_CF
						dEntreg  := STOD((cAliasSCK)->CK_ENTREG)
						cOrig    := SB1->B1_ORIGEM
						cCst	 := SF4->F4_SITTRIB
						cClasFis := ALLTRIM(cOrig)+ALLTRIM(cCst)

						dbSelectArea("SB2")
						dbSetOrder(2)
						If !dbSeek(xFilial("SB2") + PADR( AllTrim(xcLocal),TamSx3("B2_LOCAL")[1] ) + PADR( AllTrim(SZ8->Z8_PRODUTO),TamSx3("B1_COD")[1] ) )

							CriaSB2(PADR( AllTrim(SZ8->Z8_PRODUTO),TamSx3("B1_COD")[1] ),PADR( AllTrim(xcLocal),TamSx3("B2_LOCAL")[1] ) )

						EndIf

						aAdd( aLinItPv , {"C6_ITEM"       ,nItem							,NIL}) // Obrigatorio - Item do Pedido de Venda
						aAdd( aLinItPv , {"C6_PRODUTO"    ,SZ8->Z8_PRODUTO			      	,NIL}) // Obrigatorio - Produto
						aAdd( aLinItPv , {"C6_UM"         ,cUm       						,NIL}) // Obrigatorio - Unidade de Medida
						aAdd( aLinItPv , {"C6_QTDVEN"     ,SZ8->Z8_QUANT * (cAliasSCK)->CK_QTDVEN			,NIL}) // Obrigatorio - Quantidade vendida
						aAdd( aLinItPv , {"C6_QTDLIB"     ,0  					 			,NIL}) // Quantidade liberada
						aAdd( aLinItPv , {"C6_PRCVEN"     ,(cAliasSCK)->CK_PRCVEN    		,NIL}) // Preco unitario
						aAdd( aLinItPv , {"C6_XPRCMIN"    ,(cAliasSCK)->CK_XPRCMIN    		,NIL}) // Preco Minimo
						aAdd( aLinItPv , {"C6_TES"        ,cTes								,NIL}) // Obrigatorio - TES
						aAdd( aLinItPv , {"C6_LOCAL"      ,xcLocal		        			,NIL}) // Obrigatorio - Armazem
						aAdd( aLinItPv , {"C6_CF"         ,cCf		          				,NIL}) // Obrigatorio - Classifica็ใo Fiscal
						aAdd( aLinItPv , {"C6_CLI"        ,cCliente     					,NIL}) // Obrigatorio - Classifica็ใo Fiscal
						aAdd( aLinItPv , {"C6_ENTREG"     ,dEntreg		  		    		,NIL}) // Data prevista para entrega
						aAdd( aLinItPv , {"C6_LOJA"       ,cLoja		     				,NIL}) // Obrigatorio - Classifica็ใo Fiscal
						aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc							,NIL}) // Descricao do Produto
						aAdd( aLinItPv , {"C6_PRUNIT"     ,(cAliasSCK)->CK_PRUNIT  			,NIL}) // Obrigatorio - Preco de Lista
						aAdd( aLinItPv , {"C6_LOTECTL"    ,CRIAVAR("C6_LOTECTL")			,NIL}) // Lote
						aAdd( aLinItPv , {"C6_DTVALID"    ,CTOD("  /  /  ")					,NIL}) // Validade do Lote
						aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis			    			,NIL}) // Obrigatorio - Classificacao fiscal
						aAdd( aLinItPv , {"C6_TPOP"       ,"F"             					,NIL}) // Tipo da OP - F-Firme
						aAdd( aLinItPv , {"C6_XESTOQ"     ,"N"					  			,NIL}) // Informa se item foi inserido pela Agenda
						if !Empty((cAliasSCK)->CK_XKIT)
							aAdd( aLinItPv , {"C6_XKIT" ,(cAliasSCK)->CK_XKIT  			,NIL}) // Codigo do KIT
							aAdd( aLinItPv , {"C6_XKITORG" ,"ORC" 						,NIL}) // Informa que o KIT tem origem no orcamento
						endif

						aAdd( aItensPv , aClone( aLinItPv ) )
						aLinItPv := {}
						nItem := Soma1(nItem)

						RestArea(aAreaSZ8)

						dbSelectArea("SZ8")
						dbSkip()

					Enddo


					// Trata-se de Instrumental
				Else


					dbSelectArea("SB1")
					dbSetOrder(1)
					dbSeek(xFilial("SB1") + (cAliasSCK)->CK_PRODUTO)

					xcLocal   := SB1->B1_LOCPAD
					cDesc     := AllTrim(SB1->B1_DESC)
					cUm       := SB1->B1_UM

					cTes	  := U_xTesInt((cAliasSCK)->CK_PRODUTO,"8")

					If Empty (cTes)
						cTes := If(Empty(SuperGetMV("MV_TESEMPS")),"580",SuperGetMV("MV_TESEMPS"))
					Endif

					dbSelectArea("SF4")
					dbSetOrder(1)
					dbSeek(xFilial("SF4") + cTes)

					cCf      := SF4->F4_CF
					dEntreg  := STOD((cAliasSCK)->CK_ENTREG)
					cOrig    := SB1->B1_ORIGEM
					cCst	 := SF4->F4_SITTRIB
					cClasFis := ALLTRIM(cOrig)+ALLTRIM(cCst)

					dbSelectArea("SB2")
					dbSetOrder(2)
					If !dbSeek(xFilial("SB2") + PADR( AllTrim(xcLocal),TamSx3("B2_LOCAL")[1] ) + PADR( AllTrim((cAliasSCK)->CK_PRODUTO),TamSx3("B1_COD")[1] ) )
						CriaSB2(PADR( AllTrim((cAliasSCK)->CK_PRODUTO),TamSx3("B1_COD")[1] ),PADR( AllTrim(xcLocal),TamSx3("B2_LOCAL")[1] ) )
					EndIf

					aAdd( aLinItPv , {"C6_ITEM"       ,nItem							,NIL}) // Obrigatorio - Item do Pedido de Venda
					aAdd( aLinItPv , {"C6_PRODUTO"    ,(cAliasSCK)->CK_PRODUTO	      	,NIL}) // Obrigatorio - Produto
					aAdd( aLinItPv , {"C6_UM"         ,cUm       						,NIL}) // Obrigatorio - Unidade de Medida
					aAdd( aLinItPv , {"C6_QTDVEN"     ,(cAliasSCK)->CK_QTDVEN			,NIL}) // Obrigatorio - Quantidade vendida
					aAdd( aLinItPv , {"C6_QTDLIB"     ,0  					 			,NIL}) // Quantidade liberada
					aAdd( aLinItPv , {"C6_PRCVEN"     ,(cAliasSCK)->CK_PRCVEN    		,NIL}) // Preco unitario
					aAdd( aLinItPv , {"C6_XPRCMIN"    ,(cAliasSCK)->CK_XPRCMIN    		,NIL}) // Preco Minimo
					aAdd( aLinItPv , {"C6_TES"        ,cTes								,NIL}) // Obrigatorio - TES
					aAdd( aLinItPv , {"C6_LOCAL"      ,xcLocal		        			,NIL}) // Obrigatorio - Armazem
					aAdd( aLinItPv , {"C6_CF"         ,cCf		          				,NIL}) // Obrigatorio - Classifica็ใo Fiscal
					aAdd( aLinItPv , {"C6_CLI"        ,cCliente		     				,NIL}) // Obrigatorio - Classifica็ใo Fiscal
					aAdd( aLinItPv , {"C6_ENTREG"     ,dEntreg		  		    		,NIL}) // Data prevista para entrega
					aAdd( aLinItPv , {"C6_LOJA"       ,cLoja		     				,NIL}) // Obrigatorio - Classifica็ใo Fiscal
					aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc							,NIL}) // Descricao do Produto
					aAdd( aLinItPv , {"C6_PRUNIT"     ,(cAliasSCK)->CK_PRUNIT  			,NIL}) // Obrigatorio - Preco de Lista
					aAdd( aLinItPv , {"C6_LOTECTL"    ,CRIAVAR("C6_LOTECTL")			,NIL}) // Lote
					aAdd( aLinItPv , {"C6_DTVALID"    ,CTOD("  /  /  ")					,NIL}) // Validade do Lote
					aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis			    			,NIL}) // Obrigatorio - Classificacao fiscal
					aAdd( aLinItPv , {"C6_TPOP"       ,"F"             					,NIL}) // Tipo da OP - F-Firme
					aAdd( aLinItPv , {"C6_XESTOQ"     ,"N"					  			,NIL}) // Informa se item foi inserido pela Agenda
					if !Empty((cAliasSCK)->CK_XKIT)
						aAdd( aLinItPv , {"C6_XKIT" ,(cAliasSCK)->CK_XKIT  			,NIL}) // Codigo do KIT
						aAdd( aLinItPv , {"C6_XKITORG" ,"ORC" 						,NIL}) // Informa que o KIT tem origem no orcamento
					endif

					aAdd( aItensPv , aClone( aLinItPv ) )
					aLinItPv := {}
					nItem := Soma1(nItem)


				Endif

			Endif

			dbSelectArea((cAliasSCK))
			dbSkip()

		Enddo

		If Select(cAliasSCK)>0
			DbSelectArea(cAliasSCK)
			DbCloseArea()
		Endif

		CtrlArea(2,_aArea,_aAlias) // RestArea

		If Len(aItensPv) > 0

			dbSelectArea("SC5")
			dbSetOrder(1)

			dbSelectArea("SC6")
			dbSetOrder(1)

			aArea_SCJ := SCJ->(GetArea())

			aCabPv		:= FWVetByDic(aCabPv, "SC5")
			aItensPv	:= FWVetByDic(aItensPv, "SC6", .T.)

			MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItensPv,3)

			RestArea(aArea_SCJ)

			If lMsErroAuto
				// cPath := "C:\LogSiga"
				// cFile := StrTran(Dtoc(dDataBase),"/","")+"_"+StrTran(Time(),":","")+"_"+AllTrim(SCJ->CJ_NUM)+".log"
				MostraErro()
				// MsgAlert("Pedido de Venda nao gerado."+chr(13)+chr(10)+;
					// 	"Verifique o LOG (" + cFile + ") na pasta C:\LogSiga do sistema.", "Atencao !")
				DisarmTransaction()
			Else

				If !EMPTY(SCJ->CJ_XDTLIBO) .AND. ALLTRIM(SCJ->CJ_STATUS) <> "B"

					RecLock("SCJ",.F.)
					SCJ->CJ_STATUS := "B"  // Aprovado - Gerou Pedido de Venda
					("SCJ")->(MsUnLock())

				EndIf

				dbSelectArea("SCK")
				dbSetOrder(1)
				If dbSeek(xFilial("SCK") + SCJ->CJ_NUM)

					While SCK->CK_FILIAL + SCK->CK_NUM == xFilial("SCK") + SCJ->CJ_NUM .and. !Eof()

						RecLock("SCK",.F.)
						SCK->CK_NUMPV := SC5->C5_NUM
						("SCK")->(MsUnLock())

						("SCK")->(dbSkip())
					Enddo

				EndIf

				__cArea := GetArea()

				dbSelectArea("SC6")
				dbSetOrder(1)
				dbSeek(xFilial("SC6") + SC5->C5_NUM)
				While SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC5->C5_NUM .and. ("SC6")->(!Eof())

					__cArea2 := GetArea()

					cCompon  := ""

					dbSelectArea("SZ8")
					dbSetOrder(2)
					If dbSeek(xFilial("SZ8") + SC6->C6_PRODUTO)
						cCompon := SZ8->Z8_COMPON
					EndIf

					RestArea(__cArea2)


					RecLock("SC6",.F.)

					SC6->C6_NUMORC := SC5->C5_XORCAM
					SC6->C6_XCOMPON := cCompon

				/*
				//INICIO------------------------------------------------------------------------------
				//Descomentar este trecho caso queira a libera็ใo automแtica do pedido de venda-------
				
				nC6QtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )
			
				If nC6QtdLib > 0
			
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLibera por Item de Pedido                                               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Begin Transaction
					MaLibDoFat(SC6->(RecNo()),@nC6QtdLib,.F.,.F.,.T.,.T.,.F.,.F.)
					End Transaction
						
				EndIf                                                                                 
				
				//FIM---------------------------------------------------------------------------------
				//Descomentar este trecho caso queira a libera็ใo automแtica do pedido de venda-------						
				*/

					("SC6")->(MsUnLock())

					("SC6")->(dbSkip())

				Enddo

			/*
			//INICIO------------------------------------------------------------------------------
			//Descomentar este trecho caso queira a libera็ใo automแtica do pedido de venda-------		
			
			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o Flag do Pedido de Venda                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Begin Transaction
			SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			End Transaction
			
			//FIM---------------------------------------------------------------------------------
			//Descomentar este trecho caso queira a libera็ใo automแtica do pedido de venda-------						
			*/				

				RestArea(__cArea)

				//U_WF_410A()//gera workflow

				//Incproc()

				Aviso("AVISO!","Pedido de Venda n๚mero " + SC5->C5_NUM + " gerado com sucesso.",{"Ok"})
				//alert("email enviado")

			Endif

			lMsErroAuto := .F.

		Else

			Aviso("AVISO!","Pedido de Venda nใo serแ gerado, pois nใo hแ itens associados!!",{"Ok"})

		Endif


	End Transaction

	RestArea(aAreaSCJ)
	RestArea(aAreaSCK)
	RestArea(aAreaAtu)

Return

	**********************************************************************************************************************************

User Function xOrdVetSX3(_aArray, cAliasSX3)

	Local _aSX3Area := SX3->(GETAREA())
	Local _aAux     := {}
	Local _nPos     := 0

	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek(cAliasSX3)

		While !Eof() .And. (X3_ARQUIVO==cAliasSX3)

			//Acerta array com somente uma linha
			If (_nPos:= aScan(_aArray,{|x| Alltrim(x[1]) == Alltrim(X3_CAMPO) })) <> 0
				aadd(_aAux,aClone(_aArray[_nPos]))
			EndIf

			dbSkip()

		EndDo

	Else
		_aAux := _aArray
	EndIf

	RESTAREA(_aSX3Area)

Return(_aAux)

	**********************************************************************************************************************************

	/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
	ฑฑบPrograma  ณ CtrlArea บ Autor ณRicardo Mansano     บ Data ณ 18/05/2005  บฑฑ
	ฑฑฬออออออออออุออออออออออสอออออออุออออออออัอออออออออออสออออออฯอออออออออออออนฑฑ
	ฑฑบLocacao   ณ Fab.Tradicional  ณContato ณ mansano@microsiga.com.br       บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออฯออออออออฯออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบDescricao ณ Static Function auxiliar no GetArea e ResArea retornando   บฑฑ
	ฑฑบ          ณ o ponteiro nos Aliases descritos na chamada da Funcao.     บฑฑ
	ฑฑบ          ณ Exemplo:                                                   บฑฑ
	ฑฑบ          ณ Local _aArea  := {} // Array que contera o GetArea         บฑฑ
	ฑฑบ          ณ Local _aAlias := {} // Array que contera o                 บฑฑ
	ฑฑบ          ณ                     // Alias(), IndexOrd(), Recno()        บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑบ          ณ // Chama a Funcao como GetArea                             บฑฑ
	ฑฑบ          ณ P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         บฑฑ
	ฑฑบ          ณ                                                            บฑฑ
	ฑฑบ          ณ // Chama a Funcao como RestArea                            บฑฑ
	ฑฑบ          ณ P_CtrlArea(2,_aArea,_aAlias)                               บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบParametrosณ nTipo   = 1=GetArea / 2=RestArea                           บฑฑ
	ฑฑบ          ณ _aArea  = Array passado por referencia que contera GetArea บฑฑ
	ฑฑบ          ณ _aAlias = Array passado por referencia que contera         บฑฑ
	ฑฑบ          ณ           {Alias(), IndexOrd(), Recno()}                   บฑฑ
	ฑฑบ          ณ _aArqs  = Array com Aliases que se deseja Salvar o GetArea บฑฑ
	ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	ฑฑบAplicacao ณ Generica.                                                  บฑฑ
	ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
	ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
	฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

	Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)

	Local _nN

	// Tipo 1 = GetArea()
	If _nTipo == 1
		
		_aArea   := GetArea()
		
		For _nN  := 1 To Len(_aArqs)
			
			DbSelectArea(_aArqs[_nN])
			AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})
			
		Next
		
		// Tipo 2 = RestArea()
	Else
		
		For _nN := 1 To Len(_aAlias)
			
			DbSelectArea(_aAlias[_nN,1])
			DbSetOrder(_aAlias[_nN,2])
			DbGoto(_aAlias[_nN,3])
			
		Next
		
		RestArea(_aArea)
		
	Endif

	Return Nil
