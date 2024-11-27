#Include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'prtopdef.ch'
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#include "TbiConn.ch"

//Variáveis Estáticas
Static cTitulo1 := "Cadastro de Consultas SQL x API"

/*/{Protheus.doc} Z_VDCFG1
Cadastro de Consultas SQL x API - ZZB 
Este programa monta a tela para a gravação das Queries que serão consultadas através do fonte VIDSQL01.
@author TOTVS Protheus
@since 23/09/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_VDCFG1()
	Local aArea   := GetArea()
	Local oBrowse
	Local cFunBkp := FunName()

	SetFunName("Z_VDCFG1")

	//Instânciando FWMBrowse - Somente com dicionário de dados
	oBrowse := FWMBrowse():New()

	//Setando a tabela de cadastro
	oBrowse:SetAlias("ZZB")   //ZZB

	//Setando a descrição da rotina
	oBrowse:SetDescription(cTitulo1)

	//Legendas
	oBrowse:AddLegend( "ZZB->ZZB_ATIVO = '1'", "GREEN",	"Consulta Ativa" )
	oBrowse:AddLegend( "ZZB->ZZB_ATIVO = '2'", "RED",	"Consulta Inativa" )

	//Filtrando
	//oBrowse:SetFilterDefault("ZZB->ZZ1_COD >= '000000' .And. ZZB->ZZB_COD <= 'ZZZZZZ'")

	//Ativa a Browse
	oBrowse:Activate()

	SetFunName(cFunBkp)
	RestArea(aArea)
Return Nil

/*/{Protheus.doc} MenuDef
Criação do menu MVC  
@author Elton Zaniboni   
@since 31/07/2016 
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function MenuDef()
	Local aRot1 := {}
	
	//Adicionando opções
	ADD OPTION aRot1 TITLE 'Visualizar' 				ACTION 'VIEWDEF.Z_VDCFG1' 	OPERATION MODEL_OPERATION_VIEW   		ACCESS 0 //OPERATION 1
	ADD OPTION aRot1 TITLE 'Legenda'    				ACTION 'u_zModLeg4()'       OPERATION 6                      		ACCESS 0 //OPERATION X
	ADD OPTION aRot1 TITLE 'Incluir'    				ACTION 'VIEWDEF.Z_VDCFG1' 	OPERATION MODEL_OPERATION_INSERT 		ACCESS 0 //OPERATION 3
	ADD OPTION aRot1 TITLE 'Alterar'    				ACTION 'VIEWDEF.Z_VDCFG1' 	OPERATION MODEL_OPERATION_UPDATE 		ACCESS 0 //OPERATION 4
	ADD OPTION aRot1 TITLE 'Excluir'    				ACTION 'VIEWDEF.Z_VDCFG1' 	OPERATION MODEL_OPERATION_DELETE 		ACCESS 0 //OPERATION 5

Return aRot1

/*/{Protheus.doc} ModelDef
Criação do modelo de dados MVC      
@author Elton Zaniboni   
@since 31/07/2016 
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function ModelDef()
	//Criação do objeto do modelo de dados
	Local oModel := Nil
	
	//Criação da estrutura de dados utilizada na interface
	Local oStZZB := FWFormStruct(1, "ZZB")
	
	//Editando características do dicionário
	//oStZZB:SetProperty('ZZB_VCPFCNP',   MODEL_FIELD_WHEN,    FwBuildFeature(STRUCT_FEATURE_WHEN,    '.T.'))                                 //Modo de Edição
	//oStZZB:SetProperty('ZZB_COD',   MODEL_FIELD_INIT,    FwBuildFeature(STRUCT_FEATURE_INIPAD,  'GetSXENum("ZZB", "ZZB_COD")'))         //Ini Padrão
	//oStZZB:SetProperty('ZZB_VNUMINT',  MODEL_FIELD_VALID,   FwBuildFeature(STRUCT_FEATURE_VALID,   'Iif(Empty(M->ZZB_DESCR), .F., .T.)'))   //Validação de Campo
	//oStZZB:SetProperty('ZZB_DESCR',  MODEL_FIELD_OBRIGAT, Iif(RetCodUsr()!='000000', .T., .F.) )                                         //Campo Obrigatório
	
	//Instanciando o modelo, não é recomendado colocar nome da user function (por causa do u_), respeitando 10 caracteres
	oModel := MPFormModel():New("VIDFINO",/*bPre*/, /*bPos*/,/*bCommit*/,/*bCancel*/) 
	
	//Atribuindo formulários para o modelo
	oModel:AddFields("FORMZZB",/*cOwner*/,oStZZB)
	
	//Setando a chave primária da rotina
	oModel:SetPrimaryKey({'ZZB_FILIAL','ZZB_CODIGO'})
	
	//Adicionando descrição ao modelo
	oModel:SetDescription(cTitulo1)
	
	//Setando a descrição do formulário
	oModel:GetModel("FORMZZB"):SetDescription(+cTitulo1)

	// Verificar se pode Excluir
    oModel:SetVldActive( { | oModel | fVldModel( oModel ) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
Criação da visão MVC    
@author Elton Zaniboni   
@since 31/07/2016 
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static Function ViewDef()
	//Local aStruZZB	:= ZZB->(DbStruct())
	
	//Criação do objeto do modelo de dados da Interface do Cadastro de Autor/Interprete
	Local oModel := FWLoadModel("Z_VDCFG1")
	
	//Criação da estrutura de dados utilizada na interface do cadastro de Autor
	Local oStZZB := FWFormStruct(2, "ZZB")  //pode se usar um terceiro parâmetro para filtrar os campos exibidos { |cCampo| cCampo $ 'SZZ1_NOME|SZZ1_DTAFAL|'}
	
	//Criando oView como nulo
	Local oView := Nil

	//Criando a view que será o retorno da função e setando o modelo da rotina
	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	//Atribuindo formulários para interface
	oView:AddField("VIEW_ZZB", oStZZB, "FORMZZB")
	
	//Criando um container com nome tela com 100%
	oView:CreateHorizontalBox("TELA",100)
	
	//Colocando título do formulário
	//oView:EnableTitleView('VIEW_ZZB', 'Dados - '+cTitulo1 ) //  ESZ - TIREI AQUI  
	
	//Força o fechamento da janela na confirmação
	oView:SetCloseOnOk({||.T.})
	
	//O formulário da interface será colocado dentro do container
	oView:SetOwnerView("VIEW_ZZB","TELA")
	
	/*
	//Tratativa para remover campos da visualização
	For nAtual := 1 To Len(aStruZZB)
		cCampoAux := Alltrim(aStruZZB[nAtual][01])
		
		//Se o campo atual não estiver nos que forem considerados
		If Alltrim(cCampoAux) $ "ZZ1_COD;"
			oStZZB:RemoveField(cCampoAux)
		EndIf
	Next
	*/
Return oView

/*/{Protheus.doc} zMod2Leg
Função para mostrar a legenda
@author Elton Zaniboni
@since 31/07/2016
@version 1.0
	@example
	u_zMod2Leg()
/*/

/*/{Protheus.doc} zModLeg4
Função para mostrar a legenda
@author Elton Zaniboni   
@since 31/07/2016 
@version 1.0 
@type function
@revision Wagner Neves
/*/  
User Function zModLeg4()

	Local aLegenda := {}

	//Monta as cores
	//AADD(aLegenda,{"BR_AMARELO",	"(0) - Pendente Integração FIN."})
	AADD(aLegenda,{"BR_VERDE",		"Consulta Ativa."})
	AADD(aLegenda,{"BR_VERMELHO",	"Consulta Inativa."})

	BrwLegenda(cTitulo1, "Status", aLegenda)
Return

/*/{Protheus.doc} fVldModel
Valida regra
@author Elton Zaniboni   
@since 31/07/2016 
@version 1.0 
@type function
@revision Wagner Neves
/*/
STATIC Function fVldModel( oMdl )

	LOCAL lRet			:= .T.
	LOCAL nOperation 	:= oMdl:GetOperation()

	//VALIDANDO REGRA DE ALTERAÇÃO
	If nOperation == MODEL_OPERATION_DELETE

	Endif

Return( lRet )
