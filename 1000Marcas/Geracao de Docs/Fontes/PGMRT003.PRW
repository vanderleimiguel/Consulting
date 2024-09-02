#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "topconn.ch"
#INCLUDE "TOTVS.CH"

#IFNDEF 	CRLF
	#DEFINE 	CRLF ( chr(13)+chr(10) )
#ENDIF

User function RUNMODEL()

	aTables := {"SA1","SE1","AI0","SC6"}
	RpcSetType( 3 )
	//seta o ambiente com a empresa 99 filial 01 com os direitos do usuário administrador, módulo CTB
	RpcSetEnv( "99","01", "Administrador", "100902", "FIN", "U_FGERMOD1", aTables, , , ,  )

	CONOUT('Iniciando ambiente...')

	U_PGMRT003()

	RpcClearEnv( )

	CONOUT('Finalizando ambiente...')
Return


/*/{Protheus.doc} PGMRT003
Função de Notificação Eletrônica de Título
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/
User Function PGMRT003()

	Private _cPastaRaiz := SuperGetMV("MV_DIRMOD1",,"/.Anexos/")

	If IsBlind()
		lJob := .T.
	Else
		lJob := .F.
	Endif

	u_fModelo1()
	u_fModelo2()
	u_fModelo3()
	u_fModelo4()

Return(.T.)

/*/{Protheus.doc} fModelo1
Gera modelo 1
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/

//--------------------------------------------- MODELO 1 - 10 dias antes do vencimento do titulo
User Function fModelo1()
	// Envia Xml, PDF e Boleto
	Local nCount	:= 0
	Local cHtml
	Local cEmailDe 	:= AllTrim(GETMV("MV_RELFROM"))
	Local Nx := 0

	Private cQuery := ""
	Private cTipoMod  := "1"
	cQuery := fGeraQry(cTipoMod)

	cQuery += " SE1.E1_TIPO	   = 'NF' AND"  +CRLF
	cQuery += " SE1.E1_FILIAL  = '" +xFilial("SE1")+"' AND"  +CRLF
	cQuery += " SE1.D_E_L_E_T_ = ' '   AND"  +CRLF
	cQuery += " SE1.E1_SALDO > 0	   AND"  +CRLF
	cQuery += " SE1.E1_PEDIDO<>' '	   AND"  +CRLF
	cQuery += " AI0.AI0_RECBOL = '1'   AND"  +CRLF
	cQuery += " AI0.AI0_XRECCB = '1'   AND"  +CRLF
	cQuery += " SE1.E1_VENCREA BETWEEN GETDATE() AND DATEADD(day, 20, GETDATE()) "  +CRLF
	cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_CLIENTE,SE1.E1_LOJA"  +CRLF
	TCQUERY cQuery NEW ALIAS "cAlias"
	TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
	TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
	Count to nCount
	cAlias->(dbgotop())
	While cAlias->(!Eof())
		_cPasta 	:= _cPastaRaiz+Alltrim(cAlias->A1_CGC)+"\"+Alltrim(cAlias->E1_FILIAL)

		IF ! Empty(cAlias->AI0_EMABOL)
			cEmailCli	:= Alltrim(cAlias->AI0_EMABOL)
		Else
			cEmailCli	:= Alltrim(cAlias->A1_EMAIL)
		EndIf

		cHtml   := '<body>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += '  <tr align="center">'
		cHtml   += "   <p><img src='https://1000marcassafetybrasil.com.br/wp-content/uploads/2020/01/logo-rede-social.png' width='150' height='150' align='middle' /></p> "
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">MODELO 1</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Prezado Cliente <strong>'+Alltrim(cAlias->A1_NOME)+'</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Vimos por meio desta lembrar que o vencimento da sua Nota Fiscal está próximo.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Estamos enviando a Nota Fiscal eletrônica, XML e o Boleto Bancário referente os produtos</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">adquiridos da 1000Marcas Safety Brasil Ltda.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Alternativamento o Boleto Bancário poderá estar disponivel em seu DDA, caso possua convênio</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">com seu Banco.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de dúvidas ou problemas para realizar o seu pagamento, entre em contato conosco</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">através do e-mail financeiro2@1000marcasbrasil.com.br ou</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">financeiro4@1000marcasbrasil.com.br</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '</table>'
		cHtml   += '	<table width="100%" border="1">'
		cHtml   += '<tr align="center" bgcolor="#483D8B">'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Nº Título</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Parcela</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Emissão</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Vencimento</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Valor</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Ordem Compra</strong></font></td>'
		cHtml   += '  </tr>'
		cCliente    := cAlias->E1_CLIENTE+cAlias->E1_LOJA
		aAnexos		:= {}
		While cAlias->E1_CLIENTE+cAlias->E1_LOJA == cCliente
			TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
			TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
			_cCnpj 	 := Alltrim(cAlias->A1_CGC)
			aFileFun := {}

			_cData1 := StrTran(DTOC(cAlias->E1_EMISSAO),"/")
			_cPasta := _cPasta+"\"+_cData1+"\"+"NF"+cAlias->E1_NUM+cAlias->E1_PREFIXO+"\"

			cHtml   += '  <tr>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_NUM)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_PARCELA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_EMISSAO)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_VENCREA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Alltrim(Transform(cAlias->E1_SALDO,PesqPict('SE1', 'E1_SALDO')))+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->C6_PEDCLI)+'</font></td>'
			cHtml   += '  </tr>'
			// Deleta arquivo ZIP na pasta do cliente, para que possa gerar outro
			_cArqCompl 	:= _cPasta+_cCnpj+".Zip"
			If File(_cArqCompl)
				If FErase(_cArqCompl) == 0
					If lJob
						CONOUT("Arquivo foi excluído com sucesso. Arquivo "+_cArqCompl)
					Else
						FWAlertSuccess(_cArqCompl,"Arquivo excluído com sucesso", )
					EndIf
				Else
					If lJob
						CONOUT("Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					Else
						FWAlertError("Erro na exclusão arquivo.","Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					EndIf
				EndIf
			EndIf
			// Fim do processo de exclusão do arquivo

			aFileFun := Directory( _cPasta + "*", "A")
			For nX = 1 to len(aFileFun)
				aadd(aAnexos, _cPasta + aFileFun[nX][1])
			Next nX
			cAlias->(DbSkip())
		EndDo

		nRet := FZip(_cPasta+_cCnpj+".Zip", aAnexos, _cPasta, Subs(_cCnpj,1,5))

		If nRet != 0
			If lJob
				CONOUT("Não foi possível criar o arquivo zip")
			Else
				MsgInfo("Não foi possível criar o arquivo zip","Erro Compactação")
			EndIf
		Else
			If lJob
				CONOUT("Arquivo zip criado com sucesso")
			Endif
		Endif

		cHtml   += '</table>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">CNPJ 23.622.391/0001-81</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		If GetMv("MV_ZWFCOB2")
			cEmailCli := Alltrim(GetMv("MV_ZWFCOB3"))
		Endif
		cArquivo  := _cPasta+_cCnpj+".Zip"
		cAssunto 	:= "NOTIFICAÇÃO ELETRÔNICA DE TÍTULO"
		Processa({|| U_PGMRT002(cEmailDe,cEmailCli,cAssunto,cHtml,cArquivo,cTipoMod)},"Aguarde.....","Enviando E-Mail - Modelo 1.........",.F.)
	EndDo
	cAlias->(dbCloseArea())
	CONOUT("[fGeraMod] - Fim do processamento modelo " + cTipoMod )
Return .T.

//---------------------------------------------------------------------Modelo 2
/*/{Protheus.doc} fModelo2
Gera modelo 2
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/

User Function fModelo2()
	// Envia Xml, PDF
	Local nCount	:= 0
	Local cHtml
	Local nx   := 0
	Local cEmailDe 	:= AllTrim(GETMV("MV_RELFROM"))

	Private cTipoMod  := "2"
	Private cQuery := ""

	cQuery := fGeraQry(cTipoMod)

	cQuery += " SE1.E1_TIPO	   = 'NF' AND" +CRLF
	cQuery += " SE1.E1_FILIAL  = '" +xFilial("SE1")+"' AND" +CRLF
	cQuery += " SE1.D_E_L_E_T_ = ' '   AND" +CRLF
	cQuery += " SE1.E1_SALDO > 0	   AND" +CRLF
	cQuery += " SE1.E1_PEDIDO<>' '	   AND" +CRLF
	cQuery += " AI0.AI0_RECBOL = '2'   AND" +CRLF
	cQuery += " AI0.AI0_XRECCB = '1'   AND" +CRLF
	cQuery += " SE1.E1_VENCREA BETWEEN GETDATE() AND DATEADD(day, 10, GETDATE()) " +CRLF
	cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_CLIENTE,SE1.E1_LOJA" +CRLF
	TCQUERY cQuery NEW ALIAS "cAlias"
	TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
	TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
	Count to nCount
	cAlias->(dbgotop())
	While cAlias->(!Eof())
		_cPasta 	:= _cPastaRaiz+Alltrim(cAlias->A1_CGC)+"\"+Alltrim(cAlias->E1_FILIAL)

		IF ! Empty(cAlias->AI0_EMABOL)
			cEmailCli	:= Alltrim(cAlias->AI0_EMABOL)
		Else
			cEmailCli	:= Alltrim(cAlias->A1_EMAIL)
		EndIf
		cHtml   := '<body>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += '  <tr align="center">'
		cHtml   += "   <p><img src='https://1000marcassafetybrasil.com.br/wp-content/uploads/2020/01/logo-rede-social.png' width='150' height='150' align='middle' /></p> "
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">MODELO 2</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Prezado Cliente <strong>'+Alltrim(cAlias->A1_NOME)+'</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Vimos por meio desta lembrar que o vencimento da sua Nota Fiscal está próximo.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Estamos enviando a cópia da Nota Fiscal eletrônica e XML referente os produtos adquiridos da </font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '</table>'
		cHtml   += '	<table width="100%" border="1">'
		cHtml   += '	<tr align="center" bgcolor="#483D8B">'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Nº Título</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Parcela</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Emissão</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Vencimento</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Valor</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Ordem Compra</strong></font></td>'
		cHtml   += '  </tr>'
		cCliente    := cAlias->E1_CLIENTE+cAlias->E1_LOJA
		aAnexos		:= {}
		While cAlias->E1_CLIENTE+cAlias->E1_LOJA == cCliente
			TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
			TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
			_cCnpj 	 := Alltrim(cAlias->A1_CGC)
			aFileFun := {}

			_cData1 := StrTran(DTOC(cAlias->E1_EMISSAO),"/")
			_cPasta := _cPasta+"\"+_cData1+"\"+"NF"+cAlias->E1_NUM+cAlias->E1_PREFIXO+"\"

			cHtml   += '  <tr>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_NUM)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_PARCELA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_EMISSAO)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_VENCREA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Alltrim(Transform(cAlias->E1_SALDO,PesqPict('SE1', 'E1_SALDO')))+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->C6_PEDCLI)+'</font></td>'
			cHtml   += '  </tr>'
			// Deleta arquivo ZIP na pasta do cliente, para que possa gerar outro
			_cArqCompl 	:= _cPasta+_cCnpj+".Zip"
			If File(_cArqCompl)
				If FErase(_cArqCompl) == 0
					If lJob
						CONOUT("Arquivo foi excluído com sucesso. Arquivo "+_cArqCompl)
					Else
						FWAlertSuccess(_cArqCompl,"Arquivo excluído com sucesso", )
					EndIf
				Else
					If lJob
						CONOUT("Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					Else
						FWAlertError("Erro na exclusão arquivo.","Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					EndIf
				EndIf
			EndIf
			// Fim do processo de exclusão do arquivo

			aFileFun := Directory( _cPasta + "*", "A")
			For nX = 1 to len(aFileFun)
				aadd(aAnexos, _cPasta + aFileFun[nX][1])
			Next nX

			cAlias->(dbskip())

		EndDo

		nRet := FZip(_cPasta+_cCnpj+".Zip", aAnexos, _cPasta, Subs(_cCnpj,1,5))
		If nRet != 0
			If lJob
				CONOUT("Não foi possível criar o arquivo zip")
			Else
				MsgInfo("Não foi possível criar o arquivo zip","Erro Compactação")
			EndIf
		Else
			If lJob
				CONOUT("Arquivo zip criado com sucesso")
			Endif
		Endif

		cHtml   += '</table>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Devido acordo comercial, a sua cobrança está em Carteira e sua liquidação deverá der feita</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">através de depósito bancário ou PIX, conforme dados abaixo:</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco Itaú - Ag. 0002 - C/C 29322-3</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco Bradesco - Ag. 3393-6 - C/C 3510-6</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco do Brasil - Ag. 2935-1 - C/C 28000-3</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>PIX - 23.622.391Q0001-81</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de dúvidas ou problemas para realizar o seu pagamento, entre em contato conosco</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">através do e-mail financeiro2@1000marcasbrasil.com.br ou financeiro4@1000marcasbrasil.com.br</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">CNPJ 23.622.391/0001-81</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		If GetMv("MV_ZWFCOB2")
			cEmailCli := Alltrim(GetMv("MV_ZWFCOB3"))
		Endif
		cArquivo  := _cPasta+_cCnpj+".Zip"
		cAssunto  := "NOTIFICAÇÃO ELETRÔNICA DE TÍTULO"
		Processa({|| U_PGMRT002(cEmailDe,cEmailCli,cAssunto,cHtml,cArquivo,cTipoMod)},"Aguarde.....","Enviando E-Mail - Modelo 2.........",.F.)
	EndDo
	cAlias->(dbCloseArea())
	CONOUT("[fGeraMod] - Fim do processamento modelo " + cTipoMod )
Return .T.

//---------------------------------------------------------------------Modelo 3
/*/{Protheus.doc} fModelo3
Gera modelo 3
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/

User Function fModelo3()
// Envia Xml, PDF e Boleto
	Local nCount	:= 0
	Local cHtml
	Local nx := 0
	Local cEmailDe 	:= AllTrim(GETMV("MV_RELFROM"))

	Private cTipoMod  := "3"
	Private cQuery := ""

	cQuery := fGeraQry(cTipoMod)

	cQuery += " SE1.E1_TIPO	   = 'NF' AND" +CRLF
	cQuery += " SE1.E1_FILIAL  = '" +xFilial("SE1")+"' AND" +CRLF
	cQuery += " SE1.D_E_L_E_T_ = ' '   AND" +CRLF
	cQuery += " SE1.E1_SALDO > 0	   AND" +CRLF
	cQuery += " SE1.E1_PEDIDO<>' '	   AND" +CRLF
	cQuery += " AI0.AI0_RECBOL = '1'   AND" +CRLF
	cQuery += " AI0.AI0_XRECCB = '1'   AND" +CRLF
	cQuery += " SE1.E1_VENCREA BETWEEN SE1.E1_VENCREA AND DATEADD(day, 2, GETDATE()) " +CRLF
	cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_CLIENTE,SE1.E1_LOJA" +CRLF
	TCQUERY cQuery NEW ALIAS "cAlias"
	TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
	TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
	Count to nCount
	cAlias->(dbgotop())
	While cAlias->(!Eof())
		_cPasta 	:= _cPastaRaiz+Alltrim(cAlias->A1_CGC)+"\"+Alltrim(cAlias->E1_FILIAL)
		IF ! Empty(cAlias->AI0_EMABOL)
			cEmailCli	:= Alltrim(cAlias->AI0_EMABOL)
		Else
			cEmailCli	:= Alltrim(cAlias->A1_EMAIL)
		EndIf

		cHtml   := '<body>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += '  <tr align="center">'
		cHtml   += "   <p><img src='https://1000marcassafetybrasil.com.br/wp-content/uploads/2020/01/logo-rede-social.png' width='150' height='150' align='middle' /></p> "
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">MODELO 3</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Prezado Cliente <strong>'+Alltrim(cAlias->A1_NOME)+'</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Aé o momento não identificamos o pagamento do(s) Título(s) abaixo:</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '</table>'
		cHtml   += '	<table width="100%" border="1">'
		cHtml   += '<tr align="center" bgcolor="#483D8B">'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Nº Título</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Parcela</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Emissão</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Vencimento</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Valor</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Ordem Compra</strong></font></td>'
		cHtml   += '  </tr>'
		nTotal		:= 0
		nFrete    	:= 0
		nDespesa	:= 0
		cCliente    := cAlias->E1_CLIENTE+cAlias->E1_LOJA
		aAnexos		:= {}
		While cAlias->E1_CLIENTE+cAlias->E1_LOJA == cCliente
			TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
			TCSETFIELD("cAlias","E1_VENCREA","D",08,00)

			_cCnpj 	 := Alltrim(cAlias->A1_CGC)
			aFileFun := {}

			_cData1 := StrTran(DTOC(cAlias->E1_EMISSAO),"/")
			_cPasta := _cPasta+"\"+_cData1+"\"+"NF"+cAlias->E1_NUM+cAlias->E1_PREFIXO+"\"

			cHtml   += '  <tr>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_NUM)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_PARCELA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_EMISSAO)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_VENCREA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Alltrim(Transform(cAlias->E1_SALDO,PesqPict('SE1', 'E1_SALDO')))+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->C6_PEDCLI)+'</font></td>'
			cHtml   += '  </tr>'
			// Deleta arquivo ZIP na pasta do cliente, para que possa gerar outro
			_cArqCompl 	:= _cPasta+_cCnpj+".Zip"
			If File(_cArqCompl)
				If FErase(_cArqCompl) == 0
					If lJob
						CONOUT("Arquivo foi excluído com sucesso. Arquivo "+_cArqCompl)
					Else
						FWAlertSuccess(_cArqCompl,"Arquivo excluído com sucesso", )
					EndIf
				Else
					If lJob
						CONOUT("Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					Else
						FWAlertError("Erro na exclusão arquivo.","Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					EndIf
				EndIf
			EndIf
			// Fim do processo de exclusão do arquivo

			aFileFun := Directory( _cPasta + "*", "A")
			For nX = 1 to len(aFileFun)
				aadd(aAnexos, _cPasta + aFileFun[nX][1])
			Next nX

			cAlias->(dbskip())
		EndDo
		nRet := FZip(_cPasta+_cCnpj+".Zip", aAnexos, _cPasta, Subs(_cCnpj,1,5))

		If nRet != 0
			If lJob
				CONOUT("Não foi possível criar o arquivo zip")
			Else
				MsgInfo("Não foi possível criar o arquivo zip","Erro Compactação")
			EndIf
		Else
			If lJob
				CONOUT("Arquivo zip criado com sucesso")
			Endif
		Endif

		cHtml   += '</table>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Estamos reenviando a cópia da Nota Fiscal eletrônica, XML e o Boleto Bancário correspondente.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Alternativamento o Boleto Bancário poderá estar disponivel em seu DDA, caso possua convênio</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Pedimos a gentileza de retornar este e-mail com a confirmação dos dados do pagamento</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">realizado, ou com a previsão para a quitação do(s) débito(s).</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de dúvidas ou problemas para realizar o seu pagamento, entre em contato conosco</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">através do e-mail financeiro2@1000marcasbrasil.com.br ou financeiro4@1000marcasbrasil.com.br</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Caso o título já tenha sido liquidado, favor desconsiderar este aviso.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">*Lembramos que a falta do pagamento poderá ensejar o envio da cobrança automaticmente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">para cartório, após o décimo dia.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">CNPJ 23.622.391/0001-81</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		If GetMv("MV_ZWFCOB2")
			cEmailCli := Alltrim(GetMv("MV_ZWFCOB3"))
		Endif
		cArquivo  := _cPasta+_cCnpj+".Zip"
		cAssunto 	:= "COBRANÇA ELETRÔNICA - TÍTULO VENCIDO"
		Processa({|| U_PGMRT002(cEmailDe,cEmailCli,cAssunto,cHtml,cAnexo,cTipoMod)},"Aguarde.....","Enviando E-Mail - Modelo 3.........",.F.)
	EndDo
	cAlias->(dbCloseArea())
	CONOUT("[fGeraMod] - Fim do processamento modelo " + cTipoMod )
Return .T.


//---------------------------------------------------------------------Modelo 4
/*/{Protheus.doc} fModelo4
Gera modelo 4
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/

User Function fModelo4()
	// Envia Xml, PDF
	Local nCount	:= 0
	Local cHtml
	Local nx := 0
	Local cEmailDe 	:= AllTrim(GETMV("MV_RELFROM"))

	Private cTipoMod  := "4"
	Private cQuery := ""

	cQuery := fGeraQry(cTipoMod)

	cQuery += " SE1.E1_TIPO	  	 = 'NF' 					AND" +CRLF
	cQuery += " SE1.E1_FILIAL  	 = '" +xFilial("SE1")+"' 	AND" +CRLF
	cQuery += " SE1.E1_SALDO 	 >  0	   					AND" +CRLF
	cQuery += " SE1.E1_PEDIDO    <> ' '	 					AND" +CRLF
	cQuery += " AI0.AI0_RECBOL 	 = '2'						AND" +CRLF
	cQuery += " AI0.AI0_XRECCB 	 = '1'   					AND" +CRLF
	cQuery += " SE1.D_E_L_E_T_   = ' '   					" +CRLF
	cQuery += " ORDER BY SE1.E1_FILIAL,SE1.E1_CLIENTE,SE1.E1_LOJA" +CRLF
	TCQUERY cQuery NEW ALIAS "cAlias"
	TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
	TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
	Count to nCount
	cAlias->(dbgotop())
	While cAlias->(!Eof())
		_cPasta 	:= _cPastaRaiz+Alltrim(cAlias->A1_CGC)+"\"+Alltrim(cAlias->E1_FILIAL)
		IF ! Empty(cAlias->AI0_EMABOL)
			cEmailCli	:= Alltrim(cAlias->AI0_EMABOL)
		Else
			cEmailCli	:= Alltrim(cAlias->A1_EMAIL)
		EndIf
		cHtml   := '<body>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += '  <tr align="center">'
		cHtml   += "   <p><img src='https://1000marcassafetybrasil.com.br/wp-content/uploads/2020/01/logo-rede-social.png' width='150' height='150' align='middle' /></p> "
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">MODELO 4</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Prezado Cliente <strong>'+Alltrim(cAlias->A1_NOME)+'</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Até o momento não identificamos o pagamento do(s) Títulos abaixo:</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '</table>'
		cHtml   += '	<table width="100%" border="1">'
		cHtml   += '	<tr align="center" bgcolor="#483D8B">'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Nº Título</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Parcela</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Emissão</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Vencimento</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Valor</strong></font></td>'
		cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif" color="WHITE"><strong>Ordem Compra</strong></font></td>'
		cHtml   += '  </tr>'
		cCliente    := cAlias->E1_CLIENTE+cAlias->E1_LOJA
		aAnexos		:= {}
		While cAlias->E1_CLIENTE+cAlias->E1_LOJA == cCliente
			TCSETFIELD("cAlias","E1_EMISSAO","D",08,00)
			TCSETFIELD("cAlias","E1_VENCREA","D",08,00)
			_cCnpj 	 := Alltrim(cAlias->A1_CGC)
			aFileFun := {}
			_cData1 := StrTran(DTOC(cAlias->E1_EMISSAO),"/")
			_cPasta := _cPasta+"\"+_cData1+"\"+"NF"+cAlias->E1_NUM+cAlias->E1_PREFIXO+"\"
			cHtml   += '  <tr>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_NUM)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->E1_PARCELA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_EMISSAO)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+DTOC(cAlias->E1_VENCREA)+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Alltrim(Transform(cAlias->E1_SALDO,PesqPict('SE1', 'E1_SALDO')))+'</font></td>'
			cHtml   += '    <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif">'+Ltrim(cAlias->C6_PEDCLI)+'</font></td>'
			cHtml   += '  </tr>'
			// Deleta arquivo ZIP na pasta do cliente, para que possa gerar outro
			_cArqCompl 	:= _cPasta+_cCnpj+".Zip"
			If File(_cArqCompl)
				If FErase(_cArqCompl) == 0
					If lJob
						CONOUT("Arquivo foi excluído com sucesso. Arquivo "+_cArqCompl)
					Else
						FWAlertSuccess(_cArqCompl,"Arquivo excluído com sucesso", )
					EndIf
				Else
					If lJob
						CONOUT("Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					Else
						FWAlertError("Erro na exclusão arquivo.","Houve uma falha na exclusão do arquivo, erro #" + cValToChar(FError()))
					EndIf
				EndIf
			EndIf
			// Fim do processo de exclusão do arquivo
			aFileFun := Directory( _cPasta + "*", "A")
			For nX = 1 to len(aFileFun)
				aadd(aAnexos, _cPasta + aFileFun[nX][1])
			Next nX
			cAlias->(DbSkip())
		EndDo
		nRet := FZip(_cPasta+_cCnpj+".Zip", aAnexos, _cPasta, Subs(_cCnpj,1,5))
		If nRet != 0
			If lJob
				CONOUT("Não foi possível criar o arquivo zip")
			Else
				MsgInfo("Não foi possível criar o arquivo zip","Erro Compactação")
			EndIf
		Else
			If lJob
				CONOUT("Arquivo zip criado com sucesso")
			Endif
		Endif
		cHtml   += '</table>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Estamos enviando a cópia da Nota Fiscal eletrônica e XML correspondente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Lembramos que devido acordo comercial, a sua cobrança permanece em Carteira  e sua</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Liquidação deverá ser feita através de depósito bancário ou PIX, conforme dados abaixo:</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco Itaú - Ag. 0002 - C/C 29322-3</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco Bradesco - Ag. 3393-6 - C/C 3510-6</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>Banco do Brasil - Ag. 2935-1 - C/C 28000-3</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><div align="center"><font size="3" face="Arial, Helvetica, sans-serif"><strong>PIX - 23.622.391Q0001-81</strong></font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Pedimos a gentileza de retornar este e-mail com a confirmação dos dados do pagamento</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">realizado, ou com a previsão para a quitação do(s) débito(s).</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de dúvidas ou problemas para realizar o seu pagamento, entre em contato conosco</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">através do e-mail financeiro2@1000marcasbrasil.com.br ou</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">financeiro4@1000marcasbrasil.com.br</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Caso o título já tenha sido liquidado, favor desconsiderar este aviso.</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		cHtml   += ' <br>'
		cHtml   += '<table width="100%" border="0"> '
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">1000Marcas Safety Brasil Ltda</font></td>'
		cHtml   += '  </tr>'
		cHtml   += ' <br>'
		cHtml   += '  <tr>'
		cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">CNPJ 23.622.391/0001-81</font></td>'
		cHtml   += '  </tr>'
		cHtml   += '</table>'
		If GetMv("MV_ZWFCOB2")
			cEmailCli := Alltrim(GetMv("MV_ZWFCOB3"))
		Endif
		cArquivo  := _cPasta+_cCnpj+".Zip"
		cAssunto 	:= "NOTIFICAÇÃO ELETRÔNICA DE TÍTULO"
		Processa({|| U_PGMRT002(cEmailDe,cEmailCli,cAssunto,cHtml,cArquivo,cTipoMod)},"Aguarde.....","Enviando E-Mail - Modelo 4.........",.F.)
	EndDo
	cAlias->(dbCloseArea())
	CONOUT("[fGeraMod] - Fim do processamento modelo " + cTipoMod )
Return .T.

//---------------------------------------------------------------------Modelo Geral
/*/{Protheus.doc} fGeraQry
Query Modelo geral. Será usada em todas as querys
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/
Static Function fGeraQry(cTipoMod)

	CONOUT("[fGeraMod] - Selecionando registros para o modelo " + cTipoMod )

	cQuery := "SELECT "								+CRLF
	cQuery += "		E1_FILIAL," 					+CRLF
	cQuery += "		E1_PREFIXO,"					+CRLF
	cQuery += "		E1_NUM,"						+CRLF
	cQuery += "		E1_PARCELA,"					+CRLF
	cQuery += "		E1_TIPO,"						+CRLF
	cQuery += "		E1_CLIENTE,"					+CRLF
	cQuery += "		E1_LOJA,"						+CRLF
	cQuery += "		E1_NOMCLI,"						+CRLF
	cQuery += "		E1_EMISSAO,"					+CRLF
	cQuery += "		E1_VENCREA,"					+CRLF
	cQuery += "		E1_HIST,"						+CRLF
	cQuery += "		E1_VALOR,"						+CRLF
	cQuery += "		E1_SALDO,"						+CRLF
	cQuery += "		E1_PEDIDO,"						+CRLF
	cQuery += "		A1_COD,"						+CRLF
	cQuery += "		A1_LOJA,"						+CRLF
	cQuery += "		A1_NOME,"						+CRLF
	cQuery += "		A1_CGC,"						+CRLF
	cQuery += "		A1_CONTATO,"					+CRLF
	cQuery += "		A1_EMAIL,"						+CRLF
	cQuery += "		A1_END,"						+CRLF
	cQuery += "		A1_BAIRRO,"						+CRLF
	cQuery += "		A1_MUN,"						+CRLF
	cQuery += "		A1_EST,"						+CRLF
	cQuery += "		A1_CEP,"						+CRLF
	cQuery += "		A1_INSCR,"						+CRLF
	cQuery += "		A1_DDD,"						+CRLF
	cQuery += "		A1_TEL,"						+CRLF
	cQuery += "		A1_FAX,"						+CRLF
	cQuery += "		AI0_RECBOL,"					+CRLF
	cQuery += "		AI0_EMABOL,"					+CRLF
	cQuery += "		AI0_XRECCB,"					+CRLF
	cQuery += "		C6_PEDCLI"						+CRLF
	cQuery += " FROM "+RetSqlName("SE1")+" SE1" 	+CRLF
	cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_COD = SE1.E1_CLIENTE AND SA1.A1_LOJA  = SE1.E1_LOJA AND SA1.D_E_L_E_T_ = ' '"											  +CRLF
	cQuery += " INNER JOIN "+RetSqlName("AI0")+" AI0 ON AI0.AI0_FILIAL='"+xFilial("AI0")+ "' AND AI0.AI0_CODCLI = SA1.A1_COD     AND AI0.AI0_LOJA = SA1.A1_LOJA AND AI0.D_E_L_E_T_ = ' '" +CRLF
	cQuery += " LEFT  JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_FILIAL ='"+xFilial("SC6")+ "' AND SC6.C6_NUM     = SE1.E1_PEDIDO  AND SC6.D_E_L_E_T_ = ' '"								  +CRLF
	cQuery += " WHERE" +CRLF

Return(cQuery)
