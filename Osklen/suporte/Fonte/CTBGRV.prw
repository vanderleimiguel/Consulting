/*/{Protheus.doc} CTBGRV
	pe utilizado para gravar campo customizado com numero do lote do RM
	@type	 function
	@version p2210
	@author	 ivan.caproni
	@since	 10/08/2023
/*/
user function CTBGRV
    if Alltrim(ParamIxb[2]) == "OKCTBM01" .and. ParamIxb[1] == 3 // inclusao
        // variavel jInfo criada no fonte OKCTBM01
        if CT2->( FieldPos("CT2_XRMLOT") > 0 ) .and. Type("jInfo") != "U"
            CT2->CT2_XRMLOT := cValtochar(jInfo["CODLOTE"])
        endif
    endif
return
