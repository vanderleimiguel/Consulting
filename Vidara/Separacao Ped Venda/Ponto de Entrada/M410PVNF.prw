#Include "Protheus.Ch"

/*/{Protheus.doc} M410PVNF
P.E de validacao Executado antes da rotina de geração de NF's
@author Wagner Neves
@since 11/12/2024
@version 1.0
@type function
/*/
User Function M410PVNF()
    Local lRet  := .T.
    Local aArea := GetArea()

    //Verifica se existe customizacao de separacao de pedido de venda
    If ExistBlock("Z_BLQFAT")
        lRet    := U_Z_BLQFAT(SC5->C5_NUM)
    EndIf

    RestArea(aArea)
Return lRet
