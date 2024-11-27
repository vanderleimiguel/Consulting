#include "protheus.ch"

/*/{Protheus.doc} GESTFIN5
	Realiza Estorno conciliação
	@type function
	@version 1.0
	@author Wagner Neves
	@since 10/04/2023
/*/
user function GESTFINL(cTmp)
	MsgRun("Realizando Estorno Conciliacao ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV 		:= (cTmp)->(getArea())
	local cBkp 		:= CFILANT
	local nOpc as numeric
	local aPar as array
	Local nRecSE1 as numeric

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Estorna conciliacao Marcados","Estorna conciliacao Posicionado","Cancelar"},2)

	if nOpc == 3
		return
	endif

	if nOpc == 1
		(cTmp)->(dbSetOrder(2))
		if (cTmp)->(dbSeek("T"))
			while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
				nRecSE1	:= 0
				SE1->( dbGoto((cTmp)->XX_RECNO) )
				SE5->( DbSetOrder(7) )  
				If SE5->(DbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
					While SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
						If !Empty(SE5->E5_RECONC)
							fnEstConc(cTmp, (cTmp)->XX_RECNO, SE5->( Recno() ), .T., SE5->E5_SEQCON)
						EndIf
						SE5->(DbSkip())
					EndDo
				endif
				(cTmp)->(dbSkip())
			end
		endif
	else
		SE1->( dbGoto((cTmp)->XX_RECNO) )
		SE5->( DbSetOrder(7) )  
		If SE5->(DbSeek(xFilial("SE5")+SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)))
			While SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA) == SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA)
				If !Empty(SE5->E5_RECONC)
					fnEstConc(cTmp, (cTmp)->XX_RECNO, SE5->( Recno() ), .T., SE5->E5_SEQCON)
				EndIf
				SE5->(DbSkip())
			EndDo
		endif
	endif

	CFILANT := cBkp ; FwFreeArray(aPar)
	(cTmp)->(restArea(aSv))
return

static function fnEstConc(cTmp, nRecSE1, nRecSE5, lDesconc, cSeqCon)
	if Type("cCadastro") != "U"
		cBkp := cCadastro
	endif
	SetFunName("U_GESTFINL")

	U_XConcilia(nRecSE1, nRecSE5, lDesconc, cSeqCon)
	
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
