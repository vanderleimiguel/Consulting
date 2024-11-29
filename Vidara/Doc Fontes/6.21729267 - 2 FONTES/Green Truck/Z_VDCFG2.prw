#Include "TOTVS.ch"
#include "Topconn.ch"
#include "RESTFUL.CH"

/*/{Protheus.doc} Z_VDCFG2
Interface para geração de informações via Query por API via requisição REST.
Este programa gera o arquivo JSON baseado na query cadastrada na rotina VIDSQL02 no Protheus.
@author Elton Zaniboni
@since 23/09/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
WSRESTFUL Z_VDCFG2 DESCRIPTION "API REST Consulta API SQL Protheus" FORMAT APPLICATION_JSON

	WSDATA NAME      	AS CHARACTER  OPTIONAL
	WSDATA KEY		   	AS CHARACTER  OPTIONAL

	WSMETHOD GET ConsultaGenericaSQLAPI;
		DESCRIPTION "API utilizada para efetuar consulta Generica via SQL";
		WSSYNTAX "/consultar/apiqry/?{NAME}/?{KEY}";
		PATH "/consultar/apiqry/";
		TTALK "ConsultaApiQry";
		PRODUCES APPLICATION_JSON

END WSRESTFUL

WSMETHOD GET ConsultaApiQry HEADERPARAM NAME, KEY WSSERVICE Z_VDCFG2


	Local oResponse		:=	Nil
	Local aResponse		:=	{}
	Local oRetorno
	Local lRet			:=	.T.
	Local cQuery        := ""
	Local cAliasQRY
	Local cCodQry		:= ""
	Local cCodKey		:= ""
	Local aArrayAs		:= {}
	Local nI

	If ( ValType( self:NAME  ) == "C" .and. !Empty( self:NAME  ) )
		cCodQry := self:NAME

		if ( ValType( self:KEY  ) == "C" .and. !Empty( self:KEY  ) )
			cCodKey := self:KEY
		ENDIF

		dbSelectArea("ZZB")
		dbSetOrder( 2 )

		If dbSeek( xFilial("ZZB") + cCodQry + cCodKey )

			If ZZB->ZZB_ATIVO == '1'  //Só grava o conteúdo da Query na variável se a consulta estiver Ativa, caso contrario, ela não poderá ser consumida.
				cQuery := ZZB->ZZB_QUERY
			else
				cQuery := " "
			EndIf
		Endif

	ENDIF

	While .T.
		cAliasQRY := GetNextAlias()
		If !TCCanOpen(cAliasQRY) .And. Select(cAliasQRY) == 0
			Exit
		EndIf
	EndDo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.F.,.T.)
	DbSelectArea(cAliasQRY)
	(cAliasQRY)->(DbGoTop())

	for nI := 1 to fcount()
		varinfo(fieldname(nI),fieldget(ni))
		cContAs		:= fieldname(nI)
		aadd(aArrayAs, cContAs)
	next

	/*
	cQryTmp := cQuery
	For nQtdAs := 1 To fcount()
		nLenQry := len(cquery)
		nAs := At(" AS ", cQryTmp)
		nVirg := At(",", cQryTmp)
		cCpo1 := SUBSTR(cQryTmp, nAs+4, (nVirg - nAs-4))
		cQryTmp := Substr(cQryTmp, nVirg+1, nLenQry)
		aadd(aArrayAs, cCpo1)
	Next
	*/

	IF (cAliasQRY)->(EOF())
		(cAliasQRY)->(DbcloseArea())
		oResponse := JsonObject():New()
		oResponse["Resultado"]	:= {}
		self:SetResponse( oResponse:ToJson() )
		FreeObj( oResponse )
		oResponse := Nil
		Return( lRet )
	ELSE
		While !(cAliasQRY)->(EOF())

			nI 		:= 1
			nTamQry	:= fcount()

			varinfo(fieldname(nI),fieldget(nI))
			cContAs		:= fieldname(nI)
			cConteud	:= fieldget(nI)

			oRetorno  := nil
			oRetorno  := JsonObject():New()

			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]		  := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf
			If nI <= nTamQry
				oRetorno[aArrayAs[nI++]]          := Alltrim(fieldget(nI))
			EndIf

			aadd(aResponse,oRetorno)

			(cAliasQRY)->(dbskip())

		Enddo
		(cAliasQRY)->(DbcloseArea())

		oResponse := JsonObject():New()
		oResponse["Resultado"]	:= aResponse
		self:SetResponse( EncodeUTF8(oResponse:ToJson()) )
	ENDIF

	FreeObj( oResponse )
	oResponse := Nil

Return( lRet )
