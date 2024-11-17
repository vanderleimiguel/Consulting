#include "protheus.ch"
/*/{Protheus.doc} GESTFINJ
	concilia titulo
	@type function
	@version 1.0
	@author Wagner Neves
	@since 04/11/2023
/*/
user function XGESTFINJ(cTmp)
	MsgRun("Realizando conciliacao ...","Aguarde",{|| fnExec(cTmp) })
return

static function fnExec(cTmp)
	local aSV := (cTmp)->(getArea())
	local cBkp := CFILANT
	local nOpc as numeric
	local aPar as array

	nOpc := Aviso("Ação","Escolha a opção desejada?",{"Conciliar Marcados","Cancelar"},2)

	if nOpc == 2
		return
	endif

	if nOpc == 1
		(cTmp)->(dbSetOrder(2))
		if (cTmp)->(dbSeek("T"))
			while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
				
				nRecSE1	:= (cTmp)->XX_RECNO
				U_XConcilia(nRecSE1)
				
				fnUpdGrid(cTmp)
				if cBkp != nil
					cCadastro := cBkp
				endif
			(cTmp)->(dbSkip())
		end
	endif
endif


CFILANT := cBkp ; FwFreeArray(aPar)
(cTmp)->(restArea(aSv))
return

User Function XXConcilia(nRecSE1)
	Local cIdProc	:= ""
	Local cSeqCon   := ""
	Local nRecSE5 	:= 0

	SE1->( dbGoto(nRecSE1) )
	if SE1->E1_SALDO == 0

		mv_par01	:=  SE1->E1_PORTADO // Banco
		mv_par02	:=  SE1->E1_AGEDEP  // Agencia
		mv_par03	:=  SE1->E1_CONTA   // Conta
		mv_par04	:=  SE1->E1_VENCREA // Data de
		mv_par05	:=  SE1->E1_VENCREA // Data ate
		mv_par06	:= 1                // Aglutina lancamentos
		mv_par07	:= 1                // Mostra lanc. contabeis
		mv_par08	:= 2                // Contabiliza on-line
		mv_par09	:= 2                // Seleciona filial
		mv_par10	:= 2                // exibe baixas com estorno

		cIdProc	:= F473ProxNum("SIF")
		RecLock("SIF",.T.)
		SIF->IF_FILIAL 	:= xFilial("SIF")
		SIF->IF_IDPROC  := cIdProc
		SIF->IF_DTPROC  := SE1->E1_VENCREA
		SIF->IF_BANCO	:= SE1->E1_PORTADO
		SIF->IF_DESC	:= "Conciliado por GestFin"
		SIF->IF_STATUS 	:= '1'
		SIF->IF_ARQCFG	:= ""
		SIF->IF_ARQIMP	:= ""
		SIF->IF_ARQSUM	:= ""
		SIF->(MsUnlock())

		// Grava SIG
		cSeqCon   := F473ProxNum("SIG")
		RecLock("SIG",.T.)
		SIG->IG_FILIAL 	:= xFilial("SIG")
		SIG->IG_IDPROC	:= cIdProc
		SIG->IG_ITEM	:= "00001"
		SIG->IG_STATUS	:= '1'
		SIG->IG_DTEXTR	:= SE1->E1_VENCREA
		SIG->IG_DTMOVI	:= SE1->E1_VENCREA
		SIG->IG_DOCEXT	:= SE1->E1_NUM
		SIG->IG_SEQMOV  := cSeqCon
		SIG->IG_VLREXT 	:= SE1->E1_VALOR
		SIG->IG_TIPEXT	:= "001"
		SIG->IG_CARTER	:= "02"
		SIG->IG_AGEEXT  := SE1->E1_AGEDEP
		SIG->IG_CONEXT  := SE1->E1_CONTA
		SIG->IG_HISTEXT := "Conciliado por GestFin"
		SIG->IG_FILORIG := cFilAnt
		SIG->(MsUnlock())

		nRecSE5 := fFindSE5(SE1->E1_VENCREA, SE1->E1_PORTADO, SE1->E1_AGEDEP, SE1->E1_CONTA, SE1->E1_TIPO,;
			SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_CLIENTE, SE1->E1_LOJA)
		fConciliar(nRecSE5, cSeqCon)
	Else
		Alert("Nao foi possivel conciliar. Titulo: " + SE1->E1_PREFIXO + "-" + AllTrim(SE1->E1_NUM) + " possui saldo.")
	EndIf

Return

Static Function fConciliar(nRECSE5, cSeqCon)
	Local cStatus	:= ""
	Local lAtuDtDisp:= .T.
	Local lDesconc	:= .F.
	Local dDataExt	:= CTOD("")
	Local dDataMov	:= CTOD("")
	Local dDataNova	:= CTOD("")
	Local lFK5		:= .F.
	Local lFKs		:= .T.
	Local cFilFKA	:= ''
	Local cIdOrig	:= ''
	Local nRecDesco := 0

	DbSelectArea("FKA")
	DbSelectArea("FK5")
	FK5->( DbSetOrder(1) )
	SIF->( DbSetOrder(1) ) //IF_FILIAL+IF_IDPROC
	SIG->( DbSetOrder(2) ) //IG_SEQMOV
	SE5->( DbSetOrder(20)) //E5_FILIAL+E5_SEQCON
	SA6->( DbSetOrder(1) )

	cStatus	 := "1"
	lDesconc := .F.
	dDataExt  := SE1->E1_VENCREA
	dDataMov  := SE1->E1_VENCREA

	//Atualiza SE5 e atualiza o Saldo
	If nRECSE5 > 0
		nRECSE5 := IIf(nRECSE5 == 0, nRecDesco, nRECSE5)
		SE5->(DbGoTo(nRECSE5))
		FKA->(DbSetOrder(3))

		If SE5->E5_TABORI == "FK1"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK1" + SE5->E5_IDORIG ) )
			lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
			lFKs := .T. // Possui dados migrados
		ElseIf SE5->E5_TABORI == "FK2"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK2" + SE5->E5_IDORIG ) )
			lFK5 := .F. // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
			lFKs := .T. // Possui dados migrados
		ElseIf SE5->E5_TABORI == "FK5"
			FKA->( DbSeek( SE5->E5_FILIAL + "FK5" + SE5->E5_IDORIG ) )
			lFK5 := .T. // NÃO PRECISA fazer o loop na FKA procurando o registro de Movimentação Bancaria, pois esse é o registro de movimentação
			lFKs := .T. // Possui dados migrados
			cIdOrig := FKA->FKA_IDORIG
			cFilFKA := FKA->FKA_FILIAL
		ElseIf Empty(SE5->E5_TABORI)
			lFKs := .F. // NÃO POSSUI dados migrados
		EndIf

		If lFKs //Possui dados migrados
			cIdProc := FKA->FKA_IDPROC

			If !lFK5 // Precisa fazer o loop na FKA procurando o registro de Movimentação Bancaria
				FKA->( DbSetOrder(2) )
				FKA->( DbSeek( FKA->FKA_FILIAL + cIdProc ) )

				While FKA->(!EoF()) .And. FKA->FKA_IDPROC == cIdProc
					If FKA->FKA_TABORI == "FK5"
						cIdOrig := FKA->FKA_IDORIG
						cFilFKA := FKA->FKA_FILIAL
					EndIf
					FKA->(DbSkip())
				Enddo
			EndIf

			If FK5->(DbSeek(cFilFKA + cIdOrig ) )
				If !lDesconc //Conciliou
					Reclock("SE5", .F.)
					SE5->E5_RECONC := 'x'
					SE5->E5_SEQCON := cSeqCon
					SE5->( MsUnLock() )

					Reclock("FK5", .F.)
					FK5->FK5_DTCONC	:= dDataBase
					FK5->FK5_SEQCON	:= cSeqCon
					FK5->( MsUnLock() )
				Else //Desconciliou
					Reclock("SE5", .F.)
					SE5->E5_RECONC	:= ' '
					SE5->E5_SEQCON	:= ' '
					SE5->( MsUnLock() )

					Reclock("FK5", .F.)
					FK5->FK5_DTCONC	:= CTOD("")
					FK5->FK5_SEQCON	:= ""
					FK5->( MsUnLock() )
				EndIf
			Else
				cLog := "Registro não localizado na tabela FK5" + cFilFKA + "' " + "Filial: " + cIdOrig + "' "//"Registro não localizado na tabela FK5. Filial: '"
				Help( ,,"MF473GRV1",,cLog, 1, 0 )
			EndIf
		Else //Registro da SE5 não possui dados nas Tabelas FKs, não foi migrado.
			If !lDesconc //Conciliou
				Reclock( "SE5", .F. )
				SE5->E5_RECONC	:= 'x'
				SE5->E5_SEQCON	:= cSeqCon
				SE5->( MsUnLock() )
			Else //Desconciliou
				Reclock( "SE5", .F. )
				SE5->E5_RECONC	:= ' '
				SE5->E5_SEQCON	:= ' '
				SE5->( MsUnLock() )
			EndIf
		EndIf

		If lDesconc
			dDataNova := dDataMov
		Else
			dDataNova := dDataExt
		EndIf

		//Acerto E5_DTDISPO dos titulos baixados
		If dDataNova !=  SE5->E5_DTDISPO .and. lAtuDtDisp
			dOldDispo := SE5->E5_DTDISPO

			If lFKs // Possui dados migrados
				//Posiciona a FK5 com base no IDORIG da SE5 posicionada
				DbSelectArea("FK5")
				FK5->( DbSetOrder(1) )

				If FK5->(DbSeek(xFilial("SE5")+cIdOrig))
					Reclock("FK5", .F.)
					FK5->FK5_DTDISP	:= SE5->E5_DTDISPO
					FK5->(MsUnlock())

					If SE5->E5_RECPAG == "P"
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
					Else
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
						AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
					EndIf

				Else
					cLog := "Registro não localizado na tabela FK5" + cFilFKA + "' " + "Filial: " + cIdOrig + "' " //"Registro não localizado na tabela FK5. Filial: '"
					Help( , , "MF473GRV2", , "Não foi possivel atualizar o Saldo do Banco" + CRLF + cLog, 1, 0 ) // "Não foi possivel atualizar o Saldo do Banco."
				EndIf

			Else // Registro da SE5 não possui dados nas Tabelas FKs, dados não foram migrados.
				If SE5->E5_RECPAG == "P"
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "+", lDesconc )
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "-", !lDesconc )
				Else
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, dOldDispo, SE5->E5_VALOR, "-", lDesconc )
					AtuSalBco( SE5->E5_BANCO, SE5->E5_AGENCIA, SE5->E5_CONTA, SE5->E5_DTDISPO, SE5->E5_VALOR, "+", !lDesconc )
				EndIf
			EndIf

		Else
			//Atualiza apenas o saldo reconciliado
			If lDesconc	    //Desconciliou
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","+","-"),.T.,.F.)
			Else //Conciliou
				AtuSalBco(SE5->E5_BANCO,SE5->E5_AGENCIA,SE5->E5_CONTA,SE5->E5_DTDISPO,SE5->E5_VALOR,If(SE5->E5_RECPAG == "P","-","+"),.T.,.F.)
			EndIf
		EndIf
	Else
		Alert("Nao foi possivel conciliar. Titulo: " + SE1->E1_PREFIXO + "-" + AllTrim(SE1->E1_NUM) + " nao possui movimentacao na SE5.")
	EndIf

Return .T.

Static Function F473ProxNum(cTab)
	Local cNovaChave := ""
	Local aArea := GetArea()
	Local cCampo := ""
	Local cChave
	Local nIndex := 0

	If cTab == "SIF"
		SIF->(dbSetOrder(1))//IF_FILIAL+IF_IDPROC
		cCampo := "IF_IDPROC"
		nIndex := 1
	Else
		SIG->(dbSetOrder(2))//IG_FILIAL+IG_SEQMOV
		cCampo := "IG_SEQMOV"
		cChave := "IG_SEQMOV"+cEmpAnt
		nIndex := 2
	EndIf


	While .T.
		(cTab)->(dbSetOrder(nIndex))
		cNovaChave := GetSXEnum(cTab,cCampo,cChave,nIndex)
		ConfirmSX8()
		If cTab == "SIF"
			If (cTab)->(!dbSeek(xFilial(cTab) + cNovaChave) )
				Exit
			EndIf
		Else
			If (cTab)->(!dbSeek(cNovaChave) )
				Exit
			EndIf
		EndIf
	EndDo

	RestArea(aArea)
Return cNovaChave

static Function fFindSE5(dData, cBanco, cAgencia, cConta, cTipo, cPrefixo, cNum, cParcela, cCliFor, cLoja)
	Local nRec		:= 0
	Local cQuery    := ""
	Local cAlias 	:= GetNextAlias()

	cQuery := " SELECT R_E_C_N_O_ RECNO "
	cQuery += " FROM "+RetSqlName('SE5')+" SE5 "
	cQuery += " WHERE "
	cQuery += " E5_BANCO = '" + cBanco + "' AND " + CRLF
	cQuery += " E5_AGENCIA = '" + cAgencia + "' AND " + CRLF
	cQuery += " E5_CONTA   = '" + cConta + "' AND " + CRLF
	cQuery += " E5_SITUACA <> 'C' AND " + CRLF
	cQuery += " E5_RECONC = ' ' AND " + CRLF
	cQuery += " E5_PREFIXO = '" + cPrefixo + "' AND " + CRLF
	cQuery += " E5_NUMERO = '" + cNum + "' AND " + CRLF
	cQuery += " E5_PARCELA = '" + cParcela + "' AND " + CRLF
	cQuery += " E5_TIPO = '" + cTipo + "' AND " + CRLF
	cQuery += " E5_CLIFOR = '" + cCliFor + "' AND " + CRLF
	cQuery += " E5_LOJA = '" + cLoja + "' AND " + CRLF
	cQuery += " SE5.D_E_L_E_T_ = ' '"
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

	(cAlias)->(DbGoTop())

	If (cAlias)->(!EOF())
		nRec := (cAlias)->RECNO
	EndIf
	(cAlias)->(DbCloseArea())

Return nRec

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
