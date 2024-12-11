#INCLUDE "Protheus.ch"
#INCLUDE 'fileio.ch'

/*/{Protheus.doc} Z_MANUZC1
Função para efetuar manutenção na tabela ZC1
@author Wagner Neves
@since 30/11/2024
@version 1.0
@type function
/*/
User Function Z_MANUZC1()
    Local aArea       	:= GetArea()
    Local cTabela     	:= "ZC1"
	Local aIndex 		:= {}
    Private cCadastro 	:= "Documentos das Nao Conformidades"
    Private aRotina   	:= {}
	Private bFiltraBrw 	:= { || FilBrowse( cTabela , @aIndex) }

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
    // aAdd(aRotina,{"Incluir",    "AxInclui", 0, 3})
    // aAdd(aRotina,{"Alterar",    "AxAltera", 0, 4})
    aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})

	 //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
    	
    //Montando o Browse
	Eval( bFiltraBrw )
    mBrowse(6, 1, 22, 75, cTabela)
	EndFilBrw( cTabela , @aIndex )
     
    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)

Return
