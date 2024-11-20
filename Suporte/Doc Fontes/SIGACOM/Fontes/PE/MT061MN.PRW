#INCLUDE "TOTVS.CH"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} MT061MN
Ponto de entrada para Adição de botões ao aRotina MATA061-AMARRACAO PRODUTO X FORNECEDOR
@author Abel Ribeiro
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT061MN()

	aAdd(aRotina, {"Pedidos em Aberto",	"U_ZCONPEDA()", 0, 5, 0 , Nil })

Return


User Function FILSA5()

	Local cFor  := ""
	Local nPosDKD   := ""
	Local nPosProd  := ""
	Local cCodPRD   := ""
	Local cFiltro   := ""

	Default aColsDKD := {}

	IF FUNNAME() == "MATA121"

		cFor  := CA120FORN
		cloja := CA120LOJ

		nPosProd  := AScan(aHeader, {|x| AllTrim(x[2]) == "C7_PRODUTO"})

		IF nPosProd > 0
			cCodPRd := aCols[n,nPosProd]
		Endif

		cFiltro := "@#SA5->A5_FILIAL = '"+FwxFilial('SA5')+"' .AND. SA5->A5_FORNECE == '"+cFor+"' .AND. SA5->A5_LOJA == '"+cLOja+"' .AND. SA5->A5_PRODUTO == '"+ cCodPRd+"'@#"

	Else
		nPosDKD := GdFieldPos("DKD_CODIGO",aHeadDKD)

		IF nPosDKD > 0
			cCodPRd := oGetDKD:aCols[oGetDKD:nAt,nPosDKD]
		Endif

		cFor  := ca100for
		cloja := cLoja

		cFiltro := "@#SA5->A5_FILIAL = '"+FwxFilial('SA5')+"' .AND. SA5->A5_FORNECE == '"+cFor+"' .AND. SA5->A5_LOJA == '"+cLOja+"' .AND. SA5->A5_PRODUTO == '"+ cCodPRd+"'@#"
		//SET FILTER TO &cFiltro

	endif
Return(cFiltro)
