//Bibliotecas
#Include "Totvs.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} User Function zVid0046
Teste MarkBrowse
@author Daniel Atilio
@since 20/07/2022
@version 1.0
@type function
@obs Codigo gerado automaticamente pelo Autumn Code Maker
@see http://autumncodemaker.com
/*/

User Function AllFiliais()
	Local nFil
	Local nEmp
	Local cFilBck       := cFilAnt
	Local cEmpBck       := cEmpAnt
	Private _cEmp     	:= "01"
	Private _cFil     	:= "0101"
	Private aEmpAux   	:= FWAllGrpCompany()
	Private aFilAux   	:= {}

	Default aParams     := {"01","0101"}

    For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			aParams	:= {aEmpAux[nEmp], aFilAux[nFil] }
			_cEmp   := aParams[01]
			_cFil   := aParams[02]
        Next
        nX := 1
    Next
    
    //Voltando backups
	cEmpAnt := cEmpBck
	cFilAnt := cFilBck

Return
// //Percorrendo os grupos de empresa
// 	For nGrp := 1 To Len(aUnitNeg)
// 		cUnidNeg := aUnitNeg[nGrp]

// 		//Percorrendo as empresas
// 		For nEmp := 1 To Len(aEmpAux)
// 			cEmpAnt := aEmpAux[nEmp]
// 			aFilAux := FWAllFilial(cEmpAnt)
// 			//Percorrendo as filiais listadas
// 			For nAtu := 1 To Len(aFilAux)
// 				//Se o tamanho da filial for maior, atualiza
// 				If Len(cFilAnt) > Len(aFilAux[nAtu])
// 					cFilAnt := cEmpAnt + aFilAux[nAtu]
// 				Else
// 					cFilAnt := aFilAux[nAtu]
// 				EndIf

// 				//Posiciono na empresa (para poder pegar o ident)
// 				SM0->(DbGoTop())
// 				SM0->(DbSeek(cUnidNeg+cFilAnt)) //é utilizado o 01, por grupo de empresas, caso necessário rotina pode ser adaptada

// 				//......................
// 				//Fazer tratamentos necessários neste ponto, se for consultas SQL lembrar de utilizar RetSQLName e FWxFilial
// 				//......................
// 			Next
// 		Next
// 	Next

// //Voltando backups
// 	cEmpAnt := cEmpBk
// 	cFilAnt := cFilBk
// 	RestArea(aAreaM0)
Return
