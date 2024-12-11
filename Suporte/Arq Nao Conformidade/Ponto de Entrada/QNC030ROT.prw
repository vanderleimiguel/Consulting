#INCLUDE "TOTVS.CH"

/*/
{Protheus.doc} QNC030ROT 
Ponto de entrada para Inclusão de Botões
@author  Wagner Neves
@since   30/11/2024
@version 1.0
/*/
User Function QNC030ROT()
    Local aRotina:={}

    If ExistBlock("Z_ABREARQ")
        aadd(aRotina,{"Abre Arquivos","U_Z_ABREARQ", 0 , 4, 0 , Nil})
    EndIf
    If ExistBlock("Z_GRAVARQ")
        aadd(aRotina,{"Grava Arquivos","U_Z_GRAVARQ", 0 , 4, 0 , Nil})
    EndIf
Return(aRotina)
