#include "protheus.ch"
/*/{Protheus.doc} GESTFIN2
	funcionalidades para o contas a receber
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function GESTFIN2(cTmp,cBanco)
	MsgRun("Gerando bordero e arquivo ...","Aguarde",{|| fnExec(cTmp,cBanco) })
return

static function fnExec(cTmp,cBanco)
	local aSV		:= (cTmp)->(getArea())
	local cBkp		:= CFILANT
	local cNumBor	as character
	local cPath		as character
	local cIdCnab	as character
	local lOk		:= .F.

	(cTmp)->(dbSetOrder(2))

	if (cTmp)->(dbSeek("T"))
		SEE->( dbSetOrder(1) )
		if SEE->( ! dbSeek(xFilial()+cBanco) )
			(cTmp)->(restArea(aSv))
			ApMsgInfo("banco nao configurado")
			return
		endif

		if ! fnPickAccount(cBanco)
			(cTmp)->(restArea(aSv))
			return
		endif

		if Empty(SEE->EE_XTIPAPI)
			(cTmp)->(restArea(aSv))
			ApMsgInfo("tipo de API nao configurado")
			return
		endif

		if SEE->( EE_XTIPAPI == "C" .and. Empty(EE_XCONFIG) )
			(cTmp)->(restArea(aSv))
			ApMsgInfo("sem arquivo de configuracao (EE_XCONFIG)")
			return
		endif

		cPath := "c:\cnab\"
		if ! ExistDir(cPath) .and. MakeDir(cPath) != 0
			Alert("nao foi possivel criar a pasta para geracao do arquivo [c:\cnab\]")
			return
		endif

		cNumBor := Soma1(GetMV("MV_NUMBORR"),6)
		cNumBor := PadL(Alltrim(cNumBor),6,"0")

		while ! MayIUseCode("SE1"+xFilial("SE1")+cNumBor) .or. ! FA060Num(cNumBor, .F.)
			cNumBor := Soma1(cNumBor)
		end

		while (cTmp)->( ! Eof() .and. XX_OK == 'T' )
			if Empty((cTmp)->E1_NUMBOR)
				lOk := .T.
				SE1->( dbGoto((cTmp)->XX_RECNO) )

				Reclock("SEA",.T.)
				SEA->EA_FILIAL	:= xFilial("SEA")
				SEA->EA_PREFIXO	:= SE1->E1_PREFIXO
				SEA->EA_NUM		:= SE1->E1_NUM
				SEA->EA_PARCELA := SE1->E1_PARCELA
				SEA->EA_TIPO	:= SE1->E1_TIPO
				SEA->EA_FILORIG	:= SE1->E1_FILORIG

				SEA->EA_PORTADO	:= SEE->EE_CODIGO
				SEA->EA_AGEDEP	:= SEE->EE_AGENCIA
				SEA->EA_NUMCON	:= SEE->EE_CONTA
				SEA->EA_PORTANT	:= ""
				SEA->EA_AGEANT	:= ""
				SEA->EA_CONTANT	:= ""

				SEA->EA_NUMBOR	:= cNumBor
				SEA->EA_DATABOR	:= DDATABASE
				SEA->EA_CART	:= "R"
				SEA->EA_TRANSF	:= "S"
				SEA->EA_SITUACA	:= "1"
				SEA->EA_ORIGEM	:= "GESTFIN"
				SEA->EA_BORAPI	:= "N"
				SEA->(msUnlock())

				if SEE->EE_XTIPAPI == "A" // API
					cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,19)
					aOrdSE1 := SE1->(GetArea())
					SE1->( dbSetOrder(16) )
					While SE1->(dbSeek(xFilial("SE1")+cIdCnab))
						If ( __lSx8 )
							ConfirmSX8()
						EndIf
						cIdCnab := GetSxENum("SE1", "E1_IDCNAB","E1_IDCNAB"+cEmpAnt,19)
					EndDo
					SE1->(RestArea(aOrdSE1))
					ConfirmSx8()

					RecLock("SE1",.F.) ; RecLock(cTmp,.F.)
					SE1->E1_IDCNAB	:= (cTmp)->E1_IDCNAB  := cIdCnab
					SE1->(msUnlock()) ; (cTmp)->(msUnlock())
				endif

				RecLock("SE1",.F.) ; RecLock(cTmp,.F.)
				SE1->E1_PORTADO := (cTmp)->E1_PORTADO := SEA->EA_PORTADO
				SE1->E1_AGEDEP  := (cTmp)->E1_AGEDEP  := SEA->EA_AGEDEP
				SE1->E1_CONTA	:= (cTmp)->E1_CONTA	  := SEA->EA_NUMCON
				SE1->E1_SITUACA := (cTmp)->E1_SITUACA := SEA->EA_SITUACA
				SE1->E1_NUMBOR  := (cTmp)->E1_NUMBOR  := SEA->EA_NUMBOR
				SE1->E1_DATABOR := (cTmp)->E1_DATABOR := SEA->EA_DATABOR
				SE1->E1_MOVIMEN := (cTmp)->E1_MOVIMEN := SEA->EA_DATABOR
				SE1->(msUnlock()) ; (cTmp)->(msUnlock())

				if SEE->EE_XTIPAPI == "A" // API
					lGeraToken := .T.
					fnEnvBordero(cBanco,cTmp)
					/* Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
					SE1->E1_CODBAR := (cTmp)->E1_CODBAR := "1"
					SE1->E1_CODDIG := (cTmp)->E1_CODDIG := "34191790010104351004791020150008198150026000"
					SE1->E1_XAPI   := (cTmp)->E1_XAPI   := .T.
					SE1->( msUnlock() ) ; (cTmp)->( msUnlock() ) */
				endif
			endif

			(cTmp)->(dbSkip())
		end

		if lOk
			PutMv("MV_NUMBORR", cNumBor)
			if SEE->EE_XTIPAPI == "C" // CNAB
				Pergunte("AFI150",.F.)

				MV_PAR01 := cNumBor									// DO BORDERO
				MV_PAR02 := cNumBor									// ATE O BORDERO
				MV_PAR03 := SEE->EE_XCONFIG							// ARQ.CONFIG
				MV_PAR04 := cPath+cNumBor+"."+Lower(SEE->EE_EXTEN)	// ARQ. SAIDA
				MV_PAR05 := SEE->EE_CODIGO							// BANCO
				MV_PAR06 := SEE->EE_AGENCIA 						// AGENCIAO
				MV_PAR07 := SEE->EE_CONTA							// CONTA
				MV_PAR08 := SEE->EE_SUBCTA							// SUB-CONTA
				MV_PAR09 := Val(SEE->EE_CNABRC)						// CNAB 1 / CNAB 2
				MV_PAR10 := 1										// CONSIDERA FILIAIS
				MV_PAR11 := Space(Len(MV_PAR11))					// DE FILIAL
				MV_PAR12 := Replicate("Z",Len(MV_PAR12))			// ATE FILIAL
				MV_PAR13 := 3										// QUEBRA POR ?
				MV_PAR14 := 2										// SELECIONA FILIAL?

				// variaveis necessarias para a geracao do arquivo
				private cNomeSai  := ""
				private cArqBkp   := ""
				private lAborta   := .F.
				private nTecla	  := nil

				fa150Gera("SE1")
			endif
		endif
	endif

	while (cTmp)->( ! Eof() .and. XX_OK == "T" )
		fnUnmark(cTmp)
		(cTmp)->(dbSkip())
	end

	CFILANT := cBkp
	(cTmp)->(restArea(aSv))
return

static function fnUnmark(cTmp)
	Reclock(cTmp,.F.)
	(cTmp)->XX_OK := "F"
	(cTmp)->(msUnlock())
return

static function fnEnvBordero(cBanco,cTmp)
	local cWorkspace	as character
	local cEndpoint		as character
	local cRecurso		as character
	local cAppKey		as character
	local cToken		as character
	local cErr			as character
	local cRet			as character
	local oRest			as object
	local oRet			as object
	local jBody			as json
	local aHeader		:= {}
	local cHeaderRet	:= ""

	if cBanco == "001"
		cEndpoint := "https://api.bb.com.br/cobrancas/v2"
		cRecurso  := "/boletos"
		cAppKey	  := "gw-dev-app-key=94da3b26eb913c60614704611b324b7d"
		cToken	  := fnToken(cBanco)

		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)

		jBody := JsonObject():new()
		jBody["numeroConvenio"]							:= 3279055 //3128557
		jBody["numeroCarteira"]							:= 17
		jBody["numeroVariacaoCarteira"]					:= 19 //35
		jBody["codigoModalidade"]						:= 4 //1
		jBody["dataEmissao"]							:= Transform(GravaData((cTmp)->E1_EMISSAO,.F.,5),"@R 99.99.9999")
		jBody["dataVencimento"]							:= Transform(GravaData((cTmp)->E1_VENCTO,.F.,5),"@R 99.99.9999")
		jBody["valorOriginal"]							:= (cTmp)->E1_VALOR
		jBody["valorAbatimento"]						:= 0
		jBody["indicadorAceiteTituloVencido"]			:= "S"
		jBody["numeroDiasLimiteRecebimento"]			:= ""
		jBody["codigoAceite"]							:= "A"
		jBody["codigoTipoTitulo"]						:= "02"
		jBody["descricaoTipoTitulo"]					:= "DM"
		jBody["indicadorPermissaoRecebimentoParcial"]	:= "S"
		jBody["numeroTituloCliente"]					:= "000"+cValtochar(jBody["numeroConvenio"])+(cTmp)->E1_IDCNAB
		jBody["mensagemBloquetoOcorrencia"]				:= ""
		jBody["pagador"]								:= JsonObject():new()
		jBody["pagador"]["tipoInscricao"]				:= Iif(Posicione("SA1",1,xFilial("SA1")+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA,"A1_PESSOA") == "F",1,2)
		jBody["pagador"]["numeroInscricao"]				:= Val(SA1->A1_CGC)
		jBody["pagador"]["nome"]						:= Alltrim(Left(SA1->A1_NOME,60))
		jBody["pagador"]["endereco"]					:= Alltrim(Left(SA1->A1_END,60))
		jBody["pagador"]["cep"]							:= Val(StrTran(SA1->A1_CEP,"-"))
		jBody["pagador"]["cidade"]						:= Alltrim(SA1->A1_MUN)
		jBody["pagador"]["bairro"]						:= Alltrim(SA1->A1_BAIRRO)
		jBody["pagador"]["uf"]							:= SA1->A1_EST
		jBody["pagador"]["telefone"]					:= Alltrim(SA1->A1_TEL)
		//jBody["indicadorPix"]							:= "S"

		oRest := FwRest():new(cEndpoint)
		oRest:setPath(cRecurso+"?"+cAppKey)
		oRest:setPostParams(jBody:toJson())
		if ! oRest:post(aHeader)
			cErr := ""
			if ! Empty(oRest:cResult)
				oRet := JsonObject():new()
				if Empty(oRet:fromJson(oRest:cResult))
					cErr := DecodeUTF8(oRet["erros"][1]["mensagem"])
				endif
			endif
			Alert("Erro ao enviar os dados para o banco: "+cErr)
		else
			oRet := JsonObject():new()
			if Empty(oRet:fromJson(oRest:cResult))
				Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
				SE1->E1_NUMBCO := (cTmp)->E1_NUMBCO := jBody["numeroTituloCliente"]
				SE1->E1_CODBAR := (cTmp)->E1_CODBAR := oRet["codigoBarraNumerico"]
				SE1->E1_CODDIG := (cTmp)->E1_CODDIG := oRet["linhaDigitavel"]
				SE1->E1_XAPI   := (cTmp)->E1_XAPI   := .T.
				SE1->( msUnlock() ) ; (cTmp)->( msUnlock() )
			endif

			FwAlertSuccess("Bordero enviado com sucesso","Sucesso")
		endif

		FreeObj(jBody) ; FreeObj(oRest) ; FwFreeArray(aHeader)

	elseif cBanco == "422"

		cEndpoint := "https://api.safranegocios.com.br/gateway/cobrancas/v1" //"https://api-hml.safranegocios.com.br/gateway/cobrancas/v1"
		cRecurso  := "/boletos"
		cAppKey	  := "41fa65a3-1a71-4437-a169-5bd209eb2d3a"
		cToken	  := fnToken(cBanco)

		aAdd(aHeader,"Safra-Correlation-ID: "+cAppKey)
		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)

		jBody := JsonObject():new()
		jBody["agencia"]	:= PadR(Val((cTmp)->E1_AGEDEP),5,"0") //"13500"
		jBody["conta"]		:= Strzero(Val(Alltrim((cTmp)->E1_CONTA)+SEE->EE_DVCTA),9) //"005855087"

		jBody["documento"]	:= JsonObject():new()
		jBody["documento"]["numero"]				 := Val((cTmp)->E1_IDCNAB) // Random(111111,999999)
		jBody["documento"]["numeroCliente"]			 := Strzero(jBody["documento"]["numero"],9) // safra dever ter somente 9 digitos
		jBody["documento"]["especie"]				 := "01"
		jBody["documento"]["dataVencimento"]		 := Transform(DtoS((cTmp)->E1_VENCTO),"@R 9999-99-99")
		jBody["documento"]["valor"]					 := (cTmp)->E1_VALOR
		jBody["documento"]["codigoMoeda"]			 := 0
		jBody["documento"]["quantidadeDiasProtesto"] := 0

		jBody["documento"]["pagador"] := JsonObject():new()
		jBody["documento"]["pagador"]["numeroDocumento"] := Alltrim(Posicione("SA1",1,xFilial("SA1")+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA,"A1_CGC"))
		jBody["documento"]["pagador"]["nome"]			 := Alltrim(Left(SA1->A1_NOME,40))
		jBody["documento"]["pagador"]["tipoPessoa"]		 := Iif(Len(SA1->A1_CGC) == 14,"J","F")

		jBody["documento"]["pagador"]["endereco"] := JsonObject():new()
		jBody["documento"]["pagador"]["endereco"]["logradouro"]	:= Alltrim(Left(SA1->A1_END,40))
		jBody["documento"]["pagador"]["endereco"]["bairro"]		:= Alltrim(Left(SA1->A1_BAIRRO,10))
		jBody["documento"]["pagador"]["endereco"]["cidade"]		:= Alltrim(Left(SA1->A1_MUN,15))
		jBody["documento"]["pagador"]["endereco"]["uf"]			:= SA1->A1_EST
		jBody["documento"]["pagador"]["endereco"]["cep"]		:= Alltrim(SA1->A1_CEP)

		oRest := FwRest():new(cEndpoint)
		oRest:setPath(cRecurso)
		oRest:setPostParams(jBody:toJson())
		if ! oRest:post(aHeader)
			cErr := ""
			if ! Empty(oRest:cResult)
				oRet := JsonObject():new()
				if Empty(oRet:fromJson(oRest:cResult))
					if ! Empty(oRet["message"])
						cErr := DecodeUTF8(oRet["message"])
					endif
				endif
			endif
			Alert("Erro ao enviar os dados para o banco: "+cErr)
		else
			oRet := JsonObject():new()
			if Empty(oRet:fromJson(oRest:cResult))
				Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
				SE1->E1_CODBAR  := (cTmp)->E1_CODBAR  := oRet["data"]["codigoBarras"]
				SE1->E1_CODDIG  := (cTmp)->E1_CODDIG  := doLDSafra(oRet["data"]["codigoBarras"],;
																	jBody["agencia"],;
																	jBody["conta"],;
																	jBody["documento"]["numeroCliente"],;
																	jBody["documento"]["dataVencimento"],;
																	jBody["documento"]["valor"])
				SE1->E1_IDCNAB  := (cTmp)->E1_IDCNAB  := Strzero(jBody["documento"]["numero"],TamSx3("E1_IDCNAB")[1])
				SE1->E1_XAPI    := (cTmp)->E1_XAPI    := .T.
				SE1->( msUnlock() ) ; (cTmp)->( msUnlock() )
			endif

			FwAlertSuccess("Bordero enviado com sucesso","Sucesso")
		endif

		FreeObj(jBody) ; FreeObj(oRest) ; FwFreeArray(aHeader)

	elseif cBanco == "033"

		cWorkspace := "baec44dc-2f72-4581-b256-497dd3bc5d03"
		cEndpoint  := "https://trust-open.api.santander.com.br"
		cRecurso   := "/collection_bill_management/v2/workspaces/"+cWorkspace+"/bank_slips"
		cAppKey	   := "FZUAMCybSoLCWj8ulJLfoaVai1Y9m3HJ" // client_id
		cToken	   := fnToken(cBanco)

		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)
		aAdd(aHeader,"X-Application-Key: "+cAppKey)

		jBody := JsonObject():new()
		jBody["environment"]							:= "PRODUCAO"
		jBody["nsuCode"]								:= (cTmp)->E1_IDCNAB
		jBody["nsuDate"]								:= Transform(DtoS((cTmp)->E1_EMISSAO),"@R 9999-99-99")
		jBody["covenantCode"]							:= 344062
		jBody["bankNumber"]								:= Strzero(Val((cTmp)->E1_IDCNAB),12)
		jBody["dueDate"]								:= Transform(DtoS((cTmp)->E1_VENCTO),"@R 9999-99-99")
		jBody["issueDate"]								:= Transform(DtoS((cTmp)->E1_EMISSAO),"@R 9999-99-99")
		jBody["clientNumber"]							:= (cTmp)->XX_RECNO
		jBody["participantCode"]						:= (cTmp)->E1_IDCNAB
		jBody["nominalValue"]							:= Alltrim(Str((cTmp)->E1_VALOR,12,2))

		jBody["payer"]									:= JsonObject():new()
		jBody["payer"]["documentNumber"]				:= Alltrim(Posicione("SA1",1,xFilial("SA1")+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA,"A1_CGC"))
		jBody["payer"]["name"]							:= Alltrim(Left(SA1->A1_NOME,40))
		jBody["payer"]["documentType"]					:= Iif(Len(SA1->A1_CGC) == 14,"CNPJ","CPF")
		jBody["payer"]["address"]						:= Alltrim(Left(SA1->A1_END,40))
		jBody["payer"]["neighborhood"]					:= Alltrim(Left(SA1->A1_BAIRRO,10))
		jBody["payer"]["city"]							:= Alltrim(Left(SA1->A1_MUN,15))
		jBody["payer"]["state"]							:= SA1->A1_EST
		jBody["payer"]["zipCode"]						:= Transform(Alltrim(SA1->A1_CEP),"@R 99999-999")

		jBody["documentKind"]							:= "DUPLICATA_MERCANTIL"
		jBody["deductionValue"]							:= "0.00"
		jBody["paymentType"]							:= "REGISTRO"
		jBody["writeOffQuantityDays"]					:= "30"
		jBody["messages"]								:= {""}

		jBody["key"]									:= JsonObject():new()
		jBody["key"]["type"]							:= "EMAIL"
		jBody["key"]["dictKey"]							:= "pixsantander@agrofauna.com.br"

		cRet := HTTPSPost(cEndpoint+cRecurso,;
					"\certs\certif_cert.pem",;
					"\certs\certif_key.pem",;
					"Agro2024#@!",;
					"",;
					jBody:toJson(),;
					120,;
					aHeader)

		cErr := ""
		if ! Empty(cRet)
			oRet := JsonObject():new()
			if Empty(oRet:fromJson(DecodeUtf8(cRet)))
				if oRet:hasProperty("barCode") .and. oRet:hasProperty("digitableLine") .and. oRet:hasProperty("qrCodePix") .and. oRet:hasProperty("qrCodeUrl")
					Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
					SE1->E1_CODBAR := (cTmp)->E1_CODBAR := oRet["barCode"]
					SE1->E1_CODDIG := (cTmp)->E1_CODDIG := oRet["digitableLine"]
					SE1->E1_XAPI   := (cTmp)->E1_XAPI   := .T.
					SE1->( msUnlock() ) ; (cTmp)->( msUnlock() )

					FwAlertSuccess("Bordero enviado com sucesso","Sucesso")
				else
					cErr := ""
					Alert("Erro ao enviar os dados para o banco: "+cErr)
				endif
			endif
		endif

		FreeObj(jBody) ; FreeObj(oRet) ; FwFreeArray(aHeader)

	elseif cBanco == "341"

		cEndpoint  := "https://api.itau.com.br"
		cRecurso   := "/cash_management/v2/boletos"
		cAppKey	   := "4671a37e-c21b-4481-9489-40601cfaaaf3" // client_id
		cToken	   := fnToken(cBanco)

		aAdd(aHeader,"Content-Type: application/json")
		aAdd(aHeader,"Authorization: "+cToken)
		aAdd(aHeader,"x-itau-apikey: "+cAppKey)
		aAdd(aHeader,"x-itau-correlationID: "+FWUUIDV4())
		aAdd(aHeader,"x-itau-flowID: "+FWUUIDV4())

		jBody := JsonObject():new()
		//cTxt := MemoRead("/data/Json_Cobrança_Sem_Juros_e_Multa.txt")
		//jBody:fromJson(cTxt)
		jBody["data"]										:= JsonObject():new()
		jBody["data"]["etapa_processo_boleto"]				:= "efetivacao" //"validacao"
		jBody["data"]["codigo_canal_operacao"]				:= "API"

		jBody["data"]["beneficiario"]						:= JsonObject():new()
		jBody["data"]["beneficiario"]["id_beneficiario"]	:= "004500741139"
		jBody["data"]["beneficiario"]["nome_cobranca"]		:= "AGRO FAUNA COM DE INSUMOS LTDA"

		jBody["data"]["beneficiario"]["tipo_pessoa"]												:= JsonObject():new()
		jBody["data"]["beneficiario"]["tipo_pessoa"]["codigo_tipo_pessoa"]							:= "J"
		jBody["data"]["beneficiario"]["tipo_pessoa"]["numero_cadastro_nacional_pessoa_juridica"]	:= "47626510000132"

		jBody["data"]["dado_boleto"]									:= JsonObject():new()
		jBody["data"]["dado_boleto"]["descricao_instrumento_cobranca"]	:= "boleto"
		jBody["data"]["dado_boleto"]["tipo_boleto"]						:= "a vista"
		jBody["data"]["dado_boleto"]["codigo_carteira"]					:= "109"
		jBody["data"]["dado_boleto"]["valor_total_titulo"]				:= PadL(Strtran(Alltrim(Str((cTmp)->E1_VALOR,15,2)),"."),17,"0")
		jBody["data"]["dado_boleto"]["codigo_especie"]					:= "01"
		jBody["data"]["dado_boleto"]["valor_abatimento"]				:= "00000000000000000"
		jBody["data"]["dado_boleto"]["data_emissao"]					:= Transform(DtoS((cTmp)->E1_EMISSAO),"@R 9999-99-99")
		jBody["data"]["dado_boleto"]["indicador_pagamento_parcial"]		:= .T.
		jBody["data"]["dado_boleto"]["quantidade_maximo_parcial"]		:= 0

		jBody["data"]["dado_boleto"]["pagador"]								:= JsonObject():new()
		jBody["data"]["dado_boleto"]["pagador"]["pessoa"]					:= JsonObject():new()
		jBody["data"]["dado_boleto"]["pagador"]["pessoa"]["nome_pessoa"]	:= Alltrim(Posicione("SA1",1,xFilial("SA1")+(cTmp)->E1_CLIENTE+(cTmp)->E1_LOJA,"A1_NOME"))
		jBody["data"]["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]	:= JsonObject():new()
		jBody["data"]["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]["codigo_tipo_pessoa"] := SA1->A1_PESSOA
		if SA1->A1_PESSOA == "F"
			jBody["data"]["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]["numero_cadastro_pessoa_fisica"] := Alltrim(SA1->A1_CGC)
		else
			jBody["data"]["dado_boleto"]["pagador"]["pessoa"]["tipo_pessoa"]["numero_cadastro_nacional_pessoa_juridica"] := Alltrim(SA1->A1_CGC)
		endif

		jBody["data"]["dado_boleto"]["pagador"]["endereco"] := JsonObject():new()
		jBody["data"]["dado_boleto"]["pagador"]["endereco"]["nome_logradouro"]	:= Alltrim(SA1->A1_END)
		jBody["data"]["dado_boleto"]["pagador"]["endereco"]["nome_bairro"]		:= Alltrim(SA1->A1_BAIRRO)
		jBody["data"]["dado_boleto"]["pagador"]["endereco"]["nome_cidade"]		:= Alltrim(SA1->A1_MUN)
		jBody["data"]["dado_boleto"]["pagador"]["endereco"]["sigla_UF"]			:= SA1->A1_EST
		jBody["data"]["dado_boleto"]["pagador"]["endereco"]["numero_CEP"]		:= Alltrim(SA1->A1_CEP)

		jBody["data"]["dado_boleto"]["dados_individuais_boleto"] := { JsonObject():new() }
		jBody["data"]["dado_boleto"]["dados_individuais_boleto"][1]["numero_nosso_numero"]		:= Right((cTmp)->E1_IDCNAB,8)
		jBody["data"]["dado_boleto"]["dados_individuais_boleto"][1]["data_vencimento"]			:= Transform(DtoS((cTmp)->E1_VENCTO),"@R 9999-99-99")
		jBody["data"]["dado_boleto"]["dados_individuais_boleto"][1]["valor_titulo"]				:= PadL(Strtran(Alltrim(Str((cTmp)->E1_VALOR,15,2)),"."),17,"0")
		jBody["data"]["dado_boleto"]["dados_individuais_boleto"][1]["texto_seu_numero"]			:= (cTmp)->E1_IDCNAB
		jBody["data"]["dado_boleto"]["dados_individuais_boleto"][1]["texto_uso_beneficiario"]	:= "2"
		jBody["data"]["dado_boleto"]["desconto_expresso"]	:= .F.

		cRet := HTTPSPost(cEndpoint+cRecurso,;
					"\certs\itau_cert.pem",;
					"\certs\itau_key.pem",;
					"",;
					"",;
					jBody:toJson(),;
					120,;
					aHeader,;
					@cHeaderRet)

		if ! Empty(cRet)
			oRet := JsonObject():new()
			if Empty(oRet:fromJson(DecodeUtf8(cRet)))
				if oRet:hasProperty("codigo") .and. oRet:hasProperty("mensagem")
					Alert("Erro ao enviar o boleto para o banco: "+oRet["mensagem"])
				else
					Reclock("SE1",.F.) ; Reclock(cTmp,.F.)
					SE1->E1_CODBAR := (cTmp)->E1_CODBAR := oRet["data"]["dado_boleto"]["dados_individuais_boleto"][1]["codigo_barras"]
					SE1->E1_CODDIG := (cTmp)->E1_CODDIG := oRet["data"]["dado_boleto"]["dados_individuais_boleto"][1]["numero_linha_digitavel"]
					SE1->E1_XAPI   := (cTmp)->E1_XAPI   := .T.
					SE1->( msUnlock() ) ; (cTmp)->( msUnlock() )

					FwAlertSuccess("Bordero enviado com sucesso","Sucesso")
				endif
			endif
		else
			Alert("Erro ao enviar o boleto para o banco")
		endif

		FreeObj(jBody) ; FreeObj(oRet) ; FwFreeArray(aHeader)

	endif
return

class fn4FinToken
	data cBanco
	data lConsItau
	method new()
	method getToken()
endclass

method new(cBanco,lConsItau) class fn4FinToken
	default lConsItau := .F.
	::cBanco := cBanco
	::lConsItau := lConsItau
return

method getToken() class fn4FinToken
	lGeraToken := .T.
return fnToken(::cBanco,::lConsItau)

static function fnToken(cBanco,lConsItau)
	local cToken	as character
	local cEndpoint	as character
	local cRecurso	as character
	local cRetTk	as character
	local cFile		as character
	local cRet		:= ""
	local aHeader	:= {}
	local oRest		as object
	local oRet		as object

	default lConsItau := .F.

	if cBanco == "001"

		cFile := "/system/token_001.json"
		if ! lGeraToken .and. File(cFile)
			oRet := JsonObject():new()
			oRet:fromJson(MemoRead(cFile))
			cRet := "Bearer "+oRet["access_token"]
			FreeObj(oRet)
			return cRet
		endif

		cToken := "Basic ZXlKcFpDSTZJbUl3TURVMllUTXRNVFVpTENKamIyUnBaMjlRZFdKc2FXTmhaRzl5SWpvd0xDSmpiMlJwWjI5VGIyWjBkMkZ5WlNJNk56QTVPVE1zSW5ObGNYVmxibU5wWVd4SmJuTjBZV3hoWTJGdklqb3lmUTpleUpwWkNJNkltSmtPRGhpWlRNaUxDSmpiMlJwWjI5UWRXSnNhV05oWkc5eUlqb3dMQ0pqYjJScFoyOVRiMlowZDJGeVpTSTZOekE1T1RNc0luTmxjWFZsYm1OcFlXeEpibk4wWVd4aFkyRnZJam95TENKelpYRjFaVzVqYVdGc1EzSmxaR1Z1WTJsaGJDSTZNU3dpWVcxaWFXVnVkR1VpT2lKd2NtOWtkV05oYnlJc0ltbGhkQ0k2TVRjeE9EQTFNVGd5TlRJd05IMA=="
		cEndpoint := "https://oauth.bb.com.br"
		cRecurso  := "/oauth/token"

		aAdd(aHeader,"Content-Type: application/x-www-form-urlencoded")
		aAdd(aHeader,"Authorization: "+cToken)

		oRest := FwRest():new(cEndpoint)
		oRest:setPath(cRecurso)
		oRest:setPostParams('grant_type=client_credentials&scope=cobrancas.boletos-info cobrancas.boletos-requisicao ')

		if oRest:post(aHeader)
			lGeraToken := .F.
			cRetTk := oRest:getResult()
			MemoWrite(cFile,cRetTk)

			oRet := JsonObject():new()
			oRet:fromJson(cRetTk)
			cRet := "Bearer "+oRet["access_token"]

			FreeObj(oRet) ; FwFreeArray(aHeader)
		endif
		FreeObj(oRest)

	elseif cBanco == "422"

		cFile := "/system/token_422.json"
		if ! lGeraToken .and. File(cFile)
			oRet := JsonObject():new()
			oRet:fromJson(MemoRead(cFile))
			cRet := "Bearer "+oRet["access_token"]
			FreeObj(oRet)
			return cRet
		endif

		cEndpoint := "https://api.safranegocios.com.br/gateway/v1/oauth2" //"https://api-hml.safranegocios.com.br/gateway/v1/oauth2"
		cRecurso  := "/token"

		aAdd(aHeader,"Content-Type: application/x-www-form-urlencoded")

		oRest := FwRest():new(cEndpoint)
		oRest:setPath(cRecurso)
		oRest:setPostParams('client_id=664e50f95b033fcefe601bf0&username=AGRO+FAU&password=tVc7KNb9g9T2wz&refresh_token=&grant_type=password')

		if oRest:post(aHeader)
			lGeraToken := .F.
			cRetTk := oRest:getResult()
			MemoWrite(cFile,cRetTk)

			oRet := JsonObject():new()
			oRet:fromJson(cRetTk)
			cRet := "Bearer "+oRet["access_token"]

			FreeObj(oRet) ; FwFreeArray(aHeader)
		endif
		FreeObj(oRest)

	elseif cBanco == "033"

		cFile := "/system/token_033.json"
		if ! lGeraToken .and. File(cFile)
			oRet := JsonObject():new()
			oRet:fromJson(MemoRead(cFile))
			cRet := "Bearer "+oRet["access_token"]
			FreeObj(oRet)
			return cRet
		endif

		cEndpoint := "https://trust-open.api.santander.com.br/auth/oauth/v2"
		cRecurso  := "/token"

		aAdd(aHeader,"Content-Type: application/x-www-form-urlencoded")

		cRetTk := HTTPSPost(cEndpoint+cRecurso,;
					"\certs\certif_cert.pem",;
					"\certs\certif_key.pem",;
					"Agro2024#@!",;
					"",;
					"client_id=FZUAMCybSoLCWj8ulJLfoaVai1Y9m3HJ&client_secret=2UMpz1VWvpdAAAQG&grant_type=client_credentials",;
					120,;
					aHeader)

		if ! Empty(cRetTk)
			lGeraToken := .F.
			MemoWrite(cFile,cRetTk)

			oRet := JsonObject():new()
			oRet:fromJson(cRetTk)
			cRet := "Bearer "+oRet["access_token"]

			FreeObj(oRet) ; FwFreeArray(aHeader)
		endif

	elseif cBanco == "341"

		cFile := "/system/token_341.json"
		if ! lGeraToken .and. File(cFile)
			oRet := JsonObject():new()
			oRet:fromJson(MemoRead(cFile))
			cRet := "Bearer "+oRet["access_token"]
			FreeObj(oRet)
			return cRet
		endif

		cEndpoint := "https://sts.itau.com.br"
		cRecurso  := "/api/oauth/token"

		aAdd(aHeader,"Content-Type: application/x-www-form-urlencoded")

		cRetTk := HTTPSPost(cEndpoint+cRecurso,;
					"\certs\itau_cert.pem",;
					"\certs\itau_key.pem",;
					"",;
					"",;
					"client_id=4671a37e-c21b-4481-9489-40601cfaaaf3&client_secret=d89bf88f-60fb-4892-afd7-7096df1a49ea&grant_type=client_credentials",;
					120,;
					aHeader)

		if ! Empty(cRetTk)
			lGeraToken := .F.
			MemoWrite(cFile,cRetTk)

			oRet := JsonObject():new()
			oRet:fromJson(cRetTk)
			cRet := "Bearer "+oRet["access_token"]

			FreeObj(oRet) ; FwFreeArray(aHeader)
		endif

	endif
return cRet

static function doLDSafra(cCodbar,cAgencia,cConta,cNossoNum,dVencto,nValor)
	local aLinha := Array(47,"")
	local cAuxAg := PadR(cValtochar(Val(cAgencia)),5,"0")
	local cAuxCC := Strzero(Val(cConta),9)
	local cDac	 := Substr(cCodbar,5,1)
	local cFator as character
	local cAuxVl := PadL(Strtran(Alltrim(Str(nValor,8,2)),"."),10,"0")
	local cRet	 := ""
	local nAux
	local nDig
	local k

	nAux := ( StoD(Strtran(dVencto,"-")) - CtoD("07/10/97") )
	if nAux >= 10000
		cFator := Strzero(1000+nAux-10000,4)
	else
		cFator := Strzero(nAux,4)
	endif

	aLinha[01] := {"4"					,2}
	aLinha[02] := {"2"					,1}
	aLinha[03] := {"2"					,2}
	aLinha[04] := {"9"					,1}
	aLinha[05] := {"7"					,2}
	aLinha[06] := {Substr(cAuxAg,1,1)	,1}
	aLinha[07] := {Substr(cAuxAg,2,1)	,2}
	aLinha[08] := {Substr(cAuxAg,3,1)	,1}
	aLinha[09] := {Substr(cAuxAg,4,1)	,2}

	nDig := 0
	for k := 1 to 9
		nAux := Val(aLinha[k,1]) * aLinha[k,2]
		if nAux <= 9
			nDig += nAux
		elseif nAux > 9 .and. nAux < 18
			nDig += nAux % 9
		else
			nDig += 9
		endif
	next k

	nDig := nDig % 10
	if nDig != 0
		nDig := 10 - nDig
	endif

	aLinha[10] := cValtochar(nDig)

	aLinha[11] := {Substr(cAuxAg,5,1)	,1}
	aLinha[12] := {Substr(cAuxCC,1,1)	,2}
	aLinha[13] := {Substr(cAuxCC,2,1)	,1}
	aLinha[14] := {Substr(cAuxCC,3,1)	,2}
	aLinha[15] := {Substr(cAuxCC,4,1)	,1}
	aLinha[16] := {Substr(cAuxCC,5,1)	,2}
	aLinha[17] := {Substr(cAuxCC,6,1)	,1}
	aLinha[18] := {Substr(cAuxCC,7,1)	,2}
	aLinha[19] := {Substr(cAuxCC,8,1)	,1}
	aLinha[20] := {Substr(cAuxCC,9,1)	,2}

	nDig := 0
	for k := 11 to 20
		nAux := Val(aLinha[k,1]) * aLinha[k,2]
		if nAux <= 9
			nDig += nAux
		elseif nAux > 9 .and. nAux < 18
			nDig += nAux % 9
		else
			nDig += 9
		endif
	next k

	nDig := nDig % 10
	if nDig != 0
		nDig := 10 - nDig
	endif

	aLinha[21] := cValtochar(nDig)

	aLinha[22] := {Substr(cNossoNum,1,1)	,1}
	aLinha[23] := {Substr(cNossoNum,2,1)	,2}
	aLinha[24] := {Substr(cNossoNum,3,1)	,1}
	aLinha[25] := {Substr(cNossoNum,4,1)	,2}
	aLinha[26] := {Substr(cNossoNum,5,1)	,1}
	aLinha[27] := {Substr(cNossoNum,6,1)	,2}
	aLinha[28] := {Substr(cNossoNum,7,1)	,1}
	aLinha[29] := {Substr(cNossoNum,8,1)	,2}
	aLinha[30] := {Substr(cNossoNum,9,1)	,1}
	aLinha[31] := {"2"						,2}

	nDig := 0
	for k := 22 to 31
		nAux := Val(aLinha[k,1]) * aLinha[k,2]
		if nAux <= 9
			nDig += nAux
		elseif nAux > 9 .and. nAux < 18
			nDig += nAux % 9
		else
			nDig += 9
		endif
	next k

	nDig := nDig % 10
	if nDig != 0
		nDig := 10 - nDig
	endif

	aLinha[32] := cValtochar(nDig)

	aLinha[33] := cDac
	aLinha[34] := Substr(cFator,1,1)
	aLinha[35] := Substr(cFator,2,1)
	aLinha[36] := Substr(cFator,3,1)
	aLinha[37] := Substr(cFator,4,1)

	aLinha[38] := Substr(cAuxVl,01,1)
	aLinha[39] := Substr(cAuxVl,02,1)
	aLinha[40] := Substr(cAuxVl,03,1)
	aLinha[41] := Substr(cAuxVl,04,1)
	aLinha[42] := Substr(cAuxVl,05,1)
	aLinha[43] := Substr(cAuxVl,06,1)
	aLinha[44] := Substr(cAuxVl,07,1)
	aLinha[45] := Substr(cAuxVl,08,1)
	aLinha[46] := Substr(cAuxVl,09,1)
	aLinha[47] := Substr(cAuxVl,10,1)

	aEval(aLinha,{|x| cRet += Iif(Valtype(x)=="A",x[1],x) })
return cRet

static function fnPickAccount(cBanco)
	local cBkpCad	:= Iif(Type("cCadastro")!="U",cCadastro,nil)
	local cTexto	as character
	local nIndex	as numeric
	local lFind		:= .F.
	local lOk		:= .T.
	local aConta	:= {}
	local aAux		:= {}
	local aPar		:= {}
	local xBkpMv	:= MV_PAR01

	while SEE->( ! Eof() .and. EE_FILIAL+EE_CODIGO == xFilial()+cBanco )
		if SEE->EE_SUBCTA == "4FI"
			lFind := .T.

			cTexto := Alltrim(SEE->EE_AGENCIA)
			cTexto += Iif(!Empty(SEE->EE_DVAGE),"-"+Alltrim(SEE->EE_DVAGE),"")
			cTexto += " / "
			cTexto += Alltrim(SEE->EE_CONTA)
			cTexto += Iif(!Empty(SEE->EE_DVCTA),"-"+Alltrim(SEE->EE_DVCTA),"")

			aAdd(aConta,{SEE->(Recno()),cTexto})
		endif
		SEE->( dbSkip() )
	end

	if lFind
		for nIndex := 1 to Len(aConta)
			aAdd(aAux,aConta[nIndex,2])
		next nIndex

		cCadastro := "TOTVS"
		aPar := {{3,"Agencia/Conta",1,aAux,50,"",.F.}}

		if ParamBox(aPar,"Escolha a Conta",,,,,,,,,.F.)
			SEE->( dbGoto(aConta[MV_PAR01][1]) )
		else
			lOk := .F.
		endif

		if cBkpCad != nil
			cCadastro := cBkpCad
		endif
		MV_PAR01 := xBkpMv
	else
		lOk := .F.
		ApMsgInfo("nao encontrado parametros para este banco")
	endif

	FwFreeArray(aConta) ; FwFreeArray(aAux) ; FwFreeArray(aPar)
return lOk
