//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} ZTITAVENC
DISPARA E_MAIL DOS TITULOS A VENCER 
GAP ID: 033 
@author Abel Ribeiro
@since 29/05/2024
@parameters
@return
@version 1.0
    @example
 	 @revision Wagner Neves
/*/
User Function ZTITAVEN(aParams)
	Local lContinua := .F.
	Local nFil
	Local nEmp
	Local cFilBck     := cFilAnt
	Local cEmpBck     := cEmpAnt
	Private lJobPvt 			:= IsBlind() .Or. Empty(AllTrim(FunName()))
	Private _cEmp     := "01"
	Private _cFil     := "0101"
	Private cMsgLog   := ""
	Private aEmpAux   := FWAllGrpCompany()
	Private aFilAux   := {}

	Default aParams     := {"01","0101"}
	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt		:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			aParams	:= {aEmpAux[nEmp], aFilAux[nFil] }
			_cEmp   := aParams[01]
			_cFil   := aParams[02]

			//Se o ambiente não estiver em pé, sobe para usar de maneira automática
			If Select("SX2") == 0

				lJobPvt   := .T.
				lContinua := .T.

				cMsgLog := "-------------------------------------------------------------------------------"  + CRLF
				cMsgLog +=  " ZTITAVENC -  JOB ENVIO DE BOLETO A VENCER - INICIO                           "  + CRLF
				cMsgLog +=  " Empresa: " + _cEmp                                                              + CRLF
				cMsgLog +=  " Filial : " + _cFil 															  + CRLF
				cMsgLog +=  " Inicio : " + DTOC(DATE()) + " - " + subs(time(),1,5)							  + CRLF
				cMsgLog +=  "-------------------------------------------------------------------------------" + CRLF

				U_ZGERALOG(cMsgLog)

				RpcClearEnv()
				RPCSetType( 3 )     // Não consome licensa de uso
				_cEmp	:= aParams[01]
				_cFil	:= aParams[02]
				RPCSetEnv(_cEmp, _cFil, "", "", "", "")
			EndIf

			//Se não for modo automático, mostra uma pergunta
			If ! lJobPvt
				FwAlertInfo("Deseja gerar o e-Mail dos títulos a Vencer ?", "Atenção")
			EndIf

			//Se for continuar, faz a chamada para o disparo do e-Mail
			If lContinua
				If ! lJobPvt
					Processa({|| fProcDad() }, "Processando...")
				else
					Processa( fProcDad() )
				Endif
			EndIf
			RpcClearEnv() //volta a empresa anterior
		Next
		nFil	:= 1
	Next

	cEmpAnt := cEmpBck
	cFilAnt := cFilBck
Return

Static Function fProcDad()
	Local nAtual
	Local nTotal
	Local cQuery      := ""
	Local cCodCLI     := ""
	Private aDados	  := {}
	Private dDataVen  := date() //dDataBAse
	Private aRetMail  := {}
	Private aAnexos   := {}
	Private _lRetMail := .F.
	Private _cBody    := ""
	Private	_cAssunto := "[VIDARA] AVISO DE TITULOS A VENCER"
	Private cEmailFin := SuperGetMV('ZZ_XAVEMCC', .F. ,"adm.financeiro.br@vidara.com")     //Email Reponsável Financeiro
	Private nDias     := SuperGetMV('ZZ_PRZAVVE', .F. ,5) 								 //Numero de dias a vencer
	Private cCopia    := SuperGetMV('ZZ_EmFinCC', .F. ,"adm.financeiro.br@vidara.com") //Usuário que irão receber cópia dos Emails aviso cobrança
	Private _cEmailTo := ""
	Private cEmailGe  := SuperGetMV('ZZ_EMAILGE', .F. ,"")


	//Buscando os títulos que venceram, conforme o número de dias na variável nDias
	cQuery := " SELECT " + CRLF
	cQuery += " 	E1_CLIENTE, "     + CRLF
	cQuery += " 	E1_LOJA, "        + CRLF
	cQuery += " 	A1_EMAIL,"        + CRLF
	cQuery += " 	E1_NOMCLI, "      + CRLF
	cQuery += " 	E1_FILIAL, "      + CRLF
	cQuery += " 	E1_PREFIXO, "     + CRLF
	cQuery += " 	E1_NUM, "         + CRLF
	cQuery += " 	E1_PARCELA, "     + CRLF
	cQuery += " 	E1_EMISSAO, "     + CRLF
	cQuery += " 	E1_PORTADO, "     + CRLF
	cQuery += " 	E1_VENCTO, "      + CRLF
	cQuery += " 	E1_VENCREA, "     + CRLF
	cQuery += " 	SE1.R_E_C_N_O_ AS R_E_C_N_O_," + CRLF
	cQuery += "     E1_VALOR, "       + CRLF
	cQuery += " 	E1_SALDO, "       + CRLF
	cQuery += " 	E1_TIPO, "        + CRLF
	cQuery += "     A1_NOME,"         + CRLF
	cQuery += "     A1_CGC,"           + CRLF
	cQuery += " (SELECT C5_NOTA FROM "
	cQuery += " "+ RetSQLName("SC5") + " SC5 (NOLOCK) WHERE "  + CRLF
	cQuery += " SC5.D_E_L_E_T_= ' ' AND  " + CRLF
	cQuery += "C5_FILIAL = E1_FILIAL  " + CRLF
	cQuery += " AND C5_NUM = E1_PEDIDO) " + CRLF
	cQuery += " 	C5_NOTA,"     + CRLF
	cQuery += " (SELECT MAX(E1_PARCELA) FROM " + CRLF
	cQuery += "  " + RetSQLName("SE1") + " SE12 (NOLOCK) WHERE " + CRLF
	cQuery += " SE12.D_E_L_E_T_= ' ' " + CRLF
	cQuery += "  AND SE12.E1_FILIAL = SE1.E1_FILIAL  " + CRLF
	cQuery += "  AND  SE12.E1_NUM = SE1.E1_NUM  " + CRLF
	cQuery += "  AND SE12.E1_PREFIXO = SE1.E1_PREFIXO  " + CRLF
	cQuery += "  AND SE12.E1_TIPO = SE1.E1_TIPO) MAXPAR " + CRLF
	cQuery += " FROM " + CRLF
	cQuery += " 	" + RetSQLName("SE1") + " SE1 (NOLOCK) " + CRLF
	cQuery += " 	INNER JOIN " + RetSQLName("SA1") + " SA1 ON ( " + CRLF
	cQuery += " 		A1_COD      = E1_CLIENTE "     + CRLF
	cQuery += " 		AND A1_LOJA = E1_LOJA "   + CRLF
	cQuery += "    AND A1_FILIAL  = '"+xFilial("SA1")+ "' " + CRLF
	cQuery += " 		AND SA1.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " 	) " + CRLF
	cQuery += " WHERE " + CRLF
	cQuery += "     E1_FILIAL = '" + xFILIAL("SE1") + "' AND "
	cQuery += " 	E1_VENCREA    = '" + dToS(DaySum(dDataVen, nDias )) + "' "   + CRLF //vencendo hoje teste
	cQuery += "    AND E1_FILIAL  = '"+xFilial("SE1")+ "' " + CRLF
	cQuery += " 	AND SE1.D_E_L_E_T_  = ' ' "  + CRLF
	cQuery += " 	AND E1_SALDO > 0 " + CRLF
	cQuery += " ORDER BY E1_VENCREA DESC"   + CRLF

	TCQuery cQuery New Alias "QRY_DAD"

	//Define as colunas como tipo Data

	TCSetField('QRY_DAD', 'E1_EMISSAO', 'D')
	TCSetField('QRY_DAD', 'E1_VENCTO', 'D')
	TCSetField('QRY_DAD', 'E1_VENCREA', 'D')


	//Define o tamanho da régua
	Count To nTotal
	IF !lJobPvt
		ProcRegua(nTotal)
	ENDIF

	QRY_DAD->(DbGoTop())
	IF QRY_DAD->(EOF())
		cMsgLog := "-------------------------------------------------------------------------------"  + CRLF
		cMsgLog += " ZTITAVEN -  JOB ENVIO DE BOLETO A VENCER - FIM                                "  + CRLF
		cMsgLog += " Empresa: " + _cEmp 															  + CRLF
		cMsgLog += " Filial : " + _cFil  															  + CRLF
		cMsgLog += " <<<<     Nenhum Registro Selecionado para essa Data >>> "+ dToS(dDataVen)        + CRLF
		cMsgLog += " Término: " + FWTIMESTAMP() + "Hora: " + subs(time(),1,5)                         + CRLF
		cMsgLog += "-------------------------------------------------------------------------------"  + CRLF

		U_ZGERALOG(cMsgLog)
		QRY_DAD->(DbCloseArea())
		RETURN
	Endif

	//Percorrendo os registros

	cCodCLI     := QRY_DAD->E1_CLIENTE + QRY_DAD->E1_LOJA

	While ! QRY_DAD->(EoF())

		//Incrementa a régua
		nAtual++

		IF !lJobPvt
			IncProc("Processando registro " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		EndIf

		//TESTE JOB

		if Empty(cEmailGe)
			_cEmailTo := QRY_DAD->A1_EMAIL
		Else
			_cEmailTo := cEmailGe
		Endif

		IF Empty(QRY_DAD->A1_EMAIL)
			cMsgLog := "-----------------------------------------------------------------------------------"  + CRLF
			cMsgLog +=  " ZTITAVENC -  JOB ENVIO DE AVISO TITULOS A VENCER                              "  + CRLF
			cMsgLog +=  " **** Campo E-mail Cliente ["+QRY_DAD->E1_CLIENTE + "/" + QRY_DAD->E1_LOJA +"] está Vazio - E-mail Não enviado ****                    "  + CRLF
			cMsgLog +=  " Inicio : " + FWTIMESTAMP() + " - " + subs(time(),1,5)			  				  + CRLF
			cMsgLog +=  "---------------------------------------------------------------------------------" + CRLF
			U_ZGERALOG(cMsgLog)
			QRY_DAD->(dbSkip(1) )
			LOOP
		Endif
		//Adiciona dados dos títulos

		IF cCODCLI <>  QRY_DAD->E1_CLIENTE + QRY_DAD->E1_LOJA

			aSort(aDados, , , {|x, y| x[8] < y[8]})

			_cBody := QACOB0V(aDados,aDados[1][10],aDados[1][11])

			//Dispara o e-Mail

			U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBody,aAnexos)

			aDados := {}
		Endif

		aAdd(aDados, {QRY_DAD->E1_CLIENTE,QRY_DAD->E1_LOJA,;
			QRY_DAD->A1_EMAIL,;
			QRY_DAD->E1_PREFIXO,;
			QRY_DAD->E1_NUM,;
			QRY_DAD->E1_PARCELA,;
			QRY_DAD->E1_EMISSAO,;
			QRY_DAD->E1_VENCREA,;
			QRY_DAD->E1_SALDO,;
			Alltrim(QRY_DAD->A1_NOME),;
			QRY_DAD->A1_CGC,;
			QRY_DAD->E1_VALOR,;
			QRY_DAD->E1_TIPO,;
			QRY_DAD->C5_NOTA,;
			QRY_DAD->MAXPAR})

		cCODCLI := QRY_DAD->E1_CLIENTE + QRY_DAD->E1_LOJA
		cNomeCli:= QRY_DAD->E1_NOMCLI

		//Ordena o Array por Nome (Array multidimensional) - Decrescente
		QRY_DAD->(DbSkip())
	EndDo

	QRY_DAD->(DbCloseArea())

	/* Imprime Ultimo registro */


	IF LEN(aDADOS) > 0

		aSort(aDados, , , {|x, y| x[8] < y[8]})

		_cBody    := FCOB04B(aDados,aDados[1][10],aDados[1][11])

		lRetMAIL := U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBody,aAnexos)
	    /*
		IF lRetMAIL
            //Atualiza status de email enviado
            For I := 1 TO LEN(aDados)
               cSQL := "UPDATE "+RETSQLNAME("SE1")+" SET E1_ZZSTCOB = '"+cSTAT+"'"+STRZERO(Day(DDataBase),2)+ "/"+ STRZERO(Month(dDataBAse),2)+" + CRLF
               cSQL += "WHERE E1_NUM  = '"+aDados[I][5] +"' AND E1_PREFIXO = '"+aDados[I][4]+"' AND E1_CLIENTE = '"+aDados[I][1]+"' AND E1_LOJA= '"+aDados[I][2]+"'" + CRLF
               cSQL += "      E1_TIPO = '"+aDados[I][13]+"' AND E1_PARCELA = '"+aDados[I][6]+"' " + CRLF
               cSQL += "      AND D_E_L_E_T_ <> '*' "

               If TCSQLExec(cSQL) <> 0
                  ApMsgAlert( AllTrim(TCSQLError()), "Não foi possivel Gravar Flag E-mail." )
               Endif
            NEXT       
         EndIf
		*/ 
	EndIf

	cMsgLog := "-------------------------------------------------------------------------------" + CRLF
	cMsgLog += " ZTITVENC -  JOB AVISO DE TITULOS VENCIDOS - FIM                               " + CRLF
	cMsgLog += " Empresa: " + _cEmp  															+ CRLF
	cMsgLog += " Filial : " + _cFil  															+ CRLF
	cMsgLog += " Término: " + FWTIMESTAMP() + " Hora: " + subs(time(),1,5)                       + CRLF
	cMsgLog += "-------------------------------------------------------------------------------" + CRLF

	U_ZGERALOG(cMsgLog)


Return
/*
 * Funcao............: QACOB04B
 * Parametros........: aTitulo 	- Titulos a ser impresso no e-mail
 *					   _aTit	- Vetor com todos os títulos selecionados.
 *
 * Retorno...........: Texto do e-mail para titulos a Vencer
 *
 * Responsável.......: Abel Ribeiro
 * Data..............: 29/05/2024
 * Objetivo..........: e-mail Cobrança para titulos a vencer
*/

Static Function FCOB04B(_aTit,cCliente,cCNPJ)
	Local _cBody := ""
	Local _nNxt		:= 0
	Local cNomeEmp:= FWSM0Util():getSM0FullName(_cEmp, _cFil)


	_cBODY := ' <!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"> ' + CRLF
	_cBODY += ' <html xmlns="http://www.w3.org/1999/xhtml" lang="pt-br"> ' + CRLF
	_cBODY += ' <head> ' + CRLF
	_cBODY += '    <meta http-equiv="Content-Type"; charset=iso-8859-1"> ' + CRLF
	_cBODY += ' <meta name="viewport" content="width=device-width, initial-scale=1.0"> ' + CRLF
	_cBODY += ' </head> ' + CRLF
	_cBODY += '	<body style="font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #ffffff;"> ' + CRLF
	_cBODY += '		<div style="width: 100%; margin: 0 auto; background-color: #ffffff; border: 1px solid #ddd;"> ' + CRLF
	_cBODY += '			<!-- Cabeçalho do E-mail --> ' + CRLF
	_cBODY += '		   <div style="background-color: #005f27; padding: 20px; color: white; text-align: left;"> ' + CRLF
	_cBODY += '				<h1 style="margin: 0;"><img alt="" src="https://vidara.com/themes/custom/paltana/images/logos/logo.svg" /> ' + CRLF
	_cBODY += '				</h1> ' + CRLF
	_cBODY += '			</div>' + CRLF
	_cBODY += '            <!--td style="width: 5%;"><img style="height: 100px; width: 215px;" src="##_LOGOMARCA##" alt="LOGO" /></td> ' + CRLF
	_cBODY += '			<!-- Corpo do E-mail --> ' + CRLF
	_cBODY += '			<div style="padding: 20px;"> ' + CRLF
	_cBODY += '				<strong>Prezado cliente,</strong> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<p>Informamos os próximos títulos a vencer. Caso já tenha efetuado o pagamento, por favor desconsidere este aviso ou entre em contato conosco para esclarecimentos.	</p> ' + CRLF
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
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nr. Título</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Parcela</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nota Fiscal</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Data Emissão</th>"
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
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Nota: Este e-mail é gerado automaticamente, por favor não responder.</strong></p> ' + CRLF
	_cBODY += '				<p > Qualquer dúvida, entre em contato conosco.</p>	'+ CRLF
	_cBODY += '				<!--e-mail --> ' + CRLF
	_cBODY += "				<p >Email:&nbsp;<a href='mailto:'"+cEmailFin+'>'+cEmailFin+"</a></p> " + CRLF
	_cBODY += '				<p > Telefone / Whatsapp:  (11) 3109-2000 </p>	'+ CRLF



	_cBODY += '				<!-- Aviso Legal --> ' + CRLF
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Aviso Legal:</strong> ' + CRLF
	_cBODY += '				Esta mensagem é destinada exclusivamente para a(s) pessoa(s) a quem é dirigida, podendo conter informação confidencial e/ou legalmente privilegiada. Se você não for destinatário desta mensagem, <br/> ' + CRLF
	_cBODY += '				desde já fica notificado de abster-se a divulgar, copiar, distribuir, examinar ou, de qualquer forma, utilizar a informação contida nesta mensagem, por ser ilegal. ' + CRLF
	_cBODY += '				Caso você tenha recebido esta mensagem por <br/> ' + CRLF
	_cBODY += '				engano, peço que me retorne este e-mail, promovendo, desde logo, a eliminação do seu conteúdo em sua base de dados, registros ou sistema de controle. ' + CRLF
	_cBODY += '				Fica desprovida de eficácia e validade mensagem que <br/> ' + CRLF
	_cBODY += '				contiver opiniões particulares e vínculos obrigacionais, expedida por quem não detenha poderes de representação por parte da ' + CRLF
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
