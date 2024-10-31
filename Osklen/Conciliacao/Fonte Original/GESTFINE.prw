#include "totvs.ch"
#include 'fwmvcdef.ch'
/*/{Protheus.doc} GESTFINE
	permite realizar a compensacao dos titulos marcados
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFINE(cTmp)
	if ApMsgYesNo("Deseja compensar os titulos marcados?")
		MsgRun("Compensando titulos marcados ...","Aguarde",{|| fnExec(cTmp) })
	endif
return

static function fnExec(cTmp)
	local aSV  := (cTmp)->(getArea())
	local aRA  := {}
	local aNCC := {}
	local aTit := {}
	local lOk  := .T.
	local aBkp as array
	local oSx1 as object

	local aTxMoeda := {}
	local nSldComp := nil
	local nTaxaCM := 0
	local lConsdAbat := .F.
	local lContabiliza
	local lAglutina
	local lDigita

	(cTmp)->(dbSetOrder(2))

	if (cTmp)->( dbSeek("T") )
		while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
			do case
				case Alltrim((cTmp)->E1_TIPO) == "RA"
					aAdd(aRA,(cTmp)->XX_RECNO)
				case Alltrim((cTmp)->E1_TIPO) == "NCC"
					aAdd(aNCC,(cTmp)->XX_RECNO)
				case Alltrim((cTmp)->E1_TIPO) $ "NF"
					aAdd(aTit,(cTmp)->XX_RECNO)
			endcase
			(cTmp)->(dbSkip())
		end
	endif

	do case
		case Len(aRA) > 0 .and. Len(aNCC) > 0
			Alert("nao e possivel marcar titulos NCC e RA na mesma compensacao")
			lOk := .F.
		case Len(aRA) == 0 .and. Len(aNCC) == 0
			Alert("selecione as NCCs ou RAs para realizar a compensacao")
			lOk := .F.
		case Len(aTit) == 0
			Alert("selecione os titulos que serao compensados")
			lOk := .F.
	endcase

	if lOk
		aBkp := {}
		oSx1 := FwSx1Util():New()
		oSx1:addGroup("AFI340")
		oSx1:searchGroup()
		aEval(oSx1:getGroup("AFI340")[2],{|x,y| aAdd(aBkp,&("MV_PAR"+Strzero(y,2))) })

		Pergunte("AFI340",.F.)
		MV_PAR11 := 2 ; MV_PAR08 := 2 ; MV_PAR09 := 2

		lContabiliza := MV_PAR11 == 1
		lAglutina := MV_PAR08 == 1
		lDigita := MV_PAR09 == 1

		if MaIntBxCR(3,aTit,nil,Iif(Len(aNCC)>0,aNCC,aRA),nil,{lContabiliza,lAglutina,lDigita,.F.,.F.,.F.},nil,{},nil,nil,nSldComp,nil,nil,nil,nTaxaCM,aTxMoeda,lConsdAbat)
			FwAlertSuccess("Os titulos selecionados foram compensados","Titulos Compensados")
		else
			Alert("Nao foi possivel realizar a compensacao entre os titulos marcados")
			MostraErro()
		endif

		if Len(aBkp) > 0
			aEval(aBkp,{|x,y| &("MV_PAR"+Strzero(y,2)) := x })
		endif
		FwFreeArray(aBkp) ; FreeObj(oSx1)
	endif

	(cTmp)->(restArea(aSv))
	FwFreeArray(aRA) ; FwFreeArray(aNCC) ; FwFreeArray(aTit)
return
