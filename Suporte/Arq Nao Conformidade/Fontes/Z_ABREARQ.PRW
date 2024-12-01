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
    Local cFil      := xFilial("ZZ1")
	Private oDlg	:= Nil
	Private oLbx	:= Nil
	Private aVetor	:= {}

    //Verifica local de chamada da rotina
    If fwIsInCallStack('MATA410')
        cNum      := SC5->C5_NUM
    EndIf

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf

    BeginSql Alias 'TRB'

        COLUMN EMISSAO AS DATE 

        SELECT      NUM  			= isnull(ZZ1_NUM	,''),
                    SEQ  			= isnull(ZZ1_SEQ	,''),
                    EXTENSAO		= isnull(ZZ1_EXTENS	,''),
                    EMISSAO			= isnull(ZZ1_EMISSA	,''),
                    NOMEARQ		    = isnull(ZZ1_NOMEAR	,''),
                    FILIAL			= isnull(ZZ1_FILIAL	,''), 
                    ARQ             = isnull(ZZ1_ARQ	,'')
        FROM        %Table:ZZ1% ZZ1 (nolock)
        WHERE       ZZ1.%NotDel%
            AND         ZZ1.ZZ1_FILIAL  = %Exp:cFil%
            AND         ZZ1.ZZ1_NUM     = %Exp:cNum%
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
                        TRB->ARQ            ,;  // - ARQ em Base64
                        TRB->EMISSAO		})  // - Emissao do arquivo 

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
                            "Data Inclusao",;
                            "Extensao",;
                            "Nome Arquivo" SIZE 490,150 OF oDlg PIXEL

	oLbx:SetArray( aVetor )
	oLbx:bLine := {|| { aVetor[oLbx:nAt,01]  ,;
                        aVetor[oLbx:nAt,02]  ,;
                        aVetor[oLbx:nAt,06]  ,;
                        aVetor[oLbx:nAt,03]  ,;
                        aVetor[oLbx:nAt,04]  }}

	@ 180,200 Button btnGrv  PROMPT  "Abrir"  	Size 040,13 Action DinUnZip(aVetor[oLbx:nAt,05], aVetor[oLbx:nAt,04]) OF oDlg  PIXEL
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
        MsgInfo("Erro ao criar o arquivo temporário.")
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
                MsgInfo('Nao foi possivel deletar arquivo.')
            Else
                MsgInfo('Arquivo deletado com sucesso.')
            EndIf
        else
            ZZ1->(DbSetOrder(1))
            If ZZ1->(DbSeek(xFilial("ZZ1")+cNum + cSeq))
                Reclock("ZZ1",.F.)
                ZZ1->( dbDelete() )
                ZZ1->( msUnlock() )
                MsgInfo('Arquivo deletado com sucesso.')
            EndIf
        EndIf
    else
        nOpc := Aviso("Ação","Escolha a opção desejada?",{"Excluir da tabela","Cancelar"},2)
        
        If nOpc == 2
		    return
        Else 
            ZZ1->(DbSetOrder(1))
            If ZZ1->(DbSeek(xFilial("ZZ1")+cNum + cSeq))
                Reclock("ZZ1",.F.)
                ZZ1->( dbDelete() )
                ZZ1->( msUnlock() )
                MsgInfo('Arquivo deletado com sucesso.')
            EndIf
        EndIf
    Endif

    oDlg:End()

Return
