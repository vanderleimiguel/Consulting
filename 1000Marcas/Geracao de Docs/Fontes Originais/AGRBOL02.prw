#Include "Protheus.Ch"
#Include "RwMake.Ch"
#Include "Totvs.Ch"
#Include "RPTDEF.CH"
#Include "FWPrintSetup.ch"
/*/{Protheus.doc} AGRBOL01
Impressao de Boleto Laser - Padrão
@author Rodrigo Guerra
@since 07/03/2024
/*/
/******************************************************************************************************************/
User Function AGRBOL02(cCodBco)
/******************************************************************************************************************/
	Local lRet := .F.
	Private cLogoBanco := ""					        // Logo do Banco
	// Private cLogoItabom:= "LOGOITABOM.BMP"		// Logo da Empresa

	lRet := RunProc(cCodBco)

Return lRet

/******************************************************************************************************************/
Static Function RunProc(cCodBco)
/******************************************************************************************************************/
	Local CB_LD_NN	:= {}
	Local aBolText	:= {}
	Local cVen

	Local i
	Local _nVlrAbat := 0
	Local nPBonif   := 0
	// Local   nVlrBonif := 0
	Local   nTarifa   := 0
	Private aDadosEmp := {SM0->M0_NOMECOM                                    							 ,; 	//Nome da Empresa
	SM0->M0_ENDCOB																                                         ,; 	//Endereco
	AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB	             ,; 	//Complemento
	"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)				                   ,; 	//CEP
	"PABX/FAX: "+SM0->M0_TEL													                                     ,; 	//Telefones
	"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+Subs(SM0->M0_CGC,13,2) ,; 	//CGC
	"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3) }								          //I.E


	aDadoBco  := {SEE->EE_CODIGO +IIF(Empty(SEE->EE_X_DVBNC),"","-"+SEE->EE_X_DVBNC),; //+ iif(!Empty((cAliasSEE)->DVAGE), ("-"+(cAliasSEE)->EE_DVAGE), ''),;
								cBenefic            							,;
								AllTrim(SEE->EE_AGENCIA)          ,;
								AllTrim(SEE->EE_CONTA)	          ,;
								SEE->EE_DVCTA			                ,;
								AllTrim(SEE->EE_CODCART)          ,;
								SEE->EE_DVAGE}

	IncProc()

	nPBonif   := 0
	nVlrBonif := 0

	SA1->(dbSetOrder(1))
	If SA1->(dbSeek(xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA))
		If SA1->A1_X_IMPBN == 'S'
			nPBonif   := SA1->A1_X_PBON
			nVlrBonif := IIF(nPBonif>0, round(SE1->E1_SALDO*(nPBonif/100),2),0)//IIF( nPBonif > 0, (SE1->E1_VALOR-_nVlrAbat)*(nPBonif/100), 0 )
		elseif SA1->A1_X_IMPBN == 'N'
			_nVlrAbat    :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)
		ENDIF
	EndIf

	//-- Dados do Pagador
	aDatSacado   := {AllTrim(SA1->A1_NOME),AllTrim(SA1->A1_COD),A1ItaEnd("END")+"-"+A1ItaEnd("BAIRRO"),A1ItaEnd("MUN"),A1ItaEnd("EST"),A1ItaEnd("CEP"),A1ItaEnd("CNPJ")}


	//-- Tarifa
	nTarifa := 0
	If SA1->A1_X_TARIF == "S"
		nTarifa := Posicione( "SA6", 1, xFilial("SA6") + Substr(cCHV555,1,15), "A6_X_TARIF" )
	EndIf

	aBolText := {Iif(!Empty(SEE->EE_FORMEN1), Alltrim(SEE->EE_FORMEN1),''),;
							 Iif(!Empty(SEE->EE_FORMEN2), Alltrim(SEE->EE_FORMEN2),''),;
							 Iif(!Empty(SEE->EE_FOREXT1), Alltrim(SEE->EE_FOREXT1),''),;
							 Iif(!Empty(SEE->EE_FOREXT2), Alltrim(SEE->EE_FOREXT2),'')}

	//-- Retorna cod barras, linha digitada, e nosso numero
	CB_LD_NN     := Ret_cBarra(	Subs(aDadoBco[1],1,3)               ,;//+'9'+Right(aDadoBco[1],1)	,;
															aDadoBco[3]										,;
															aDadoBco[4]										,;
															aDadoBco[5]										,;
															aDadoBco[6]										,;
															AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA)	,;
															(SE1->E1_SALDO-_nVlrAbat) )

	//-- Dados do Titulo
	aDadosTit    := {SE1->E1_PREFIXO+AllTrim(SE1->E1_NUM)+AllTrim(SE1->E1_PARCELA),;
									SE1->E1_EMISSAO,;
									dDatabase,;
									SE1->E1_VENCTO,;
									(SE1->E1_SALDO - _nVlrAbat),;
									nVlrBonif,;
									nTarifa,;
									IIf(aDadoBco[1] == "341", E1_TIPO , "DM")}
	if lPosFat
		Impress(oPrint,cLogoBanco,aDadosEmp,aDadosTit,aDadoBco,aDatSacado,aBolText,CB_LD_NN,_nVlrAbat)
	else
		For I:=1 To MV_PAR13 // Numero de Copias
			Impress(oPrint,cLogoBanco,aDadosEmp,aDadosTit,aDadoBco,aDatSacado,aBolText,CB_LD_NN,_nVlrAbat)
		Next
	EndIf
	
	//Grava na SE1
	If Empty(SE1->E1_NUMBCO)
		SE1->(RecLock("SE1",.F.))
			SE1->E1_NUMBCO  := cNosso + Mod11Bco(AllTrim(SEE->EE_CODCART)+cNosso)
			SE1->E1_X_BCOBL := SubStr(cChvBcoCC,1,3)

		If Empty(SE1->E1_X_NNBOL)
			SE1->E1_X_NNBOL :=  SE1->E1_NUMBCO
			SE1->E1_X_BCO	  :=  SEE->EE_CODIGO
			SE1->E1_X_AG 	  :=  SEE->EE_AGENCIA
			SE1->E1_X_CONTA :=  SEE->EE_CONTA
		Endif

		SE1->(MsUnlock())
		cNossoPad := StrZero(Val(cNossoPad)+1,11)

		If SEE->(dbSeek(XFILIAL()+cChvBcoCC))
			SEE->(Reclock("SEE",.f.))
				SEE->EE_FAXATU := cNossoPad
			SEE->(MsUnlock())
		Endif
	Endif

Return .T.

/******************************************************************************************************************/
Static Function Impress(oPrint,cLogoBanco,aDadosEmp,aDadosTit,aDadoBco,aDatSacado,aBolText,CB_LD_NN,_nVlrAbat)
/******************************************************************************************************************/
	Local n_Lin       := 0
	Local n_Col       := 0
	Local n_hLin      := 0
	Local n_LinSav    := 0
	Local n_SavLin2   := 0
	Local n_VLin      := 0
	Local n_VCol      := 0

	Local PixelX	  := nil
	Local PixelY	  := nil

	Local oFont10N
	Local oFont07N
	Local oFont07
	Local oFont08
	Local oFont08N
	Local oFont09N
	Local oFont09
	Local oFont10
	Local oFont11
	Local oFont12
	Local oFont11N
	Local oFont18N
	Local OFONT12N

	Local  VBOX    :=  080
	Local  HMARGEM :=  080
	Local  VMARGEM :=  030

	Local cBanco   := SubStr(aDadoBco[1],1,3)
	Local cCdBnc   := aDadoBco[1]
	Local cLinDig  := CB_LD_NN[2]
	Local cAgencia := aDadoBco[3]
	Local cConven  := "22222222"
	Local cConta   := aDadoBco[4]
	Local cNumBco  := RetNN_Bco()
	Local cNumTit  := aDadosTit[1] //"002 123456789 001"
	Local nValBol  := aDadosTit[5]
	Local nDescre  := 0
	Local cNomeCli := aDatSacado[1]
	Local cEndCli  := aDatSacado[3]
	Local cCep     := aDatSacado[5]
	Local cMunic   := aDatSacado[4]
	Local cUF      := aDatSacado[5]
	Local cNomEmp  := aDadosEmp[1]
	Local cMsgBol  := "Pague preferencialmente no "+ AllTrim(aDadoBco[2])
	Local cEspecDoc:= aDadosTit[8]
	Local cAceite  := "S"
	Local dDtaEmis := Date()
	Local dDtaVenc := aDadosTit[4]
	Local cUsoBco  := ""
	Local cCodCart := aDadoBco[6]
	Local cInstru1 := aBolText[1]//"Cobrar Juros de R$ "+Transf(SE1->E1_PORCJUR/100*SE1->E1_SALDO,"@e 99,999.99")+" ao dia"//"Instrução 1"
	Local cInstru2 := aBolText[2]//"Após o vencimento cobrar 2.00% de multa."//"Instrução 2"
	Local cInstru3 := aBolText[3]//"Desconto concedido e aplicado no valor de R$ " + Transform(aDadosTit[6] > 0,"@E 999,999.99")//"Instrução 3"
	Local cInstru4 := aBolText[4]//"Valor já liquido, valor bruto de R$ "+ Transform(aDadosTit[5] +_nVlrAbat,"@E 999,999.99") +" concedido o desconto de R$ " + Transform(_nVlrAbat,"@E 99,999.99")//"Instrução 4"
	Local cCodBar  := CB_LD_NN[1]
	Local cLogoBco := cLogoItabom

	PixelX  := oPrint:nLogPixelX()
	PixelY  := oPrint:nLogPixelY()

	//--------------------------------------------------------------------------+
	// Processa o desenho                                                       |
	//--------------------------------------------------------------------------+
	oFont10N   := TFont():New("Times New Roman", ,-08,.T.,.F.)// 1
	oFont07N   := TFont():New("Times New Roman", ,-06,.T.,.F.)// 2
	oFont07    := TFont():New("Times New Roman", ,-06,.F.,.F.)// 3
	oFont08    := TFont():New("Times New Roman", ,-07,.F.,.F.)// 4
	oFont08N   := TFont():New("Times New Roman", ,-06,.T.,.F.)// 5
	oFont09N   := TFont():New("Times New Roman", ,-08,.T.,.F.)// 6
	oFont09    := TFont():New("Times New Roman", ,-08,.F.,.F.)// 7
	oFont10    := TFont():New("Times New Roman", ,-09,.F.,.F.)// 8
	oFont11    := TFont():New("Times New Roman", ,-10,.F.,.F.)// 9
	oFont12    := TFont():New("Times New Roman", ,-11,.F.,.F.)// 10
	oFont12N   := TFont():New("Times New Roman", ,-11,.T.,.F.)// 10
	oFont14N   := TFont():New("Times New Roman", ,-12,.T.,.T.)// 10
	oFont11N   := TFont():New("Times New Roman", ,-10,.T.,.F.)// 11
	oFont18N   := TFont():New("Times New Roman", ,-17,.T.,.T.)// 12
	oFONT12N   := TFont():New("Times New Roman", ,-11,.T.,.F.)// 12

	//---------------------------------------------------------------------------+
	// Inicializacao da pagina do objeto grafico                                 |
	///--------------------------------------------------------------------------+
	oPrint:StartPage()

	//+----------------------------+
	//     Linha da Margem
	//+----------------------------+
	oPrint:Box( 10, 10, 830, 600, "-4")

	nHPage := oPrint:nHorzRes()
	nHPage *= (300/PixelX)
	nHPage -= HMARGEM
	nVPage := oPrint:nVertRes()
	nVPage *= (300/PixelY)
	nVPage -= VBOX

	//---------------------------------------------------------------------------+
	// Desenha o Recibo do Sacado.                                               |
	//---------------------------------------------------------------------------+
	oPrint:Box(HMARGEM,VMARGEM,038,578)
	oPrint:Line(58,VMARGEM, 58, 578, 0, "-4")
	oPrint:Box(HMARGEM,VMARGEM,038,433)
	oPrint:Line(58,VMARGEM, 58, 578, 0, "-4")
	oPrint:Box(HMARGEM,VMARGEM,038,289)
	oPrint:Line(58,VMARGEM, 58, 578, 0, "-4")
	oPrint:Box(HMARGEM,VMARGEM,038,144)
	oPrint:Line(58,VMARGEM, 58, 578, 0, "-4")

	//+----------------+
	//Logo do Banco    |
	//+----------------+
	oPrint:SayBitmap( 011, 030, cLogoItabom, 82, 26)

	// Banco e Linha Digitável
	//oPrint:Say(034,032, cNomeBco+" | "+cBanco+" | ", oFont18N)
	oPrint:Say(030,130, " | "+cCdBnc+" | ", oFont18N)
	oPrint:Say(034,240, Transform(cLinDig, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999"), oFont14N)// --> LINHA DIGITAVEL CB  ( 23790.12301 60000.000038 78000.456703 3 49130000042790 )

	oPrint:Say(034,505, "Recibo do Pagador", oFont12N)

	// Títulos da primeira linha de boxes
	oPrint:Say(044,032, "Vencimento", oFont07)

	// Mudanca no texto do boleto solicitado pelo SAFRA
	IF cBanco $ "033/353/422"
		oPrint:Say(044,146, "Agência/Código do Beneficiario", oFont07)
	ELSE
		oPrint:Say(044,146, "Agência/Código do Cedente", oFont07)
	ENDIF

	oPrint:Say(044,291, "Número do Documento", oFont07)
	oPrint:Say(044,435, "Nosso Número"/*"Nosso Número/Código do Documento"*/, oFont07)

	// Títulos da segunda linha de boxes
	//  Lin Col
	oPrint:Say(064,032, "Valor do Documento", oFont07)
	oPrint:Say(064,146, "(-) Descontos", oFont07)
	oPrint:Say(064,291, "(+) Acréscimos", oFont07)
	oPrint:Say(064,435, "(=) Valor Cobrado", oFont07)

	// Dados da primeira linha de boxes
	oPrint:Say(056,070, DTOC(dDtaVenc), oFont12)

	IF cBanco $ "033/353/422"
		oPrint:Say(056,150, cAgencia +" / "+ cConven, oFont12)
	Else
		oPrint:Say(056,150, cAgencia +" / "+ cConta, oFont12)
	EndIf

	oPrint:Say(056,300, cNumTit , oFont12)
	oPrint:Say(056,450, cNumBco, oFont12)

	// Dados da segunda linha de boxes
	oPrint:Say(076,080, Transform(nValBol, PesqPict("SE1","E1_SALDO")), oFont12)
	If nDescre > 0
		oPrint:Say(076,200, Transform(nDescre, PesqPict("SE1","E1_DECRESC")), oFont12)
	EndIf

	//---------------------------------------------------------------------------+
	// Dados do Pagador (Recibo do Pagador).                                       |
	//---------------------------------------------------------------------------+
	oPrint:Say(086,032, "Pagador", oFont07)

	//oPrint:Say(086,435, "------------------- Autenticação Mecânica -------------------", oFont07)

	oPrint:Say(088         , 080, cNomeCli, oFont12)
	oPrint:Say(088 + 10    , 080, cEndCli, oFont12)
	oPrint:Say(088 + (2*10), 080, "CEP: "+cCep+" "+cMunic+" - "+cUF, oFont12 )

	//---------------------------------------------------------------------------+
	// Dados do Sacador Avalista/cedente. BLOCO 1                                       |
	//---------------------------------------------------------------------------+
	oPrint:Say(128,032, "Sacador/Avalista", oFont07)

	// Inicia Linha
	n_Lin := 130

	oPrint:Say(n_Lin, 080, cNomEmp, oFont12)

	n_Lin += 14

	// Linha Pontilhada
	n_Lin += 16
	oPrint:Say(n_Lin,VMARGEM, Replicate("-",177), oFont12)

	//---------------------------------------------------------------------------+
	// Desenha o Boleto (Ficha de Compensação).                                  |
	//---------------------------------------------------------------------------+

	// Banco e Linha Digitável
	n_Lin += 20

	//+----------------+
	//Logo do Banco    |
	//+----------------+
	// oPrint:SayBitmap(n_Lin-28, 030, cLogoItabom, 90, 40)
	oPrint:Say(n_Lin,130, " | "+cCdBnc+" | ", oFont18N)
	//oPrint:Say(n_Lin,032, cNomeBco+" | "+cBanco+" | ", oFont18N)
	oPrint:Say(n_Lin,315, Transform(cLinDig, "@R 99999.99999 99999.999999 99999.999999 9 99999999999999"), oFont14N)

	// Box Geral
	n_Lin += 5
	oPrint:Box(n_Lin,VMARGEM,n_Lin+240,578)
	n_LinSav := n_Lin

	// Coluna Principal
	n_Col := 415
	oPrint:Line(n_Lin,n_Col, n_Lin+180, n_Col, 0, "-4")

	// Colunas da 3a. Linha da Ficha
	n_VLin := n_Lin + 40
	n_VCol := 280
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,n_VCol+50)

	n_VCol := 230
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,n_VCol+50)

	n_VCol := 100
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,230)

	// Colunas da 4a Linha da Ficha
	n_VLin += 20
	n_VCol := 330
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,n_VCol+85)

	n_VCol := 230
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,330)

	n_VCol := 165
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,230)

	n_VCol := VMARGEM
	oPrint:Box(n_VLin,n_VCol,n_VLin+20,100)

	// Define a altura da linha
	n_hLin := 20

	// Linhas
	oPrint:Line(n_Lin+n_hLin, VMARGEM, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, VMARGEM, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, VMARGEM, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, VMARGEM, n_Lin+n_hLin, 578, 0, "-4")

	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, n_Col, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, n_Col, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, n_Col, n_Lin+n_hLin, 578, 0, "-4")
	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin, n_Col, n_Lin+n_hLin, 578, 0, "-4")

	n_Lin += n_hLin
	oPrint:Line(n_Lin+n_hLin,  VMARGEM, n_Lin+n_hLin, 578, 0, "-4")

	// Titulo Box Sacado/Sacador Avalista
	oPrint:Say(n_Lin+27,VMARGEM+2, "Pagador", oFont07)
	oPrint:Say(n_Lin+70,VMARGEM+2, "Sacador/Avalista", oFont07)

	// Autenticacao
	n_Lin += 60 + n_hLin + 7
	oPrint:Say(n_Lin,435, "Autenticação Mecânica/Ficha de Compensação", oFont07)

	//---------------------------------------------------------------------------+
	// Título dos Quadros da Ficha de Compensacao                                |
	//---------------------------------------------------------------------------+

	// 1a. Linha
	n_Lin := n_LinSav + 6
	n_Col := 032
	oPrint:Say(n_Lin, n_Col, "Local de Pagamento", oFont07)

	n_Col := 418
	oPrint:Say(n_Lin, n_Col, "Vencimento", oFont07)

	// 2a. Linha
	n_Lin += n_hLin
	n_Col := 032

	oPrint:Say(n_Lin, n_Col, "Beneficiario", oFont07)

	n_Col := 418

	oPrint:Say(n_Lin, n_Col, "Agência/Código do Beneficiario", oFont07)

	// 3a. Linha
	n_Lin += n_hLin
	n_Col := 032
	oPrint:Say(n_Lin, n_Col, "Data do Documento", oFont07)

	n_Col := 102
	oPrint:Say(n_Lin, n_Col, "Número do Documento", oFont07)

	n_Col := 232
	oPrint:Say(n_Lin, n_Col, "Espécie Doc.", oFont07)

	n_Col := 282
	oPrint:Say(n_Lin, n_Col, "Aceite", oFont07)

	n_Col := 332
	oPrint:Say(n_Lin, n_Col, "Data do Processamento", oFont07)

	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "Nosso Número", oFont07)

	// 4a. Linha
	n_Lin += n_hLin
	n_Col := 032
	oPrint:Say(n_Lin, n_Col, "Uso do Banco", oFont07)

	n_Col := 102
	oPrint:Say(n_Lin, n_Col, "Carteira", oFont07)

	n_Col := 167
	oPrint:Say(n_Lin, n_Col, "Espécie", oFont07)

	n_Col := 232
	oPrint:Say(n_Lin, n_Col, "Quantidade", oFont07)

	n_Col := 332
	oPrint:Say(n_Lin, n_Col, "(X) Valor", oFont07)

	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(=) Valor do Documento", oFont07)

	oPrint:Say(n_Lin+21,VMARGEM+2, "Instruções - Texto de Responsabilidade do Cedente", oFont07)

	n_SavLin2 := n_Lin

	// 5a. Linha (Coluna Direita)
	n_Lin += n_hLin
	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(-) Descontos / Abatimentos", oFont07)

	// 6a. Linha (Coluna Direita)
	n_Lin += n_hLin
	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(-) Outras Deduções", oFont07)

	// 7a. Linha (Coluna Direita)
	n_Lin += n_hLin
	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(+) Mora Multa", oFont07)

	// 8a. Linha (Coluna Direita)
	n_Lin += n_hLin
	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(+) Outros Acréscimos", oFont07)

	// 9a. Linha (Coluna Direita)
	n_Lin += n_hLin
	n_Col := 417
	oPrint:Say(n_Lin, n_Col, "(=) Valor Cobrado", oFont07)

	//---------------------------------------------------------------------------+
	// Texto/Detalhes da Ficha de Compensacao                                    |
	//---------------------------------------------------------------------------+

	// 1a. Linha
	n_Lin := n_LinSav + (n_hLin-2)
	n_Col := VMARGEM+10
	oPrint:Say(n_Lin, n_Col, cMsgBol, oFont12)
	oPrint:Say(n_Lin,480, DTOC(dDtaVenc), oFont12)

	// 2a. Linha
	n_Lin += n_hLin-2
	oPrint:Say(n_Lin, n_Col, cNomEmp, oFont12)
	oPrint:Say(n_Lin,460, cAgencia +" / "+ cConta , oFont12)

	// 3a. Linha
	n_Lin += n_hLin
	oPrint:Say(n_Lin, n_Col, DTOC(dDtaEmis), oFont12)

	n_Col := 120
	oPrint:Say(n_Lin, n_Col, cNumTit, oFont12)

	n_Col := 240
	oPrint:Say(n_Lin, n_Col, cEspecDoc, oFont12)

	n_Col := 300
	oPrint:Say(n_Lin, n_Col, cAceite, oFont12)

	n_Col := 340
	oPrint:Say(n_Lin, n_Col, DTOC(dDtaEmis), oFont12)

	n_Col := 480
	oPrint:Say(n_Lin, n_Col, cNumBco, oFont12)

	// 4a. Linha
	n_Lin += n_hLin
	n_Col := VMARGEM+10
	oPrint:Say(n_Lin, n_Col, cUsoBco, oFont12)

	n_Col := 120
	oPrint:Say(n_Lin, n_Col, cCodCart, oFont12)

	n_Col := 180
	oPrint:Say(n_Lin, n_Col, "R$", oFont12)

	n_Col := 480
	oPrint:Say(n_Lin, n_Col, Transform(nValBol, PesqPict("SE1","E1_SALDO")), oFont12)

	// 5a. Linha (Coluna à direita)
	n_Lin += n_hLin
	n_Col := 480
	If nDescre > 0
		oPrint:Say(n_Lin, n_Col, Transform(nDescre, PesqPict("SE1","E1_DECRESC")), oFont12)
	EndIf

	//6a. Linha (Coluna à direita)
	// --> Outros acréscimos - nao sera impressa
	n_Lin += n_hLin

	//7a. Linha (Coluna à direita)
	n_Lin += n_hLin
	n_Col := 480

	//8a. Linha (Coluna à direita)
	n_Lin += n_hLin
	n_Col := 480

	//9a. Linha  (Coluna à direita)
	n_Lin += n_hLin
	n_Col := 480

	//---------------------------------------------------------------------------+
	// Texto/Box (Instruções Bancárias).                                         |
	//---------------------------------------------------------------------------+
	n_hLin := 10
	n_Lin  := n_SavLin2 + (4* n_hLin ) - 5
	n_Col  := VMARGEM+10
	oPrint:Say(n_Lin, n_Col, AllTrim(cInstru1), oFont12)

	n_Lin += n_hLin
	oPrint:Say(n_Lin, n_Col, AllTrim(cInstru2), oFont12)

	n_Lin += n_hLin
	oPrint:Say(n_Lin, n_Col, AllTrim(cInstru3), oFont12)

	n_Lin += n_hLin
	oPrint:Say(n_Lin, n_Col, AllTrim(cInstru4), oFont12)

	n_Lin += 10

	//n_Lin += n_hLin
	oPrint:Say(n_Lin+10, n_Col, "PARA REGULARIZAÇÃO DE PROTESTO POR FAVOR ACESSAR O SITE:", oFont12)
	//n_Lin += n_hLin
	oPrint:Say(n_Lin+20, n_Col, "https://protestosp.com.br/, clicar na opção SERVIÇOS ELETRONICOS DE", oFont12)
	//n_Lin += n_hLin
	oPrint:Say(n_Lin+30, n_Col, "PROTESTO, EFETUAR O CADASTRO E PAGAR O BOLETO.", oFont12)

	//---------------------------------------------------------------------------+
	// Dados do Pagador (Ficha de Compensacao). BLOCO 2 ANTES DO CODIGO DE BARRA  |
	//---------------------------------------------------------------------------+
	oPrint:Say(n_Lin += 50         , 080, cNomeCli , oFont12)
	oPrint:Say(n_Lin += 10         , 080, cEndCli , oFont12)
	oPrint:Say(n_Lin += 10         , 080, "CEP: "+cCep+" "+cMunic+" - "+cUF, oFont12 )

	//---------------------------------------------------------------------------+
	// Imprime os dados do Sacador Avalista/cedente.                             |
	//---------------------------------------------------------------------------+
	n_Lin += 21

	oPrint:Say(n_Lin, 080, cNomEmp, oFont12)

	n_Lin += 12

	//---------------------------------------------------------------------------+
	// Código de Barras                                                          |
	//---------------------------------------------------------------------------+
	oPrint:FwMsBar("INT25", 37, 2.5, cCodBar, oPrint, .F., CLR_BLACK,.T.,0.02,0.8,.F.)

	//---------------------------------------------------------------------------+
	// Finalizar a Página.                                                       |
	//---------------------------------------------------------------------------+
	oPrint:EndPage()

Return

/******************************************************************************************************************/
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)
/******************************************************************************************************************/
	Local bldocnufinal := strzero(val(cNroDoc),8)
	Local blvalorfinal := strzero(int(nValor*100),14)
	Local dvnn := 0
	Local dvcb := 0
	Local dv   := 0
	Local NN := ''
	Local RN := ''
	Local CB := ''
	Local s  := ''
	Local cStrTrb, cDigDac, cStr1, cStr2, cStr3, cDig1, cDig2, cDig3
	Local cTipCobr := '2' //Tipo de cobrança : 1-Emissão entidade bancária, 2- Emissão própria

// cAgencia := Right('0000'+AllTrim(cAgencia),4)
	cConta	 := PADL(AllTrim(cConta),7,'0')

	cCmpLivre :=  SubStr(cAgencia,1,4)+cCarteira+Left(cNosso,11)+cConta+'0'

	cCmpDtVlr := PadL(Alltrim(Str(SE1->E1_VENCTO - CTOD('07/10/1997'))), 4, '0') + StrZero(Round(nValor,2) * 100,10)

	CB := Left(cBanco,4)+cCmpDtVlr+cCmpLivre

	cDigDac := AllTrim(Mod11_2(CB))

	CB := Left(CB, 4) + cDigDac + Right(CB, 39)

	cStr1 := Left(cBanco,4)+Left(cCmpLivre,5)
	cStr2 := SubStr(cCmpLivre, 06, 10)
	cStr3 := SubStr(cCmpLivre, 16, 10)

	cDig1 := AllTrim(Mod10Bco(cStr1))
	cDig2 := AllTrim(Mod10Bco(cStr2))
	cDig3 := AllTrim(Mod10Bco(cStr3))

	RN :=  Left(cStr1, 5) + '.' + SubStr(cStr1, 6, 4) + cDig1 + '  '
	RN +=  Left(cStr2, 5) + '.' + SubStr(cStr2, 6, 5) + cDig2 + '  '
	RN +=  Left(cStr3, 5) + '.' + SubStr(cStr3, 6, 5) + cDig3 + '  '
	RN +=  cDigDac + '  ' + cCmpDtVlr

Return({CB,RN,NN})


/******************************************************************************************************************/
Static Function Mod11_2(cLinha)
/******************************************************************************************************************/
	Local cDigRet
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local nFator:= 9
	Local nResult

	For nCont:= Len(cLinha) TO 1 Step -1
		nFator++
		If nFator > 9
			nFator:= 2
		EndIf

		nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
	Next nCont


	nResto:= Mod(nSoma, 11)

	nResult:= 11 - nResto

	If nResult == 0 .Or. nResult == 1 .Or. nResult == 10 .Or. nResult == 11
		cDigRet:= "1"
	Else
		cDigRet:= StrZero(11 - nResto, 1)
	EndIf

Return cDigRet


/******************************************************************************************************************/
Static Function Mod10Bco(cLinha)
/******************************************************************************************************************/
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local cDigRet
	Local nResult
	Local lDobra:= .f.
	Local cValor
	Local nAux

	For nCont:= Len(cLinha) To 1 Step -1
		lDobra:= !lDobra

		If lDobra
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1)) * 2))
		Else
			cValor:= AllTrim(Str(Val(Substr(cLinha, nCont, 1))))
		EndIf

		For nAux:= 1 To Len(cValor)
			nSoma += Val(Substr(cValor, nAux, 1))
		Next n
	Next nCont

	nResto:= MOD(nSoma, 10)

	nResult:= 10 - nResto

	If nResult == 10
		cDigRet:= "0"
	Else
		cDigRet:= StrZero(10 - nResto, 1)
	EndIf

Return cDigRet

/******************************************************************************************************************/
Static Function Mod11Bco(cLinha)
/******************************************************************************************************************/
	Local cDigRet
	Local nSoma:= 0
	Local nResto
	Local nCont
	Local nFator:= 7
	Local nResult

	For nCont:= Len(cLinha) TO 1 Step -1
		nFator++
		If nFator > 7
			nFator:= 2
		EndIf

		nSoma += Val(Substr(cLinha, nCont, 1)) * nFator
	Next nCont

	nResto:= Mod(nSoma, 11)

	If nResto == 1
		cDigRet:= "P"
	ElseIf nResto == 0
		cDigRet:= "0"
	Else
		nResult:= 11 - nResto
		cDigRet:= StrZero(nResult, 1)
	EndIf

Return cDigRet


/******************************************************************************************************************/
Static Function RetNN_Bco()
/******************************************************************************************************************/
	Local cTexto:= ""
	cTexto:= AllTrim(SEE->EE_CODCART) + cNosso
	cRet:= AllTrim(SEE->EE_CODCART) + "/" + cNosso + "-" + Mod11Bco(cTexto)
Return cRet

/******************************************************************************************************************/
Static Function A1ItaEnd( cCampo )
/******************************************************************************************************************/
	Local cDados := ""
	Do Case
	Case cCampo == "END"
		cDados := IIF( !Empty(SA1->A1_ENDCOB), AllTrim(SA1->A1_ENDCOB), AllTrim(SA1->A1_END) )
	Case cCampo == "BAIRRO"
		cDados := IIF( !Empty(SA1->A1_BAIRROC), AllTrim(SA1->A1_BAIRROC), AllTrim(SA1->A1_BAIRRO) )
	Case cCampo == "CEP"
		cDados := IIF( !Empty(SA1->A1_CEPC), AllTrim(SA1->A1_CEPC), AllTrim(SA1->A1_CEP) )
	Case cCampo == "MUN"
		cDados := IIF( !Empty(SA1->A1_MUNC), AllTrim(SA1->A1_MUNC), AllTrim(SA1->A1_MUN) )
	Case cCampo == "EST"
		cDados := IIF( !Empty(SA1->A1_ESTC), AllTrim(SA1->A1_ESTC), AllTrim(SA1->A1_EST) )
	Case cCampo == "CNPJ"
		cDados := IIF( !Empty(SA1->A1_CGC), AllTrim(SA1->A1_CGC), " " )
	EndCase
	
Return cDados
