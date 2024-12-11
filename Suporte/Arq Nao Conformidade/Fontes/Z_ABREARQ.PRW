#INCLUDE "PROTHEUS.CH"
#include 'fwmvcdef.ch'

/*/{Protheus.doc} Z_ABREARQ
Função para abrir tela de arquivos
@author Wagner Neves
@since 30/11/2024
@version 1.0
@type function
/*/
User Function Z_ABREARQ()   
	
	Local aArea	    := GetArea()
	Local cTitulo	:= "Arquivos de Nao Conformidade"
    Local btnGrv
    Local btnExcl
    Local cNum      := ""
    Local cFil      := xFilial("ZC1")
	Private oDlg	:= Nil
	Private oLbx	:= Nil
	Private aVetor	:= {}

    //Verifica local de chamada da rotina
    If fwIsInCallStack('QNCA030')
        cNum      := QI3->QI3_CODIGO
    ElseIf fwIsInCallStack('QIEA220')
        cNum      := QEM->QEM_NNC
    EndIf

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf

    BeginSql Alias 'TRB'

        COLUMN EMISSAO AS DATE 

        SELECT      NUM  			= isnull(ZC1_NUM	,''),
                    SEQ  			= isnull(ZC1_SEQ	,''),
                    EXTENSAO		= isnull(ZC1_EXTENS	,''),
                    EMISSAO			= isnull(ZC1_EMISSA	,''),
                    HORA			= isnull(ZC1_HRINCL	,''),
                    USERID			= isnull(ZC1_USRINC	,''),
                    USERNOME		= isnull(ZC1_LGINCL	,''),
                    NOMEARQ		    = isnull(ZC1_NOMEAR	,''),
                    MODULO		    = isnull(ZC1_MODORI	,''),
                    ROTINA		    = isnull(ZC1_ROTORI	,''),
                    FILIAL			= isnull(ZC1_FILIAL	,''), 
                    ARQ             = isnull(ZC1_ARQ	,'')
        FROM        %Table:ZC1% ZC1 (nolock)
        WHERE       ZC1.%NotDel%
            AND         ZC1.ZC1_FILIAL  = %Exp:cFil%
            AND         ZC1.ZC1_NUM     = %Exp:cNum%
        ORDER BY    NUM, SEQ

    EndSql    

	dbSelectArea("TRB")
	TRB->(dbGoTop())

	// - Alimenta o array "aVetor" de acordo com os parametros.
	While TRB->(!Eof())

		aAdd(aVetor,{						 ;
						TRB->NUM		    ,;	// - Nao conformidade
						TRB->SEQ			,;	// - Sequencia
						TRB->EXTENSAO		,;	// - Extensao do arquivo
                        TRB->NOMEARQ		,;	// - Nome do Arquivo
                        TRB->USERNOME       ,;  // - Nome Usuario
						TRB->HORA	    	,;	// - Hora
                        TRB->USERID		    ,;	// - User Id
                        TRB->ARQ            ,;  // - ARQ em Base64
                        TRB->EMISSAO		,;  // - Emissao do arquivo 
                        TRB->MODULO		    ,;	// - Modulo
                        TRB->ROTINA         })  // - Rotina 

		TRB->(dbSkip())
	EndDo

	TRB->(dbCloseArea())

    //verifica se encontrou arquivos
	If(Len( aVetor ) <= 0)
		Aviso(cTitulo,"Nao há ARQ salva para esta nao conformidade",{"Ok"})
		Return
	EndIf

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 000,000 TO 420,1010 PIXEL                 

	@ 010,010 LISTBOX oLbx VAR cVar FIELDS HEADER ;
                            "Nao Conformidade",;
                            "Sequencia",;
                            "Extensao",;
                            "Nome Arquivo" ,;
                            "Modulo Origem" ,;
                            "Rotina Origem" ,;
                            "Data Inclusao",;
                            "Hora Inclusao",;
                            "Usuario Inclusao" SIZE 490,150 OF oDlg PIXEL

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| { aVetor[oLbx:nAt,01]  ,;
                        aVetor[oLbx:nAt,02]  ,;
                        aVetor[oLbx:nAt,03]  ,;
                        AllTrim(aVetor[oLbx:nAt,04])  ,;
                        AllTrim(aVetor[oLbx:nAt,10])  ,;
                        AllTrim(aVetor[oLbx:nAt,11])  ,;
                        aVetor[oLbx:nAt,09]  ,;
                        aVetor[oLbx:nAt,06]  ,;
                        AllTrim(aVetor[oLbx:nAt,05])  }}

	@ 180,200 Button btnGrv  PROMPT  "Abrir"  	Size 040,13 Action DinUnZip(aVetor[oLbx:nAt,08], aVetor[oLbx:nAt,04]) OF oDlg  PIXEL
    @ 180,280 Button btnExcl PROMPT "Excluir"  	Size 040,13 Action CloseDLG(aVetor[oLbx:nAt,01], aVetor[oLbx:nAt,02], aVetor[oLbx:nAt,04]) OF oDlg  PIXEL
 	
    ACTIVATE DIALOG oDlg CENTERED

	RestArea(aArea)

Return

/*/{Protheus.doc} DinUnZip
Função para decodificar arquivos
@author Wagner Neves
@since 30/11/2024
@version 1.0
@type function
/*/
Static Function DinUnZip(cBinB64, cNomeArq)
    
    Local cTemp := GetTempPath() // Caminho do arquivo temporário
    Local nRet  := 0
    Local lRet  := .F.
    Local nFile

	if SubStr(cTemp, Len(cTemp), 1) != "\"
		cTemp += "\"
	endif

    // Criar o arquivo temporário e escrever o conteúdo binário
    nFile := FCreate(cTemp + AllTrim(cNomeArq))

    IF nFile < 0
        FWAlertInfo("Erro ao criar o arquivo temporário.", "Z_ABREARQ - Mensagem ...")
        RETURN
    ENDIF

    FWrite(nFile, Decode64(cBinB64))
    FClose(nFile)

    // Utilizar WinExec para abrir a ARQ
    nRet := WinExec("cmd /c start " + cTemp + AllTrim(cNomeArq))

    // Verificar o resultado
    IF nRet >= 32
        lRet := .T. 
    ENDIF    

Return(lRet)


/*/{Protheus.doc} CloseDLG
Função para apagar arquivo
@author Wagner Neves
@since 30/11/2024
@version 1.0
@type function
/*/
Static Function CloseDLG(cNum, cSeq, cNomeArq)

    Local cTemp := GetTempPath() // Caminho do arquivo temporário
    Local nOpc  := 0

    If FILE(cTemp + Alltrim(cNomeArq))
        nOpc := Aviso("Ação","Escolha a opção desejada?",{"Excluir Arq. Maq. Local","Excluir da tabela","Cancelar"},2)
        
        If nOpc == 3
		    return
	    ElseIf nOpc == 1
            If FErase( cTemp + Alltrim(cNomeArq) ) == -1
                FWAlertInfo('Nao foi possivel deletar arquivo.', "Z_ABREARQ - Mensagem ...")
            Else
                FWAlertInfo('Arquivo deletado com sucesso.', "Z_ABREARQ - Mensagem ...")
            EndIf
        else
            ZC1->(DbSetOrder(1))
            If ZC1->(DbSeek(xFilial("ZC1")+cNum + cSeq))
                Reclock("ZC1",.F.)
                ZC1->( dbDelete() )
                ZC1->( msUnlock() )
                FWAlertInfo('Arquivo deletado com sucesso.', "Z_ABREARQ - Mensagem ...")
            EndIf
        EndIf
    else
        nOpc := Aviso("Ação","Escolha a opção desejada?",{"Excluir da tabela","Cancelar"},2)
        
        If nOpc == 2
		    return
        Else 
            ZC1->(DbSetOrder(1))
            If ZC1->(DbSeek(xFilial("ZC1")+cNum + cSeq))
                Reclock("ZC1",.F.)
                ZC1->( dbDelete() )
                ZC1->( msUnlock() )
                FWAlertInfo('Arquivo deletado com sucesso.', "Z_ABREARQ - Mensagem ...")
            EndIf
        EndIf
    Endif

    oDlg:End()

Return
