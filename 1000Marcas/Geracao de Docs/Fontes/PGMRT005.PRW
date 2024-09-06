#INCLUDE "protheus.ch"
#INCLUDE "colors.ch"
#INCLUDE "font.ch"
#INCLUDE "topconn.ch"

/*/{Protheus.doc} PGMRT005
Função de envio de documentos via Job
@author Wagner Neves
@since 03/06/2024
@version 1.0
@type function
/*/
User Function PGMRT005()
    Local aArea     := GetArea()
    Local cQuery    := ""
    Local cAliasSF2 := GetNextAlias()
    Local cCGC      := ""
    Local cA1Email  := ""
    Local cAIEmail  := ""
    Local cPath     := ""
    Local cHtml     := ""
    Local cDoc      := ""
    Local cSerie    := ""
    Local lEnvio    := .F.
    Local cEmail    := ""
    Local cAssunto  := ""
    Local cRecCob   := ""
    Local cTipoDoc  := ""
    Local nX
    Local aFileFun  := {}
    Local aAnexos   := {}
    Local cDataIni  := SuperGetMv("MV_ZWFCOB4",.F.,"20240501")
    Local cPasta    := SuperGetMv("MV_ZWFCOB1",.F.,"\AnexosCb\")
    Private lJob	:= ( GetRemoteType() == -1 )	// Identifica que não foi iniciado por SMARTCLIENT
	// Default cDoc	:= PadR("000295242"	, TamSX3('F2_DOC')[1]) //VM Teste
	// Default cSerie  := PadR("001"		, TamSX3('F2_SERIE')[1]) //VM Teste

	IF lJob
		cEmpInt := "01"
		cFilInt := "01"

		RpcClearEnv()
		RpcSetEnv(cEmpInt,cFilInt)
		CONOUT("["+LEFT(DTOC(Date()),5)+"]["+LEFT(Time(),5)+"][PGMRT005] Iniciando processamento via schedule.")
		nOpca:= 1
    EndIf

    //Query busca notas
    cQuery := " SELECT F2_FILIAL, F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, F2_CHVNFE, F2_HAUTNFE, SF2.R_E_C_N_O_ SF2RECNO, F2_XENMAIL, "
    cQuery += " E1_NUM, E1_PREFIXO, E1_EMISSAO "
    cQuery += " FROM "+RetSqlName("SF2") + " SF2 "
    cQuery += " INNER JOIN "+RetSqlName("SE1")+" SE1 ON SE1.E1_NUM = SF2.F2_DOC AND SE1.E1_PREFIXO = SF2.F2_SERIE AND SE1.D_E_L_E_T_ = ' '"	
    cQuery += " WHERE F2_CHVNFE <> '' "
    cQuery += " AND F2_HAUTNFE <> '' "
	cQuery += " AND F2_XENMAIL <> '1' "
    // cQuery += " AND F2_SERIE= '"+cSerie+"' " //VM Teste
    // cQuery += " AND F2_DOC= '"+cDoc+"' " //VM Teste
    cQuery += " AND E1_EMISSAO>= '"+cDataIni+"' "
    cQuery += " AND SF2.D_E_L_E_T_=' ' "
    cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSF2,.F.,.T.)
	(cAliasSF2)->(DbGoTop())

    While (cAliasSF2)->(!Eof())

        cData   := StrTran(DTOC(STOD((cAliasSF2)->E1_EMISSAO)), "/", "")
        cDoc    := AllTrim((cAliasSF2)->F2_DOC)
        cSerie  := AllTrim((cAliasSF2)->F2_SERIE)

        //Busca email do cliente na SA1
        SA1->(dbSetOrder(1))
		If SA1->(dbSeek( xFilial("SA1") + (cAliasSF2)->(F2_CLIENTE+F2_LOJA)))
			cCGC	    := AllTrim(SA1->A1_CGC)
            cA1Email    := AllTrim(SA1->A1_EMAIL)
		EndIf

        //Busca email do cliente na AI0
        AI0->(dbSetOrder(1))
		If AI0->(dbSeek( xFilial("AI0") + (cAliasSF2)->(F2_CLIENTE+F2_LOJA)))
            cAIEmail    := AllTrim(AI0->AI0_EMABOL)
            cRecCob     := AI0->AI0_XRECCB
		EndIf

        //Define pasta para buscar arquivos
        cPath	:= cPasta + cCGC + "\" + xFilial('SE1') + "\" + cData + "\NF" +  AllTrim(cDoc) + AllTrim(cSerie) + "\"

        aFileFun := Directory( cPath + "*", "A")
        For nX = 1 to len(aFileFun)
            If cRecCob = "1"
                aadd(aAnexos, cPath + aFileFun[nX][1])
            Else
                cTipoDoc := SUBSTR( aFileFun[nX][1], 1, 3)
                If cTipoDoc <> "BOL"
                    aadd(aAnexos, cPath + aFileFun[nX][1])
                EndIf
            EndIf
        Next nX
        
        //Define email a serem enviados
		If GetMv("MV_ZWFCOB2")
			cEmail := Alltrim(GetMv("MV_ZWFCOB3"))
		Else
            If !Empty(cA1Email)
                cEmail := cA1Email
            EndIf
            If !Empty(cAIEmail)
                If !Empty(cEmail)
                    cEmail  := cEmail + ";" + cAIEmail
                Else
                    cEmail := cAIEmail
                EndIf
            EndIf
        Endif

        //Verifica se possui email a ser emviado e anexo
        If !Empty(cEmail) .AND. Len(aAnexos) > 0
            //Gera HTML
            cHtml   := '<body>'
            cHtml   += '<table width="100%" border="0"> '
            cHtml   += ' <br>'
            cHtml   += '  <tr>'
            If cRecCob = "1" 
                cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em anexo segue documentos referente, XML, Nota fiscal e boletos de seu pedido</font></td>'
            Else
                cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em anexo segue documentos referente, XML e Nota fiscal de seu pedido</font></td>'
            EndIf
            cHtml   += '  </tr>'
            cHtml   += '  <tr>'
            cHtml   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Em caso de dúvidas, entre em contato conosco</font></td>'
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

            cAssunto    := "NOTIFICAÇÃO ELETRÔNICA DE TÍTULO"
            lEnvio      := U_PGMRT002("",cEmail,cAssunto,cHtml,"","4",aAnexos)

            If lEnvio
                //Grava Flag que ja enviou email
                SF2->(DbGoTo((cAliasSF2)->SF2RECNO))
                SF2->(Reclock("SF2",.f.))
                    SF2->F2_XENMAIL := "1"
                SF2->(MsUnlock())
            EndIf
        EndIf

        (cAliasSF2)->(DbSkip())
    EndDo

    IF lJob
		RpcClearEnv()
	EndIf

    FWRestArea(aArea)
Return
