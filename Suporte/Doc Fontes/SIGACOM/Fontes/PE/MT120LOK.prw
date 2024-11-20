#INCLUDE 	"PROTHEUS.CH"
#INCLUDE 	"TOTVS.CH"

/*/{Protheus.doc} MT120LOK
Ponto de entrada para validação da linha do Pedido de compra MATA120 - PEDIDO DE COMPRAS
@author Abel Ribeiro
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MT120LOK()

	Local lRet		:= .T.
	Local lDeleted	:= .F.
	Local nPosProd  := AScan(aHeader, {|x| AllTrim(x[2]) == "C7_PRODUTO"})
	Local nPosFab   := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ZZCDFAB"} )
	Local nPosLfab  := aScan(aHeader, {|x| AllTrim(x[2]) == "C7_ZZLJFAB"} )
	Local nItem     := 0
	Local lBloq		:= If(SuperGetMV("ZZ_BLQFABP")== "S",.T.,.F.)

	//GAP ID: 103
	// Tratamento para verificar se a linha esta ativa ou apagada.

	If ValType(aCols[n,Len(aCols[n])]) == "L"
		lDeleted := aCols[n,Len(aCols[n])]
	EndIf

	If AllTrim(FunName()) $ "MATA120|MATA121" .And. !lDeleted

		FOR nItem :=1 TO LEN(ACOLS)

			If !Empty(aCols[nItem][nPosFab])
				// Posiciona no produto x Fornecedor
				SA5->(DBSetOrder(1))
				SA5->(DBSeek(xFilial("SA5") +  cVALTOCHAR(CA120FORN) + cVALTOCHAR(CA120LOJ) + cVALTOCHAR(aCols[nItem][nPosProd])+ cVALTOCHAR(aCols[nItem][nPosFab])+cVALTOCHAR(aCols[nItem][nPosLfab])))

				IF SA5->A5_ZZHOMOL = '2'
					FWALERTERROR("Produto "+ cVALTOCHAR(aCols[nItem][nPosProd]) + " Não está Homologado para este Fabricante","MT120LOK - Fabricante não Homologado ")
					IF lBloq
						lRet := .F.
					else
						Lret := .T.
					EndIf
				EndIf
			Endif
		NEXT
	EndIf

Return lRet
