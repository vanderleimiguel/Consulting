#INCLUDE "Protheus.ch"
#INCLUDE 'fileio.ch'

/*/{Protheus.doc} Z_GRAVARQ
Função para gravar arquivos de nao conformidade
@author Wagner Neves
@since 30/11/2024
@version 1.0
@type function
/*/
User Function Z_GRAVARQ()
    Local aAreaZC1  := ZC1->(GetArea())
    Local aFiles    := {}
    Local aSizes    := {}
    Local cBinar    := ""
    Local nHandle   := 0
    Local cQuery 	:= ""
    Local cNomeArq  := ""
    Local nExtens   := 0
    Local cExtens   := ""
    Local cNum      := ""
    Local cModulo   := ""
    Local cRotina   := ""
    Local cLimArq   := SuperGetMV("ZZ_LIMARQ",.F.,5)
    Local cLimSize  := SuperGetMV("ZZ_LIMSIZ",.F.,10000000)

    Private cAliasTmp := GetNextAlias()

    //Verifica local de chamada da rotina
    If fwIsInCallStack('QNCA030')
        cNum      := QI3->QI3_CODIGO
        cModulo   := "SIGAQNC"
        cRotina   := "QNCA030"
    ElseIf fwIsInCallStack('QIEA220')
        cNum      := QEM->QEM_NNC
        cModulo   := "SIGAQIE"
        cRotina   := "QIEA220"
    EndIf

    //Mostra o Prompt para selecionar arquivos
	cPath := tFileDialog( "All files (*) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If !Empty(cPath)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cPath)

		    //verifica tamanho do arquivo
            ADir(cPath, aFiles, aSizes)//Verifica o tamanho do arquivo, parâmetro exigido na FRead.

            //Verifica tamanho do arquivo
            If aSizes[1] <= cLimSize
            
                nExtens := AT(".", aFiles[1] )
                cExtens := AllTrim(Substr(aFiles[1],nExtens+1))

                //Transforma imagem em binario
                nHandle := fopen(cPath , FO_READWRITE + FO_SHARED )
                FRead( nHandle, cBinar, aSizes[1] ) //Carrega na variável cString, a string ASCII do arquivo.
                fclose(nHandle)

                If  !Empty(cBinar) .And. !Empty(cNum)

                    // Fecho a consulta se o Alias estiver em uso
                    If Select(cAliasTmp) > 0
                        (cAliasTmp)->(dbCloseArea())
                    Endif

                    cQuery := ""
                    cQuery += " SELECT "
                    cQuery += " MAX(ZC1_SEQ) NEXTSEQ "
                    cQuery += " FROM "+RetSQLName("ZC1")+" ZC1 (nolock) "
                    cQuery += " WHERE "
                    cQuery += " ZC1_FILIAL = '"+xFilial("ZC1")+"'  AND "
                    cQuery += " ZC1_NUM = '"+cNum+"' AND "
                    cQuery += " ZC1.D_E_L_E_T_ = ' ' "
                    cQuery := ChangeQuery(cQuery)

                    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)

                    // Ajusto a sequencia caso a consulta nao retorne infos.
                    If (cAliasTmp)->(EOF()) .OR. Empty((cAliasTmp)->NEXTSEQ)
                        cSeq := '001'
                    else
                        cSeq := SOMA1((cAliasTmp)->NEXTSEQ)
                    Endif

                    If Val(cSeq) <= cLimArq

                    //Gera Nome do Arquivo
                    cNomeArq    := Alltrim(cNum) +"_"+ Alltrim(cSeq) +"."+ cExtens

                    // Efetua a gravação do Registro
                    RecLock("ZC1", .T.)
                        ZC1->ZC1_FILIAL := xFilial("ZC1")
                        ZC1->ZC1_SEQ    := cSeq
                        ZC1->ZC1_NUM    := cNum
                        ZC1->ZC1_EMISSA := dDatabase
                        ZC1->ZC1_ARQ    := Encode64(cBinar)
                        ZC1->ZC1_NOMEAR := cNomeArq
                        ZC1->ZC1_EXTENS := cExtens
                        ZC1->ZC1_MODORI := cModulo
                        ZC1->ZC1_ROTORI := cRotina
                        ZC1->ZC1_USRINC := __cUserID
						ZC1->ZC1_NOMINC := UsrFullName(__cUserID )
						ZC1->ZC1_HRINCL := TIME()
						ZC1->ZC1_LGINCL := UsrRetName(__cUserID )

                    ZC1->(MsUnlock())

                    FWAlertInfo("Arquivo "+cExtens+" salvo com sucesso, na nao conformidade "+AllTrim(cNum)+" sequencia "+cSeq+" !", "Z_GRAVARQ - Mensagem ...")

                    // Fecha a consulta 
                    (cAliasTmp)->(dbCloseArea())
                    Else
                        FWAlertError("Quantidade de arquivos maior que o limite de "+cValToChar(cLimArq)+" por nao conformidade!", "Z_GRAVARQ - Mensagem ...")
                    EndIf
                Endif
            Else
                FWAlertError("Tamanho do arquivo maior que o limite de: "+cValToChar(cLimSize)+" Byte", "Z_GRAVARQ - Mensagem ...")
            EndIf
		Else
			FWAlertError("Arquivo e/ou extensão inválida!", "Z_GRAVARQ - Mensagem ...")
		EndIf 

    EndIf
    
    // Restaura a area de trabalho
    RestArea(aAreaZC1)

Return()
