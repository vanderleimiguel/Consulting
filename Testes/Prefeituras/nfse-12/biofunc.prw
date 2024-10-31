#include "rwmake.ch"     

User Function DV_BB(_cPar)
Local i := 0
SetPrvt("i, nModulo , cChar, nMult,X,Y")

nModulo := 0
cStr := alltrim(SE1-> E1_NUMBCO)
X := Iif( X==Nil , 2 , X)
Y := Iif( Y==Nil , 9 , Y)
nMult := Y
cStr := alltrim(cStr)
for i := len(cStr) to 1 step -1
	cChar := substr(cStr, i ,1)
	if isAlpha( cChar )
		Help( " " , 1 , "ONLYNUM" )
		return .F.
	end
	nModulo := nModulo + (val( cChar ) * nMult)
	nMult := iif( nMult == X, 9 , nMult-1 )
next
nRest := nModulo % 11
nRest := iif(nRest<10,nRest,99)
//nRest := iif(nRest == 0 .or. nRest == 1, 0, 11 - nRest)
//alert(cStr+" - "+str(nRest,2))
if nRest==99
	if empty(_cPar)
		Return( "X" )
	else
		Return( "0" )
	endif
else
	Return( str(nRest,1) )
endif



User Function DV_BD(_cPar)
Local i := 0
SetPrvt("nModulo , cChar, nMult,X,Y")

nModulo := 0
cStr := alltrim(SE1-> E1_NUMBCO)
X := Iif( X==Nil , 2 , X)
Y := Iif( Y==Nil , 9 , Y)
nMult := Y
cStr := alltrim(cStr)
for i := len(cStr) to 1 step -1
	cChar := substr(cStr, i ,1)
	if isAlpha( cChar )
		Help( " " , 1 , "ONLYNUM" )
		return .F.
	end
	nModulo := nModulo + (val( cChar ) * nMult)
	nMult := iif( nMult == X, 9 , nMult-1 )
next
nRest := nModulo % 11
nRest := iif(nRest<10,nRest,99)
//nRest := iif(nRest == 0 .or. nRest == 1, 0, 11 - nRest)
//alert(cStr+" - "+str(nRest,2))
if nRest==99
	if empty(_cPar)
		Return( "P" )
	else
		Return( "0" )
	endif
else
	Return( str(nRest,1) )
endif



User Function DV_BITAU(_cPar)
Local L,D,P	:= 0
Local B     := .F.
L := Len(_cPar)
B := .T.
D := 0
While L > 0
	P := Val(SubStr(_cPar, L, 1))
	If (B)
		P := P * 2
		If P > 9
			P := P - 9
		End
	End
	D := D + P
	L := L - 1
	B := !B
End
D := 10 - (Mod(D,10))
If D = 10
	D := 0
End
Return(D)



User Function DV_BS(_cPar)
Local i := 0
SetPrvt("nModulo , cChar, nMult,X,Y")

nModulo := 0
cStr := alltrim("09"+STRZERO(VAL(SE1->E1_NUMBCO),11))
cStr := "33715113353"
X := Iif( X==Nil , 2 , X)
Y := Iif( Y==Nil , 9 , Y)
nMult := Y
cStr := alltrim(cStr)
for i := len(cStr) to 1 step -1
	cChar := substr(cStr, i ,1)
	if isAlpha( cChar )
		Help( " " , 1 , "ONLYNUM" )
		return .F.
	end
	nModulo := nModulo + (val( cChar ) * nMult)
	nMult := iif( nMult == X, 9 , nMult-1 )
next
nRest := nModulo % 11
nRest := iif(nRest<10,nRest,99)
//nRest := iif(nRest == 0 .or. nRest == 1, 0, 11 - nRest)
//alert(cStr+" - "+str(nRest,2))
if nRest==99
	if empty(_cPar)
		Return( "0" )
	else
		Return( "0" )
	endif
else
	Return( str(nRest,1) )
endif



User Function seq(x)
          
LOCAL seq:=x

	DbSelectArea("SEE")												
	DbSetOrder(1)
	DbSeek(xFilial("SEE")+SEE->EE_CODIGO+SEE->EE_AGENCIA+SEE->EE_CONTA)
           
	IF (X == "00001" .AND. SEE->EE_CODCOBE != "2 ")
	    RecLock("SEE",.F.)
		SEE->EE_NUMBCO := "00001" 
		SEE->EE_CODCOBE:= "2 "
	  	MsUnlock()         
	 	Return SEE->EE_NUMBCO  
	ELSE 
		RecLock("SEE",.F.)
		SEE->EE_NUMBCO := STRZERO(VAL(SEE->EE_NUMBCO)+1,5)
		SEE->EE_CODCOBE:= "1 "
	  	MsUnlock()
	  	Return SEE->EE_NUMBCO	
	ENDIF
	



User Function TOT_TIT(_cPar)
local nAbat:=0
Local aPCC := {}
Local nRet := 0
if empty(_cPar)

	nAbat:= SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA)
	/*--------------------------------------------------------------------------\
	| DTM | IT Sofware Solutions                                    31/07/2018  |
	| Autor: Rodrigo Mello                                                      |
	| Objetivo: Adicionar valores de retencao do PCC Baixa                      |
	\--------------------------------------------------------------------------*/
	aPCC := newMinPcc(DataValida(SE1->E1_VENCTO,.T.), SE1->E1_SALDO, SE1->E1_NATUREZ, "R", SE1->(E1_CLIENTE + E1_LOJA))
	nAbat += aPCC[2] // PIS - Baixa
	nAbat += aPCC[3] // COF - Baixa
	nAbat += aPCC[4] // CSL - Baixa
	nRet := SE1->(((E1_VALOR-nAbat)-E1_DECRESC)+E1_ACRESC)
	/*--------------------------------------------------------------------------*/ 
	//return(STRZERO(( SE1->(((E1_VALOR-nAbat)-E1_DECRESC)+E1_ACRESC)  )*100,13))
else
	nAbat:= SomaAbat(TRB->E1_PREFIXO, TRB->E1_NUM, TRB->E1_PARCELA,"R", 1,, TRB->E1_CLIENTE,TRB->E1_LOJA)
	/*--------------------------------------------------------------------------\
	| DTM | IT Sofware Solutions                                    31/07/2018  |
	| Autor: Rodrigo Mello                                                      |
	| Objetivo: Adicionar valores de retencao do PCC Baixa                      |
	\--------------------------------------------------------------------------*/
	aPCC := newMinPcc(DataValida(TRB->E1_VENCTO,.T.), TRB->E1_SALDO, TRB->E1_NATUREZ, "R", TRB->(E1_CLIENTE + E1_LOJA))
	nAbat += aPCC[2] // PIS - Baixa
	nAbat += aPCC[3] // COF - Baixa
	nAbat += aPCC[4] // CSL - Baixa
	nRet := TRB->(((E1_VALOR-nAbat)-E1_DECRESC)+E1_ACRESC)
	/*--------------------------------------------------------------------------*/ 
	//return(STRZERO(( TRB->(((E1_VALOR-nAbat)-E1_DECRESC)+E1_ACRESC)  )*100,13))
endif
//return(STRZERO((SE1->(E1_SALDO-E1_IRRF-((E1_PIS+E1_COFINS+E1_CSLL)-(E1_SABTPIS+E1_SABTCOF+E1_SABTCSL))))*100,13))
Return Strzero(nRet*100,13)

User Function TOT_DESC()
local nAbat:=0
nAbat:= SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA,"R", 1,, SE1->E1_CLIENTE,SE1->E1_LOJA)
return(STRZERO((SE1->((  ((E1_VALOR-nAbat)-E1_DECRESC)+E1_ACRESC  )*(E1_DESCFIN/100)))*100,13))
//return(STRZERO((SE1->((E1_SALDO-E1_IRRF-((E1_PIS+E1_COFINS+E1_CSLL)-(E1_SABTPIS+E1_SABTCOF+E1_SABTCSL)))*(E1_DESCFIN/100)))*100,13))

User Function TOT_JUR()
//return(STRZERO(((SE1->E1_SALDO*0.05)/30)*100,13))
return(STRZERO(if(trim(SEE->EE_INSTPRI)=="00",0,((SE1->E1_SALDO*0.05)/30)*100),13))

User Function TOT_PV()
Local _nscI := 0
// n --> Variavel publica que diz a posicao do cursor no grid (rowpos)

if aCols[n,08]=='702' .and. aCols[n,06]==0 .and. len(aCols)>1
	_nscTot:=0
	_bscErro:=.F.
//	alert(str(len(aCols),3)+" - "+str(len(aCols[01]),3))
	for _nscI := 1 to len(aCols)
		if aCols[_nscI,len(aCols[01])]==.F.
			if aCols[_nscI,08]=='701'
				_nscTot+=aCols[_nscI,07]
			endif
			if aCols[_nscI,08]!='701' .and. aCols[_nscI,08]!='702' .and. aCols[_nscI,08]!='703'
				_bscErro:=.T.
			endif
		endif
	next
	if _nscTot>0
		if _bscErro
			Alert('TES NAO COMPATIVEL COM ANALISE(S), CORRIJA')
			return(.F.)
		endif		
		aCols[n,06]:=_nscTot
		M->C6_PRCVEN:=_nscTot
		A410MultT()
		A410Zera()
	endif
endif
return(.T.)


***************************************************************************

***************************************************************************
USER FUNCTION CGC(cCGC,cPessoa)
LOCAL nDigito1 := nDigito2 := nDigito4 := 0, nVez := 1, nConta, nResto, nDigito
IF cPessoa=="J"
   FOR nConta := 1 TO LEN(cCGC)-2
      IF AT(SUBS(cCGC,nConta,1),"/-.") == 0
         nDigito1 := nDigito1 + VAL(SUBS(cCGC,nConta,1)) * (IF(nVez<5,6,14)-nVez)
         nDigito4 := nDigito4 + VAL(SUBS(cCGC,nConta,1)) * (IF(nVez<6,7,15)-nVez)
         nVez ++
      ENDIF
   NEXT
   nResto   := nDigito1 - (INT(nDigito1/11)*11)
   nDigito  := IF(nResto < 2,0,11-nResto)
   nDigito4 := nDigito4 + 2 * nDigito
   nResto   := nDigito4 - (INT(nDigito4/11)*11)
   nDigito  := VAL(STR(nDigito,1)+STR(IF(nResto < 2,0,11-nResto),1))
   IF nDigito <> VAL(SUBS(cCGC,LEN(cCGC)-1,2))
      RETURN(.F.)
   ELSE
      RETURN(.T.)
   ENDIF
ELSE  // PESSOA FISICA, VERIFICA CPF
   FOR nConta := 1 TO LEN(cCGC)-2
      IF AT(SUBS(cCGC,nConta,1),"/-.") == 0
         nDigito1 := nDigito1+(11-nVez)*VAL(SUBS(cCGC,nConta,1))
         nDigito2 := nDigito2+(12-nVez)*VAL(SUBS(cCGC,nConta,1))
         nVez ++
      ENDIF
   NEXT
   nResto   := nDigito1-(INT(nDigito1/11)*11)
   nDigito  := IF(nResto < 2,0,11-nResto)
   nDigito2 := nDigito2 + 2 * nDigito
   nResto   := nDigito2 - (INT(nDigito2/11)*11)
   nDigito  := VAL(STR(nDigito,1)+STR(IF(nResto<2,0,11-nResto),1))
   IF nDigito <> VAL(SUBS(cCGC,LEN(cCGC)-1,2))
      RETURN(.F.)
   ELSE
      RETURN(.T.)
   ENDIF
ENDIF
***************************************************************************

User Function zzNomus(__cPC,__lPar)
Local __cUsu,__cRet,__cCC,__cAprv

__lPar  := if(empty(__lPar),.f.,.t.)
__cUsu  := posicione("SC1",6,xFilial("SC1")+__cPC,"C1_USER")
if empty(trim(__cUsu))
	__cCC  := posicione("SC7",1,xFilial("SC7")+__cPC,"C7_CC")
	__cUsu := posicione("SC7",1,xFilial("SC7")+__cPC,"C7_USER")
else
	__cCC := posicione("SC1",6,xFilial("SC1")+__cPC,"C1_CC")
endif
//__cCC   := if(empty(trim(__cUsu)),posicione("SC7",1,xFilial("SC1")+__cPC,"C7_CC"),posicione("SC1",6,xFilial("SC1")+__cPC,"C1_CC"))
__cAprv := posicione("SZ8",1,xFilial("SZ8")+"A"+__cCC,"Z8_USUARIO")

if __lPar

	if empty(trim(__cUsu))
		__cRet := space(06)
	else
		__cRet := trim(__cAprv)
	endif

else
	if empty(trim(__cUsu))
		__cRet := padr("-x-",40)
	else
	//	__cRet := trim(__aUsu[ascan(__aUsu,{|a| a[01][01]==__cUsu})][01][04])
		__cRet := padr(trim(UsrFullName(__cUsu)),30)
//		__cRet := left(__cRet,39)
//		if trim(RetCodUsr()) == trim(__cAprv)
//			__cRet:= __cRet + __cCC	//"!"+space(03)+__cAprv
//		else
//			__cRet:= __cRet + "*"	//__cCC	//"x"+space(03)+__cAprv
//		endif
	endif
endif

Return __cRet

User Function SZ8A001()
axCadastro("SZ8","Amarracao Aprovador x C.Custo",".T.",".T.")
return(.T.)

User Function zzatucot()
Local __cUsu,__cRet,__cCC,__cAprv

dbSelectarea("SCR")
dbSetOrder(1)
dbGotop()
while ! eof()

	__cUsu  := posicione("SC1",6,xFilial("SC1")+trim(CR_NUM),"C1_USER")
	if empty(trim(__cUsu))
		__cCC  := posicione("SC7",1,xFilial("SC7")+trim(CR_NUM),"C7_CC")
		__cUsu := posicione("SC7",1,xFilial("SC7")+trim(CR_NUM),"C7_USER")
	else
		__cCC := posicione("SC1",6,xFilial("SC1")+trim(CR_NUM),"C1_CC")
	endif
	//__cCC   := if(empty(trim(__cUsu)),posicione("SC7",1,xFilial("SC1")+__cPC,"C7_CC"),posicione("SC1",6,xFilial("SC1")+__cPC,"C1_CC"))
	__cAprv := posicione("SZ8",1,xFilial("SZ8")+"A"+__cCC,"Z8_USUARIO")

	if empty(trim(__cUsu))
		__cRet := space(06)
	else
		__cRet:= trim(__cAprv)
	endif
	
	RecLock("SCR",.F.)
	SCR->CR_ZZFILTR := __cRet
	MsUnLock()

	dbskip()
	
enddo

alert("Atualizaçao Concluida !")

Return(.t.)

User Function zzaturef()

dbSelectarea("SC1")
dbSetOrder(1)
dbGotop()
while ! eof()
	
	if empty(trim(SC1->C1_ZZREF))
		RecLock("SC1",.F.)
		SC1->C1_ZZREF := posicione("SB1",1,xFilial("SB1")+SC1->C1_PRODUTO,"B1_ZZREF")
		MsUnLock()
	endif

	dbskip()
	
enddo

alert("OK REF!")

Return(.t.)

//User Function Grafico()

//winexec("c:\project1.exe",1)
//return(.t.)
