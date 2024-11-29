#Include 'Protheus.ch'

/*/{Protheus.doc} F4LoteArray
Função que retorna fabricante de loja na tabela Z42
@author Totvs
@since 23/05/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function F4LoteArray()

	Local aArrayF4 := PARAMIXB[5]

	DBSELECTAREA("Z42")
	DBSETORDER(1)
	IF Z42->(dbSeek(xFilial("Z42")+aArrayF4[2]+ALLTRIM(aArrayF4[1])))
		Aadd(aArrayF4, Z42->Z42_FABRIC)
		Aadd(aArrayF4, Z42->Z42_LJFABR)
	Else
		Aadd(aArrayF4, ' ')
		Aadd(aArrayF4, ' ')

	Endif

Return(aArrayF4)
