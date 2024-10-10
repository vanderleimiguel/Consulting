#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} FIRSTNFSE
Ponto de Entrada Inclui botões no aRotina FISA022
@author Wagner Neves
@since 09/10/2024
@version 1.0
@type function
/*/
User Function FIRSTNFSE()
    
    //Rotina de consulta e envio de xml e Nfs-e
    If ExistBlock("CONSTXML")
        aAdd( aRotina, {"Consultar e enviar NFS-e"  ,"U_CONSTXML", 0, 6, 0, NIL } )
    EndIf

Return( Nil )
