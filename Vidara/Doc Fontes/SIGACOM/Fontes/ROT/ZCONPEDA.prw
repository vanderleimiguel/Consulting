//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} zConPEDA
Browse com pedidos em aberto
@author Abel Ribeiro 
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function zConPEDA()
	Local aArea 	:= FWGetArea()
	local cCodFor 	:= SA5->A5_FORNECE
	local cCodloja 	:= SA5->A5_LOJA
	local cCodPro 	:= SA5->A5_PRODUTO
	local cCodFab 	:= SA5->A5_FABR
	local cLojaF	:= SA5->A5_FALOJA

	//Chama a tela
	fMontaTela(cCodFor,cCodloja,cCodPro,cCodFab,cLojaF)

	FWRestArea(aArea)
Return

/*/{Protheus.doc} fMontaTela
Monta a tela com a marcação de dados
@author Abel Ribeiro
@since 24/05/2024
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/
Static Function fMontaTela(cCodFor,cCodloja,cCodPro,cCodFab,cLojaF)
	Local aArea         := GetArea()
	Local nX
	//Tamanho da janela
	Private aSize := MsAdvSize(.F.)
	Private nJanLarg := aSize[5]
	Private nJanAltu := aSize[6]
	//Local bBlocoIni    := {|| EnchoiceBar(oDlgBrow, bBlocoOk, bBlocoCan, , aOutrasAc)}
	Private lOk        := .F.
	//Janela e componentes
	Private oDlg
	Private oTable
	Private oBrowse
	Private oFWFilter

	Private cAliasTmp := GetNextAlias()
	Private aCoors := {}
	Private aSeek  := {}
	Private aIndex := {}
	Private aRotina	:= {{ "Pesquisar"	,"AxPesqui"		,0,1}} //MenuDef()

	//Private aRotina   := MenuDef()
	//Tamanho da janela

	aTamX3Flds := {TamSX3("C7_NUM"), TamSX3("C7_FORNECE"),TamSX3("C7_LOJA"),TamSX3("A2_NOME"),TamSX3("B1_COD"),TamSX3("B1_DESC"),TamSX3("A2_NOME"),TamSX3("B1_TE")}

	aStruct := {}
	//                           TIPO              TAM               DEC
	AAdd(aStruct, {'PEDIDO'    , aTamX3Flds[1][3], aTamX3Flds[1][1], aTamX3Flds[1][2],"@!", 'Pedido'})
	AAdd(aStruct, {'CODFORN'   , aTamX3Flds[2][3], aTamX3Flds[2][1], aTamX3Flds[2][2],"@!", 'Fornecedor'})
	AAdd(aStruct, {'LOJA'      , aTamX3Flds[3][3], aTamX3Flds[3][1], aTamX3Flds[3][2],"@!", 'Loja'})
	AAdd(aStruct, {'NOMEFOR'   , aTamX3Flds[4][3], aTamX3Flds[4][1], aTamX3Flds[4][2],"@!", 'Nome'})
	AAdd(aStruct, {'CODPROD'   , aTamX3Flds[5][3], aTamX3Flds[5][1], aTamX3Flds[5][2],"@!", 'Produto'})
	AAdd(aStruct, {'DESCPROD'  , aTamX3Flds[6][3], aTamX3Flds[6][1], aTamX3Flds[6][2],"@!", 'Descricao'})
	AAdd(aStruct, {'CODFAB'   , aTamX3Flds[2][3], aTamX3Flds[2][1], aTamX3Flds[2][2],"@!", 'Fabricante'})
	AAdd(aStruct, {'LOJAFAB'    , aTamX3Flds[3][3], aTamX3Flds[3][1], aTamX3Flds[3][2],"@!", 'Loja Fabr'})
	Aadd(aStruct, {'FABRICANTE', aTamX3Flds[7][3], aTamX3Flds[7][1], aTamX3Flds[7][2],"@!", 'Nome Fabr'})
	AAdd(aStruct, {'HOMOLOGADO', aTamX3Flds[8][3], aTamX3Flds[8][1], aTamX3Flds[8][2],"@!", 'Homologado'})


	aIndex := {"PEDIDO"}
	aSeek  := {{"Nr Pedido", {{"LookUp", "C", aTamX3Flds[1][1], 0, "",,}} , 1, .T. }}

	//Set Columns
	aColumns := {}
	aFilter  := {}
	For nX := 01 To Len(aStruct)
		//Columns
		AAdd(aColumns,FWBrwColumn():New())
		aColumns[Len(aColumns)]:SetData( &("{||"+aStruct[nX][1]+"}") )
		aColumns[Len(aColumns)]:SetTitle(aStruct[nX][6])
		aColumns[Len(aColumns)]:SetSize(aStruct[nX][3])
		aColumns[Len(aColumns)]:SetDecimal(aStruct[nX][4])
		aColumns[Len(aColumns)]:SetPicture(aStruct[nX][5])
		//Filters
		IF nX == 1
			aAdd(aFilter, {aStruct[nX][1], "Pedido", aStruct[nX][3], TamSX3(aStruct[nX][1]), TamSX3(aStruct[nX][2]), aStruct[nX][5]} )
		ENDIF
	Next nX


	//Instance of Temporary Table
	oTable := FWTemporaryTable():New()
	//Set Fields
	oTable:SetFields(aStruct)
	//Set Indexes
	oTable:AddIndex("1", {"PEDIDO"} )
	oTable:AddIndex("2", {"CODFORN"} )
	//Create
	oTable:Create()
	cAliasTmp := otable:GetAlias()
	cTableName := oTable:getRealName()

	//Popula a tabela temporária

	cQryDados := ""

	cQryDados := "INSERT INTO "+cTableName + " (PEDIDO,CODFORN,LOJA,NOMEFOR,CODPROD,DESCPROD,CODFAB,LOJAFAB,FABRICANTE,HOMOLOGADO) " + CRLF
	cQryDados += "SELECT C7_NUM AS PEDIDO, C7_FORNECE AS CODFORN, C7_LOJA AS LOJA,SA2.A2_NOME AS NOMEFOR, B1_COD AS CODPROD,B1_DESC AS DESCPROD, " + CRLF
	cQryDados += "C7_ZZCDFAB CODFAB, C7_ZZLJFAB LOJAFAB, SA2F.A2_NOME AS FABRICANTE, " + CRLF
	cQryDados += " CASE WHEN A5_ZZHOMOL = '1' THEN 'SIM' ELSE 'NAO' END AS 'HOMOLOGADO' FROM "+RETSQLNAME("SC7") + " SC7 (NOLOCK) "	+ CRLF
	cQryDados += "INNER JOIN "+RETSQLNAME("SA5") + " SA5 ON A5_PRODUTO = C7_PRODUTO AND A5_FORNECE = C7_FORNECE AND A5_LOJA = C7_LOJA AND A5_ZZHOMOL = '2' AND SA5.D_E_L_E_T_ <> '*' "		+ CRLF
	cQryDados += "INNER JOIN "+RETSQLNAME("SA2") + " SA2 ON SA2.A2_COD = A5_FORNECE AND SA2.A2_LOJA = A5_LOJA AND SA2.D_E_L_E_T_ <> '*' "		+ CRLF
	cQryDados += "INNER JOIN "+RETSQLNAME("SA2") + " SA2F ON SA2F.A2_COD = A5_FABR AND SA2F.A2_LOJA = A5_FALOJA AND SA2F.D_E_L_E_T_ <> '*' "		+ CRLF
	cQryDados += "INNER JOIN "+RETSQLNAME("SB1") + " SB1 ON B1_COD = A5_PRODUTO AND SB1.D_E_L_E_T_ = '' "	+ CRLF
	cQryDados += "WHERE "		+ CRLF
	cQryDados += "SC7.C7_QUJE = 0 AND SC7.D_E_L_E_T_ <> '*'"		+ CRLF
	cQryDados += " AND SC7.C7_ZZCDFAB = '" + cCodFab + "' AND SC7.C7_ZZLJFAB = '" + cLojaF + "' AND SC7.C7_PRODUTO = '" + cCodPro + "'

	//cQryDados += "SC7.C7_QUJE = 0 AND SC7.C7_ZZFABR = '1' AND SC7.D_E_L_E_T_ <> '*'"		+ CRLF

	if TCSqlExec(cQryDados) >= 0
		aCoors := FWGetDialogSize()

		//Se os botões de Ok e Fecha devem fechar o browse, então você deve ser o responsável pelo oOwner do browse
		//oDlg = MsDialog():New( aCoors[1], aCoors[2], aCoors[3], aCoors[4], "",,,.F., nOR(WS_VISIBLE, WS_POPUP),,,,,.T.,, ,.F. )
		//Cria a janela
		DEFINE MSDIALOG oDlg TITLE "Consulta Pedidos em Aberto - Não Homologados"  FROM 0, 0 TO nJanAltu, nJanLarg PIXEL
		oBrowse:= FWMBrowse():New(oDlg)
		oBrowse:SetDescription("Consulta de Pedidos Compras em Aberto Não Homologados")
		oBrowse:SetDataTable()
		oBrowse:SetTemporary(.T.)
		oBrowse:SetAlias(oTable:getAlias())
		oBrowse:SetColumns(aColumns)
		oBrowse:SetFieldFilter(aFilter) //Set Filters
		oBrowse:OptionReport(.F.)       //Disable Report Print

		oBrowse:DisableDetails()
		oBrowse:DisableConfig()
		oBrowse:OptionReport(.F.)
		oBrowse:DisableReport(.T.)
		oBrowse:SetAmbiente(.F.)
		oBrowse:SetWalkThru(.F.)
		//Adiciona Botoes
		//oBrowse:AddButton( "OK"    , {|| lRet := .T., oDlg:end() } ,, 2 ) //"Confirmar"
		oBrowse:AddButton( "Fechar", {|| oDlg:end() } ,, 2 ) //"Cancelar"

		oBrowse:SetQueryIndex(aIndex)
		oBrowse:SetSeek(.T.,aSeek)

		oBrowse:Activate(oDlg)
		Activate MsDialog oDlg Centered

		//oBrowse:deActivate()
		//oBrowse:destroy()
		//FreeObj(oBrowse)
		//oBrowse := nil
	else
		lRet := .F.

		// Caso deseja gerar exceção...
		// UserException(TCSqlError())
	endif

	oTable:delete()
//FreeObj(oTable)
//oTable := nil        

	RestArea(aArea)
Return

//--------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da rotina

@author TOTVS Protheus
@since  26/07/2024
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

	Local aRotina 	:= {{ "Pesquisar"	,"AxPesqui"		,0,1}}

Return aRotina


User Function Z_VLFHML ()

	Local cAliasQry	:= ""
	Local cQuery	:= ""
	Local lret      := .T.
	local cCodPro := SA5->A5_PRODUTO
	local cCodFab := SA5->A5_FABR
	local cLojaF  := SA5->A5_FALOJA


	IF altera .Or. inclui

		If M->A5_ZZHOMOL == "2"

			cQuery := "SELECT SC7.R_E_C_N_O_ RECSC7 "
			cQuery += "  FROM "+RetSqlName("SC7")+" SC7 (NOLOCK) "
			cQuery += " WHERE SC7.D_E_L_E_T_= ' ' "
			cQuery += " AND SC7.C7_QUJE = 0 AND SC7.C7_ZZCDFAB = '" + cCodFab + "' AND SC7.C7_ZZLJFAB = '" + cLojaF + "' AND SC7.C7_PRODUTO = '" + cCodPro + "'  "

			cAliasQry := MPSysOpenQuery(cQuery)

			DbSelectArea(cAliasQry)
			(cAliasQry)->(DbGoTop())
			If (cAliasQry)->(!Eof())
				FWAlertWarning("Mensagem de aviso", "Z_VLFMHL -Existe pedidos de compra não finalizados contendo o Fabricado que está sendo desomologado.")
			Endif

			If Select(cAliasQry)>0
				(cAliasQry)->(DbCloseArea())
			EndIf
		Else
			IF Empty(M->A5_ZZDTEXP)
				FWAlertWarning("Informe a data de Expiração dessa Homologação. ", "Z_VLFMHL - AVISO")
			Endif
		Endif

	Endif

Return(lret)


