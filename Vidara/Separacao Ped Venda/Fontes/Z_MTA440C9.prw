#Include "Protheus.Ch"

/*/{Protheus.doc} Z_MTA440C9
Funcao chamada do P.E MTA440C9
@author Wagner Neves
@since 28/11/2024
@version 1.0
@type function
/*/
User Function Z_MTA440C9()
    Local cFrom     := SuperGetMV("MV_RELFROM",,"" )
    Local cTo       := SuperGetMV("ZZ_MAILPED",,"" )
    Local cSubject  := ""
    Local cBody     := ""
    Local cFilNome  := ""

    //Gravo Logs da libercao
    RecLock("SC9",.F.)
        SC9->C9_ZZDTLIB  := Date()
        SC9->C9_ZZHRLIB  := Time()
        SC9->C9_ZZUSLIB  := UsrRetName(RetCodUsr())
    SC9->(MsUnlock())

    //Envia email
    If ExistBlock("Z_EnvMail") .AND. !Empty(cFrom) .AND. !Empty(cTo)
        cFilNome    := FwFilialName( cEmpAnt, cFilAnt, 1 )
        cSubject    := "Pedido de Venda "+Alltrim(SC9->C9_PEDIDO)+" Liberado"
        
        cBody   := '<body>'
        cBody   += '<table width="100%" border="0"> '
        cBody   += ' <br>'
        cBody   += '  <tr>'
        cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Pedido de venda '+Alltrim(SC9->C9_PEDIDO)+' liberado</font></td>'
        cBody   += '  </tr>'
        cBody   += '<table width="100%" border="0"> '
        cBody   += ' <br>'
        cBody   += '  <tr>'
        cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Atenciosamente</font></td>'
        cBody   += '  </tr>'
        cBody   += ' <br>'
        cBody   += '  <tr>'
        cBody   += '   <td><font size="3" face="Arial, Helvetica, sans-serif">Vidara '+cFilNome+'</font></td>'
        cBody   += '  </tr>'
        cBody   += ' <br>'
        cBody   += '</table>'

        U_Z_EnvMail(cFrom,cTo,cSubject,cBody)
    EndIf

Return
