#Include "rwmake.ch"
#Include "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³xDelKit      ºAutor  ³Yttalo P. Martins    º Data ³10/09/12 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao disparada pelo Botao "Deletar kit", no pedido de     º±±
±±º          ³vendas, que tem, como finalidade, deletar os kits/componentes±±
±±º          ³no aCols do Pedido de Venda.                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function xDelKit()

LOCAL aVetor := {}//cod kit,descr kit,tipo
LOCAL aDel   := {}
LOCAL oDlg := NIL
LOCAL oLbx := NIL
LOCAL cQuery := ""
LOCAL ni     := 1
LOCAL cKit   := ""
LOCAL cComp  := ""
LOCAL cTipo  := ""
LOCAL nRet   := 0

For ni := 1 to Len(aCols)
	
	If !(aCols[ni][Len(aCols[ni])])
		
		//---------------------------------------------------------------------------------------------------
		
		//adiciona o kit instrumental ao vetor
		If !Empty(aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XKIT"})])
			
			cKit := ALLTRIM( aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XKIT"})] )
			
			If aScan(aVetor,{|x| AllTrim(x[1])= cKit }) = 0
				
				dbSelectArea("SZ3")
				dbSetOrder(1)
				If dbSeek(xFilial("SZ3")+cKit)
					
					AADD(aVetor,{cKit,SZ3->Z3_DESCR,"I"})//Tipo "I" kit instrumental
					
				EndIf
				
			EndIf
			
		Endif
		
		//---------------------------------------------------------------------------------------------------
		
		//adiciona o kit de componente ao vetor
		If !Empty(aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XCOMPON"})])
			
			cComp := ALLTRIM( aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XCOMPON"})] )
			
			If aScan(aVetor,{|x| AllTrim(x[1])= cComp }) = 0
				
				dbSelectArea("SZ7")
				dbSetOrder(1)
				If dbSeek(xFilial("SZ7")+cComp)
					
					AADD(aVetor,{cComp,SZ7->Z7_DESC,"C"})//Tipo "C" kit componente
					
				EndIf
				
			EndIf
			
		Endif
		
		//---------------------------------------------------------------------------------------------------
		
	Endif
	
Next ni

If Len(aVetor)==0
	Aviso( "FIM", "Não há kits no grid!", {"Ok"} )
	Return
Endif

DEFINE MSDIALOG oDlgList TITLE "Kits Intrumental/Componentes" FROM 300,400 TO 540,700 PIXEL
@ 10,10 LISTBOX oLbx FIELDS HEADER "Código","Descrição" SIZE 130,095 OF oDlgList PIXEL
oLbx:SetArray( aVetor )
oLbx:bLine := {|| {aVetor[oLbx:nAt,1],aVetor[oLbx:nAt,2],aVetor[oLbx:nAt,3]} }
DEFINE SBUTTON FROM 107,090 TYPE 1 ACTION (nRet := 1,aDel := aVetor[oLbx:nAt],oDlgList:End()) ENABLE OF oDlgList
DEFINE SBUTTON FROM 107,120 TYPE 2 ACTION (nRet := 0,oDlgList:End()) ENABLE OF oDlgList
ACTIVATE MSDIALOG oDlgList

If nRet ==1
	
	cTipo := aDel[3]
	
	For ni := 1 to Len(aCols)
		
		If !(aCols[ni][Len(aCols[ni])])
			
			If cTipo == "I"
				//adiciona o kit instrumental ao vetor
				If !Empty(aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XKIT"})])
					
					cKit := ALLTRIM( aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XKIT"})] )
					
					If aScan(aDel,cKit) > 0
						
						aCols[ni][Len(aCols[ni])] := .T.
						
					EndIf
					
				Endif
				
			Else
				
				//adiciona o kit de componente ao vetor
				If !Empty(aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XCOMPON"})])
					
					cComp := ALLTRIM( aCols[ni][aScan(aHeader,{|x| AllTrim(x[2])="C6_XCOMPON"})] )
					
					If aScan(aDel,cComp) > 0
						
						aCols[ni][Len(aCols[ni])] := .T.
						
					EndIf
					
				Endif
				
			EndIf
			
		Endif
		
	Next ni
	
	GetDRefresh()//atualiza acols
	
EndIf

Return