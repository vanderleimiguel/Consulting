#INCLUDE 	"PROTHEUS.CH"
#INCLUDE 	"TOTVS.CH"

/*/{Protheus.doc} MTA103OK
Ponto de entrada Altera o resultado da validação padrão para inclusão/alteração de registros de entrada MATA103 - DOCUMENTO DE ENTRADA
@author Abel Ribeiro
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MTA103OK()

	Local lRet			:= ParamIxb[1] //.T.
	Local lDeleted		:= .F.
	Local nPosProd  	:= Ascan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"})
	Local nPosLoj   	:= AScan(aHeader,{|x| AllTrim(x[2]) == "D1_LOJA"})
	Local nPosFCI   	:= AScan(aHeader,{|x| AllTrim(x[2]) == "D1_FCICOD"})
	Local nPosFabric	:= GdFieldPos("DKD_ZZFABR",aHeadDKD)
	Local nPosLjFab		:= GdFieldPos("DKD_ZZLJFA",aHeadDKD)
	Local lBloq			:= If(SuperGetMV("ZZ_BLQFABD")== "S",.T.,.F.)
	Local nPosClas  	:= AScan(aHeader,{|x| AllTrim(x[2]) == "D1_CLASFIS"})
	Local cGRPNAC		:= AllTrim(GetMv("ZZ_GRPNAC",.T.,"0;4;5;6;7"))
	Local cGRPIMP		:= AllTrim(GetMv("ZZ_GRPIMP",.T.,"1;2;3;8"))
	Local nItem     	:= 0
	Local _cFornece 	:= CA100FOR

	If ValType(aCols[n,Len(aCols[n])]) == "L"
		lDeleted := aCols[n,Len(aCols[n])]
	EndIf

	If AllTrim(FunName()) $ "MATA103" .And. !lDeleted

		FOR nItem :=1 TO LEN(ACOLS)

			// Posiciona no produto
			SB1->(DBSetOrder(1))
			SB1->(DBSeek(xFilial("SB1") + cVALTOCHAR(aCols[nItem][nPosProd]) ))

			If nPosFabric > 0 .and. !empty(oGetDKD:aCols[oGetDKD:nAt,nPosFabric])
				// Posiciona no produto x Fornecedor
				SA5->(DBSetOrder(1))
				If  SA5->(MsSeek(xFilial("SA5") + cVALTOCHAR(_cFORNECE) + cVALTOCHAR(aCols[nItem][nPosLoj]) +cVALTOCHAR(aCols[nItem][nPosProd]) + oGetDKD:aCols[oGetDKD:nAt,nPosFabric] + oGetDKD:aCols[oGetDKD:nAt,nPosLjFab] ))
					If SA5->A5_ZZHOMOL = "2"
						FWAlertInfo("Este Produto "+ cVALTOCHAR(aCols[nItem][nPosProd]) + " não está homologado para este fabricante.", "A103CLAS - Classificação Nota")
						//lRet := .F.
						IF lBloq
							lRet := .F.
						else
							Lret := .T.
						EndIf
					Endif
				Endif
			Endif

			IF SUBSTR(aCOLS[nItem][nPosClas],1,1) $ ('1/2/3/8') .and. empty(aCols[nItem][nPosFCI])

				FWAlertInfo("Atenção. Produto Importado, Informar o código da Ficha FCI "+ cVALTOCHAR(aCols[nItem][nPosProd]), "A103CLAS - Classificação Nota")
				lRet := .F.
			EndIf

			IF SB1->B1_ORIGEM $ cGRPNAC
				IF !(SUBSTR(aCOLS[nItem][nPosClas],1,1) $ cGRPNAC)
					FWAlertInfo("Atenção. Origem do Produto "+ cVALTOCHAR(aCols[nItem][nPosProd]) + "diferente do CST informado na Nota ", "A103CLAS - Classificação Nota")
					lRet := .F.
				Endif
			Elseif SB1->B1_ORIGEM $ cGRPIMP
				IF !(SUBSTR(aCOLS[nItem][nPosClas],1,1) $ cGRPIMP)
					FWAlertInfo("Atenção. Origem do Produto "+ cVALTOCHAR(aCols[nItem][nPosProd]) + "diferente do CST informado na Nota ", "A103CLAS - Classificação Nota")
					lRet := .F.
				Endif
			ENDIF
		NEXT
	EndIf
Return lRet
