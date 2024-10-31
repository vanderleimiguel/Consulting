#include 'totvs.ch'
#include 'protheus.ch'
#include 'topconn.ch'

//-----------------------------------------------------------------------
/*/{Protheus.doc} BIOPENFSE
Ponto de entrada especifico BIOAGRI para inclusão de mensagens diversas
na NFS-e.

@author Leonardo Azevedo
@since 16.05.2014

@param	cDiscrNFSe		Variavel contendo as mensagens.
@param	aDupl			Array contendo as duplicatas geradas.

@return
/*/
//-----------------------------------------------------------------------

User Function BIOPENFSE(cDiscrNFSe,aDuplic,lGerNota)

//Adicionado Leonardo Azevedo - 15/04/14 - campos para controle de mensagens
Local nMesVenc		:= 0
Local nAnoVenc		:= 0
Local dVencto		:= CTOD("")
Local cObs			:= ""
Local cZZDescri		:= ""
Local aArea			:= Lj7GetArea({"SD2","SF2","SC5","SC6","SE1"})
Local aAreaSC6
Local cAliasSE1		:= "SE1"
Local cTipoPcc		:= "PIS','COF','CSL','CF-','PI-','CS-','IR-"
Local cMV_LJTPNFE	:= SuperGetMV("MV_LJTPNFE", ," ")
Local cWhere	 	:= ""
Local cAliasSD2  	:= "SD2"
Local cField     	:= ""
Local nRetPis		:= 0
Local nRetCof		:= 0
Local nRetCsl		:= 0
Local nRetIr		:= 0
Local nValFat		:= 0
Local nValDesc		:= 0
Local nI			:= 0
Local cQrySE1		:= ""
Local cQrySD2		:= ""
Local cQrySC5		:= ""
Local cMenNf		:= ""
//Fim

// DTM | IT [Rodrigo Mello 13/09/2018 - Mensagens de acumulo PCC/IR]
Local cAlias		:= ""
Local x				:= 0
// Vars Demon Acum PCC/IR [DTM]  
Local cDocsAcumPCC	:= " "
Local cDocsAcumIR	:= " "

default lGerNota := .f.

//Adicionado Leonardo Azevedo - 15/04/14 - alimenta variaveis para controle de mensagens
cLJTPNFE := (StrTran(cMV_LJTPNFE," ,"," ','"))+" "
cWhere := cLJTPNFE

dbSelectArea("SE1")
dbSetOrder(1)

cAliasSE1 := GetNextAlias()
BeginSql Alias cAliasSE1
	COLUMN E1_VENCORI AS DATE
	SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VENCORI,E1_VALOR,E1_ORIGEM,E1_CSLL,E1_COFINS,E1_PIS,E1_VENCREA
	FROM %Table:SE1% SE1
	WHERE
	SE1.E1_FILIAL = %xFilial:SE1% AND
	SE1.E1_PREFIXO = %Exp:SF2->F2_PREFIXO% AND
	SE1.E1_NUM = %Exp:SF2->F2_DUPL% AND
	((SE1.E1_TIPO = %Exp:MVNOTAFIS%) OR
	 SE1.E1_TIPO IN (%Exp:cTipoPcc%) OR
	 (SE1.E1_ORIGEM = 'LOJA701' AND SE1.E1_TIPO IN (%Exp:cWhere%))) AND
	SE1.%NotDel%
	ORDER BY %Order:SE1%
EndSql

While !Eof() .And. xFilial("SE1") == (cAliasSE1)->E1_FILIAL .And.;
	SF2->F2_PREFIXO == (cAliasSE1)->E1_PREFIXO .And.;
	SF2->F2_DOC == (cAliasSE1)->E1_NUM

	If (cAliasSE1)->E1_TIPO $ "PIS,PI-"
		nRetPis	:= 	(cAliasSE1)->E1_VALOR
		If 	nMesVenc == 0
			nMesVenc 	:= Month(STOD((cAliasSE1)->E1_VENCREA))
			dVencto		:=	(cAliasSE1)->E1_VENCREA
		EndIf
		If 	nAnoVenc == 0
			nAnoVenc	:= Year(STOD((cAliasSE1)->E1_VENCREA))
		EndIf
	ElseIf (cAliasSE1)->E1_TIPO $ "COF,CF-"
		nRetCof	:= 	(cAliasSE1)->E1_VALOR
	ElseIf (cAliasSE1)->E1_TIPO $ "CSL,CS-"
		nRetCsl	:= 	(cAliasSE1)->E1_VALOR
	ElseIf (cAliasSE1)->E1_TIPO $ "IR-"
		nRetIr	:= 	(cAliasSE1)->E1_VALOR
	EndIf

	dbSelectArea(cAliasSE1)
	dbSkip()
EndDo
//Fim

//Adicionado Leonardo Azevedo - 26/06/13
cField := "%"

If SD2->(FieldPos("D2_TOTIMP"))<>0
   cField  +=",D2_TOTIMP"
EndIf

If SD2->(FieldPos("D2_DESCICM"))<>0
   cField  +=",D2_DESCICM"
EndIf

cField += "%"

dbSelectArea("SD2")
dbSetOrder(3)

cAliasSD2 := GetNextAlias()
BeginSql Alias cAliasSD2
	SELECT D2_FILIAL,D2_SERIE,D2_DOC,D2_CLIENTE,D2_LOJA,D2_COD,D2_TES,D2_NFORI,D2_SERIORI,D2_ITEMORI,D2_TIPO,D2_ITEM,D2_CF,
		D2_QUANT,D2_TOTAL,D2_DESCON,D2_VALFRE,D2_SEGURO,D2_PEDIDO,D2_ITEMPV,D2_DESPESA,D2_VALBRUT,D2_VALISS,D2_PRUNIT,
		D2_CLASFIS,D2_PRCVEN,D2_CODISS,D2_DESCZFR,D2_PREEMB,D2_BASEISS,D2_VALIMP1,D2_VALIMP2,D2_VALIMP3,D2_VALIMP4,D2_VALIMP5,D2_PROJPMS %Exp:cField%,
		D2_VALPIS,D2_VALCOF,D2_VALCSL,D2_VALIRRF,D2_VALINS
	FROM %Table:SD2% SD2
	WHERE
	SD2.D2_FILIAL = %xFilial:SD2% AND
	SD2.D2_SERIE = %Exp:SF2->F2_SERIE% AND
	SD2.D2_DOC = %Exp:SF2->F2_DOC% AND
	SD2.D2_CLIENTE = %Exp:SF2->F2_CLIENTE% AND
	SD2.D2_LOJA = %Exp:SF2->F2_LOJA% AND
	SD2.%NotDel%
	ORDER BY %Order:SD2%
EndSql

While !(cAliasSD2)->(Eof()) .And. xFilial("SD2") == (cAliasSD2)->D2_FILIAL .And.;
	SF2->F2_SERIE == (cAliasSD2)->D2_SERIE .And.;
	SF2->F2_DOC == (cAliasSD2)->D2_DOC

	dbSelectArea("SC5")
	dbSetOrder(1)
	If DbSeek(xFilial("SC5")+(cAliasSD2)->D2_PEDIDO)
		aAreaSC6 := SC6->(GetArea())

		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek(xFilial("SC6")+SC5->C5_NUM)
			While !SC6->(eof()) .and. SC6->C6_NUM == SC5->C5_NUM
				If !Empty(cZZDescri)
					cZZDescri	+= "; "
				EndIf
				//----------------------------------------------------|
				// Raphael Kouy Giusti - 26/10/2016					  |
				// Se o item for liberado, compõe a descrição.  	  |
				//----------------------------------------------------|
				If SC6->C6_QTDLIB > 0 
					cZZDescri	+= alltrim(SC6->C6_DESCRI)+" "
				EndIf
				SC6->(dbSkip())
			EndDo
		EndIf
		RestArea(aAreaSC6)
		
	EndIf
	dbSelectArea(cAliasSD2)
	dbSkip()
EndDo
			//----------------------------------------------------|
	   		//Verifica se existe mais de um pedido para a RPS, 	  |
	   		//se existir mantém uma única mensagem para a RPS.	  |
	   		//----------------------------------------------------|
	   		// Raphael Koury Giusti  | Data: 28/06/2017			  |
	   		//----------------------------------------------------|				
			cQrySC5 += " SELECT COUNT(C5_NUM) QTDPEDIDO "
			cQrySC5 += " FROM "+RetSQLName("SC5")+" SC5 "
			cQrySC5 += " WHERE "
			cQrySC5 += " C5_NOTA = '"+Alltrim(SF2->F2_DOC)+"' "
			cQrySC5 += " AND C5_FILIAL = '"+xFilial("SF2")+"' "
			cQrySC5 += " AND D_E_L_E_T_ = '' " 
			cQrySC5 += " GROUP BY C5_NOTA "	
			
			if select('TSC5') <> 0
				TSC5->(dbCloseArea())
			endIf			
				
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQrySC5),'TSC5',.F.,.T.)
					
		if 	TSC5->QTDPEDIDO > 1
			cQrySD2 += " SELECT DISTINCT C5.C5_NUM PEDIDO, C5.C5_MENNOTA MENSAGEM, C5.R_E_C_N_O_ RECNO "
			cQrySD2 += " FROM "+RetSQLName("SD2")+" D2 "
			cQrySD2 += " INNER JOIN "+RetSQLName("SC5")+" C5 ON C5.C5_FILIAL = D2.D2_FILIAL AND C5.C5_NUM = D2.D2_PEDIDO AND C5.D_E_L_E_T_ = '' "
			cQrySD2 += " WHERE D2.D2_DOC = '"+Alltrim(SF2->F2_DOC)+"' "
			cQrySD2 += " AND D2_FILIAL = '"+xFilial("SF2")+"'
			cQrySD2 += " AND D2.D_E_L_E_T_ = '' "
			
			if select('TQSD2') <> 0
				TQSD2->(dbCloseArea())
			endIf			
			
			dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQrySD2),'TQSD2',.F.,.T.)
			TQSD2->(dbGoTop())
			
			//Pega a mensagem de um pedido
			while TQSD2->(!Eof())   
			 	if !Empty(TQSD2->MENSAGEM)
			 		cMenNf := Alltrim(TQSD2->MENSAGEM)
			 	endif
			 	TQSD2->(dbSkip())
			enddo
			
			//Realiza a gravação da mensagem em todos os pedidos.
			if !Empty(cMenNf)
				TQSD2->(dbGoTop())
						
				while TQSD2->(!Eof())
				   dbSelectArea("SC5")
				   if dbSeek(xFilial("SC5")+Alltrim(TQSD2->PEDIDO))	
				   		RecLock("SC5",.f.)
				   			SC5->C5_MENNOTA := Alltrim(cMenNF)
				   		MsUnLock()
				   endif
				   SC5->(dbCloseArea())
				   TQSD2->(dbSkip())
			 	enddo
			endif
			
			 TQSD2->(dbCloseArea())
			 TSC5->(dbCloseArea())
			
			cDiscrNFSe += Alltrim(cMenNf)
		endif
//Fim

//Adicionado Leonardo Azevedo - 15/04/14 - mensagens das faturas na NFS-e
//DESCRICAO DOS PRODUTOS NA SC6
/*
If !Empty(cZZDescri)
	If Len(cDiscrNFSe) > 0 .And. SubStr(cDiscrNFSe, Len(cDiscrNFSe), 1) <> " "
		cDiscrNFSe += CHR(13)+CHR(10)
	EndIf
	cDiscrNFSe += " "+alltrim(cZZDescri)
EndIf

//MENSAGEM DE NOTAS QUE COMPOE O CALCULO DO(S) IMPOSTO(S)
If 	nRetPis > 0
	cObs := VerImpRet( nMesVenc , nAnoVenc , dVencto , SF2->F2_PREFIXO , SF2->F2_DUPL , SF2->F2_PREFIXO , SF2->F2_CLIENT , SF2->F2_LOJA )
	If !Empty(cObs)
		If Len(cDiscrNFSe) > 0 .And. SubStr(cDiscrNFSe, Len(cDiscrNFSe), 1) <> " " .and. !lGerNota
			cDiscrNFSe += CHR(13)+CHR(10)
		EndIf
		cDiscrNFSe += " "+alltrim(cObs)
	EndIf
EndIf*/
//FATURAS E VALORES
For nI := 1 to len(aDuplic)
	If !Empty(aDuplic[nI,2]) //.And. !AllTrim(DTOC(aDupl[nI,2])+"-"+alltrim(Transform(aDupl[nI,3],"@E 999,999,999.99"))) $ cDiscrNFSe
		If Len(cDiscrNFSe) > 0 .And. SubStr(cDiscrNFSe, Len(cDiscrNFSe), 1) <> " "
			If nI == 1
				if !lGerNota
					cDiscrNFSe += CHR(13)+CHR(10)+CHR(13)+CHR(10)
				endif
				cDiscrNFSe += " FATURAS: "
			Else
				cDiscrNFSe += " | "
			EndIf
		Else 
			cDiscrNFSe += " FATURA: "
		EndIf
		
		nValTot := fGetDesc(aDuplic[nI,1],cTipoPcc)
		nValFat := aDuplic[nI,3] - nValTot //aDuplic[nI,3] - (nRetPis+nRetCof+nRetCsl+nRetIr)
		
		//-----------------------------------------|
		// Query que realiza a busca do vencimento |
		// real do título da fatura.			   |
		//-----------------------------------------|
		cQrySE1 := ""
		cQrySE1 += " select SE1.E1_VENCREA, SE1.E1_PARCELA, SE1.E1_VALOR, SE1.R_E_C_N_O_ AS E1_RECNO from "+RetSQLName("SE1")+" SE1 "
		cQrySE1 += " where SE1.E1_PREFIXO = '"+Alltrim(SubStr(aDuplic[nI,1],1,3))+"' "
		cQrySE1 += " and SE1.E1_NUM = '"+Alltrim(SubStr(aDuplic[nI,1],4,9))+"' "
		cQrySE1 += " and SE1.E1_VALOR = '"+cValToChar(aDuplic[nI,3])+"' "
		cQrySE1 += " and SE1.E1_TIPO = 'NF' "
		cQrySE1 += " and SE1.E1_PARCELA = '"+Alltrim(aDuplic[nI,4])+"' "
		cQrySE1 += " and SE1.E1_FILORIG = '"+xFilial("SF2")+"' "
		
		if select("QryE1") <> 0
			QryE1->(dbCloseArea())
		endIf
				
		TcQuery cQrySE1 ALIAS "QryE1" NEW
	
		memowrite("C:\Query\SE1.txt",cQrySE1)
	
		TcSetField("QryE1","E1_VENCREA","D",8,0)
		
		dbSelectArea("QryE1")
		QryE1->(dbGoTop())
		
		/*--------------------------------------------------------------------------\
		| DTM | IT Sofware Solutions                                    05/11/2018  |
		| Autor: Rodrigo Mello                                                      |
		| Objetivo: Adicionar valores de retencao do PCC Baixa                      |
		\--------------------------------------------------------------------------*/
		dbSelectArea("SE1")
		SE1->(dbGoTo(QryE1->E1_RECNO))
		If SuperGetMv('ZZ_UPDPCC5',.F.,.T.)
			aPCC := newMinPcc(DataValida(SE1->E1_VENCTO,.T.), SE1->E1_SALDO, SE1->E1_NATUREZ, "R", SA1->(A1_COD+A1_LOJA))
			nValFat -= aPCC[2] // PIS - Baixa
			nValFat -= aPCC[3] // COF - Baixa
			nValFat -= aPCC[4] // CSL - Baixa
		EndIf
		/*-------------------------------------------------------------------------*/ 
		
		//cDiscrNFSe += AllTrim(DTOC(aDuplic[nI,2])+" - R$ "+alltrim(Transform(nValFat,"@E 999,999,999.99")))
		cDiscrNFSe += Alltrim(DTOC(QryE1->E1_VENCREA)+" - R$ "+alltrim(Transform(nValFat,"@E 999,999,999.99")))
		
	EndIf
Next
//Fim

//------------------------------------------------------|
// Solicitado a inclusão da observação abaixo pelo 		|
// chamado https://ssp.mxns.com/helpdesk/tickets/3959	|
// atendendo uma solicitação do cliente.				|
//------------------------------------------------------|
if(SC5->C5_CLIENTE == "469400")
	cDiscrNFSe += "	- Servico efetuado com suspensao da exigencia da Contribuicao para o PIS PASEP e da COFINS  "+;
					  "conforme Ato Declaratorio Executivo n 117  de 04 de julho de 2017  Portaria n 60 de "+; 
					  "10 de marco de 2017  do Ministerio de Minas e Energia de acordo com os art 1 ao 5 da "; 
					  +"Lei 1.488 de 15 06 2007, Decreto 6.144 de 03/07/20017 e alteracoes - REIDI - "
endif

/*============================================================================\
| DTM | IT [Rodrigo Mello - 13/09/2018] Mensagens Acumulo do PCC              |
|==============================================================================
|     Funcao para apresentacao dos documentos relacionado a base de calculo   |
| de impostos. PCC / IR                                                       |
=============================================================================*/
for x:=1 to Len(aDuplic)
	// Acumulo PCC
	If GetMV('MV_BR10925') == '1'  // PCC na Baixa Doc. Saida
		cAlias := GetNextAlias()
		BeginSQL Alias cAlias
			SELECT
					E1B.E1_NUM + '-' + E1B.E1_PARCELA as DOCUMENTO
			FROM 
					%Table:SE1% E1A
				INNER JOIN %Table:SE1% E1B (NOLOCK)
					ON  E1B.%notdel% 
					AND E1A.E1_CLIENTE	= E1B.E1_CLIENTE
					AND E1A.E1_NUM		<>	E1B.E1_NUM
					AND E1B.E1_PIS+E1B.E1_COFINS+E1B.E1_CSLL > 0 
					AND E1B.E1_VENCORI	= %Exp:aDuplic[x,2]%
					AND E1A.E1_EMISSAO  >= E1B.E1_EMISSAO
			WHERE 
					E1A.D_E_L_E_T_		= '' 
				AND E1A.E1_FILIAL		= %xFilial:SE1%
				AND E1A.E1_PREFIXO + E1A.E1_NUM + E1A.E1_PARCELA	= %Exp:aDuplic[x,1]%
				AND E1A.E1_TIPO			= 'NF'
				AND E1A.E1_CLIENTE		= %Exp:SF2->F2_CLIENTE%
				AND E1A.E1_LOJA			= %Exp:SF2->F2_LOJA%
				AND E1A.E1_VENCORI		= %Exp:aDuplic[x,2]% 
			GROUP BY 
					E1B.E1_NUM, 
					E1B.E1_PARCELA
			ORDER BY 
					E1B.E1_NUM, 
					E1B.E1_PARCELA
		EndSQL
	
		While (cAlias)->(!Eof())
			If .NOT.(cAlias)->DOCUMENTO $ cDocsAcumPCC 
				cDocsAcumPCC += (cAlias)->DOCUMENTO
			EndIf
			(cAlias)->(dbSkip())
			If (cAlias)->(!Eof())
				cDocsAcumPCC += '/'
			EndIf
		EndDo
	
		(cAlias)->(dbCloseArea())
	EndIf

	If GetMV('MV_AGLIMPJ') == '3' .and. GetMV('MV_ACMIRPJ') == '1' // Aglutina IRRF por Raiz CNPJ .and. Gera IRRF Emissao 
		cAlias := GetNextAlias()
		BeginSQL Alias cAlias
			SELECT
					E1B.E1_NUM + '-' + E1B.E1_PARCELA as DOCUMENTO
			FROM 
					%Table:SE1% E1A
				INNER JOIN %Table:SE1% E1B (NOLOCK)
					ON  E1B.%notdel% 
					AND E1A.E1_CLIENTE	= E1B.E1_CLIENTE
					AND E1A.E1_NUM		<>	E1B.E1_NUM
					AND E1B.E1_VRETIRF	> 0 
					AND E1A.E1_EMISSAO	= E1B.E1_EMISSAO
			WHERE 
					E1A.D_E_L_E_T_		= '' 
				AND E1A.E1_FILIAL		= %xFilial:SE1%
				AND E1A.E1_PREFIXO + E1A.E1_NUM + E1A.E1_PARCELA	= %Exp:aDuplic[x,1]%
				AND E1A.E1_TIPO			= 'NF'
				AND E1A.E1_CLIENTE		= %Exp:SF2->F2_CLIENTE%
				AND E1A.E1_LOJA			= %Exp:SF2->F2_LOJA%
				AND E1A.E1_EMISSAO		= %Exp:SF2->F2_EMISSAO% 
			GROUP BY 
					E1B.E1_NUM,
					E1B.E1_PARCELA
			ORDER BY 
					E1B.E1_NUM,
					E1B.E1_PARCELA
		EndSQL
	
		While (cAlias)->(!Eof())
			If !(cAlias)->DOCUMENTO $ cDocsAcumIR
				cDocsAcumIR += (cAlias)->DOCUMENTO
			EndIf
			(cAlias)->(dbSkip())
			If (cAlias)->(!Eof())
				cDocsAcumIR += '/'
			EndIf
		EndDo
	
		(cAlias)->(dbCloseArea())
	EndIf

next x

If !Empty(cDocsAcumPCC)
	cDiscrNFSe += CRLF 
	cDiscrNFSe += " Documentos relacionados a base de calculo PIS/COFINS/CSLL: " + cDocsAcumPCC
EndIf
If !Empty(cDocsAcumIR)
	cDiscrNFSe += CRLF 
	cDiscrNFSe += " Documentos relacionados a base de calculo IRRF: " + cDocsAcumIR
EndIf

Lj7RestArea(aArea)

Return

/*/{Protheus.doc} VerImpRet
Função para busca de notas anteriores a nota atual cuja soma ocasione
retenção de PIS, COFINS e CSLL

@author Leonardo Azevedo
@since 16.05.2014

@param	nMesVenc		Variavel contendo o mês do vencimento do titulo de IPI.
@param	nAnoVenc		Variavel contendo o ano do vencimento do titulo de IPI.
@param	dVencto		Variavel contendo a data do vencimento do titulo de IPI.
@param	XPREFIXO		Variavel contendo o prefixo do titulo atual.
@param	xNUM_DUPLIC	Variavel contendo o numero da duplicata atual.
@param	xSERIE			Variavel contendo a serie da duplicata atual.
@param	xCLIENTE		Variavel contendo o cliente da duplicata atual.
@param	xLOJA			Variavel contendo a Loja da duplicata atual.

@return
/*/
//-----------------------------------------------------------------------
/*
Static Function VerImpRet( nMesVenc , nAnoVenc , dVencto , XPREFIXO , xNUM_DUPLIC , xSERIE , xCLIENTE , xLOJA )

Local cRet		:=	""
Local cTSE1 	:= 	""
Local cQSE1 	:= 	""
Local cQry		:=	""
Local cQry2		:=	""

cQSE1 := GetNextAlias()
cTSE1 := GetNextAlias()

If nMesVenc <> 0 .and. nAnoVenc <> 0 .and. !Empty(dVencto)

	BeginSql Alias cQSE1
		COLUMN E1_VENCREA AS DATE
		SELECT MIN(E1_NUM) NUM
		FROM %Table:SE1% SE1
		WHERE
		SE1.E1_FILIAL          = %xFilial:SE1%  AND
		SE1.E1_CLIENTE         = %Exp:xCLIENTE% AND
		SE1.E1_LOJA            = %Exp:xLOJA%    AND
		SE1.E1_TIPO            = %Exp:"PI-"%    AND
		SE1.E1_PREFIXO         = %Exp:XPREFIXO% AND
		MONTH(SE1.E1_VENCREA)  = %Exp:nMesVenc% AND
		YEAR(SE1.E1_VENCREA)   = %Exp:nAnoVenc% AND
		SE1.E1_VENCREA        >= %Exp:dVencto%  AND
		SE1.%NotDel%
	EndSql

	If	(cQSE1)->NUM == xNUM_DUPLIC
		BeginSql Alias cTSE1
			COLUMN E1_VENCREA AS DATE
			SELECT E1_FILIAL,E1_PREFIXO,E1_NUM,E1_SERIE,E1_PARCELA,E1_TIPO,E1_VENCREA,E1_VALOR
			FROM %Table:SE1% SE1
			WHERE
			SE1.E1_FILIAL         = %xFilial:SE1%      AND
			SE1.E1_CLIENTE        = %Exp:xCLIENTE%     AND
			SE1.E1_LOJA           = %Exp:xLOJA%        AND
			SE1.E1_TIPO           = %Exp:"NF"%         AND
			SE1.E1_PREFIXO        = %Exp:XPREFIXO%     AND
			MONTH(SE1.E1_VENCREA) = %Exp:nMesVenc%     AND
			YEAR(SE1.E1_VENCREA)  = %Exp:nAnoVenc%     AND
			SE1.E1_VENCREA       <= %Exp:dVencto%      AND
			SE1.E1_NUM           <= %Exp:xNUM_DUPLIC%  AND
			SE1.%NotDel%
			ORDER BY %Order:SE1%
		EndSql
	EndIf

/*	If 	Select(cTSE1) > 0
		cRet += 'Relacao de NFs que compuseram o valor da Retencao (PIS-COFINS-CSLL): '
		While !(cTSE1)->(Eof())
			cRet += (cTSE1)->E1_TIPO + ' ' + AllTrim((cTSE1)->E1_NUM) + '-' + (cTSE1)->E1_SERIE + ' ' +  DtoC((cTSE1)->E1_VENCREA) + ' - '
			dbSelectArea(cTSE1)
			dbSkip()
		EndDo
	EndIf
*/
/*	cQSE1->(dbCloseArea())
	cTSE1->(dbCloseArea())
EndIf

If !Empty(cRet)
	cRet := Substr( Alltrim(cRet) , 01 , ( Len(Alltrim(cRet)) - 1 ) )
EndIf

Return cRet*/

//-----------------------------------------------------------------------
/*/{Protheus.doc} fGetDesc
Função para somar os valores dos titulos de impostos (PI-,CS-,CF- e IR-)
para cada parcela dos titulos a serem listados nas observações da NFS-e

@author Leonardo Azevedo
@since 27.06.2014

@return
/*/
//-----------------------------------------------------------------------

Static Function fGetDesc(cNumTit,cTipoPcc)

Local cQry := ""
Local nVal := 0
Local cZZSE1 := GetNextAlias()

BeginSql Alias cZZSE1
	SELECT SUM(SE1.E1_VALOR) AS TOTAL
	FROM %Table:SE1% SE1
	WHERE
	SE1.E1_FILIAL = %xFilial:SE1% AND
	SE1.E1_PREFIXO = %Exp:Substr(cNumTit,1,TamSX3("E1_PREFIXO")[1])% AND
	SE1.E1_NUM = %Exp:Substr(cNumTit,TamSX3("E1_PREFIXO")[1]+1,TamSX3("E1_NUM")[1])% AND
	SE1.E1_PARCELA = %Exp:Substr(cNumTit,(TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+1),TamSX3("E1_PARCELA")[1])% AND
	SE1.E1_TIPO IN (%Exp:cTipoPcc%) AND
	SE1.%NotDel%
EndSql

If 	Select(cZZSE1) > 0
	nVal := (cZZSE1)->TOTAL
EndIf

//cZZSE1->(dbCloseArea())

Return nVal