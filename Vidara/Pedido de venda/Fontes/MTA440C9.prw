#Include "Protheus.Ch"

/*/{Protheus.doc} User Function MTA440C9
P.E que acorre apos gravação de cada linha da SC9 na liberacao do pedido de venda.
@author Leandro Campos
@since 28/11/2024
@version 1.0
@type function
/*/
User Function MTA440C9()

    //Gravo Logs da libercao
    RecLock("SC9",.F.)
        SC9->C9_XHRLIB  := Time()
	    SC9->C9_XUSLIB  := UsrRetName(RetCodUsr())
    SC9->(MsUnlock())

Return
