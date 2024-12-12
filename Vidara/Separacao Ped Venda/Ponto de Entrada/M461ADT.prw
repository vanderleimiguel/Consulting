#Include "Protheus.Ch"

/*/{Protheus.doc} M461ADT
O ponto de entrada Documento de Saída - Faturar Itens do Pedido de Venda
@author Wagner Neves
@since 11/12/2024
@version 1.0
@type function
/*/
User Function M461ADT()
    Local lRet  := .T.
    Local aArea := GetArea()

    //Verifica se existe customizacao de separacao de pedido de venda
    If ExistBlock("Z_BLQFAT")
        lRet    := U_Z_BLQFAT(PARAMIXB[1],PARAMIXB[2])
    EndIf

    RestArea(aArea)
Return lRet
