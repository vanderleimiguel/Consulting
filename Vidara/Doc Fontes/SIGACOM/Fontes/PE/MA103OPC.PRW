#INCLUDE "Protheus.ch"

/*/{Protheus.doc} MA103OPC
Ponto de entrada para Adição de itens no menu da rotina MATA103-DOCUMENTO ENTRADA
@author Abel Ribeiro
@since 05/05/2023
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function MA103OPC()

	Local aRet := {}

	aAdd(aRet,{'Impressão Etiqueta Recebimento', 'U_ZWMSETQ1', 0, 5})

Return aRet
