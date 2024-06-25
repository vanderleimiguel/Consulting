//feature/RTASK0018793-Pagto-Dois-Cartoes - Wagner Neves - 17/05/2024

#include "totvs.ch"
#include "topconn.ch"
#include "tbiconn.ch"

/*/{Protheus.doc} MGFFATA4	 
Integracao de pedidos de venda do E-Commerce
@type function

@author Josué Danich
@since 10/08/2020
@version P12
/*/

user function MGFFATA4()

	U_MFGCONOU('Iniciando integração de pedidos do E-Commerce...')

	PREPARE ENVIRONMENT EMPRESA "01" FILIAL "010041"

	U_MFGCONOU('Recuperando pedidos do OCC...')
	MGFFATA4R()
	U_MFGCONOU("Completou recuperação de pedidos do OCC")

	U_MFGCONOU('Validando registros na tabela de caução...')
	MGFFATA4V()
	U_MFGCONOU('Completou validação de registros na tabela de caução')

	U_MFGCONOU('Validando registros faturados na tabela de caução...')
	MGFFATA4F()
	U_MFGCONOU('Completou validação de registros faturados na tabela de caução')


return

/*/{Protheus.doc} MGFFATA4R 
Recupera pedidos de venda do E-Commerce
@type function

@author Josué Danich
@since 10/08/2020
@version P12
/*/
Static function MGFFATA4R()

	Local _curl := getmv("MGFFATA42",,"https://p1596728c1prd-admin.occa.ocs.oraclecloud.com/ccadmin/v1/orders/?queryFormat=SCIM&useAdvancedQParser=true&q=state%20eq%20%22SUBMITTED%22%20and%20siteId%20eq%20%22siteUS%22%20and%20x_paymentApprover%20eq%20true")
	Local _curl2 := getmv("MGFFATA4R")
	local cTpPedEcom	:= allTrim( superGetMv( "MGF_PVECOM", , "EC" ) )
	local cCondPgEco	:= allTrim( superGetMv( "MGFECOCDPG", , "999" ) )
	Local _nerros		:=	0
	Local _cMsgSZ1		:=	''
	Local _cMsgErr
	Local _cApikey  	:= AllTrim( GetMv("MGFURLDG03",.F.,''))

	Local _nTxCaucao		:= superGetMv( "MGFECOTXCA", , 1 )
	Local _cNomtag
	Local _lCaptnoPv

	Local _ndias
	Local _cDiaIni

	Private cEr := ''

	//puxa token do OCC

	_curltoken := getmv("MGFFATA4T",,"https://p1596728c1prd-admin.occa.ocs.oraclecloud.com/ccadmin/v1/login")

	aHeadStr := {}
	aadd( aHeadStr, 'Content-Type: application/x-www-form-urlencoded')

	_cauth := getmv("MGFFATA4A",, "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIzNTJlNWU1Zi1jYmQ0LTQ1MTMtYTlhZC00YTgwOWEzNTY4OGIiLCJpc3MiOiJhcHBsaWNhdGlvbkF1dGgiLCJleHAiOjE2NjM3ODQ1NzAsImlhdCI6MTYzMjI0ODU3MH0=.LvD71raNXeagPf10WXoyZMCa414pRsMBQj9uX4fMNds=")

	aadd( aHeadStr, 'Authorization: ' + _cauth)

	cHeaderRet := ""

	_cret := httpQuote( _cURLtoken /*<cUrl>*/, "POST" /*<cMethod>*/, /*[cGETParms]*/, 'grant_type=client_credentials' /*[cPOSTParms]*/, 120 /*[nTimeOut]*/, aHeadStr /*[aHeadStr]*/, cHeaderRet /*[@cHeaderRet]*/ )

	nStatuHttp	:= httpGetStatus()


	U_MFGCONOU(" [MGFFATA4] * * * * * Status da integracao * * * * *")
	U_MFGCONOU(" [MGFFATA4] URL..........................: " + _cURLToken)
	U_MFGCONOU(" [MGFFATA4] HTTP Method..................: " + "POST")
	U_MFGCONOU(" [MGFFATA4] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) )
	U_MFGCONOU(" [MGFFATA4] Retorno........................: " + substr(_cret,1,100))
	U_MFGCONOU(" [MGFFATA4] * * * * * * * * * * * * * * * * * * * * ")

	If nStatuHttp < 200 .or. nStatuHttp > 299
		U_MFGCONOU('Falha ao recuperar TOKEN OCC, encerrando rotina!')
		Return
	Endif

	oJsont := JsonObject():New()
	oJsont:FromJson(_cret)

	_cauthped := ojsont['access_token']

	//Puxa pedidos do OCC
	cTimeIni	:= time()
	cHeaderRet	:= ""
	aHeadStr := {}
	aHeadStr2 := {}
	aadd( aHeadStr, 'Content-Type: application/json')
	aadd( aHeadStr, 'Authorization: Bearer ' + _cauthped)
	aadd( aHeadStr2, 'Content-Type: application/json')
	If !empty(_cApikey)
		aadd(aHeadStr2,'apikey: ' + alltrim(_cApikey))
	endif

	_canof := substr(dtos(date()),1,4)
	_cmesf := substr(dtos(date()),5,2)
	_cdiaf := substr(dtos(date()),7,4)

	_ndias := getmv("MGFFATA4W",,0)
	_cDiaIni	:=	dtos(date() - _ndias)

	_canoi := substr(_cDiaIni,1,4)
	_cmesi := substr(_cDiaIni,5,2)
	_cdiai := substr(_cDiaIni,7,4)

	curlpost2 := strtran(_curl2,"%ANO%",_canoi)
	curlpost2 := strtran(curlpost2,"%MES%",_cmesi)
	curlpost2 := strtran(curlpost2,"%DIA%",_cdiai)

	_cret2 := httpQuote( cURLPost2 /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, "" /*[cPOSTParms]*/, 120 /*[nTimeOut]*/, aHeadStr2 /*[aHeadStr]*/, cHeaderRet /*[@cHeaderRet]*/ )

	_dtini := date()-3

	_cano := substr(dtos(_dtini),1,4)
	_cmes := substr(dtos(_dtini),5,2)
	_cdia := substr(dtos(_dtini),7,2)

	_curl := _curl + "%20and%20submittedDate%20gt%20%22" + _cano + "%2D" + _cmes + "%2D" + _cdia + "%22"

	_cret := httpQuote( _cURL /*<cUrl>*/, "GET" /*<cMethod>*/, /*[cGETParms]*/, "" /*[cPOSTParms]*/, 120 /*[nTimeOut]*/, aHeadStr /*[aHeadStr]*/, cHeaderRet /*[@cHeaderRet]*/ )

	nStatuHttp	:= httpGetStatus()
	cTimeFin	:= time()
	cTimeProc	:= elapTime( cTimeIni, cTimeFin )

	fGrvJson()

	U_MFGCONOU(" [MGFFATA4] * * * * * Status da integracao * * * * *")
	U_MFGCONOU(" [MGFFATA4] Inicio.......................: " + cTimeIni + " - " + dToC(dDataBase))
	U_MFGCONOU(" [MGFFATA4] Fim..........................: " + cTimeFin + " - " + dToC(dDataBase))
	U_MFGCONOU(" [MGFFATA4] Tempo de Processamento.......: " + cTimeProc)
	U_MFGCONOU(" [MGFFATA4] URL..........................: " + _cURL)
	U_MFGCONOU(" [MGFFATA4] HTTP Method..................: " + "GET")
	U_MFGCONOU(" [MGFFATA4] Status Http (200 a 299 ok)...: " + allTrim( str( nStatuHttp ) ) )
	U_MFGCONOU(" [MGFFATA4] Retorno........................: " + substr(_cret,1,100))
	U_MFGCONOU(" [MGFFATA4] * * * * * * * * * * * * * * * * * * * * ")

	If nStatuHttp < 200 .or. nStatuHttp > 299
		U_MFGCONOU('Falha ao recuperar pedidos de venda, encerrando rotina!')
		Return
	Else
		oJson := JsonObject():New()
		oJson:FromJson(_cret)
		_nni := 1
		_nlast := len(ojson["items"])

		Do while _nni <= _nlast

			U_MFGCONOU('Validando pedido ' + strzero(_nni,6) + ' de ' + strzero(_nlast,6) + '...' )

			IF ojson["items"][_nni]["commerceItems"][_nin]["mf_tradedItems"] <>  Nil

				BEGIN SEQUENCE

					_nerros := 0

					If ojson["items"][_nni]["state"] == "SUBMITTED"

						ZC5->(Dbsetorder(1))  //ZC5_FILIAL+ZC5_IDSFA

						_cMsgSZ1	:=	alltrim(ojson["items"][_nni]["_filialCD"])+alltrim(ojson["items"][_nni]["id"])

						_cfilial := alltrim(ojson["items"][_nni]["_filialCD"])

						//Se for da filial de depósito fechado ajusta procura
						If getmv("MGF_DEPFE0",,.F.) .AND. U_VerDepFec(alltrim(ojson["items"][_nni]["_filialCD"]))  //filial física do depósito fechado

							//filial fiscal do depósito fechado
							_cMsgSZ1	:= ZM0->ZM0_CODFIL + alltrim(ojson["items"][_nni]["id"])
							_cfilial    := ZM0->ZM0_CODFIL

						Endif

						If ZC5->(Dbseek(_cMsgSZ1))
							U_MFGCONOU('Pedido ' + ojson["items"][_nni]["id"] + " - " + strzero(_nni,6) + ' de ' + strzero(_nlast,6) + ' já consta na ZC5...')
						Else
							SA1->(Dbsetorder(15)) //A1_ZCDECOM
							_cMsgSZ1	:=	alltrim(ojson["items"][_nni]["organizationId"])
							If Empty(_cMsgSZ1)	.or.	!(SA1->(Dbseek(_cMsgSZ1)))
								_cMsgErr	:=	'Pedido ' + ojson["items"][_nni]["id"] + " - " + strzero(_nni,6) + ' de ' + strzero(_nlast,6) + ' com cliente inválido!' + " organizationId : " + alltrim(ojson["items"][_nni]["organizationId"])
								U_MFGCONOU(_cMsgErr)
								_nerros++
								//Se teve erro de cliente nem tenta gravar na ZC5 pois pode ser que
								//o cliente seja preenchido no json posteriormente
								BREAK
							Endif

							SA3->(Dbsetorder(1)) //A3_FILIAL+A3_COD

							If !(SA3->(Dbseek(xfilial("SA3")+alltrim(ojson["items"][_nni]["idVendedor"]))) .and. alltrim(SA3->A3_COD) == ALLTRIM(ojson["items"][_nni]["idVendedor"]))
								_cMsgErr	:=	'Pedido ' + ojson["items"][_nni]["id"] + " - " + strzero(_nni,6) + ' de ' + strzero(_nlast,6) + ' com vendedor inválido!' + " idVendedor : " + alltrim(ojson["items"][_nni]["idVendedor"])
								U_MFGCONOU(_cMsgErr)
								_nerros++
								//Se teve erro de vendedor nem tenta gravar na ZC5 pois pode ser que
								//o vendedor seja preenchido no json posteriormente
								BREAK
							Endif

							BEGIN TRANSACTION
								_nnj := 1//WN
								Do While _nnj <= len(ojson["items"][_nni]["paymentGroups"])//WN
									_cnsu		:= ""
									_cpayid		:= ""
									_cidprof	:= ""
									_nvalres	:= 0
									_cRawRes	:= ""
									_cOrIdJson	:= ""
									_cTrIdJson	:= ""
									_cPaymMeth	:=	""
									_cGatePg	:=	alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["gatewayName"])
									if valtype(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["transactionId"]) == "C"

										If ! _cGatePg == "NewInvoiceGateway"

											If valtype(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["type"]) == "C"
												If "PIX" $ ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["type"]
													_cPaymMeth := "PIXJPAYMEN"
												Endif
											Endif

											If _cGatePg	==	"getnetGateway"
												_cnsu := alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["acquirer_transaction_id"])
												_cNomtag	:=	"payment_id"
											ElseIf _cGatePg	==	"payu-latam"
												_cRawRes	:=	alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["paymentProps"]["rawResponse"])
												_cRawRes	:=	Decode64(_cRawRes)
												oJsonRaw := JsonObject():new()
												fwJsonDeserialize( _cRawRes, @oJsonRaw )
												_cOrIdJson := oJsonRaw:transactionResponse:orderId
												_cTrIdJson := oJsonRaw:transactionResponse:transactionId
												_cnsu := _cOrIdJson
												_cNomtag	:=	"payment_id"
											ElseIf "jpayment-" $_cGatePg
												_cRawRes	:=	alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["rawResponse"])
												_cRawRes	:=	Decode64(_cRawRes)
												oJsonRaw	:= JsonObject():new()
												fwJsonDeserialize( _cRawRes, @oJsonRaw )
												_cOrIdJson	:= oJsonRaw:orderId
												_cTrIdJson	:= oJsonRaw:transactionId
												_cnsu		:= _cOrIdJson
												_cNomtag	:=	"paymentId"
											Endif

											_cpayid := alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"][_cNomtag])
											_cidprof := alltrim(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["card_id"])

											If "jpayment-"	$	_cGatePg
												If ojson["items"][_nni]["paymentGroups"][_nnj]["amountAuthorized"]	<> Nil
													_nvalres := ojson["items"][_nni]["paymentGroups"][_nnj]["amountAuthorized"] * _nTxCaucao
												Endif
											Else
												If ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["valorReservado"]	<> Nil
													_nvalres := VAL(ojson["items"][_nni]["paymentGroups"][_nnj]["authorizationStatus"][1]["statusProps"]["valorReservado"])
												Endif
											Endif
										Endif
									Endif

									Reclock("ZC5",.T.)

									//Se for da filial de depósito fechado ajusta ZC5_FILIAL e marca como depósito fechado
									If getmv("MGF_DEPFE0",,.F.);
											.AND. alltrim(ojson["items"][_nni]["_filialCD"]) == ZM0->ZM0_FILFIS	// JA ESTA POSICIONADO NO DEP.FECHADO

										//filial física do depósito fechado
										ZC5->ZC5_FILIAL := ZM0->ZM0_CODFIL	//filial fiscal do depósito fechado
										ZC5->ZC5_PROMOC := ZM0->ZM0_FILFIS	 //guarda filial física para gravar C5_CLIRET e C5_LOJARET
										ZC5->ZC5_MENPAD := ALLTRIM(ZM0->ZM0_MENNOT)

									Else

										ZC5->ZC5_FILIAL :=  alltrim(ojson["items"][_nni]["_filialCD"])
										ZC5->ZC5_PROMOC := 'false'

									Endif


									ZC5->ZC5_CLIENT := alltrim(SA1->A1_CGC)
									ZC5->ZC5_ZTIPPE := allTrim( superGetMv( "MGF_PVECOM", , "EC" ) )
									ZC5->ZC5_VENDED := alltrim(ojson["items"][_nni]["idVendedor"])


									_cidend := ""

									if valtype(ojson["items"][_nni]["shippingGroups"][1]["shippingAddress"]["IdProtheus"]) == "C"
										_cidend := alltrim(ojson["items"][_nni]["shippingGroups"][1]["shippingAddress"]["IdProtheus"])
									Endif

									ZC5->ZC5_ZIDEND := _cidend

									ZC5->ZC5_STATUS := '1' //Recebido

									ZC5->ZC5_ZTIPOP := allTrim( superGetMv( "MGF_OPECOM", , "BJ" ) )

									//Se for pedido de depósito fechado vai puxar tipo de operação específico
									If getmv("MGF_DEPFE0",,.F.);
											.AND. alltrim(ojson["items"][_nni]["_filialCD"]) == ZM0->ZM0_FILFIS  //filial física do depósito fechado

										ZC5->ZC5_ZTIPOP	:= ZM0->ZM0_TPOPER	//allTrim( getMv( "MGF_DEPFEF",,"VD" ) )

									Endif

									ZC5->ZC5_HRRECE  := TIME()
									ZC5->ZC5_IDSFA  := alltrim(ojson["items"][_nni]["id"]+cValToChar(_nnj))//WN
									ZC5->ZC5_INTEGR	:= "P"

									_dtent := dtos(date()+2)
									_dtform := substr(_dtent,1,4) + "-" + substr(_dtent,5,2) + "-" + substr(_dtent,7,2)

									If valtype(ojson["items"][_nni]["_dataEntrega"]) == "C"
										_dtform := substr(alltrim(ojson["items"][_nni]["_dataEntrega"]),1,10) //   "2021-04-20T00:39:26.000Z"
									Endif

									ZC5->ZC5_DTENTR := STOD(strTran( left( allTrim( _dtform ) , 10 ) , "-" ))

									ZC5->ZC5_ORIGEM := '003'
									ZC5->ZC5_DTRECE := DATE()
									ZC5->ZC5_RESERV := 'S'
									ZC5->ZC5_IDEXTE := alltrim(ojson["items"][_nni]["id"])
									ZC5->ZC5_ORCAME := 'N'
									ZC5->ZC5_PVREDE := 'N'
									ZC5->ZC5_CODTAB :=  alltrim(ojson["items"][_nni]["priceGroupId"])
									ZC5->ZC5_CODCON := alltrim(cCondPgEco)
									ZC5->ZC5_ZTIPES := 'N'
									ZC5->ZC5_ORIGPV := "E"
									ZC5->ZC5_USANCC := '0'
									ZC5->ZC5_NSU := _cnsu
									ZC5->ZC5_IDPROF := _cidprof
									ZC5->ZC5_PAYMID := _cpayid
									ZC5->ZC5_VALCAU := _nvalres
									ZC5->ZC5_ZGATEP := _cGatePg
									ZC5->ZC5_ZATORD  := _cOrIdJson
									ZC5->ZC5_ZGTRID := _cTrIdJson

									If alltrim(_cPaymMeth) == 'PIXJPAYMEN'
										ZC5->ZC5_PAYMET			:= _cPaymMeth
									Endif

									_lCaptnoPv	:=	ojson["items"][_nni]["mm_payment_complete"]

									If _lCaptnoPv
										ZC5->ZC5_JSNCAU		:= _cRawRes		//"definir json no getorders"
									Else
										ZC5->ZC5_JSNCAU		:= ""
									Endif


									ZC5->(Msunlock())

									_nnj++//WN
								EndDo//WN

								_ntot := len(ojson["items"][_nni]["commerceItems"])
								_nin := 1

								Do while _nin <= _ntot

									Reclock("ZC6",.T.)

									ZC6->ZC6_FILIAL := _cfilial
									ZC6->ZC6_ITEM := alltrim(str(_nin))
									ZC6->ZC6_PRODUT := alltrim(ojson["items"][_nni]["commerceItems"][_nin]["productId"])

									ZC6->ZC6_QTDVEN := val(ojson["items"][_nni]["commerceItems"][_nin]["mf_tradedItems"])

									If ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['salePrice'] > 0
										ntotit := ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['salePrice']
									Else
										ntotit := ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['listPrice']
									Endif

									ZC6->ZC6_PRCVEN := ntotit
									ZC6->ZC6_OPER := allTrim( superGetMv( "MGF_OPECOM", , "BJ" ) )
									ZC6->ZC6_IDSFA := alltrim(ojson["items"][_nni]["id"])

									If ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['discountable']	.and. Len(ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['itemDiscountInfos']) > 0
										ntotit := ojson["items"][_nni]["commerceItems"][_nin]['priceInfo']['itemDiscountInfos'][1]['amount']
									Else
										ntotit := 0
									Endif

									ZC6->ZC6_DSCITE := ntotit

									ZC6->(Msunlock())

									_nin++

								Enddo

							END TRANSACTION


						Endif

					Else

						U_MFGCONOU('Pedido ' + ojson["items"][_nni]["id"] + " - " + strzero(_nni,6) + ' de ' + strzero(_nlast,6) + ' não está submetido...' )

					Endif

				END SEQUENCE

			Endif

			_nni++

		Enddo

	Endif

Return


/*/{Protheus.doc} MGFFATA4V 
Verifica e corrige tabela ZE6010
@type function

@author Josué Danich
@since 10/08/2020
@version P12
/*/

static function MGFFATA4V()

	_ndias := getmv("MGFFATA4V",,60)

	U_MFGCONOU("Carregando pedidos órfãos...")

//Seleciona pedidos dos últimos 60 dias que não tem ZE6
	cQryZC5 := "SELECT ZC5.R_E_C_N_O_ ZC5RECNO"												+ CRLF
	cQryZC5 += " FROM "			+ retSQLName("ZC5") + " ZC5"								+ CRLF
	cQryZC5 += " WHERE"																		+ CRLF
	cQryZC5 += " 	ZC5.ZC5_STATUS	=	'3'"												+ CRLF
	cQryZC5 += " 	AND	ZC5_DTRECE >= '" + DTOS(DATE()-_ndias) + "' "						+ CRLF
	cQryZC5 += " 	AND ZC5_NSU > ' ' "														+ CRLF
	cQryZC5 += " 	AND NOT EXISTS(SELECT ZE6.R_E_C_N_O_ FROM ZE6010 ZE6 WHERE ZE6.D_E_L_E_T_ <> '*' "  + CRLF
	cQryZC5 += " 	                                                     AND ZC5.ZC5_NSU = ZE6.ZE6_NSU ) " + CRLF
	cQryZC5 += " 	AND	ZC5.D_E_L_E_T_	<>	'*'"											+ CRLF
	cQryZC5 += " ORDER BY ZC5_IDSFA"														+ CRLF

	tcQuery cQryZC5 new Alias "QRYZC5T"

	_ntot := 0
	_nni := 1

	If QRYZC5T->( EOF() )

		U_MFGCONOU("Não foram localizados pedidos órfãos")
		QRYZC5T->(Dbclosearea())
		Return

	Else

		U_MFGCONOU("Contando pedidos órfãos...")

		Do while !QRYZC5T->( EOF() )

			_ntot++
			QRYZC5T->( Dbskip() )

		Enddo

		QRYZC5T->(Dbgotop())

	Endif


//Cria ZE6 para pedidos órfãos
	Do while !QRYZC5T->( EOF() )

		ZC5->(Dbgoto(QRYZC5T->ZC5RECNO))

		U_MFGCONOU("Criando ZE6 para pedido órfão " + ALLTRIM(ZC5->ZC5_IDSFA) + " - " + strzero(_nni,6) +  " de " + strzero(_ntot,6) + "...")

		cQryZE6 := "SELECT R_E_C_N_O_ REC "											+ CRLF
		cQryZE6 += " FROM " + retSQLName("ZE6") + " ZE6"							+ CRLF
		cQryZE6 += " WHERE"															+ CRLF
		cQryZE6 += " 		ZE6.ZE6_NSU		=	'" + alltrim(ZC5->ZC5_NSU)	+ "'"	+ CRLF
		cQryZE6 += " 	AND	ZE6.ZE6_FILIAL	=	'" + xFilial("ZE6")			+ "'"	+ CRLF
		cQryZE6 += " 	AND	ZE6.D_E_L_E_T_	<>	'*'"								+ CRLF

		tcQuery cQryZE6 New Alias "QRYZE6"

		if QRYZE6->(EOF())

			SA1->(Dbsetorder(3)) //A1_FILIAL+A1_CGC

			if (SA1->(Dbseek(xfilial("SA1")+alltrim(ZC5->ZC5_CLIENT))))

				RecLock("ZE6",.T.)
				ZE6->ZE6_FILIAL		:= ZC5->ZC5_FILIAL
				ZE6->ZE6_STATUS		:= "0"		// 0-Caução / 1-Título Gerado / 2-Título Baixado / 3-Erro
				ZE6->ZE6_PEDIDO     := ZC5->ZC5_PVPROT
				ZE6->ZE6_CLIENT		:= SA1->A1_COD
				ZE6->ZE6_LOJACL		:= SA1->A1_LOJA
				ZE6->ZE6_CNPJ		:= SA1->A1_CGC
				ZE6->ZE6_NOMECL		:= SA1->A1_NOME
				ZE6->ZE6_NSU		:= ZC5->ZC5_NSU
				ZE6->ZE6_IDTRAN		:= ZC5->ZC5_PAYMID
				ZE6->ZE6_DTINCL		:= date()
				ZE6->ZE6_VALCAU		:= ZC5->ZC5_VALCAU
				ZE6->ZE6_CODADM		:= '001'
				ZE6->ZE6_DESADM		:= 'MASTERCARD A VISTA'

				//Verifica se já tem nota fiscal
				SD2->(Dbsetorder(8)) //D2_FILIAL+D2_PEDIDO
				SE1->(Dbsetorder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA
				ZEC->(Dbsetorder(1)) //ZEC_FILIAL+ZEC_COD

				If SD2->(Dbseek(ZC5->ZC5_FILIAL+ZC5->ZC5_PVPROT));
						.AND. SE1->(Dbseek(SD2->D2_FILIAL+SD2->D2_SERIE+SD2->D2_DOC))

					ZE6->ZE6_STATUS	=	'1'
					ZE6->ZE6_NOTA	=	SD2->D2_DOC
					ZE6->ZE6_SERIE	=	SD2->D2_SERIE
					ZE6->ZE6_DTNOTA	=	SD2->D2_EMISSAO
					ZE6->ZE6_VALEFE	=	SE1->E1_VALOR - (SE1->E1_VALOR/100*1.75)
					ZE6->ZE6_VALREA	=	SE1->E1_VALOR
					ZE6->ZE6_VENCTO	=	SD2->D2_EMISSAO+30
					ZE6->ZE6_VENCRE	=	dataValida( SD2->D2_EMISSAO+30, .T. )
					ZE6->ZE6_OBS		=	'Título Gerado'
					ZE6->ZE6_PREFIX	=	SE1->E1_PREFIXO
					ZE6->ZE6_TITULO	=	SE1->E1_NUM
					ZE6->ZE6_PARCEL	=	SE1->E1_PARCELA
					ZE6->ZE6_TIPO	=	'CC'

				Endif

				ZE6->(MsUnLock())

			Endif

		Endif

		QRYZE6->(Dbclosearea())

		U_MFGCONOU("Gravou ZE6 para pedido órfão " + ALLTRIM(ZC5->ZC5_IDSFA) + " - " + strzero(_nni,6) +  " de " + strzero(_ntot,6) + "...")

		_nni++

		QRYZC5T->( Dbskip() )

	Enddo

	QRYZC5T->(Dbclosearea())

Return


/*/{Protheus.doc} MGFFATA4F
Verifica e corrige itens faturados da tabela ZE6010
@type function

@author Josué Danich
@since 10/08/2020
@version P12
/*/

static function MGFFATA4F()

	_ndias := getmv("MGFFATA4V",,60)

	U_MFGCONOU("Carregando nota órfãs...")

//Seleciona ZE6 dos ultimos 60 dias que tem SD2 mas não estão com faturamento marcado
	cQryZC5 := "select ZE6.R_E_C_N_O_ RECNO"												+ CRLF
	cQryZC5 += " FROM "			+ retSQLName("ZE6") + " ZE6"								+ CRLF
	cQryZC5 += " WHERE"																		+ CRLF
	cQryZC5 += " 	ZE6_STATUS <> '5' AND ZE6_STATUS <> '3'"								+ CRLF
	cQryZC5 += " 	AND	ZE6_DTINCL >= '" + DTOS(DATE()-_ndias) + "' "						+ CRLF
	cQryZC5 += " 	AND ZE6_NOTA = ' ' "														+ CRLF
	cQryZC5 += " 	AND EXISTS(SELECT R_E_C_N_O_ FROM SD2010 SD2 WHERE D2_FILIAL = ZE6_FILIAL AND D2_PEDIDO = ZE6_PEDIDO "  + CRLF
	cQryZC5 += " 	                                                     AND SD2.D_E_L_E_T_ <> '*' ) " + CRLF
	cQryZC5 += " 	AND	ZE6.D_E_L_E_T_	<>	'*'"											+ CRLF

	tcQuery cQryZC5 new Alias "QRYZC5T"

	_ntot := 0
	_nni := 1

	If QRYZC5T->( EOF() )

		U_MFGCONOU("Não foram localizados notas órfãs")
		QRYZC5T->(Dbclosearea())
		Return

	Else

		U_MFGCONOU("Contando notas órfãs...")

		Do while !QRYZC5T->( EOF() )

			_ntot++
			QRYZC5T->( Dbskip() )

		Enddo

		QRYZC5T->(Dbgotop())

	Endif


//marca ZE6 que já estão com faturamento
	Do while !QRYZC5T->( EOF() )

		ZE6->(Dbgoto(QRYZC5T->RECNO))

		U_MFGCONOU("Marcando ZE6 para nota órfã " + ALLTRIM(ZE6->ZE6_FILIAL) + " - " + ALLTRIM(ZE6->ZE6_PEDIDO) + " - " + strzero(_nni,6) +  " de " + strzero(_ntot,6) + "...")

		SD2->(Dbsetorder(8)) //D2_FILIAL+D2_PEDIDO
		SF2->(Dbsetorder(1)) //F2_FILIAL+F2_DOC)
		SE1->(Dbsetorder(1)) //E1_FILIAL+E1_PREFIXO+E1_NUM

		if (SD2->(Dbseek(ZE6->ZE6_FILIAL+ZE6->ZE6_PEDIDO)) .AND. SF2->(Dbseek(SD2->D2_FILIAL+SD2->D2_DOC));
				.AND.  SE1->(Dbseek(SD2->D2_FILIAL+SD2->D2_SERIE+SD2->D2_DOC)) )

			Reclock("ZE6",.F.)
			ZE6->ZE6_STATUS	=	'1'
			ZE6->ZE6_NOTA	=	SD2->D2_DOC
			ZE6->ZE6_SERIE	=	SD2->D2_SERIE
			ZE6->ZE6_DTNOTA	=	SD2->D2_EMISSAO
			ZE6->ZE6_VALEFE	=	SE1->E1_VALOR - (SE1->E1_VALOR/100*1.75)
			ZE6->ZE6_VALREA	=	SE1->E1_VALOR
			ZE6->ZE6_VENCTO	=	SD2->D2_EMISSAO+30
			ZE6->ZE6_VENCRE	=	dataValida( SD2->D2_EMISSAO+30, .T. )
			ZE6->ZE6_OBS		=	'Título Gerado'
			ZE6->ZE6_PREFIX	=	SE1->E1_PREFIXO
			ZE6->ZE6_TITULO	=	SE1->E1_NUM
			ZE6->ZE6_PARCEL	=	SE1->E1_PARCELA
			ZE6->ZE6_TIPO	=	'CC'

			ZE6->(MsUnLock())

			Reclock("SE1",.F.)
			SE1->E1_ZNSU	:= ALLTRIM(ZE6->ZE6_NSU)
			SE1->(Msunlock())

		Endif

		U_MFGCONOU("Gravou ZE6 para pedido órfão " + ALLTRIM(ZC5->ZC5_IDSFA) + " - " + strzero(_nni,6) +  " de " + strzero(_ntot,6) + "...")

		_nni++

		QRYZC5T->( Dbskip() )

	Enddo

	QRYZC5T->(Dbclosearea())

Return


Static Function fGrvJson()
	Local cFile := 'C:\TEMP\TESTEJSON.TXT'
	Local cJsonStr,oJsonW
	Local cerr := ""

// Le a string JSON do arquivo do disco 
	cJsonStr := "" //readfile(cFile)
	cTeste := ''
// Cria o objeto JSON e popula ele a partir da string
	oJsonW := JSonObject():New()
	_cRet  := oJSonW:fromJson(cJsonStr)

	If !empty(cErr)
		MsgStop(cErr,"JSON PARSE ERROR")
		Return
	Endif
Return(_cRet)
