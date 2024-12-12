//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

/*/{Protheus.doc} Z_JOBPEDL
Funcao de envio de email de pedidos liberados para separcao
@author Wagner Neves
@since 11/12/2024
@parameters
@return
@version 1.0
/*/
User Function Z_JOBPEDL()
    Local lContinua     := .F.
    Local nFil
	Local nEmp
	Local cFilBck       := cFilAnt
	Local cEmpBck       := cEmpAnt
	Private lJobPvt     := IsBlind() .Or. Empty(AllTrim(FunName()))
	Private _cEmp       := ""
	Private _cFil       := ""
	Private aEmpAux     := FWAllGrpCompany()
	Private aFilAux     := {}

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

				RpcClearEnv()
				RPCSetType( 3 )     // Não consome licensa de uso
				_cEmp	:= aParams[01]
				_cFil	:= aParams[02]
				RPCSetEnv(_cEmp, _cFil, "", "", "", "")
			EndIf

			//Se for continuar, faz a chamada para o disparo do e-Mail
			If lContinua
                If lJobPvt
					Processa( fProcDad() )
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

/*---------------------------------------------------------------------*
 | Func:  fProcDad                                                     |
 | Desc:  Função processa dados para enviar por email 			       |
 *---------------------------------------------------------------------*/
Static Function fProcDad()
    Local cQryDados := ''
    Local cFrom     := SuperGetMV("MV_RELFROM",,"" )
    Local cTo       := SuperGetMV("ZZ_MAILPED",,"" )
    Local cSubject  := ""
    Local cBody     := ""
    Local cFilNome  := ""
    Local aDados    := {}

	//Busca titulos atraves dos parametros
	cQryDados := " SELECT SC9.C9_PEDIDO,SC9.C9_FILIAL,SC9.C9_CLIENTE,SC9.C9_LOJA, "
	cQryDados +=  " SC9.C9_ZZDTLIB," + CRLF
	cQryDados +=  " SC9.C9_ZZHRLIB," + CRLF
	cQryDados +=  " SC9.C9_ZZUSLIB," + CRLF
    cQryDados +=  " SC9.R_E_C_N_O_ AS C9RECNO, "
 	cQryDados +=  " C6.C6_ENTREG," + CRLF
	cQryDados +=  " (SELECT A1.A1_NOME FROM " + RetSqlName("SA1") + " A1 WHERE A1.A1_COD = SC9.C9_CLIENTE) AS NOME" + CRLF
	cQryDados +=  " FROM "+RetSqlName("SC9")+" SC9 "
	cQryDados +=  "INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SC6") + " C6 (NOLOCK) " + CRLF
	cQryDados +=  " ON C6.C6_FILIAL = SC9.C9_FILIAL" + CRLF
	cQryDados +=  " AND C6.C6_NUM = SC9.C9_PEDIDO" + CRLF
	cQryDados +=  " AND C6.C6_ITEM = SC9.C9_ITEM" + CRLF
	cQryDados +=  " AND C6.D_E_L_E_T_ = ' '" + CRLF
	cQryDados +=  " INNER JOIN" + CRLF
	cQryDados +=  " " + RetSqlName("SF4") + " F4 (NOLOCK) " + CRLF
	cQryDados +=  " ON F4.F4_FILIAL = '"+xFilial("SF4")+"'" + CRLF
	cQryDados +=  " AND F4.F4_CODIGO = C6.C6_TES" + CRLF		
	cQryDados +=  " WHERE SC9.C9_FILIAL = '" + xFilial("SC9") + "' AND " + CRLF
	cQryDados +=  " F4.F4_ESTOQUE = 'S' AND " + CRLF
	cQryDados += " SC9.C9_BLCRED = ' '" + CRLF
    cQryDados += " AND SC9.C9_BLEST = ' '" + CRLF
	cQryDados += " AND SC9.C9_ZZFASE = 'A'" + CRLF
    cQryDados += " AND SC9.C9_ZZENVMA = ' '" + CRLF
	cQryDados += " AND SC9.D_E_L_E_T_ = ' '" 
	cQryDados += " ORDER BY SC9.C9_FILIAL,SC9.C9_PEDIDO,SC9.C9_PRODUTO,SC9.C9_CLIENTE,SC9.C9_LOJA "
	PLSQuery(cQryDados, 'QRYDADTMP')

	//Definindo o tamanho da régua
	DbSelectArea('QRYDADTMP')
	Count to nTotal
	QRYDADTMP->(DbGoTop())

	//Enquanto houver registros, adiciona na temporária
	While !QRYDADTMP->(EoF())
		SC5->(DbSetOrder(1))
        If SC5->(DbSeek(xFilial("SC5")+QRYDADTMP->C9_PEDIDO))
            CTT->(DbSetOrder(1))
			If CTT->(DbSeek(xFilial("SC5")+SC5->C5_ZZCC))
				If CTT->CTT_ZZNPED = "1"
               		aAdd(aDados,{QRYDADTMP->C9_PEDIDO,;        //1
                        AllTrim(QRYDADTMP->C9_CLIENTE)+"/"+AllTrim(QRYDADTMP->C9_LOJA),;           //2
                        QRYDADTMP->NOME,;       //3
                        Dtoc(QRYDADTMP->C9_ZZDTLIB),;       //4
                        Dtoc(QRYDADTMP->C6_ENTREG),;          //5
                        AllTrim(QRYDADTMP->C9_ZZUSLIB)+" - "+ AllTrim(SC5->C5_ZZCC)})     //6

                        SC9->(DbGoTo(QRYDADTMP->C9RECNO))
                        RecLock("SC9", .F.)
                        SC9->C9_ZZENVMA := "X"
                        SC9->(MsUnlock())
				EndIf
			EndIf
        EndIf
        QRYDADTMP->(DbSkip())
    EndDo
    QRYDADTMP->(DbCloseArea())

    //Verifica se encontrou titulos
    If !Empty(aDados)
        If ExistBlock("Z_EnvMail") .AND. !Empty(cFrom) .AND. !Empty(cTo)
        cFilNome    := FwFilialName( cEmpAnt, cFilAnt, 1 )
        cSubject    := "[Vidara] - "+AllTrim(cFilNome)+"- Notificação de Pedidos Liberados"

        cBody	:= fGeraBody(aDados)

        U_Z_EnvMail(cFrom,cTo,cSubject,cBody)
        // U_VDEVMAIL(cTo,"",cSubject,cBody)
        
        EndIf
    EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  fGeraBody                                                    |
 | Desc:  Função para gera body para envio de email 			       |
 *---------------------------------------------------------------------*/
Static Function fGeraBody(_aTit)
	Local _cBody    := ""
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
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<p>Informamos que os pedidos abaixo foram liberados e estão disponiveis para separação</p> ' + CRLF
	_cBODY += '				<p></p> ' + CRLF
	_cBODY += '				<!-- Tabela --> ' + CRLF
	_cBODY += '				</span> ' + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += '				<br /> ' + CRLF
	_cBODY += "<!-- Tabela -->" + CRLF
	_cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>" + CRLF
	_cBODY += "               <thead>"

	_cBODY += "                  <tr>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Num. Pedido</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Código/Loja</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Nome Cliente</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Data de Liberação</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Data de Entrega</th>"
	_cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Usurio/Centro de Custo da Liberação</th>"
	_cBODY += "                  </tr>"
	_cBODY += "               </thead>"
	_cBODY += "               <tbody>"

    For _nNxt := 1 to Len(_aTit)
        _cBody   += "<tr>" + CRLF

        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,01]+"</td>"     + CRLF                               + CRLF
        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,02]+" </td>"     + CRLF
        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,03]+"</td>"    + CRLF
        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,04]    + "</td>"    + CRLF
        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>" + _aTIT[_nNxt,05]   + "</td>"        + CRLF
        _cBody   += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"  + _aTIT[_nNxt,06] +"</td>"    + CRLF
        _cBody   += "</tr>   "+ CRLF

    Next

	_cBODY += '					</tbody> ' + CRLF
	_cBODY += '				</table> ' + CRLF
	_cBODY += '				<br /> ' + CRLF

	_cBODY += '				<!-- Aviso Legal --> ' + CRLF
	_cBODY += '				<p style="font-size: 11px; color: #555; margin-top: 20px;"> <strong>Aviso Legal:</strong> ' + CRLF
	_cBODY += '				"Esse e-mail e quaisquer arquivos transmitidos com ele são confidenciais e destinados exclusivamente para uso pelo individuo ou pela entidade a quem estão endereçados. Se Você recebeu este e-mail por engano, notifique o administrador do sistema." ' + CRLF
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
