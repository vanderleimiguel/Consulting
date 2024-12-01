#INCLUDE "TOTVS.CH"

/*/
{Protheus.doc} A410CONS
Ponto de entrada Inclusão de botões na enchoicebar
@author  Wagner Neves
@since   30/11/2024
@version 1.0
/*/
User Function A410CONS() as Array

    Local aBotoes as Array

    aBotoes := {}

    If ExistBlock("Z_ABREARQ")
        aAdd(aBotoes,{"Abre Arquivos", { || u_Z_ABREARQ() }, "Abre Arquivos"})
    EndIf
    If ExistBlock("Z_GRAVARQ")
        aAdd(aBotoes,{"Grava Arquivos", { || u_Z_GRAVARQ() }, "Grava Arquivos"})
    EndIf

Return aBotoes
