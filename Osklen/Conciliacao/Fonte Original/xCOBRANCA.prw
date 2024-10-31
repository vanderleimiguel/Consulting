#include "totvs.ch"
/*/{Protheus.doc} xCOBRANCA
	envia email de cobranca para os clientes
	@type function
	@version 1.0
	@author ivan.caproni
	@since 10/04/2023
/*/
user function xCOBRANCA(aParms)
	local dDias		as date
	local nD		as numeric
	local aInfo		as array
	local cTbl		as character
	local cCliente	as character
	local cCorpo	as character
	local cPara		as character
	local cEmail	as character
	local cAssunto	as character

	if Select("SX2") == 0
		if aParms == nil
			return
		endif
		RpcSetEnv(aParms[1],aParms[2])
	endif

	dDias := Date()
	for nD := 1 to GetMv("FC_NUMDIA1",,2)
		dDias := DataValida(dDias + 1,.T.)
	next nD
	
	cEmail := GetMv("FC_FLDMAIL",,"A1_EMAIL")

	cTbl := GetNextAlias()
	BeginSql alias cTbl
		column E1_VENCREA as date
		SELECT E1_CLIENTE,E1_LOJA,E1_NUM,E1_PARCELA,E1_VENCREA,E1_SALDO
		FROM %table:SE1%
		WHERE E1_FILIAL=%xFilial:SE1%
			AND E1_VENCREA = %exp:dDias%
			AND E1_SALDO > 0
			AND E1_TIPO NOT IN ('NCC','RA')
			AND %notDel%
		ORDER BY E1_CLIENTE,E1_LOJA
	EndSql

	aInfo := {}
	while (cTbl)->( ! Eof() )
		cCliente := (cTbl)->(E1_CLIENTE+E1_LOJA)
		
		aAdd(aInfo,{(cTbl)->E1_NUM,;
					(cTbl)->E1_PARCELA,;
					(cTbl)->E1_VENCREA,;
					(cTbl)->E1_SALDO,;
					Alltrim(Posicione("SA1",1,xFilial()+cCliente,"A1_NOME"))})

		(cTbl)->( dbSkip() )

		if (cTbl)->( cCliente != E1_CLIENTE+E1_LOJA .or. Eof() )
			cAssunto := "Boletos a vencer"
			cCorpo	 := getHtmlaVencer(aInfo)
			cPara	 := SA1->&cEmail

			aInfo := U_xEMAIL2(cAssunto, cCorpo, cPara)
			aInfo := {}
		endif
	end
	(cTbl)->( dbClosearea() )

	dDias := Date()
	for nD := 1 to GetMv("FC_NUMDIA2",,2)
		dDias := DataValida(dDias - 1,.F.)
	next nD

	cTbl := GetNextAlias()
	BeginSql alias cTbl
		column E1_VENCREA as date
		SELECT E1_CLIENTE,E1_LOJA,E1_NUM,E1_PARCELA,E1_VENCREA,E1_SALDO
		FROM %table:SE1%
		WHERE E1_FILIAL=%xFilial:SE1%
			AND E1_VENCREA = %exp:dDias%
			AND E1_SALDO > 0
			AND E1_TIPO NOT IN ('NCC','RA')
			AND %notDel%
		ORDER BY E1_CLIENTE,E1_LOJA
	EndSql

	aInfo := {}
	while (cTbl)->( ! Eof() )
		cCliente := (cTbl)->(E1_CLIENTE+E1_LOJA)
		
		aAdd(aInfo,{(cTbl)->E1_NUM,;
					(cTbl)->E1_PARCELA,;
					(cTbl)->E1_VENCREA,;
					(cTbl)->E1_SALDO,;
					Alltrim(Posicione("SA1",1,xFilial()+cCliente,"A1_NOME"))})

		(cTbl)->( dbSkip() )

		if (cTbl)->( cCliente != E1_CLIENTE+E1_LOJA .or. Eof() )
			cAssunto := "Boletos vencidos"
			cCorpo	 := getHtmlVencido(aInfo)
			cPara	 := SA1->&cEmail

			aInfo := U_xEMAIL2(cAssunto, cCorpo, cPara)
			aInfo := {}
		endif
	end

	(cTbl)->( dbClosearea() )

	FwFreeArray(aInfo)
return

static function getHtmlaVencer(aTit)
	local nInd		as numeric
	local cHtml		:= ""
	local cAux		as character
	local cPict		:= "@E 99,999,999.99"
	local cEnter	:= "<br>"
	local cFile		:= "/system/texto_email_cobranca_avencer.txt"
	local cLogoSup	:= "data:image/png;base64,"+Encode64(,"/system/logo-superior.png")
	local cLogoInf	:= "data:image/png;base64,"+Encode64(,"/system/logo-inferior.png")
	local oFile		as object
	local cTitulos	:= ""

	for nInd := 1 to Len(aTit)
		if nInd == 1
			cTitulos += "Titulo    Parcela Vencto     Valor"+cEnter
		endif
		cTitulos += aTit[nInd][1]+" "+aTit[nInd][2]+" "+DtoC(aTit[nInd][3])+" "+Transform(aTit[nInd][4],cPict)+cEnter
	next nInd

	if ! File(cFile)
		cHtml += '<!DOCTYPE html>'
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		cHtml += '<html>'
		cHtml += "Prezados,"+cEnter
		cHtml += cEnter
		cHtml += "Gostaríamos de lembrar que o título abaixo está próximo do vencimento."+cEnter
		cHtml += cEnter
		cHtml += aTit[1][5]+cEnter
		cHtml += cEnter
		cHtml += cTitulos
		cHtml += cEnter
		cHtml += "Solicitação de 2ª via de boleto, entre em contato através do endereço: boletos@agrofauna.com.br"+cEnter
		cHtml += cEnter
		cHtml += "Em caso de dúvidas, entre em contato conosco pelo telefone: (17) 9912-1187"+cEnter
		cHtml += cEnter
		cHtml += "Por favor, não responder esse e-mail automático."+cEnter
		cHtml += "</body>"
		cHtml += "</html>"
	else
		cHtml += '<!DOCTYPE html>'
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		cHtml += '<html>'

		cAux := ""
		oFile := FwFileReader():New(cFile)
		if oFile:open()
			while oFile:hasLine()
				cAux := oFile:getLine()
				do case
					case "##TITULOS##" $ cAux
						cAux := Strtran(cAux,"##TITULOS##",cTitulos)
					case "##NOMECLI##" $ cAux
						cAux := Strtran(cAux,"##NOMECLI##",aTit[1][5])
					case "##LOGOSUPERIOR##" $ cAux
						if File("/system/logo-superior.png")
							cAux := Strtran(cAux,"##LOGOSUPERIOR##",'<img src="'+cLogoSup+'" alt="logo_superior">')
						else
							cAux := Strtran(cAux,"##LOGOSUPERIOR##","")
						endif
					case "##LOGOINFERIOR##" $ cAux
						if File("/system/logo-inferior.png")
							cAux := Strtran(cAux,"##LOGOINFERIOR##",'<img src="'+cLogoInf+'" alt="logo_inferior">')
						else
							cAux := Strtran(cAux,"##LOGOINFERIOR##","")
						endif
				endcase
				cHtml += cAux + cEnter
			end
			oFile:close()
		endif

		cHtml += "</body>"
		cHtml += "</html>"
	endif
return cHtml

static function getHtmlVencido(aTit)
	local nInd		as numeric
	local cHtml		:= ""
	local cPict		:= "@E 99,999,999.99"
	local cEnter	:= "<br>"
	local cFile		:= "/system/texto_email_cobranca_vencido.txt"
	local cLogoSup	:= "data:image/png;base64,"+Encode64(,"/system/logo-superior.png")
	local cLogoInf	:= "data:image/png;base64,"+Encode64(,"/system/logo-inferior.png")
	local oFile		as object
	local cTitulos	:= ""

	for nInd := 1 to Len(aTit)
		if nInd == 1
			cTitulos += "Titulo    Parcela Vencto     Valor"+cEnter
		endif
		cTitulos += aTit[nInd][1]+" "+aTit[nInd][2]+" "+DtoC(aTit[nInd][3])+" "+Transform(aTit[nInd][4],cPict)+cEnter
	next nInd

	if ! File(cFile)
		cHtml += '<!DOCTYPE html>'
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		cHtml += '<html>'
		cHtml += "Prezados,"+cEnter
		cHtml += cEnter
		cHtml += "Por gentileza, solicitamos uma posição referente título em aberto."+cEnter
		cHtml += cEnter
		cHtml += aTit[1][5]+cEnter
		cHtml += cEnter
		cHtml += cTitulos
		cHtml += cEnter
		cHtml += "Caso já tenha efetuado o pagamento, por gentileza, enviar o comprovante para verificarmos com o Banco o que ocorreu."+cEnter
		cHtml += cEnter
		cHtml += "Em caso de dúvidas, entre em contato conosco pelo telefone: (17) 9912-1187"+cEnter
		cHtml += cEnter
		cHtml += "Por favor, não responder esse e-mail automático."+cEnter
		cHtml += "</body>"
		cHtml += "</html>"
	else
		cHtml += '<!DOCTYPE html>'
		cHtml += '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">'
		cHtml += '<html>'

		cAux := ""
		oFile := FwFileReader():New(cFile)
		if oFile:open()
			while oFile:hasLine()
				cAux := oFile:getLine()
				do case
					case "##TITULOS##" $ cAux
						cAux := Strtran(cAux,"##TITULOS##",cTitulos)
					case "##NOMECLI##" $ cAux
						cAux := Strtran(cAux,"##NOMECLI##",aTit[1][5])
					case "##LOGOSUPERIOR##" $ cAux
						if File("/system/logo-superior.png")
							cAux := Strtran(cAux,"##LOGOSUPERIOR##",'<img src="'+cLogoSup+'" alt="logo_superior">')
						else
							cAux := Strtran(cAux,"##LOGOSUPERIOR##","")
						endif
					case "##LOGOINFERIOR##" $ cAux
						if File("/system/logo-inferior.png")
							cAux := Strtran(cAux,"##LOGOINFERIOR##",'<img src="'+cLogoInf+'" alt="logo_inferior">')
						else
							cAux := Strtran(cAux,"##LOGOINFERIOR##","")
						endif
				endcase
				cHtml += cAux + cEnter
			end
			oFile:close()
		endif

		cHtml += "</body>"
		cHtml += "</html>"
	endif
return cHtml
