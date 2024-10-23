#include "protheus.ch"

/*/{Protheus.doc} MGFESTAG
Json Estoque
@author Vanderlei Miguel
@since 17/06/2024
@version 1.0
@type function
/*/
User Function MGFESTAG()

	Local cFile := 'c:\temp\jsonest.txt'
	Local cJsonStr,oJson
    Local nX, nY
    Local cIdProd   := ""
    Local cDtValid  := ""
    Local cDtProd   := ""
    Local nQtdNorm  := 0
    Local nPesoMed  := 0
    Local cTipoEst  := ""
    Local nQtdEst   := 0
    Local _cTipoEst := "A"

    // Le a string JSON do arquivo do disco 
	cJsonStr := readfile(cFile)

    // Cria o objeto JSON e popula ele a partir da string
    oJson := JSonObject():New()
    cErr  := oJSon:fromJson(cJsonStr)

    If !empty(cErr)
        MsgStop(cErr,"JSON PARSE ERROR")
        Return
    Endif

    For nX := 1 To Len(oJSon)
        cIdProd   := ojson[nX]["idProduto"]
        cDtValid  := ojson[nX]["dataValidade"]
        cDtProd   := ojson[nX]["dataProducao"]
        nQtdNorm  := ojson[nX]["quantidade"]
        nPesoMed  := ojson[nX]["pesoMedio"]
        If Len(ojson[nX]["tipoEstoques"]) <> 0
            For nY := 1 To Len(ojson[nX]["tipoEstoques"])
                cTipoEst  := ojson[nX]["tipoEstoques"][nY]["sigla"]
                
                If cTipoEst = _cTipoEst
                    nQtdEst   := ojson[nX]["tipoEstoques"][nY]["quantidade"]

                EndIf
            Next
        EndIf

    Next
Return

STATIC Function ReadFile(cFile)
    Local cBuffer := ''
    Local nH , nTam
    nH := Fopen(cFile)
    IF nH != -1
        nTam := fSeek(nH,0,2)
        fSeek(nH,0)
        cBuffer := space(nTam)
        fRead(nH,@cBuffer,nTam)
        fClose(nH)
    Else
        MsgStop("Falha na abertura do arquivo ["+cFile+"]","FERROR "+cValToChar(Ferror()))
    Endif

Return cBuffer
