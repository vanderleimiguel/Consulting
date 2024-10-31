#include "totvs.ch"
/*/{Protheus.doc} GESTFINH
	permite contabilizar
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFINH(cTmp)
	local aLPs		:= {"500","501"}
	local cArquivo	as character
	local cPadrao	as character
	local cLote		:= "008850"
	local lUsaFlag	:= SuperGetMV("MV_CTBFLAG",.T.,.F.)
	local cBkp		:= cCadastro
	local lPadrao	as logical
	local lDigita	:= .T.
	local nIdx		as numeric
	local nHdlPrv	as numeric
	local nTotal	as numeric
	local dDtLanc	as date
	local aFlagCTB	:= {}

	cCadastro += " - Contabilizacao"

	SE1->( dbGoto((cTmp)->XX_RECNO) )

	for nIdx := 1 to Len(aLPs)
		cPadrao := aLPs[nIdx]
		lPadrao := VerPadrao(cPadrao)

		if lPadrao
			if cPadrao $ "500/501" .and. (cTmp)->E1_LA == "S"
				loop
			endif

			nHdlPrv := HeadProva(cLote,"FINA040",__cUserid,@cArquivo)
			if nHdlPrv > 0
				nTotal := 0

				if lUsaFlag
					aAdd(aFlagCTB,{"E1_LA","S","SE1",SE1->( Recno() ),0,0,0})
				endif

				nTotal += DetProva( nHdlPrv, cPadrao, "FINA040", cLote, /*nLinha*/, /*lExecuta*/,;
									/*cCriterio*/, /*lRateio*/, /*cChaveBusca*/, /*aCT5*/,;
									/*lPosiciona*/, @aFlagCTB, /*aTabRecOri*/, /*aDadosProva*/ )

				if nTotal > 0
					dDtLanc := SE1->E1_EMISSAO

					RodaProva(nHdlPrv,nTotal)
					cA100Incl(cArquivo, nHdlPrv, 3 /*nOpcx*/, cLote, lDigita, .F. /*lAglut*/,;
							/*cOnLine*/, dDtLanc, /*dReproc*/, @aFlagCTB, /*aDadosProva*/, {} )

					aFlagCTB := {}

					if ! lUsaFlag
						Reclock("SE1") ; Reclock(cTmp)
						SE1->E1_LA := (cTmp)->E1_LA := "S"
						SE1->(MsUnlock()) ; (cTmp)->(MsUnlock())
					endif
				endif
			endif
		endif
	next nIdx

	cCadastro := cBkp

	FwAlertSuccess("Contabilizacao finalizada com sucesso","Contabilizacao")
return
