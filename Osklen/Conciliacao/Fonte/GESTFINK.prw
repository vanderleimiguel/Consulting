#include "protheus.ch"

/*/{Protheus.doc} GESTFINK
	Realiza Cancelamento da Baixa do titulo
	@type function
	@version 1.0
	@author Wagner Neves
	@since 10/04/2023
/*/
user function GESTFINK(cTmp)
	MsgRun("Realizando cancelamento de baixas ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV := (cTmp)->(getArea())
	local cBkp := CFILANT
	local nOpc as numeric
	// local cHistor as character
	local aPar as array
	Local nRecSE1 as numeric

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Cancela Baixa Marcaddo","Cancela Baixa Posicionado","Cancelar"},2)

	if nOpc == 3
		return
	endif

	if nOpc == 1
		(cTmp)->(dbSetOrder(2))
		if (cTmp)->(dbSeek("T"))
			while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
				nRecSE1	:= 0
				SE1->( dbGoto((cTmp)->XX_RECNO) )
				if SE1->E1_SALDO == 0
					fnEstBaix(cTmp)
				endif
				(cTmp)->(dbSkip())
			end
		endif
	else
		SE1->( dbGoto((cTmp)->XX_RECNO) )
		if SE1->E1_SALDO > 0
			Alert("titulo nao esta baixado")
			return
		else
			fnEstBaix(cTmp)
		endif
	endif

	CFILANT := cBkp ; FwFreeArray(aPar)
	(cTmp)->(restArea(aSv))
return

static function fnEstBaix(cTmp)
	Local lCancBx	:= .T.

	if Type("cCadastro") != "U"
		cBkp := cCadastro
	endif

	//verifica se titulo esta conciliado
	// SE5->( DbSetOrder(7) )  
	// If SE5->(DbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
	// 	While SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
	// 		If !Empty(SE5->E5_RECONC)
	// 			lCancBx	:= .F.
	// 		EndIf
	// 		SE5->(DbSkip())
	// 	EndDo
	// endif

	// If lCancBx
		SetFunName("U_GESTFINK")

		ALTERA := .F.
		INCLUI := .F.
		FINA070(,5,.T.)
		
		fnUpdGrid(cTmp)

		SetFunName("GESTFIN")
	// endif

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
