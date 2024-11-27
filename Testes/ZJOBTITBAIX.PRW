#INCLUDE "PROTHEUS.CH"
#include 'tbiconn.ch'
#include 'topconn.ch'
#include 'AP5MAIL.ch'


/*/{Protheus.doc} ZJOBTITBAIX
DISPARA E_MAIL AVISO DE BAIXA DE PAGAMENTOS D-1
ID: 035 - JOB Aviso de Baixa de Pagamento MIT044
@author Abel Ribeiro
@since 03/06/2024
@parameters
@return
@version 1.0
    @example
 	 @revision Wagner Neves
/*/

USER FUNCTION ZTITBAIX()
	Local lContinua  := .F.
	Local nFil
	Local nEmp
	Local cFilBck     := cFilAnt
	Local cEmpBck     := cEmpAnt
	Private lJobPvt   := .F.
	Private _cEmp     := "01"
	Private _cFil     := "01"
	Private cLogMsg   := ""
	Private aEmpAux   := FWAllGrpCompany()
	Private aFilAux   := {}

	aTables := {"SE5","SE2","SA2","SE1"}

	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			_cEmp   := aEmpAux[nEmp]
			_cFil   := aFilAux[nFil]
			//Se o ambiente não estiver em pé, sobe para usar de maneira automática
			If Select("SX2") == 0
				lJobPvt   := .T.
				lContinua := .T.

				cLogMsg := "-------------------------------------------------------------------------------" + CRLF
				cLogMsg += " ZTITBAIX: " + _cEmp                                                             + CRLF
				cLogMsg += " Filial  : " + _cFil                                                             + CRLF
				cLogMsg += " Inicio  : " + DTOC(DATE()) + " - " + subs(time(),1,5)                           + CRLF
				cLogMsg += "-------------------------------------------------------------------------------" + CRLF

				U_ZGERALOG(cLogMsg)

				RpcClearEnv()
				RPCSetType( 3 )     // Não consome licensa de uso
				RPCSetEnv(_cEmp, _cFil, "", "", "", "")

			Endif

			//Se não for modo automático, mostra uma pergunta
			If ! lJobPvt
				FWALERTINFO("Deseja gerar o e-Mail dos títulos vencidos?", "Atenção")
			EndIf

			//Se for continuar, faz a chamada para o disparo do e-Mail
			If !lJobPvt
				Processa({|| fProcDad() }, "Processando...")
			Else
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
	Local cCODFOR     := ""
	Local cQuery      := ""
	Local cUPDSe2     := ""

	Local cAliasSE2   := GetNextAlias()
	Local nReg        := 0
	Local cCopia      := ""
	Local nZ

	Private dDataBx   := DATE() //CTOD("16/08/2024")    //dDataBAse
	Private aDados1   := {}
	Private aAnexos   := {}
	Private cMSGLog     := ""
	Private _lRetMail := .F.
	Private _cAssunto := "[VIDARA] AVISO DE TITULOS PAGOS"
	Private cEmailFin := SuperGetMV('ZZ_XAVEMCC', .F. ,"adm.financeiro.br@vidara.com")                 //Email Reponsável Financeiro
	Private _cBODY      := ""
	Private cEmailGe  := SuperGetMV('ZZ_EMAILGE', .F. ,"")



	cQUERY := "SELECT E2_NUM,E2_PARCELA,E2_TIPO,E2_PREFIXO,E2_FORNECE,E2_LOJA, E2_VENCREA,E2_BAIXA,E2_EMISSAO,E2_VALOR,E2_SALDO, " + CRLF
	cQUERY += " E2_ORIGEM,
	cQuery += " (SELECT MAX(E2_PARCELA) FROM " + CRLF
	cQuery += "  " + RetSQLName("SE2") + " SE22 (NOLOCK) WHERE " + CRLF
	cQuery += " SE22.D_E_L_E_T_= ' ' " + CRLF
	cQuery += "  AND SE22.E2_FILIAL = SE2.E2_FILIAL  " + CRLF
	cQuery += "  AND  SE22.E2_NUM = SE2.E2_NUM  " + CRLF
	cQuery += "  AND SE22.E2_PREFIXO = SE2.E2_PREFIXO  " + CRLF
	cQuery += "  AND SE22.E2_TIPO = SE2.E2_TIPO) MAXPAR, " + CRLF
	cQUERY += " A2_NOME,A2_EMAIL,A2_CGC FROM "+RETSQLNAME("SE2")+ " SE2 (NOLOCK) "                             + CRLF
	cQUERY += "INNER JOIN "+RETSQLNAME("SA2")+ " SA2 ON A2_COD = E2_FORNECE AND A2_LOJA = E2_LOJA AND SA2.D_E_L_E_T_ <> '*' " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "     E2_ZZENVMA IN (' ','2') AND E2_BAIXA = '"+DTOS(dDATABX)+"' AND SE2.D_E_L_E_T_ = ' ' " + CRLF
	cQuery += " ORDER BY E2_VENCREA "
	//cQUERY += "GROUP BY E2_NUM,E2_PARCELA,E2_TIPO,E2_PREFIXO,E2_FORNECE,E2_LOJA, E2_VENCREA,E2_BAIXA,E2_EMISSAO,E2_VALOR,E2_SALDO,A2_NOME,A2_EMAIL,A2_CGC"


	DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),cAliasSE2, .F., .T.)

	TcSetField(cAliasSE2,"E2_BAIXA"  ,"D",8,0)
	TcSetField(cAliasSE2,"E2_EMISSAO","D",8,0)
	TcSetField(cAliasSE2,"E2_VENCREA","D",8,0)

	DBSelectArea(cAliasSE2)
	(cAliasSE2)->(DBGoTop())

	IF (cAliasSE2)->(EOF())
		cMSgLog:= "-------------------------------------------------------------------------------" + CRLF
		cMSgLog+= " ZTITBAIX -  JOB ENVIO AVISO DE PAGAMENTO                                      " + CRLF
		cMSgLog+= " Empresa: " + _cEmp 														              		  + CRLF
		cMSgLog+= " Filial : " + _cFil 																              + CRLF
		cMSgLog+= " Inicio : " + DTOC(DATE()) + " - " + subs(time(),1,5) 							        + CRLF
		cMSgLog+= " <<<<< Arquivo Vazio. Nenhum Registro Encontrado >>>>>" + DTOC(DATE()) + " - "   + subs(time(),1,5) + CRLF
		cMSgLog+= "-------------------------------------------------------------------------------" + CRLF
		U_ZGERALOG(cMsgLog)
		(cAliasSE2)->(DbCloseArea())
		RETURN
	Endif

	//Percorrendo os registros
	cCODFOR := (cAliasSE2)->E2_FORNECE +  (cAliasSE2)->E2_LOJA

	While (cAliasSE2)->(!EOF())

		IF Empty(cEmailGe)
			_cEmailTo := (cAliasSE2)->A2_EMAIL
		Else
			_cEmailTo:= cEmailGe
		Endif

		IF Empty(_cEmailTo)
			cMsgLog := "-----------------------------------------------------------------------------------"  + CRLF
			cMsgLog +=  " ZTITBAIX -  JOB ENVIO DE TITULOS BAIXADOS                                        "  + CRLF
			cMsgLog +=  " **** Campo E-mail Fornecedor ["+(cAliasSE2)->E2_FORNECE + "/" + (cAliasSE2)->E2_LOJA +"] está Vazio - E-mail Não enviado ****" + CRLF
			cMsgLog +=  " Inicio : " + FWTIMESTAMP() + " - " + subs(time(),1,5)			  				  + CRLF
			cMsgLog +=  "---------------------------------------------------------------------------------" + CRLF
			U_ZGERALOG(cMsgLog)
			(cAliasSE2)->(dbSkip(1) )
			LOOP
		Endif

		nREG++
		IF cCODFOR <>  (cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA

			aSort(aDados1, , , {|x, y| x[6] < y[6]})

			_cBODY := QACOB0X(aDados1,aDados1[1][8],aDADOS1[1][09],aDADOS1[1,16])

			//Dispara o e-Mail
			U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBODY,aAnexos)

			aDados1  := {}
		EndIf

		AADD( aDados1,{ (cAliasSE2)->E2_NUM,;
			(cAliasSE2)->E2_PARCELA,;
			(cAliasSE2)->E2_FORNECE,;
			(cAliasSE2)->E2_LOJA,;
			(cAliasSE2)->E2_EMISSAO,;
			(cAliasSE2)->E2_VENCREA,;
			(cAliasSE2)->E2_VALOR,;
			(cAliasSE2)->A2_NOME,;
			(cAliasSE2)->A2_CGC,;
			(cAliasSE2)->E2_PREFIXO,;
			(cAliasSE2)->E2_TIPO,;
			(cAliasSE2)->A2_EMAIL,;
			(cAliasSE2)->E2_SALDO,;
			(cAliasSE2)->MAXPAR,;
			(cAliasSE2)->E2_ORIGEM,;
			(cAliasSE2)->E2_BAIXA} )

		cCodFOR := (cAliasSE2)->E2_FORNECE + (cAliasSE2)->E2_LOJA

		(cAliasSE2)->(dbSkip(1) )
	ENDDO


	(cAliasSE2)->(DbCloseArea())

/* Imprime Ultimo registro */

	IF LEN(aDADOS1) > 0

		aSort(aDados1, , , {|x, y| x[6] < y[6]})

		_cBODY    := QACOB0X(aDados1,aDADOS1[1,8],aDADOS1[1,9],aDADOS1[1,16])

		lEnvMail := U_VDEVMAIL(_cEmailTo,cCopia,_cAssunto,_cBODY,aAnexos)

		IF lEnvMail

			//Atualiza status de email enviado
			For nZ := 1 TO LEN(aDADOS1)
				// cUPDSE2 := "UPDATE "+RETSQLNAME("SE2")+" SET E2_ZZENVMA = '1' " + CRLF
				// cUPDSE2 += "WHERE E2_NUM  = '"+aDados1[nZ][1] +"' AND E2_PREFIXO = '"+aDados1[nZ][10]+"' AND E2_FORNECE = '"+aDados1[I][3]+"' AND E2_LOJA= '"+aDados[I][4]+"'" + CRLF
				// cUPDSE2 += "      E2_TIPO = '"+aDados1[nZ][11]+"' AND E2_PARCELA = '"+aDados1[Nz][2]+"' " + CRLF
				// cUPDSE2 += "      AND D_E_L_E_T_ = ' ' "

				// If TCSQLExec(cUPDSE2) <> 0
				// 	ApMsgAlert( AllTrim(TCSQLError()), "Não foi possivel Gravar Flag E-mail." )
				// Endif

				SE2->( DbSetOrder(1) )
				If SE2->(DbSeek(xFilial("SE2")+aDados1[nZ][10]+aDados1[nZ][1]+aDados1[Nz][2]+aDados1[nZ][11]+aDados1[I][3]+aDados[I][4]))//E2_FILIAL+E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA
					Reclock("SE2", .F.)
					SE2->E2_ZZENVMA := "1"
					SE2->( MsUnLock() )
				EndIf
			NEXT
		Endif

		cLogMsg := "-------------------------------------------------------------------------------" + CRLF
		cLogMsg += " ZTITBAIX -  JOB ENVIO DE E-MAIL TITULOS BAIXADOS -  FIM                       " + CRLF
		cLogMsg += " Empresa: " + _cEmp  															               + CRLF
		cLogMsg += " Filial : " + _cFil  													               		+ CRLF
		cLogMsg += " Término: " + DTOC(DATE()) + " Hora: " + subs(time(),1,5)                       + CRLF
		cLogMsg += "-------------------------------------------------------------------------------" + CRLF

		U_ZGERALOG(cLogMsg)
	Endif
RETURN
Static Function QACOB0X(_aTit,cNomeFor,cCNPJ,dBaixa)
	Local _cBODY := ""
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
	_cBODY += '				<strong>Prezado fornecedor,</strong> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<p>Comunicamos que efetuamos o pagamento dos títulos abaixo:</p> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<!-- Tabela --> ' + CRLF
	_cBODY += '				</span> ' + CRLF
	_cBODY += "				<span style='font-weight: bold;'>Fornecedor: &nbsp; <strong> <span style='color: #339966;'> "+ cNomeFor + "</strong> </span> " + CRLF
	_cBODY += " 			&nbsp; " + IIF(Len(Alltrim(cCNPJ)) > 11,"("+Transform(cCNPJ,"@R 99.999.999/9999-99")+")",+"("+Transform(cCNPJ,"@R 999.999.999-99")+")")+" </p> " + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += "				<span style='font-weight: bold;'>Data da Baixa: &nbsp; <strong> <span style='color: #339966;'> "+  TRANSFORM(dBaixa,"@E 99/99/9999")  + "</strong> </span> " + CRLF
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

		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,1]+"</td>"     + CRLF                               + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,2]+" / "+_aTIT[_nNxt,14]+" </td>"     + CRLF
		IF  ALLTRIM(_aTIT[_nNxt,15]) == 'MATA100'
			_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + _aTIT[_nNxt,1]+"</td>"    + CRLF
		Else
			_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp; </td>"    + CRLF
		Endif
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + TRANSFORM(_aTIT[_nNxt,05],"@E 99/99/9999")    + "</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + Transform(_aTIT[_nNxt,06],"@E 99/99/9999")    + "</td>"        + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;"  + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,07], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,13], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
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

Return _cBODY
