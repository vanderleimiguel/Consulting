#Include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'prtopdef.ch'
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#include "TbiConn.ch"

Static cTitulo1 := "Monitor de Integracao Expense Mobi"

/*/{Protheus.doc} Z_VDFIN1
Monitor de Integracao Expense Mobi - ZZA 
Este programa monta uma tela de monitor de integracao
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_VDFIN1()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("Z_VDFIN1")

	//Inst�nciando FWMBrowse - Somente com dicion�rio de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("ZZA")   //ZZA

	//Setando a descri��o da rotina
	oBrowse:SetDescription(cTitulo1)

	//Legendas
	oBrowse:AddLegend( "ZZA->ZZA_STATUS = '0'", "YELLOW","Aguardando Integracao FIN" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS = '1'", "GREEN",	"Integrado com sucesso FIN" )
	oBrowse:AddLegend( "ZZA->ZZA_STATUS = '2'", "RED",	"Erro Integracao FIN" )


	//Filtrando
	//oBrowse:SetFilterDefault("ZZA->ZZ1_COD >= '000000' .And. ZZA->ZZA_COD <= 'ZZZZZZ'")

	//Ativa a Browse
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Criacao de Menu
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function MenuDef()
	Local aRot1 := {}
	
	//Adicionando op��es
	ADD OPTION aRot1 TITLE 'Visualizar' 					ACTION 'VIEWDEF.Z_VDFIN1' 	OPERATION MODEL_OPERATION_VIEW   		ACCESS 0 //OPERATION 1
	ADD OPTION aRot1 TITLE 'Legenda'    					ACTION 'u_zMod2Leg()'       OPERATION 6                      		ACCESS 0 //OPERATION X
	ADD OPTION aRot1 TITLE 'Incluir'    					ACTION 'VIEWDEF.Z_VDFIN1' 	OPERATION MODEL_OPERATION_INSERT 		ACCESS 0 //OPERATION 3
	ADD OPTION aRot1 TITLE 'Alterar'    					ACTION 'VIEWDEF.Z_VDFIN1' 	OPERATION MODEL_OPERATION_UPDATE 		ACCESS 0 //OPERATION 4
	ADD OPTION aRot1 TITLE 'Excluir'    					ACTION 'VIEWDEF.Z_VDFIN1' 	OPERATION MODEL_OPERATION_DELETE 		ACCESS 0 //OPERATION 5
	ADD OPTION aRot1 TITLE '1-Integr.API Expense Mobi' 		ACTION 'U_Z_VDFIN2()'       OPERATION MODEL_OPERATION_INSERT   		ACCESS 0 //OPERATION X
	ADD OPTION aRot1 TITLE '2-Integr.Cta Pagar Protheus' 	ACTION 'U_Z_VDFIN3()'       OPERATION 8                      		ACCESS 0 //OPERATION X

Return aRot1

/*/{Protheus.doc} ModelDef
Criacao de modelo de dados
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function ModelDef()
	//Cria��o do objeto do modelo de dados
	Local oModel := Nil
	
	//Cria��o da estrutura de dados utilizada na interface
	Local oStZZA := FWFormStruct(1, "ZZA")
	
	//Editando caracter�sticas do dicion�rio
	oStZZA:SetProperty('ZZA_VCPFCN',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))                                 //Modo de Edi��o
	//oStZZA:SetProperty('ZZA_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZA", "ZZA_COD")'))         //Ini Padr�o
	//oStZZA:SetProperty('ZZA_VNUMINT',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZZA_DESCR), .F., .T.)'))   //Valida��o de Campo
	//oStZZA:SetProperty('ZZA_DESCR',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigat�rio
	
	//Instanciando o modelo, n�o � recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("VIDFINO",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formul�rios para o modelo
	oModel:AddFields("FORMZZA",/*cOwner*/,oStZZA)
	
	//Setando a chave prim�ria da rotina
	//oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_VCPFCN','ZZA_VNUMINT'})
	oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_VCPFCN'})
	
	//Adicionando descri��o ao modelo
	oModel:SetDescription(cTitulo1)
	
	//Setando a descri��o do formul�rio
	oModel:GetModel("FORMZZA"):SetDescription(+cTitulo1)

	// Verificar se pode Excluir
    oModel:SetVldActive( { | oModel | fVldModel( oModel ) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
Criacao de visao MVC
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function ViewDef()
	
	//Local aStruZZA	:= ZZA->(DbStruct())
	
	//Cria��o do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("Z_VDFIN1")
	
	//Cria��o da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZZA := FWFormStruct(2, "ZZA")  //pode se usar um terceiro par�metro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que ser� o retorno da fun��o e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formul�rios para interface
	oView:AddField("VIEW_ZZA", oStZZA, "FORMZZA")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando t�tulo do formul�rio
	//oView:EnableTitleView('VIEW_ZZA', 'Dados - '+cTitulo1 ) //  ESZ - TIREI AQUI  
	
	//For�a o fechamento da janela na confirma��o
	oView:SetCloseOnOk({||.T.})
	
	//O formul�rio da interface ser� colocado dentro do container
	oView:SetOwnerView("VIEW_ZZA","TELA")
	
	/*
	//Tratativa para remover campos da visualiza��o
	For nAtual := 1 To Len(aStruZZA)
		cCampoAux := Alltrim(aStruZZA[nAtual][01])
		
		//Se o campo atual n�o estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZZ1_COD;"
			oStZZA:RemoveField(cCampoAux)
		EndIf
	Next
	*/
Return oView

/*/{Protheus.doc} zMod2Leg
Funcao para mostrar legenda
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function zMod2Leg()
	Local aLegenda := {}

	//Monta as cores
	AADD(aLegenda,{"BR_AMARELO",	"(0) - Aguardando Integracao FIN."})
	AADD(aLegenda,{"BR_VERDE",		"(1) - Integrado com sucesso FIN."})
	AADD(aLegenda,{"BR_VERMELHO",	"(2) - Erro Integracao FIN."})


	BrwLegenda(cTitulo1, "Status", aLegenda)
Return

/*/{Protheus.doc} fVldModel
Criacao de modelo
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
STATIC Function fVldModel( oMdl )

	LOCAL lRet			:= .T.
	LOCAL nOperation 	:= oMdl:GetOperation()

	//VALIDANDO REGRA DE ALTERA��O
	If nOperation == MODEL_OPERATION_DELETE

		//Verifica se j� existe a integra��o com o Financeiro, se existir, n�o permite excluir a movimenta��o.
		If ZZA->ZZA_STATUS == '1'
			lRet := .F.
			//MsgAlert("Esse lan�amento j� foi integrado com o Financeiro: "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)+"Prefixo : "+ZZA->ZZA_PREFIX+" "+CHR(13)+CHR(10)+"N�mero: "+Alltrim(ZZA->ZZA_NUM)+" "+CHR(13)+CHR(10)+" Parcela: "+ZZA->ZZA_PARCEL+" "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)+" Tipo: "+ZZA->ZZA_TIPO+" "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)+"Por esse motivo, n�o ser� permitido a exclus�o deste registro. ","Aten��o")
			MsgAlert("Esse lancamento ja foi integrado com o Financeiro: "+CHR(13)+CHR(10)+""+CHR(13)+CHR(10)+"Por esse motivo, nao sera permitido a exclusao deste registro. ","Atencao")

		Endif

	Endif

Return( lRet )






