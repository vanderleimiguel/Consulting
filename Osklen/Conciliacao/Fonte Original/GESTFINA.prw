#include "totvs.ch"
/*/{Protheus.doc} GESTFINA
	Posicao cliente
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
	@obs copia da Fc010Cli (FINC010.prx)
/*/
user function GESTFINA(cTmp)
	local aSave		:= SA1->( getArea() )
	local cBkp		:= CFILANT
	local aBackup	:= {}
	local nInd		as numeric
	local oX1		as object
	local cCliente	:= (cTmp)->( E1_CLIENTE+E1_LOJA )
	local cAliAtu	:= Alias()
	local nOrdAtu	:= IndexOrd()
	local nRecAtu	:= Recno()

	SA1->( dbSetOrder(1) )
	if SA1->( dbSeek(xFilial()+cCliente) )
		oX1 := FwSx1Util():new()
		oX1:addGroup("FIC010")
		oX1:searchGroup()

		for nInd := 1 to Len(oX1:getGroup("FIC010")[2])
			aAdd(aBackup,&("MV_PAR"+Strzero(nInd,2)))
		next nInd

		Pergunte("FIC010",.F.)
		setPergs()
		fnExec()

		aEval(aBackup,{|x,y| &("MV_PAR"+Strzero(y,2)) := x })
		FreeObj(oX1) ; FwFreeArray(aBackup)
	endif

	dbSelectArea(cAliAtu)
	dbSetOrder(nOrdAtu)
	dbGoto(nRecAtu)

	CFILANT := cBkp
	SA1->( restArea(aSave) )
return

static function fnExec()
	local oDlg		as object
	local cCadastro := "Consulta Posicao Clientes"
	local cCgc		:= RetTitle("A1_CGC")
	local cMoeda    := ""
	local nMcusto   := Iif(SA1->A1_MOEDALC > 0, SA1->A1_MOEDALC, Val(GetMv("MV_MCUSTO")))
	local aSavAhead := If(Type("aHeader")=="A",aHeader,{})
	local aSavAcol  := If(Type("aCols")=="A",aCols,{})
	local nSavN     := If(Type("N")=="N",n,0)
	local aCols     := {}
	local aHeader   := {}
	local cSalFin	:= ""
	local cLcFin	:= ""
	local cTelefone := Alltrim(SA1->A1_DDI)+" "+Alltrim(SA1->A1_DDD)+" "+Alltrim(SA1->A1_TEL)
	local dPRICOM   := CRIAVAR("A1_PRICOM",.F.)
	local dULTCOM   := CRIAVAR("A1_ULTCOM",.F.)
	local dDTULCHQ  := CRIAVAR("A1_DTULCHQ",.F.)
	local dDTULTIT  := CRIAVAR("A1_DTULTIT",.F.)
	local cRISCO    := ""
	local nLC       := 0
	local nSALDUP   := 0
	local nSALDUPM  := 0
	local nLCFIN    := 0
	local nMATR     := 0
	local nSALFIN   := 0
	local nSALFINM  := 0
	local nMETR     := 0
	local nMCOMPRA  := 0
	local nMSALDO   := 0
	local nCHQDEVO  := 0
	local nTITPROT  := 0
	local oNomCli	:= Nil
	local oNumTel	:= Nil
	local oNumCGC	:= Nil

	cLcFin	:= GetSx3Cache("A1_LCFIN","X3_TITULO")
	cSalFin	:= GetSx3Cache("A1_SALFIN","X3_TITULO")
	cMoeda	:= " "+Pad(Getmv("MV_SIMB"+Alltrim(STR(nMCusto))),4)

	if MV_PAR13 == 1
		nLC      := SA1->A1_LC
		dPRICOM  := SA1->A1_PRICOM
		nSALDUP  := SA1->A1_SALDUP
		nSALDUPM := SA1->A1_SALDUPM
		dULTCOM  := SA1->A1_ULTCOM
		nLCFIN   := SA1->A1_LCFIN
		nMATR    := SA1->A1_MATR
		nSALFIN  := SA1->A1_SALFIN
		nSALFINM := SA1->A1_SALFINM
		nMETR    := SA1->A1_METR
		nMCOMPRA := SA1->A1_MCOMPRA
		cRISCO   := SA1->A1_RISCO
		nMSALDO  := SA1->A1_MSALDO
		nCHQDEVO := SA1->A1_CHQDEVO
		dDTULCHQ := SA1->A1_DTULCHQ
		nTITPROT := SA1->A1_TITPROT
		dDTULTIT := SA1->A1_DTULTIT
	else
		Fc010Loja(@nLC,@dPRICOM,@nSALDUP,@nSALDUPM,@dULTCOM,@nLCFIN,@nMATR,@nSALFIN,@nSALFINM,@nMETR,@nMCOMPRA,@cRISCO,@nMSALDO,@nCHQDEVO,@dDTULCHQ,@nTITPROT,@dDTULTIT)
	endif

	aHeader	:= {"Descricao","Valor","Valores em"+RTrim(cMoeda)," ","Descricao","Consulta Posicao"}

	Aadd(aCols,{"Limite de Credito",TRansform(Round(Noround(xMoeda(nLC, nMcusto, 1,dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LC",14,1)),;
	TRansform(nLC,PesqPict("SA1","A1_LC",14,nMCusto)),;
	" ","Primeira Compra",SPACE(07)+DtoC(dPRICOM)})

	//saldo # ultima compra
	Aadd(aCols,{"Saldo Historico",TRansform(nSALDUP,PesqPict("SA1","A1_SALDUP",14,1) ),;
	TRansform(nSALDUPM,PesqPict("SA1","A1_SALDUPM",14,nMcusto)),;
	" ","Ultima Compra",SPACE(07)+DtoC(dULTCOM)})

	//limite de credito secundario # maior atraso
	Aadd(aCols,{cLcFin,TRansform(Round(Noround(xMoeda(nLCFIN,nMcusto,1,dDatabase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_LCFIN",14,1)),;
	TRansform(nLCFIN,PesqPict("SA1","A1_LCFIN",14,nMcusto)),;
	" ","Maior Atraso",Transform(nMATR,PesqPict("SA1","A1_MATR",14))})

	//saldo do limite de credito secundario $ media de atraso
	Aadd(aCols,{cSalFin,TRansform(nSALFIN,PesqPict("SA1","A1_SALFIN",14,1)),;
	TRansform(nSALFINM,PesqPict("SA1","A1_SALFINM",14,nMcusto)),;
	" ","Media de Atraso",PADC(STR(nMETR,7,2),22)})

	//maior compra # grau de risco
	Aadd(aCols,{"Maior Compra",;
	TRansform(Round(Noround(xMoeda(nMCOMPRA, nMcusto ,1, dDataBase,MsDecimais(1)+1),2),MsDecimais(1)),PesqPict("SA1","A1_MCOMPRA",14,1) ) ,;
	TRansform(nMCOMPRA,PesqPict("SA1","A1_MCOMPRA",14,nMcusto)),;
	" ","Grau de Risco",SPACE(25)+cRISCO})

	//maior saldo
	Aadd(aCols,{"Maior saldo",;
	TRansform(Round(Noround(xMoeda(nMSALDO, nMcusto ,1, dDataBase,MsDecimais(1)+1 ),2),MsDecimais(1)),PesqPict("SA1","A1_MSALDO",14,1)),;
	TRansform(nMSALDO,PesqPict("SA1","A1_MSALDO",14,nMcusto)),;
	" "," ",""})

	DEFINE MSDIALOG oDlg FROM 09,0 TO 30,67.5 TITLE cCadastro OF oMainWnd

	@ 001,002 TO 043, 267 OF oDlg	PIXEL
	@ 130,002 TO 154, 114 OF oDlg	PIXEL
	@ 130,121 TO 154, 267 OF oDlg	PIXEL

	@ 004,005 SAY "Codigo"		SIZE 025,07          OF oDlg PIXEL
	@ 012,004 MSGET SA1->A1_COD	SIZE 070,09 WHEN .F. OF oDlg PIXEL

	if MV_PAR13 == 1  //Considera loja
		@ 004,077 SAY "Loja"		 SIZE 020,07          OF oDlg PIXEL
		@ 012,077 MSGET SA1->A1_LOJA SIZE 021,09 WHEN .F. OF oDlg PIXEL
	endif

	@ 004,100 SAY "Nome" 						SIZE 025,07 OF oDlg PIXEL
	@ 012,100 MSGET oNomCli VAR SA1->A1_NOME	SIZE 150,09 OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_NOME')

	@ 023,005 SAY cCGC    SIZE 025,07 OF oDlg PIXEL
	@ 030,004 MSGET oNumCGC Var SA1->A1_CGC	SIZE 070,09 PICTURE StrTran(PicPes(SA1->A1_PESSOA),"%C","") OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_CGC')

	@ 023,077 SAY "Telefone" 					SIZE 025,07 OF oDlg PIXEL
	@ 030,077 MSGET oNumTel Var cTelefone	SIZE 060,09 OF oDlg PIXEL When .F. OFUSCATED RetGlbLGPD('A1_TEL')

	@ 023,141 SAY RetTitle("A1_VENCLC")  SIZE 035,07 OF oDlg PIXEL
	@ 030,141 MSGET SA1->A1_VENCLC       SIZE 060,09 WHEN .F. OF oDlg PIXEL

	@ 023,206 SAY "Vendedor" SIZE 035,07 OF oDlg PIXEL
	@ 030,206 MSGET SA1->A1_VEND  	 SIZE 053,09 WHEN .F. OF oDlg PIXEL

	oLbx := RDListBox(3.5, .42, 264, 70, aCols, aHeader,{38,51,51,11,50,63})

	@ 124,002 SAY "Cheques Devolvidos"	SIZE 061,07 OF oDlg PIXEL
	@ 124,121 SAY "Titulos Protestados" SIZE 061,07 OF oDlg PIXEL

	@ 133,005 SAY "Quantidade"		 SIZE 034,07 OF oDlg PIXEL
	@ 133,045 SAY "Ultimo Devolvido" SIZE 066,07 OF oDlg PIXEL
	@ 133,126 SAY "Quantidade"		 SIZE 034,07 OF oDlg PIXEL
	@ 133,163 SAY "Ultimo Protesto"  SIZE 076,07 OF oDlg PIXEL

	@ 141,006 MSGET nCHQDEVO SIZE 024,08 WHEN .F. OF oDlg PIXEL
	@ 141,045 MSGET dDTULCHQ SIZE 050,08 WHEN .F. OF oDlg PIXEL
	@ 141,126 MSGET nTITPROT SIZE 024,08 WHEN .F. OF oDlg PIXEL
	@ 141,163 MSGET dDTULTIT SIZE 050,08 WHEN .F. OF oDlg PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

	aHeader := aSavAHead
	aCols   := aSavaCol
	N       := nSavN
return

static function setPergs()
	local nT := TamSx3("E1_PREFIXO")[1]
	MV_PAR01 := Ctod("01/01/1980")
	MV_PAR02 := Ctod("31/12/2049")
	MV_PAR03 := Ctod("01/01/1980")
	MV_PAR04 := Ctod("31/12/2049")
	MV_PAR05 := 1
	MV_PAR06 := Space(nT)
	MV_PAR07 := Replicate("Z",nT)
	MV_PAR08 := 1
	MV_PAR09 := 1
	MV_PAR00 := 1
	MV_PAR11 := 1
	MV_PAR12 := 1
	MV_PAR13 := 1
	MV_PAR14 := 1
	MV_PAR15 := 1
	MV_PAR16 := 1
	MV_PAR17 := 2
	MV_PAR18 := 1
return
