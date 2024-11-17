#include "protheus.ch"
/*/{Protheus.doc} GESTFIN5
	Realiza Baixa do titulo
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/

user function GESTFIN5(cTmp)
	MsgRun("Realizando baixas ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV := (cTmp)->(getArea())
	local cBkp := CFILANT
	local nOpc as numeric
	// local cHistor as character
	local aPar as array
	Local nRecSE1 as numeric

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Baixar Marcados","Baixar Posicionado","Cancelar"},2)

	if nOpc == 3
		return
	endif

	if nOpc == 1
		(cTmp)->(dbSetOrder(2))
		if (cTmp)->(dbSeek("T"))
			while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
				nRecSE1	:= 0
				SE1->( dbGoto((cTmp)->XX_RECNO) )
				if SE1->E1_SALDO > 0
					fnBaixar(cTmp)
					//Efetua conciliacao
					nRecSE1	:= (cTmp)->XX_RECNO
					U_XConcilia(nRecSE1)
				endif
				(cTmp)->(dbSkip())
			end
		endif
	else
		SE1->( dbGoto((cTmp)->XX_RECNO) )
		if SE1->E1_SALDO == 0
			Alert("titulo ja baixado")
			return
		else
			fnBaixar(cTmp)
			//Efetua conciliacao
			nRecSE1	:= (cTmp)->XX_RECNO
			U_XConcilia(nRecSE1)
		endif
	endif

	CFILANT := cBkp ; FwFreeArray(aPar)
	(cTmp)->(restArea(aSv))
return

static function fnBaixar(cTmp)
	if Type("cCadastro") != "U"
		cBkp := cCadastro
	endif
	SetFunName("U_GESTFIN5")

	ALTERA := .F.

	FINA070(,3,.T.)
	fnUpdGrid(cTmp)

	SetFunName("GESTFIN")
	if cBkp != nil
		cCadastro := cBkp
	endif
return

static function fnUpdGrid(cTmp)
	local nNumFld := SE1->(FCount())
	local nIndex as numeric
	local cFld as character
	Reclock(cTmp,.F.)
	for nIndex := 1 to nNumFld
		cFld := SE1->(Field(nIndex))
		if (cTmp)->( &cFld != SE1->&cFld )
			(cTmp)->&cFld := SE1->&cFld
		endif
	next nIndex
	(cTmp)->(msUnlock())
return
