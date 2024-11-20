#INCLUDE "TOTVS.CH"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} MT140TOK
Ponto de entrada para validação Valida informações MATA140 - PRE DOCUMENTO DE ENTRADA
@author Abel Ribeiro
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
USER FUNCTION MT140TOK()
	Local _lRet 		:= .T.
	Local _aArea    	:= GetArea()
	Local _cFornece		:= CA100FOR
	Local _cLoja		:= CLOJA
	Local nPosProduto	:= GDFieldPos("D1_COD")
	Local nPosFabric	:= GdFieldPos("DKD_ZZFABR",aHeadDKD)
	Local nPosLjFab		:= GdFieldPos("DKD_ZZLJFA",aHeadDKD)
	Local nItem      	:= 0
	Local lBloq			:= If(SuperGetMV("ZZ_BLQFABD")== "S",.T.,.F.)
	Local lRet 			:= .T.
	Local cProd			:= " "

	if funname() <> "EICDI154"
		For nItem := 1 To Len(aCols)
			If !aCols[nItem][Len(aCols[nItem])]
				If !Empty(aCols[nItem,nPosProduto])
					If nPosFabric > 0 .and.  !empty(aColsdkd[nItem,nPosFabric])
						SA5->(dbSetOrder(1) )
						//If  SA5->(MsSeek(xFilial("SA5") + _cFornece + _cLOJA +aCols[nItem,nPosProduto] + oGetDKD:aCols[oGetDKD:nAt,nPosFabric] + oGetDKD:aCols[oGetDKD:nAt,nPosLjFab] ))
						If  SA5->(MsSeek(xFilial("SA5") + _cFornece + _cLOJA +aCols[nItem,nPosProduto] + aColsdkd[nItem,nPosFabric] + aColsdkd[nItem,nPosLjFab] ))
							If SA5->A5_ZZHOMOL = "2"
								IF Empty(cProd)
									cProd := aCols[nItem,nPosProduto]
								else
									cProd := alltrim(cProd) + " / " + alltrim(aCols[nItem,nPosProduto])
								Endif
								lRet := .F.
								//Exit
							EndIf
						Endif
					endif
				Endif
			Endif
		Next nItem

		if !lRet
			FWALERTERROR("Produto "+ cProd + " Não está Homologado para este Fabricante","MT140LOK - Verificar Produto ")
			IF lBloq
				_lRet := .F.
			else
				_lRet := .T.
			EndIf
		Endif
	Endif
	RestArea(_aArea)

Return(_lRet)




