#include "totvs.ch"
#include 'fwmvcdef.ch'
/*/{Protheus.doc} GESTFING
	permite consultar os saldos bancários
	@type function
	@version 1.0
	@author ivan.caproni
	@since 05/07/2023
/*/
user function GESTFING(cTmp)
	local oDlg as object
	local oBrw as object
	local oTbl as object

	oTbl := dataDef()
	oDlg := mainScreenDef()
	oBrw := browseDef(oTbl,oDlg)

	oBrw:activate()
	oDlg:activate()

	oTbl:delete() ; FreeObj(oTbl)
	oBrw:deActivate() ; FreeObj(oBrw)
	FreeObj(oDlg)
return

static function mainScreenDef()
	local oDlg := FwDialogModal():new()
	local nRdc := 40 // diminui em 40% a tela
	oDlg:setCloseButton(.F.)
	oDlg:setEscClose(.F.)
	oDlg:enableAllClient()
	oDlg:nBottom *= 1 - nRdc/100
	oDlg:nRight  *= 1 - nRdc/100
	oDlg:createDialog()
	oDlg:addCloseButton()
return oDlg

static function browseDef(oTbl,oDlg)
	local oBrowse as object
	local oColuna as object
	local nIndex  as numeric
	local cField  as character

	oBrowse := FwBrowse():new(oDlg:getPanelMain())
	oBrowse:setDataTable(.T.)
	oBrowse:setAlias(oTbl:getAlias())
	oBrowse:setDescription("Central 4Fin - Saldos Bancários")
	oBrowse:setProfileId("SALD")
	oBrowse:disableConfig()

	for nIndex := 1 to Len(oTbl:oStruct:aFields)
		cField := oTbl:oStruct:aFields[nIndex][1]
		oColuna := FwBrwColumn():new()
		oColuna:setData(&("{||"+cField+"}"))
		oColuna:setTitle(Alltrim(GetSx3Cache(cField,"X3_TITULO")))
		oColuna:setSize(TamSx3(cField)[1])
		oColuna:setAlign(Iif(GetSx3Cache(cField,"X3_TIPO") == "N",2,1))
		oColuna:setPicture(GetSx3Cache(cField,"X3_PICTURE"))
		oBrowse:setColumns({oColuna})
	next nIndex
return oBrowse

static function dataDef()
	local oTable as object
	local cQuery := ""
	local cField := ""
	local aField := {FwSx3Util():getFieldStruct("E8_FILIAL"),;
					 FwSx3Util():getFieldStruct("E8_BANCO"),;
					 FwSx3Util():getFieldStruct("E8_AGENCIA"),;
					 FwSx3Util():getFieldStruct("E8_CONTA"),;
					 FwSx3Util():getFieldStruct("E8_DTSALAN"),;
					 FwSx3Util():getFieldStruct("E8_SALANT"),;
					 FwSx3Util():getFieldStruct("E8_DTSALAT"),;
					 FwSx3Util():getFieldStruct("E8_SALATUA"),;
					 FwSx3Util():getFieldStruct("E8_SALRECO")}

	oTable := FwTemporaryTable():new()
	oTable:setFields(aField)
	oTable:addIndex("1",{"E8_FILIAL","E8_BANCO","E8_AGENCIA","E8_CONTA"})
	oTable:create()

	aEval(aField,{|x| cField += Alltrim(x[1])+"," })
	cField := Left(cField,Len(cField)-1)

	cQuery += "INSERT INTO "+oTable:getRealName()+" ("+cField+")"
	cQuery += " SELECT "+cField
	cQuery += " FROM "+RetSqlName("SE8")+" A"
	cQuery += " JOIN ("
	cQuery += 	" SELECT E8_FILIAL [FILIAL], E8_BANCO [BANCO], E8_AGENCIA [AGENCIA], E8_CONTA [CONTA], MAX(E8_DTSALAT) [DTSALAT]"
	cQuery += 	" FROM "+RetSqlName("SE8")
	cQuery += 	" WHERE D_E_L_E_T_=' '"
	cQuery += 	" GROUP BY E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA"
	cQuery += " ) B"
	cQuery += " ON A.E8_FILIAL		= B.FILIAL "
	cQuery += 	" AND A.E8_BANCO	= B.BANCO"
	cQuery += 	" AND A.E8_AGENCIA	= B.AGENCIA"
	cQuery += 	" AND A.E8_CONTA	= B.CONTA"
	cQuery += 	" AND A.E8_DTSALAT	= B.DTSALAT"
	cQuery += 	" AND A.D_E_L_E_T_	= ' '"
	xRet := TcSqlExec(cQuery)

	(oTable:getAlias())->( dbGotop() )
return oTable
