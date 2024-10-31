#include "protheus.ch"
/*/{Protheus.doc} GESTFIN4
	visualizar o cadastro de cliente
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function GESTFIN4(cTmp)
	local aSave		:= SA1->( getArea() )
	local cBkp		:= CFILANT
	local cCliente	:= (cTmp)->( E1_CLIENTE+E1_LOJA )
	local nRet		as numeric
	SA1->( dbSetOrder(1) )
	if SA1->( dbSeek(xFilial()+cCliente) )
		nRet := Aviso("Clientes","O que deseja fazer com o cadastro do cliente?"+CRLF+;
								CRLF+;
								(cTmp)->E1_NOMCLI,;
								{"Visualizar","Cancelar","Incluir","Alterar"},2)
		if cValtochar(nRet) $ "1,3,4"
			MsgRun("Carregando dados do cliente ...","Aguarde",{|| FwExecView("Cliente","CRMA980",nRet,,,,20) })
		endif
	endif
	CFILANT := cBkp
	SA1->( restArea(aSave) )
return
