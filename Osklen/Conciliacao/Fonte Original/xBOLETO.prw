#include "rwmake.ch"
#include "totvs.ch"
/*/{Protheus.doc} xBOLETO
	emissao do boleto
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function xBOLETO(cTmp)
	MsgRun("Gerando boletos ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV := (cTmp)->(getArea())
	local cBkp := CFILANT
	local cCliente as character
	
	private oPrint
	
	(cTmp)->(dbSetOrder(2))
	
	if (cTmp)->(dbSeek("T"))
		while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
			cCliente := (cTmp)->(E1_CLIENTE+E1_LOJA)
			if Empty((cTmp)->E1_CODBAR) .or. Empty((cTmp)->E1_CODDIG) .or. Empty((cTmp)->E1_IDCNAB)
				if ApMsgYesNo("Boleto nao enviado ao banco. Por este motivo algumas informacoes de pagamento podem nao aparecer. Deseja prosseguir?")
					U_xBOLEXEC((cTmp)->XX_RECNO)
				endif
			else
				U_xBOLEXEC((cTmp)->XX_RECNO)
			endif

			(cTmp)->(dbSkip())

			if (cTmp)->( Eof() .or. XX_OK == 'F' .or. cCliente != E1_CLIENTE+E1_LOJA )
				if oPrint != nil
					oPrint:cPathPdf := "C:\Temp\"
					MakeDir(oPrint:cPathPdf)
					oPrint:lServer := .F.
					oPrint:setViewPdf(.T.)
					oPrint:preview()
					FreeObj(oPrint)
				endif
			endif
		end
	endif

	CFILANT := cBkp
	(cTmp)->(restArea(aSv))
return
/*/{Protheus.doc} xBOLEXEC
	emissao do boleto
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function xBOLEXEC(nSe1Recno)
	local cNroDoc		as character
	local cFile			as character
	local cCart			:= "02"
	local nVlrAbat		as numeric
	local aDadosEmp		as array
	local aDadosTit		as array
	local aDadosBanco	as array
	local aDatSacado	as array
	local aCB_RN_NN		as array
	local aBolText		:= {"Após o vencimento cobrar multa de R$ "	,;
							"Mora Diaria de R$ "					,;
							"Sujeito a Protesto apos 05 (cinco) dias do vencimento"}

	SE1->( dbGoto(nSe1Recno) )
	
	ProcRegua(0)

	if oPrint == nil
		cFile := "BOLETO_"+DtoS(DDATABASE)+"_"+StrTran(Time(),":")
		oPrint := FwMsPrinter():new(cFile,6,.T.,"/spool/",.T.,,,,.T.,,,.F.)
	endif

	aDadosEmp    := {SM0->M0_FULNAME                                    						,;	// [01] Nome da Empresa
					SM0->M0_ENDCOB                                     							,;	// [02] Endereço
					AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB	,;	// [03] Complemento
					"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)				,;	// [04] CEP
					"PABX/FAX: "+SM0->M0_TEL													,;	// [05] Telefones
					"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+				;	// [06]
					Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+						;	// [07]
					Subs(SM0->M0_CGC,13,2)														,;	// [08] CGC
					"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+				;	// [09]
					Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)							} 	// [10] I.E

	//Posiciona o SA6 (Bancos)
	DbSelectArea("SA6")
	DbSetOrder(1)
	DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	
	//Posiciona na Arq de Parametros CNAB
	DbSelectArea("SEE")
	DbSetOrder(1)
	DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	
	//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	DbSelectArea("SE1")
	aDadosBanco  := {SA6->A6_COD,;	// [1]Numero do Banco
                    SA6->A6_NOME,;	// [2]Nome do Banco
	                SUBSTR(SA6->A6_AGENCIA, 1, 4),;	// [3]Agência
                    SUBSTR(SA6->A6_NUMCON,1,Len(AllTrim(SA6->A6_NUMCON))-1),;	// [4]Conta Corrente
                    SUBSTR(SA6->A6_NUMCON,Len(AllTrim(SA6->A6_NUMCON)),1),;		// [5]Dígito da conta corrente
                    cCart}	// [6]Codigo da Carteira

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;	// [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            ,;	// [4]Cidade
		SA1->A1_EST                                      ,;	// [5]Estado
		SA1->A1_CEP                                      ,;	// [6]CEP
		SA1->A1_CGC										 ,;	// [7]CGC
		SA1->A1_PESSOA									}	// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)				,;	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA				,;	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                            ,;	// [4]Cidade
		SA1->A1_ESTC	                                    ,;	// [5]Estado
		SA1->A1_CEPC                                        ,;	// [6]CEP
		SA1->A1_CGC											,;	// [7]CGC
		SA1->A1_PESSOA										 }	// [8]PESSOA
	Endif
	
	nVlrAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

	//Aqui defino parte do nosso numero. Sao 8 digitos para identificar o titulo. 
	//Abaixo apenas uma sugestao
	cNroDoc	:= StrZero(	Val(Alltrim(SE1->E1_NUM)+Alltrim(SE1->E1_PARCELA)),9)

	aCB_RN_NN := {	SE1->E1_CODBAR	,; // codigo barras
					SE1->E1_CODDIG	,; // linha digitavel
					SE1->E1_IDCNAB	}  // nosso numero

	aDadosTit	:= {AllTrim(E1_NUM)+AllTrim(E1_PARCELA)	,;  // [1] Número do título
						E1_EMISSAO						,;  // [2] Data da emissão do título
						dDataBase						,;  // [3] Data da emissão do boleto
						E1_VENCTO						,;  // [4] Data do vencimento
						(E1_SALDO - nVlrAbat)			,;  // [5] Valor do título
						aCB_RN_NN[3]					,;  // [6] Nosso número (Ver fórmula para calculo)
						E1_PREFIXO						,;  // [7] Prefixo da NF
						E1_TIPO							}   // [8] Tipo do Titulo
	
	Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASERDO ITAU COM CODIGO DE BARRAS      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN)
	local oFont8
	local oFont11c
	local oFont10
	local oFont14
	local oFont16n
	local oFont15
	local oFont14n
	local oFont24
	local oFont12
	local nI := 0
	local nAux := 15 // variavel auxiliar para facilitar manutencao
	local nRow1
	local nRow2
	local nRow3

	//Parametros de TFont.New()
	//1.Nome da Fonte (Windows)
	//3.Tamanho em Pixels
	//5.Bold (T/F)
	oFont8   := TFont():New("Arial"		 ,9,08,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont10  := TFont():New("Arial"		 ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont12  := TFont():New("Arial"		 ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont14  := TFont():New("Arial"		 ,9,14,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont20  := TFont():New("Arial"		 ,9,20,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont21  := TFont():New("Arial"		 ,9,21,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont16n := TFont():New("Arial"		 ,9,16,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont15  := TFont():New("Arial"		 ,9,15,.T.,.T.,5,.T.,5,.T.,.F.)
	oFont15n := TFont():New("Arial"		 ,9,15,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont14n := TFont():New("Arial"		 ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
	oFont24  := TFont():New("Arial"		 ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)

	oPrint:startPage()   // Inicia uma nova página

	/******************/
	/* PRIMEIRA PARTE */
	/******************/

	nRow1 := 0
	
	oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
	oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

	oPrint:Say  (nRow1+0084+nAux,100,aDadosBanco[2],oFont14 )		// [2]Nome do Banco
	oPrint:Say  (nRow1+0089+nAux,513,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco

	oPrint:Say  (nRow1+0084+nAux,1800,"Comprovante de Entrega",oFont10)
	oPrint:Line (nRow1+0150,100 ,nRow1+0150,2200)

	oPrint:Say  (nRow1+0150+nAux,100 ,"Beneficiário",oFont8)
	oPrint:Say  (nRow1+0200+nAux,100 ,Alltrim(aDadosEmp[1])+" - "+aDadosEmp[6],oFont10)				//Nome + CNPJ

	oPrint:Say  (nRow1+0150+nAux,1060,"Agência/Código Beneficiário",oFont8)
	oPrint:Say  (nRow1+0200+nAux,1060,PadR(Val(aDadosBanco[3]),5,"0")+"/"+Strzero(Val(aDadosBanco[4]),9)+aDadosBanco[5],oFont10)

	oPrint:Say  (nRow1+0150+nAux,1510,"Nro.Documento",oFont8)
	oPrint:Say  (nRow1+0200+nAux,1510,aDadosTit[7]+aDadosTit[1],oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow1+0250+nAux,100 ,"Pagador",oFont8)
	oPrint:Say  (nRow1+0300+nAux,100 ,aDatSacado[1],oFont10)				//Nome

	oPrint:Say  (nRow1+0250+nAux,1060,"Vencimento",oFont8)
	oPrint:Say  (nRow1+0300+nAux,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

	oPrint:Say  (nRow1+0250+nAux,1510,"Valor do Documento",oFont8)
	oPrint:Say  (nRow1+0300+nAux,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

	oPrint:Say  (nRow1+0400+nAux,0100,"Recebi(emos) o bloqueto/título",oFont10)
	oPrint:Say  (nRow1+0450+nAux,0100,"com as características acima.",oFont10)
	oPrint:Say  (nRow1+0350+nAux,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0350+nAux,1410,"Assinatura",oFont8)
	oPrint:Say  (nRow1+0450+nAux,1060,"Data",oFont8)
	oPrint:Say  (nRow1+0450+nAux,1410,"Entregador",oFont8)

	oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
	oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
	oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 )
	oPrint:Line (nRow1+0550, 100,nRow1+0550,2200 )

	oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
	oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
	oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 )
	oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

	oPrint:Say  (nRow1+0165+nAux,1910,"(  )Mudou-se"				,oFont8)
	oPrint:Say  (nRow1+0205+nAux,1910,"(  )Ausente"					,oFont8)
	oPrint:Say  (nRow1+0245+nAux,1910,"(  )Não existe nº indicado"	,oFont8)
	oPrint:Say  (nRow1+0285+nAux,1910,"(  )Recusado"				,oFont8)
	oPrint:Say  (nRow1+0325+nAux,1910,"(  )Não procurado"			,oFont8)
	oPrint:Say  (nRow1+0365+nAux,1910,"(  )Endereço insuficiente"	,oFont8)
	oPrint:Say  (nRow1+0405+nAux,1910,"(  )Desconhecido"			,oFont8)
	oPrint:Say  (nRow1+0445+nAux,1910,"(  )Falecido"				,oFont8)
	oPrint:Say  (nRow1+0485+nAux,1910,"(  )Outros(anotar no verso)"	,oFont8)
			

	/*****************/
	/* SEGUNDA PARTE */
	/*****************/

	nRow2 := 0

	//Pontilhado separador
	For nI := 100 to 2200 step 50
		oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)
	Next nI

	oPrint:Line (nRow2+0710,100,nRow2+0710,2200)
	oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
	oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

	oPrint:Say  (nRow2+0644+nAux,100,aDadosBanco[2],oFont14 )		// [2]Nome do Banco
	oPrint:Say  (nRow2+0649+nAux,513,aDadosBanco[1]+"-7",oFont21 )	// [1]Numero do Banco
	oPrint:Say  (nRow2+0644+nAux,1800,"Recibo do Pagador",oFont10)

	oPrint:Line (nRow2+0810,100,nRow2+0810,2200 )
	oPrint:Line (nRow2+0910,100,nRow2+0910,2200 )
	oPrint:Line (nRow2+0980,100,nRow2+0980,2200 )
	oPrint:Line (nRow2+1050,100,nRow2+1050,2200 )

	oPrint:Line (nRow2+0910,500,nRow2+1050,500)
	oPrint:Line (nRow2+0980,750,nRow2+1050,750)
	oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
	oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
	oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

	oPrint:Say  (nRow2+0710+nAux,100 ,"Local de Pagamento",oFont8)
	// oPrint:Say  (nRow2+0725+nAux,400 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BRADESCO      ",oFont10)
	// oPrint:Say  (nRow2+0765+nAux,400 ,"APÓS O VENCIMENTO, SOMENTE NO BRADESCO      ",oFont10)
	oPrint:Say  (nRow2+0765+nAux,400 ,"Pagável em qualquer Banco do sistema de compensação  ",oFont10)

	oPrint:Say  (nRow2+0710+nAux,1810,"Vencimento"                                     ,oFont8)
	cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0750+nAux,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0810+nAux,100 ,"Beneficiário"                                    ,oFont8)
	oPrint:Say  (nRow2+0850+nAux,100 ,Alltrim(aDadosEmp[1])+" - "+aDadosEmp[6]			,oFont10) //Nome + CNPJ

	oPrint:Say  (nRow2+0810+nAux,1810,"Agência/Código Beneficiário",oFont8)
	cString := PadR(Val(aDadosBanco[3]),5,"0")+"/"+Strzero(Val(aDadosBanco[4]),9)+aDadosBanco[5]
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0850+nAux,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0910+nAux,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow2+0940+nAux,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

	oPrint:Say  (nRow2+0910+nAux,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow2+0940+nAux,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow2+0910+nAux,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (nRow2+0940+nAux,1050,"DM"											,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow2+0910+nAux,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow2+0940+nAux,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow2+0910+nAux,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow2+0940+nAux,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

	oPrint:Say  (nRow2+0910+nAux,1810,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(aDadosTit[6])
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+0940+nAux,nCol,cString,oFont11c)

	oPrint:Say  (nRow2+0980+nAux,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow2+0980+nAux,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow2+1010+nAux,555 ,aDadosBanco[6]                                  	,oFont10)

	oPrint:Say  (nRow2+0980+nAux,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (nRow2+1010+nAux,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (nRow2+0980+nAux,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow2+0980+nAux,1485,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow2+0980+nAux,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow2+1010+nAux,nCol,cString ,oFont11c)

	oPrint:Say  (nRow2+1050+nAux,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)
	if aDadosBanco[1] == "422"
		oPrint:say(nRow2+1150+nAux,100,"Este boleto representa duplicata cedida fiduciariamente ao banco Safra, ficando vedado o pagamento de qualquer outra forma que não através deste boleto",oFont8)
	endif
	// oPrint:Say  (nRow2+1150+nAux,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))       ,oFont10)
	// oPrint:Say  (nRow2+1200+nAux,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
	// oPrint:Say  (nRow2+1250+nAux,100 ,aBolText[3]                                        ,oFont10)

	oPrint:Say  (nRow2+1050+nAux,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow2+1120+nAux,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow2+1190+nAux,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow2+1260+nAux,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow2+1330+nAux,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow2+1400+nAux,100 ,"Pagador"                                        ,oFont8)
	oPrint:Say  (nRow2+1430+nAux,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
	oPrint:Say  (nRow2+1483+nAux,400 ,aDatSacado[3]                                    ,oFont10)
	oPrint:Say  (nRow2+1536+nAux,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow2+1589+nAux,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow2+1589+nAux,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow2+1589+nAux,1850,aDadosTit[6],oFont10)

	oPrint:Say  (nRow2+1605+nAux,100 ,"Beneficiário Final",oFont8)
	oPrint:Say  (nRow2+1645+nAux,1500,"Autenticação Mecânica",oFont8)

	oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 ) 
	oPrint:Line (nRow2+1120,1800,nRow2+1120,2200 )
	oPrint:Line (nRow2+1190,1800,nRow2+1190,2200 )
	oPrint:Line (nRow2+1260,1800,nRow2+1260,2200 )
	oPrint:Line (nRow2+1330,1800,nRow2+1330,2200 )
	oPrint:Line (nRow2+1400,100 ,nRow2+1400,2200 )
	oPrint:Line (nRow2+1640,100 ,nRow2+1640,2200 )


	/******************/
	/* TERCEIRA PARTE */
	/******************/

	nRow3 := -100

	For nI := 100 to 2200 step 50
		oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
	Next nI

	oPrint:Line (nRow3+2000,100,nRow3+2000,2200)
	oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
	oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

	oPrint:Say  (nRow3+1934+nAux,100,aDadosBanco[2],oFont14 )		// 	[2]Nome do Banco
	oPrint:Say  (nRow3+1939+nAux,513,aDadosBanco[1]+"-7",oFont21 )	// 	[1]Numero do Banco
	oPrint:Say  (nRow3+1934+nAux,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

	oPrint:Line (nRow3+2100,100,nRow3+2100,2200 )
	oPrint:Line (nRow3+2200,100,nRow3+2200,2200 )
	oPrint:Line (nRow3+2270,100,nRow3+2270,2200 )
	oPrint:Line (nRow3+2340,100,nRow3+2340,2200 )

	oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
	oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
	oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
	oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
	oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

	oPrint:Say  (nRow3+2000+nAux,100 ,"Local de Pagamento",oFont8)
	// oPrint:Say  (nRow3+2015+nAux,400 ,"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO BRADESCO      ",oFont10)
	// oPrint:Say  (nRow3+2055+nAux,400 ,"APÓS O VENCIMENTO, SOMENTE NO BRADESCO      ",oFont10)
	oPrint:Say  (nRow3+2015+nAux,400 ,"Pagável em qualquer Banco do sistema de compensação  ",oFont10)
			
	oPrint:Say  (nRow3+2000+nAux,1810,"Vencimento",oFont8)
	cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
	nCol	 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2040+nAux,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2100+nAux,100 ,"Beneficiário",oFont8)
	oPrint:Say  (nRow3+2140+nAux,100 ,Alltrim(aDadosEmp[1])+" - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

	oPrint:Say  (nRow3+2100+nAux,1810,"Agência/Código Beneficiário",oFont8)
	cString := PadR(Val(aDadosBanco[3]),5,"0")+"/"+Strzero(Val(aDadosBanco[4]),9)+aDadosBanco[5]
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2140+nAux,nCol,cString ,oFont11c)


	oPrint:Say  (nRow3+2200+nAux,100 ,"Data do Documento"                              ,oFont8)
	oPrint:Say  (nRow3+2230+nAux,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


	oPrint:Say  (nRow3+2200+nAux,505 ,"Nro.Documento"                                  ,oFont8)
	oPrint:Say  (nRow3+2230+nAux,605 ,aDadosTit[7]+aDadosTit[1]						,oFont10) //Prefixo +Numero+Parcela

	oPrint:Say  (nRow3+2200+nAux,1005,"Espécie Doc."                                   ,oFont8)
	oPrint:Say  (nRow3+2230+nAux,1050,"DM"												,oFont10) //Tipo do Titulo

	oPrint:Say  (nRow3+2200+nAux,1305,"Aceite"                                         ,oFont8)
	oPrint:Say  (nRow3+2230+nAux,1400,"N"                                             ,oFont10)

	oPrint:Say  (nRow3+2200+nAux,1485,"Data do Processamento"                          ,oFont8)
	oPrint:Say  (nRow3+2230+nAux,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


	oPrint:Say  (nRow3+2200+nAux,1810,"Nosso Número"                                   ,oFont8)
	cString := Alltrim(aDadosTit[6])
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2230+nAux,nCol,cString,oFont11c)


	oPrint:Say  (nRow3+2270+nAux,100 ,"Uso do Banco"                                   ,oFont8)

	oPrint:Say  (nRow3+2270+nAux,505 ,"Carteira"                                       ,oFont8)
	oPrint:Say  (nRow3+2300+nAux,555 ,aDadosBanco[6]                                  	,oFont10)

	oPrint:Say  (nRow3+2270+nAux,755 ,"Espécie"                                        ,oFont8)
	oPrint:Say  (nRow3+2300+nAux,805 ,"R$"                                             ,oFont10)

	oPrint:Say  (nRow3+2270+nAux,1005,"Quantidade"                                     ,oFont8)
	oPrint:Say  (nRow3+2270+nAux,1485,"Valor"                                          ,oFont8)

	oPrint:Say  (nRow3+2270+nAux,1810,"Valor do Documento"                          	,oFont8)
	cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
	nCol 	 := 1810+(374-(len(cString)*22))
	oPrint:Say  (nRow3+2300+nAux,nCol,cString,oFont11c)

	oPrint:Say  (nRow3+2340+nAux,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)",oFont8)
	if aDadosBanco[1] == "422"
		oPrint:say(nRow3+2440+nAux,100,"Este boleto representa duplicata cedida fiduciariamente ao banco Safra, ficando vedado o pagamento de qualquer outra forma que não através deste boleto",oFont8)
	endif
	// oPrint:Say  (nRow3+2440+nAux,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))      ,oFont10)
	// oPrint:Say  (nRow3+2490+nAux,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
	// oPrint:Say  (nRow3+2540+nAux,100 ,aBolText[3]                                        ,oFont10)
	// oPrint:Say  (nRow3+2590+nAux,100 ,aCB_RN_NN[1]                                       ,oFont10) // CODIBAR

	oPrint:Say  (nRow3+2340+nAux,1810,"(-)Desconto/Abatimento"                         ,oFont8)
	oPrint:Say  (nRow3+2410+nAux,1810,"(-)Outras Deduções"                             ,oFont8)
	oPrint:Say  (nRow3+2480+nAux,1810,"(+)Mora/Multa"                                  ,oFont8)
	oPrint:Say  (nRow3+2550+nAux,1810,"(+)Outros Acréscimos"                           ,oFont8)
	oPrint:Say  (nRow3+2620+nAux,1810,"(=)Valor Cobrado"                               ,oFont8)

	oPrint:Say  (nRow3+2690+nAux,100 ,"Pagador"                                        ,oFont8)
	oPrint:Say  (nRow3+2700+nAux,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

	if aDatSacado[8] = "J"
		oPrint:Say  (nRow3+2700+nAux,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
	Else
		oPrint:Say  (nRow3+2700+nAux,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
	EndIf

	oPrint:Say  (nRow3+2753+nAux,400 ,aDatSacado[3]										,oFont10)
	oPrint:Say  (nRow3+2806+nAux,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
	oPrint:Say  (nRow3+2806+nAux,1750,aDadosTit[6]										,oFont10)

	oPrint:Say  (nRow3+2815+nAux,100 ,"Beneficiário Final"								,oFont8)
	oPrint:Say  (nRow3+2855+nAux,1500,"Autenticação Mecânica - Ficha de Compensação"	,oFont8)

	oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
	oPrint:Line (nRow3+2410,1800,nRow3+2410,2200 )
	oPrint:Line (nRow3+2480,1800,nRow3+2480,2200 )
	oPrint:Line (nRow3+2550,1800,nRow3+2550,2200 )
	oPrint:Line (nRow3+2620,1800,nRow3+2620,2200 )
	oPrint:Line (nRow3+2690,100 ,nRow3+2690,2200 )
	oPrint:Line (nRow3+2850,100 ,nRow3+2850,2200 )

	oPrint:fwMsBar("INT25",66,2.1,aCB_RN_NN[1],oPrint,.F.,nil,nil,0.025,1.0,nil,nil,"A",.F.)

	RecLock("SE1",.F.)
	SE1->E1_NUMBCO := aCB_RN_NN[3] // Nosso número
	SE1->(MsUnlock())

	oPrint:EndPage() // Finaliza a página

return
