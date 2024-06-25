
/*/{Protheus.doc} AGRBOL03
Gera HTML e faz envio de Email
@author Rodrigo Guerra
@since 07/03/2024
/*/
User Function AGRBOL03()
	Local cHTMLTits := ""
	Local cHtml1    := ""
	Local cHtml2    := ""
	Local cEmail    := "totvs.alexandre.dias@gmail.com;totvs.rodrigo.guerra@gmail.com" //(cAliasSE1)->A1_EMAIL AJUSTAR
	Local cNomFant  := ""
	Local cCliAtu   := (cAliasSE1)->E1_CLIENTE
	Local cAtach    := cFileOrig


	cHtml1 := '<html><body><form><table>'
	cHtml1 += '<tr><td align="center" ><div class="gdlr-logo"><a href="http://itabom.com.br" ><img src="http://itabom.com.br/wp-content/uploads/2018/05/Logo-Itabom-1-e1527197284153.png" alt="" width="401" height="192" /></a><div></td></tr>'
	cHtml2 := '<tr><td><b>Prezado(a) '+AllTrim((cAliasSE1)->A1_NOME)+' </b></td></tr>'
	cHtml2 += '<tr><td><b>Consta em nossos registros o(s) seguinte(s) valor(es) em aberto e como forma de colaboração para facilitar o pagamento, segue abaixo de cada título sua respectiva linha digitável:  </b></td></tr>'
	cHtml2 += '<tr><td></td></tr>'


	// if Empty(ALLTRIM(QRYSE1->A1_X_MAILC))
	// 	cEmail := 'csc_cobranca@itabom.com.br;cobranca@itabom.com.br'
	// Else
	// 	cEmail := ALLTRIM(QRYSE1->A1_X_MAILC)+';'+'csc_cobranca@itabom.com.br;cobranca@itabom.com.br'
	// Endif


	cNomFant := (cAliasSE1)->A1_NREDUZ

	cHTMLTits += '<tr><td></td></tr>'

	_nVlrAbat :=  SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA)


	cHTMLTits += '<tr><td><b>Titulo: </b>'+AllTrim((cAliasSE1)->E1_NUM)+' Parcela: ' + (cAliasSE1)->E1_PARCELA +'</td></tr>'
	cHTMLTits += '<tr><td><b> Emissão: </b>'+ Substr((cAliasSE1)->E1_EMISSAO,7,2)+'/'+ Substr((cAliasSE1)->E1_EMISSAO,5,2)+'/'+ Substr((cAliasSE1)->E1_EMISSAO,1,4)+'</td></tr>'
	cHTMLTits += '<tr><td><b>Vencimento: </b>'+ Substr((cAliasSE1)->E1_VENCTO,7,2)+'/'+ Substr((cAliasSE1)->E1_VENCTO,5,2)+'/'+ Substr((cAliasSE1)->E1_VENCTO,1,4)+'</td></tr>'
	cHTMLTits += '<tr><td><b>Valor:  R$ </b>'+  AllTrim(Transform((cAliasSE1)->E1_SALDO-_nVlrAbat, "@E 999,999,999.99")) +'</td></tr>'
	//Banco / Fundo Negociado: (Nome e CNPJ).
	cHTMLTits += '<tr><td><b>Linha Digitavel:  </b>'+  Nlinha + '</td></tr>'

	cHtml4 := '<tr><td></td></tr>'

	// cHtml4 += '<tr><td>Como não recebemos nenhuma comunicação sobre os motivos do atraso, solicitamos que entre em contato o quanto antes para regularização desta pendência. </td></tr>'
	// cHtml4 += '<tr><td>Caso o pagamento já tenha sido efetuado, por favor desconsidere este aviso.</td></tr>'
	// cHtml4 += '<tr><td>Informamos que, por política da empresa, não está autorizado o recebimento de qualquer valor por parte de nossos representantes. Somente reconhecemos os pagamentos quando efetuados por meio de depósitos bancários em nome da empresa e boletos bancários disponibilizados pela Polifrigor.</td></tr>'

	cHtml4 += '<tr><td>Atenciosamente,</td></tr>'
	cHtml4 += '<tr><td>AgroFoods </td></tr>'
	cHtml4 += '<tr><td><b>Departamento de Cobrança</b></td></tr>'
	cHtml4 += '<tr><td>cobranca@itabom.com.br</td></tr>'
	cHtml4 += '<tr><td>011-3149-6948</td></tr>'
	cHtml4 += '</table></form></body></html>'

	cHtml  :=  cHtml1 + cHtml2 + cHTMLTits +cHtml4


	lRet := U_EnviarEmail(cEmail,"Fatura em aberto para cliente " + cCliAtu +'-'+ cNomFant ,cHtml, cAtach)

Return
