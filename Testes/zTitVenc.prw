//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"
/*
// Projeto: VIDARA
// Modulo : SIGAFIN
// Fonte  : ZTITVENC
// ------------+-------------------+-----------------------------------------------------------
// Data        | Autor             | Descricao
// ------------+-------------------+-----------------------------------------------------------
// 29/05/2024  | Abel Ribeiro      | DISPARA E_MAIL AVISO DE TITULOS VENCIDOS 
//             |                   | GAP ID: 034  
// ------------+-------------------+-----------------------------------------------------------
*/

User Function zTitVenc(aParams)
	Local aArea
	Local lContinua  := .F.
	Local nFil
	Local nEmp
	Local cFilBck       := cFilAnt
	Local cEmpBck       := cEmpAnt
	Private lJobPvt 			:= IsBlind() .Or. Empty(AllTrim(FunName()))
	Private _cEmp     	:= "01"
	Private _cFil     	:= "0101"
	Private aEmpAux   	:= FWAllGrpCompany()
	Private aFilAux   	:= {}
	Private cMsgLog   	:= ""

	Default aParams     := {"01","0101"}
	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			aParams	:= {aEmpAux[nEmp], aFilAux[nFil] }
			_cEmp   := aParams[01]
			_cFil   := aParams[02]
			//Se o ambiente n�o estiver em p�, sobe para usar de maneira autom�tica
			If Select("SX2") == 0
				lJobPvt   := .T.
				lContinua := .T.

				cMsgLog := "-------------------------------------------------------------------------------"  + CRLF
				cMsgLog +=  " ZTITVENC -  JOB ENVIO DE AVISO TITULOS VENCIDOS                             "  + CRLF
				cMsgLog +=  " Empresa: " + _cEmp                                                              + CRLF
				cMsgLog +=  " Filial : " + _cFil 															 + CRLF
				cMsgLog +=  " Inicio : " + FWTIMESTAMP() + " - " + subs(time(),1,5)							 + CRLF
				cMsgLog +=  "-------------------------------------------------------------------------------" + CRLF
				U_ZGERALOG(cMsgLog)

				RpcClearEnv()
				RPCSetType( 3 )     // N�o consome licensa de uso

				_cEmp	:= aParams[01]
				_cFil	:= aParams[02]

				RPCSetEnv(_cEmp, _cFil, "", "", "", "")
			EndIf

			aArea := GetArea()

			//Se n�o for modo autom�tico, mostra uma pergunta
			If ! lJobPvt
				FWALERTINFO("Deseja gerar o e-Mail dos t�tulos vencidos?", "Aten��o")
			EndIf

			//Se for continuar, faz a chamada para o disparo do e-Mail
			If lContinua .and. !lJobPvt
				Processa({|| fProcDad() }, "Processando...")
			else
				fProcDad()
			EndIf

		/* reseta AMbiente */ 
			RpcClearEnv()
		Next
		nFil	:= 1
	Next

	cEmpAnt := cEmpBck
	cFilAnt := cFilBck
Return

Static Function fProcDad()
	Local cCodCLI     := ""
	Local nAtual      := 0
	Local nTotal      := 0
	Local cQuery      := ""
	Local I
	Local cStat       := 'Enviado E-mail Cobran�a em '
	Private aDados	  := {}
	Private dDataVen  := dDataBAse
	Private cCopia    := ""
	Private aAnexos   := {}
	Private _lRetMail := .F.
	Private cEmailFin := SuperGetMV('ZZ_XAVEMCC', .F. ,"adm.financeiro.br@vidara.com")                 //Email Repons�vel Financeiro
	Private _cAssunto := "[VIDARA] AVISO DE T�TULO(S) VENCIDO(S)"
	Private _cBody    := ""
	Private cEmailGe  := SuperGetMV('ZZ_EMAILGE', .F. ,"")



	//Buscando os t�tulos que venceram, conforme o n�mero de dias na vari�vel nDias
	cQuery := " SELECT " + CRLF
	cQuery += " 	E1_CLIENTE,"  + CRLF
	cQuery += "     E1_LOJA,"     + CRLF
	cQuery += " 	A1_EMAIL, "   + CRLF
	cQuery += " 	E1_NOMCLI, "  + CRLF
	cQuery += " 	E1_FILIAL, "  + CRLF
	cQuery += " 	E1_PREFIXO, " + CRLF
	cQuery += " 	E1_NUM, "     + CRLF
	cQuery += " 	E1_PARCELA, " + CRLF
	cQuery += " 	E1_TIPO, "    + CRLF
	cQuery += " 	E1_EMISSAO, " + CRLF
	cQuery += " 	E1_VENCREA, " + CRLF
	cQuery += " 	E1_SALDO, "   + CRLF
	cQuery += " 	E1_VALOR,"    + CRLF
	cQuery += " 	A1_COD, "     + CRLF
	cQuery += " 	A1_CGC, "     + CRLF
	cQuery += " 	A1_NOME,"     + CRLF
	cQuery += " (SELECT C5_NOTA FROM "
	cQuery += " "+ RetSQLName("SC5") + " SC5 WHERE "  + CRLF
	cQuery += " SC5.D_E_L_E_T_= ' ' AND  " + CRLF
	cQuery += "C5_FILIAL = E1_FILIAL  " + CRLF
	cQuery += " AND C5_NUM = E1_PEDIDO) " + CRLF
	cQuery += " 	C5_NOTA,"     + CRLF
	cQuery += " (SELECT MAX(E1_PARCELA) FROM " + CRLF
	cQuery += "  " + RetSQLName("SE1") + " SE12 WHERE " + CRLF
	cQuery += " SE12.D_E_L_E_T_= ' ' " + CRLF
	cQuery += "  AND SE12.E1_FILIAL = SE1.E1_FILIAL  " + CRLF
	cQuery += "  AND  SE12.E1_NUM = SE1.E1_NUM  " + CRLF
	cQuery += "  AND SE12.E1_PREFIXO = SE1.E1_PREFIXO  " + CRLF
	cQuery += "  AND SE12.E1_TIPO = SE1.E1_TIPO) MAXPAR " + CRLF

	cQuery += " FROM " + CRLF
	cQuery += " 	" + RetSQLName("SE1") + " SE1 "  + CRLF
	cQuery += " 	INNER JOIN " + RetSQLName("SA1") + " SA1 ON ( " + CRLF
	cQuery += " 		A1_COD = E1_CLIENTE "        + CRLF
	cQuery += " 		AND A1_LOJA = E1_LOJA "      + CRLF
	cQuery += "    AND A1_FILIAL  = '"+xFilial("SA1")+ "' " + CRLF
	cQuery += " 		AND SA1.D_E_L_E_T_ = '' "    + CRLF
	cQuery += " 	) " + CRLF

	cQuery += " WHERE " + CRLF
	cQuery += " 	E1_SALDO > 0 " + CRLF
	cQuery += " 	AND E1_VENCREA < '" + dToS(dDataBase) + "' " + CRLF
	cQuery += " 	AND SE1.D_E_L_E_T_ = '' " + CRLF
	cQuery += "    AND E1_FILIAL  = '"+xFilial("SE1")+ "' " + CRLF
	cQuery += "     AND  E1_TIPO NOT LIKE '%-'  AND E1_TIPO NOT LIKE 'RA' AND E1_TIPO <> '" + MVPROVIS +"' " + CRLF
	cQuery += " 	AND E1_SALDO > 0 " + CRLF
	cQuery += "  AND E1_NUM = '000074662' "
	cQuery += " ORDER BY " + CRLF
	cQuery += " 	E1_CLIENTE,E1_LOJA, E1_VENCREA " + CRLF

	TCQuery cQuery New Alias "QRY_SE1"

	//Define as colunas como tipo Data
	TCSetField('QRY_SE1', 'E1_EMISSAO', 'D')
	TCSetField('QRY_SE1', 'E1_VENCREA', 'D')

	//Define o tamanho da r�gua
	Count To nTotal

	IF !lJobPvt
		ProcRegua(nTotal)
	ENDIF

	QRY_SE1->(DbGoTop())

	//Percorrendo os registros
	cCODCLI := QRY_SE1->E1_CLIENTE + QRY_SE1->E1_LOJA

	While ! QRY_SE1->(EoF())

		//Incrementa a r�gua
		nAtual++

		IF !lJobPvt
			IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		EndIf

		//TESTE JOB

		If Empty(cEmailGe)
			_cEmailTo := QRY_SE1->A1_EMAIL
		Else
			_cEmailTo := cEmailGe
		Endif
		IF Empty(QRY_SE1->A1_EMAIL)
			cMsgLog := "-----------------------------------------------------------------------------------"  + CRLF
			cMsgLog +=  " ZTITVENC -  JOB ENVIO DE AVISO TITULOS VENCIDOS                              "  + CRLF
			cMsgLog +=  " **** Campo E-mail Cliente ["+QRY_SE1->E1_CLIENTE + "/" + QRY_SE1->E1_LOJA +"] est� Vazio - E-mail N�o enviado ****                    "  + CRLF
			cMsgLog +=  " Inicio : " + FWTIMESTAMP() + " - " + subs(time(),1,5)			  				  + CRLF
			cMsgLog +=  "---------------------------------------------------------------------------------" + CRLF
			U_ZGERALOG(cMsgLog)
			QRY_SE1->(dbSkip(1) )
			LOOP
		Endif
		//Adiciona dados dos t�tulos

		IF cCODCLI <>  QRY_SE1->E1_CLIENTE + QRY_SE1->E1_LOJA

			aSort(aDados, , , {|x, y| x[8] < y[8]})

			_cBody := QACOB0V(aDados,aDados[1][10],aDados[1][11])

			//Dispara o e-Mail

			U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBody,aAnexos)

			aDados := {}
		Endif

		aAdd(aDados, {QRY_SE1->E1_CLIENTE,QRY_SE1->E1_LOJA,;
			QRY_SE1->A1_EMAIL,;
			QRY_SE1->E1_PREFIXO,;
			QRY_SE1->E1_NUM,;
			QRY_SE1->E1_PARCELA,;
			QRY_SE1->E1_EMISSAO,;
			QRY_SE1->E1_VENCREA,;
			QRY_SE1->E1_SALDO,;
			Alltrim(QRY_SE1->A1_NOME),;
			QRY_SE1->A1_CGC,;
			QRY_SE1->E1_VALOR,;
			QRY_SE1->E1_TIPO,;
			QRY_SE1->C5_NOTA,;
			QRY_SE1->MAXPAR})

		cCODCLI := QRY_SE1->E1_CLIENTE + QRY_SE1->E1_LOJA
		cNomeCli:= QRY_SE1->E1_NOMCLI

		//Ordena o Array por Nome (Array multidimensional) - Decrescente
		QRY_SE1->(DbSkip())
	EndDo

	QRY_SE1->(DbCloseArea())

	/* Imprime Ultimo registro */


	IF LEN(aDADOS) > 0

		aSort(aDados, , , {|x, y| x[8] < y[8]})

		_cBody    := QACOB0V(aDados,aDados[1][10],aDados[1][11])

		lRetMAIL := U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBody,aAnexos)

		IF lRetMAIL
			//Atualiza status de email enviado
			For I := 1 TO LEN(aDados)
				// cSQL := "UPDATE "+RETSQLNAME("SE1")+" SET E1_ZZSTCOB = '"+cSTAT+"'"+STRZERO(Day(DDataBase),2)+ "/"+ STRZERO(Month(dDataBAse),2)+" + CRLF
				// cSQL += "WHERE E1_NUM  = '"+aDados[I][5] +"' AND E1_PREFIXO = '"+aDados[I][4]+"' AND E1_CLIENTE = '"+aDados[I][1]+"' AND E1_LOJA= '"+aDados[I][2]+"'" + CRLF
				// cSQL += "      E1_TIPO = '"+aDados[I][13]+"' AND E1_PARCELA = '"+aDados[I][6]+"' " + CRLF
				// cSQL += "      AND D_E_L_E_T_ <> '*' "

				// If TCSQLExec(cSQL) <> 0
				// 	ApMsgAlert( AllTrim(TCSQLError()), "N�o foi possivel Gravar Flag E-mail." )
				// Endif
				SE1->( DbSetOrder(2) )
				If SE1->(DbSeek(xFilial("SE1")+aDados[I][1]+aDados[I][2]+aDados[I][4]+aDados[I][5]+aDados[I][6]+aDados[I][13]))//E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
					Reclock("SE1", .F.)
					SE1->E1_ZZSTCOB := cSTAT+STRZERO(Day(DDataBase),2)+ "/"+ STRZERO(Month(dDataBAse),2)
					SE1->( MsUnLock() )
				EndIf
			NEXT
		EndIf
	EndIf

	cMsgLog := "-------------------------------------------------------------------------------" + CRLF
	cMsgLog += " ZTITVENC -  JOB AVISO DE TITULOS VENCIDOS - FIM                               " + CRLF
	cMsgLog += " Empresa: " + _cEmp  															+ CRLF
	cMsgLog += " Filial : " + _cFil  															+ CRLF
	cMsgLog += " T�rmino: " + FWTIMESTAMP() + " Hora: " + subs(time(),1,5)                       + CRLF
	cMsgLog += "-------------------------------------------------------------------------------" + CRLF

	U_ZGERALOG(cMsgLog)

Return

Static Function QACOB0V(_aTit,cCliente,cCNPJ)
	Local _cBody := ""
	Local _nNxt		:= 0
	Local cNomeEmp:= FWSM0Util():getSM0FullName(_cEmp, _cFil)


	_cBODY := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ' + CRLF
	_cBODY += ' <html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br"> ' + CRLF
	_cBODY += ' <head> ' + CRLF
	_cBODY += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"> ' + CRLF
	_cBODY += ' <meta name="viewport" content="width=device-width, initial-scale=1.0"> ' + CRLF
	_cBODY += ' </head> ' + CRLF
	_cBODY += '	<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #ffffff;"> ' + CRLF
	_cBODY += '		<div style="width: 100%; margin: 0 auto; background-color: #ffffff; border: 1px solid #ddd;"> ' + CRLF
	_cBODY += '			<!-- Cabe�alho do E-mail --> ' + CRLF
	_cBODY += '		   <div style="background-color: #005f27; padding: 20px; color: white; text-align: left;"> ' + CRLF
	_cBODY += '				<h1 style="margin: 0;"><img alt="" src="https://vidara.com/themes/custom/paltana/images/logos/logo.svg" /> ' + CRLF
	_cBODY += '				</h1> ' + CRLF
	_cBODY += '			</div>' + CRLF
	_cBODY += '            <!--td style="width: 5%;"><img style="height: 100px; width: 215px;" src="##_LOGOMARCA##" alt="LOGO" /></td> ' + CRLF
	_cBODY += '			<!-- Corpo do E-mail --> ' + CRLF
	_cBODY += '			<div style="padding: 20px;"> ' + CRLF
	_cBODY += '				<strong>Prezado cliente,</strong> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<p>Ainda n�o identificamos o pagamento dos t�tulos listados abaixo. Caso j� tenha efetuado o pagamento, por favor desconsidere este aviso ou entre em contato conosco para esclarecimentos.	</p> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<!-- Tabela --> ' + CRLF
	_cBODY += '				</span> ' + CRLF
	_cBODY += "				<span style='font-weight: bold;'>Cliente: &nbsp; <strong> <span style='color: #339966;'> "+ cCliente + "</strong> </span> " + CRLF
	_cBODY += " 			&nbsp; " + IIF(Len(Alltrim(cCNPJ)) > 11,"("+Transform(cCNPJ,"@R 99.999.999/9999-99")+")",+"("+Transform(cCNPJ,"@R 999.999.999-99")+")")+" </p> " + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += "<!-- Tabela -->" + CRLF
	_cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>" + CRLF
	_cBODY += "               <thead>"

	_cBODY += "                  <tr>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nr. T�tulo</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Parcela</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nota Fiscal</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Data Emiss�o</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Vencimento</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Valor</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Saldo</th>"
	_cBODY += "                  </tr>"
	_cBODY += "               </thead>"
	_cBODY += "               <tbody>"


	For _nNxt := 1 to Len(_aTit)

		_cBody   += "<tr>" + CRLF

		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,5]+"</td>"     + CRLF                               + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,6]+" / "+_aTIT[_nNxt,15]+" </td>"     + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + _aTIT[_nNxt,14]+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + TRANSFORM(_aTIT[_nNxt,07],"@E 99/99/9999")    + "</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + Transform(_aTIT[_nNxt,08],"@E 99/99/9999")    + "</td>"        + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;"  + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,12], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,09], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
		_cBody   += "</tr>   "+ CRLF

	Next


	_cBODY += '					</tbody> ' + CRLF
	_cBODY += '				</table> ' + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += '				<!-- Nota--> ' + CRLF
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Nota: Este e-mail � gerado automaticamente, por favor n�o responder.</strong></p> ' + CRLF
	_cBODY += '				<p > Qualquer d�vida, entre em contato conosco.</p>	'+ CRLF
	_cBODY += '				<!--e-mail --> ' + CRLF
	_cBODY += "				<p >Email:&nbsp;<a href='mailto:'"+cEmailFin+'>'+cEmailFin+"</a></p> " + CRLF
	_cBODY += '				<p > Telefone / Whatsapp:  (11) 3109-2000 </p>	'+ CRLF



	_cBODY += '				<!-- Aviso Legal --> ' + CRLF
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Aviso Legal:</strong> ' + CRLF
	_cBODY += '				Esta mensagem � destinada exclusivamente para a(s) pessoa(s) a quem � dirigida, podendo conter informa��o confidencial e/ou legalmente privilegiada. Se voc� n�o for destinat�rio desta mensagem, <br/> ' + CRLF
	_cBODY += '				desde j� fica notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar a informa��o contida nesta mensagem, por ser ilegal. ' + CRLF
	_cBODY += '				Caso voc� tenha recebido esta mensagem por <br/> ' + CRLF
	_cBODY += '				engano, pe�o que me retorne este e-mail, promovendo, desde logo, a elimina��o do seu conte�do em sua base de dados, registros ou sistema de controle. ' + CRLF
	_cBODY += '				Fica desprovida de efic�cia e validade mensagem que <br/> ' + CRLF
	_cBODY += '				contiver opini�es particulares e v�nculos obrigacionais, expedida por quem n�o detenha poderes de representa��o por parte da ' + CRLF
	_cBODY += "				<strong>'"+cnomeemp+"'</strong> " + CRLF
	_cBODY += '				</p> ' + CRLF
	_cBODY += '			</div> ' + CRLF
	_cBODY += '		</div> ' + CRLF
	_cBODY += '        <div style="background-color: #005f27; padding: 20px; color: white; text-align: left;"> ' + CRLF
	_cBODY += '            <h1 style="margin: 0;"><img alt="" src="https://vidara.com/themes/custom/paltana/images/logos/logo.svg" /> ' + CRLF
	_cBODY += '            </h1> ' + CRLF
	_cBODY += '        </div>	' + CRLF
	_cBODY += '	</body> ' + CRLF
	_cBODY += ' </html> ' + CRLF




Return _cBody

/*
Static Function QACOB0V(_aTit,cCliente,cCNPJ)
Local _cBody := ""
Local _nNxt		:= 0 


            _cBODY := "<!DOCTYPE html>" + CRLF
            _cBODY += "<html lang='pt-BR'>" + CRLF
            _cBODY += "<head>" + CRLF
            _cBODY += "   <meta charset='UTF-8'>" + CRLF
            _cBODY += "   <meta name='viewport' content='width=device-width, initial-scale=1.0'>" + CRLF
            _cBODY += "</head>" + CRLF
            _cBODY += "<body style='font-family: Trebuchet MS sans-serif; margin: 0; padding: 0; background-color: #ffffff;'>" + CRLF
            _cBODY += "   <div style='font-family: Trebuchet MS;width: 100%; margin: 0 auto; background-color: #ffffff; border: 1px solid #ddd;'>" + CRLF
            _cBODY += "      <!-- Cabe�alho do E-mail -->" + CRLF
            _cBODY += "      <div style='background-color: #005f27; padding: 20px; color: white; text-align: left;'>" + CRLF
            _cBODY += "            <h1 style='margin: 0;'><img src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1>" + CRLF
            _cBODY += "      </div>" + CRLF
            _cBODY += "<!-- Corpo do E-mail -->" + CRLF
            _cBODY += "      <div>" + CRLF
			_cBODY += "<b> " + CRLF
			_cBODY += " <span style='font-size:14.0pt;font-family:'Trebuchet MS',sans-serif;color:black'>Prezado cliente,<o:p></o:p></span></b></p> "+ CRLF
			_cBODY += " <p class=MsoNormal><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'> " + CRLF
//			_cBODY += " </div> "
//			_cBODY += "            <b><p><strong>Prezado Cliente,</strong><o:p></o:p></p>"
			_cBODY += " <p class=MsoNormal><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'> " + CRLF
			_cBODY += "Ainda n�o identificamos o pagamento dos titulos listados abaixo. Caso j� tenha efetuado o pagamento, por favor desconsidere este aviso ou entre em contato conosco para esclarecimentos.<o:p></o:p></span></p>" + CRLF
			_cBODY += " <p class=MsoNormal><b><i><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'><o:p>&nbsp;</o:p></span> " + CRLF
			_cBODY += "</div>" + CRLF
            _cBODY += " <h4> <span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'> Cliente:&nbsp;</span> " + CRLF
			_cBODY    += "<span style='color:#046A38;font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR;'>"+ cCliente + " " +"</span>" + CRLF
			_cBODY    += "<span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'> " + IIF(Len(Alltrim(cCNPJ)) > 11,"("+Transform(cCNPJ,"@R 99.999.999/9999-99")+")",+"("+Transform(cCNPJ,"@R 999.999.999-99")+")")+"</span><br /><br></p></h4>" + CRLF
		    _cBODY += "<!-- Tabela -->" + CRLF
            _cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>" + CRLF
            _cBODY += "               <thead>"

            _cBODY += "                  <tr>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nr. T�tulo</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Parcela</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nota Fiscal</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Data Emiss�o</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Vencimento</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Valor</th>"
            _cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Saldo</th>"
            _cBODY += "                  </tr>"
            _cBODY += "               </thead>"
            _cBODY += "               <tbody>"
         
            
     	For _nNxt := 1 to Len(_aTit)

				_cBody   += "<tr>" + CRLF
	                          
			    _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,5]+"</td>"     + CRLF                               + CRLF
                _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,6]+"</td>"     + CRLF
				_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + _aTIT[_nNxt,14]+"</td>"    + CRLF
				_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + TRANSFORM(_aTIT[_nNxt,07],"@E 99/99/9999")    + "</td>"    + CRLF
			    _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + Transform(_aTIT[_nNxt,08],"@E 99/99/9999")    + "</td>"        + CRLF
	    		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;"  + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,12], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
         		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,09], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
                _cBody   += "</tr>   "+ CRLF 
			
		Next
       

            _cBODY += "               </tbody>"
            _cBODY += "            </table>"
            _cBODY += "            <!-- Aviso Legal -->"
            _cBODY += "            <p style='style='font-size:10.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR ;'>"
            _cBODY += "               <strong><b><i>Nota: Este E-mail � gerado automaticamente, favor n�o responder.</strong> "
            _cBODY += "            </b></i></p>"
			_cBody   += "<p><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'>Telefone / Whatsapp:&nbsp; (11) 3109-2000 </span></p>" + CRLF
            _cBody   += "<p><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'>Email:&nbsp;<a href='mailto:'"+cEmailFin+'>'+cEmailFin+"</a></span></p>" + CRLF
			_cBody   += "<p><span style='font-size:12.0pt;font-family:'Trebuchet MS',serif;mso-fareast-language:PT-BR'>Qualquer duvida, entre em contato conosco </span></p>" + CRLF

			_cBODY += "      </div>"
            _cBODY += "   </div>"
            _cBODY += "  <div style='background-color: #005f27; padding: 20px; color: white; text-align: center;'> "
            _cBODY += "   <h1 style='margin: 0;'><img alt='' src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1> "
            _cBODY += "     </div>"
            _cBODY += "</body>"
            _cBODY += "</html>"   


		
Return _cBody
/*
