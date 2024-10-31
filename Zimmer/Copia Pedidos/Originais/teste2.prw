#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"

//-------------------------------------------------------------------------------
/*/{Protheus.doc} MM444
Filtro no campo RA_MATSUP chamada no X3_VLDUSER 

@return 
@author Mauricio Carneiro
@since 22/01/2020
/*/
//-------------------------------------------------------------------------------
User Function MM444()
Local cTitulo	:= "Mat Superior"
Local cQuery	:= ""
Local cAlias	:= "SRA"
Local cCpoChave	:= "RA_MAT"
Local cTitCampo	:= RetTitle(cCpoChave)
Local cMascara	:= PesqPict(cAlias,cCpoChave)
Local nTamCpo	:= TamSx3(cCpoChave)[1]
Local cRetCpo	:= "M->RA_MAT"
Local nColuna	:= 2
Local cCodigo	:= SRA->RA_MAT
Private bRet 	:= .F.
Private nCpPesq := 0

	dbSelectArea("SRA")

	If !Empty(M->RA_MMFISUP)
		MsgInfo("O campo Filial Super não foi preenchido, serão filtrados os gestores da filial 010101, para as demais favor preencher o campo!")
		cMMEmp := Substr(M->RA_MMFISUP,1,2)
		cMMFil := M->RA_MMFISUP
	EndIf

	cQuery := " SELECT RA_FILIAL, RA_MAT, RA_NOME "
	cQuery += " FROM "+RetSqlName("SRA")+ " SRA WITH (NOLOCK) "
	cQuery += " WHERE D_E_L_E_T_= ' ' AND RA_FILIAL = '" + xFilial("SRA") + "' "
	cQuery += " AND RA_DEMISSA = '' "
	cQuery += " ORDER BY RA_FILIAL, RA_MAT " 

	bRet := MM444A(cTitulo, cQuery, nTamCpo, cAlias, cCodigo, cCpoChave, cTitCampo, cMascara, cRetCpo, nColuna)
Return(bRet)


//Monta a Tela
Static Function MM444A(cTitulo, cQuery, nTamCpo, cAlias, cCodigo, cCpoChave, cTitCampo, cMascara, cRetCpo, nColuna)
Local cCampos 	 := ""
Local bCampo	 := {}
Local nCont		 := 0
Local aCampos 	 := {}
Local cCSSGet	 := "QLineEdit{ border: 1px solid gray;border-radius: 3px;background-color: #ffffff;selection-background-color: #3366cc;selection-color: #ffffff;padding-left:1px;}"
Local cCSSButton := "QPushButton{background-repeat: none; margin: 2px;background-color: #ffffff;border-style: outset;border-width: 2px;border: 1px solid #C0C0C0;border-radius: 5px;border-color: #C0C0C0;font: bold 12px Arial;padding: 6px;QPushButton:pressed {background-color: #ffffff;border-style: inset;}"
Local cTabela 
Local nLista  
Local nX

Private _aDados  := {}
Private _nColuna := 0
Private _oLista	 := nil
Private _oDlg 	 := nil
Private _cCodigo

Default cTitulo   := ""
Default cCodigo   := Space(6)
Default nTamCpo   := 6
Default _nColuna  := 1
Default cTitCampo := RetTitle(cCpoChave)
Default cMascara  := PesqPict('"'+cAlias+'"',cCpoChave)

	_nColuna := nColuna	
	_cCodigo := cCodigo
	cTabela  := CriaTrab(Nil,.F.)

	dbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cTabela, .F., .T.)

	(cTabela)->(dbGoTop())

	If (cTabela)->(Eof())
		MsgStop("Não há registros para serem exibidos!","Atenção")
		Return
	Endif

	Do While !(cTabela)->(Eof())

		cCampos	:= ""
		aCampos := {}

		For nX := 1 TO (cTabela)->(FCount())
			bCampo := {|nX| (cTabela)->(Field(nX)) }
			cCampo := EVAL(bCampo,nX)
			xConteudo := (cTabela)->&(cCampo)

			If ValType(xConteudo) <> "M" .AND. ValType(xConteudo) <> "U"
				if ValType(xConteudo)=="C"
					cCampos += "'" + xConteudo + "',"
				ElseIf ValType(xConteudo)=="D"
					cCampos +=  DTOC(xConteudo) + ","
				Else
					cCampos +=  xConteudo + ","
				Endif

				aAdd(aCampos,{cCampo,Alltrim(RetTitle(cCampo)),"LEFT",30})
				if Upper(Alltrim(cCampo)) == "RA_MAT"
					nCpPesq := Len(aCampos)
				endif
			Endif
		Next

		If !Empty(cCampos)
			cCampos	:= Substr(cCampos,1,len(cCampos)-1)
			aAdd( _aDados,&("{"+cCampos+"}"))
		Endif

		(cTabela)->(dbSkip())

	Enddo

	(cTabela)->(dbCloseArea())

	If Len(_aDados) == 0
		MsgInfo("Não há dados para exibir!","Aviso")
		Return
	Endif

	nLista := aScan(_aDados, {|x| alltrim(x[1]) == alltrim(_cCodigo)})

	iif(nLista = 0,nLista := 1,nLista)

	Define MsDialog _oDlg Title "Consulta Padrão" + IIF(!Empty(cTitulo)," - " + cTitulo,"") From 0,0 To 280, 500 Of oMainWnd Pixel

	oCodigo := TGet():New( 003, 005,{|u| if(PCount()>0,_cCodigo:=u,_cCodigo)},_oDlg,205, 010,cMascara,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,"",_cCodigo,,,,,,,cTitCampo + ": ",1 )
	oCodigo:SetCss(cCSSGet)

	oButton1 := TButton():New(010, 212," &Pesquisar ",_oDlg,{|| Processa({|| MM444C(_oLista:nAt, _aDados) },"Aguarde...") },037,013,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton1:SetCss(cCSSButton)

	_oLista := TCBrowse():New(26,05,245,90,,,,_oDlg,,,,,{|| _oLista:Refresh()},,,,,,,.F.,,.T.,,.F.,,,.f.)

	nCont := 1

	For nX := 1 to len(aCampos)
		cColuna := &('_oLista:AddColumn(TCColumn():New("'+aCampos[nX,2]+'", {|| _aDados[_oLista:nAt,'+StrZero(nCont,2)+']},PesqPict("'+cAlias+'","'+aCampos[nX,1]+'"),,,"'+aCampos[nX,3]+'", '+StrZero(aCampos[nX,4],3)+',.F.,.F.,,{|| .F. },,.F., ) )')
		nCont++
	Next

	_oLista:SetArray(_aDados)
	_oLista:bWhen 	   := { || Len(_aDados) > 0 }
	_oLista:bLDblClick := { || MM444B(_oLista:nAt, _aDados, cRetCpo)  }
	_oLista:Refresh()

	oButton2 := TButton():New(122, 005," OK "		,_oDlg,{|| Processa({|| MM444B(_oLista:nAt, _aDados, cRetCpo) },"Aguarde...") },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton2:SetCss(cCSSButton)
	oButton3 := TButton():New(122, 047," Cancelar "	,_oDlg,{|| _oDlg:End() },037,012,,,.F.,.T.,.F.,,.F.,,,.F. )
	oButton3:SetCss(cCSSButton)

	Activate MSDialog _oDlg Centered

Return(bRet)


//Atualiza o campo
Static Function MM444B(nLinha, aDados, cRetCpo)
	cCodigo    := aDados[nLinha,_nColuna]
	&(cRetCpo) := cCodigo
	bRet       := .T.
	_oDlg:End()
Return


//Botão Pesquisar
Static Function MM444C(nLinhaNew, aDados)
Local nAtual
Local n
Local cCodPesq := alltrim(_cCodigo)
Local nTamPesq := len(cCodPesq)
//Local oGrid

	if nCpPesq > 0
		n := aScan(aDados, {|x| left(x[nCpPesq],nTamPesq) = cCodPesq})
		if (n > 0) .and. (n <> _oLista:nAt)
			_oLista:nAt := n
			_oLista:Refresh()
		endif
	endif

Return
