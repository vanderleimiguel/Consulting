//Bibliotecas
#Include "Protheus.ch" 
#Include "FWMVCDEF.CH"

/*/{Protheus.doc} MATA061
Ponto de Entrada para valida��o a fim de n�o permitir Data de expira��o em branco quando homologa��o = "S".
@author Abel Ribeiro 
@since 21/10/2024
@version 1.0 
@type function 
@obs Deixar o nome do prw como: MATA061_pe.prw 
/*/
User Function MATA061() 
    Local aParam   := PARAMIXB 
    Local lRet     := .T. 
    Local oObj     := Nil 
    Local cIdPonto := ""
    Local cIdModel := ""
    Local lIsGrid  := .F.
    Local nLinha

    //Se tiver par�metros
    If aParam != Nil 
        //Pega informa��es dos par�metros
        oObj     := aParam[1] 
        cIdPonto := aParam[2] 
        cIdModel := aParam[3] 
        lIsGrid  := (Len(aParam) > 3)

        oModelPad := FWModelActive()
        oModelGrid := oOBJ:GetModel("MdGridSA5")
        
        If cIdPonto == "MODELPOS"

            IF oObj:GetOperation() == MODEL_OPERATION_INSERT .OR. oObj:GetOperation() == MODEL_OPERATION_UPDATE 
                For nLinha := 1 To oModelGrid:Length()
                    oModelGrid:GoLine(nLinha)

                    //Se o campo A estiver preenchido, mas o campo B estiver vazio
                    If oModelGrid:GetValue("A5_ZZHOMOL") == '1' .And. Empty(oModelGrid:GetValue("A5_ZZDTEXP"))
                        lRet := .F.
                        ExibeHelp("ERRO", "Data de Expira��o Inv�lida." + cValToChar(nLinha), "Informe a Data de Expira��o da Homologa��o.")
                        Exit
                    EndIf
                Next               
            EndIf  
        EndIf 
    Endif
Return lRet
