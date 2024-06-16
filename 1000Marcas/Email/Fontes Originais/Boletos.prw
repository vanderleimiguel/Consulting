#INCLUDE "Protheus.ch"
#INCLUDE "RwMake.ch"

/* 
+-----------------------------------------------------------------------+
¦Programa  ¦Boletos ¦ Autor ¦ Luis Paulo Faria   ¦ Data: 	  09.04.2015¦
+----------+------------------------------------------------------------¦
¦Descriçào ¦ Fonte para chamada dos fontes de boletos por banco   		¦
¦          ¦                     												   ¦
¦          ¦                                                            ¦
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO PARA EXPRESSO NEPOMUCENO                        ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR      ¦ DATA       ¦ MOTIVO DA ALTERACAO                    ¦
+-----------------+------------+----------------------------------------¦
|						|            |                                        |
+-----------------------------------------------------------------------+
*/
User Function Boletos()

Local _cPergBol := "BOLETOS"  


If !Pergunte (_cPergBol,.T.)
	Return(.F.)
EndIf

If(MV_PAR01==1)   // BOLETOS DO BANCO DO BRASIL
	
	If(MV_PAR02==1) // BOLETO PADRAO BB
	  
	  	U_BLTCDBB()
	
	ElseIf(MV_PAR02==2) // BOLETO FATURA X CTRC
   
     	U_BolFatBB()  
   
   Else
   
   	MsgInfo ( "Informar o tipo de boleto e o banco !!", "Informações incompletas" )	
   
	EndIf  
	
ElseIf(MV_PAR01==2) // BOLETO PADRAO BRADESCO
	
	If(MV_PAR02==1) // BOLETO PADRAO BB
	  
	  U_BolBrad()
	
	ElseIf(MV_PAR02==2)// BOLETO FATURA X CTRC
   
     U_NEPR005()
   
   Else
   
   	MsgInfo ( "Informar o tipo de boleto e o banco !!", "Informações incompletas" )	
   
	EndIf
	
ElseIf(MV_PAR01==3)

	MsgInfo ( "Boleto do Banco em Desenvolvimento !!", "Layout Em Construção" )   

ElseIf(MV_PAR01==4)                                        

	MsgInfo ( "Boleto do Banco em Desenvolvimento !!", "Layout Em Construção" )

EndIf
        

Return()