#include "totvs.ch"
/*/{Protheus.doc} GESTFINC
	adiciona as funcionalidades de incluir e visualizar titulo
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFINC(cTmp)
	local cMsg as character
	local cFld as character
	local cBkp as character
	local nOpc as numeric
	local nInd as numeric
	local nOldRec := SE1->( Recno() )

	cMsg := "Escolha a opção desejada"+CRLF
	cMsg += ""
	nOpc := Aviso("Central 4Fin - Titulos",cMsg,{"Incluir Titulo","Visualizar Titulo","Cancelar"},2)

	if nOpc == 1
		if Type("cCadastro") != "U"
			cBkp := cCadastro
		endif
		SetFunName("U_GESTFINC")

		FINA040(,3)

		if nOldRec != SE1->( Recno() )
			Reclock(cTmp,.T.)
			for nInd := 1 to SE1->(FCount())
				cFld := SE1->( Field(nInd) )
				(cTmp)->&cFld := SE1->&cFld
			next nInd
			(cTmp)->( msUnlock() )
		endif

		SetFunName("GESTFIN")
		if cBkp != nil
			cCadastro := cBkp
		endif
	elseif nOpc == 2
		SE1->( dbGoto((cTmp)->XX_RECNO) )
		AxVisual("SE1",(cTmp)->XX_RECNO,2)
	endif
return
