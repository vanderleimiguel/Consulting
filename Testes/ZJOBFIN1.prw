//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*
// Projeto: VIDARA
// Modulo : SIGAFIN
// Fonte  : ZJOBFIN1
// ------------+-------------------+-----------------------------------------------------------
// Data        | Autor             | Descricao
// ------------+-------------------+-----------------------------------------------------------
// 19/06/2024  | Abel Ribeiro      | DISPARA E_MAIL DOS TITULOS EM ATRASO PARA OS USUÀRIOS 
//             |                   | CADASTRADOS DOS GRUPOS / DIVISÂO VIDARA 
//             |                   | GAP ID: 032
// ------------+-------------------+-----------------------------------------------------------
*/
User Function ZJOBFIN1(aParams)
	Local lContinua 	:= .F.
	Local nFil
	Local nEmp
	Local cFilBck       := cFilAnt
	Local cEmpBck       := cEmpAnt
	Private cMSGLog     := ""
	Private lJobPvt		:= IsBlind() .Or. Empty(AllTrim(FunName()))
	Private _cEmp     	:= "01"
	Private _cFil     	:= "0101"
	Private aEmpAux   	:= FWAllGrpCompany()
	Private aFilAux   	:= {}

	Default aParams     := {"01","0101"}

	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
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
				cMSgLog:= "-------------------------------------------------------------------------------"
				cMSgLog+= " ZJOBFIN1 -  JOB ENVIO DE TITULOS EM ATRASO  - INICIO                          "
				cMSgLog+= " Empresa: " + _cEmp
				cMSgLog+= " Filial : " + _cFil
				cMSgLog+= " Inicio : " + DTOC(DATE()) + " - " + subs(time(),1,5)
				cMSgLog+= "-------------------------------------------------------------------------------"

				RpcClearEnv()
				RPCSetType( 3 )     // Não consome licensa de uso
				_cEmp	:= aParams[01]
				_cFil	:= aParams[02]
				RPCSetEnv(_cEmp, _cFil, "", "", "", "")
			EndIf

			//Se não for modo automático, mostra uma pergunta
			If ! lJobPvt
				If MSGYESNO("Deseja gerar o e-Mail dos Titulos em Atraso ?", "Atenção")
					lContinua := .t.
				Else
					lContinua := .f.
				EndIf
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
	Local nX
	Local nI
	Local lEnvMail := .F.
	Local cQuery      := ""
	Private aDados	    := {}
	Private _aEmail     := {}
	Private dDataVen    := dDataBAse
	Private aRetMail    := {}
	Private aAnexos     := {}
	Private _lRetMail   := .F.
	Private cCopia      := ""
	Private _cBody      := ""
	Private	_cAssunto   := "[VIDARA] AVISO DE CLIENTES EM ATRASOS"
	Private _nSeq       := 0
	Private nDiasAtras  := 0
	Private cGrupoAnt   := ""

	cQuery += "SELECT E1_NOMCLI, A1_EST, A1_VEND, A3_NOME, E1_NUM,E1_TIPO, E1_CLIENTE,E1_LOJA,E1_EMISSAO, E1_SALDO,E1_VALOR,E1_PARCELA,E1_VENCREA,E1_ZZSTCOB,E1_ZZGRP, " +CRLF
	cQuery += " E1_VEND1, E1_VEND2, E1_VEND3, E1_VEND4, E1_VEND5,
	cQuery += " (SELECT CTT_CUSTO  FROM "+RETSQLNAME("CTT")+" CTT (NOLOCK) WHERE CTT.D_E_L_E_T_= ' ' AND CTT_FILIAL  = '"+xFilial("CTT")+ "' AND CTT_ZZGRP = E1_ZZGRP) CUSTO, "   + CRLF
	cQuery += " (SELECT CTT_DESC01 FROM "+RETSQLNAME("CTT")+" CTT (NOLOCK) WHERE CTT.D_E_L_E_T_= ' ' AND CTT_FILIAL  = '"+xFilial("CTT")+ "' AND CTT_ZZGRP = E1_ZZGRP) DESCC, " + CRLF
	cQuery += " (SELECT C5_NOTA    FROM "+RetSQLName("SC5") + " SC5 (NOLOCK) WHERE SC5.D_E_L_E_T_= ' ' AND  C5_FILIAL = E1_FILIAL AND C5_NUM = E1_PEDIDO) C5_NOTA,"     + CRLF
	cQuery += " (SELECT MAX(E1_PARCELA) FROM " +RetSQLName("SE1") + " SE12 (NOLOCK) WHERE SE12.D_E_L_E_T_= ' ' " + CRLF
	cQuery += "  AND SE12.E1_FILIAL = SE1.E1_FILIAL  " + CRLF
	cQuery += "  AND  SE12.E1_NUM = SE1.E1_NUM  " + CRLF
	cQuery += "  AND SE12.E1_PREFIXO = SE1.E1_PREFIXO  " + CRLF
	cQuery += "  AND SE12.E1_TIPO = SE1.E1_TIPO) MAXPAR " + CRLF
	cQuery += " FROM "+RETSQLNAME("SE1")+" SE1 (NOLOCK) "           + CRLF
	cQuery += " INNER JOIN " + RetSqlName("SA1") + " SA1 " + CRLF
	cQuery += "   ON  SA1.A1_COD = SE1.E1_CLIENTE AND "    + CRLF
	cQuery += "       SA1.A1_LOJA = SE1.E1_LOJA   AND "    + CRLF
	cQuery += "    A1_FILIAL  = '"+xFilial("SA1")+ "' " + CRLF
	cQuery += "    AND   SA1.D_E_L_E_T_ = ' ' "               + CRLF
	cQuery += " LEFT JOIN " + RetSqlName("SA3") + " SA3 " + CRLF
	cQuery += "   ON  SA3.A3_COD  = SA1.A1_VEND "          + CRLF
	cQuery += "       AND SA3.D_E_L_E_T_ = ' ' "           + CRLF
	cQuery += "    AND A3_FILIAL  = '"+xFilial("SA3")+ "' " + CRLF
	cQuery += " WHERE
	cQuery += "       E1_SALDO > 0 "               + CRLF
	cQuery += "       AND  E1_VENCREA  <= '" + DTOS(dDataVen) + "' " + CRLF
	cQuery += "       AND  E1_TIPO NOT LIKE '%-'  AND E1_TIPO NOT LIKE 'RA' AND E1_TIPO <> '" + MVPROVIS +"' " + CRLF
	cQuery += "       AND  E1_ZZGRP <> '   ' AND SE1.D_E_L_E_T_=  '  '"          + CRLF
	cQuery += "    AND E1_FILIAL  = '"+xFilial("SE1")+ "' " + CRLF
	cQuery += " ORDER BY E1_ZZGRP "  					   + CRLF

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
		cMSgLog:= "-------------------------------------------------------------------------------" + CRLF
		cMSgLog+= " ZJOBFIN1 -  JOB ENVIO E_MAIL DE RELAÇÂO DE TITULOS EM ATRASO                  " + CRLF
		cMSgLog+= " Empresa: " + _cEmp 																+ CRLF
		cMSgLog+= " Filial : " + _cFil 																+ CRLF
		cMSgLog+= " Inicio : " + DTOC(DATE()) + " - " + subs(time(),1,5) 							+ CRLF
		cMSgLog+= " <<<<< Arquivo Vazio. Nenhum Registro Encontrado >>>>>" + DTOC(DATE()) + " - "   + subs(time(),1,5) + CRLF
		cMSgLog+= "-------------------------------------------------------------------------------" + CRLF
		U_ZGERALOG(cMsgLog)
		QRY_DAD->(DbCloseArea())
		RETURN
	Endif

	//Percorrendo os registros

	cGrupoAnt := QRY_DAD->E1_ZZGRP

	While !QRY_DAD->(EOF() )
		//Incrementa a régua

		nAtual++
		IF !lJobPvt
			IncProc("Processando Titulos " + cValToChar(nAtual) + " de " + cValToChar(nTotal) + "...")
		ENDIF

		_nSeq++
		nDiasAtras := ( dDataBAse - QRY_DAD->E1_VENCREA )

		IF cGrupoAnt <>  QRY_DAD->E1_ZZGRP

			FBuscaGrupo(cGrupoAnt)

			_cBody := FCOB04C(aRetMail,aRetMail[1][15],aRetMail[1][16])  //Corpo do E-mail Titulos a Vencer (Preventivo)

			//Dispara E-mail para todos os usuários do Grupo
			For nX := 1 TO LEN(_aEmail)
				U_VDEVMAIL(_aEMAIL[Nx][1],cCopia,_cAssunto,_cBody,aAnexos)
			Next

			nSEQ     := 0
			aRETMAIL := {}
			_aEMAIL  := {}
		ENDIF

		Aadd(aRetMail,{;
			_Nseq              ,;       //01
		QRY_DAD->E1_CLIENTE,;       //02
		QRY_DAD->A1_EST    ,;       //03
		QRY_DAD->A1_VEND   ,;       //04
		QRY_DAD->E1_NOMCLI ,;       //05
		QRY_DAD->E1_NUM    ,;       //06
		QRY_DAD->E1_PARCELA,;       //07
		QRY_DAD->E1_EMISSAO,;       //08
		QRY_DAD->E1_VENCREA,;       //09
		QRY_DAD->E1_VALOR  ,;       //10
		QRY_DAD->E1_SALDO  ,;            //11
		nDiasAtras,;				     //12
		Alltrim(QRY_DAD->A3_NOME)   ,;   //13
		Alltrim(QRY_DAD->E1_ZZSTCOB) ,;//14
		QRY_DAD->CUSTO,; //15
		QRY_DAD->DESCC,; //16
		QRY_DAD->C5_NOTA,; //17
		QRY_DAD->MAXPAR,; //18
		QRY_DAD->E1_VEND1   ,; //19
		QRY_DAD->E1_VEND2   ,; //20
		QRY_DAD->E1_VEND3  ,; //21
		QRY_DAD->E1_VEND4   ,; //22
		QRY_DAD->E1_VEND5   })//23

		cGrupoAnt := QRY_DAD->E1_ZZGRP
		QRY_DAD->(DbSkip())
	ENDDO

	QRY_DAD->(DbCloseArea())

	IF LEN(aRetMail) > 0
		/* Imprime Ultimo registro */
		_cBody := FCOB04C(aRetMail,aRetMail[1][15],aRetMail[1][16])  //Corpo do E-mail Titulos a Vencer (Preventivo)

		FBuscaGrupo(cGrupoAnt)
		//Dispara E-mail para todos os usuários do Grupo
		For nI := 1 TO LEN(_aEMAIL)

			lEnvMail := U_VDEVMAIL(_aEMAIL[nI][1],cCopia,_cAssunto,_cBody,aAnexos)

		Next

		cLogMsg := "-------------------------------------------------------------------------------" + CRLF
		cLogMsg += " ZJOBFIN1 -  JOB ENVIO DE E-MAIL RELAÇÃO TITULOS EM ATRASO -  FIM              " + CRLF
		cLogMsg += " Empresa: " + _cEmp  														    + CRLF
		cLogMsg += " Filial : " + _cFil  													    	+ CRLF
		cLogMsg += " Término: " + DTOC(DATE()) + " Hora: " + subs(time(),1,5)                        + CRLF
		cLogMsg += "-------------------------------------------------------------------------------" + CRLF

		U_ZGERALOG(cLogMsg)
	Endif
RETURN
/*
 * Funcao............: QACOB04B
 * Parametros........: aTitulo 	- Titulos a ser impresso no e-mail
 *					   _aTit	- Vetor com todos os títulos selecionados.
 *
 * Retorno...........: Texto do e-mail para titulos Vencidos 
 *
 * Responsável.......: Abel Ribeiro
 * Data..............: 29/05/2024
 * Objetivo..........: e-mail Cobrança para titulos Vencidos
*/

Static Function FCOB04C(_aTit,cCusto,cDesc)
	Local _cBody := ""
	Local _nNxt		:= 0



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
	_cBODY += '				<strong>Prezados,</strong> ' + CRLF
	_cBODY += '				<p>Segue a listagem de Clientes em Atraso.</p> ' + CRLF
	_cBODY += '				<p>	</p> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<!-- Tabela --> ' + CRLF
	_cBODY += '				</span> ' + CRLF
	_cBODY += "				<span style='font-weight: bold;'>Centro de Custo: &nbsp; <strong> <span style='color: #339966;'> "+ cCusto + " - </strong> " + CRLF
	_cBODY += " 			&nbsp; " + cDesc+" </span> </p> " + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += "<!-- Tabela -->" + CRLF
	_cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>" + CRLF
	_cBODY += "               <thead>"

	_cBODY += "                  <tr>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Codigo/Loja</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Razão Social</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nota Fiscal</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Parcela</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Dias de Atraso</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Valor</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Saldo</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Representante</th>"
	_cBODY += "                  </tr>"
	_cBODY += "               </thead>"
	_cBODY += "               <tbody>"


	For _nNxt := 1 to Len(_aTit)

		_cBody   += "<tr>" + CRLF

		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" +  _aTIT[_nNxt,6]+" / "+_aTIT[_nNxt,15]+"</td>"     + CRLF                               + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" +_aTIT[_nNxt,5]+" </td>"     + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + _aTIT[_nNxt,17]+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" +  _aTIT[_nNxt,7]+" / "+_aTIT[_nNxt,18]+"</td>"     + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + cvaltochar(_aTIT[_nNxt,12])    + "</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;"  + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,10], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" + GETMV("MV_SIMB1")+"  "+Alltrim(Transform(_aTIT[_nNxt,11], PesqPict("SE1","E1_VALOR")))+"</td>"    + CRLF
		_cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>&nbsp;" +Posicione("SA3",1,xFilial("SA3")+_aTIT[_nNxt,19],"A3_NOME")+" " + CRLF
		IF !Empty(_aTIT[_nNxt,20])
			_cBody   += " <br> &nbsp;" +Posicione("SA3",1,xFilial("SA3")+_aTIT[_nNxt,20],"A3_NOME")+" "
		Endif
		IF !Empty(_aTIT[_nNxt,21])
			_cBody   += "<br> &nbsp;" +Posicione("SA3",1,xFilial("SA3")+_aTIT[_nNxt,21],"A3_NOME")+" "
		Endif
		IF !Empty(_aTIT[_nNxt,22])
			_cBody   += " <br> &nbsp;" +Posicione("SA3",1,xFilial("SA3")+_aTIT[_nNxt,22],"A3_NOME")+" "
		Endif
		IF !Empty(_aTIT[_nNxt,23])
			_cBody   += " <br> &nbsp;" +Posicione("SA3",1,xFilial("SA3")+_aTIT[_nNxt,23],"A3_NOME")+" "
		Endif
		_cBody   += "</td>"    + CRLF
		_cBody   += "</tr>   "+ CRLF

	Next


	_cBODY += '					</tbody> ' + CRLF
	_cBODY += '				</table> ' + CRLF
	_cBODY += '				<br /> ' + CRLF

	_cBODY += '				<!-- Aviso Legal --> ' + CRLF
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Aviso Legal:</strong> ' + CRLF
	_cBODY += '				 Esse e-mail e quaisquer arquivos transmitidos com ele são confidenciais e destinados exclusivamente <br/> ' + CRLF
	_cBODY += '				 para uso pelo indivíduo ou pela entidade a quem estão endereçados. ' + CRLF
	_cBODY += '				Se você recebeu este e-mail por engano, notifique o administrador do sistema." <br/> ' + CRLF
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

/* Pesquisa na tabela Z21 os E-mails dos Responsáveis */
Static Function FBuscaGrupo(cGrupo)

	dbSelectArea("Z21")

	Z21->(dbSetOrder(1))
	If  Z21->(DBSEEK(xFilial("Z21") + cGrupo ))

		While Z21->(!EOF()) .And.  Z21->Z21_GRUPO = cGrupo

			IF !Empty(USRRetMail(Z21->Z21_CODUSR))

				IF Ascan(_aEMAIL, { |x| x[1] == USRRetMail(Z21->Z21_CODUSR) }) == 0
					AADD( _aEmail,{USRRetMail(Z21->Z21_CODUSR) } )
				Endif
			Endif
			Z21->(dbSkip(1))
		ENDDO

	Endif
Return
