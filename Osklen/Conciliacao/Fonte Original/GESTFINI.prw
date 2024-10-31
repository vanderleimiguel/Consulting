#include "totvs.ch"

#define OPER_COND_X_BANCO	1
#define OPER_ENVIO_AUTO		2
#define OPER_ESTORNO		3

/*/{Protheus.doc} GESTFINI
	faz o envio automatico dos titulos para o Itau
	@type	 function
	@version 1.0
	@author	 ivan.caproni
	@since	 10/09/2024
/*/
user function GESTFINI(nOperation,aParms,cTmp4fin)
	do case
		case nOperation == OPER_COND_X_BANCO
			condBanco()
		case nOperation == OPER_ENVIO_AUTO
			envioAuto(aParms)
		case nOperation == OPER_ESTORNO
			estornoBanco(cTmp4fin)
	endcase
return

static function condBanco
	local cModo1 := ""
	local cModo2 := ""
	local lHelp	 := .T.
	if ! xRetModo("SE4","Z01",lHelp,@cModo1,@cModo2) // CRIAR
		FwExecView("Amarracao Condicao x Banco","GESTFINI",4,,,,30)
	endif
return

static function ModelDef
	local oSE4		:= FwFormStruct(1,'SE4',{|cCampo| getStruct(cCampo) })
	local oZ01		:= FwFormStruct(1,'Z01') // CRIAR
	local oModel	:= MPFormModel():new('GESTFINIM',,{|oModel| tudoOk(oModel) })

	oModel:addFields('MASTER',,oSE4)
	oModel:addGrid('DETAIL','MASTER',oZ01) // CRIAR
	oModel:setRelation('DETAIL',{	{'Z01_FILIAL'	,'xFilial("Z01")'	},;
									{'Z01_COND'		,'E4_CODIGO'		} },Z01->(IndexKey(1)) )
	oModel:getModel('DETAIL'):setUniqueLine({'Z01_COND','Z01_BANCO','Z01_AGENCI','Z01_CONTA'})
	oModel:setDescription('Amarracao Condicao x Banco')
	oModel:getModel('MASTER'):setDescription('Condicao de pagamento')
	oModel:getModel('DETAIL'):setDescription('Listagem Banco/Agencia/Conta')
	oModel:setPrimaryKey({})
return oModel

static function ViewDef
	local oModel	:= FwLoadModel("GESTFINI")
	local oSE4		:= FwFormStruct(2,'SE4',{|cCampo| getStruct(cCampo) })
	local oZ01		:= FwFormStruct(2,'Z01') // CRIAR
	local oView		:= FwFormView():new()
	oView:setModel(oModel)
	oView:addField('VIEW_M',oSE4,'MASTER')
	oView:addGrid('VIEW_D',oZ01,'DETAIL')
	oView:createHorizontalBox('SUPERIOR',20)
	oView:createHorizontalBox('INFERIOR',80)
	oView:setOwnerView('VIEW_M','SUPERIOR')
	oView:setOwnerView('VIEW_D','INFERIOR')
	oView:enableTitleView('VIEW_M')
	oView:enableTitleView('VIEW_D')
return oView

static function getStruct(cField)
return Trim(cField) $ "E4_CODIGO/E4_DESCRI"

static function tudoOk(oModel)
	local lstBanco	:= "341"
	local lTudoOk	:= .T.
	local oGrid		:= oModel:getModel("DETAIL")
	local nIndex	as numeric
	local nCnt		:= 0
	local aSave		:= FwSaveRows()

	for nIndex := 1 to oGrid:lenght()
		oGrid:goLine(nIndex)
		if ! oGrid:isDeleted()
			cBanco := oGrid:getValue("Z01_BANCO") // CRIAR
			if ! cBanco $ lstBanco
				lTudoOk := .F.
				Help(,,'Help',,'Ainda nao e permitido utilizar esse banco ['+cBanco+'] nessa amarracao. Permitido: '+lstBanco,1,0)
				exit
			endif

			if oGrid:getValue("Z01_PRINC") == "1" // CRIAR
				nCnt ++
			endif

			if nCnt > 1
				lTudoOk := .F.
				Help(,,'Help',,'Somente 1 banco/agencia/conta deve ser o principal',1,0)
				exit
			endif
		endif
	next nIndex

	FwRestRows(aSave)

	if nCnt == 0
		lTudoOk := .F.
		Help(,,'Help',,'Marque 1 banco/agencia/conta para ser o principal',1,0)
	endif
return lTudoOk

static function envioAuto(aParms)
	local cTmp	as character

	RpcSetEnv(aParms[1],aParms[2])

	cTmp := GetNextAlias()
	BeginSql alias cTmp
		SELECT SF2.R_E_C_N_O_ SF2RECNO
				, SE1.R_E_C_N_O_ SE1RECNO
				, Z01.R_E_C_N_O_ Z01RECNO // CRIAR
				, SA1.R_E_C_N_O_ SA1RECNO
		FROM %table:SF2% SF2
		JOIN %table:SE1% SE1
			ON E1_FILIAL = %xFilial:SE1%
				AND E1_CLIENTE = F2_CLIENTE
				AND E1_LOJA = F2_LOJA
				AND E1_PREFIXO = F2_PREFIXO
				AND E1_NUM = F2_DOC
				AND E1_TIPO = 'NF'
				AND SE1.%notDel%
		JOIN %table:SE4% SE4
			ON E4_FILIAL = %xFilial:SE4%
				AND E4_CODIGO = F2_COND
				AND SE4.%notDel%
		JOIN %table:Z01% Z01 // CRIAR
			ON Z01_FILIAL = %xFilial:Z01% // CRIAR
				AND Z01_COND = E4_CODIGO // CRIAR
				AND Z01_PRINC = '1' // CRIAR
				AND Z01.%notDel% // CRIAR
		JOIN %table:SA1% SA1
			ON A1_FILIAL = %xFilial:SA1%
				AND A1_COD = F2_CLIENTE
				AND A1_LOJA = F2_LOJA
				AND SA1.%notDel%
		WHERE F2_FILIAL = %xFilial:SF2%
			AND F2_CHAVNFE <> ''
			AND F2_XBOLDFE = 'N' // CRIAR
			AND SF2.%notDel%
		ORDER BY 4,1,2
	EndSql

	if (cTmp)->(!Eof())
		oEnvio := gestaoEnvio():new()

		while (cTmp)->(!Eof())
			nSa1Recno := (cTmp)->SA1RECNO
			nZ01Recno := (cTmp)->Z01RECNO // CRIAR
			oEnvio:addTitulo((cTmp)->SE1RECNO)

			(cTmp)->(dbSkip())

			if nSa1Recno != (cTmp)->SA1RECNO
				oEnvio:setBank(nZ01Recno)
				oEnvio:setCustomer(nSa1Recno)

				oEnvio:sendToBank()
				if oEnvio:hasError()
					oEnvio:sendErrorByEmail()
				else
					oEnvio:generateAllBoleto()
					oEnvio:addFileToSend(geraDanfe())
					oEnvio:sendToCustomerByEmail()
				endif
			endif

			oEnvio:clean()
			(cTmp)->(dbSkip())
		end
		oEnvio:destroy()
	endif

	(cTmp)->(dbCloseArea())
	RpcClearEnv()
return
/*/{Protheus.doc} gestaoEnvio
	classe que faz a comunicacao com Itau, gera boleto, danfe e envia
	@type	 class
	@version 1.0
	@author	 ivan.caproni
	@since	 10/09/2024
/*/
class gestaoEnvio
	data aRecno		as array
	data msgErr		as array
	data lError		as logical
	data recnoSA1	as numeric
	data recnoZ01	as numeric

	method new()
	method addTitulo()
	method clean()
	method destroy()
	method hasError()
	method setBank()
	method setCustomer()
	method getToken()
	method sendToBank()
	method isWebhookActive()
	method activateWebhook()
endclass

method new() class gestaoEnvio
	setIni(self)
return

method clean() class gestaoEnvio
	setIni(self)
return

static function setIni(oObj)
	oObj:aRecno	:= {}
	oObj:msgErr	:= {}
	oObj:lError	:= .F.
	oObj:recnoSA1 := 0
	oObj:recnoZ01 := 0
return

method destroy() class gestaoEnvio
	FwFreeArray(::aRecno)
return

method addTitulo(nSe1Recno) class gestaoEnvio
	aAdd(::aRecno,nSe1Recno)
return

method hasError() class gestaoEnvio
return ::lError

method setBank(nRecno) class gestaoEnvio
	::recnoZ01 := nRecno
return

method setCustomer(nRecno) class gestaoEnvio
	::recnoSA1 := nRecno
return

method getToken() class gestaoEnvio
	local cToken	as character
	local cEndpoint	:= "https://sandbox.devportal.itau.com.br/api/oauth/jwt"
	local cParam	:= "client_id=4671a37e-c21b-4481-9489-40601cfaaaf3"+;
						"&client_secret=d89bf88f-60fb-4892-afd7-7096df1a49ea"+;
						"&grant_type=client_credentials"
	local cRetorno	:= HttpPost(cEndpoint,cParam)
	local jBody		as json
	if ! Empty(cRetorno)
		jBody := JsonObject():new()
		jBody:fromJson(cRetorno)
		cToken := jBody["access_token"]
	endif
return cToken

method sendToBank() class gestaoEnvio
	local cEndpoint	:= "https://sandbox.devportal.itau.com.br/itau-ep9-gtw-pix-recebimentos-conciliacoes-v2-ext/v2/boletos_pix"
	local cToken	:= ::getToken()
	// local cJson		as character
	local cRetorno	as character
	local aHeader	as array
	local oBody		as json
	local oRet		as json
	local nIdx		as numeric

	if ! ::isWebhookActive()
		::activateWebhook()
	endif

	FwSm0Util():setSM0PositionBycFilAnt()
	Z01->(dbGoto(::recnoZ01)) // CRIAR
	SA1->(dbGoto(::recnoSA1))

	for nIdx := 1 to Len(::aRecno)
		SE1->(dbGoto(::aRecno[nIdx]))

		oBody := JsonObject():new()
		oBody["etapa_processo_boleto"] := "efetivacao"

		oBody["beneficiario"] := JsonObject():new()
		oBody["beneficiario"]["id_beneficiario"] := Strzero(Val(Z01->Z01_AGENCI),4)+;
													Strzero(Val(Z01->Z01_CONTA),7)+;
													Left(Z01->Z01_DVCNT,1)

		oBody["dado_boleto"] := JsonObject():new()
		oBody["dado_boleto"]["tipo_boleto"]						:= "a vista"
		oBody["dado_boleto"]["descricao_instrumento_cobranca"]	:= "boleto_pix"
		oBody["dado_boleto"]["texto_seu_numero"]				:= "000001"
		oBody["dado_boleto"]["codigo_carteira"]					:= "110"
		oBody["dado_boleto"]["valor_total_titulo"]				:= StrZero(Round(SE1->E1_VALOR*100,2),17)
		oBody["dado_boleto"]["codigo_especie"]					:= "01"
		oBody["dado_boleto"]["data_emissao"]					:= Transform(Stod(Date()),"@R 9999-99-99")
		oBody["dado_boleto"]["valor_abatimento"]				:= StrZero(Round(SE1->E1_DECRESC*100,2),17)

		oBody["dado_boleto"]["negativacao"] := JsonObject():new()
		oBody["dado_boleto"]["negativacao"]["negativacao"] := "8"
		oBody["dado_boleto"]["negativacao"]["quantidade_dias_negativacao"] := "010"

		oBody["dado_boleto"]["pagador"] := JsonObject():new()

		oBody["dado_boleto"]["pagador"]["pessoa"] := JsonObject():new()
		oBody["dado_boleto"]["pagador"]["pessoa"]["nome_pessoa"] := Alltrim(SA1->A1_NOME)
		oBody["dado_boleto"]["pagador"]["pessoa"]["nome_fantasia"] := Alltrim(SA1->A1_NREDUZ)

		oBody["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"] := JsonObject():new()
		oBody["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]["codigo_tipo_pessoa"] := SA1->A1_PESSOA
		oBody["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]["numero_cadastro_pessoa_fisica"] := SA1->A1_CGC

		oBody["dado_boleto"]["pagador"]["endereco"] := JsonObject():new()
		oBody["dado_boleto"]["pagador"]["endereco"]["nome_logradouro"]	:= Alltrim(SA1->A1_END)
		oBody["dado_boleto"]["pagador"]["endereco"]["nome_bairro"]		:= Alltrim(SA1->A1_BAIRRO)
		oBody["dado_boleto"]["pagador"]["endereco"]["nome_cidade"]		:= Alltrim(SA1->A1_MUN)
		oBody["dado_boleto"]["pagador"]["endereco"]["sigla_UF"]			:= Alltrim(SA1->A1_EST)
		oBody["dado_boleto"]["pagador"]["endereco"]["numero_CEP"]		:= Alltrim(SA1->A1_CEP)

		oBody["dado_boleto"]["dados_individuais_boleto"] := {}
		oBody["dado_boleto"]["dados_individuais_boleto"][1] := JsonObject():new()
		oBody["dado_boleto"]["dados_individuais_boleto"][1]["numero_nosso_numero"]		:= Right(SE1->E1_IDCNAB,8)
		oBody["dado_boleto"]["dados_individuais_boleto"][1]["data_vencimento"]			:= Transform(Stod(SE1->E1_VENCTO),"@R 9999-99-99")
		oBody["dado_boleto"]["dados_individuais_boleto"][1]["valor_titulo"]				:= StrZero(Round(SE1->E1_VALOR*100,2),17)
		oBody["dado_boleto"]["dados_individuais_boleto"][1]["data_limite_pagamento"]	:= Transform(Stod(SE1->E1_VENCTO+10),"@R 9999-99-99")
/*
		BeginContent var cJson
			{
				"etapa_processo_boleto": "efetivacao",
				"beneficiario": {
					"id_beneficiario": "150000052061"
				},
				"dado_boleto": {
					"tipo_boleto": "a vista",
					"descricao_instrumento_cobranca": "boleto_pix",
					"texto_seu_numero": "000001",
					"codigo_carteira": "110",
					"valor_total_titulo": "90000000000030000",
					"codigo_especie": "01",
					"data_emissao": "2022-03-25",
					"valor_abatimento": "00000000000000010",
					"negativacao": {
						"negativacao": "8",
						"quantidade_dias_negativacao": "010"
					},
					"pagador": {
						"pessoa": {
							"nome_pessoa": "Joao Silva",
							"nome_fantasia": "Joao Silva",
							"tipo_pessoa": {
								"codigo_tipo_pessoa": "F",
								"numero_cadastro_pessoa_fisica": "26556923221"
							}
						},
						"endereco": {
							"nome_logradouro": "Av do Estado, 5533",
							"nome_bairro": "Mooca",
							"nome_cidade": "Sao Paulo",
							"sigla_UF": "SP",
							"numero_CEP": "04135010"
						}
					},
					"dados_individuais_boleto": [
						{
							"numero_nosso_numero": "12345678",
							"data_vencimento": "2022-07-30",
							"valor_titulo": "00000000000010001",
							"data_limite_pagamento": "2022-10-30"
						}
					]
				}
			}
		EndContent

		oBody := JsonObject():new()
		oBody:fromJson(cJson)
*/
		aHeader := {}
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: Bearer "+cToken)

		cRetorno := HttpPost(cEndpoint,cParam,oBody:toJson(),,aHeader)

		if Empty(cRetorno)
			aAdd(::msgErr,"nao ha dados no retorno do banco")
		else
			oRet := JsonObject():new()
			if Empty(oRet:fromJson(DecodeUtf8(cRetorno)))
				if oRet:hasProperty("codigo") .and. oRet:hasProperty("mensagem")
					aAdd(::msgErr,"erro ao enviar o boleto para o banco: "+oRet["mensagem"])
				else
					Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
					SE1->E1_CODBAR	:= oRet["data"]["dado_boleto"]["dados_individuais_boleto"][1]["codigo_barras"]
					SE1->E1_CODDIG	:= oRet["data"]["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"]
					SE1->E1_XAPI	:= .T.
					SE1->E1_XTXID	:= oRet["data"]["dados_qrcode"]["txid"] // CRIAR
					SE1->E1_XQRCODE	:= oRet["data"]["dados_qrcode"]["base64"] // CRIAR
					SE1->E1_XCPCL	:= oRet["data"]["dados_qrcode"]["emv"] // CRIAR
					SE1->( msUnlock() ) ; (cTmp)->( msUnlock() )
				endif
			else
				aAdd(::msgErr,"erro no parser do json de retorno do banco")
			endif
		endif
	next nIdx

	if Len(::msgErr) > 0
		::lError := .T.
	endif

	FreeObj(oBody) ; FreeObj(oRet) ; FwFreeArray(aHeader)
return

method isWebhookActive() class gestaoEnvio
	local lOk		:= .F.
	local cChavePix	:= "financeiro@fas-solutions.com.br"
	local cEndpoint	:= "https://secure.api.itau/pix_recebimentos/v2/webhook/"+Escape(cChavePix)
	local cRetorno	:= HttpGet(cEndpoint)
	local oBody		as json
	if Empty(cRetorno)
		aAdd(::msgErr,"nao ha dados no retorno do banco para verificacao do webhook")
	else
		oBody := JsonObject():new()
		oBody:fromJson(cRetorno)
		if oBody:hasProperty("chave") .and. oBody["chave"] == cChavePix
			lOk := .T.
		else
			aAdd(::msgErr,"propriedade 'chave' nao encontrada na verificacao do webhook")
		endif
	endif
return lOk

method activateWebhook() class gestaoEnvio
	local lOk		:= .F.
	local cChavePix	:= "financeiro@fas-solutions.com.br"
	local cEndpoint	:= "https://secure.api.itau/pix_recebimentos/v2/webhook/"+Escape(cChavePix)
	local oBody		:= JsonObject():new()
	local cHttpCode	:= ""

	oBody["webhookUrl"] := "https://pix.example.com/api/webhook/"
	HttpQuote(cEndpoint,"PUT",,oBody:toJson())
	HttpGetStatus(@cHttpCode)

	if "200" $ cHttpCode .or. "201" $ cHttpCode
		lOk := .T.
	else
		aAdd(::msgErr,"erro ao cadastrar webhook")
	endif
return

// executado via central 4fin
static function estornoBanco(cTmp)
	local cEndpoint as character
	local cRetorno	as character
	local cIdBoleto	as character
	local cHttpCode	:= ""
	local cCert		:= "/certs/itau_cert.pem"
	local cPrivKey	:= "/certs/itau_key.pem"
	local cPassword	:= ""
	local aSave		:= SA6->(getArea())

	SA6->( dbSetOrder(RetOrder("SA6","A6_FILIAL+A6_COD+A6_AGENCIA+A6_NUMCON")) )
	SA6->( dbSeek(xFilial()+(cTmp)->E1_PORTADO+(cTmp)->E1_AGEDEP+(cTmp)->E1_CONTA) )

	cIdBoleto	:= 	Strzero(Val(SA6->A6_AGENCIA),4)+; //"agencia" 4 digitos
					Strzero(Val(SA6->A6_NUMCON),4)+; //"conta" 7 digitos
					Left(SA6->A6_DVCTA,1)+; //"dac" 1 digito
					"110"+; //"carteira" 3 digitos
					Right(SE1->E1_IDCNAB,8) //"nosso_numero" 8 digitos

	cEndpoint := "https://devportal.itau.com.br/sandboxapi/cash_management_ext_v2/v2"
	cEndpoint += "/cash_management/v2/boletos/"+cIdBoleto+"/baixa"

	cRetorno := HttpSQuote(cEndpoint,;
							cCert,;
							cPrivKey,;
							cPassword,;
							"PATCH")

	if Empty(cRetorno)
		Alert("erro ao cancelar boleto no Itau")
	else
		oBody := JsonObject():new()
		oBody:fromJson(DecodeUtf8(cRetorno))

		if oBody:hasProperty("codigo") .and. oBody:hasProperty("mensagem")
			Alert("erro ao cancelar boleto no Itau: "+oBody["mensagem"])
		else
			HttpGetStatus(@cHttpCode)
			if "200" $ cHttpCode .or. "201" $ cHttpCode .or. "204" $ cHttpCode
				FwAlertSuccess("Instrução de baixa realizada com sucesso","Sucesso")
			endif
		endif
	endif

	SA6->(restArea(aSave))
return
