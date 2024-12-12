#Include "Protheus.Ch"

/*/{Protheus.doc} Z_MTA440C9
Funcao chamada do P.E MTA440C9
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function Z_MTA440C9()
    Local nIntWMS		:= GETMV( "MV_INTWMS" )
    Local cPedido       := SC9->C9_PEDIDO
    Local cItem         := SC9->C9_ITEM
    Local cProduto      := SC9->C9_PRODUTO

    //Verifica condições para bloquear pedido para liberacao e separacao
    If !nIntWMS 
        SC5->(DbSetOrder(1))
        If SC5->(DbSeek(xFilial("SC5")+cPedido))
            If SC5->C5_TIPO = "N"
                SC6->(DbSetOrder(1))
                If SC6->(DbSeek(xFilial("SC6")+cPedido+cItem+cProduto))
                    SF4->(DbSetOrder(1))
                    If SF4->(DbSeek(xFilial("SF4")+SC6->C6_TES)) 
                        If SF4->F4_ESTOQUE  = "S"
                            RecLock("SC9",.F.)
                                SC9->C9_ZZFASE  := "B"
                            SC9->(MsUnlock())
                        EndIf
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf
    
Return
