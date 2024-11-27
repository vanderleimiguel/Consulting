#Include 'Totvs.ch'

/*/{Protheus.doc} Z_VDCFG2
Ponto de entrada de confirmação de exclusão de titulis - FINA050 - Contas a Pagar
Este programa valida se o usuário tem permissão para excluir um título no contas a pagar
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
			Help( ,, 'FA050DEL',, "O seu usuário não ter permissão para exclusão de um título que foi gerado através da rotina 'Monitor de Integração Expense Mobi'.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Solicite para a pessoa responsável, ou peça para incluir o seu usuário no parâmetro customizado 'ZZ_XUSREXC'."})
			lRet    := .F.
		EndIf
	EndIf

	If cusername $ GetNewPar("ZZ_XUSREXC")
		If Alltrim(SE2->E2_HIST) == Alltrim(cHistor)

			If MsgYesNo("Verificamos que seu usuário possui permissão para exclusão de títulos através da rotina 'Monitor de Integração Expense Mobi'. Deseja realmente exclui-lo ?", "Atenção")
				lRet    := .T.
			Else
				lRet    := .F.
			EndIf

		EndIf
	EndIf

Return lRet
