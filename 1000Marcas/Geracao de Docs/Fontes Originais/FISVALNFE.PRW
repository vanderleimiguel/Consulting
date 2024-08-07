#include 'protheus.ch'
#include 'parmtype.ch'

//-------------------------------------------------------------------
/*/{Protheus.doc} FISVALNFE
@description    Este ponto de entrada foi disponibilizado a fim de 
				permitir a valida��o da transmiss�o  das Notas Fiscais 
				pela rotina SPEDNFE.
@link			https://tdn.totvs.com/pages/releaseview.action?pageId=6077186
@author			Jos� Eul�lio
@since     		09/06/2020
/*/			
//-------------------------------------------------------------------
User Function FISVALNFE()
	Local lTransmite	:= .T.
	Local cTipo			:= PARAMIXB[1]
	Local cFilNota		:= PARAMIXB[2]
	Local cEmissao		:= PARAMIXB[3]
	Local cNota			:= PARAMIXB[4]
	Local cSerie		:= PARAMIXB[5]
	Local cClieFor		:= PARAMIXB[6]
	Local cLoja			:= PARAMIXB[7]
	Local cEspec		:= PARAMIXB[8]
	Local cFormul		:= PARAMIXB[9]
	Local cChave		:= cFilNota+cNota+cSerie+cClieFor+cLoja
	Local aAreaSF2		:= SF2->(GetArea())

	SF2->(dbSetOrder(1)) //F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO

//Posiciona Cabe�alho da Nota e verifica se n�o tem transportadora
	If SF2->(dbseek(cChave)) .And. (SF2->F2_FIMP==' ' /*.Or. SF2->F2_FIMP=='S'*/)
		lTransmite := U_TRANSCIF(cChave)
		If !lTransmite
			Alert("Transmiss�o n�o permitida! Documento/S�rie: " + cNota + "/" + cSerie + " n�o cont�m uma transportadora relacionada.")
		EndIf
	EndIf

	RestArea(aAreaSF2)

Return lTransmite

//-------------------------------------------------------------------
/*/{Protheus.doc} TRANSCIF
@description    Retorna falso se a Nota indicada n�o tem Transportadora
 				e tem frete do tipo CIF
@author			Jos� Eul�lio
@since     		09/06/2020
/*/			
//-------------------------------------------------------------------
User Function TRANSCIF(cChave)
	Local lTransmite	:= .T.
	Local aAreaSD2		:= SD2->(GetArea())
	Local aAreaSC5		:= SC5->(GetArea())

	Default cChave		:= SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

	SD2->(dbSetOrder(3)) //D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA+D2_COD+D2_ITEM
	SC5->(DbSetOrder(1)) //C5_FILIAL+C5_NUM

	If Empty(SF2->F2_TRANSP)
		//Posiciona nos itens
		If SD2->(dbseek(cChave))
			//Roda os itens
			While !(SD2->(EoF())) .AND. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == cChave
				//Busca pedido
				If SC5->(DbSeek(xFilial("SC5",SF2->F2_FILIAL) + SD2->D2_PEDIDO))
					//verifica tipo de frete se � CIF
					If SC5->C5_TPFRETE == "C"
						lTransmite := .F.
						Exit
					EndIf
				EndIf
				SD2->(dbSkip())
			EndDo
		EndIf
	EndIf

	RestArea(aAreaSD2)
	RestArea(aAreaSC5)
Return lTransmite
