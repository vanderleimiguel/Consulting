#INCLUDE "RWMAKE.CH"
#Include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ BolBB    ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO BANCO Bradesco COM CODIGO DE BARRAS    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±± ±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function BolBrad()

LOCAL	aPergs := {} 
PRIVATE lExec    := .F.
PRIVATE cIndexName := ''
PRIVATE cIndexKey  := ''
PRIVATE cFilter    := ''

Tamanho  := "M"
titulo   := "Impressao de Boleto com Codigo de Barras"
cDesc1   := "Este programa destina-se a impressao do Boleto com Codigo de Barras."
cDesc2   := ""
cDesc3   := ""
cString  := "SE1"
wnrel    := "BOLETO"
lEnd     := .F.
aReturn  := {"Zebrado", 1,"Administracao", 2, 2, 1, "",1 }   
nLastKey := 0

if cVersao == 'P11'
	cPerg     :=padr("BLTBAR",10,' ')
else
	cPerg     :="BLTBAR"
endif

dbSelectArea("SE1")
/*
Aadd(aPergs,{"De Prefixo","","","mv_ch1","C",3,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Prefixo","","","mv_ch2","C",3,0,0,"G","","MV_PAR02","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Numero","","","mv_ch3","C",9,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Numero","","","mv_ch4","C",9,0,0,"G","","MV_PAR04","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Parcela","","","mv_ch5","C",1,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Parcela","","","mv_ch6","C",1,0,0,"G","","MV_PAR06","","","","Z","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Portador","","","mv_ch7","C",3,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"Ate Portador","","","mv_ch8","C",3,0,0,"G","","MV_PAR08","","","","ZZZ","","","","","","","","","","","","","","","","","","","","","SA6","","","",""})
Aadd(aPergs,{"De Cliente","","","mv_ch9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"Ate Cliente","","","mv_cha","C",6,0,0,"G","","MV_PAR10","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","SA1","","","",""})
Aadd(aPergs,{"De Loja","","","mv_chb","C",2,0,0,"G","","MV_PAR11","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Loja","","","mv_chc","C",2,0,0,"G","","MV_PAR12","","","","ZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Emissao","","","mv_chd","D",8,0,0,"G","","MV_PAR13","","","","01/01/08","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Emissao","","","mv_che","D",8,0,0,"G","","MV_PAR14","","","","31/12/10","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"De Vencimento","","","mv_chf","D",8,0,0,"G","","MV_PAR15","","","","01/01/08","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Vencimento","","","mv_chg","D",8,0,0,"G","","MV_PAR16","","","","31/12/10","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Do Bordero","","","mv_chh","C",6,0,0,"G","","MV_PAR17","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Ate Bordero","","","mv_chi","C",6,0,0,"G","","MV_PAR18","","","","ZZZZZZ","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aPergs,{"Reimpressao","","","mv_chj","C",1,0,0,"C","","MV_PAR19","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","","","","",""})

AjustaSx1(cPerg,aPergs)
*/

if !Pergunte (cPerg,.T.)
	Set Filter to
	Return
Endif

cIndexName	:= Criatrab(Nil,.F.)
cIndexKey	:= "E1_PORTADO+E1_CLIENTE+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+DTOS(E1_EMISSAO) "
cFilter		+= "E1_FILIAL=='"+xFilial("SE1")+"'.And.E1_SALDO>0.And. "
cFilter		+= "E1_PREFIXO>='" + MV_PAR01 + "'.And.E1_PREFIXO<='" + MV_PAR02 + "'.And. " 
cFilter		+= "E1_NUM>='" + MV_PAR03 + "'.And. E1_NUM<='" + MV_PAR04 + "'.And. "
cFilter		+= "E1_PARCELA>='" + MV_PAR05 + "'.And.E1_PARCELA<='" + MV_PAR06 + "'.And. "
//cFilter		+= "E1_PORTADO>='" + MV_PAR07 + "'.And.E1_PORTADO<='" + MV_PAR08 + "'.And."
cFilter		+= "E1_CLIENTE>='" + MV_PAR07 + "'.And. E1_CLIENTE<='" + MV_PAR08 + "'.And. "
cFilter		+= "E1_LOJA>='" + MV_PAR09 + "'.And. E1_LOJA<='"+MV_PAR10+"'.And. "
cFilter		+= "DTOS(E1_EMISSAO) >='"+DTOS(mv_par11)+"'.and. DTOS(E1_EMISSAO) <= '"+DTOS(mv_par12)+"'.And. "
cFilter		+= "DTOS(E1_VENCREA) >='"+DTOS(mv_par13)+"'.and. DTOS(E1_VENCREA) <= '"+DTOS(mv_par14)+"'.And. "
//cFilter		+= "E1_NUMBOR>='" + MV_PAR17 + "'.And.E1_NUMBOR<='" + MV_PAR18 + "'.And."
cFilter		+= "!(E1_TIPO$MVABATIM).And. "
//cFilter		+= "E1_PORTADO<>'   '.And."
cFilter     += "POSICIONE('SA1',1,xFilial('SA1') + E1_CLIENTE + E1_LOJA,'A1_BOLETO') == '1'"

IndRegua("SE1", cIndexName, cIndexKey,, cFilter, "Aguarde selecionando registros....")
DbSelectArea("SE1")
#IFNDEF TOP
	DbSetIndex(cIndexName + OrdBagExt())
#ENDIF
dbGoTop()
@ 001,001 TO 400,700 DIALOG oDlg TITLE "Seleção de Titulos"
@ 001,001 TO 170,350 BROWSE "SE1" MARK "E1_OK"
@ 180,310 BMPBUTTON TYPE 01 ACTION (lExec := .T.,Close(oDlg))
@ 180,280 BMPBUTTON TYPE 02 ACTION (lExec := .F.,Close(oDlg))
ACTIVATE DIALOG oDlg CENTERED
	
dbGoTop()
If lExec
	Processa({|lEnd|MontaRel()})
Endif
RetIndex("SE1")
Ferase(cIndexName+OrdBagExt())

Return Nil

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  MontaRel³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER COM CODIGO DE BARRAS			     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaRel()
LOCAL oPrint
LOCAL nX := 0
Local cNroDoc :=  " "
LOCAL aDadosEmp    := {	SM0->M0_NOMECOM                                  								  ,; //[1]Nome da Empresa
								SM0->M0_ENDCOB                                     						  ,; //[2]Endereço
								AllTrim(SM0->M0_BAIRCOB)+", "+AllTrim(SM0->M0_CIDCOB)+", "+SM0->M0_ESTCOB ,; //[3]Complemento
								"CEP: "+Subs(SM0->M0_CEPCOB,1,5)+"-"+Subs(SM0->M0_CEPCOB,6,3)             ,; //[4]CEP
								"PABX/FAX: "+SM0->M0_TEL                                                  ,; //[5]Telefones
								"CNPJ: "+Subs(SM0->M0_CGC,1,2)+"."+Subs(SM0->M0_CGC,3,3)+"."+          	   ; //[6]
								Subs(SM0->M0_CGC,6,3)+"/"+Subs(SM0->M0_CGC,9,4)+"-"+                       ; //[6]
								Subs(SM0->M0_CGC,13,2)                                                    ,; //[6]CGC
								"I.E.: "+Subs(SM0->M0_INSC,1,3)+"."+Subs(SM0->M0_INSC,4,3)+"."+            ; //[7]
								Subs(SM0->M0_INSC,7,3)+"."+Subs(SM0->M0_INSC,10,3)                         } //[7]I.E

LOCAL aDadosTit
LOCAL aDadosBanco
LOCAL aDatSacado
LOCAL aBolText     := {"Juros de 2% por atraso",;
					   "Multa de 5% por atraso"}
LOCAL nI           := 1
LOCAL aCB_RN_NN    := {}
LOCAL aMultJur	   := {}	
LOCAL nVlrAbat     := 0               
LOCAL nVlrAcres		:= 0

Private nIss       := 0.00

oPrint:= TMSPrinter():New( "Boleto Laser" )
oPrint:SetPortrait() // ou SetLandscape()
oPrint:StartPage()   // Inicia uma nova página

dbGoTop()
ProcRegua(RecCount())
Do While !EOF()
	//Posiciona o SA6 (Bancos)
	
	IF(IW_Msgbox("Deseja inserir valor de juros e multa para o título "+SE1->E1_NUM+;
			" ? Caso sim os valores serão substituidos no título !" ,"Juros / Multa", "YESNO" ))
	
		aMultJur := MultJur()
		
		DbSelectArea("SE1")
		If Reclock("SE1",.F.)
			Replace SE1->E1_JUROS WITH aMultJur[1]
			Replace SE1->E1_MULTA WITH aMultJur[2]
			msunlock()
		Endif
		
	EndIf
	
	If(!EMPTY(ALLTRIM(SE1->E1_PORTADO)))
	
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+SE1->E1_PORTADO+SE1->E1_AGEDEP+SE1->E1_CONTA,.T.)
	
	Else
		
		DbSelectArea("SA6")
		DbSetOrder(1)
		DbSeek(xFilial("SA6")+POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_BCO1')+SUBSTR(POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_AGENC1'),1,5)+SUBSTR(POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_CONTA1'),1,10),.T.)
	
	EndIf
	
	//Posiciona na Arq de Parametros CNAB
	DbSelectArea("SEE")
	DbSetOrder(1)
	
	If(!Empty(SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA)))
		DbSeek(xFilial("SEE")+SE1->(E1_PORTADO+E1_AGEDEP+E1_CONTA),.T.)
	Else
		DbSeek(xFilial("SEE")+POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_BCO1')+SUBSTR(POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_AGENC1'),1,5)+SUBSTR(POSICIONE('SA1',1,xFilial('SA1')+SE1->E1_CLIENTE+SE1->E1_LOJA,'SA1->A1_CONTA1'),1,10),.T.)	
	EndIf
		IF mv_par15==1 //Reimpressao  
		cNroDoc := "9"+alltrim(SE1->E1_NUMBCO)
		
		Else
		
		If empty(SE1->E1_NUMBCO) .AND. Marked("E1_OK")
	 		If Reclock("SEE",.F.)
		    	Replace SEE->EE_FAXATU WITH  soma1(alltrim(SEE->EE_FAXATU),5)
		     	msunlock()
	      	Endif
	      	
	      	cNroDoc := FNossoN("9"+alltrim(SEE->EE_FAXATU))
	      
	      	DbSelectArea("SE1")
		   	If Reclock("SE1",.F.)
				Replace SE1->E1_NUMBCO WITH Substr(cNroDoc,2,12)
				msunlock()
			Endif	      	
	    
	    Endif   
		EndIf
	
	//Posiciona o SA1 (Cliente)
	DbSelectArea("SA1")
	DbSetOrder(1)
	DbSeek(xFilial()+SE1->E1_CLIENTE+SE1->E1_LOJA,.T.)
	
	DbSelectArea("SE1")
	aDadosBanco  := {SA6->A6_COD                       							    ,;	// [1]Numero do Banco
							SA6->A6_NREDUZ                                       	,;  // [2]Nome do Banco
	                  SUBSTR(SA6->A6_AGENCIA, 1, 4)                        			,;	// [3]Agência 
					  SUBSTR(SA6->A6_DVAGE, 1, 1)									,;  // [4]Dígito da Agência	                  
                      SUBSTR(SA6->A6_NUMCON,1,7)								,;	// [5]Conta Corrente
                      Alltrim(SA6->A6_DVCTA)  										,;	// [6]Dígito da conta corrente
                      "09"                                              		}	// [7]Codigo da Carteira

	If Empty(SA1->A1_ENDCOB)
		aDatSacado   := {AllTrim(SA1->A1_NOME)           ,;      	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA           ,;      	// [2]Código
		AllTrim(SA1->A1_END )+"-"+AllTrim(SA1->A1_BAIRRO),;      	// [3]Endereço
		AllTrim(SA1->A1_MUN )                            ,;			// [4]Cidade
		SA1->A1_EST                                      ,;    		// [5]Estado
		SA1->A1_CEP                                      ,;      	// [6]CEP
		SA1->A1_CGC										 ,;			// [7]CGC
		SA1->A1_PESSOA								      }  		// [8]PESSOA
	Else
		aDatSacado   := {AllTrim(SA1->A1_NOME)            	 ,;   	// [1]Razão Social
		AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA               ,;   	// [2]Código
		AllTrim(SA1->A1_ENDCOB)+"-"+AllTrim(SA1->A1_BAIRROC) ,;   	// [3]Endereço
		AllTrim(SA1->A1_MUNC)	                             ,;   	// [4]Cidade
		SA1->A1_ESTC	                                     ,;   	// [5]Estado
		SA1->A1_CEP                                          ,;   	// [6]CEP
		SA1->A1_CGC											 ,;		// [7]CGC
		SA1->A1_PESSOA										  }		// [8]PESSOA
	Endif
	
   /*Alterado por Luiz para pegar campo decrescimo dia 22/08/13
   	nVlrAbat   :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)

     Alterado por Inácio conforme SAU 15515 para diminuir o ISS (+ nIss) 
       do valor total do título fatura 000420384 em 03/03/2015. Incluida a função fBscAbtIss para tal tarefa.
   */

	fBscAbtISS(@nIss, xFilial("SE1"), SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "IS-", SE1->E1_CLIENTE, SE1->E1_LOJA)

	nVlrAbat	:= SE1->E1_DECRESC + nIss
	nVlrAcres	:=	SE1->E1_ACRESC
   		
	//	Monta codigo de barras
	aCB_RN_NN    :=Ret_cBarra(SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA	,SE1->E1_TIPO	,;
							Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[5] ,aDadosBanco[6]	,;
							cNroDoc		,((E1_VALOR+nVlrAcres)-nVlrAbat)	, "09"	,"9"	)  // MARCOS GODOI
    /*
	aCB_RN_NN    :=Ret_cBarra(SE1->E1_PREFIXO	,SE1->E1_NUM	,SE1->E1_PARCELA	,SE1->E1_TIPO	,;
							Subs(aDadosBanco[1],1,3)	,aDadosBanco[3]	,aDadosBanco[5] ,aDadosBanco[6]	,;
							cNroDoc		,((E1_VALOR+nVlrAcres)-nVlrAbat)	, "09"	,"9"	) // MARCOS GODOI
    */
	
	
		aDadosTit	:= {AllTrim(E1_NUM)+iif(E1_PARCELA = ' ','0',AllTrim(E1_PARCELA))		     ,;  // [1] Número do título
						SE1->E1_EMISSAO                          ,;  // [2] Data da emissão do título
						dDataBase                    			     ,;  // [3] Data da emissão do boleto
						SE1->E1_VENCTO                           ,;  // [4] Data do vencimento
						((SE1->E1_SALDO + nVlrAcres) - nVlrAbat) ,;  // [5] Valor do título
						aCB_RN_NN[3]                        	  ,;  // [6] Nosso número (Ver fórmula para calculo)
						SE1->E1_PREFIXO                          ,;  // [7] Prefixo da NF
						"DM"	                                   ,;  // [8] Tipo do Titulo
	                    SE1->E1_MULTA                       ,;  // [9] MULTA
	                    SE1->E1_JUROS                       ,;  //[10] JUROS
	                    SE1->E1_ACRESC							   }  //[11] Acrescimo
	                    
  //Grava o valor do abatimento no campo SE1->E1_ABATIME para utilização do arquivo
  
   //DbSelectArea("SE1")
   //DbSetOrder(1)    

   /* Comentado em 08/08/12 por Guilherme Luan Resende Lima
   If Reclock("SE1",.F.)
		REPLACE SE1->E1_ABATIME WITH nVlrAbat  
	  msunlock()
   endif	                    
  */
	                    
    If Marked("E1_OK")
		Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
		nX := nX + 1
	EndIf
	dbSkip()
	IncProc()
	nI := nI + 1
EndDo
oPrint:EndPage()     // Finaliza a página
oPrint:Preview()     // Visualiza antes de imprimir

Return nil



Static Function fBscAbtISS( nIss, cFilIss, cPrefIss, cNumIss, cParcIss, cTipoIss, cCliIss, cLojIss)
***********************************************************************************************************************
*   Função para buuscar o valor do iss
**
*** 
****  
Local aAreaIss := GetArea()
Local cQuery   := ''

#IFDEF TOP
        
	cQuery := " SELECT * "
	cQuery += " FROM "+RetSQLName("SE1")+" (NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += "       AND E1_FILIAL  = '"+cFilIss+"' "
	cQuery += "       AND E1_PREFIXO = '"+cPrefIss+"' "
	cQuery += "       AND E1_NUM     = '"+cNumIss+"' "
	cQuery += "       AND E1_PARCELA = '"+cParcIss+"' "
	cQuery += "       AND E1_TIPO    = '"+cTipoIss+"' "
	cQuery += "       AND E1_CLIENTE = '"+cCliIss+"' "
	cQuery += "       AND E1_LOJA    = '"+cLojIss+"' "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSE1", .F., .T.)
      
#ENDIF

dbSelectArea("TSE1")
dbGoTop()

If !Eof()

	nIss := TSE1->E1_VALOR

Else

	nIss := 0.00

Endif

dbSelectArea("TSE1")
TSE1->(dbCloseArea())

RestArea(aAreaIss)

Return(.T.)


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³  Impress ³ Autor ³ Microsiga             ³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ IMPRESSAO DO BOLETO LASER DO BANCO BRADESCO                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Impress(oPrint,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,aCB_RN_NN,cNroDoc)
LOCAL oFont8
LOCAL oFont11c
LOCAL oFont10
LOCAL oFont14
LOCAL oFont16n
LOCAL oFont15
LOCAL oFont14n
LOCAL oFont24
LOCAL nI := 0

//Parametros de TFont.New()
//1.Nome da Fonte (Windows)
//3.Tamanho em Pixels
//5.Bold (T/F)
oFont8  := TFont():New("Arial",9,8,.T.,.F.,5,.T.,5,.T.,.F.)
oFont11c := TFont():New("Courier New",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont11  := TFont():New("Arial",9,11,.T.,.T.,5,.T.,5,.T.,.F.)
oFont10  := TFont():New("Arial",9,10,.T.,.T.,5,.T.,5,.T.,.F.)
oFont14  := TFont():New("Arial",9,14,.T.,.T.,5,.T.,5,.T.,.F.)
oFont20  := TFont():New("Arial",9,20,.T.,.T.,5,.T.,5,.T.,.F.)
oFont21  := TFont():New("Arial",9,21,.T.,.T.,5,.T.,5,.T.,.F.)
oFont16n := TFont():New("Arial",9,16,.T.,.F.,5,.T.,5,.T.,.F.)
oFont15  := TFont():New("Arial",9,15,.T.,.T.,5,.T.,5,.T.,.F.)
oFont15n := TFont():New("Arial",9,15,.T.,.F.,5,.T.,5,.T.,.F.)
oFont14n := TFont():New("Arial",9,14,.T.,.F.,5,.T.,5,.T.,.F.)
oFont24  := TFont():New("Arial",9,24,.T.,.T.,5,.T.,5,.T.,.F.)

oPrint:StartPage()   // Inicia uma nova página

/******************/
/* PRIMEIRA PARTE */
/******************/

nRow1 := 0
 
oPrint:Line (nRow1+0150,500,nRow1+0070, 500)
oPrint:Line (nRow1+0150,710,nRow1+0070, 710)

oPrint:SayBitmap(nRow1+0060,155,"logobradesco.bmp",300,100)    // Logo do Banco
//oPrint:Say  (nRow1+0084,155,aDadosBanco[2],oFont11 )	   		// [2]Nome do Banco
oPrint:Say  (nRow1+0075,513,aDadosBanco[1]+"-2",oFont21 )  		// [1]Numero do Banco

oPrint:Say  (nRow1+0084,1900,"Comprovante de Entrega",oFont10)
oPrint:Line (nRow1+0150,100,nRow1+0150,2300)

oPrint:Say  (nRow1+0150,100 ,"Cedente",oFont8)
oPrint:Say  (nRow1+0200,100 ,aDadosEmp[1],oFont10)				//Nome + CNPJ

oPrint:Say  (nRow1+0150,1060,"Agência/Código Cedente",oFont8)
//oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+aDadosBanco[5]+"-"+aDadosBanco[6],oFont10)
oPrint:Say  (nRow1+0200,1060,aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+alltrim(SA6->A6_NUMCON)+"-"+aDadosBanco[6],oFont10)
oPrint:Say  (nRow1+0150,1510,"Nro.Documento",oFont8)
oPrint:Say  (nRow1+0200,1510,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9)),oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow1+0250,100 ,"Sacado",oFont8)
oPrint:Say  (nRow1+0300,100 ,aDatSacado[1],oFont10)				//Nome

oPrint:Say  (nRow1+0250,1060,"Vencimento",oFont8)
oPrint:Say  (nRow1+0300,1060,StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4),oFont10)

oPrint:Say  (nRow1+0250,1510,"Valor do Documento",oFont8)
oPrint:Say  (nRow1+0300,1550,AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),oFont10)

oPrint:Say  (nRow1+0400,0100,"Recebi(emos) o bloqueto/título",oFont10)
oPrint:Say  (nRow1+0450,0100,"com as características acima.",oFont10)
oPrint:Say  (nRow1+0350,1060,"Data",oFont8)
oPrint:Say  (nRow1+0350,1410,"Assinatura",oFont8)
oPrint:Say  (nRow1+0450,1060,"Data",oFont8)
oPrint:Say  (nRow1+0450,1410,"Entregador",oFont8)

oPrint:Line (nRow1+0250, 100,nRow1+0250,1900 )
oPrint:Line (nRow1+0350, 100,nRow1+0350,1900 )
oPrint:Line (nRow1+0450,1050,nRow1+0450,1900 ) //---
oPrint:Line (nRow1+0550, 100,nRow1+0550,2300 )

oPrint:Line (nRow1+0550,1050,nRow1+0150,1050 )
oPrint:Line (nRow1+0550,1400,nRow1+0350,1400 )
oPrint:Line (nRow1+0350,1500,nRow1+0150,1500 ) //--
oPrint:Line (nRow1+0550,1900,nRow1+0150,1900 )

oPrint:Say  (nRow1+0165,1910,"(  )Mudou-se"                                	,oFont8)
oPrint:Say  (nRow1+0205,1910,"(  )Ausente"                                    ,oFont8)
oPrint:Say  (nRow1+0245,1910,"(  )Não existe nº indicado"                  	,oFont8)
oPrint:Say  (nRow1+0285,1910,"(  )Recusado"                                	,oFont8)
oPrint:Say  (nRow1+0325,1910,"(  )Não procurado"                              ,oFont8)
oPrint:Say  (nRow1+0365,1910,"(  )Endereço insuficiente"                  	,oFont8)
oPrint:Say  (nRow1+0405,1910,"(  )Desconhecido"                            	,oFont8)
oPrint:Say  (nRow1+0445,1910,"(  )Falecido"                                   ,oFont8)
oPrint:Say  (nRow1+0485,1910,"(  )Outros(anotar no verso)"                  	,oFont8)
           

/*****************/
/* SEGUNDA PARTE */
/*****************/

nRow2 := 0

//Pontilhado separador
For nI := 100 to 2300 step 50
	oPrint:Line(nRow2+0580, nI,nRow2+0580, nI+30)
Next nI

oPrint:Line (nRow2+0710,100,nRow2+0710,2300)
oPrint:Line (nRow2+0710,500,nRow2+0630, 500)
oPrint:Line (nRow2+0710,710,nRow2+0630, 710)

oPrint:SayBitmap(nRow1+0610,155,"logobradesco.bmp",300,100) // Logo do Banco
//oPrint:Say  (nRow2+0644,155,aDadosBanco[2],oFont11 )		// [2]Nome do Banco
oPrint:Say  (nRow2+0635,513,aDadosBanco[1]+"-2",oFont21 )	// [1]Numero do Banco   
oPrint:Say  (nRow2+0644,755,aCB_RN_NN[2],oFont15n)			// Linha Digitavel do Codigo de Barras
//oPrint:Say  (nRow2+0644,1800,"Recibo do Sacado",oFont10)

oPrint:Line (nRow2+0810,100,nRow2+0810,2300 )
oPrint:Line (nRow2+0910,100,nRow2+0910,2300 )
oPrint:Line (nRow2+0980,100,nRow2+0980,2300 )
oPrint:Line (nRow2+1050,100,nRow2+1050,2300 )

oPrint:Line (nRow2+0910,500,nRow2+1050,500)
oPrint:Line (nRow2+0980,750,nRow2+1050,750)
oPrint:Line (nRow2+0910,1000,nRow2+1050,1000)
oPrint:Line (nRow2+0910,1300,nRow2+0980,1300)
oPrint:Line (nRow2+0910,1480,nRow2+1050,1480)

oPrint:Say  (nRow2+0710,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow2+0725,400 ,"Pagavel preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)
//oPrint:Say  (nRow2+0765,400 ,"Pagável preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)

oPrint:Say  (nRow2+0710,1810,"Vencimento"                                     ,oFont8)
cString	:= StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0750,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0810,100 ,"Cedente"                                        ,oFont8)
oPrint:Say  (nRow2+0850,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow2+0810,1810,"Agência/Código Cedente",oFont8)
//cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+aDadosBanco[5]+"-"+aDadosBanco[6])
cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+AllTrim(SA6->A6_NUMCON)+"-"+aDadosBanco[6])
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0850,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0910,100 ,"Data do Documento"                              ,oFont8)
oPrint:Say  (nRow2+0940,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4),oFont10)

oPrint:Say  (nRow2+0910,505 ,"Nro.Documento"                                  ,oFont8)
oPrint:Say  (nRow2+0940,605 ,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9))						  ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow2+0910,1005,"Espécie Doc."                                   ,oFont8)
oPrint:Say  (nRow2+0940,1050,aDadosTit[8]									  ,oFont10) //Tipo do Titulo

oPrint:Say  (nRow2+0910,1305,"Aceite"                                         ,oFont8)
oPrint:Say  (nRow2+0940,1400,"N"                                              ,oFont10)

oPrint:Say  (nRow2+0910,1485,"Data do Processamento"                          ,oFont8)
oPrint:Say  (nRow2+0940,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4),oFont10) // Data impressao

oPrint:Say  (nRow2+0910,1810,"Nosso Número"                                   ,oFont8)
cString := "0"+Alltrim(Substr(cNroDoc,1,1))+"/"+Alltrim(Substr(cNroDoc,2,11)+"-"+Substr(cNroDoc,13,1))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+0940,nCol,cString,oFont11c)

oPrint:Say  (nRow2+0980,100 ,"Uso do Banco"                                   ,oFont8)

oPrint:Say  (nRow2+0980,505 ,"Carteira"                                       ,oFont8)
oPrint:Say  (nRow2+1010,555 ,aDadosBanco[7]                                   ,oFont10)

oPrint:Say  (nRow2+0980,755 ,"Espécie"                                        ,oFont8)
oPrint:Say  (nRow2+1010,805 ,"R$"                                             ,oFont10)

oPrint:Say  (nRow2+0980,1005,"Quantidade"                                     ,oFont8)
oPrint:Say  (nRow2+0980,1485,"Valor"                                          ,oFont8)

oPrint:Say  (nRow2+0980,1810,"Valor do Documento"                          	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))
nCol := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow2+1010,nCol,cString ,oFont11c)

oPrint:Say  (nRow2+1050,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

//If !Empty(Alltrim(aDadosTit[11]))  // parcela
//	oPrint:Say  (nRow2+1100,100 , "Parcela: "+aDadosTit[11] ,oFont10)
//EndIf

//oPrint:Say  (nRow2+1150,100 ,aBolText[1]+" "+AllTrim(Transform((aDadosTit[5]*0.02),"@E 99,999.99"))       ,oFont10)
//oPrint:Say  (nRow2+1200,100 ,aBolText[2]+" "+AllTrim(Transform(((aDadosTit[5]*0.01)/30),"@E 99,999.99"))  ,oFont10)
oPrint:Say  (nRow2+1150,100 ,aBolText[1]  ,oFont10)
oPrint:Say  (nRow2+1200,100 ,aBolText[2]  ,oFont10)
//oPrint:Say  (nRow2+1250,100 ,aBolText[3]  ,oFont10)

//oPrint:Say  (nRow2+1250,100 ,aDadosTit[13]                          ,oFont10)
//oPrint:Say  (nRow2+1300,100 ,"Apartamento: "+aDadosTit[12]           ,oFont10)


oPrint:Say  (nRow2+1050,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow2+1120,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow2+1190,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow2+1260,1810,"(+)Outros Acréscimos"                           ,oFont8) 
cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))   
//nCol := 1260+(374-(len(cString)*22))
oPrint:Say	(nRow2+1280,2100,cString									  ,oFont8)
oPrint:Say  (nRow2+1330,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow2+1400,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow2+1430,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)
oPrint:Say  (nRow2+1483,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow2+1536,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado

if aDatSacado[8] = "J"
	oPrint:Say  (nRow2+1589,400 ,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow2+1589,400 ,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10) 	// CPF
EndIf

oPrint:Say  (nRow2+1589,1850,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say  (nRow2+1605,100 ,"Sacador/Avalista",oFont8)
oPrint:Say  (nRow2+1645,1500,"Autenticação Mecânica",oFont8)

oPrint:Line (nRow2+0710,1800,nRow2+1400,1800 ) 
oPrint:Line (nRow2+1120,1800,nRow2+1120,2300 )
oPrint:Line (nRow2+1190,1800,nRow2+1190,2300 )
oPrint:Line (nRow2+1260,1800,nRow2+1260,2300 )
oPrint:Line (nRow2+1330,1800,nRow2+1330,2300 )
oPrint:Line (nRow2+1400,100 ,nRow2+1400,2300 )
oPrint:Line (nRow2+1640,100 ,nRow2+1640,2300 )


/******************/
/* TERCEIRA PARTE */
/******************/

nRow3 := 0

For nI := 100 to 2300 step 50
	oPrint:Line(nRow3+1880, nI, nRow3+1880, nI+30)
Next nI

oPrint:Line (nRow3+2000,100,nRow3+2000,2300)
oPrint:Line (nRow3+2000,500,nRow3+1920, 500)
oPrint:Line (nRow3+2000,710,nRow3+1920, 710)

oPrint:SayBitmap(nRow1+1900,155,"logobradesco.bmp",300,100) // Logo do Banco
//oPrint:Say  (nRow3+1934,155,aDadosBanco[2],oFont11 )		// 	[2]Nome do Banco
oPrint:Say  (nRow3+1925,513,aDadosBanco[1]+"-2",oFont21 )	// 	[1]Numero do Banco
oPrint:Say  (nRow3+1934,755,aCB_RN_NN[2],oFont15n)			//	Linha Digitavel do Codigo de Barras

oPrint:Line (nRow3+2100,100,nRow3+2100,2300 )
oPrint:Line (nRow3+2200,100,nRow3+2200,2300 )
oPrint:Line (nRow3+2270,100,nRow3+2270,2300 )
oPrint:Line (nRow3+2340,100,nRow3+2340,2300 )

oPrint:Line (nRow3+2200,500 ,nRow3+2340,500 )
oPrint:Line (nRow3+2270,750 ,nRow3+2340,750 )
oPrint:Line (nRow3+2200,1000,nRow3+2340,1000)
oPrint:Line (nRow3+2200,1300,nRow3+2270,1300)
oPrint:Line (nRow3+2200,1480,nRow3+2340,1480)

oPrint:Say  (nRow3+2000,100 ,"Local de Pagamento",oFont8)
oPrint:Say  (nRow3+2015,400 ,"Pagavel preferencialmente na Rede Bradesco ou Bradesco Expresso",oFont10)

           
oPrint:Say  (nRow3+2000,1810,"Vencimento",oFont8)
cString := StrZero(Day(aDadosTit[4]),2) +"/"+ StrZero(Month(aDadosTit[4]),2) +"/"+ Right(Str(Year(aDadosTit[4])),4)
nCol	 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2040,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2100,100 ,"Cedente",oFont8)
oPrint:Say  (nRow3+2140,100 ,aDadosEmp[1]+"                  - "+aDadosEmp[6]	,oFont10) //Nome + CNPJ

oPrint:Say  (nRow3+2100,1810,"Agência/Código Cedente",oFont8)
//cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+aDadosBanco[5]+"-"+aDadosBanco[6])
cString := Alltrim(aDadosBanco[3]+"-"+aDadosBanco[4]+"/"+AllTrim(SA6->A6_NUMCON)+"-"+aDadosBanco[6])
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2140,nCol,cString ,oFont11c)


oPrint:Say  (nRow3+2200,100 ,"Data do Documento"                                ,oFont8)
oPrint:Say (nRow3+2230,100, StrZero(Day(aDadosTit[2]),2) +"/"+ StrZero(Month(aDadosTit[2]),2) +"/"+ Right(Str(Year(aDadosTit[2])),4), oFont10)


oPrint:Say  (nRow3+2200,505 ,"Nro.Documento"                                    ,oFont8)
oPrint:Say  (nRow3+2230,605 ,Alltrim(aDadosTit[7])+Alltrim(SubStr(aDadosTit[1],2,9))    ,oFont10) //Prefixo +Numero+Parcela

oPrint:Say  (nRow3+2200,1005,"Espécie Doc."                                     ,oFont8)
oPrint:Say  (nRow3+2230,1050,aDadosTit[8]										,oFont10) //Tipo do Titulo

oPrint:Say  (nRow3+2200,1305,"Aceite"                                           ,oFont8)
oPrint:Say  (nRow3+2230,1400,"N"                                                ,oFont10)

oPrint:Say  (nRow3+2200,1485,"Data do Processamento"                            ,oFont8)
oPrint:Say  (nRow3+2230,1550,StrZero(Day(aDadosTit[3]),2) +"/"+ StrZero(Month(aDadosTit[3]),2) +"/"+ Right(Str(Year(aDadosTit[3])),4)                               ,oFont10) // Data impressao


oPrint:Say  (nRow3+2200,1810,"Nosso Número"                                     ,oFont8)
cString := "0"+Alltrim(Substr(cNroDoc,1,1))+"/"+Alltrim(Substr(cNroDoc,2,11)+"-"+Substr(cNroDoc,13,1))
nCol := 1809+(374-(len(cString)*22))
oPrint:Say  (nRow3+2230,nCol,cString,oFont11c)


oPrint:Say  (nRow3+2270,100 ,"Uso do Banco"                                     ,oFont8)

oPrint:Say  (nRow3+2270,505 ,"Carteira"                                         ,oFont8)
oPrint:Say  (nRow3+2300,555 ,aDadosBanco[7]                                  	,oFont10)

oPrint:Say  (nRow3+2270,755 ,"Espécie"                                          ,oFont8)
oPrint:Say  (nRow3+2300,805 ,"R$"                                               ,oFont10)

oPrint:Say  (nRow3+2270,1005,"Quantidade"                                       ,oFont8)
oPrint:Say  (nRow3+2270,1485,"Valor"                                            ,oFont8)

oPrint:Say  (nRow3+2270,1810,"Valor do Documento"                    	      	,oFont8)
cString := Alltrim(Transform(aDadosTit[5],"@E 99,999,999.99"))       
nCol 	 := 1810+(374-(len(cString)*22))
oPrint:Say  (nRow3+2300,nCol,cString,oFont11c)

oPrint:Say  (nRow3+2340,100 ,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont8)

//If !Empty(Alltrim(aDadosTit[11]))  // parcela
//	oPrint:Say  (nRow3+2390,100 , "Parcela: "+aDadosTit[11] ,oFont10)
//EndIf

oPrint:Say  (nRow3+2440,100 ,aBolText[1] ,oFont10)
oPrint:Say  (nRow3+2490,100 ,aBolText[2] ,oFont10)
//oPrint:Say  (nRow3+2540,100 ,aBolText[3] ,oFont10)
//oPrint:Say  (nRow3+2540,100 ,aBolText[3]                                        ,oFont10)
//oPrint:Say  (nRow3+2540,100 ,aDadosTit[13]                          ,oFont10)
//oPrint:Say  (nRow3+2590,100 ,"Apartamento: "+aDadosTit[12]           ,oFont10)


oPrint:Say  (nRow3+2340,1810,"(-)Desconto/Abatimento"                         ,oFont8)
oPrint:Say  (nRow3+2410,1810,"(-)Outras Deduções"                             ,oFont8)
oPrint:Say  (nRow3+2480,1810,"(+)Mora/Multa"                                  ,oFont8)
oPrint:Say  (nRow3+2550,1810,"(+)Outros Acréscimos"                           ,oFont8) 
cString := Alltrim(Transform(aDadosTit[11],"@E 99,999,999.99"))   
//nCol := 1260+(374-(len(cString)*22))
oPrint:Say	(nRow2+2580,2100,cString									      ,oFont8)
oPrint:Say  (nRow3+2620,1810,"(=)Valor Cobrado"                               ,oFont8)

oPrint:Say  (nRow3+2690,100 ,"Sacado"                                         ,oFont8)
oPrint:Say  (nRow3+2700,400 ,aDatSacado[1]+" ("+aDatSacado[2]+")"             ,oFont10)

if aDatSacado[8] = "J"
	oPrint:Say  (nRow3+2700,1750,"CNPJ: "+TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99"),oFont10) // CGC
Else
	oPrint:Say  (nRow3+2700,1750,"CPF: "+TRANSFORM(aDatSacado[7],"@R 999.999.999-99"),oFont10)	 	// CPF
EndIf
                                                          	
oPrint:Say  (nRow3+2753,400 ,aDatSacado[3]                                    ,oFont10)
oPrint:Say  (nRow3+2806,400 ,aDatSacado[6]+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont10) // CEP+Cidade+Estado
oPrint:Say  (nRow3+2806,1750,Substr(aDadosTit[6],1,3)+Substr(aDadosTit[6],4)  ,oFont10)

oPrint:Say  (nRow3+2815,100 ,"Sacador/Avalista"                               ,oFont8)
oPrint:Say  (nRow3+2855,1500,"Autenticação Mecânica - Ficha de Compensação"                        ,oFont8)

oPrint:Line (nRow3+2000,1800,nRow3+2690,1800 )
oPrint:Line (nRow3+2410,1800,nRow3+2410,2300 )
oPrint:Line (nRow3+2480,1800,nRow3+2480,2300 )
oPrint:Line (nRow3+2550,1800,nRow3+2550,2300 )
oPrint:Line (nRow3+2620,1800,nRow3+2620,2300 )
oPrint:Line (nRow3+2690,100 ,nRow3+2690,2300 )

oPrint:Line (nRow3+2850,100,nRow3+2850,2300  )

//MSBAR("INT25",24.5,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,15,Nil,Nil,"A",.F.)                                                                        

MSBAR("INT25",24.5,1,aCB_RN_NN[1],oPrint,.F.,Nil,Nil,0.025,,Nil,Nil,"A",.F.)

//DbSelectArea("SE1")
//RecLock("SE1",.f.)
//SE1->E1_NUMBCO 	:=	aCB_RN_NN[3]   // Nosso número (Ver fórmula para calculo)
//MsUnlock()

oPrint:EndPage() // Finaliza a página

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FNossoN   ºAutor  ³Roberto/Guilherme   º Data ³  22/01/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera o Nosso Número              					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static function FNossoN(cNoss)
local nCont 	:= 0
local nPeso 	:= 1
local cRet		:= ''
local nResto	:= 0
local nResult 	:= 0
local cDig		:= ''
		
For i := 12 To 1 Step -1
	nPeso := nPeso + 1  
	nCont := nCont + (Val(SUBSTR(cNoss,i,1))) * nPeso
	If nPeso == 7
		nPeso := 1
	Endif   
Next

nResto := ( nCont % 11 )  

If nResto = 1
	cDig := 'P'
Elseif nResto = 0
	cDig := '0'
else
	cDig := Str(11 - nResto,1)
EndIf

//cRet	:= substr(cNoss,3,11) + cDig
cRet := cNoss + cDig

return cRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³RetDados  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera SE1                        					          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ret_cBarra(	cPrefixo	,cNumero	,cParcela	,cTipo	,;
						cBanco		,cAgencia	,cConta		,cDacCC	,;
						cNroDoc		,nValor		,cCart		,cMoeda	)

Local cNosso		:= ""
Local cDigNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local cNro  		:= ""
Local aRet			:= {}

//DEFAULT nValor := 0

cAgencia:=STRZERO(Val(cAgencia),4)
		
cNosso := "" 
cNro   := Val(cNroDoc)
//NNUM   := STRZERO(Val(cNroDoc),11)
NNUM := Alltrim(Substr(cNroDoc,1,12))

//Nosso Numero
//cDigNosso  := U_CALC_di9(NNUM)
//cNosso     := NNUM + cDigNosso

// campo livre			// verificar a conta e carteira

//cCampoL := NNUM+cAgencia+StrZero(Val(cDacCC),8)+cCart
cCampoL := cAgencia+cCart+substr(NNUm,2,11)+cConta+"0"

//campo livre do codigo de barra                   // verificar a conta
If nValor > 0
	cFatorValor  := u_fator()+strzero(nValor*100,10)
Else
	//cFatorValor  := u_fator()+strzero(SE1->E1_VALOR*100,10)
	cFatorValor  := u_fator()+strzero(((SE1->E1_SALDO + nVlrAcres) - nVlrAbat)*100,10) // Marcos Godoi
	
Endif

cLivre := cBanco+cMoeda+cFatorValor+cCampoL

// campo do codigo de barra
cDigBarra := U_CALC_5p( cLivre )
cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)

// composicao da linha digitavel
cParte1  := cBanco+cMoeda
cParte1  := cParte1 + SUBSTR(cCampoL,1,5)
cDig1    := U_DIGIT001( cParte1 )
cParte2  := SUBSTR(cCampoL,6,10)
cDig2    := U_DIGIT001( cParte2 )
cParte3  := SUBSTR(cCampoL,16,10)
cDig3    := U_DIGIT001( cParte3 )
cParte4  := " "+cDigBarra+" "
cParte5  := cFatorValor

cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
			substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
			substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
			cParte4+;
			cParte5

Aadd(aRet,cBarra)
Aadd(aRet,cDigital)
Aadd(aRet,cNosso)		


Return aRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³DIGIT001  ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Para calculo da linha digitavel do Banco do Bradesco        º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function DIGIT001(cVariavel)

Local Auxi := 0, sumdig := 0
cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lbase

While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo 

cValor:=AllTrim(STR(sumdig,12))

If VAL(cValor) >= 10
	nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cValor,1,1))+1,12))+"0")
Else
	nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cValor,1,1))+1,12)))
EndIf
auxi := nDezena - sumdig
If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³FATOR		ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do FATOR  de vencimento para linha digitavel.       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User function Fator()
If Len(ALLTRIM(SUBSTR(DTOC(SE1->E1_VENCTO),7,4))) = 4
	cData := SUBSTR(DTOC(SE1->E1_VENCTO),7,4)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
Else
	cData := "20"+SUBSTR(DTOC(SE1->E1_VENCTO),7,2)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
//cFator := STR(1000+(SE1->E1_VENCREA-STOD("20000703")),4)
Return(cFator)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFuncao    ³CALC_5p   ºAutor  ³Microsiga           º Data ³  02/13/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Calculo do digito do código de barras                       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ BOLETOS                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CALC_5p(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lbase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))

//---------------------------------------------------------------------------------

Static Function MultJur()

Local nJuros	:= 0
Local nMulta	:= 0
Local aValores 	:= {}
Local lRet := .F.
Local nOpca := 0
Local lRet := .F.

While .T.

nOpca := 0

	DEFINE MSDIALOG oMkwdlg FROM	070,116 TO 200,380 TITLE "Dados de Juros/Multa" PIXEL  	

	@ 010,010 SAY "Juros"     	Size 25,08 OF oMkwdlg PIXEL	//"Juros"
	@ 025,010 SAY "Multa"   	Size 25,08 OF oMkwdlg PIXEL	//"Multa"
//	@ 040,010 SAY STR0130     	Size 25,08 OF oMkwdlg PIXEL	//"Conta"
//	@ 055,010 SAY STR0131    	Size 25,08 OF oMkwdlg PIXEL	//"Cheque"
//	@ 070,010 SAY STR0132		Size 35,08 OF oMkwdlg PIXEL	//"Vencimento"
//	@ 085,010 SAY STR0133		Size 25,08 OF oMkwdlg PIXEL	//"Valor"
//	@ 100,010 SAY STR0142		Size 25,08 OF oMkwdlg PIXEL	//"Emitente"
//	@ 010,050 MSGET oBanco VAR aCmc7[1] WHEN lCorrige	Size 70,10 OF oMkwdlg PIXEL hasbutton
//	@ 025,050 MSGET aCmc7[3] WHEN lCorrige	Size 70,08 OF oMkwdlg PIXEL hasbutton
//	@ 040,050 MSGET aCmc7[4] WHEN lCorrige	Size 70,08 OF oMkwdlg PIXEL hasbutton
//	@ 055,050 MSGET aCmc7[2] WHEN lCorrige	Size 70,08 OF oMkwdlg PIXEL hasbutton
	@ 010,050 MSGET nJuros Picture "@E 99,999,999.99" Size 70,08  OF oMkwdlg PIXEL hasbutton
	@ 025,050 MSGET nMulta Picture "@E 99,999,999.99" Size 70,08  OF oMkwdlg PIXEL hasbutton
//	@ 100,050 MSGET cEmiten460 Picture "@!S40" Size 70,08  OF oMkwdlg PIXEL hasbutton
		
	DEFINE SBUTTON FROM 040, 035 TYPE 1 ACTION (nOpca:=1,oMkwdlg:End())ENABLE OF oMkwdlg PIXEL
	DEFINE SBUTTON FROM 040, 065 TYPE 2 ACTION (nOpca:=2,oMkwdlg:End())ENABLE OF oMkwdlg PIXEL
		
ACTIVATE MSDIALOG oMkwdlg CENTERED


	If nOpca == 1  // Confirma Dados do Cheque
	   lRet := .T.
		
	ElseIf nOpca == 2 	// Finaliza inclusao de cheques
		lRet := .F.
		
	Endif	

	Exit

EndDo

aadd(aValores,nJuros)
aadd(aValores,nMulta)

Return(aValores)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSx1    ³ Autor ³ Microsiga            	³ Data ³ 13/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica/cria SX1 a partir de matriz para verificacao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para Clientes Microsiga                    	  		³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1(cPerg, aPergs)

Local _sAlias	:= Alias()
Local aCposSX1	:= {}
Local nX 		:= 0
Local lAltera	:= .F.
Local nCondicao
Local cKey		:= ""
Local nJ			:= 0

aCposSX1:={"X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO","X1_TAMANHO",;
			"X1_DECIMAL","X1_PRESEL","X1_GSC","X1_VALID",;
			"X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01",;
			"X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02",;
			"X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03",;
			"X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04",;
			"X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05",;
			"X1_F3", "X1_GRPSXG", "X1_PYME","X1_HELP" }

dbSelectArea("SX1")
dbSetOrder(1)
For nX:=1 to Len(aPergs)
	lAltera := .F.
	If MsSeek(cPerg+Right(aPergs[nX][11], 2))
		If (ValType(aPergs[nX][Len(aPergs[nx])]) = "B" .And.;
			 Eval(aPergs[nX][Len(aPergs[nx])], aPergs[nX] ))
			aPergs[nX] := ASize(aPergs[nX], Len(aPergs[nX]) - 1)
			lAltera := .T.
		Endif
	Endif
	
	If ! lAltera .And. Found() .And. X1_TIPO <> aPergs[nX][5]	
 		lAltera := .T.		// Garanto que o tipo da pergunta esteja correto
 	Endif	
	
	If ! Found() .Or. lAltera
		RecLock("SX1",If(lAltera, .F., .T.))
		Replace X1_GRUPO with cPerg
		Replace X1_ORDEM with Right(aPergs[nX][11], 2)
		For nj:=1 to Len(aCposSX1)
			If 	Len(aPergs[nX]) >= nJ .And. aPergs[nX][nJ] <> Nil .And.;
				FieldPos(AllTrim(aCposSX1[nJ])) > 0
				Replace &(AllTrim(aCposSX1[nJ])) With aPergs[nx][nj]
			Endif
		Next nj
		MsUnlock()
		cKey := "P."+AllTrim(X1_GRUPO)+AllTrim(X1_ORDEM)+"."

		If ValType(aPergs[nx][Len(aPergs[nx])]) = "A"
			aHelpSpa := aPergs[nx][Len(aPergs[nx])]
		Else
			aHelpSpa := {}
		Endif
		
		If ValType(aPergs[nx][Len(aPergs[nx])-1]) = "A"
			aHelpEng := aPergs[nx][Len(aPergs[nx])-1]
		Else                                              
			aHelpEng := {}
		Endif

		If ValType(aPergs[nx][Len(aPergs[nx])-2]) = "A"
			aHelpPor := aPergs[nx][Len(aPergs[nx])-2]
		Else
			aHelpPor := {}
		Endif

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
	Endif
Next

