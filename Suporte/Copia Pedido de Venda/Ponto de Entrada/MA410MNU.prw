#INCLUDE "TOTVS.CH"

/*/
{Protheus.doc} MA410MNU
Ponto de entrada para adicionar botoes no pedido de venda ( MATA410 )
@author  Wagner Neves
@since   25/09/2024
@version 1.0
/*/
User Function MA410MNU()

	//Botao de copia multipla de pedidos de venda
	If ExistBlock("XCOPMUL")
		aAdd(aRotina, {"Copia Multipla"    , "U_XCOPMUL"	   , 0, 6, 0, NIL} )
	Endif

Return
