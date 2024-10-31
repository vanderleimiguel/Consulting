#include "totvs.ch"
#include "RPTDef.ch"
#include "FWPrintSetup.ch"
/*/{Protheus.doc} GESTFIN6
	gera a DANFE
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function GESTFIN6(cTmp)
	MsgRun("Gerando DANFE ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSv := {(cTmp)->(getArea()),SF2->(getArea())}
	local cBkp := CFILANT
	local nOpc as numeric

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Marcados","Posicionado","Cancelar"},2)

	if nOpc == 3
		return
	endif

	if nOpc == 1
		(cTmp)->(dbSetOrder(2))
		if (cTmp)->(dbSeek("T"))
			SF2->( dbSetOrder(1) )
			while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
				if Alltrim((cTmp)->E1_TIPO) == "NF"
					CFILANT := (cTmp)->E1_FILORIG
					if SF2->( msSeek(xFilial()+(cTmp)->E1_NUM+(cTmp)->E1_PREFIXO+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA) )
						fnDanfe(cTmp)
					endif
				endif
				(cTmp)->(dbSkip())
			end
		endif
	else
		if Alltrim((cTmp)->E1_TIPO) == "NF"
			SF2->( dbSetOrder(1) )
			CFILANT := (cTmp)->E1_FILORIG
			if SF2->( msSeek(xFilial()+(cTmp)->E1_NUM+(cTmp)->E1_PREFIXO+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA) )
				fnDanfe(cTmp)
			endif
		endif
	endif

	CFILANT := cBkp
	(cTmp)->(restArea(aSv[1]))
	SF2->(restArea(aSv[2]))
return


static function fnDanfe(cTmp)
	local cIdent    := RetIdEnti()
	local oDanfe    := Nil
	local lEnd      := .F.
	local nTamNota  := TamSX3('F2_DOC')[1]
	local nTamSerie := TamSX3('F2_SERIE')[1]
	local dDataDe   := sToD("19800101")
	local dDataAt   := Date()
	local cNota		:= SF2->F2_DOC
	local cSerie	:= SF2->F2_SERIE
	local cPasta	:= GetTempPath()
	local cArquivo  := cNota + "_" + dToS(Date()) + "_" + StrTran(Time(), ":", "-")

	if SubStr(cPasta, Len(cPasta), 1) != "\"
		cPasta += "\"
	endif

	Pergunte("NFSIGW",.F.)
	MV_PAR01 := PadR(cNota,  nTamNota)     //Nota Inicial
	MV_PAR02 := PadR(cNota,  nTamNota)     //Nota Final
	MV_PAR03 := PadR(cSerie, nTamSerie)    //Série da Nota
	MV_PAR04 := 2                          //NF de Saida
	MV_PAR05 := 1                          //Frente e Verso = Sim
	MV_PAR06 := 2                          //DANFE simplificado = Nao
	MV_PAR07 := dDataDe                    //Data De
	MV_PAR08 := dDataAt                    //Data Até

	oDanfe := FWMSPrinter():new(cArquivo, IMP_PDF, .F., , .T.)
	oDanfe:setResolution(78)
	oDanfe:setPortrait()
	oDanfe:setPaperSize(DMPAPER_A4)
	oDanfe:setMargin(60, 60, 60, 60)

	oDanfe:nDevice  := 6
	oDanfe:cPathPDF := cPasta
	oDanfe:lServer  := .F.
	oDanfe:lViewPDF := .F.

	PixelX    := oDanfe:nLogPixelX()
	PixelY    := oDanfe:nLogPixelY()
	nConsNeg  := 0.4
	nConsTex  := 0.5
	oRetNF    := Nil
	nColAux   := 0

	RptStatus({|lEnd| u_DanfeProc(@oDanfe, @lEnd, cIdent, , , .F.)}, "Imprimindo Danfe...")
	oDanfe:Print()

	FreeObj(oDanfe)

	ShellExecute("open", cArquivo+".pdf", "", cPasta, 1)
return
