#include "protheus.ch"

/*/{Protheus.doc} TxtToJson
Gera Json Object atraves de um Json em TXT
@author Vanderlei Miguel
@since 17/06/2024
@version 1.0
@type function
/*/
User Function TxtToJson()

	Local cFile := 'c:\temp\json.txt'
	Local cJsonStr,oJson

    // Le a string JSON do arquivo do disco 
	cJsonStr := readfile(cFile)

    // Cria o objeto JSON e popula ele a partir da string
    oJson := JSonObject():New()
    cErr  := oJSon:fromJson(cJsonStr)

    If !empty(cErr)
        MsgStop(cErr,"JSON PARSE ERROR")
        Return
    Endif

    _nnj    := len(ojson["items"][1]["paymentGroups"])
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
