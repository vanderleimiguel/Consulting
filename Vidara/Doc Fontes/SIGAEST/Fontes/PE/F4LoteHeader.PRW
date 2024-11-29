#Include 'Protheus.ch'

/*/{Protheus.doc} F4LoteHeader
Função que retorna fabricante de loja na tabela Z42
@author Totvs
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function F4LoteHeader()

	Local aHeaderF4 := PARAMIXB[3]

	Aadd(aHeaderF4, 'Cod. Fabricante')
	Aadd(aHeaderF4, 'Loja Fabricante')

Return(aHeaderF4)
