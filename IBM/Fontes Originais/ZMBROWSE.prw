#INCLUDE "TOTVS.CH"

User Function ZMBROWSE()
    Local aArea       := GetArea()
    Local cTabela     := "SF2"
    Private aCores    := {}
    Private cCadastro := "Tabela SF2"
    Private aRotina   := {}
     
    //Montando o Array aRotina, com funções que serão mostradas no men
    aAdd(aRotina,{"Colsultar e enviar NFS-e", "U_CONSTXML", 0, 8})
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
 
    //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
     
    //Montando o Browse
    mBrowse(6, 1, 22, 75, cTabela, , , , , , aCores )
     
    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)
Return
