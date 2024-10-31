#include "totvs.ch"
/*/{Protheus.doc} GESTFINB
	Posicao cliente - executa botoes
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
	@obs copia da Fc010Cli (FINC010.prx)
/*/
user function GESTFINB(cTmp,nTipo)
	local aSave		:= SA1->( getArea() )
	local cBkp		:= CFILANT
	local cCadBkp	:= cCadastro
	local aBackup	:= {}
	local nInd		as numeric
	local oX1		as object
	local cCliente	:= (cTmp)->( E1_CLIENTE+E1_LOJA )
	local cAliAtu	:= Alias()
	local nOrdAtu	:= IndexOrd()
	local nRecAtu	:= Recno()
	local aParam	:= {}
	local aTemps	:= {}

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

		for nInd := 1 to Len(oX1:getGroup("FIC010")[2])
			aAdd(aParam,&("MV_PAR"+Strzero(nInd,2)))
		next nInd

		Private nCasas  := GetMv("MV_CENT")
		Private aSelFil	:= {}
		Private aTmpFil	:= {}
		Private aRotina := FwLoadMenuDef("FINC010")

		If FWModeAccess("SA1",3) == "C"
			If MV_PAR17 == 1
				If  FindFunction("AdmSelecFil")
					AdmSelecFil("FIC010",17,.F.,@aSelFil,"SA1",(FwModeAccess("SA1",1) == "E"),(FwModeAccess("SA1",2) == "E"),cFilant)
				Else
					aSelFil := AdmGetFil(.F.,.F.,"SA1")
				Endif
			Endif
			If Empty(aSelFil)
				Aadd(aSelFil,cFilant)
			Endif
		Else
			Aadd(aSelFil,cFilAnt)
		Endif

		do case
			case nTipo == 1
				Fc010Brow(nTipo,aTemps,aParam,.T.,{"","","",""})
			case nTipo == 2
				Fc010Brow(nTipo,aTemps,aParam,.T.,{"","","",""})
			case nTipo == 3
				Fc010Brow(nTipo,aTemps,aParam,.T.,{"","","",""})
			case nTipo == 4
				Fc010Brow(nTipo,aTemps,aParam,.T.,{"","","",""})
			case nTipo == 5
				cCadastro += " - Referencias"
				Mata030Ref("SA1",SA1->(Recno()),2)
		endcase

		(aTail(aTemps)[1])->(dbCloseArea())

		FC010QFil(2)
		FwFreeArray(aParam) ; FwFreeArray(aTmpFil) ; FwFreeArray(aSelFil)

		aEval(aBackup,{|x,y| &("MV_PAR"+Strzero(y,2)) := x })
		FreeObj(oX1) ; FwFreeArray(aBackup) ; FwFreeArray(aTemps)
	endif

	cCadastro := cCadBkp
	CFILANT := cBkp
	SA1->( restArea(aSave) )

	dbSelectArea(cAliAtu)
	dbSetOrder(nOrdAtu)
	dbGoto(nRecAtu)
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
