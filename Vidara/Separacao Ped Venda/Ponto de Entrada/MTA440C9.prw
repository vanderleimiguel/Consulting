#Include "Protheus.Ch"

/*/{Protheus.doc} MTA440C9
P.E que acorre apos gravação de cada linha da SC9 na liberacao do pedido de venda.
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function MTA440C9()

    //Verifica se existe customizacao de separacao de pedido de venda
    If ExistBlock("Z_MTA440C9") .AND. ExistBlock("Z_BRWPEDL")
        U_Z_MTA440C9()
    EndIf
Return
