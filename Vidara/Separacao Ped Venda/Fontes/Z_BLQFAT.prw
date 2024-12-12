#Include "Protheus.Ch"

/*/{Protheus.doc} Z_BLQFAT
Funcao de bloqueio de faturamento
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function Z_BLQFAT(cPedido, cItem)
    Local lRet      := .T.
    Default cItem   := ""

    If !Empty(cPedido) .AND. Empty(cItem)
        SC9->(DbSetOrder(1))
        If SC9->(DbSeek(xFilial("SC9")+cPedido))
            While cPedido = SC9->C9_PEDIDO
                If SC9->C9_ZZFASE = "L" .OR. SC9->C9_ZZFASE = "B"
                    lRet    := .F.
                    FWAlertInfo("O pedido esta bloqueado por separacao", "Z_BLQFAT - Mensagem ...")
                    Exit
                EndIf
            SC9->(DbSkip())
            EndDo
        EndIf
    elseif !Empty(cPedido) .AND. !Empty(cItem)
        SC9->(DbSetOrder(1))
        If SC9->(DbSeek(xFilial("SC9")+cPedido+cItem))
            If SC9->C9_ZZFASE = "L" .OR. SC9->C9_ZZFASE = "B"
                lRet    := .F.
                FWAlertInfo("O pedido esta bloqueado por separacao", "Z_BLQFAT - Mensagem ...")
            EndIf
        EndIf
    EndIf

Return lRet
