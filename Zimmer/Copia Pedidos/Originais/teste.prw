#INCLUDE "totvs.ch"

/*/{Protheus.doc} GMMA410BUT
	O ponto de entrada GMMA410BUT permite adicionar bot�es de usu�rio na enchoice.
	GMMA410BUT - Adi��o de bot�es na Enchoice ( [ nOpc ], [ M->C5_NUM ], [ M->C5_CLIENTE ], [ M->C5_LOJACLI ] ) --> aButtonUsr
	@type function
	@version  1.0
	@author User
	@since 15/12/2023
	@link https://tdn.totvs.com/pages/releaseview.action?pageId=6784493
	@return variant, aButtons
/*/
User Function GMMA410BUT()
	// Grava posicionamento das tabelas antes do reposicionamento da rotina.

	Local aButtons := {}


		aAdd( aButtons , { "KIT" , {|| U_fWMEKit()  } ,"TELA KIT" , "TELA KIT" } )


Return(aButtons)
