#Include 'Protheus.ch'
#Include 'RwMake.ch'
#Include 'TopConn.ch'
#Include "FWAdapterEAI.ch"

/*
{Protheus.doc} MATA410B()
	Rastreabilidade de pedidos de compra e venda                                
			
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	17/03/2013
*/

Function MATA410B()

FwIntegDef("MATA410B")

Return

/*
{Protheus.doc} IntegDef(cXML,nTypeTrans,cTypeMessage,cVersion)
	Rastreabilidade de pedidos de compra e venda                                
		
	@param	cXML      		Conteudo xml para envio/recebimento
	@param nTypeTrans		Tipo de transacao. (Envio/Recebimento)              
	@param	cTypeMessage  Tipo de mensagem. (Business Type, WhoIs, etc)
	@param	cVersion		Versão em uso
	
	@retorno aRet			Array contendo o resultado da execucao e a mensagem Xml de retorno.
				aRet[1]	(boolean) Indica o resultado da execução da função
				aRet[2]	(caracter) Mensagem Xml para envio                             
	
	@author	Rodrigo Machado Pontes
	@version	P11
	@since	17/03/2013
*/

Static Function IntegDef(xEnt, nTypeTrans, cTypeMessage, cVersion, cTransaction, lJSon)

	Local aRet := {}
	
	Default cTransaction := ""
	Default lJSon		 := .F.
	
	cVersion := AllTrim(cVersion)
	
	If lJSon .And. FindFunction( "MATI410BO")
		aRet := MATI410BO(xEnt, nTypeTrans, cTypeMessage, cVersion)
	Else
		aRet := MATI410B( xEnt, nTypeTrans, cTypeMessage, cVersion)
	EndIf	

Return aRet
