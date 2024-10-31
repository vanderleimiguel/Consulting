#Include "rwmake.ch"
#Include "topconn.ch"
#include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWMEA007   บAutor  ณManoel de Sa        บ Data ณ  14/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para verificacao de itens da Nota Fiscal de Retorno  บฑฑ
ฑฑบ          ณcom a finalidade de, se necessario, gerar Pedido de Venda   บฑฑ
ฑฑบ          ณpara faturamento dos itens indicados.                       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function WMEA007()
	Local cNFTela		:= SF1->F1_DOC
	Local cSerieTela	:= SF1->F1_SERIE
	Private oButton1
	Private oButton2
	Private oButton3
	Private oGroup1
	Private oMeter1
	Private nMeter1
	Private oMeter2
	Private nMeter2
	Private oMeter3
	Private nMeter3
	Private oMeter4
	Private nMeter4
	Private oMeter5
	Private nMeter5
	Private oMeter6
	Private nMeter6
	Private oMeter7
	Private nMeter7
	Private oSay1
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay13
	Private oSay2
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private cPoder3		:= ""
	Private oDlg
	Private cNFOri		:= ""
	Private cSerOri		:= ""



	DEFINE MSDIALOG oDlg TITLE "PROCESSO DE RETORNO/GERAวรO AUTOMมTICA DE PV." FROM 000, 000  TO 400, 500 COLORS 0, 16777215 PIXEL

	//@ 017, 003 MSPANEL oPanel1 SIZE 245, 167 OF oDlg COLORS 0, 16777215 RAISED
	@ 008, 003 GROUP oGroup1 TO 160, 250 PROMPT "Monitorando o retorno, aguarde o processamento da NF:"+cNFTela+"/"+cSerieTela+"..." OF oDlg COLOR 0, 16777215 PIXEL

	@ 032, 009 SAY oSay1 PROMPT "1 - Endere็ando produtos retornados..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 039, 010 METER oMeter2 VAR nMeter2 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 039, 100 SAY oSay2 PROMPT "........................100% concluํdo" SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 053, 009 SAY oSay3 PROMPT "2 - Preparando item(ns) para gera็ใo do PV..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 060, 010 METER oMeter3 VAR nMeter3 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 061, 100 SAY oSay4 PROMPT "........................100% concluํdo" SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 073, 009 SAY oSay5 PROMPT "3 - Transferindo produtos marcados para faturamento..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 080, 010 METER oMeter4 VAR nMeter4 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 081, 100 SAY oSay6 PROMPT "........................100% concluํdo" SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 093, 009 SAY oSay7 PROMPT "4 - Gerando PV para faturamento..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 100, 010 METER oMeter5 VAR nMeter5 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 101, 100 SAY oSay8 PROMPT "........................100% concluํdo" SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 113, 009 SAY oSay9 PROMPT "5 - Gerando PV Rep. auto Poder Terceiros..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 120, 010 METER oMeter6 VAR nMeter6 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 120, 100 SAY oSay10 PROMPT cPoder3 SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 133, 009 SAY oSay11 PROMPT "6 - Enviando E-mail sobre o retorno de NFs..." SIZE 200, 007 OF oGroup1 COLORS 0, 16777215 PIXEL
	@ 140, 010 METER oMeter7 VAR nMeter7 SIZE 075, 008 OF oGroup1 TOTAL 100 COLOR 0, 16777215 PIXEL
	@ 140, 100 SAY oSay12 PROMPT "........................100% concluํdo" SIZE 101, 007 OF oGroup1 COLORS 0, 16777215 PIXEL

	@ 175, 150 BUTTON oButton1 PROMPT "Processar"  ACTION(Processa({||fGeraBARRA()},"Verificando necessidade de gerar Pedido de Venda...")) SIZE 037, 012 OF oDlg PIXEL
	@ 175, 200 BUTTON oButton2 PROMPT "Fechar" ACTION(oDlg:End()) SIZE 037, 012 OF oDlg PIXEL
	@ 175, 010 BUTTON oButton3 PROMPT "Rel. Qualidade>>" ACTION(U_WMER019(cNFOri,cSerOri)) SIZE 060, 012 OF oDlg PIXEL

	oSay2:lVisibleControl		:= .F.
	oSay4:lVisibleControl		:= .F.
	oSay6:lVisibleControl		:= .F.
	oSay8:lVisibleControl		:= .F.
	oSay10:lVisibleControl		:= .F.
	oSay12:lVisibleControl		:= .F.
	oButton2:lVisibleControl	:= .F.
	oButton3:lVisibleControl	:= .F.

	ACTIVATE MSDIALOG oDlg CENTERED




Return .T.
	******************************
Static Function fGeraBARRA()
	******************************
	Local lErro      := .F.
	Private aAreaAtu   := GetArea()
	Private aAreaSC5   := SC5->(GetArea())
	Private aAreaSC6   := SC6->(GetArea())
	Private aAreaSC9   := SC9->(GetArea())
	Private aAreaSCJ   := SCJ->(GetArea())
	Private aAreaSCK   := SCK->(GetArea())
	Private aAreaSF1   := SF1->(GetArea())
	Private aAreaSD1   := SD1->(GetArea())
	Private aAreaSF2   := SF2->(GetArea())
	Private aAreaSD2   := SD2->(GetArea())
	Private aAreaSDA   := SDA->(GetArea())
	Private aAreaSDB   := SDB->(GetArea())
	Private aAreaSB6   := SB6->(GetArea())
	Private aAreaSF4   := SF4->(GetArea())
	Private aAreaSA7   := SA7->(GetArea())
	Private aAreaSA1   := SA1->(GetArea())
	Private aAreaSA3   := SA3->(GetArea())

	Private cNf      := ""
	Private aCabPv   := {}
	Private aCabPvP3 := {}
	Private aItensPv := {}
	Private aLinItPv := {}
	Private aItPvTer := {}
	Private lGeraCab := .F.
	Private lGerCabP3:= .F.
	Private nItem    := 0
	Private lGeraPV  :=	.F.
	Private cNrPvTer := ""

	Private cFilial		:= SF1->F1_FILIAL
	Private cNF	  		:= SF1->F1_DOC
	Private cSerie		:= SF1->F1_SERIE
	Private cCliente	:= SF1->F1_FORNECE
	Private cloja		:= SF1->F1_LOJA

	Private cCodOri		:= ""
	Private cItemOri	:= ""

	Private cPedWF      := ""//pedido gerado que serแ usado no workflow
	Private __aArea
	Private cArmazem 	:= ""

	Private cNumOrcam 	:= ""

	//--------------------------------------------
	PUBLIC xaSD3Doc     := {}

	//monitorar responsแvel pela entrada da nota
	RecLock("SF1",.F.)
	SF1->F1_XCONFER	:= cUserName
	SF1->(MsUnLock())


	//--------------------------------------------

	/*
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
	ฑฑบ                                                                        บฑฑ
	ฑฑบ Customiza็ใo so pode ser executada para NFs diferentes do tipo "N"     บฑฑ
	ฑฑบ                                                                        บฑฑ
	ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
	ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	*/

	IF (SF1->F1_TIPO <> "N")

		__aArea := GetArea()

		cNFEnt := cFilial + cNF + cSerie + cCliente + cLoja

		dbSelectArea("SD1") // Itens da NF
		dbSetOrder(1)       // Filial + Documeto + Serie + Fornecedor + Loja
		dbSeek(cNFEnt)

		cNFOri		:= SD1->D1_NFORI
		cSerOri		:= SD1->D1_SERIORI
		cCodOri		:= SD1->D1_COD
		cItemOri	:= SD1->D1_ITEMORI

		/*
		ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
		ฑฑบ                                                                        บฑฑ
		ฑฑบ Verifica todos os itens da Nota Fiscal de Entrada tipo "D" ou "B" com  บฑฑ
		ฑฑบ a finalidade de identificar se algum item foi marcado para faturamento บฑฑ
		ฑฑบ (D1_XFATSN = "1") = SIM                                                บฑฑ
		ฑฑบ                                                                        บฑฑ
		ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
		ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
		*/

		While xFilial("SD1")+ SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA = cNFEnt .and. SD1->(!Eof())

			If SD1->D1_XFATSN = "1" // SIM
				lGeraPV  :=	.T.
			Endif

			SD1->(dbSkip())

		Enddo

		/*
		ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
		ฑฑบ                                                                       บฑฑ
		ฑฑบ Executa fun็ใo para endere็ar todos itens da NFe de Retorno           บฑฑ
		ฑฑบ antes de transferir, gerar PV e liberar PV                            บฑฑ
		ฑฑบ Analista Resp. Yttalo P.Martins                                       บฑฑ
		ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
		*/

		ProcRegua(100)

		fEnderNF() // Fun็ใo para Endere็ar os itens da NF de Retorno

		/*
		ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
		ฑฑบ                                                                       บฑฑ
		ฑฑบ Executa fun็ใo para carregar vetor com Itens marcados para Faturamen- บฑฑ
		ฑฑบ to. lGeraPV  :=	.T.         										  บฑฑ
		ฑฑบ                                                                       บฑฑ
		ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
		ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
		*/
		If lGeraPV
			ProcRegua(50)

			fGeraVetorPV()

			*'Yttalo P. Martins_INICIO--------------------------------------------------------------'*
			//Realiza transfer๊ncia dos itens a serem faturados para o armaz้m 35 no endere็o EMPENHO
			Begin Transaction

				ProcRegua(50)

				fEnderPed(@lErro)

				If lErro == .T.
					DisarmTransaction()
					Break
				EndIf

			End Transaction
			*'Yttalo P. Martins_FIM-----------------------------------------------------------------'*

		EndIf


		/*
		ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
		ฑฑบ                                                                       บฑฑ
		ฑฑบ Verifica se o vetor esta carregado com algum item para gerar Pedido deบฑฑ
		ฑฑบ Venda. ((aCabPv > 0) = .T.)											  บฑฑ
		ฑฑบ                                                                       บฑฑ
		ฑฑบ	Analista Resp. Jos้ de Assun็ใo					                      บฑฑ
		ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
		*/
		If Len(aCabPv) > 0

			Processa({||U_fGeraPv()},"Gerando Pedido de Venda para Faturamento...")  // Gera Pedido de Venda

			/*
			ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
			ฑฑบ Gera PV Reposi็ใo Automatica Poder de Terceiros                       บฑฑ
			ฑฑบ 																	  บฑฑ
			ฑฑบ Verifica se o vetor esta carregado com algum item para gerar Pedido deบฑฑ
			ฑฑบ Venda referente a remessa 'Reposicao Autom. P3' para cobrir Qtd minimaบฑฑ
			ฑฑบ	que deverแ constar com o cliente, cadastrada em Cliente x Fornecedor. บฑฑ
			ฑฑบ                                                                       บฑฑ
			ฑฑบ	Analista Resp. Jos้ de Assun็ใo					                      บฑฑ
			ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
			*/
			If MsgYesNo("Verifica reposi็ใo automatica Poder de Terceiro?", "Reposi็ใo")

				If Len(aItPvTer) > 0

					cNrPvTer := "P3"

					Processa({||U_fGeraPv()},"Gerando PV Rep. Automatica Poder de Terceiros...")  // Gera Pedido de Venda

				Else

					Aviso("Nใo existem itens com estoque mํnimo cadastrado para reposi็ใo automแtica de Poder de Terceiros!!!","Aten็ใo!")

					nMeter6 := 100
					oMeter6:Set(nMeter6)
					cPoder3	:= "........................Nใo se Aplica"
					oSay10:lVisibleControl := .T.
					oDlg:CommitControls()
					oDlg:Refresh()
				Endif

			Endif

		Else
			/*
			ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
			ฑฑบ                                                                       บฑฑ
			ฑฑบ Verifica se Nota Original vem de um Pedido de Venda gerado por Agenda บฑฑ
			ฑฑบ de Or็amento e, consequentemente, de um Or็amento.					  บฑฑ
			ฑฑบ Neste caso, o Or็amento tem de ser liberado e a Agenda copiada para   บฑฑ
			ฑฑบ uma nova Agenda ficando a original com o status de "Reprogramada".    บฑฑ
			ฑฑบ																		  บฑฑ
			ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
			*/

			/*
			ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
			ฑฑบ                                                                       บฑฑ
			ฑฑบ Validar se trata-se de um retorno de KIT, neste caso nใo deverแ copiarบฑฑ
			ฑฑบ a Agenda de Or็amento.												  บฑฑ
			ฑฑบ																		  บฑฑ
			ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
			*/

			If !MsgYesNo("Devolu็ใo de Venda?", "Retorno")

				dbSelectArea("SD1") // Itens da NF
				dbSetOrder(1)       // Documeto + Serie + Fornecedor + Loja
				If dbSeek( cNFEnt )

					// Pontera na Nota Fiscal de Saida
					dbSelectArea("SD2")
					dbSetOrder(3) // Documento + Serie + Fornecedor + Loja + Produto + Item
					If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI)

						// Pontera no item da agenda para verificar se NF ้ referente ao KIT
						dbSelectarea("SZ6")
						dbSetOrder(4) // Pedido
						If dbSeek(xFilial("SZ6") + SD2->D2_PEDIDO)

							If Empty(Z6_KIT)

								// Pontera no Pedido de Venda
								dbSelectArea("SC5")
								dbSetOrder(1) // Numero
								If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)

									// Pontera no Orcamento
									dbSelectArea("SCJ")
									dbSetOrder(1) // Orcamento
									If dbSeek(xFilial("SCJ") + SC5->C5_XORCAM)

										// Muda Status do Orcamento para "Sem Kit associado"
										// Ajuste Status - 20100701
										If (AllTrim(SCJ->CJ_XSITUAC) == "2" .OR. AllTrim(SCJ->CJ_XSITUAC) == "5") .AND. AllTrim(CJ_XTIPORC) == "2"
											RecLock("SCJ",.F.)
											Replace CJ_STATUS with "A"
											MsUnLock()
										ElseIf (AllTrim(SCJ->CJ_XSITUAC) == "1" .OR. AllTrim(SCJ->CJ_XSITUAC) == "3" .OR. AllTrim(SCJ->CJ_XSITUAC) == "4" ) .AND. AllTrim(CJ_XTIPORC) == "2"
											RecLock("SCJ",.F.)
											Replace CJ_STATUS with "C"
											MsUnLock()
										Endif

										// Muda Status da Agenda para "Reprogramado"
										dbSelectArea("SZ5")
										dbSetOrder(10) // Orcamento
										If dbSeek(xFilial("SZ5") + SC5->C5_XORCAM)
											RecLock("SZ5",.F.)
											Replace Z5_STATUS with "I"    // Reprogramada
											MsUnLock()

											// Copia Agenda com Status "Sem Kit associado"
											U_fCopiaSZ5()

										Endif

									Endif

								Endif

							Endif

						Endif

					Endif

				Endif

			Endif

		Endif

		*'Yttalo P.Martins--INICIO------------------------------'*
		RestArea(__aArea)

		//chama a rotina de envio de e-mail
		U_WF_103A(nil, nil, cPedWF)
		*'Yttalo P.Martins--FIM---------------------------------'*
		//__aArea := GetArea()
		nMeter7 := 100
		oMeter7:Set(nMeter7)
		oSay12:lVisibleControl := .T.
		oDlg:CommitControls()
		oDlg:Refresh()

		dbSelectArea("SD1") // Itens da NF
		dbSetOrder(1)       // Filial + Documeto + Serie + Fornecedor + Loja
		dbSeek(cNFEnt)

		//preenche o campo C5_NOTA e o C5_SERIE, pois quando o pedido for parcial, na SC5 nใo grava a nota e s้rie
		dbSelectArea("SD2")
		dbSetOrder(3) // Documento + Serie + Fornecedor + Loja + Produto + Item
		If dbSeek(xFilial("SD2") + SD1->D1_NFORI + SD1->D1_SERIORI + SD1->D1_FORNECE + SD1->D1_LOJA + SD1->D1_COD + SD1->D1_ITEMORI)

			dbSelectArea("SC5")
			dbSetOrder(1) // Numero
			If dbSeek(xFilial("SC5") + SD2->D2_PEDIDO)

				If EMPTY(SC5->C5_NOTA)
					RecLock("SC5",.F.)
					SC5->C5_NOTA  := SD1->D1_NFORI
					SC5->C5_SERIE := SD1->D1_SERIORI
					SC5->( MsUnLock() )
				EndIf

			EndIf

		EndIf

		//RestArea(__aArea)
		*'Yttalo P.Martins--INICIO------------------------------'*
		//chama relat๓rio de sistema de qualidade
		//U_WMER019(cNFOri,cSerOri)
		oButton1:lVisibleControl	:= .F.
		oButton2:lVisibleControl	:= .T.
		oButton3:lVisibleControl	:= .T.
		*'Yttalo P.Martins--FIM---------------------------------'*

	Endif

	RestArea(aAreaAtu)
	RestArea(aAreaSC5)
	RestArea(aAreaSC6)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWMEA007   บAutor  ณManoel de Sa        บ Data ณ  14/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para gerar os vetores de cabecalho e itens do        บฑฑ
ฑฑบ          ณpedido de venda a ser gerado.                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fGeraVetorPV()

	Local cDesc     := CriaVar("B1_DESC")
	Local cQuerySB6 := GetNextAlias()
	Local cSD1FAT   := GetNextAlias()
	Local cSD1P3   	:= GetNextAlias()
	Local cAliasSB6 := GetNextAlias()
	Local nSdDb6    := 0
	Local nPrcVen   := 0
	Local nPrUnit   := 0
	Local dDtValid  := StoD("20491231")

	Local nPosicao	:= 0

	Private cNumSeq := ""

	/*
	ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
	ฑฑบ                                                                        บฑฑ
	ฑฑบ Ponterando na NFe de Origem (Saida para Emprestimo/Consigna็ใo) para   บฑฑ
	ฑฑบ buscar os valores corretos para o Pedidos de Venda a ser gerado e o    บฑฑ
	ฑฑบ Cliente correto para qual sera feita a venda dos itens utilizados.     บฑฑ
	ฑฑบ                                                                        บฑฑ
	ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
	ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
	*/

	// Pontera na Nota Fiscal de Saida
	dbSelectArea("SD2")
	dbSetOrder(3) // Filial + Documento + Serie + Fornecedor + Loja
	If dbSeek(xFilial("SD2")+cNFOri+cSerOri+cCliente+cLoja)

		// Pontera no Pedido de Venda
		dbSelectArea("SC5")
		dbSetOrder(1) // Numero
		If dbSeek(xFilial("SC5")+SD2->D2_PEDIDO)

			/*
			ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
			ฑฑบ                                                                        บฑฑ
			ฑฑบ Ponterando no cabecalho do orcamento caso a Nota de Saida tenha sido   บฑฑ
			ฑฑบ originada por orcamento que virou pedido, "Else" busca dados somente   บฑฑ
			ฑฑบ do Pedido de Venda.                                                    บฑฑ
			ฑฑบ                                                                        บฑฑ
			ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
			ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
			*/

			// Pontera no Orcamento
			dbSelectArea("SCJ")
			dbSetOrder(1) // Orcamento
			If dbSeek(xFilial("SCJ") + SC5->C5_XORCAM)

				If !lGeraCab

					aAdd( aCabPv , { "C5_TIPO"      ,"N"                 ,NIL} ) // Tipo do PV
					aAdd( aCabPv , { "C5_EMISSAO"   ,dDataBase           ,NIL} ) // Data de Emissao
					/*
					ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
					ฑฑบ INICIO                                                                 บฑฑ
					ฑฑบ Para PVs de Produtos marcados para Faturamento onde existe             บฑฑ
					ฑฑบ relacionamento com Or็amento, os dados de Cliente devem ser            บฑฑ
					ฑฑบ originados do Or็amento que iniciou o Processo.						   บฑฑ
					ฑฑบ																		   บฑฑ
					ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
					ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
					*/

					aAdd( aCabPv , { "C5_CLIENTE"   ,SCJ->CJ_CLIENTE    ,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPv , { "C5_LOJACLI"   ,SCJ->CJ_LOJA   	,NIL} ) // LOJA
					aAdd( aCabPv , { "C5_CLIENT"    ,SCJ->CJ_CLIENT     ,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPv , { "C5_LOJAENT"   ,SCJ->CJ_LOJAENT    ,NIL} ) // LOJA
					/*
					ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯออออออออออออออนฑฑ
					ฑฑบ FIM                                                                       บฑฑ
					ฑฑบ Analista Resp. Jos้ de Assun็ใo                                        บฑฑ
					ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
					*/

					aAdd( aCabPv , { "C5_TIPOCLI"   ,"F"                 ,NIL} ) // TIPO DO CLIENTE
					aAdd( aCabPv , { "C5_TPFRETE"   ,"S"                 ,NIL} ) // TIPO DO FRETE
					aAdd( aCabPv , { "C5_CONDPAG"   ,SC5->C5_CONDPAG     ,NIL} ) // CONDICAO DO PAGAMENTO
					aAdd( aCabPv , { "C5_TABELA"    ,""     			 ,NIL} ) // TABELA DE PRECOS
					aAdd( aCabPv , { "C5_VEND1"    	,SC5->C5_VEND1	     ,NIL} ) // VENDEDOR
					aAdd( aCabPv , { "C5_XPACIEN"   ,SC5->C5_XPACIEN     ,NIL} ) // COD DO PACIENTE
					aAdd( aCabPv , { "C5_XNOMPAC"   ,SC5->C5_XNOMPAC     ,NIL} ) // NOME DO PACIENTE
					aAdd( aCabPv , { "C5_XORCAM"    ,SC5->C5_XORCAM      ,NIL} ) // COD DO ORCAMENTO
					aAdd( aCabPv , { "C5_XMEDICO"   ,SC5->C5_XMEDICO     ,NIL} ) // CODIGO DO MEDICO
					aAdd( aCabPv , { "C5_XNOMMED"   ,SC5->C5_XNOMMED     ,NIL} ) // NOME DO MEDICO
					aAdd( aCabPv , { "C5_XCONVEN"   ,SC5->C5_XCONVEN     ,NIL} ) // CODIGO DO CONVENIO
					aAdd( aCabPv , { "C5_XNOMCON"   ,SC5->C5_XNOMCON     ,NIL} ) // NOME DO CONVENIO
					aAdd( aCabPv , { "C5_XHOSPIT"   ,SC5->C5_XHOSPIT     ,NIL} ) // CODIGO DO HOSPITAL
					aAdd( aCabPv , { "C5_XNOMHOS"   ,SC5->C5_XNOMHOS     ,NIL} ) // NOME DO HOSPITAL
					aAdd( aCabPv , { "C5_XPROCED"   ,SC5->C5_XPROCED     ,NIL} ) // CODIGO DO PROCEDIMENTO
					aAdd( aCabPv , { "C5_XDESPRO"   ,SC5->C5_XDESPRO     ,NIL} ) // DESCRICAO DO PROCEDIMENTO
					aAdd( aCabPv , { "C5_XDTCIRU"   ,SC5->C5_XDTCIRU     ,NIL} ) // DATA DA CIRURGIA
					aAdd( aCabPv , { "C5_XHORCIR"   ,SC5->C5_XHORCIR     ,NIL} ) // HORA DA CIRURGIA
					aAdd( aCabPv , { "C5_VEND4"    	,SC5->C5_VEND4       ,NIL} ) // INSTRUMENTADOR
					aAdd( aCabPv , { "C5_XTIPVEN"   ,"2"                 ,NIL} ) // TIPO DE VENDA - PARTICULAR OU ORCAMENTO
					aAdd( aCabPv , { "C5_MOEDA"     ,1                   ,NIL} ) // MOEDA
					aAdd( aCabPv , { "C5_PESOL"     ,0.01                ,NIL} ) // PESO LIQUIDO
					aAdd( aCabPv , { "C5_PBRUTO"    ,0.01                ,NIL} ) // PESO BRUTO
					aAdd( aCabPv , { "C5_LIBEROK"   ,"S"                 ,NIL} ) // FLAG DE LIBERACAO DO PEDIDO
					aAdd( aCabPv , { "C5_TXMOEDA"   ,0                   ,NIL} ) // TAXA DA MOEDA
					aAdd( aCabPv , { "C5_TPCARGA"   ,"2"                 ,NIL} ) // CARGA DO OMS 1-UTILIZA - 2-NAO UTILIZA
					aAdd( aCabPv , { "C5_ORCRES"    ," "                 ,NIL} ) // NUMERO DO ORCAMENTO
					aAdd( aCabPv , { "C5_TIPLIB"    ,"1"                 ,NIL} ) // TIPO DE LIBERACAO DO PV 1 - ITEM 2 - PEDIDO
					aAdd( aCabPv , { "C5_XRETORN"  	,"S"                 ,NIL} ) // FLAG SE FOI RETORNO
					aAdd( aCabPv , { "C5_XSITUAC"  	,"A"                 ,NIL} ) // CLASSIFICACAO
					aAdd( aCabPv , { "C5_XSTATUS"  	,"A"                 ,NIL} ) // STATUS

					// Alterado por Jos้ de Assun็ใo - Totvs RJ [ 23/11/2017 ]
					// Criado para herdar a informa็ใo do Cod/Desc Projeto
					aAdd( aCabPv , { "C5_XPROJET"  	,SC5->C5_XPROJET     ,NIL} ) // CODIGO DO PROJETO
					aAdd( aCabPv , { "C5_XDESCPR"  	,SC5->C5_XDESCPR     ,NIL} ) // DESCRICAO DO PROJETO

					lGeraCab := .T.

				Endif

				zQuery := " SELECT * FROM "     + RetSqlName("SD1")+ ""
				zQuery += " WHERE D1_FILIAL = '"+ xFilial("SDA")+"' AND"
				zQuery += "       D1_DOC	= '"+ cNF      +"' AND"
				zQuery += "       D1_SERIE  = '"+ cSerie   +"' AND"
				zQuery += "       D1_FORNECE= '"+ cCliente +"' AND"
				zQuery += "       D1_LOJA  	= '"+ cLoja    +"' AND"
				zQuery += "       D1_XFATSN	= '1' AND"
				zQuery += "       D_E_L_E_T_ <> '*' "

				If Select(cSD1FAT) > 0
					dbSelectArea(cSD1FAT)
					(cSD1FAT)->(dbCloseArea())
				Endif

				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,zQuery), cSD1FAT , .F., .T.)

				dbSelectArea(cSD1FAT)
				(cSD1FAT)->(dbGotop())

				While (cSD1FAT)->(!Eof())

					//Caso o lote tenha uma data de validade
					//diferente da que estแ no arm. 01 origem
					//exibe a msg e aborta o retorno...
					DBSELECTAREA("SB8")
					SB8->(DBSETORDER(3))
					SB8->(dbGotop())

					IF !SB8->(dbSeek(xFilial("SB8")+(cSD1FAT)->D1_COD+(cSD1FAT)->D1_XLOCFAT+(cSD1FAT)->D1_LOTECTL+(cSD1FAT)->D1_NUMLOTE+(cSD1FAT)->D1_DTVALID))

						MsgAlert("Produto [ "+Alltrim((cSD1FAT)->D1_COD)+" ]- Lote [ "+Alltrim((cSD1FAT)->D1_LOTECTL)+" ], equalize a validade do lote nos armazens do sistema!","Validade diferente no Arm [ "+Alltrim((cSD1FAT)->D1_XLOCFAT)+" ]!")

					Endif

					Incproc("Gerando item(ns) do pedido de venda ...")

					cDesc   := Posicione("SB1",1,xFilial("SB1") + (cSD1FAT)->D1_COD,"B1_DESC")

					//cTes    := U_MyTesInt(2,"01",SCJ->CJ_CLIENTE,SCJ->CJ_LOJA,"C",SD1FAT->D1_COD,"C6_TES")//TESTE
					cTes	:= U_xTesInt((cSD1FAT)->D1_COD,"01")

					If Empty (cTes)
						cTes := If(Empty(SuperGetMV("MV_TESVEN")),"601",SuperGetMV("MV_TESVEN"))
					Endif

					//==========================================================================//
					//Incluido por Rafael Fernandes - Tratamento para poder de terceiros        //
					//==========================================================================//
					nItem    := nItem + 1

					dbSelectArea("SF4") // TES
					dbSetOrder(1)       // Codigo
					dbSeek(xFilial("SF4") + (cSD1FAT)->D1_TES)

					If Alltrim(SF4->F4_PODER3) $ 'R|D' .And. nItem == 1
						cNewCli   := ''
						cNewLjCli := ''
						GetPoder3()
					Else
						AlertBlq()
						cNewCli   := SC5->C5_CLIENTE
						cNewLjCli := SC5->C5_LOJACLI
					EndIf


					dbSelectArea("SF4") // TES
					dbSetOrder(1)       // Codigo
					dbSeek(xFilial("SF4") + cTes)

					cCf      := SF4->F4_CF
					cClasFis := Posicione("SB1",1,xFilial("SB1") + (cSD1FAT)->D1_COD,"B1_ORIGEM")
					cClasFis += SF4->F4_SITTRIB

					/*
					ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
					ฑฑบ                                                                       บฑฑ
					ฑฑบ Busca o preco original do Orcamento porque os precos informados na NF บฑฑ
					ฑฑบ de imprestimo, correspondiam ao CMV Unitario do Produto informado na  บฑฑ
					ฑฑบ tabela de pre็os cod. 006                                             บฑฑ
					ฑฑบ 																	  บฑฑ
					ฑฑบ Efetuado tratamento para que seja considerado que o produto na NF de  บฑฑ
					ฑฑบ Emprestimo seja de um componente									  บฑฑ
					ฑฑบ                                                                       บฑฑ
					ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
					ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
					*/

					// Pontera nos Itens da Agenda
					dbSelectArea("SZ6")
					dbSetOrder(4) // Orcamento

					If dbSeek(xFilial("SZ6") + SC5->C5_NUM)

						// Pontera nos Itens Orcamento
						dbSelectArea("SCK")
						dbSetOrder(3) // Orcamento

						If dbSeek(xFilial("SCK") + SZ6->Z6_COMPON + SCJ->CJ_NUM)

							nPrcVen  := IIF(SCK->CK_PRUNIT>0,SCK->CK_PRUNIT,(cSD1FAT)->D1_VUNIT)//SCK->CK_PRCVEN
							nPrUnit  := IIF(SCK->CK_PRUNIT>0,SCK->CK_PRUNIT,(cSD1FAT)->D1_VUNIT)

						else

							dbselectarea("SB1")
							dbSelectArea("SCK")
							SCK->(dbSetOrder(3)) // CK_FILIAL + CK_PRODUTO + CK_NUM + CK_ITEM
							dbSelectArea("SC6")
							SC6->(dbSetOrder(2)) // C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM

							Do Case
							Case SCK->(dbSeek(xFilial("SCK") + (cSD1FAT)->D1_COD + SCJ->CJ_NUM)) .AND. SCK->CK_PRCVEN > 0
								nPrcVen  := SCK->CK_PRCVEN
								nPrUnit  := SCK->CK_PRCVEN

							Case SC6->(dbSeek(xFilial("SC6") + (cSD1FAT)->D1_COD + SC5->C5_NUM)) .AND. (SCK->(dbSetOrder(6)) /*CK_FILIAL+CK_NUM+CK_XKIT+CK_PRODUTO*/, .T.) .AND. SCK->(dbSeek(xFilial("SCK") + (cSD1FAT)->D1_COD + SC6->C6_XKIT)) .AND. SCK->CK_PRCVEN > 0
								nPrcVen  := SCK->CK_PRCVEN
								nPrUnit  := SCK->CK_PRCVEN

							Case SCK->(dbSeek(xFilial("SB1") + (cSD1FAT)->D1_COD)) .AND. SB1->B1_CUSTD > 0
								nPrcVen  := SB1->B1_CUSTD
								nPrUnit  := SB1->B1_CUSTD

							Otherwise
								nPrcVen  := (cSD1FAT)->D1_VUNIT
								nPrUnit  := (cSD1FAT)->D1_VUNIT
							EndCase

						EndIf

					Else

						dbselectarea("SB1")
						dbSelectArea("SCK")
						SCK->(dbSetOrder(3)) // CK_FILIAL + CK_PRODUTO + CK_NUM + CK_ITEM
						dbSelectArea("SC6")
						SC6->(dbSetOrder(2)) // C6_FILIAL+C6_PRODUTO+C6_NUM+C6_ITEM

						Do Case
						Case SCK->(dbSeek(xFilial("SCK") + (cSD1FAT)->D1_COD + SCJ->CJ_NUM)) .AND. SCK->CK_PRCVEN > 0
							nPrcVen  := SCK->CK_PRCVEN
							nPrUnit  := SCK->CK_PRCVEN

						Case SC6->(dbSeek(xFilial("SC6") + (cSD1FAT)->D1_COD + SC5->C5_NUM)) .AND. (SCK->(dbSetOrder(6)) /*CK_FILIAL+CK_NUM+CK_XKIT+CK_PRODUTO*/, .T.) .AND. SCK->(dbSeek(xFilial("SCK") + (cSD1FAT)->D1_COD + SC6->C6_XKIT)) .AND. SCK->CK_PRCVEN > 0
							nPrcVen  := SCK->CK_PRCVEN
							nPrUnit  := SCK->CK_PRCVEN

						Case SCK->(dbSeek(xFilial("SB1") + (cSD1FAT)->D1_COD)) .AND. SB1->B1_CUSTD > 0
							nPrcVen  := SB1->B1_CUSTD
							nPrUnit  := SB1->B1_CUSTD

						Otherwise
							nPrcVen  := (cSD1FAT)->D1_VUNIT
							nPrUnit  := (cSD1FAT)->D1_VUNIT
						EndCase

					EndIf

					nPosicao := 0
					iif(len(aItensPv)>0, nPosicao := Ascan( aItensPv, { | x | x[ 02,02 ] == (cSD1FAT)->D1_COD .and. x[ 15,02 ] == (cSD1FAT)->D1_LOTECTL} ),nil) //Addd Glaicon Cesar 03-09-2018 - verifica se ja existe o item

					If( nPosicao == 0 ) //Addd Glaicon Cesar 03-09-2018
						aAdd( aLinItPv , {"C6_ITEM"       ,strzero(nItem,2)			,NIL}) // Obrigatorio - Item do Pedido de Venda
						aAdd( aLinItPv , {"C6_PRODUTO"    ,(cSD1FAT)->D1_COD       	,NIL}) // Obrigatorio - Produto
						aAdd( aLinItPv , {"C6_UM"         ,(cSD1FAT)->D1_UM        	,NIL}) // Obrigatorio - Unidade de Medida
						aAdd( aLinItPv , {"C6_QTDVEN"     ,(cSD1FAT)->D1_XQTDFAT   	,NIL}) // Obrigatorio - Quantidade vendida
						aAdd( aLinItPv , {"C6_PRCVEN"     ,nPrcVen              	,NIL}) // Preco unitario
						aAdd( aLinItPv , {"C6_QTDLIB"     ,0						,NIL}) // Quantidade liberada /*SD1FAT->D1_XQTDFAT*/
						aAdd( aLinItPv , {"C6_TES"        ,cTes                 	,NIL}) // Obrigatorio - TES
						aAdd( aLinItPv , {"C6_LOCAL"      ,(cSD1FAT)->D1_XLOCFAT   	,NIL}) // Obrigatorio - Armazem
						//aAdd( aLinItPv , {"C6_LOCALIZ"    ,IIF(Localiza((cSD1FAT)->D1_COD),"EMPENHO","" )			,NIL}) //Endere็o
						aAdd( aLinItPv , {"C6_CF"         ,cCf                  	,NIL}) // Obrigatorio - Classifica็ใo Fiscal
						aAdd( aLinItPv , {"C6_CLI"        ,SC5->C5_CLIENTE      	,NIL}) // Obrigatorio
						aAdd( aLinItPv , {"C6_LOJA"       ,SC5->C5_LOJACLI         	,NIL}) // Obrigatorio
						aAdd( aLinItPv , {"C6_ENTREG"     ,dDataBase            	,NIL}) // Data prevista para entrega
						aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc                	,NIL}) // Descricao do Produto
						aAdd( aLinItPv , {"C6_PRUNIT"     ,nPrUnit              	,NIL}) // Obrigatorio - Preco de Lista
						aAdd( aLinItPv , {"C6_LOTECTL"    ,(cSD1FAT)->D1_LOTECTL   	,NIL}) // Lote
						aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis             	,NIL}) // Obrigatorio - Classificacao fiscal
						aAdd( aLinItPv , {"C6_TPOP"       ,"F"                  	,NIL}) // Tipo da OP - F-Firme
						aAdd( aLinItPv , {"C6_XTIPOPV"    ,"P"                     	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)
						aAdd( aLinItPv , {"C6_TPPROD "    ,"1"                     	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)

						If Rastro( (cSD1FAT)->D1_COD )
							dDtValid := xDtValid((cSD1FAT)->D1_COD,(cSD1FAT)->D1_LOTECTL,(cSD1FAT)->D1_XLOCFAT)
							aAdd( aLinItPv , {"C6_DTVALID"       ,dDtValid                  ,NIL}) //Dt. Validade Lote
						EndIf

						aAdd( aItensPv , aClone( aLinItPv ) )
						aLinItPv := {}
					Else //Addd Glaicon Cesar 03-09-2018
						aItensPv[nPosicao,04][02] +=(cSD1FAT)->D1_XQTDFAT //Addd Glaicon Cesar 03-09-2018
					EndIf //Addd Glaicon Cesar 03-09-2018

					(cSD1FAT)->(dbSkip())


				Enddo

				If Select(cSD1FAT) > 0
					dbSelectArea(cSD1FAT)
					(cSD1FAT)->(dbCloseArea())
				Endif

				/*
				ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
				ฑฑบ INICIO - PODER DE TERCEIROS REPOSICAO AUTOMATICA                      บฑฑ
				ฑฑบ 																	  บฑฑ
				ฑฑบ Identifica que se trata de item em poder de terceiros que ้ controladoบฑฑ
				ฑฑบ por saldo minimo cadastrado em ClientexProduto e que necessita de uma บฑฑ
				ฑฑบ reposi็ใo                                                             บฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
				ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
				*/

				If !lGerCabP3

					aAdd( aCabPvP3 , { "C5_TIPO"     ,"N"                 		,NIL} ) // Tipo do PV
					aAdd( aCabPvP3 , { "C5_EMISSAO"  ,dDataBase           		,NIL} ) // Data de Emissao
					aAdd( aCabPvP3 , { "C5_CLIENTE"  ,SC5->C5_CLIENTE     		,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_LOJACLI"  ,SC5->C5_LOJACLI     		,NIL} ) // LOJA
					aAdd( aCabPvP3 , { "C5_CLIENT"   ,SC5->C5_CLIENTE     		,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_LOJAENT"  ,SC5->C5_LOJACLI     		,NIL} ) // LOJA
					aAdd( aCabPvP3 , { "C5_TIPOCLI"  ,"F"                 		,NIL} ) // TIPO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_TPFRETE"  ,"S"                 		,NIL} ) // TIPO DO FRETE
					aAdd( aCabPvP3 , { "C5_CONDPAG"  ,SC5->C5_CONDPAG     		,NIL} ) // CONDICAO DO PAGAMENTO
					aAdd( aCabPvP3 , { "C5_TABELA"   ,""     			 		,NIL} ) // TABELA DE PRECOS
					aAdd( aCabPvP3 , { "C5_VEND1"    ,SC5->C5_VEND1	     		,NIL} ) // VENDEDOR
					aAdd( aCabPvP3 , { "C5_XPACIEN"  ,SC5->C5_XPACIEN     		,NIL} ) // COD DO PACIENTE
					aAdd( aCabPvP3 , { "C5_XNOMPAC"  ,SC5->C5_XNOMPAC     		,NIL} ) // NOME DO PACIENTE
					aAdd( aCabPvP3 , { "C5_XMEDICO"  ,SC5->C5_XMEDICO     		,NIL} ) // CODIGO DO MEDICO
					aAdd( aCabPvP3 , { "C5_XNOMMED"  ,SC5->C5_XNOMMED     		,NIL} ) // NOME DO MEDICO
					aAdd( aCabPvP3 , { "C5_XCONVEN"  ,SC5->C5_XCONVEN     		,NIL} ) // CODIGO DO CONVENIO
					aAdd( aCabPvP3 , { "C5_XNOMCON"  ,SC5->C5_XNOMCON     		,NIL} ) // NOME DO CONVENIO
					aAdd( aCabPvP3 , { "C5_XHOSPIT"  ,SC5->C5_XHOSPIT     		,NIL} ) // CODIGO DO HOSPITAL
					aAdd( aCabPvP3 , { "C5_XNOMHOS"  ,SC5->C5_XNOMHOS     		,NIL} ) // NOME DO HOSPITAL
					aAdd( aCabPvP3 , { "C5_XPROCED"  ,SC5->C5_XPROCED     		,NIL} ) // CODIGO DO PROCEDIMENTO
					aAdd( aCabPvP3 , { "C5_XDESPRO"  ,SC5->C5_XDESPRO     		,NIL} ) // DESCRICAO DO PROCEDIMENTO
					aAdd( aCabPvP3 , { "C5_XDTCIRU"  ,SC5->C5_XDTCIRU     		,NIL} ) // DATA DA CIRURGIA
					aAdd( aCabPvP3 , { "C5_XHORCIR"  ,SC5->C5_XHORCIR     		,NIL} ) // HORA DA CIRURGIA
					aAdd( aCabPvP3 , { "C5_VEND4"    ,SC5->C5_VEND4       		,NIL} ) // INSTRUMENTADOR
					aAdd( aCabPvP3 , { "C5_XTIPVEN"  ,"2"                 		,NIL} ) // TIPO DE VENDA - PARTICULAR OU ORCAMENTO
					aAdd( aCabPvP3 , { "C5_MOEDA"    ,1                   		,NIL} ) // MOEDA
					aAdd( aCabPvP3 , { "C5_PESOL"    ,0.01                		,NIL} ) // PESO LIQUIDO
					aAdd( aCabPvP3 , { "C5_PBRUTO"   ,0.01                		,NIL} ) // PESO BRUTO
					aAdd( aCabPvP3 , { "C5_LIBEROK"  ,"S"                 		,NIL} ) // FLAG DE LIBERACAO DO PEDIDO
					aAdd( aCabPvP3 , { "C5_TXMOEDA"  ,0                   		,NIL} ) // TAXA DA MOEDA
					aAdd( aCabPvP3 , { "C5_TPCARGA"  ,"2"                 		,NIL} ) // CARGA DO OMS 1-UTILIZA - 2-NAO UTILIZA
					aAdd( aCabPvP3 , { "C5_ORCRES"   ," "                 		,NIL} ) // NUMERO DO ORCAMENTO
					aAdd( aCabPvP3 , { "C5_TIPLIB"   ,"1"                 		,NIL} ) // TIPO DE LIBERACAO DO PV 1 - ITEM 2 - PEDIDO
					aAdd( aCabPvP3 , { "C5_XRETORN"  ,""                 		,NIL} ) // FLAG SE FOI RETORNO
					aAdd( aCabPvP3 , { "C5_XSITUAC"  ,"A"                 		,NIL} ) // CLASSIFICACAO
					aAdd( aCabPvP3 , { "C5_XSTATUS"  ,"A"                 		,NIL} ) // STATUS
					aAdd( aCabPvP3 , { "C5_XOBS"  	 ,"PV REPOSICAO AUTOMATICA"	,NIL} ) // OBS

					// Alterado por Jos้ de Assun็ใo - Totvs RJ [ 23/11/2017 ]
					// Criado para herdar a informa็ใo do Cod/Desc Projeto
					aAdd( aCabPvP3 , { "C5_XPROJET"  ,SC5->C5_XPROJET     		,NIL} ) // CODIGO DO PROJETO
					aAdd( aCabPvP3 , { "C5_XDESCPR"  ,SC5->C5_XDESCPR     		,NIL} ) // DESCRICAO DO PROJETO

					lGerCabP3 := .T.

				Endif

				// Select de todos os itens que estใo retornando para verificar se necessita
				// reposi็ใo automatica de Poder de Terceiros

				P3Query := " SELECT * FROM "+RetSqlName("SD1")+ ""
				P3Query += " WHERE D1_FILIAL 	= 	'"+ xFilial("SD1")	+"' AND"
				P3Query += "       D1_DOC		= 	'"+ cNF      		+"' AND"
				P3Query += "       D1_SERIE  	= 	'"+ cSerie   		+"' AND"
				P3Query += "       D1_FORNECE	= 	'"+ cCliente 		+"' AND"
				P3Query += "       D1_LOJA  	= 	'"+ cLoja    		+"' AND"
				P3Query += "       D_E_L_E_T_ 	<> 	'*' "

				If Select(cSD1P3) > 0
					dbSelectArea(cSD1P3)
					(cSD1P3)->(dbCloseArea())
				Endif

				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,P3Query), cSD1P3 , .F., .T.)

				dbSelectArea(cSD1P3)
				(cSD1P3)->(dbGotop())

				While (cSD1P3)->(!Eof())

					Incproc("Gerando item(ns) Rep. automatica Poder de Terceiros ...")

					dbSelectArea("SA7")
					dbSetOrder(1) // Cliente + Loja + Produto
					If dbSeek(xFilial("SA7") + (cSD1P3)->D1_FORNECE + (cSD1P3)->D1_LOJA + (cSD1P3)->D1_COD)

						If SA7->A7_XESTMIN <> 0

							cQuerySB6 := "SELECT Est_Min.Cliente, Est_Min.Loja, Est_Min.Produto, "
							cQuerySB6 += "       Est_Min.Est_Min, Sld_PoderTerc.Sld_PoderTerc, "
							cQuerySB6 += "       SUM(Est_Min.Est_Min-Sld_PoderTerc.Sld_PoderTerc)AS Saldo "
							cQuerySB6 += "     FROM "
							cQuerySB6 += "        (SELECT A7_CLIENTE Cliente, A7_LOJA Loja, A7_PRODUTO Produto, A7_XESTMIN Est_Min "
							cQuerySB6 += "             FROM " + RetSqlName("SA7") + " "
							cQuerySB6 += "             WHERE   A7_FILIAL   = '" + xFilial("SA7") + "' "
							cQuerySB6 += "                 AND A7_CLIENTE  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                 AND A7_LOJA     = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                 AND A7_PRODUTO  = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                 AND A7_XESTMIN <> '0' "
							cQuerySB6 += "                 AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "       AS Est_Min CROSS JOIN "
							cQuerySB6 += "        (SELECT SUM( (ISNULL(Sld_Remessa.Sld_Remessa,0)) - (ISNULL(Sld_Devolucao.Sld_Devolucao,0)) )AS Sld_PoderTerc "
							cQuerySB6 += "              FROM "
							cQuerySB6 += "                 (SELECT SUM(B6_SALDO) Sld_Remessa "
							cQuerySB6 += "                       FROM " + RetSqlName("SB6") + " "
							cQuerySB6 += "                       WHERE   B6_FILIAL  = '" + xFilial("SB6")  + "' "
							cQuerySB6 += "                           AND B6_CLIFOR  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                           AND B6_LOJA    = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                           AND B6_PRODUTO = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                           AND B6_PODER3  = 'R' "
							cQuerySB6 += "                           AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "               AS Sld_Remessa CROSS JOIN "
							cQuerySB6 += "                (SELECT      SUM(B6_SALDO) Sld_Devolucao "
							cQuerySB6 += "                      FROM " + RetSqlName("SB6") + " "
							cQuerySB6 += "                      WHERE   B6_FILIAL  = '" + xFilial("SB6")  + "' "
							cQuerySB6 += "                          AND B6_CLIFOR  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                          AND B6_LOJA    = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                          AND B6_PRODUTO = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                          AND B6_PODER3  = 'D' "
							cQuerySB6 += "                          AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "                       AS Sld_Devolucao) AS Sld_PoderTerc "
							cQuerySB6 += "     GROUP BY Est_Min.Cliente, Est_Min.Loja, Est_Min.Produto, "
							cQuerySB6 += "              Est_Min.Est_Min, Sld_PoderTerc.Sld_PoderTerc "

							memowrite("C:\Totvs\Terceiros.SQL",cQuerySB6)

							If Select(cAliasSB6) > 0
								dbSelectArea(cAliasSB6)
								(cAliasSB6)->(dbCloseArea())
							Endif

							TcQuery cQuerySB6 Alias (cAliasSB6) NEW

							(cAliasSB6)->(dbGoTop())

							If (cAliasSB6)->(!Eof())
								nSdSb6 := (cAliasSB6)->Saldo
							Endif

							If Select(cAliasSB6) > 0
								dbSelectArea(cAliasSB6)
								(cAliasSB6)->(dbCloseArea())
							Endif

							// Verifica se saldo (Estoque Min - Qtd em P3) e maior
							// que 0, caracterizando necessidade de reposi็ใo
							// pedido de emprestimo
							If nSdSb6 > 0

								cDesc   := Posicione("SB1",1,xFilial("SB1") + SA7->A7_PRODUTO,"B1_DESC")

								cTes	:= U_xTesInt(SA7->A7_PRODUTO,"Y")

								If Empty (cTes)
									cTes := "507"
								Endif

								nItem    := nItem + 1

								cNewCli   := (cSD1P3)->D1_FORNECE
								cNewLjCli := (cSD1P3)->D1_LOJA

								dbSelectArea("SF4") // TES
								dbSetOrder(1)       // Codigo
								IF dbSeek(xFilial("SF4") + cTes)
									cCf      := SF4->F4_CF
									cClasFis := Posicione("SB1",1,xFilial("SB1") + (cSD1P3)->D1_COD,"B1_ORIGEM")
									cClasFis += SF4->F4_SITTRIB
								ENDIF

								nPrcVen  := (cSD1P3)->D1_VUNIT
								nPrUnit  := (cSD1P3)->D1_VUNIT

								nPosicao := 0
								iif(len(aItPvTer)>0, nPosicao := Ascan( aItPvTer, { | x | x[ 02,02 ] == (cSD1P3)->D1_COD } ),nil) //Addd Glaicon Cesar 03-09-2018 - verifica se ja existe o item

								If( nPosicao == 0 ) //Addd Glaicon Cesar 03-09-2018
									aAdd( aLinItPv , {"C6_ITEM"       ,strzero(nItem,2)                    	,NIL}) // Obrigatorio - Item do Pedido de Venda
									aAdd( aLinItPv , {"C6_PRODUTO"    ,(cSD1P3)->D1_COD                     ,NIL}) // Obrigatorio - Produto
									aAdd( aLinItPv , {"C6_UM"         ,(cSD1P3)->D1_UM                      ,NIL}) // Obrigatorio - Unidade de Medida
									aAdd( aLinItPv , {"C6_QTDVEN"     ,nSdSb6					            ,NIL}) // Obrigatorio - Quantidade vendida
									aAdd( aLinItPv , {"C6_PRCVEN"     ,nPrcVen                             	,NIL}) // Preco unitario
									aAdd( aLinItPv , {"C6_QTDLIB"     ,0									,NIL}) // Quantidade liberada /*SD1FAT->D1_XQTDFAT*/
									aAdd( aLinItPv , {"C6_TES"        ,cTes                                	,NIL}) // Obrigatorio - TES
									aAdd( aLinItPv , {"C6_LOCAL"      ,"01"					   				,NIL}) // Obrigatorio - Armazem
									aAdd( aLinItPv , {"C6_CF"         ,cCf                                  ,NIL}) // Obrigatorio - Classifica็ใo Fiscal
									aAdd( aLinItPv , {"C6_CLI"        ,cNewCLi  		                   	,NIL}) // Obrigatorio
									aAdd( aLinItPv , {"C6_LOJA"       ,cNewLjCli        	             	,NIL}) // Obrigatorio
									aAdd( aLinItPv , {"C6_ENTREG"     ,dDataBase                          	,NIL}) // Data prevista para entrega
									aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc                            	,NIL}) // Descricao do Produto
									aAdd( aLinItPv , {"C6_PRUNIT"     ,nPrUnit                             	,NIL}) // Obrigatorio - Preco de Lista
									aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis                            	,NIL}) // Obrigatorio - Classificacao fiscal
									aAdd( aLinItPv , {"C6_TPOP"       ,"F"                                 	,NIL}) // Tipo da OP - F-Firme
									aAdd( aLinItPv , {"C6_XTIPOPV"    ,"P"                                 	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)
									aAdd( aLinItPv , {"C6_TPPROD "    ,"1"                                 	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)

									aAdd(aItPvTer, aClone(aLinItPv))
									aLinItPv := {}
								Else //Addd Glaicon Cesar 03-09-2018
									aItPvTer[nPosicao,04][02] += nSdSb6 //Addd Glaicon Cesar 03-09-2018
								EndIf //Addd Glaicon Cesar 03-09-2018

							Endif

						Endif

					Endif

					(cSD1P3)->(dbSkip())

				Enddo

				If Select(cSD1P3) > 0
					dbSelectArea(cSD1P3)
					(cSD1P3)->(dbCloseArea())
				Endif

				/*
				ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
				ฑฑบ FIM    - PODER DE TERCEIROS REPOSICAO AUTOMATICA                      บฑฑ
				ฑฑบ 																	  บฑฑ
				ฑฑบ Identifica que se trata de item em poder de terceiros que ้ controladoบฑฑ
				ฑฑบ por saldo minimo cadastrado em ClientexProduto e que necessita de uma บฑฑ
				ฑฑบ reposi็ใo                                                             บฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
				ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
				*/

			Else

				/*ฑฑฬออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Condi็ใo em que a NF de Empr้stimo nใo teve como origem um Or็amento eบฑฑ
				ฑฑบ um pedido de venda.                                                   บฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
				ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
				*/

				If !lGeraCab

					aAdd( aCabPv , { "C5_TIPO"      ,"N"                 ,NIL} ) // Tipo do PV
					aAdd( aCabPv , { "C5_EMISSAO"   ,dDataBase           ,NIL} ) // Data de Emissao
					aAdd( aCabPv , { "C5_CLIENTE"   ,SC5->C5_CLIENTE     ,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPv , { "C5_LOJACLI"   ,SC5->C5_LOJACLI     ,NIL} ) // LOJA
					aAdd( aCabPv , { "C5_CLIENT"    ,SC5->C5_CLIENTE     ,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPv , { "C5_LOJAENT"   ,SC5->C5_LOJACLI     ,NIL} ) // LOJA
					aAdd( aCabPv , { "C5_TIPOCLI"   ,"F"                 ,NIL} ) // TIPO DO CLIENTE
					aAdd( aCabPv , { "C5_TPFRETE"   ,"S"                 ,NIL} ) // TIPO DO FRETE
					aAdd( aCabPv , { "C5_CONDPAG"   ,SC5->C5_CONDPAG     ,NIL} ) // CONDICAO DO PAGAMENTO
					aAdd( aCabPv , { "C5_TABELA"    ,""     			 ,NIL} ) // TABELA DE PRECOS
					aAdd( aCabPv , { "C5_VEND1"    	,SC5->C5_VEND1	     ,NIL} ) // VENDEDOR
					aAdd( aCabPv , { "C5_XPACIEN"   ,SC5->C5_XPACIEN     ,NIL} ) // COD DO PACIENTE
					aAdd( aCabPv , { "C5_XNOMPAC"   ,SC5->C5_XNOMPAC     ,NIL} ) // NOME DO PACIENTE
					aAdd( aCabPv , { "C5_XORCAM"    ,SC5->C5_XORCAM      ,NIL} ) // COD DO ORCAMENTO
					aAdd( aCabPv , { "C5_XMEDICO"   ,SC5->C5_XMEDICO     ,NIL} ) // CODIGO DO MEDICO
					aAdd( aCabPv , { "C5_XNOMMED"   ,SC5->C5_XNOMMED     ,NIL} ) // NOME DO MEDICO
					aAdd( aCabPv , { "C5_XCONVEN"   ,SC5->C5_XCONVEN     ,NIL} ) // CODIGO DO CONVENIO
					aAdd( aCabPv , { "C5_XNOMCON"   ,SC5->C5_XNOMCON     ,NIL} ) // NOME DO CONVENIO
					aAdd( aCabPv , { "C5_XHOSPIT"   ,SC5->C5_XHOSPIT     ,NIL} ) // CODIGO DO HOSPITAL
					aAdd( aCabPv , { "C5_XNOMHOS"   ,SC5->C5_XNOMHOS     ,NIL} ) // NOME DO HOSPITAL
					aAdd( aCabPv , { "C5_XPROCED"   ,SC5->C5_XPROCED     ,NIL} ) // CODIGO DO PROCEDIMENTO
					aAdd( aCabPv , { "C5_XDESPRO"   ,SC5->C5_XDESPRO     ,NIL} ) // DESCRICAO DO PROCEDIMENTO
					aAdd( aCabPv , { "C5_XDTCIRU"   ,SC5->C5_XDTCIRU     ,NIL} ) // DATA DA CIRURGIA
					aAdd( aCabPv , { "C5_XHORCIR"   ,SC5->C5_XHORCIR     ,NIL} ) // HORA DA CIRURGIA
					aAdd( aCabPv , { "C5_VEND4"    	,SC5->C5_VEND4       ,NIL} ) // INSTRUMENTADOR
					aAdd( aCabPv , { "C5_XTIPVEN"   ,"2"                 ,NIL} ) // TIPO DE VENDA - PARTICULAR OU ORCAMENTO
					aAdd( aCabPv , { "C5_MOEDA"     ,1                   ,NIL} ) // MOEDA
					aAdd( aCabPv , { "C5_PESOL"     ,0.01                ,NIL} ) // PESO LIQUIDO
					aAdd( aCabPv , { "C5_PBRUTO"    ,0.01                ,NIL} ) // PESO BRUTO
					aAdd( aCabPv , { "C5_LIBEROK"   ,"S"                 ,NIL} ) // FLAG DE LIBERACAO DO PEDIDO
					aAdd( aCabPv , { "C5_TXMOEDA"   ,0                   ,NIL} ) // TAXA DA MOEDA
					aAdd( aCabPv , { "C5_TPCARGA"   ,"2"                 ,NIL} ) // CARGA DO OMS 1-UTILIZA - 2-NAO UTILIZA
					aAdd( aCabPv , { "C5_ORCRES"    ," "                 ,NIL} ) // NUMERO DO ORCAMENTO
					aAdd( aCabPv , { "C5_TIPLIB"    ,"1"                 ,NIL} ) // TIPO DE LIBERACAO DO PV 1 - ITEM 2 - PEDIDO
					aAdd( aCabPv , { "C5_XRETORN"  	,"S"                 ,NIL} ) // FLAG SE FOI RETORNO
					aAdd( aCabPv , { "C5_XSITUAC"  	,"A"                 ,NIL} ) // CLASSIFICACAO
					aAdd( aCabPv , { "C5_XSTATUS"  	,"A"                 ,NIL} ) // STATUS

					// Alterado por Jos้ de Assun็ใo - Totvs RJ [ 23/11/2017 ]
					// Criado para herdar a informa็ใo do Cod/Desc Projeto
					aAdd( aCabPv , { "C5_XPROJET"  	,SC5->C5_XPROJET     ,NIL} ) // CODIGO DO PROJETO
					aAdd( aCabPv , { "C5_XDESCPR"  	,SC5->C5_XDESCPR     ,NIL} ) // DESCRICAO DO PROJETO

					lGeraCab := .T.

				Endif

				zQuery := " SELECT * FROM "     + RetSqlName("SD1")+ ""
				zQuery += " WHERE D1_FILIAL = '"+ xFilial("SD1")+"' AND"
				zQuery += "       D1_DOC	= '"+ cNF      +"' AND"
				zQuery += "       D1_SERIE  = '"+ cSerie   +"' AND"
				zQuery += "       D1_FORNECE= '"+ cCliente +"' AND"
				zQuery += "       D1_LOJA  	= '"+ cLoja    +"' AND"
				zQuery += "       D1_XFATSN	= '1' AND"
				zQuery += "       D_E_L_E_T_ <> '*' "

				If Select(cSD1FAT) > 0
					dbSelectArea(cSD1FAT)
					(cSD1FAT)->(dbCloseArea())
				Endif

				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,zQuery), cSD1FAT , .F., .T.)

				dbSelectArea(cSD1FAT)
				(cSD1FAT)->(dbGotop())

				While (cSD1FAT)->(!Eof())

					//Caso o lote tenha uma data de validade
					//diferente da que estแ no arm. 01 origem
					//exibe a msg e aborta o retorno...
					DBSELECTAREA("SB8")
					SB8->(DBSETORDER(3))
					SB8->(dbGotop())

					IF !SB8->(dbSeek(xFilial("SB8")+(cSD1FAT)->D1_COD+(cSD1FAT)->D1_XLOCFAT+(cSD1FAT)->D1_LOTECTL+(cSD1FAT)->D1_NUMLOTE+(cSD1FAT)->D1_DTVALID))

						MsgAlert("Produto [ "+Alltrim((cSD1FAT)->D1_COD)+" ]- Lote [ "+Alltrim((cSD1FAT)->D1_LOTECTL)+" ], equalize a validade do lote nos armazens do sistema!","Validade diferente no Arm [ "+Alltrim((cSD1FAT)->D1_XLOCFAT)+" ]!")

					Endif

					Incproc("Gerando item(ns) do pedido de venda ...")

					cDesc   := Posicione("SB1",1,xFilial("SB1") + (cSD1FAT)->D1_COD,"B1_DESC")

					//cTes    := U_MyTesInt(2,"01",SC5->C5_CLIENTE,SC5->C5_LOJACLI,"C",SD1FAT->D1_COD,"C6_TES")//TESTE
					cTes	:= U_xTesInt((cSD1FAT)->D1_COD,"01")

					If Empty (cTes)
						cTes := If(Empty(SuperGetMV("MV_TESVEN")),"601",SuperGetMV("MV_TESVEN"))
					Endif


					//==========================================================================//
					//Incluido por Rafael Fernandes - Tratamento para poder de terceiros        //
					//==========================================================================//
					nItem    := nItem + 1

					dbSelectArea("SF4") // TES
					dbSetOrder(1)       // Codigo
					dbSeek(xFilial("SF4") + (cSD1FAT)->D1_TES)

					If Alltrim(SF4->F4_PODER3) $ 'R|D' .And. nItem == 1
						cNewCli   := ''
						cNewLjCli := ''
						GetPoder3()
					Else
						AlertBlq()
						cNewCli   := SC5->C5_CLIENTE
						cNewLjCli := SC5->C5_LOJACLI
					EndIf


					dbSelectArea("SF4") // TES
					dbSetOrder(1)       // Codigo
					dbSeek(xFilial("SF4") + cTes)

					cCf      := SF4->F4_CF
					cClasFis := Posicione("SB1",1,xFilial("SB1") + (cSD1FAT)->D1_COD,"B1_ORIGEM")
					cClasFis += SF4->F4_SITTRIB


					/*
					ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
					ฑฑบ                                                                       บฑฑ
					ฑฑบ Busca o preco original do Orcamento porque os precos informados na NF บฑฑ
					ฑฑบ de imprestimo, correspondiam ao CMV Unitario do Produto informado na  บฑฑ
					ฑฑบ tabela de pre็os cod. 006                                             บฑฑ
					ฑฑบ                                                                       บฑฑ
					ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
					ฑฑบ                                                                       บฑฑ
					ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
					*/
					nPrcVen  := (cSD1FAT)->D1_VUNIT
					nPrUnit  := (cSD1FAT)->D1_VUNIT

					nPosicao := 0
					iif(len(aItensPv)>0, nPosicao := Ascan( aItensPv, { | x | x[ 02,02 ] == (cSD1FAT)->D1_COD .and. x[ 15,02 ] == (cSD1FAT)->D1_LOTECTL } ),nil) //Addd Glaicon Cesar 03-09-2018

					If( nPosicao == 0 ) //Addd Glaicon Cesar 03-09-2018
						aAdd( aLinItPv , {"C6_ITEM"       ,strzero(nItem,2)                    	,NIL}) // Obrigatorio - Item do Pedido de Venda
						aAdd( aLinItPv , {"C6_PRODUTO"    ,(cSD1FAT)->D1_COD                    ,NIL}) // Obrigatorio - Produto
						aAdd( aLinItPv , {"C6_UM"         ,(cSD1FAT)->D1_UM                     ,NIL}) // Obrigatorio - Unidade de Medida
						aAdd( aLinItPv , {"C6_QTDVEN"     ,(cSD1FAT)->D1_XQTDFAT                ,NIL}) // Obrigatorio - Quantidade vendida
						aAdd( aLinItPv , {"C6_PRCVEN"     ,nPrcVen                             	,NIL}) // Preco unitario
						aAdd( aLinItPv , {"C6_QTDLIB"     ,0									,NIL}) // Quantidade liberada /*SD1FAT->D1_XQTDFAT*/
						aAdd( aLinItPv , {"C6_TES"        ,cTes                                	,NIL}) // Obrigatorio - TES
						aAdd( aLinItPv , {"C6_LOCAL"      ,(cSD1FAT)->D1_XLOCFAT   				,NIL}) // Obrigatorio - Armazem
						//aAdd( aLinItPv , {"C6_LOCALIZ"    ,IIF( Localiza((cSD1FAT)->D1_COD),"EMPENHO","" )							,NIL}) //Endere็o
						aAdd( aLinItPv , {"C6_CF"         ,cCf                                  ,NIL}) // Obrigatorio - Classifica็ใo Fiscal
						aAdd( aLinItPv , {"C6_CLI"        ,cNewCLi  		                   	,NIL}) // Obrigatorio
						aAdd( aLinItPv , {"C6_LOJA"       ,cNewLjCli        	             	,NIL}) // Obrigatorio
						aAdd( aLinItPv , {"C6_ENTREG"     ,dDataBase                          	,NIL}) // Data prevista para entrega
						aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc                            	,NIL}) // Descricao do Produto
						aAdd( aLinItPv , {"C6_PRUNIT"     ,nPrUnit                             	,NIL}) // Obrigatorio - Preco de Lista
						aAdd( aLinItPv , {"C6_LOTECTL"    ,(cSD1FAT)->D1_LOTECTL                ,NIL}) // Lote
						aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis                            	,NIL}) // Obrigatorio - Classificacao fiscal
						aAdd( aLinItPv , {"C6_TPOP"       ,"F"                                 	,NIL}) // Tipo da OP - F-Firme
						aAdd( aLinItPv , {"C6_XTIPOPV"    ,"P"                                 	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)
						aAdd( aLinItPv , {"C6_TPPROD "    ,"1"                                 	,NIL}) // Tipo

						If Rastro( (cSD1FAT)->D1_COD )
							dDtValid := xDtValid((cSD1FAT)->D1_COD,(cSD1FAT)->D1_LOTECTL,(cSD1FAT)->D1_XLOCFAT)
							aAdd( aLinItPv , {"C6_DTVALID"       ,dDtValid                  ,NIL}) //Dt. Validade Lote
						EndIf

						aAdd( aItensPv , aClone( aLinItPv ) )
						aLinItPv := {}

					Else //Addd Glaicon Cesar 03-09-2018
						aItensPv[nPosicao,04][02] += (cSD1FAT)->D1_XQTDFAT //Addd Glaicon Cesar 03-09-2018
					EndIf //Addd Glaicon Cesar 03-09-2018

					(cSD1FAT)->(dbSkip())

				Enddo

				If Select(cSD1FAT) > 0
					dbSelectArea(cSD1FAT)
					(cSD1FAT)->(dbCloseArea())
				Endif

				/*
				ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
				ฑฑบ INICIO - PODER DE TERCEIROS REPOSICAO AUTOMATICA                      บฑฑ
				ฑฑบ 																	  บฑฑ
				ฑฑบ Identifica que se trata de item em poder de terceiros que ้ controladoบฑฑ
				ฑฑบ por saldo minimo cadastrado em ClientexProduto e que necessita de uma บฑฑ
				ฑฑบ reposi็ใo                                                             บฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
				ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
				*/

				If !lGerCabP3

					aAdd( aCabPvP3 , { "C5_TIPO"     ,"N"                 		,NIL} ) // Tipo do PV
					aAdd( aCabPvP3 , { "C5_EMISSAO"  ,dDataBase           		,NIL} ) // Data de Emissao
					aAdd( aCabPvP3 , { "C5_CLIENTE"  ,SC5->C5_CLIENTE     		,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_LOJACLI"  ,SC5->C5_LOJACLI     		,NIL} ) // LOJA
					aAdd( aCabPvP3 , { "C5_CLIENT"   ,SC5->C5_CLIENTE     		,NIL} ) // CODIGO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_LOJAENT"  ,SC5->C5_LOJACLI     		,NIL} ) // LOJA
					aAdd( aCabPvP3 , { "C5_TIPOCLI"  ,"F"                 		,NIL} ) // TIPO DO CLIENTE
					aAdd( aCabPvP3 , { "C5_TPFRETE"  ,"S"                 		,NIL} ) // TIPO DO FRETE
					aAdd( aCabPvP3 , { "C5_CONDPAG"  ,SC5->C5_CONDPAG     		,NIL} ) // CONDICAO DO PAGAMENTO
					aAdd( aCabPvP3 , { "C5_TABELA"   ,""     			 		,NIL} ) // TABELA DE PRECOS
					aAdd( aCabPvP3 , { "C5_VEND1"    ,SC5->C5_VEND1	     		,NIL} ) // VENDEDOR
					aAdd( aCabPvP3 , { "C5_XPACIEN"  ,SC5->C5_XPACIEN     		,NIL} ) // COD DO PACIENTE
					aAdd( aCabPvP3 , { "C5_XNOMPAC"  ,SC5->C5_XNOMPAC     		,NIL} ) // NOME DO PACIENTE
					aAdd( aCabPvP3 , { "C5_XMEDICO"  ,SC5->C5_XMEDICO     		,NIL} ) // CODIGO DO MEDICO
					aAdd( aCabPvP3 , { "C5_XNOMMED"  ,SC5->C5_XNOMMED     		,NIL} ) // NOME DO MEDICO
					aAdd( aCabPvP3 , { "C5_XCONVEN"  ,SC5->C5_XCONVEN     		,NIL} ) // CODIGO DO CONVENIO
					aAdd( aCabPvP3 , { "C5_XNOMCON"  ,SC5->C5_XNOMCON     		,NIL} ) // NOME DO CONVENIO
					aAdd( aCabPvP3 , { "C5_XHOSPIT"  ,SC5->C5_XHOSPIT     		,NIL} ) // CODIGO DO HOSPITAL
					aAdd( aCabPvP3 , { "C5_XNOMHOS"  ,SC5->C5_XNOMHOS     		,NIL} ) // NOME DO HOSPITAL
					aAdd( aCabPvP3 , { "C5_XPROCED"  ,SC5->C5_XPROCED     		,NIL} ) // CODIGO DO PROCEDIMENTO
					aAdd( aCabPvP3 , { "C5_XDESPRO"  ,SC5->C5_XDESPRO     		,NIL} ) // DESCRICAO DO PROCEDIMENTO
					aAdd( aCabPvP3 , { "C5_XDTCIRU"  ,SC5->C5_XDTCIRU     		,NIL} ) // DATA DA CIRURGIA
					aAdd( aCabPvP3 , { "C5_XHORCIR"  ,SC5->C5_XHORCIR     		,NIL} ) // HORA DA CIRURGIA
					aAdd( aCabPvP3 , { "C5_VEND4"    ,SC5->C5_VEND4       		,NIL} ) // INSTRUMENTADOR
					aAdd( aCabPvP3 , { "C5_XTIPVEN"  ,"2"                 		,NIL} ) // TIPO DE VENDA - PARTICULAR OU ORCAMENTO
					aAdd( aCabPvP3 , { "C5_MOEDA"    ,1                   		,NIL} ) // MOEDA
					aAdd( aCabPvP3 , { "C5_PESOL"    ,0.01                		,NIL} ) // PESO LIQUIDO
					aAdd( aCabPvP3 , { "C5_PBRUTO"   ,0.01                		,NIL} ) // PESO BRUTO
					aAdd( aCabPvP3 , { "C5_LIBEROK"  ,"S"                 		,NIL} ) // FLAG DE LIBERACAO DO PEDIDO
					aAdd( aCabPvP3 , { "C5_TXMOEDA"  ,0                   		,NIL} ) // TAXA DA MOEDA
					aAdd( aCabPvP3 , { "C5_TPCARGA"  ,"2"                 		,NIL} ) // CARGA DO OMS 1-UTILIZA - 2-NAO UTILIZA
					aAdd( aCabPvP3 , { "C5_ORCRES"   ," "                 		,NIL} ) // NUMERO DO ORCAMENTO
					aAdd( aCabPvP3 , { "C5_TIPLIB"   ,"1"                 		,NIL} ) // TIPO DE LIBERACAO DO PV 1 - ITEM 2 - PEDIDO
					aAdd( aCabPvP3 , { "C5_XRETORN"  ,""                 		,NIL} ) // FLAG SE FOI RETORNO
					aAdd( aCabPvP3 , { "C5_XSITUAC"  ,"A"                 		,NIL} ) // CLASSIFICACAO
					aAdd( aCabPvP3 , { "C5_XSTATUS"  ,"A"                 		,NIL} ) // STATUS
					aAdd( aCabPvP3 , { "C5_XOBS"  	 ,"PV REPOSICAO AUTOMATICA"	,NIL} ) // OBS

					// Alterado por Jos้ de Assun็ใo - Totvs RJ [ 23/11/2017 ]
					// Criado para herdar a informa็ใo do Cod/Desc Projeto
					aAdd( aCabPvP3 , { "C5_XPROJET"  ,SC5->C5_XPROJET     		,NIL} ) // CODIGO DO PROJETO
					aAdd( aCabPvP3 , { "C5_XDESCPR"  ,SC5->C5_XDESCPR     		,NIL} ) // DESCRICAO DO PROJETO

					lGerCabP3 := .T.

				Endif

				// Select de todos os itens que estใo retornando para verificar se necessita
				// reposi็ใo automatica de Poder de Terceiros

				P3Query := " SELECT * FROM "+RetSqlName("SD1")+ ""
				P3Query += " WHERE D1_FILIAL 	= 	'"+ xFilial("SD1")	+"' AND"
				P3Query += "       D1_DOC		= 	'"+ cNF      		+"' AND"
				P3Query += "       D1_SERIE  	= 	'"+ cSerie   		+"' AND"
				P3Query += "       D1_FORNECE	= 	'"+ cCliente 		+"' AND"
				P3Query += "       D1_LOJA  	= 	'"+ cLoja    		+"' AND"
				P3Query += "       D_E_L_E_T_ 	<> 	'*' "

				If Select(cSD1P3) > 0
					dbSelectArea(cSD1P3)
					(cSD1P3)->(dbCloseArea())
				Endif

				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,P3Query), cSD1P3 , .F., .T.)

				dbSelectArea(cSD1P3)
				(cSD1P3)->(dbGotop())

				While (cSD1P3)->(!Eof())

					Incproc("Gerando item(ns) Rep. automatica Poder de Terceiros ...")

					dbSelectArea("SA7")
					dbSetOrder(1) // Cliente + Loja + Produto
					If dbSeek(xFilial("SA7") + (cSD1P3)->D1_FORNECE + (cSD1P3)->D1_LOJA + (cSD1P3)->D1_COD)

						If SA7->A7_XESTMIN <> 0

							cQuerySB6 := "SELECT Est_Min.Cliente, Est_Min.Loja, Est_Min.Produto, "
							cQuerySB6 += "       Est_Min.Est_Min, Sld_PoderTerc.Sld_PoderTerc, "
							cQuerySB6 += "       SUM(Est_Min.Est_Min-Sld_PoderTerc.Sld_PoderTerc)AS Saldo "
							cQuerySB6 += "     FROM "
							cQuerySB6 += "        (SELECT A7_CLIENTE Cliente, A7_LOJA Loja, A7_PRODUTO Produto, A7_XESTMIN Est_Min "
							cQuerySB6 += "             FROM " + RetSqlName("SA7") + " "
							cQuerySB6 += "             WHERE   A7_FILIAL   = '" + xFilial("SA7") + "' "
							cQuerySB6 += "                 AND A7_CLIENTE  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                 AND A7_LOJA     = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                 AND A7_PRODUTO  = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                 AND A7_XESTMIN <> '0' "
							cQuerySB6 += "                 AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "       AS Est_Min CROSS JOIN "
							cQuerySB6 += "        (SELECT SUM( (ISNULL(Sld_Remessa.Sld_Remessa,0)) - (ISNULL(Sld_Devolucao.Sld_Devolucao,0)) )AS Sld_PoderTerc "
							cQuerySB6 += "              FROM "
							cQuerySB6 += "                 (SELECT SUM(B6_SALDO) Sld_Remessa "
							cQuerySB6 += "                       FROM " + RetSqlName("SB6") + " "
							cQuerySB6 += "                       WHERE   B6_FILIAL  = '" + xFilial("SB6")  + "' "
							cQuerySB6 += "                           AND B6_CLIFOR  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                           AND B6_LOJA    = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                           AND B6_PRODUTO = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                           AND B6_PODER3  = 'R' "
							cQuerySB6 += "                           AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "               AS Sld_Remessa CROSS JOIN "
							cQuerySB6 += "                (SELECT      SUM(B6_SALDO) Sld_Devolucao "
							cQuerySB6 += "                      FROM " + RetSqlName("SB6") + " "
							cQuerySB6 += "                      WHERE   B6_FILIAL  = '" + xFilial("SB6")  + "' "
							cQuerySB6 += "                          AND B6_CLIFOR  = '" + (cSD1P3)->D1_FORNECE + "' "
							cQuerySB6 += "                          AND B6_LOJA    = '" + (cSD1P3)->D1_LOJA    + "' "
							cQuerySB6 += "                          AND B6_PRODUTO = '" + (cSD1P3)->D1_COD     + "' "
							cQuerySB6 += "                          AND B6_PODER3  = 'D' "
							cQuerySB6 += "                          AND D_E_L_E_T_ = ' ') "
							cQuerySB6 += "                       AS Sld_Devolucao) AS Sld_PoderTerc "
							cQuerySB6 += "     GROUP BY Est_Min.Cliente, Est_Min.Loja, Est_Min.Produto, "
							cQuerySB6 += "              Est_Min.Est_Min, Sld_PoderTerc.Sld_PoderTerc "

							memowrite("C:\Totvs\Terceiros.SQL",cQuerySB6)

							If Select(cAliasSB6) > 0
								dbSelectArea(cAliasSB6)
								(cAliasSB6)->(dbCloseArea())
							Endif

							TcQuery cQuerySB6 Alias (cAliasSB6) NEW

							(cAliasSB6)->(dbGoTop())

							If (cAliasSB6)->(!Eof())
								nSdSb6 := (cAliasSB6)->Saldo
							Endif

							If Select(cAliasSB6) > 0
								dbSelectArea(cAliasSB6)
								(cAliasSB6)->(dbCloseArea())
							Endif

							// Verifica se saldo (Estoque Min - Qtd em P3) e maior
							// que 0, caracterizando necessidade de reposi็ใo
							// pedido de emprestimo
							If nSdSb6 > 0

								cDesc   := Posicione("SB1",1,xFilial("SB1") + SA7->A7_PRODUTO,"B1_DESC")

								cTes	:= U_xTesInt(SA7->A7_PRODUTO,"Y")

								If Empty (cTes)
									cTes := "507"
								Endif

								nItem    := nItem + 1

								cNewCli   := (cSD1P3)->D1_FORNECE
								cNewLjCli := (cSD1P3)->D1_LOJA

								dbSelectArea("SF4") // TES
								dbSetOrder(1)       // Codigo
								IF dbSeek(xFilial("SF4") + cTes)
									cCf      := SF4->F4_CF
									cClasFis := Posicione("SB1",1,xFilial("SB1") + (cSD1P3)->D1_COD,"B1_ORIGEM")
									cClasFis += SF4->F4_SITTRIB
								ENDIF

								nPrcVen  := (cSD1P3)->D1_VUNIT
								nPrUnit  := (cSD1P3)->D1_VUNIT

								nPosicao := 0
								iif(len(aItPvTer)>0, nPosicao := Ascan( aItPvTer, { | x | x[ 02,02 ] == (cSD1P3)->D1_COD } ),nil ) //Addd Glaicon Cesar 03-09-2018

								If( nPosicao == 0 ) //Addd Glaicon Cesar 03-09-2018
									aAdd( aLinItPv , {"C6_ITEM"       ,strzero(nItem,2)                    	,NIL}) // Obrigatorio - Item do Pedido de Venda
									aAdd( aLinItPv , {"C6_PRODUTO"    ,(cSD1P3)->D1_COD                     ,NIL}) // Obrigatorio - Produto
									aAdd( aLinItPv , {"C6_UM"         ,(cSD1P3)->D1_UM                      ,NIL}) // Obrigatorio - Unidade de Medida
									aAdd( aLinItPv , {"C6_QTDVEN"     ,nSdSb6					            ,NIL}) // Obrigatorio - Quantidade vendida
									aAdd( aLinItPv , {"C6_PRCVEN"     ,nPrcVen                             	,NIL}) // Preco unitario
									aAdd( aLinItPv , {"C6_QTDLIB"     ,0									,NIL}) // Quantidade liberada /*SD1FAT->D1_XQTDFAT*/
									aAdd( aLinItPv , {"C6_TES"        ,cTes                                	,NIL}) // Obrigatorio - TES
									aAdd( aLinItPv , {"C6_LOCAL"      ,"01"					   				,NIL}) // Obrigatorio - Armazem
									aAdd( aLinItPv , {"C6_CF"         ,cCf                                  ,NIL}) // Obrigatorio - Classifica็ใo Fiscal
									aAdd( aLinItPv , {"C6_CLI"        ,cNewCLi  		                   	,NIL}) // Obrigatorio
									aAdd( aLinItPv , {"C6_LOJA"       ,cNewLjCli        	             	,NIL}) // Obrigatorio
									aAdd( aLinItPv , {"C6_ENTREG"     ,dDataBase                          	,NIL}) // Data prevista para entrega
									aAdd( aLinItPv , {"C6_DESCRI"     ,cDesc                            	,NIL}) // Descricao do Produto
									aAdd( aLinItPv , {"C6_PRUNIT"     ,nPrUnit                             	,NIL}) // Obrigatorio - Preco de Lista
									aAdd( aLinItPv , {"C6_CLASFIS"    ,cClasFis                            	,NIL}) // Obrigatorio - Classificacao fiscal
									aAdd( aLinItPv , {"C6_TPOP"       ,"F"                                 	,NIL}) // Tipo da OP - F-Firme
									aAdd( aLinItPv , {"C6_XTIPOPV"    ,"P"                                 	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)
									aAdd( aLinItPv , {"C6_TPPROD "    ,"1"                                 	,NIL}) // Tipo do PV (Implante / Instrumental / Trauma)

									aAdd(aItPvTer, aClone(aLinItPv))
									aLinItPv := {}
								Else //Addd Glaicon Cesar 03-09-2018
									aItPvTer[nPosicao,04][02] += nSdSb6 //Addd Glaicon Cesar 03-09-2018
								EndIf //Addd Glaicon Cesar 03-09-2018

							Endif

						Endif

					Endif

					(cSD1P3)->(dbSkip())

				Enddo

				If Select(cSD1P3) > 0
					dbSelectArea(cSD1P3)
					(cSD1P3)->(dbCloseArea())
				Endif

				/*
				ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
				ฑฑบ FIM    - PODER DE TERCEIROS REPOSICAO AUTOMATICA                      บฑฑ
				ฑฑบ 																	  บฑฑ
				ฑฑบ Identifica que se trata de item em poder de terceiros que ้ controladoบฑฑ
				ฑฑบ por saldo minimo cadastrado em ClientexProduto e que necessita de uma บฑฑ
				ฑฑบ reposi็ใo                                                             บฑฑ
				ฑฑบ                                                                       บฑฑ
				ฑฑบ Analista Resp. Jos้ de Assun็ใo                                       บฑฑ
				ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
				*/

			Endif

		Endif

	Endif


	nMeter3 := 100
	oMeter3:Set(nMeter3)
	oSay4:lVisibleControl := .T.
	oDlg:CommitControls()
	oDlg:Refresh()

Return

	*-----------------------------*
User Function fGeraPV()
	*-----------------------------*
	// Funcao para geracao do Pedido de Venda

	Private lMsErroAuto := .F.

	RestArea(aAreaSC5)
	RestArea(aAreaSC6)
	RestArea(aAreaSC9)
	RestArea(aAreaSCJ)
	RestArea(aAreaSCK)
	RestArea(aAreaSF1)
	RestArea(aAreaSD1)
	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSDA)
	RestArea(aAreaSDB)
	RestArea(aAreaSB6)
	RestArea(aAreaSF4)
	RestArea(aAreaSA7)
	RestArea(aAreaSA1)

	dbSelectArea("SC5")
	dbSetOrder(1)

	dbSelectArea("SC6")
	dbSetOrder(1)

	dbSelectArea("SC9")
	dbSetOrder(1)

	dbSelectArea("SCJ")
	dbSetOrder(1)

	dbSelectArea("SCK")
	dbSetOrder(1)

	dbSelectArea("SF1")
	dbSetOrder(1)

	dbSelectArea("SD1")
	dbSetOrder(1)

	dbSelectArea("SF2")
	dbSetOrder(1)

	dbSelectArea("SD2")
	dbSetOrder(1)

	dbSelectArea("SDA")
	dbSetOrder(1)

	dbSelectArea("SDB")
	dbSetOrder(1)

	dbSelectArea("SB6")
	dbSetOrder(1)

	dbSelectArea("SF4")
	dbSetOrder(1)

	dbSelectArea("SA7")
	dbSetOrder(1)

	dbSelectArea("SA1")
	dbSetOrder(1)


	If cNrPvTer = "P3"

		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPvP3,aItPvTer,3)

	Else

		MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItensPv,3)

	Endif

	If lMsErroAuto

		MakeDir("C:\LogSiga")

		cPath := "C:\LogSiga"
		cFile := cFilAnt + AllTrim(SZ5->Z5_NUM) + ".log"
		MostraErro(cPath,cFile)
		lMsErroAuto := .F.
		MsgAlert("Pedido de Venda nao gerado."+chr(13)+chr(10)+;
			"Verifique o LOG (" + cFile + ") na pasta C:\LogSiga do sistema.", "Atencao !")
	Else

		If cNrPvTer = "P3"

			Aviso("AVISO!",Alltrim(cUserName)+", PV Reposi็ใo Automแtica Poder de Terceiro Nr " + SC5->C5_NUM + " gerado com sucesso!",{"Ok"})

			//chama a rotina de envio de e-mail
			U_WF_007A(nil, nil, SC5->C5_NUM)


			nMeter6 := 100
			oMeter6:Set(nMeter6)
			cPoder3	:= "........................100% concluํdo"
			oSay10:lVisibleControl := .T.
			oDlg:CommitControls()
			oDlg:Refresh()

		Else

			dbSelectArea("SCJ")
			dbSetOrder(1)
			If dbSeek(xFilial('SCJ')+cNumOrcam)
				RecLock('SCJ',.F.)
				SCJ->CJ_STATUS := 'B'
				SCJ->(MsUnlock())
			EndIf

			dbSelectArea("SC6")
			dbSetOrder(1)
			MsSeek(xFilial("SC6")+SC5->C5_NUM)

			While ("SC6")->(!Eof()) .And. ("SC6")->C6_FILIAL == xFilial("SC6") .And.;
					("SC6")->C6_NUM == SC5->C5_NUM

				RecLock("SC6",.F.) //Forca a atualizacao do Buffer no Top
				nC6QtdLib := ( SC6->C6_QTDVEN - ( SC6->C6_QTDEMP + SC6->C6_QTDENT ) )

				If nC6QtdLib > 0

					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณLibera por Item de Pedido                                               ณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					Begin Transaction
						MaLibDoFat(SC6->(RecNo()),@nC6QtdLib,.F.,.F.,.T.,.T.,.F.,.F.)
					End Transaction

				EndIf

				SC6->(MsUnLock())

				dbSelectArea("SC6")
				("SC6")->(dbSkip())

			EndDo

			//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
			//ณAtualiza o Flag do Pedido de Venda                                      ณ
			//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
			Begin Transaction
				SC6->(MaLiberOk({SC5->C5_NUM},.F.))
			End Transaction

			Aviso("AVISO!",Alltrim(cUserName)+", Pedido de Venda n๚mero " + SC5->C5_NUM + " gerado com sucesso!",{"Ok"})
			// Identifica Pedido gerado no SC9 para libera-lo da conferencia cega,
			// jแ que o produto foi utilizado e nใo mais estแ no estoque.

			dbSelectArea("SC9")
			dbSetOrder(1)
			If dbSeek(xFilial("SC9") + SC5->C5_NUM)

				While ("SC9")->(!Eof()) .And. ("SC9")->C9_FILIAL == xFilial("SC9") .And. ("SC9")->C9_PEDIDO == SC5->C5_NUM

					RecLock("SC9",.F.)
					Replace C9_XSEPARA with "1" // Jแ Separado
					Replace C9_XCONF  with "S" // Jแ conferido
					MsUnLock()

					dbSelectArea("SC9")
					("SC9")->(dbSkip())

				EndDo

			Endif

			*'Yttalo P. Martins--INICIO----------------------------------------'*
			//guarda na variแvel cPedWF o pedido de retorno gerado para WorkFlow
			cPedWF := SC5->C5_NUM
			//guarda na SF1 o pedido de retorno gerado
			RecLock("SF1",.F.)
			SF1->F1_XPEDRET := SC5->C5_NUM
			MSUnlock()

			//Rotina de transfer๊ncia de pedido para o armaz้m "35" e endere็o "EMPENHO"
			//U_WMEA014(SC5->C5_NUM)
			*'Yttalo P. Martins--FIM-------------------------------------------'*

			nMeter5 := 100
			oMeter5:Set(nMeter5)
			oSay8:lVisibleControl := .T.
			oDlg:CommitControls()
			oDlg:Refresh()

		Endif

	Endif

Return

	*-----------------------------*
User Function fCopiaSZ5()
	*-----------------------------*
	/*
	Local aAreaAtu := GetArea()
	Local aAreaSZ5 := SZ5->(GetArea())
	Local aAreaSZ6 := SZ6->(GetArea())
	*/
	Local aCabSZ5  := {}
	Local aIteSZ6  := {}
	Local cNum     := SZ5->Z5_NUM
	Local cNovoNum := GetSX8Num("SZ5","Z5_NUM")
	Local nLP,nJp
	dbSelectArea("SZ5")

	For nLp := 1 to fCount()
		aAdd(aCabSZ5,{FieldName(nLp),FieldGet(nLp)})
	Next

	RecLock("SZ5",.T.)
	For nLp := 1 to Len(aCabSZ5)
		If Alltrim(aCabSZ5[nLp,1]) == "Z5_NUM"
			//Replace Z5_NUM with cNovoNum
			SZ5->Z5_NUM := cNovoNum
		Else
			//Replace &aCabSZ5[nLp,1] with aCabSZ5[nLp,2]
			&("SZ5->"+aCabSZ5[nLp,1]) := aCabSZ5[nLp,2]
			If Alltrim(aCabSZ5[nLp,1]) == "Z5_KIT"
				//Replace Z5_KIT with "N"
				SZ5->Z5_KIT := "N"
			Endif
		Endif
	Next
	MsUnLock()

	dbSelectArea("SZ6")
	dbSetOrder(1)
	dbSeek(xFilial("SZ6") + cNum)
	nItem := 0

	While SZ6->Z6_FILIAL + SZ6->Z6_NUM = xFilial("SZ6") + cNum .and. SZ6->(!Eof())

		If Empty(SZ6->Z6_KIT)

			nItem := nItem + 1
			For nLp := 1 to fCount()
				aAdd(aIteSZ6,{nItem,FieldName(nLp),FieldGet(nLp)})
			Next

		Endif

		SZ6->(dbSkip())

	Enddo

	For nLp := 1 to Len(aIteSZ6)
		nItem := aIteSZ6[nLp,1]
		RecLock("SZ6",.T.)
		For nJp := nLp to Len(aIteSZ6)
			If aIteSZ6[nJp,1] = nItem
				//If Alltrim(aCabSZ5[nLp,1]) == "Z6_NUM"
				If Alltrim(aIteSZ6[nLp,2]) == "Z6_NUM"
					//Replace Z6_NUM with cNovoNum
					SZ6->Z6_NUM := cNovoNum
				Else
					//Replace &aIteSZ6[nLp,2] with aIteSZ6[nLp,3]
					&("SZ6->"+aIteSZ6[nLp,2]) := aIteSZ6[nLp,3]
				Endif
			Else
				Exit
			Endif
		Next
		MsUnLock()

	Next

	ConfirmSX8()

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfEnderNF  บAutor  ณManoel de Sa      บ Data ณ  14/07/09   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que endere็a o restante dos itens da NF de Retorno   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fEnderNF()

	Local cItemSDB := "0001"
	Local cSD1FAT  := GetNextAlias()
	Local cTMPIMP  := GetNextAlias()
	Local cTMPSDB  := GetNextAlias()
	Local nContBarra	:= 0

	zQuery := " SELECT * FROM "     + RetSqlName("SD1")+ ""
	zQuery += " WHERE D1_FILIAL = '"+ xFilial("SD1")+"' AND"
	zQuery += "       D1_DOC	= '"+ cNF      +"' AND"
	zQuery += "       D1_SERIE  = '"+ cSerie   +"' AND"
	zQuery += "       D1_FORNECE= '"+ cCliente +"' AND"
	zQuery += "       D1_LOJA  	= '"+ cLoja    +"' AND"
	//zQuery += "       D1_XFATSN	<> '1' AND"
	zQuery += "       D_E_L_E_T_ <> '*' "

	If Select(cSD1FAT) > 0
		dbSelectArea(cSD1FAT)
		(cSD1FAT)->(dbCloseArea())
	Endif

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,zQuery), cSD1FAT , .F., .T.)

	dbSelectArea(cSD1FAT)
	(cSD1FAT)->(dbGotop())

	While (cSD1FAT)->(!Eof())


		Incproc("Verificando / Endere็ando item(ns) da nota...")

		cQuery := " SELECT DA_NUMSEQ FROM "+RETSQLNAME("SDA")+ " "
		cQuery += " WHERE DA_FILIAL  = '"+xFilial("SDA")+"' AND "
		cQuery += "       DA_PRODUTO = '"+(cSD1FAT)->D1_COD+"' AND "
		cQuery += "       DA_LOCAL   = '"+(cSD1FAT)->D1_LOCAL+"' AND "
		cQuery += "       DA_LOTECTL = '"+(cSD1FAT)->D1_LOTECTL+"' AND "
		cQuery += "       DA_DOC 	 = '"+(cSD1FAT)->D1_DOC+"' AND "
		cQuery += "       DA_SERIE 	 = '"+(cSD1FAT)->D1_SERIE+"' AND "
		cQuery += "       DA_SALDO   > 0 AND "//= "+STR(SD1FAT->D1_QUANT)+" AND "
		cQuery += "       D_E_L_E_T_ <> '*' "

		If Select(cTMPIMP) > 0
			dbSelectArea(cTMPIMP)
			(cTMPIMP)->(dbCloseArea())
		Endif

		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,CQUERY), cTMPIMP , .F., .T.)

		dbSelectArea(cTMPIMP)
		(cTMPIMP)->(dbGotop())

		If (cTMPIMP)->(!Eof())

			cNumSeq := (cTMPIMP)->DA_NUMSEQ

			*'Yttalo P. Martins-INICIO--------------------------------------------------------------------------'*
			*'endere็o nใo era encontrado na SDB pelo dbseek, jแ que o DB_ITEM estava diferente do item da nota-'*
			/*
			cLocaliz := "INSTR"

			DbSelectArea("SDB")
			DbSetOrder(16)
			If DbSeek(xFilial("SDB")+SD1FAT->D1_NFORI + SD1FAT->D1_SERIORI + STRZERO(Val(SD1FAT->D1_ITEMORI),TamSX3("DB_ITEM")[1]) + SD1FAT->D1_FORNECE + SD1FAT->D1_LOJA + SD1FAT->D1_COD + SD1FAT->D1_LOTECTL)

			If SD1FAT->D1_LOCAL != SDB->DB_LOCAL
			cLocaliz := "ATRANSFERIR"
			Else
			cLocaliz := SDB->DB_LOCALIZ
			EndIf

			Endif
			*/
			cQuerySDB := " SELECT * FROM "+RETSQLNAME("SDB")+ " "
			cQuerySDB += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"' AND "
			cQuerySDB += "       DB_DOC 	= '"+(cSD1FAT)->D1_NFORI+"' AND "
			cQuerySDB += "       DB_SERIE 	= '"+(cSD1FAT)->D1_SERIORI+"' AND "
			cQuerySDB += "       DB_CLIFOR 	= '"+(cSD1FAT)->D1_FORNECE+"' AND "
			cQuerySDB += "       DB_LOJA 	= '"+(cSD1FAT)->D1_LOJA+"' AND "
			cQuerySDB += "       DB_PRODUTO = '"+(cSD1FAT)->D1_COD+"' AND "
			cQuerySDB += "       DB_LOTECTL = '"+(cSD1FAT)->D1_LOTECTL+"' AND "
			cQuerySDB += "       D_E_L_E_T_ <> '*' "

			If Select(cTMPSDB) > 0
				dbSelectArea(cTMPSDB)
				(cTMPSDB)->(dbCloseArea())
			Endif

			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuerySDB), cTMPSDB , .F., .T.)

			dbSelectArea(cTMPSDB)
			(cTMPSDB)->(dbGotop())

			If (cTMPSDB)->(!EOF())
				cLocaliz := (cTMPSDB)->DB_LOCALIZ
			Else
				cLocaliz := "ATRANSFERIR"
			EndIf

			If Select(cTMPSDB) > 0
				dbSelectArea(cTMPSDB)
				(cTMPSDB)->(dbCloseArea())
			Endif

			*'Yttalo P. Martins-FIM-------------------------------------------------------------------------'*

			//DbSelectArea("SD1")

			aEnderecaH := {}
			aEnderecaI := {}

			//Prepara vetor para endere็amento execauto
			aAdd(aEnderecaH,{"DA_FILIAL"    ,xFilial("SDA")                               					,NIL})
			aAdd(aEnderecaH,{"DA_PRODUTO"   ,PADR(AllTrim((cSD1FAT)->D1_COD),TamSx3("D1_COD")[1])     			,NIL})
			aAdd(aEnderecaH,{"DA_LOCAL"     ,SubSTR((cSD1FAT)->D1_LOCAL,1,TamSx3("D3_LOCAL")[1])      			,NIL})
			aAdd(aEnderecaH,{"DA_LOTECTL"   ,SubSTR(AllTrim((cSD1FAT)->D1_LOTECTL),1,TamSx3("D3_LOTECTL")[1])  ,NIL})
			aAdd(aEnderecaH,{"DA_QTDORI"    ,(cSD1FAT)->D1_QUANT		                                 		,Nil})
			aAdd(aEnderecaH,{"DA_SALDO"     ,(cSD1FAT)->D1_QUANT						                   		,Nil})
			aAdd(aEnderecaH,{"DA_DATA"      ,dDataBase                                    					,NiL})
			aAdd(aEnderecaH,{"DA_NUMSEQ"    ,cNumSeq                                     					,NiL})

			//cItemSDB := IIF( (SD1FAT->D1_QUANT-SD1FAT->D1_XQTDFAT) > 0,"0002","0001")
			cItemSDB := "0001"

			aAdd(aEnderecaI,{{"DB_FILIAL"   ,xFilial("SDB")                					,NIL},;
				{"DB_PRODUTO"   ,PADR(AllTrim((cSD1FAT)->D1_COD),TamSx3("D1_COD")[1])        		,NIL},;
				{"DB_LOCAL"     ,SubSTR((cSD1FAT)->D1_LOCAL,1,TamSx3("D3_LOCAL")[1])  				,NIL},;
				{"DB_ITEM"      ,cItemSDB														,NIL},;
				{"DB_LOCALIZ"   ,SubSTR(AllTrim(cLocaliz),1,TamSx3("DB_LOCALIZ")[1])		  	,NIL},;
				{"DB_DOC"     	,(cSD1FAT)->D1_DOC			                                 		,Nil},;
				{"DB_SERIE"     ,(cSD1FAT)->D1_SERIE		                                 		,Nil},;
				{"DB_CLIFOR"    ,(cSD1FAT)->D1_FORNECE		                                 		,Nil},;
				{"DB_LOJA"     	,(cSD1FAT)->D1_LOJA		                                 		,Nil},;
				{"DB_TIPONF"    ,(cSD1FAT)->D1_TIPO		                                 		,Nil},;
				{"DB_ORIGEM"    ,"SD1"					                                 		,Nil},;
				{"DB_LOTECTL"   ,(cSD1FAT)->D1_LOTECTL		                                 		,Nil},;
				{"DB_TIPO"     	,(cSD1FAT)->D1_TIPO		                                 		,Nil},;
				{"DB_QUANT"     ,(cSD1FAT)->D1_QUANT					                         	,Nil},;
				{"DB_DATA"      ,dDataBase                          		          			,NiL}})

			lMsErroAuto := .F.

			DbSelectArea("SDA")
			//SET FILTER TO SDA->DA_FILIAL+AllTrim(SDA->DA_PRODUTO)+AllTrim(SDA->DA_LOCAL)+AllTrim(SDA->DA_NUMSEQ) == xFilial("SDA")+Alltrim((cSD1FAT)->D1_COD)+Alltrim((cSD1FAT)->D1_LOCAL)+cNumSeq

			MSExecAuto({|x,y,z| MATA265(x,y,z)},aEnderecaH,aEnderecaI,3)

			IF lMsErroAuto
				MostraErro()
				DisarmTransaction()
				lMsErroAuto := .T.
				return
			EndIF

		Endif

		If Select(cTMPIMP) > 0
			dbSelectArea(cTMPIMP)
			(cTMPIMP)->(dbCloseArea())
		Endif

		(cSD1FAT)->(dbSkip())

	Enddo

	If Select(cSD1FAT) > 0
		dbSelectArea(cSD1FAT)
		(cSD1FAT)->(dbCloseArea())
	Endif

	nMeter2 := 100
	oMeter2:Set(nMeter2)
	oSay2:lVisibleControl := .T.
	oDlg:CommitControls()
	oDlg:Refresh()


return
	***************************************************************************************************************************************************
	*'Yttalo P. Martins_INICIO-----------------------------------------------------------------------------------------------------------------------'*
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfEnderPed  บAutor  ณYttalo P. Martins  บ Data ณ  18/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que transfere os itens a serem faturados para gerar  บฑฑ
ฑฑบ          ณo pedido de venda                                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function fEnderPed(lErro)

	Local aTransf  := {}
	Local dDtValid  := StoD("20491231")
	Local cDocSD3   := ""
	Local cEnderOri := ""
	Local cSD1FAT  := GetNextAlias()
	Local cTMPSDB  := GetNextAlias()

	dbselectarea("SD3")
	cDocSD3  := nextnumero("SD3", 2, "D3_DOC", .T.)

	zQuery := " SELECT * FROM "     + RetSqlName("SD1")+ ""
	zQuery += " WHERE D1_FILIAL = '"+ xFilial("SD1")+"' AND"
	zQuery += "       D1_DOC	= '"+ cNF      +"' AND"
	zQuery += "       D1_SERIE  = '"+ cSerie   +"' AND"
	zQuery += "       D1_FORNECE= '"+ cCliente +"' AND"
	zQuery += "       D1_LOJA  	= '"+ cLoja    +"' AND"
	zQuery += "       D1_XFATSN	= '1' AND"
	zQuery += "       D1_LOTECTL <> ' ' AND"
	zQuery += "       D_E_L_E_T_ <> '*' "

	If Select(cSD1FAT) > 0
		dbSelectArea(cSD1FAT)
		(cSD1FAT)->(dbCloseArea())
	Endif

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,zQuery), cSD1FAT , .F., .T.)

	dbSelectArea(cSD1FAT)
	(cSD1FAT)->(dbGotop())

	While (cSD1FAT)->(!Eof())

		Incproc("Verificando / Transferindo item(ns) para Armazem de Faturamento...")

		cArea := GetArea()

		//------------------------------------------------------------------------------
		//Query retorna endere็o de origem da nota
		cQuerySDB := " SELECT * FROM "+RETSQLNAME("SDB")+ " "
		cQuerySDB += " WHERE DB_FILIAL  = '"+xFilial("SDB")+"' AND "
		cQuerySDB += "       DB_DOC 	= '"+(cSD1FAT)->D1_NFORI+"' AND "
		cQuerySDB += "       DB_SERIE 	= '"+(cSD1FAT)->D1_SERIORI+"' AND "
		cQuerySDB += "       DB_CLIFOR 	= '"+(cSD1FAT)->D1_FORNECE+"' AND "
		cQuerySDB += "       DB_LOJA 	= '"+(cSD1FAT)->D1_LOJA+"' AND "
		cQuerySDB += "       DB_PRODUTO = '"+(cSD1FAT)->D1_COD+"' AND "
		cQuerySDB += "       DB_LOTECTL = '"+(cSD1FAT)->D1_LOTECTL+"' AND "
		cQuerySDB += "       D_E_L_E_T_ <> '*' "

		If Select(cTMPSDB) > 0
			dbSelectArea(cTMPSDB)
			(cTMPSDB)->(dbCloseArea())
		Endif

		dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuerySDB), cTMPSDB , .F., .T.)

		dbSelectArea(cTMPSDB)
		(cTMPSDB)->(dbGotop())

		If (cTMPSDB)->(!EOF())

			cEnderOri := (cTMPSDB)->DB_LOCALIZ
			cLocaliz  := "EMPENHO"

		Else

			cEnderOri := ""
			cLocaliz  := ""

		EndIf

		If Select(cTMPSDB) > 0
			dbSelectArea(cTMPSDB)
			(cTMPSDB)->(dbCloseArea())
		Endif

		RestArea(cArea)
		//-----------------------------------------------------------------------------------------

		//aTransf  := {}
		xaSD3Doc := {}
		//	If Rastro((cSD1FAT)->D1_COD) != Nil
		//If Rastro((cSD1FAT)->D1_COD)
		dDtValid := xDtValid((cSD1FAT)->D1_COD,(cSD1FAT)->D1_LOTECTL,(cSD1FAT)->D1_LOCAL)
		//Else
		//dDtValid := CtoD("  /  /  ")
		//EndIf
		//Else
		//	dDtValid := CtoD("  /  /  ")
		//EndIf

		nPosicao := 0

		iif(len(aTransf)>0, nPosicao := Ascan( aTransf, { | x | x[ 01 ] == (cSD1FAT)->D1_COD .and. x[ 06 ] == (cSD1FAT)->D1_LOTECTL} ),nil) //Addd Glaicon Cesar 03-09-2018 - verifica se ja existe o item

		If( nPosicao == 0 ) //Addd Glaicon Cesar 03-09-2018
			aAdd( aTransf, {(cSD1FAT)->D1_COD, ;										// Produto origem
			(cSD1FAT)->D1_LOCAL, ; 														// Almox origem
			(cSD1FAT)->D1_XQTDFAT, ;													// Quantidade a transferir
			cDocSD3, ;                              									// Documento
			dDataBase, ;                            									// Data
			(cSD1FAT)->D1_LOTECTL, ;   													// Lote origem
			dDtValid, ;																	// Validade
			cEnderOri, ;																// Endere็o origem
			(cSD1FAT)->D1_COD, ;										 				// Produto destino
			(cSD1FAT)->D1_XLOCFAT, ; 													// Almox destino
			cLocaliz, ;																	// Endere็o destino
			.F., ;    																	// Indica se e estorno
			(cSD1FAT)->D1_LOTECTL})														// Lote destino

			AADD(xaSD3Doc,{cNF,cSerie})
		Else //Addd Glaicon Cesar 03-09-2018
			aTransf[nPosicao,03] += (cSD1FAT)->D1_XQTDFAT //Addd Glaicon Cesar 03-09-2018
		EndIf //Addd Glaicon Cesar 03-09-2018

		//TransfItem(aTransf,@lErro)

		(cSD1FAT)->(dbSkip())

	Enddo

	TransfItem(aTransf,@lErro)

	If Select(cSD1FAT) > 0
		dbSelectArea(cSD1FAT)
		(cSD1FAT)->(dbCloseArea())
	Endif

return

	********************************************************************************************************************************
Static Function xDtValid(cCodOri,cLote,cLocal)
	Local dData     := StoD("20491231")
	Local cQuerySB8 := ""
	Local cAliasSB8 := GetNextAlias()

	cQuerySB8 := "SELECT * "
	cQuerySB8 += "	   FROM " + RetSqlName("SB8") + " "
	cQuerySB8 += "	   WHERE   B8_FILIAL   = '" + xFilial("SB8")  + "' "
	cQuerySB8 += "	       AND B8_PRODUTO  = '" + cCodOri           + "' "
	cQuerySB8 += "	       AND B8_LOTECTL  = '" + cLote           + "' "
	cQuerySB8 += "	       AND B8_LOCAL    = '" + cLocal          + "' "
	cQuerySB8 += "	       AND D_E_L_E_T_  = ' ' "

	If Select(cAliasSB8) > 0
		dbSelectArea(cAliasSB8)
		(cAliasSB8)->(dbCloseArea())
	Endif

	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuerySB8), cAliasSB8 , .F., .T.)

	dbSelectArea(cAliasSB8)
	(cAliasSB8)->(dbGoTop())

	If (cAliasSB8)->(!EOF())
		dData := STOD((cAliasSB8)->B8_DTVALID)
	Else
		dData := StoD("20491231")
	EndIf

	If Select(cAliasSB8) > 0
		dbSelectArea(cAliasSB8)
		(cAliasSB8)->(dbCloseArea())
	Endif

Return(dData)

	*****************************************************************************************************************************
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTransfItem บAutor  ณYttalo P. Martins  บ Data ณ  18/11/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que transfere os itens a serem faturados para o arma บฑฑ
ฑฑบ          ณz้m "35" e endere็o "EMPENHO"                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function TransfItem(aTransf,lErro)
	Local	x
	Local	aAuto	:= {}
	Local	aItens	:= {}
	Local	aItem	:= {}
	Local	cDoc	:= ""
	Local	nOpcAuto:= 3

	Private lMsErroAuto := .F.

	Private cXNF  := cNF
	Private cXSer := cSerie
	Private cXObs := 'Transferencia automatica, retorno de cirurgia...'

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Pega a variavel que identifica se o calculo do custo e' :    ณ
	//ณ               O = On-Line                                    ณ
	//ณ               M = Mensal                                     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	PRIVATE cCusMed  := GetMv("MV_CUSMED")
	PRIVATE cCadastro:= OemToAnsi("Transfer๊ncias")	//"Transfer๊ncias"
	PRIVATE aRegSD3  := {}
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se o custo medio e' calculado On-Line               ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If cCusMed == "O"
		PRIVATE nHdlPrv // Endereco do arquivo de contra prova dos lanctos cont.
		PRIVATE lCriaHeader := .T. // Para criar o header do arquivo Contra Prova
		PRIVATE cLoteEst 	// Numero do lote para lancamentos do estoque
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณ Posiciona numero do Lote para Lancamentos do Faturamento     ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		dbSelectArea("SX5")
		dbSeek(xFilial()+"09EST")
		cLoteEst:=IIF(Found(),Trim(X5Descri()),"EST ")
		PRIVATE nTotal := 0 	// Total dos lancamentos contabeis
		PRIVATE cArquivo	// Nome do arquivo contra prova
	EndIf

	dbSelectArea("SB2")
	dbSetOrder(2)
	If !dbSeek(xFilial("SB2") + "35" + ALLTRIM(aTransf[1][1]) )

		CriaSB2(ALLTRIM(aTransf[1][1]),"35")

	EndIf

	DBSELECTAREA("SD3")
	SD3->(DBSETORDER(1))

	cDoc := GetSxENum("SD3","D3_DOC")//GetSxENum("SD3","D3_DOC",1)
	aAdd(aAuto,{cDoc,dDataBase}) //Cabecalho

	For x := 1 To Len(aTransf)

		aLinha	:= {}

		DBSELECTAREA("SB1")
		SB1->(DBSETORDER(1))
		SB1->(DbSeek(xFilial("SB1")+aTransf[x][1]))
		cXDescr := SB1->B1_DESC
		cXUM	:= SB1->B1_UM

		//PRODUTO ORIGEM
		aAdd(aLinha,{"D3_COD"        , aTransf[x][1]	,NIL})// 01.Produto Origem
		aAdd(aLinha,{"D3_DESCRI"     , cXDescr			,NIL})// 02.Descricao
		aAdd(aLinha,{"D3_UM"         , cXUM				,NIL})// 03.Unidade de Medida
		aAdd(aLinha,{"D3_LOCAL"      , aTransf[x][2]	,NIL})// 04.Armazem Origem
		aAdd(aLinha,{"D3_LOCALIZ"    , ""				,NIL})// 05.Endereco Origem

		//PRODUTO DESTINO
		aAdd(aLinha,{"D3_COD"        , aTransf[x][1] 	,NIL})// 06.Produto Destino
		aAdd(aLinha,{"D3_DESCRI"     , cXDescr			,NIL})// 07.Descricao
		aAdd(aLinha,{"D3_UM"         , cXUM				,NIL})// 08.Unidade de Medida
		aAdd(aLinha,{"D3_LOCAL"      , aTransf[x][10]	,NIL})// 09.Armazem Destino
		aAdd(aLinha,{"D3_LOCALIZ"    , ""            	,NIL})// 10.Endereco Destino

		aAdd(aLinha,{"D3_NUMSERI"    , ""            	,NIL})// 11.Numero de Serie origem
		aAdd(aLinha,{"D3_LOTECTL"    , aTransf[x][13]	,NIL})// 12.Lote origem
		aAdd(aLinha,{"D3_NUMLOTE"    , ""            	,NIL})// 13.Sub-Lote origem
		aAdd(aLinha,{"D3_DTVALID"    , aTransf[x][7]	,NIL})// 14.Data de Validade origem
		aAdd(aLinha,{"D3_POTENCI"    , 0             	,NIL})// 15.Potencia do Lote origem
		aAdd(aLinha,{"D3_QUANT"      , aTransf[x][3] 	,NIL})// 16.Quantidade
		aAdd(aLinha,{"D3_QTSEGUM"    , 0             	,NIL})// 17.Quantidade na 2 UM
		aAdd(aLinha,{"D3_ESTORNO"    , ""            	,NIL})// 18.Estorno
		aAdd(aLinha,{"D3_NUMSEQ"     , ""            	,NIL})// 19.NumSeq

		aAdd(aLinha,{"D3_LOTECTL"    , aTransf[x][13]	,NIL})// 20.Lote Destino
		aAdd(aLinha,{"D3_NUMLOTE"    , ""            	,NIL})// 21.Sub-Lote origem Destino
		aAdd(aLinha,{"D3_DTVALID"    , aTransf[x][7]	,NIL})// 22.Data de Validade Destino
		aAdd(aLinha,{"D3_ITEMGRD"    , ""            	,NIL})// 23.Item Grade

		aadd(aLinha,{"D3_CODLAN"	 , ""				,NIL}) //24.cat83 prod origem
		aadd(aLinha,{"D3_CODLAN"	 , ""				,NIL}) //25.cat83 prod destino

		aadd(aLinha,{"D3_IDDCF"		 , ""				,NIL}) //26.Iddcf
		aadd(aLinha,{"D3_OBSERVA"	 , ""				,NIL}) //27.Observa

		//Campos customizados estใo sendo tratados pelo PE MA261D3...
		//Alterado por JOSE DE ASSUNCAO - TOTVS RJ

		//aAdd(aLinha,{"D3_XDOCRET"    , cNF 			,NIL})// 28.Doc de Retorno
		//aAdd(aLinha,{"D3_XSERRET"    , cSerie			,NIL})// 29.Serie Doc de Retorno

		aadd(aAuto,aLinha)

	Next

	MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

	If lMsErroAuto

		ConOut(Repl("-", 80))
		conout("{"+Alltrim(cUserName)+"} - Transferencia nใo realizada [Retorno "+Alltrim(cNF)+"/"+Alltrim(cSerie)+"]!")
		ConOut(Repl("-", 80))

		MOSTRAERRO()
		cPath := "C:\LogSiga\"
		cFile := StrTran(Dtoc(dDataBase),"/","")+"_"+StrTran(Time(),":","")+"_"+AllTrim(aTransf[1][4])+".log"
		MostraErro(cPath,cFile)
		MsgAlert("Item(s) nใo transferido(s)! Doc: "+AllTrim(aTransf[1][4])+chr(13)+chr(10)+;
			"Verifique o LOG (" + cFile + ") na pasta C:\LogSiga do sistema.", "Atencao !")

		lErro     := .T.

	Else

		ConOut(Repl("-", 80))
		conout("{"+Alltrim(cUserName)+"} - Transferencia efetuada com sucesso [Retorno "+Alltrim(cNF)+"/"+Alltrim(cSerie)+"]!")
		ConOut(Repl("-", 80))

		Aviso( "Aten็ใo", cUserName+ ", a transfer๊ncia foi realizada com sucesso!", {"Ok"} )

		nMeter4 := 100
		oMeter4:Set(nMeter4)
		oSay6:lVisibleControl := .T.
		oDlg:CommitControls()
		oDlg:Refresh()

	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGetPoder3 บAutor  ณRafael Fernandes    บ Data ณ  07/11/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Realiza a modifica็ใo de dados no cabe็alho de pedido para บฑฑ
ฑฑบ          ณ retornos com poder de terceiro                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GetPoder3()

	Local oButOK
	local oGroup1
	local oGroup2
	local oGroup3
	local oGroup4
	local oGroup5
	local oGroup6
	local oGroup7
	local oGroup8
	local oSay1

	Private oGetRet1
	Private cGetRet1 	:= Criavar("C5_CLIENT")
	Private oGetRet2
	Private cGetRet2 	:= Criavar("C5_LOJACLI")
	Private oGetRet3
	Private cGetRet3 	:= Criavar("A1_NOME")
	Private oGetRet4
	Private cGetRet4 	:= Criavar("C5_XHOSPIT")
	Private oGetRet5
	Private cGetRet5 	:= Criavar("C5_XNOMHOS")
	Private oGetRet6
	Private cGetRet6 	:= Criavar("C5_XCONVEN")
	Private oGetRet7
	Private cGetRet7 	:= Criavar("C5_XNOMCON")
	Private oGetRet8
	Private cGetRet8 	:= Criavar("C5_XMEDICO")
	Private oGetRet9
	Private cGetRet9 	:= Criavar("C5_XNOMMED")
	Private oGetRet10
	Private cGetRet10	:= Criavar("C5_XPROCED")
	Private oGetRet11
	Private cGetRet11 	:= Criavar("C5_XDESPRO")
	Private oGetRet12
	Private cGetRet12 	:= Criavar("C5_XNOMPAC")
	Private oDlgP3

	While .T.
		lOpc := .F.

		cGetRet1 	:= Criavar("C5_CLIENT")
		cGetRet2 	:= Criavar("C5_LOJACLI")
		cGetRet3 	:= Criavar("A1_NOME")
		cGetRet4 	:= Criavar("C5_XHOSPIT")
		cGetRet5 	:= Criavar("C5_XNOMHOS")
		cGetRet6 	:= Criavar("C5_XCONVEN")
		cGetRet7 	:= Criavar("C5_XNOMCON")
		cGetRet8 	:= Criavar("C5_XMEDICO")
		cGetRet9 	:= Criavar("C5_XNOMMED")
		cGetRet10	:= Criavar("C5_XPROCED")
		cGetRet11 	:= Criavar("C5_XDESPRO")
		cGetRet12 	:= Criavar("C5_XNOMPAC")
		cNumOrcam   :=  ''

		//============================================================//
		// Adicionado Rafael Fernandes 09/10/2015
		cQuery := ""
		cQuery += " WHERE SCJ.D_E_L_E_T_ =  ''  "+CRLF
		cQuery += " AND CJ_EMISSAO >= '"+SuperGetMV("MV_XDTCORT",.F.,'20150801')+"'  "+CRLF
		cQuery += " AND CJ_STATUS = 'A' "+CRLF

		//Independente de ser com vํnculo ou s/ vํnculo os produtos marcados devem ser transferidos

		aButtons:={}
		aAdd(aButtons,{"DESTINOS"  , {|| U_RetP3Vinc() ,.T.},"Vincular"})
		aAdd(aButtons,{"DESTINOS"  , {|| .T.},"S/ Vinculo"})

		_aFields := {"CJ_NUM","CJ_XNOMPAC","CJ_XNOMPRO","CJ_XDTCIRU","CJ_XHORCIR","CJ_XNOMMED","CJ_XNOMCON","CJ_XNOMHOS" }
		MsAguarde({||U_WMEA040('SCJ',cQuery,_aFields,aButtons,.T.)},'Buscando Or็amentos. Aguarde...')
		//============================================================//

		DEFINE MSDIALOG oDlgP3 TITLE "Poder de terceiros" FROM 000, 000  TO 410, 600 PIXEL

		@ 002, 003 GROUP oGroup1 TO 175, 297 PROMPT ".: Retorno de Poder de Terceiros :." OF oDlgP3 PIXEL

		@ 010, 010 SAY oSay1 PROMPT "Informe abaixo os dados a serem considerados no retorno:" SIZE 278, 007 OF oDlgP3 COLORS 255, 16777215 PIXEL

		@ 020, 005 GROUP oGroup2 TO 042, 289 PROMPT " Cliente " OF oGroup1 PIXEL
		@ 028, 010 MSGET oGetRet1 VAR cGetRet1 F3 'SA1' SIZE 040, 010 OF oGroup2 PIXEL
		@ 028, 051 MSGET oGetRet2 VAR cGetRet2 VALID(cGetRet3 := GetAdvFVal('SA1','A1_NOME',xFilial('SA1')+cGetRet1+cGetRet2,1,'')) SIZE 020, 010 OF oGroup3 PIXEL
		@ 028, 071 MSGET oGetRet3 VAR cGetRet3 SIZE 212, 010 OF oGroup3 PIXEL

		@ 045, 005 GROUP oGroup3 TO 067, 289 PROMPT " Hopital " OF oGroup1 PIXEL
		@ 053, 010 MSGET oGetRet4 VAR cGetRet4 F3 'ZZ6' SIZE 060, 010 OF oGroup3 PIXEL
		@ 053, 071 MSGET oGetRet5 VAR cGetRet5 SIZE 212, 010 OF oGroup2 PIXEL

		@ 070, 005 GROUP oGroup4 TO 092, 289 PROMPT " Conv๊nio " OF oGroup1 PIXEL
		@ 078, 010 MSGET oGetRet6 VAR cGetRet6 F3 'ZZ7' SIZE 060, 010 OF oGroup4 PIXEL
		@ 078, 071 MSGET oGetRet7 VAR cGetRet7 SIZE 212, 010 OF oGroup4 PIXEL

		@ 095, 005 GROUP oGroup5 TO 117, 289 PROMPT " M้dico " OF oGroup1 PIXEL
		@ 103, 010 MSGET oGetRet8 VAR cGetRet8 F3 'ZZ9' SIZE 060, 010 OF oGroup5 PIXEL
		@ 103, 071 MSGET oGetRet9 VAR cGetRet9 SIZE 212, 010 OF oGroup5 PIXEL

		@ 120, 005 GROUP oGroup6 TO 142, 289 PROMPT " Procedimento " OF oGroup1 PIXEL
		@ 128, 010 MSGET oGetRet10 VAR cGetRet10 VALID(cGetRet11 := GetAdvFVal('SZD','ZD_DESC',xFilial('SZD')+cGetRet10,1,'')) F3 'SZD' SIZE 060, 010 OF oGroup6 PIXEL
		@ 128, 071 MSGET oGetRet11 VAR cGetRet11 SIZE 212, 010 OF oGroup6 PIXEL

		@ 145, 005 GROUP oGroup7 TO 167, 289 PROMPT " Paciente " OF oGroup1 PIXEL
		@ 153, 010 MSGET oGetRet12 VAR cGetRet12 SIZE 273, 010 OF oGroup7 PIXEL

		@ 178, 003 GROUP oGroup8 TO 201, 297 OF oDlgP3 PIXEL

		@ 183, 253 BUTTON oButOK PROMPT "Confirmar" ACTION(lOpc := (fValidP3() .AND. AlertBlq()), IIF(lOpc, oDlgP3:end(),nil) ) SIZE 037, 012 OF oDlgP3 PIXEL

		ACTIVATE MSDIALOG oDlgP3

		If lOpc
			Exit
		Else
			Alert('O preenchimento dos dados ้ obrigat๓rio!')
		EndIf
	EndDo

	nPosCli 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_CLIENTE" } )
	nPosLjCli 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_LOJACLI" } )
	nPosCliEn 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_CLIENT"  } )
	nPosLjCEn 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_LOJAENT" } )
	nPosHos 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XHOSPIT" } )
	nPosNomHos 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XNOMHOS" } )
	nPosCon 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XCONVEN" } )
	nPosNomCon 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XNOMCON" } )
	nPosMed	 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XMEDICO" } )
	nPosNomMed 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XNOMMED" } )
	nPosPro 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XPROCED" } )
	nPosNomPro 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XDESPRO" } )
	nPosNomPac 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XNOMPAC" } )
	nPosOrcam 	:= aScan( aCabPV , {|x|Alltrim(x[1]) == "C5_XORCAM"  } )

	aCabPV[nPosCli][2] 		:= cGetRet1
	aCabPV[nPosLjCli][2] 	:= cGetRet2
	aCabPV[nPosCliEn][2]	:= cGetRet1
	aCabPV[nPosLjCEn][2] 	:= cGetRet2
	aCabPV[nPosHos][2] 		:= cGetRet4
	aCabPV[nPosNomHos][2] 	:= cGetRet5
	aCabPV[nPosCon][2] 		:= cGetRet6
	aCabPV[nPosNomCon][2] 	:= cGetRet7
	aCabPV[nPosMed][2] 		:= cGetRet8
	aCabPV[nPosNomMed][2] 	:= cGetRet9
	aCabPV[nPosPro][2] 		:= cGetRet10
	aCabPV[nPosNomPro][2] 	:= cGetRet11
	aCabPV[nPosNomPac][2] 	:= cGetRet12
	aCabPV[nPosOrcam][2]	:= cNumOrcam

	cNewCli   := cGetRet1
	cNewLjCli := cGetRet2

Return

User Function RetP3Vinc

	dbSelectArea('SCJ')
	dbSetOrder(1)
	If dbSeek(xFilial("SCJ")+oNewGD1:ACOLS[oNewGD1:NAT][aScan(oNewGD1:AHEADER,{|X| Alltrim(X[2]) == 'CJ_NUM' })])

		cGetRet1 	:= SCJ->CJ_CLIENTE
		cGetRet2 	:= SCJ->CJ_LOJA
		cGetRet3 	:= SCJ->CJ_NOMCLI
		cGetRet4 	:= SCJ->CJ_XHOSPIT
		cGetRet5 	:= SCJ->CJ_XNOMHOS
		cGetRet6 	:= SCJ->CJ_XCONVEN
		cGetRet7 	:= SCJ->CJ_XNOMCON
		cGetRet8 	:= SCJ->CJ_XMEDICO
		cGetRet9 	:= SCJ->CJ_XNOMMED
		cGetRet10	:= SCJ->CJ_XPROCED
		cGetRet11 	:= SCJ->CJ_XNOMPRO
		cGetRet12 	:= SCJ->CJ_XNOMPAC

		cNumOrcam 	:= SCJ->CJ_NUM

	EndIf

Return

Static Function fValidP3
	Local lRet := .T.
	Local v
	For v:=1 to 12
		cVldGet := '!Empty(cGetRet'+cValtoChar(v)+')'
		lRet := &cVldGet

		If !lRet
			Alert('Serแ necessแrio informar todos os dados antes de continuar')
			Exit
		EndIf
	Next

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณAlertBlq  บAutor  ณJOSE DE ASSUNCAO    บ Data ณ  22/10/15   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Mostra alerta antes de continuar sobre cadastro bloqueado  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function AlertBlq()

	Local cCadBlq := ""
	Local lRet := .T.

	RestArea(aAreaSA1)
	RestArea(aAreaSA3)

	dbSelectArea("ZZ9")
	IF !DbSeek(xFilial("ZZ9")+SC5->C5_XMEDICO)
		cCadBlq += CRLF+"Cadastro do(a) M้dico(a) Cod '"+SC5->C5_XMEDICO+" nใo foi localizado!"+CRLF
		lRet := .F.
	Endif

	dbSelectArea("ZZ7")
	IF !DbSeek(xFilial("ZZ7")+SC5->C5_XCONVEN)
		cCadBlq += CRLF+"Cadastro do Conv๊nio Cod '"+SC5->C5_XCONVEN+" nใo foi localizado!"+CRLF
		lRet := .F.
	Endif

	dbSelectArea("ZZ6")
	IF !DbSeek(xFilial("ZZ6")+SC5->C5_XHOSPIT)
		cCadBlq += CRLF+"Cadastro do Hospital Cod '"+SC5->C5_XHOSPIT+" nใo foi localizado!"+CRLF
		lRet := .F.
	Endif

	dbSelectArea("SA1")
	dbSetOrder(1)
	DbSeek(xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI)
	IF SA1->A1_MSBLQL == "1"//bloqueado

		cCadBlq += CRLF+"Cadastro do Cliente Cod '"+SC5->C5_CLIENTE+"/"+SC5->C5_LOJACLI+"'("+Alltrim(SA1->A1_NREDUZ)+") estแ Bloqueado!"+CRLF
		lRet := .F.

	Endif

	dbSelectArea("SA3")
	dbSetOrder(1)
	DbSeek(xFilial("SA3")+SC5->C5_VEND1)
	IF SA3->A3_MSBLQL == "1"//bloqueado

		cCadBlq += CRLF+"Cadastro do(a) Vendedor(a) Cod '"+SC5->C5_VEND1+"'("+Alltrim(SA3->A3_NOME)+") estแ Bloqueado!"+CRLF
		lRet := .F.

	Endif

	dbSelectArea("SA3")
	dbSetOrder(1)
	DbSeek(xFilial("SA3")+SC5->C5_VEND4)
	IF SA3->A3_MSBLQL == "1"//bloqueado

		cCadBlq += CRLF+"Cadastro do(a) Instrumentador(a) Cod '"+SC5->C5_VEND4+"'("+Alltrim(SA3->A3_NOME)+") estแ Bloqueado!"+CRLF
		lRet := .F.

	Endif

	If !Empty(cCadBlq)

		cCadBlq += CRLF+"O PV nใo serแ gerado por este motivo, acompanhe pelo log a seguir..."

		MsgInfo(cUserName+","+CRLF+cCadBlq,"Aten็ใo")

	Endif

Return(lRet)
