#Include 'totvs.ch'
#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'prtopdef.ch'
#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#include "TbiConn.ch"

/*/{Protheus.doc} Z_VDFIN3
Monitor de Integracao Expense Mobi - ZZA 
Executa criação dos títulos da ZZA para a SE2.
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Z_VDFIN3()

	//Private cPrefixo
	Private dDataDe  	:= MsDate()
	Private dDataAte	:= MsDate()
	//	Local cFilDe	:= " "//Space(Len(xFilial("SZ2")))
	//	Local cFilAte	:= " " //Replicate("Z",Len(xFilial("SZ2")))
	Private aPergs   	:= {}
	Private lError	:= .F.
	Private aVetor 	:= {}
	Private aDados 	:= {}
	Private nI 		:= 1
	Private cNum	:= ""
	Private cPrefixo:= ""
	Private cParcela:= ""
	Private cTipo	:= ""
	Private cTipoDes:= ""
	Private cFornec	:= ""
	Private cLoja	:= ""

	aAdd(aPergs, {1, "Data De :",  dDataDe,  "", ".T.", "", ".T.", 60,  .F.})
	aAdd(aPergs, {1, "Data Ate :", dDataAte,  "", ".T.", "", ".T.", 60,  .F.})
	aAdd(aPergs, {2, "Tipo Despesa :",  cTipoDes, {"RDE=Desp. Reembolsável","CCE=Desp. Não Reembolsável (Cartão)"}, 122, ".T.", .F.})

	If ParamBox(aPergs, "Informe os parâmetros -")
		dDataDe    := Mv_Par01
		dDataAte   := Mv_Par02
		cTipoDes   := Mv_Par03
	Else
		Return .T.
	EndIf

	U_VAlida()

Return

/*/{Protheus.doc} Valida
Valida dados antes da gravacao na tabela SE2
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function Valida()

	cQuery := "SELECT ZZA_FILIAL, ZZA_VCPFCN, ZZA_VIDDES, ZZA_VNATUR, ZZA_VCCUST, ZZA_VFORPA, ZZA_VVALOR, ZZA_VNOME, ZZA_STATUS, ZZA_VDTAPR "
	cQuery += "	FROM " + RetSqlName("ZZA") + " ZZA (NOLOCK) " + Chr(10) + Chr (13)
	cQuery += " WHERE  "+ Chr(10) + Chr(13)
	cQuery += " ZZA_FILIAL ='"+XFILIAL("ZZA")+"' "+ Chr(10) + Chr(13)
	cQuery += " AND ZZA_VDTAPR BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "+ Chr(10) + Chr(13)
	cQuery += " AND ZZA_PREFIX BETWEEN '"+cTipoDes+"' AND '"+cTipoDes+"' "+ Chr(10) + Chr(13)
	cQuery += " AND ZZA_STATUS IN (0,2) "+ Chr(10) + Chr(13)
	cQuery += " AND D_E_L_E_T_='' "+ Chr(10) + Chr(13)
	//	cQuery += " GROUP BY ZZA_FILIAL, ZZA_VCPFCN, ZZA_VNATUR, ZZA_VCCUST, ZZA_VFORPA "

	While .T.
		cAliasQRY := GetNextAlias()
		If !TCCanOpen(cAliasQRY) .And. Select(cAliasQRY) == 0
			Exit
		EndIf
	EndDo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQRY,.F.,.T.)
	DbSelectArea(cAliasQRY)
	(cAliasQRY)->(DbGoTop())

	While !(cAliasQRY)->(EOF())

		//========================================================================
		//ÍNICIO - VALIDAÇÕES ANTES DA GRAVAÇÃO
		//========================================================================

		//VERIFICA O CÓDIGO DO COLABORADOR/FORNECEDORES (SA2)
		If !Empty((cAliasQRY)->ZZA_VCPFCN)
			dbSelectArea("SA2")
			dbSetOrder(3)
			If !dbSeek(xFilial("SA2") + Padr((cAliasQRY)->ZZA_VCPFCN, TamSx3('A2_CGC')[1]))

				lError := .T.

				MsgAlert("Colaborador não cadastrado como Fornecedor (SA2). "+Chr(10) + Chr (13)+" CPF: "+(cAliasQRY)->ZZA_VCPFCN+" "+Chr(10) + Chr (13)+" ID Despesa: "+(cAliasQRY)->ZZA_VIDDES+"  "+" "+Chr(10) + Chr (13)+" Nome: "+(cAliasQRY)->ZZA_VNOME+"  ","Atenção")

				DbSelectArea("ZZA")
				DbSetOrder(1)
				DbGotop()

				If DbSeek(xFilial("ZZA")+(cAliasQRY)->ZZA_VIDDES)
					RecLock("ZZA",.F.)
					ZZA->ZZA_STATUS 	:= "2"
					ZZA->ZZA_OBSERV	:= "Claborador não cadastrado como Fornecedor(SA2)"
					//ZZA->ZZA_OBSMEM	:= "Claborador não cadastrado como Fornecedor(SA2)'
					//	cObservacao		:=  "Colaborador  não cadastrado como Fornecedor(SA2)"
					//	MSMM("ZZA_OBSMEM",, , cObservacao, 1, , , "ZZA", "ZZA_OBSMEM")
					MsUnlock()
				Endif
			EndIf
		EndIf

		//VERIFICA SE EXISTE A NATUREZA FINANCEIRA (SED)
		If !Empty((cAliasQRY)->ZZA_VNATUR)

			dbSelectArea("SED")
			dbSetOrder(01)
			If !dbSeek(xFilial("SED")+(cAliasQRY)->ZZA_VNATUR)
				lError := .T.

				MsgAlert("Natureza Financeira não cadastrada no Protheus(SED). "+Chr(10) + Chr (13)+" Natureza: "+(cAliasQRY)->ZZA_VNATUR+" "+Chr(10) + Chr (13)+" ID Despesa: "+(cAliasQRY)->ZZA_VIDDES+"  "+" "+Chr(10) + Chr (13)+" Nome: "+(cAliasQRY)->ZZA_VNOME+"  ","Atenção")

				DbSelectArea("ZZA")
				DbSetOrder(1)
				DbGotop()

				If DbSeek(xFilial("ZZA")+(cAliasQRY)->ZZA_VIDDES)
					RecLock("ZZA",.F.)
					ZZA->ZZA_STATUS 	:= "2"
					ZZA->ZZA_OBSERV	:= "Natureza não cadastrada no Protheus(SED)"
					//ZZA->ZZA_OBSMEM	:= "Natureza não cadastrada no Protheus(SED)'
					//	cObservacao		:=  "Natureza não cadastrada no Protheus(SED)"
					//	MSMM("ZZA_OBSMEM",, , cObservacao, 1, , , "ZZA", "ZZA_OBSMEM")
					MsUnlock()
				Endif
			EndIf
		EndIf

		//VERIFICA SE EXISTE CENTRO DE CUSTO (CTT)
		If !Empty((cAliasQRY)->ZZA_VCCUST)

			dbSelectArea("CTT")
			dbSetOrder(01)
			If !dbSeek(xFilial("CTT")+(cAliasQRY)->ZZA_VCCUST)
				lError := .T.

				MsgAlert("Centro de Custo não cadastrado no Protheus(CTT). "+Chr(10) + Chr (13)+" C.Custo: "+(cAliasQRY)->ZZA_VCCUST+" "+Chr(10) + Chr (13)+" ID Despesa: "+(cAliasQRY)->ZZA_VIDDES+"  "+" "+Chr(10) + Chr (13)+" Nome: "+(cAliasQRY)->ZZA_VNOME+"  ","Atenção")

				DbSelectArea("ZZA")
				DbSetOrder(1)
				DbGotop()

				If DbSeek(xFilial("ZZA")+(cAliasQRY)->ZZA_VIDDES)
					RecLock("ZZA",.F.)
					ZZA->ZZA_STATUS 	:= "2"
					ZZA->ZZA_OBSERV	:= "C.Custo não cadastrado no Protheus(CTT)"
					//ZZA->ZZA_OBSMEM	:= "C.Custo não cadastrado no Protheus(CTT)'
					//	cObservacao		:=  "C.Custo não cadastrado no Protheus(CTT)'
					//	MSMM("ZZA_OBSMEM",, , cObservacao, 1, , , "ZZA", "ZZA_OBSMEM")
					MsUnlock()
				Endif
			EndIf
		EndIf

		IF (cAliasQRY)->ZZA_STATUS=="2"
			dbSelectArea("CTT")
			dbSetOrder(01)
			If dbSeek(xFilial("CTT")+(cAliasQRY)->ZZA_VCCUST)

				dbSelectArea("SED")
				dbSetOrder(01)
				If dbSeek(xFilial("SED")+(cAliasQRY)->ZZA_VNATUR)

					dbSelectArea("SA2")
					dbSetOrder(03)
					If dbSeek(xFilial("SA2") + Padr((cAliasQRY)->ZZA_VCPFCN, TamSx3('A2_CGC')[1]))
						DbSelectArea("ZZA")
						DbSetOrder(1)
						DbGotop()

						If DbSeek(xFilial("ZZA")+(cAliasQRY)->ZZA_VIDDES)
							RecLock("ZZA",.F.)
							ZZA->ZZA_STATUS 	:= "0"
							ZZA->ZZA_OBSERV	:= "Corrigido Inconsistência. Aguardando integração com CP"
						EndIf
					Endif
				EndIf
			EndIf
		EndIf

		(cAliasQRY)->(dbskip())

		//========================================================================
		//FIM - VALIDAÇÕES ANTES DA GRAVAÇÃO
		//========================================================================

		//Next
	Enddo

	(cAliasQRY)->(DbcloseArea())

	//Se identificado inconsistências nos dados gravados não executa a geração dos títulos no SE2
	If lError
		Help( ,, 'Z_VDFIN3',, "Foram identificados registros com inconsistências/erros, com isso, nenhuma movimentação será integrada para o Financeiro (CP)!", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Corrija-os e execute a integração novamente."})
	Else
		U_IniGrava()
	EndIf

Return

/*/{Protheus.doc} IniGrava
Grava dados na SE2
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function IniGrava()

	cQry2 := "SELECT ZZA_FILIAL, ZZA_VCPFCN, ZZA_VNATUR, ZZA_VCCUST, ZZA_VFORPA, SUM(ZZA_VVALOR) AS VALTOT "
	cQry2 += "	FROM " + RetSqlName("ZZA") + " ZZA (NOLOCK) " + Chr(10) + Chr (13)
	cQry2 += " WHERE  "+ Chr(10) + Chr(13)
	cQry2 += " ZZA_FILIAL ='"+XFILIAL("ZZA")+"' "+ Chr(10) + Chr(13)
	cQry2 += " AND ZZA_VDTAPR BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "+ Chr(10) + Chr(13)
	cQry2 += " AND ZZA_PREFIX BETWEEN '"+cTipoDes+"' AND '"+cTipoDes+"' "+ Chr(10) + Chr(13)
	cQry2 += " AND ZZA_STATUS IN (0,2) "+ Chr(10) + Chr(13)
	cQry2 += " AND D_E_L_E_T_='' "+ Chr(10) + Chr(13)
	cQry2 += " GROUP BY ZZA_FILIAL, ZZA_VCPFCN, ZZA_VNATUR, ZZA_VCCUST, ZZA_VFORPA "

	While .T.
		cAliaQRY := GetNextAlias()
		If !TCCanOpen(cAliaQRY) .And. Select(cAliaQRY) == 0
			Exit
		EndIf
	EndDo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry2),cAliaQRY,.F.,.T.)
	DbSelectArea(cAliaQRY)
	(cAliaQRY)->(DbGoTop())

	While !(cAliaQRY)->(EOF())

		//========================================================================
		//ATRIBUIÇÕES DOS CONTEÚDOS DAS VARIÁVEIS
		//========================================================================
		cFilialZA	:= (cAliaQRY)->ZZA_FILIAL
		cPrefixo	:=  If((cAliaQRY)->ZZA_VFORPA=="Cartao Corporativo  ", "CCE", "RDE" )
		cNum		:=  Random(0, 500000000) //dtos(ddatabase)+"D" //Alltrim(ZZA->ZZA_VIDDES)
		cParcela	:=  "01"
		cTipo		:=  "NF"
		cNatureza	:=  Alltrim((cAliaQRY)->ZZA_VNATUR)
		cFornec		:=  GETADVFVAL("SA2","A2_COD",xFilial("SA2")+ALLTRIM((caliaQRY)->ZZA_VCPFCN), 3)
		cLoja		:=  GETADVFVAL("SA2","A2_LOJA",xFilial("SA2")+ALLTRIM((caliaQRY)->ZZA_VCPFCN), 3)
		cNomeFor	:=  GETADVFVAL("SA2","A2_NOME",xFilial("SA2")+ALLTRIM((caliaQRY)->ZZA_VCPFCN), 3)
		//dEmissao	:= Stod(Right(_aCSV[I][12],4) + Subs(_aCSV[I][12],3,2) + Left(_aCSV[I][12],2))
		dEmissao	:= ddatabase //ZZA->ZZA_VDTAPR  //" " //ctod(_aCSV[I][12])
		dVencto		:= ddatabase //ZZA->ZZA_VDTAPR //ctod(_aCSV[I][13])
		dVencReal	:= ddatabase //ZZA->ZZA_VDTAPR //ctod(_aCSV[I][14])
		nValor		:= (cAliaQRY)->VALTOT//StrTran(Alltrim(_aCSV[I][15]), '.' , '') //remove ponto
		//nValor 	:= ZZA->ZZA_VNUMINT" " //Val(StrTran(nValor, ',' , '.' )) // troca virgula por ponto
		nSaldo 		:= (cAliaQRY)->VALTOT //StrTran(Alltrim(_aCSV[I][20]), '.' , '') //SE2->E2_SALDO
		//nSaldo 		:= " " //Val(StrTran(nSaldo, ',' , '.' )) //SE2->E2_SALDO
		nMoeda		:= 1
		cFilOrigem	:= xFilial("SE2")
		cHistorico	:=  "TIT CRIADO AUTOM PELA Z_VDFIN3"
		cCCusto		:= Alltrim((cAliaQRY)->ZZA_VCCUST)

		//========================================================================
		//ATRIBUIÇÃO DO CONTEUDO DAS VÁRIAVES NO ARRAY ANTES DO EXECAUTO
		//========================================================================
		aadd(aVetor,{"E2_FILIAL", 	xFilial('SE2'), nil})
		aadd(aVetor,{"E2_PREFIXO",	Padr( cPrefixo, TamSx3('E2_PREFIXO')[1]) ,	nil})
		aadd(aVetor,{"E2_NUM",     	Padr( cNum, TamSx3('E2_NUM')[1]) 		 ,	nil})
		aadd(aVetor,{"E2_TIPO",    	Padr( cTipo , TamSx3('E2_TIPO')[1])		 ,	nil})
		aadd(aVetor,{"E2_PARCELA", 	Padr( cParcela, TamSx3('E2_PARCELA')[1]) ,	nil})
		aadd(aVetor,{"E2_NATUREZ", 	cNatureza,	nil})
		aadd(aVetor,{"E2_FORNECE",	cFornec,	nil})
		aadd(aVetor,{"E2_LOJA",		cLoja,		nil})
		aadd(aVetor,{"E2_EMISSAO",	ddatabase,	nil})
		aadd(aVetor,{"E2_EMIS1",	ddatabase,	nil})
		aadd(aVetor,{"E2_VENCTO",	If(cPrefixo=="CCE", ddatabase, ddatabase+3),	nil})
		aadd(aVetor,{"E2_VENCREA",	If(cPrefixo=="CCE", ddatabase, ddatabase+3),	nil})
		aadd(aVetor,{"E2_VALOR",	nValor,		nil})
		aadd(aVetor,{"E2_SALDO",	nSaldo,		nil})
		aadd(aVetor,{"E2_MOEDA",	nMoeda,		nil})
		aadd(aVetor,{"E2_CCUSTO",	cCCusto,	nil})
		aadd(aVetor,{"E2_NOMFOR",	cNomeFor,	nil})
		aadd(aVetor,{"E2_FILORIG",	cFilOrigem,	nil})
		aadd(aVetor,{"E2_MSFIL",	cFilOrigem,	nil})
		aadd(aVetor,{"E2_HIST",		cHistorico,	nil})

		aadd(aDados,aVetor)

		aVetor := {}

		(cAliaQRY)->(dbskip())

	Enddo

	//========================================================================
	//VERIFICA SE JÁ EXISTE TÍTULO GRAVADO NO SE2 COM AS MESMAS INFORMAÇÕES
	//========================================================================
	dbSelectArea("SE2")
	dbSetOrder(1)
	If !dbSeek(xFilial("SE2") + Padr(cPrefixo, TamSx3('E2_PREFIXO')[1]) + ;
			Padr(cNum, TamSx3('E2_NUM')[1]) + Padr(cParcela, TamSx3('E2_PARCELA')[1]) + ;
			Padr( cTipo , TamSx3('E2_TIPO')[1]) + cFornec + cLoja )
		GRAVA1( 'I' )

		lError := .T.

	Else
		GRAVA1( 'A' )

		lError := .T.
		//eszMsgAlert("Título: "+cNum+" já existe no SE2, portanto não será criado! ","Atenção")

	EndIf

	//	MsgAlert("Foram identificados registros com erros. Corrija-os e execute a integração novamente.! ","Atenção")

Return()

/*/{Protheus.doc} Valida
Executa o execauto para gravar titulos na SE2
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
Static FUNCTION GRAVA1( cMov )

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	If cMov == 'I'
		While nI <= Len(aDados)
			MsExecAuto( { |x,y| FINA050(x,y)} , aDados[nI], 3) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
			nI++
		EndDo
	ElseIf cMov == 'A'
	//	MsExecAuto( { |x,y| FINA050(x,y)} , aVetor, 4) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
	Endif

	If lMsErroAuto
		MostraErro()
	Else
		If cMov == 'I'
			U_AtuZZA()

		ElseIf cMov == 'A'
			//nQtdAlt++
		EndIf
	Endif
Return

/*/{Protheus.doc} AtuZZA
Atualiza titulo gravado na ZZA
@author Elton Zaniboni
@since 03/09/2024	
@version 1.0 
@type function
@revision Wagner Neves
/*/
User Function AtuZZA()

	Private cMsg	:= " "

	cQry3 := "SELECT ZZA_VIDDES, ZZA_STATUS "
	cQry3 += "	FROM " + RetSqlName("ZZA") + " ZZA (NOLOCK) " + Chr(10) + Chr (13)
	cQry3 += " WHERE  "+ Chr(10) + Chr(13)
	cQry3 += " ZZA_FILIAL ='"+XFILIAL("ZZA")+"' "+ Chr(10) + Chr(13)
	cQry3 += " AND ZZA_VDTAPR BETWEEN '"+dtos(dDataDe)+"' AND '"+dtos(dDataAte)+"' "+ Chr(10) + Chr(13)
	cQry3 += " AND ZZA_PREFIX BETWEEN '"+cTipoDes+"' AND '"+cTipoDes+"' "+ Chr(10) + Chr(13)
	cQry3 += " AND ZZA_STATUS IN (0,2) "+ Chr(10) + Chr(13)
	cQry3 += " AND D_E_L_E_T_='' "+ Chr(10) + Chr(13)

	While .T.
		cAliQRY := GetNextAlias()
		If !TCCanOpen(cAliQRY) .And. Select(cAliQRY) == 0
			Exit
		EndIf
	EndDo

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry3),cAliQRY,.F.,.T.)
	DbSelectArea(cAliQRY)
	(cAliQRY)->(DbGoTop())

	While !(cAliQRY)->(EOF())

		//Alert("Aqui irá atualizar a ZZA")
		DbSelectArea("ZZA")
		DbSetOrder(1)
		DbGotop()

		If DbSeek(xFilial("ZZA")+(cAliQRY)->ZZA_VIDDES)

			RecLock("ZZA",.F.)
			ZZA->ZZA_STATUS 		:= '1'
			ZZA->ZZA_OBSERV		:= "Título gerado com sucesso no CP"
			//ZZA->ZZA_OBSMEM		:= 'Título gerado com sucesso no SE2'
			//cObservacao		:=  "Título gerado com sucesso no SE2"
			//MSMM("ZZA_OBSMEM",, , cObservacao, 1, , , "ZZA", "ZZA_OBSMEM")
			MsUnlock()
			cMsg := "Criação do(s) título(s) realizada(s) com sucesso no Contas a Pagar! "+Chr(10) + Chr (13)+" Ao fechar esssa mensagem, será(ão) atualizado(s) o Status (legenda) do(s) movimento(s) na rotina de 'Monitor de Integração Expense Mobi'.""
		EndIf

		(cAliQRY)->(dbskip())

	Enddo

	(cAliQRY)->(DbcloseArea())

	If cMsg == " "
		FWAlertHelp("Não existem movimentações para serem integradas no Contas a Pagar com os parâmetros informados! ", "Verifique os parâmetros e tente novamente!")
	Else
		FWAlertSuccess(cMsg, "Z_VDFIN3")
	EndIf
Return
