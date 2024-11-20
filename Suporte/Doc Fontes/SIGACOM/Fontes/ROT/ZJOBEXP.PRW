#INCLUDE "PROTHEUS.CH"
#include 'tbiconn.ch'
#include 'topconn.ch'
#include 'AP5MAIL.ch'

/*/{Protheus.doc} ZJOBEXPA
DISPARA E_MAIL PARA OS PRODUTOS HOMOLOGADOS VENCIDOS > 3 ANOS
@author TOTVS Protheus
@since 26/06/2024
@version 1.0 
@type function
@revision Wagner Neves
/*/
USER FUNCTION ZJOBEXPA(cPar)
	Local nFil
	Local nEmp
	Local cFilBck     := cFilAnt
	Local cEmpBck     := cEmpAnt
	Private lJobPvt   := .F.
	Private _cEmp     := "01"
	Private _cFil     := "01"
	Private cMsgLog   := ""
	Private aEmpAux   := FWAllGrpCompany()
	Private aFilAux   := {}

	For nEmp := 1 To Len(aEmpAux)
		cEmpAnt	:= aEmpAux[nEmp]
		aFilAux   	:= FWAllFilial()
		For nFil := 1 To Len(aFilAux)
			cFilAnt := aFilAux[nFil]
			_cEmp   := aEmpAux[nEmp]
			_cFil   := aFilAux[nFil]
			//Se o ambiente não estiver em pé, sobe para usar de maneira automática
			If Select("SX2") == 0
				lJobPvt := .T.
				lContinua := .T.

				cMsgLog+= "-------------------------------------------------------------------------------" + CRLF
				cMsgLog+= " ROTINA: ZJOBEXPA  -  JOB VERIFICA DATA DE HOMOLOGAÇÂO PRODUTOS FABRICANTES    " + CRLF
				cMsgLog+= " Empresa: " + _cEmp + CRLF
				cMsgLog+= " Filial : " + _cFil + CRLF
				cMsgLog+= " Inicio : " + DTOC(DATE()) + ' - ' + subs(time(),1,5)                            + CRLF
				cMsgLog+= "-------------------------------------------------------------------------------"

				U_ZGERALOG(cMSGLOG)

				RpcClearEnv()
				RPCSetType( 3 )     // Não consome licensa de uso
				RPCSetEnv(_cEmp, _cFil, "", "", "", "")

				PROCDAD(cPAR)
			EndIf
		Next
		nFil	:= 1
	Next

	cEmpAnt := cEmpBck
	cFilAnt := cFilBck

RETURN

Static Function ProcDad(cPAR)
	Local I,nZ,Nx
	Local cAssunto1   := "Aviso de vencimento cliente x Fornecedor x Fabricante."
	Local cAssunto2   := "Aviso de Vencimento Produto x Fornecedor x fabricante. "
	Private cBODY     := " "
	Private nDiasPexp := SuperGetMV('ZZ_PRZVCEX', .F. ,90)                 //Dias vencimento data de Expiração default 90 Dias
	Private nDiasPHom := SuperGetMV('ZZ_PRZVCHM', .F. ,90)                 //Dias vencimento data de Homologação defalut 90 dias
	Private cLista  	:= SuperGetMV('ZZ_GRPMAIL', .F. ,"000000")           //caso o parametro esteja vazio manda somente para o administrador
	Private nPrzEnvio	:= SuperGetMV('ZZ_PRZENVM', .F. ,30)                 //Dias vencimento data de Expiração default 90 Dias

	Private aDados1   := {}
	Private aDados2   := {}
	Private lEnvMail  := .F.
	Private cCopia    := ""
	Private aAnexos   := {}
	DEFAULT cPar      := '1'

	aLISMail := SEPARA(cLista,";")

	//Dispara E-mails com prazo data de expiração Expirado

	IF cPAR == '1'

		cQUERY := "SELECT " + CRLF
		cQUERY += " A5_PRODUTO,A5_NOMPROD,A5_NOMEFOR,A5_FORNECE,A5_LOJA,A5_FABR,A5_FALOJA,A2_NOME,A5_ZZDTEXP,A5_ZZHOMOL,A5_ZZENVEX,"      + CRLF
		cQuery += " SA5.R_E_C_N_O_ as NRECSA5, DATEDIFF(DAY,GETDATE(),A5_ZZDTEXP) AS nDias FROM "+RETSQLNAME("SA5")+ " SA5 (NOLOCK),"+ RETSQLNAME("SA2")+" SA2 (NOLOCK) " + CRLF
		cQUERY += " WHERE "                                                + CRLF
		cQUERY += "    SA5.A5_FILIAL  = '" + xFilial("SA5") + "' AND "     + CRLF
		// cQUERY += "    SA5.A5_ZZENVEX  IN (' ','2') AND "                  + CRLF   //Email Não enviado
		cQUERY += "    SA5.A5_ZZHOMOL  = '1'        AND "                  + CRLF   //Somente os Homologados
		cQUERY += "    SA2.A2_COD  = SA5.A5_FABR    AND "                  + CRLF
		cQUERY += "    SA2.A2_LOJA = SA5.A5_FALOJA  AND "                  + CRLF
		cQUERY += "    SA5.A5_FABR <> ' '           AND "                  + CRLF
		cQUERY += "    SA2.D_E_L_E_T_  = ' '        AND "                  + CRLF
		cQUERY += "    SA5.D_E_L_E_T_ = ' ' "                              + CRLF
		cQUERY += "    ORDER BY A5_ZZDTEXP,A5_FORNECE,A5_LOJA,A5_FABR,A5_FALOJA,A5_PRODUTO "                              + CRLF

		DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY_SA5", .F., .T.)

		TcSetField("QRY_SA5","A5_ZZDTEXP","D",8,0)

		DBSelectArea("QRY_SA5")
		QRY_SA5->(DBGoTop())


		While QRY_SA5->(!EOF())

			nResta := QRY_SA5->nDias
			//nREG++
			//IF nResta <= nPrzEnvio
			if QRY_SA5->A5_ZZDTEXP <= date()
				AADD( aDados1,{QRY_SA5->A5_FORNECE+"/"+QRY_SA5->A5_LOJA,QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,"LICENCA",QRY_SA5->A5_ZZDTEXP,nResta,QRY_SA5->nRECSA5 } )
				// AADD( aDados1,{ QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,QRY_SA5->A5_NOMPROD,QRY_SA5->A5_ZZDTEXP,QRY_SA5->nRECSA5 } )
			Elseif daysum(date(),nDiasPexp) ==QRY_SA5->A5_ZZDTEXP
				AADD( aDados1,{QRY_SA5->A5_FORNECE+"/"+QRY_SA5->A5_LOJA,QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,"LICENCA",QRY_SA5->A5_ZZDTEXP,nResta,QRY_SA5->nRECSA5 } )
			ENDIF
			QRY_SA5->(dbSkip(1) )
		ENDDO

	ELSEIF cPar == '2'  // Dispara E-mails com prazo de homologação a Vencer
		//cDataAux :=  DtoS( DATE()) - 90
		cQUERY := "SELECT " + CRLF
		cQUERY += " A5_PRODUTO,A5_NOMPROD,A5_NOMEFOR,A5_FORNECE,A5_LOJA,A5_FABR,A5_FALOJA,A2_NOME,A5_ZZDTHOM,A5_ZZHOMOL,A5_ZZENVEX,A5_ZZENVHM, "      + CRLF
		//cQUERY   += " A5_PRODUTO,A5_NOMPROD,A5_NOMEFOR,A5_LOJA,A5_FABR,A5_FALOJA,A2_NOME,A5_ZZDTHOM,A5_ZZHOMOL,A5_ZZENVHM,"      + CRLF
		cQuery   += " SA5.R_E_C_N_O_ as NRECSA5, DATEDIFF(DAY,GETDATE(),A5_ZZDTHOM) AS nDias FROM "+RETSQLNAME("SA5")+ " SA5 (NOLOCK),"+ RETSQLNAME("SA2")+" SA2 (NOLOCK) " + CRLF
		cQUERY   += " WHERE SA5.A5_FILIAL = '" + xFilial("SA5") + "' AND " + CRLF
		cQUERY   += "      SA5.A5_ZZENVHM  IN (' ','2') AND "              + CRLF   //Email Não enviado
		cQUERY   += "      SA5.A5_ZZHOMOL  = '1'     AND "                 + CRLF   //Somente os Homologados
		cQUERY   += "    SA2.A2_COD = SA5.A5_FABR    AND "                 + CRLF
		cQUERY   += "    SA2.A2_LOJA = SA5.A5_FALOJA AND "                 + CRLF
		cQUERY   += "    SA5.A5_FABR<> ' '  AND "                            + CRLF
		cQUERY   += "    SA5.D_E_L_E_T_ = ' '        AND "                + CRLF
		cQUERY   += "    SA2.D_E_L_E_T_  = ' '  "                          + CRLF
		cQUERY += "    ORDER BY A5_ZZDTHOM,A5_FORNECE,A5_LOJA,A5_FABR,A5_FALOJA,A5_PRODUTO "                              + CRLF

		DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY_SA5", .F., .T.)

		TcSetField("QRY_SA5","A5_ZZDTHOM","D",8,0)

		DBSelectArea("QRY_SA5")
		QRY_SA5->(DBGoTop())

		While QRY_SA5->(!EOF())
			nResta := QRY_SA5->nDias
			//nREG++
			if QRY_SA5->A5_ZZDTHOM <= date()
				//IF nResta <= nDiasPHom
				AADD( aDados2,{QRY_SA5->A5_FORNECE+"/"+QRY_SA5->A5_LOJA,QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,"LICENCA",QRY_SA5->A5_ZZDTHOM,nResta,QRY_SA5->nRECSA5 } )
				// AADD( aDados2,{ QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,QRY_SA5->A5_NOMPROD,QRY_SA5->A5_ZZDTHOM,QRY_SA5->nRECSA5} )
			Elseif  daysum(date(),nDiasPHom) == QRY_SA5->A5_ZZDTHOM
				AADD( aDados2,{QRY_SA5->A5_FORNECE+"/"+QRY_SA5->A5_LOJA,QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,"LICENCA",QRY_SA5->A5_ZZDTHOM,nResta,QRY_SA5->nRECSA5 } )
			ENDIF
			QRY_SA5->(dbSkip(1) )
		ENDDO

	ELSEIF cPar == '3'  // Altera o Campo Homologado para não após data vencidade.

		cQUERY := "SELECT " + CRLF
		cQUERY   += " A5_PRODUTO,A5_NOMPROD,A5_NOMEFOR,A5_LOJA,A5_FABR,A5_FALOJA,A2_NOME,A5_ZZDTHOM,A5_ZZHOMOL,A5_ZZENVHM,"      + CRLF
		cQuery   += " SA5.R_E_C_N_O_ as NRECSA5, DATEDIFF(DAY,GETDATE(),A5_ZZDTHOM) AS nDias FROM "+RETSQLNAME("SA5")+ " SA5 (NOLOCK),"+ RETSQLNAME("SA2")+" SA2 (NOLOCK) " + CRLF
		cQUERY   += " WHERE SA5.A5_FILIAL = '" + xFilial("SA5") + "' AND " + CRLF
		cQUERY   += "      SA5.A5_ZZENVHM  = '1' AND "              + CRLF   //Email Não enviado
		cQUERY   += "      SA5.A5_ZZHOMOL  = '1'     AND "                 + CRLF   //Somente os Homologados
		cQUERY   += "    SA2.A2_COD = SA5.A5_FABR    AND "                 + CRLF
		cQUERY   += "    SA2.A2_LOJA = SA5.A5_FALOJA AND "                 + CRLF
		cQUERY   += "    SA5.A5_FABR<> ' '  AND "                            + CRLF
		cQUERY   += "    SA5.D_E_L_E_T_ = ' '        AND "                + CRLF
		cQUERY   += "    SA2.D_E_L_E_T_  = ' '  "                          + CRLF

		DbUseArea(.T.,"TOPCONN", TCGENQRY(,,cQuery),"QRY_SA5", .F., .T.)

		TcSetField("QRY_SA5","A5_ZZDTHOM","D",8,0)

		DBSelectArea("QRY_SA5")
		QRY_SA5->(DBGoTop())

		While QRY_SA5->(!EOF())

			//nREG++
			if QRY_SA5->A5_ZZDTHOM > date()

				dbselecTarea("SA5")
				SA5->(DBGOTO(QRY_SA5->nRECSA5))
				SA5->(RecLock("SA5",.F.))
				SA5->A5_ZZHOMOL	:= '2'
				SA5->(MsUnlock())
				//IF nResta <= nDiasPHom
				// AADD( aDados2,{ QRY_SA5->A5_NOMEFOR,QRY_SA5->A5_FABR+"/"+QRY_SA5->A5_FALOJA,QRY_SA5->A2_NOME,QRY_SA5->A5_PRODUTO,QRY_SA5->A5_NOMPROD,QRY_SA5->A5_ZZDTHOM,QRY_SA5->nRECSA5} )
			ENDIF
			QRY_SA5->(dbSkip(1) )
		ENDDO



	Endif

	IF Len(aDados1) > 0

		For nZ := 1 TO LEN(aLisMail)

			cTO := UsrRetMail(aLisMail[nZ])     //Busca E-mail cadastroo de Usuários Protheus, conforme informado nos parametros
			IF !Empty(cTO)                     // Se Campo E-mail estiver vazio, não envio



				cBODY := "<!DOCTYPE html>"
				cBODY += "<html lang='pt-BR'>"
				cBODY += "<head>"
				cBODY += "   <meta charset='UTF-8'>"
				cBODY += "   <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
				cBODY += "</head>"
				cBODY += "<body style='font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;'>"
				cBODY += "   <div style='width: 100%; margin: 0 auto; background-color: #ffffff; border: 1px solid #ddd;'>"
				cBODY += "      <!-- Cabeçalho do E-mail -->"
				cBODY += "      <div style='background-color: #005f27; padding: 20px; color: white; text-align: left;'>"
				cBODY += "            <h1 style='margin: 0;'><img src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1>"
				cBODY += "      </div>"
				cBODY += "<!-- Corpo do E-mail -->"
				cBODY += "      <div style='padding: 20px;'>"
				cBODY += "            <p>Prezados,</p>"
				cBODY += "            <p>Informamos que a data de Expiração do Produto x Fornecedor x Fabricante irá vencer nos próximos dias.</p>"
				cBODY += "<!-- Tabela -->"
				cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>"
				cBODY += "               <thead>"
				cBODY += "                  <tr>"
				cBODY += "                        <th colspan='2' style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Fornecedor</th>"
				cBODY += "                        <th colspan='2' style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Fabricante</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"
				//cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"


				cBODY += "                  </tr>"
				cBODY += "                  <tr>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Código/Loja</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Razão Social</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Código/Loja</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Razão Social</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Produto</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Expiração</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Dias para Vencer</th>"
				cBODY += "                  </tr>"
				cBODY += "               </thead>"
				cBODY += "               <tbody>"


				For I := 1 TO LEN(aDados1)

					iF aDados1[I][8] > 0
						cBODY += "                  <tr>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][1]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][2]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][3]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][4]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][5]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+DTOC(aDados1[I][7])+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+cValtochar(aDados1[I][8])+"</td>"
						cBODY += "                  </tr>"
					else
						cBODY += "                  <tr>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][1]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][2]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][3]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][4]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados1[I][5]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+DTOC(aDados1[I][7])+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+cValtochar(aDados1[I][8])+"</td>"
						cBODY += "                  </tr>"
					Endif
				Next


				cBODY += "               </tbody>"
				cBODY += "            </table>"
				cBODY += "            <!-- Aviso Legal -->"
				cBODY += "            <p style='font-size: 12px; color: #555; margin-top: 20px;'>"
				cBODY += "               <strong>Aviso Legal:</strong> Este e-mail e quaisquer arquivos transmitidos com ele são confidenciais e destinados exclusivamente para uso pelo indivíduo ou pela entidade a quem estão endereçados. Se você recebeu este e-mail por engano, notifique o administrador do sistema."
				cBODY += "            </p>"
				cBODY += "      </div>"
				cBODY += "   </div>"
				cBODY += "  <div style='background-color: #005f27; padding: 20px; color: white; text-align: center;'> "
				cBODY += "   <h1 style='margin: 0;'><img alt='' src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1> "
				cBODY += "     </div>"
				cBODY += "</body>"
				cBODY += "</html>"

				lEnvMail := U_VDEVMAIL(cTO,cCopia,cAssunto1,cBody,aAnexos)
			else
				cMsgLog := "----------------------------------------------------------------------------------------------" + CRLF
				cMsgLog += " ROTINA: ZJOBEXPA  -  JOB VERIFICA DATA DE EXPIRAÇÂO PRODUTOS X FABRICANTES                   " + CRLF
				cMsgLog += " Empresa: " + _cEmp                                                                             + CRLF
				cMsgLog += " Filial : " + _cFil                                                                             + CRLF
				cMsgLog += " *** E_Mail Usuário "+aLisMail[Nz]+" não Preenchido, Cadastro de Usuários . Verifique com TI.***" + CRLF
				cMsgLog += " FIM    : " + DTOC(DATE()) + ' - ' + subs(time(),1,5)                                           + CRLF
				cMsgLog += "----------------------------------------------------------------------------------------------" + CRLF
				U_ZGERALOG(cMsgLog)
			ENDIF
		NEXT

		//Atualiza status de email enviado

		For I := 1 TO LEN(aDADOS1)
			dbselecTarea("SA5")
			SA5->(DBGOTO(aDados1[I][9]))
			SA5->(RecLock("SA5",.F.))
			SA5->A5_ZZENVEX := '1'
			SA5->(MsUnlock())
		Next

	ENDIF

	IF Len(aDados2) > 0

		For nX := 1 TO LEN(aLisMail)

			cTO := UsrRetMail(aLisMail[nX])     //Busca E-mail cadastroo de Usuários Protheus, conforme informado nos parametros

			IF !Empty(cTO)
				cBODY := "<!DOCTYPE html>"
				cBODY += "<html lang='pt-BR'>"
				cBODY += "<head>"
				cBODY += "   <meta charset='UTF-8'>"
				cBODY += "   <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
				cBODY += "</head>"
				cBODY += "<body style='font-family: Arial, sans-serif; margin: 0; padding: 0; background-color: #f4f4f4;'>"
				cBODY += "   <div style='width: 100%; margin: 0 auto; background-color: #ffffff; border: 1px solid #ddd;'>"
				cBODY += "      <!-- Cabeçalho do E-mail -->"
				cBODY += "      <div style='background-color: #005f27; padding: 20px; color: white; text-align: left;'>"
				cBODY += "            <h1 style='margin: 0;'><img src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1>"
				cBODY += "      </div>"
				cBODY += "<!-- Corpo do E-mail -->"
				cBODY += "      <div style='padding: 20px;'>"
				cBODY += "            <p>Prezados,</p>"
				cBODY += "            <p>Informamos que a data de Homologação do Produto x Fornecedor x Fabricante irá vencer nos próximos dias.</p>"
				cBODY += "<!-- Tabela -->"
				cBODY += "            <table style='width: 100%; border-collapse: collapse; table-layout: auto; margin-top: 10px; border-color:#005f27;'>"
				cBODY += "               <thead>"
				cBODY += "                  <tr>"
				cBODY += "                        <th colspan='2' style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Fornecedor</th>"
				cBODY += "                        <th colspan='2' style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Fabricante</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>""
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"
				//cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'></th>"


				cBODY += "                  </tr>"
				cBODY += "                  <tr>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Código/Loja</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Razão Social</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Código/Loja</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Razão Social</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Produto</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Homologação</th>"
				cBODY += "                        <th style='border: 1px solid #005f27; padding: 8px; text-align: left; background-color: #005f27; color: white;'>Dias para Vencer</th>"
				cBODY += "                  </tr>"
				cBODY += "               </thead>"
				cBODY += "               <tbody>"


				For I := 1 TO LEN(aDados2)

					iF aDados2[I][8] > 0
						cBODY += "                  <tr>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][1]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][2]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][3]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][4]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][5]+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+DTOC(aDados2[I][7])+"</td>"
						cBODY += "<td style='border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+cValtochar(aDados2[I][8])+"</td>"
						cBODY += "                  </tr>"
					else
						cBODY += "                  <tr>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][1]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][2]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][3]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][4]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+aDados2[I][5]+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+DTOC(aDados2[I][7])+"</td>"
						cBODY += "<td style='background-color: #f8d7da; border: 2px solid #005f27; padding: 8px; text-align: left; word-break: break-word;'>"+cValtochar(aDados2[I][8])+"</td>"
						cBODY += "                  </tr>"
					Endif
				Next


				cBODY += "               </tbody>"
				cBODY += "            </table>"
				cBODY += "            <!-- Aviso Legal -->"
				cBODY += "            <p style='font-size: 12px; color: #555; margin-top: 20px;'>"
				cBODY += "               <strong>Aviso Legal:</strong> Este e-mail e quaisquer arquivos transmitidos com ele são confidenciais e destinados exclusivamente para uso pelo indivíduo ou pela entidade a quem estão endereçados. Se você recebeu este e-mail por engano, notifique o administrador do sistema."
				cBODY += "            </p>"
				cBODY += "      </div>"
				cBODY += "   </div>"
				cBODY += "  <div style='background-color: #005f27; padding: 20px; color: white; text-align: center;'> "
				cBODY += "   <h1 style='margin: 0;'><img alt='' src='https://vidara.com/themes/custom/paltana/images/logos/logo.svg' /></h1> "
				cBODY += "     </div>"
				cBODY += "</body>"
				cBODY += "</html>"

				lEnvMail := U_VDEVMAIL(cTO,cCopia,cAssunto2,cBody,aAnexos)
			ELSE
				cMsgLog := "----------------------------------------------------------------------------------------------" + CRLF
				cMsgLog += " ROTINA: ZJOBEXPA  -  JOB VERIFICA DATA DE EXPIRAÇÂO PRODUTOS X FABRICANTES                   " + CRLF
				cMsgLog += " Empresa: " + _cEmp                                                                             + CRLF
				cMsgLog += " Filial : " + _cFil                                                                             + CRLF
				cMsgLog += " *** E_Mail Usuário "+aLISMail[nX]+" não Preenchido, Cadastro de Usuários . Verifique com TI.***" + CRLF
				cMsgLog += " FIM    : " + DTOC(DATE()) + ' - ' + subs(time(),1,5)                                           + CRLF
				cMsgLog += "----------------------------------------------------------------------------------------------" + CRLF
				U_ZGERALOG(cMsgLog)
			ENDIF
		NEXT nX

		//Atualiza status de email enviado
		For I := 1 TO LEN(aDados2)

			dbselecTarea("SA5")
			SA5->(DBGOTO(aDados2[I][9]))
			SA5->(RecLock("SA5",.F.))
			SA5->A5_ZZENVHM	:= '1'
			//SA5->A5_ZZHOMOL	:= '2'    //Altera status da Homologação para 2=(não Homologado)
			SA5->(MsUnlock())

		NEXT

	ENDIF

	cMsgLog := "-------------------------------------------------------------------------------" + CRLF
	cMsgLog += " ROTINA: ZJOBEXPA  -  JOB VERIFICA DATA DE HOMOLOGAÇÂO PRODUTOS FABRICANTES    " + CRLF
	cMsgLog += " Empresa: " + _cEmp                                                              + CRLF
	cMsgLog += " Filial : " + _cFil                                                              + CRLF
	cMsgLog += " *** TERMINO DE EXECUÇÂO NORMAL ***"                                             + CRLF
	cMsgLog += " FIM    : " + DTOC(DATE()) + ' - ' + subs(time(),1,5)                            + CRLF
	cMsgLog += "-------------------------------------------------------------------------------"
	U_ZGERALOG(cMsgLog)
   /* reseta AMbiente */  
	RpcClearEnv()

RETURN
