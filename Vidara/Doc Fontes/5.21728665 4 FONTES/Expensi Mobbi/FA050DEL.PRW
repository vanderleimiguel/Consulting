#Include 'Totvs.ch'

/*/{Protheus.doc} Z_VDCFG2
Ponto de entrada de confirma��o de exclus�o de titulis - FINA050 - Contas a Pagar
Este programa valida se o usu�rio tem permiss�o para excluir um t�tulo no contas a pagar
@author Elton Zaniboni
@since 08/10/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function FA050DEL()

	Local lRet      := .T.
	Local cHistor   := "TIT CRIADO AUTOM PELA Z_VDFIN3"

	If !cusername $ GetNewPar("ZZ_XUSREXC")
		If Alltrim(SE2->E2_HIST) == Alltrim(cHistor)
			Help( ,, 'FA050DEL',, "O seu usu�rio n�o ter permiss�o para exclus�o de um t�tulo que foi gerado atrav�s da rotina 'Monitor de Integra��o Expense Mobi'.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Solicite para a pessoa respons�vel, ou pe�a para incluir o seu usu�rio no par�metro customizado 'ZZ_XUSREXC'."})
			lRet    := .F.
		EndIf
	EndIf

	If cusername $ GetNewPar("ZZ_XUSREXC")
		If Alltrim(SE2->E2_HIST) == Alltrim(cHistor)

			If MsgYesNo("Verificamos que seu usu�rio possui permiss�o para exclus�o de t�tulos atrav�s da rotina 'Monitor de Integra��o Expense Mobi'. Deseja realmente exclui-lo ?", "Aten��o")
				lRet    := .T.
			Else
				lRet    := .F.
			EndIf

		EndIf
	EndIf

Return lRet
