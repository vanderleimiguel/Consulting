#INCLUDE "Protheus.ch"
#INCLUDE 'fileio.ch'

/*/{Protheus.doc} Z_GRAVARQ
Função para gravar arquivos de nao conformidade
@author Wagner Neves
@since 30/12/2024
@version 1.0
@type function
/*/
User Function Z_GRAVARQ()
    Local aAreaZZ1  := ZZ1->(GetArea())
    Local aFiles    := {}
    Local aSizes    := {}
    Local cBinar    := ""
    Local nHandle   := 0
    Local cQuery 	:= ""
    Local cNomeArq  := ""
    Local nExtens   := 0
    Local cExtens   := ""
    Local cNum      := ""
    Local cLimArq   := SuperGetMV("ZZ_LIMARQ",.F.,5)
    Local cLimSize  := SuperGetMV("ZZ_LIMSIZ",.F.,10000000)

    Private cAliasTmp := GetNextAlias()

    //Verifica local de chamada da rotina
    If fwIsInCallStack('MATA410')
        cNum      := SC5->C5_NUM
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
                    cQuery += " MAX(ZZ1_SEQ) NEXTSEQ "
                    cQuery += " FROM "+RetSQLName("ZZ1")+" ZZ1 (nolock) "
                    cQuery += " WHERE "
                    cQuery += " ZZ1_FILIAL = '"+xFilial("ZZ1")+"'  AND "
                    cQuery += " ZZ1_NUM = '"+cNum+"' AND "
                    cQuery += " ZZ1.D_E_L_E_T_ = ' ' "
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
                    RecLock("ZZ1", .T.)
                        ZZ1->ZZ1_FILIAL := xFilial("ZZ1")
                        ZZ1->ZZ1_SEQ    := cSeq
                        ZZ1->ZZ1_NUM    := cNum
                        ZZ1->ZZ1_EMISSA := dDatabase
                        ZZ1->ZZ1_ARQ    := Encode64(cBinar)
                        ZZ1->ZZ1_NOMEAR := cNomeArq
                        ZZ1->ZZ1_EXTENS := cExtens

                    ZZ1->(MsUnlock())

                    MsgInfo("Arquivo "+cExtens+" salvo com sucesso, na nao conformidade "+AllTrim(cNum)+" sequencia "+cSeq+" !", "Arquivo salvo")

                    // Fecha a consulta 
                    (cAliasTmp)->(dbCloseArea())
                    Else
                        MsgStop("Quantidade de arquivos maior que o limite de "+cValToChar(cLimArq)+" por nao conformidade!", "Atenção")
                    EndIf
                Endif
            Else
                MsgStop("Tamanho do arquivo maior que o limite de: "+cValToChar(cLimSize)+" Byte", "Atenção")
            EndIf
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf 

    EndIf
    
    // Restaura a area de trabalho
    RestArea(aAreaZZ1)

Return()
