#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.CH"
#include 'dbtree.ch'

//Variáveis que existirão mesmo após sair do prw
Static cEmpBkp := ""
Static cFilBkp := ""
Static nTotRegua := 0
Static nAtuRegua := 0
Static nPerRegua := 0
Static aRegua1   := {.F., .F., .F.}

/*/{Protheus.doc} SPCTRFAF
Funcao para processamento de transferencia de ativos
@author Wagner Neves
@since 06/05/2024
@version 1.0
@type function
/*/
User Function SPCTRFAF()
	Private oDlg
	Private _oOk      := LoadBitmap(GetResources(),"LBOK")
	Private _oNo      := LoadBitmap(GetResources(),"LBNO")
	Private oCinza    := LoadBitmap(GetResources(),"BR_CINZA")
	Private oAmarelo  := LoadBitmap(GetResources(),"BR_AMARELO")
	Private oVerde    := LoadBitmap(GetResources(),"BR_VERDE")
	Private oVermelho := LoadBitmap(GetResources(),"BR_VERMELHO")
	Private oLaranja  := LoadBitmap(GetResources(),"BR_LARANJA")
	Private oVerdeE   := LoadBitmap(GetResources(),"BR_VERDE_ESCURO")
	Private oAzulCl   := LoadBitmap(GetResources(),"BR_AZUL_CLARO")
	Private oAzul     := LoadBitmap(GetResources(),"BR_AZUL")
	Private oPreto    := LoadBitmap(GetResources(),"BR_PRETO")
	Private oMarron   := LoadBitmap(GetResources(),"BR_MARROM_OCEAN")
	Private oCancela  := LoadBitmap(GetResources(),"BR_CANCEL")
	Private oVioleta  := LoadBitmap(GetResources(),"BR_VIOLETA")
	Private oBandVerm := LoadBitmap(GetResources(),"IC_TOOLBARSTATUS_RED")
	Private oBandAmar := LoadBitmap(GetResources(),"IC_TOOLBARSTATUS_BLUE")
	Private oBandVerd := LoadBitmap(GetResources(),"IC_TOOLBARSTATUS_GREEN")
	Private oFont     := TFont():New("Times New Roman",09,10,,.T.,,,,.T.)
	Private oFont1    := TFont():New("Times New Roman",14,14,,.T.,,,,.T.)
	Private cTime     := ""
	Private oCor      := oCinza
	Private oCorSit   := oBandVerd
	Private oGroup, oGroupCli, oGroupATV
	Private oSayDir, oSayDescNat
	Private oGetDir, oGetNomeBanco
	Private oBtnCar, oBtnExp, oBtnSai, oBtnLeg, oBtnCont, oBtnMvC
	Private oSayOGrp, oGetOGrp, oGetOGrp2, oSayODG1, oGetODG1, oSayOFil, oGetOFil, oGetOFil2, oSayODE1, oGetODE1
	Private oSayDGrp, oGetDGrp, oGetDGrp2, oSayDDG1, oGetDDG1, oSayDFil, oGetDFil, oGetDFil2, oSayDDE1, oGetDDE1
	Private oBtnGrv
	Private oBtnVis
	Private oProcess
	Private oProcess2
	Private oProcess3
	Private cDir := ""
	Private cNome, cCNPJ, cBanco, cAgencia, cConta, cNomeBanco, cNatureza, cDescNat, cLojDevNew, cStATVBx, cSTTitBx
	Private nValor, nQuant, nOpcLog
	Private cOriGrp, cOriDesGrp, cOriFil, cOriDesFil
	Private cDesGrp, cDesDesGrp, cDesFil, cDesDesFil
	Private dDtArq
	Private aHeaderATV := {}
	Private aFieldsATV := {}
	Private aLogBx     := {}
	Private lMarca     := .T.
	Private aFile      := {}
	Private cCodUser   := RetCodUsr()
	Private cAliasTmp  := "SZZ_" + cCodUser
	Private lProcess   := .F.

	nValor := 0
	nQuant := 0

	//Monta tela
	fMontaTela()

Return()

/*---------------------------------------------------------------------*
 | Func:  fMontaTela                                                   |
 | Desc:  Função que monta tela     	                               |
 *---------------------------------------------------------------------*/
Static Function fMontaTela()

	Local cEstBT, cEstBTGrv, cEstBTCan, cEstBTExp, cEstBTSai, cEstBTVal, cEstBTLeg, cEstGet, cEstGet2, cEstPanel, cEstPanelBranco, cEstSay

	aHeaderATV := {"Imp","Proc","Chave","Cod_Grupo","Cod_Bem", "Item", "Dt_Aquis", "Descr_Bem", "Plaqueta", "Inicio_Depr", "Valor_Orig", "Taxa_Depr", "Depr_Balanco",;
		"Depr_Mes", "Depr_Acum", "Saldo", "Data_Baixa", "Observação","Grupo"}

	Aadd(aFieldsATV, {oCorSit,oCor,"", "", "", "", "", "", "", "", "", "", "", "","","","","","","","",""})

	cNatureza := Space(5)

	DEFINE DIALOG oDlg TITLE "Importação, Baixa e Geração Ativo Fixo" FROM 180,180 TO 230,345 // Usando o método New

//Esta parte é a responsável pela criação dos estilos que serão aplicados em cada objeto posteriormente
	cEstBT    := "QPushButton {background-image: url(rpo:totvsprinter_excel.png);background-repeat: none; margin: 2px;}"
	cEstBTGrv := "QPushButton {background-image: url(rpo:icone_ok.jpg);background-repeat: none; margin: 2px; font: bold 12px Arial;}"
	cEstBTCan := "QPushButton {background-image: url(rpo:bmpdel_mdi.png);background-repeat: none; margin: 4px; font: bold 12px Arial;}"
	cEstBTExp := "QPushButton {background-image: url(rpo:checked.png);background-repeat: none; margin: 4px; font: bold 12px Arial;}"
	cEstBTSai := "QPushButton {background-image: url(rpo:final_mdi.png);background-repeat: none; margin: 4px; font: bold 12px Arial;}"

	cEstBTVal := "QPushButton {background-image: url(rpo:checked.png);background-repeat: none; margin: 2px;"
	cEstBTVal += "background-color: #FFFFFF;"
	cEstBTVal += " border-style: outset;"
	cEstBTVal += " border-width: 2px;"
	cEstBTVal += " border: 1px solid #C0C0C0;"
	cEstBTVal += " border-radius: 5px;"
	cEstBTVal += " border-color: #C0C0C0;"
	cEstBTVal += " font: bold 12px Arial;"
	cEstBTVal += " padding: 6px;"
	cEstBTVal += "}"
	cEstBTVal += "QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }"

	cEstBTVis := "QPushButton {background-image: url(rpo:bmpcons.png);background-repeat: none; margin: 2px;"
	cEstBTVis += "background-color: #FFFFFF;"
	cEstBTVis += " border-style: outset;"
	cEstBTVis += " border-width: 2px;"
	cEstBTVis += " border: 1px solid #C0C0C0;"
	cEstBTVis += " border-radius: 5px;"
	cEstBTVis += " border-color: #C0C0C0;"
	cEstBTVis += " font: bold 12px Arial;"
	cEstBTVis += " padding: 6px;"
	cEstBTVis += "}"
	cEstBTVis += "QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }"

	cEstBTLeg := "QPushButton {background-image: url(rpo:ng_ico_legenda.png);background-repeat: none; margin: 2px;"
	cEstBTLeg += "background-color: #FFFFFF;"
	cEstBTLeg += " border-style: outset;"
	cEstBTLeg += " border-width: 2px;"
	cEstBTLeg += " border: 1px solid #C0C0C0;"
	cEstBTLeg += " border-radius: 5px;"
	cEstBTLeg += " border-color: #C0C0C0;"
	cEstBTLeg += " font: bold 12px Arial;"
	cEstBTLeg += " padding: 6px;"
	cEstBTLeg += "}"
	cEstBTLeg += "QPushButton:pressed { background-color: qlineargradient(x1: 0, y1: 0, x2: 0, y2: 1, stop: 0 #dadbde, stop: 1 #f6f7fa); }"

	cEstGet := "QLineEdit{ border: 1px solid gray;border-radius: 5px;background-color: #FFFFFF;selection-background-color: #CCCCCC;"
	cEstGet += "background-repeat: no-repeat;"
	cEstGet += "background-attachment: fixed;"
	cEstGet += "padding-left:5px;}"

	cEstGet2 := "QLineEdit{ border: 1px solid gray;border-radius: 5px;background-color: #CCCCCC;selection-background-color: #999999;"
	cEstGet2 += "background-repeat: no-repeat;"
	cEstGet2 += "background-attachment: fixed;"
	cEstGet2 += "padding-left:5px;}"

	cEstPanel := "QGroupBox {border: 1px solid gray;border-radius: 9px;margin-top: 0.5em;background-color: #99CCFF;}
	cEstPanel += "QGroupBox::title {subcontrol-origin: margin;left: 10px;padding: 0 3px 0 3px;background-color: #99CCFF;}

	cEstPanelBranco := "QGroupBox {border: 1px solid gray;border-radius: 9px;margin-top: 0.5em;background-color: none;}
	cEstPanelBranco += "QGroupBox::title {subcontrol-origin: margin;left: 10px;padding: 0 3px 0 3px;background-color: none;}

	cEstSay   := "QLabel {border: 1px solid gray;}

//Fim da seleção de estilos

//Janela 1 --------------------------------------------------------------------------------------------------------------------------------------------------------------
	oGroup   := TGroup():New(004,005,037,640,"",oDlg,,,.T.)
	oGetDir  := TGet():New(012,015,bSetGet(cDir),oDlg,470,015,  ,, ,,,   ,,.T.,,   ,{||.F. },   ,   ,,   ,   ,"",      ,,,,,,,"Arquivo:")
	oBtnCar  := TButton():New(010,484,"" 	                ,oDlg,{|| fAbreDir(@cDir) },20,20,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnVis  := TButton():New(010,550,"   Importar Arquivo" ,oDlg,{|| fImpAux(cDir)} ,70,20,,,.F.,.T.,.F.,,.F.,,,.F. )
//Janela 2--------------------------------------------------------------------------------------------------------------------------------------------------------------
	oGroupCli 	  := TGroup():New(038,005,115,640,"Dados dos Grupos/Filiais",oDlg,,,.T.)

	oSayOGrp      := TSay():New(050,015,{||"Grupo Origem:"   }     ,oDlg,,,.F.,,,.T.,,,080,15)
	@060, 015 MSGET  oGetOGrp VAR cOriGrp SIZE 035, 015 OF oDlg Picture "@!" COLORS 0, 16777215 PIXEL
	@120, 070 BTNBMP oGetOGrp2 RESOURCE "PESQUISA" SIZE 030, 030 OF oDlg ACTION cOriGrp := ChamaCons("SM0MRP",cOriGrp, "GrpOri") PIXEL
	oSayODG1      := TSay():New(050,060,{||"Descricao Grupo Origem:" }       ,oDlg,,,.F.,,,.T.,,,100,20)
	@060, 060 MSGET oGetODG1 VAR cOriDesGrp SIZE 110, 015 OF oDlg WHEN .F. Picture "@!" COLORS 0, 16777215 PIXEL
	oSayOFil      := TSay():New(050,195,{||"Filial Origem:"   }     ,oDlg,,,.F.,,,.T.,,,080,15)
	@060, 195 MSGET  oGetOFil VAR cOriFil SIZE 040, 015 OF oDlg Picture "@!" COLORS 0, 16777215 PIXEL
	@120, 440 BTNBMP oGetOFil2 RESOURCE "PESQUISA" SIZE 030, 030 OF oDlg ACTION cOriFil := ChamaCons("SM0",cOriFil, "FilOri") PIXEL
	oSayODE1      := TSay():New(050,245,{||"Descricao Filial Origem:" }       ,oDlg,,,.F.,,,.T.,,,100,20)
	@060, 245 MSGET oGetODE1 VAR cOriDesFil SIZE 110, 015 OF oDlg WHEN .F. Picture "@!" COLORS 0, 16777215 PIXEL

	oSayDGrp      := TSay():New(080,015,{||"Grupo Destino:"   }     ,oDlg,,,.F.,,,.T.,,,080,15)
	@090, 015 MSGET  oGetDGrp VAR cDesGrp SIZE 035, 015 OF oDlg Picture "@!" COLORS 0, 16777215 PIXEL
	@180, 070 BTNBMP oGetDGrp2 RESOURCE "PESQUISA" SIZE 030, 030 OF oDlg ACTION cDesGrp := ChamaCons("SM0MRP",cDesGrp, "GrpDes") PIXEL
	oSayDDG1      := TSay():New(080,060,{||"Descricao Grupo Destino:" }       ,oDlg,,,.F.,,,.T.,,,100,20)
	@090, 060 MSGET oGetDDG1 VAR cDesDesGrp SIZE 110, 015 OF oDlg WHEN .F. Picture "@!" COLORS 0, 16777215 PIXEL
	oSayDFil      := TSay():New(080,195,{||"Filial Destino:"   }     ,oDlg,,,.F.,,,.T.,,,080,15)
	@090, 195 MSGET  oGetDFil VAR cDesFil SIZE 040, 015 OF oDlg Picture "@!" COLORS 0, 16777215 PIXEL
	@180, 440 BTNBMP oGetDFil2 RESOURCE "PESQUISA" SIZE 030, 030 OF oDlg ACTION cDesFil := ChamaCons("SM0",cDesFil, "FilDes") PIXEL
	oSayDDE1      := TSay():New(080,245,{||"Descricao Filial Destino:" }       ,oDlg,,,.F.,,,.T.,,,100,20)
	@090, 245 MSGET oGetDDE1 VAR cDesDesFil SIZE 110, 015 OF oDlg WHEN .F. Picture "@!" COLORS 0, 16777215 PIXEL

//--------------------------------------------------------------------------------------------------------------------------------------------------------------
	oBtnLeg       := TButton():New(080,550,"   Legenda",oDlg,{|| fLegendaATV() },70,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGroupATV := TGroup()  :New(120,005,350,640,"Registros que compõem o arquivo",oDlg,,,.T.)
	oBrw      := TWBrowse():New(130,010,620,220,,aHeaderATV,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	oBrw:SetArray(aFieldsATV)
	oBrw:bLine      := {|| {;
		aFieldsATV[oBrw:nAT,01],;
		aFieldsATV[oBrw:nAT,02],;
		aFieldsATV[oBrw:nAT,03],;
		aFieldsATV[oBrw:nAT,04],;
		aFieldsATV[oBrw:nAT,05],;
		aFieldsATV[oBrw:nAT,06],;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,07],"@E 99/99/9999")),;
		aFieldsATV[oBrw:nAT,08],;
		aFieldsATV[oBrw:nAT,09],;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,10],"@E 99/99/9999")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,11],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,12],"@E 999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,13],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,14],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,15],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,16],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsATV[oBrw:nAT,17],"@E 99/99/9999")),;
		aFieldsATV[oBrw:nAT,18],;
		aFieldsATV[oBrw:nAT,19] }}

	oBtnGrv := TButton():New(353,250,"   Processa"     	  ,oDlg,{|| fProcessa()         },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnMvC := TButton():New(353,320,"   Movimento Contabil"	,oDlg,{|| fMostrMov() 	},90,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnCont:= TButton():New(353,410,"   Contabiliza"  	  ,oDlg,{|| fContaAux()         },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExp := TButton():New(353,480,"   Ver Log" 		  ,oDlg,{|| fMostrLog() 		},70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnSai := TButton():New(353,550,"   Encerrar"        ,oDlg,{|| oDlg:End()        	},70,23,,,.F.,.T.,.F.,,.F.,,,.F. )

	/*Neste momento, para definirmos o estilo, usaremos a propriedade SetCss, no qual informaremos a ela a variavel que contém 
	o estilo que criamos anteriormente.*/
	oGroup       :SetCss(cEstPanel)
	oBtnCar      :SetCss(cEstBT) 
	oBtnVis      :SetCss(cEstBTVis)
	oGetDir      :SetCss(cEstGet)
	oGroupCli    :SetCss(cEstPanelBranco)
	oBtnLeg      :SetCss(cEstBTLeg)
	oGroupATV    :SetCss(cEstPanelBranco)
	oBtnGrv      :SetCss(cEstBTGrv) 
	oBtnExp      :SetCss(cEstBTExp) 
	oBtnSai      :SetCss(cEstBTSai) 
	oBtnCont     :SetCss(cEstBTGrv) 
	oBtnMvC      :SetCss(cEstBTExp) 

	ACTIVATE DIALOG oDlg CENTERED 

Return

/*---------------------------------------------------------------------*
 | Func:  fAbreDir                                                     |
 | Desc:  Função que abre busca do arquivo CSV                         |
 *---------------------------------------------------------------------*/
Static Function fAbreDir(cDir)
       
	//Busca arquivo
	cDir := cGetFile('Arquivo *|*.CSV|Arquivo CSV|*.CSV','Selecione arquivo',0,'C:\ArquivosCSV\',.T.,,.F.)

Return

/*---------------------------------------------------------------------*
 | Func:  fImpAux                                                      |
 | Desc:  Função que inicia regua de processamento e chama importação  |
 *---------------------------------------------------------------------*/
Static Function fImpAux(_cArqOri) 
	
	//Ativa regua de processamento e chama funcao
    oProcess := MsNewProcess():New({|| fImpArq(_cArqOri) }, "Processando...", "Aguarde...", .T.)
    oProcess:Activate()

Return

/*---------------------------------------------------------------------*
 | Func:  fImpArq                                                      |
 | Desc:  Função que importa arquivo para browse e monta tabela        |
 *---------------------------------------------------------------------*/
Static Function fImpArq(cArqOri) 
	Local cArea			:=getArea() 
    Local nTotLinhas  	:= 0
    Local cLinAtu     	:= ""
    Local nLinhaAtu   	:= 0
    Local aLinha      	:= {}
    Local aColSN1     	:= {}
    Local aColSN3     	:= {}    
    Local oArquivo
    Local aLinhas
    Local cChave		:= ""
    Local cCodGrp   	:= ""
    Local cCodBem   	:= ""
    Local cItem     	:= ""
    Local dDtAquis
    Local cDescBem  	:= ""
    Local cPlaqueta 	:= ""
    Local dIniDepr
    Local nVlrOrig  	:= 0
    Local nTaxa     	:= 0
    Local nDeprBal  	:= 0
    Local nDeprMes  	:= 0
    Local nDeprAcu  	:= 0
	Local nSaldo    	:= 0
    Local dDataBaix 
    Local cObserv   	:= ""
    Local cGrupo    	:= ""
	Local dDtValid  
	Local nLinInic  	:= 0
	Local nLinImp		:= 0
	Local nTotZW2   	:= 0
	Local nTamChav      := 0
	Local nPosDivCh     := 0
	Local cChave2       := ""
	Local nTamCod       := 0
	Local nCmpCod       := TamSx3("N1_CBASE")[1]
	Local nCmpItem      := TamSx3("N1_ITEM")[1]
	Private aCampos 	:= {}
	Private aColunas 	:= {}
	Private oTempTable

	nTotZW2	:= fContaZW2()

	If nTotZW2 > 0
	    MsgStop("Existem itens processados que nao foram contabilizados, antes de importar os itens precisam ser contabilizados!", "Bloqueio")
		Return
	EndIf
	
   	//Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)

			//Define a régua
    		zProcRegua(oProcess, nTotLinhas, 5)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

			//Campos da Temporária
			AADD(aCampos,{"CHAVE"		,"C"	,24		,0		})
			AADD(aCampos,{"CODGRUP"    	,"C"	,4		,0		})
			AADD(aCampos,{"CODBEM"    	,"C"	,10		,0		})
			AADD(aCampos,{"ITEM"   		,"C"	,4		,0		})
			AADD(aCampos,{"DTAQUIS"   	,"D"	,8		,0		})
			AADD(aCampos,{"DESCBEM"   	,"C"	,40		,0		})
			AADD(aCampos,{"PLAQUET"  	,"C"	,20		,0		})
			AADD(aCampos,{"DTIDEPR"   	,"D"	,8		,0		})
			AADD(aCampos,{"VALORIG"   	,"N"	,16		,2		})
			AADD(aCampos,{"TAXA"  		,"N"	,16		,2		})
			AADD(aCampos,{"DEPRBAL"  	,"N"	,16		,2		})
			AADD(aCampos,{"DEPMES"  	,"N"	,16		,2		})
			AADD(aCampos,{"DEPRACU"   	,"N"	,16		,2		})
			AADD(aCampos,{"SALDO"   	,"N"	,16		,2		})
			AADD(aCampos,{"DTBAIXA"   	,"D"	,8		,0		})
			AADD(aCampos,{"OBSERV" 		,"C"	,40		,0		})
			AADD(aCampos,{"GRUPO" 		,"C"	,40		,0		})

			//Cria a tabela temporária
			If Select(cAliasTmp) > 0
				(cAliasTmp)->(DbClosearea())
			EndIf
			oTempTable:= FWTemporaryTable():New(cAliasTmp)
			oTempTable:SetFields( aCampos )
			oTempTable:Create()
            
			//Enquanto tiver linhas
            While (oArquivo:HasLine())
                aColSN1     := {}
                aColSN3     := {}  

                //Incrementa na tela a mensagem
                nLinhaAtu++
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

				//Define linhas a processar
				dDtValid  	:= CTOD(aLinha[5])
				If dDtValid > CTOD("01/01/2000") .AND. ValType(dDtValid) = "D"               
					nLinInic++
					
					//Efetua tratamento para separar codigo e item da chave
					cChave		:= aLinha[1] //Busca chave
					nTamChav	:= Len(cChave) //Verifica tamenho da chave
					cChave2     := SubStr(cChave, 1, (nTamChav - 8)) //Separa a chave extraindo data
					nTamCod  	:= Len(AllTrim(aLinha[3])) //Verifica tamenho do codigo do bem
					nPosDivCh   := AT(AllTrim(aLinha[3]), cChave2) //encontra posição que esta o codigo do bem
					cCodBem     := PadR(SubStr(cChave2, 1, (nPosDivCh + (nTamCod - 1))), nCmpCod, " ") //Separa codigo do bem
					cItem       := PadR(SubStr(cChave2, (nPosDivCh + nTamCod)), nCmpItem, " ") //separa item
		
					//Incrementa a régua
					zIncProc(oProcess, cCodBem + cItem)

					cChave		:= aLinha[1]
					cCodGrp		:= PadL(aLinha[2],3,"0")                 
					dDtAquis  	:= CTOD(aLinha[5])
					cDescBem  	:= aLinha[6]
					cPlaqueta  	:= aLinha[7]
					dIniDepr  	:= CTOD(aLinha[8]) 
					nVlrOrig	:= TratNum(aLinha[9])
					nTaxa		:= TratNum(aLinha[10])
					nDeprBal	:= TratNum(aLinha[11])
					nDeprMes	:= TratNum(aLinha[12])
					nDeprAcu	:= TratNum(aLinha[13])
					nSaldo		:= TratNum(aLinha[14])
					dDataBaix	:= CTOD(aLinha[15]) 
					cObserv		:= aLinha[16]
					cGrupo		:= aLinha[17]

					//Grava na temporária
					RecLock(cAliasTmp, .T.)

					(cAliasTmp)->CHAVE		:= cChave
					(cAliasTmp)->CODGRUP  	:= cCodGrp
					(cAliasTmp)->CODBEM  	:= cCodBem
					(cAliasTmp)->ITEM  		:= cItem
					(cAliasTmp)->DTAQUIS  	:= dDtAquis
					(cAliasTmp)->DESCBEM  	:= cDescBem
					(cAliasTmp)->PLAQUET  	:= cPlaqueta
					(cAliasTmp)->DTIDEPR  	:= dIniDepr
					(cAliasTmp)->VALORIG 	:= nVlrOrig
					(cAliasTmp)->TAXA 		:= nTaxa
					(cAliasTmp)->DEPRBAL 	:= nDeprBal
					(cAliasTmp)->DEPMES  	:= nDeprMes
					(cAliasTmp)->DEPRACU  	:= nDeprAcu
					(cAliasTmp)->SALDO  	:= nSaldo
					(cAliasTmp)->DTBAIXA 	:= dDataBaix
					(cAliasTmp)->OBSERV 	:= cObserv
					(cAliasTmp)->GRUPO  	:= cGrupo
					(cAliasTmp)->(MsUnlock())
                EndIf
            EndDo

        Else
            MsgStop("Arquivo não tem conteúdo!", "Atenção")
        EndIf

        //Fecha o arquivo
        oArquivo:Close()
    Else
        MsgStop("Arquivo não pode ser aberto!", "Atenção")
    EndIf

	//Monta browse com ativos da tambela temporaria
	(cAliasTmp)->(dbGoTop())
	If (cAliasTmp)->(Eof())
		(cAliasTmp)->(DbCloseArea())
		MsgStop("Não foram encontrados ativos para importacao!", "Atencao")
	Else
		aFieldsATV := {}
		While (cAliasTmp)->(!Eof())                    
			oCorTit := oVerde
			Aadd(aFieldsATV,{oCorTit, oVermelho, (cAliasTmp)->CHAVE, (cAliasTmp)->CODGRUP, (cAliasTmp)->CODBEM,;
								 (cAliasTmp)->ITEM, (cAliasTmp)->DTAQUIS , (cAliasTmp)->DESCBEM, (cAliasTmp)->PLAQUET,;
								 (cAliasTmp)->DTIDEPR, (cAliasTmp)->VALORIG, (cAliasTmp)->TAXA, (cAliasTmp)->DEPRBAL,;
								 (cAliasTmp)->DEPMES, (cAliasTmp)->DEPRACU, (cAliasTmp)->SALDO, (cAliasTmp)->DTBAIXA,;
								 (cAliasTmp)->OBSERV, (cAliasTmp)->GRUPO}) 
			nLinImp++
			dbSkip()
		End

		oBrw:SetArray(aFieldsATV)
		oBrw:bLine      := {|| {oVerde, oCinza,;
							aFieldsATV[oBrw:nAT,03], aFieldsATV[oBrw:nAT,04], aFieldsATV[oBrw:nAT,05],	aFieldsATV[oBrw:nAT,06],;
							aFieldsATV[oBrw:nAT,07], aFieldsATV[oBrw:nAT,08], aFieldsATV[oBrw:nAT,09], aFieldsATV[oBrw:nAT,10],;
							aFieldsATV[oBrw:nAT,11], aFieldsATV[oBrw:nAT,12], aFieldsATV[oBrw:nAT,13], aFieldsATV[oBrw:nAT,14],;
							aFieldsATV[oBrw:nAT,15], aFieldsATV[oBrw:nAT,16], aFieldsATV[oBrw:nAT,17], aFieldsATV[oBrw:nAT,18],;
							aFieldsATV[oBrw:nAT,19] }}

		MsgInfo("Foram importados: " + cValToChar(nLinImp) + " registros de um total de: " + cValToChar(nLinInic) + " registros!", "Registros importados!")
	EndIf
				
	restArea(cArea)

Return

/*---------------------------------------------------------------------*
 | Func:  fProcessa                                                    |
 | Desc:  Função que gerencia processamento                            |
 *---------------------------------------------------------------------*/
Static Function fProcessa()

	//Valida se todos os campos estão preenchidos para processamento
	If Empty(cDir)
		msgalert("Nenhum arquivo selecionado. Não é possível processar Baixa.","ATENÇÃO")
	ElseIf Empty(cOriGrp) .OR. Empty(cOriFil) .OR. Empty(cDesGrp) .OR. Empty(cDesFil)
		MsgStop("Os dados de grupo/filial origem e destino, devem estar preenchidos","Bloqueio")
		Return
	ElseIf cOriFil <> cFilAnt
 		MsgStop("Filial de origem selecionada, diferente da filial logada","Bloqueio")
		Return
	ElseIf cOriGrp <> cEmpAnt
 		MsgStop("Grupo de origem selecionado, diferente do grupo logado","Bloqueio")
		Return
	ElseIf lProcess
	 	MsgStop("Ativos já foram processados!","Bloqueio")
		Return
	ElseIf msgYesNo("Este processo realizará o processamento de todos os ativos listado. Deseja continuar?","Processa")
    	oProcess2 := MsNewProcess():New({|| ProcAtivo()}, "Processando...", "Aguarde...", .T.)
    	oProcess2:Activate()
	EndIf

Return()

/*---------------------------------------------------------------------*
 | Func:  ProcAtivo                                                    |
 | Desc:  Função que processa ativo                                    |
 *---------------------------------------------------------------------*/
Static Function ProcAtivo()
	Local aArea 		:= GetArea()
	Local cBase 		:= ""
	Local cItem 		:= ""
	Local cTipo 		:= ""
	Local cTpSaldo 		:= ""
	Local cBaixa 		:= ""
	Local nQtdBaixa 	:= 0
	Local cMotivo 		:= ""
	Local cMetDepr 		:= ""
	Local aCab 			:= {}
	Local aAtivo 		:= {}
	Local aParam 		:= {}
	Local nProcOk     	:= 0
	Local nProcErr		:= 0
	Local cBaixaAtu     := ""
	Local nX
    Local nQtd 			:= 0
    Local cPlaq 		:= ""
    Local cPatrim 		:= ""
    Local cGrpOri 		:= ""
	Local cGrpDest		:= ""
    Local dAquisic 
    Local dIndDepr 
    Local cDescric 		:= ""
    Local cHistor 		:= ""
    Local cContab 		:= ""
    Local nValOri 		:= 0
    Local nTaxa1 		:= 0
    Local aParam2 		:= {}
    Local aCab2 		:= {}
    Local aItens 		:= {}	
	Local cStBaixa		:= ""
	Local cStInclus		:= ""
	Local cStProces		:= ""
	Local cStContab     := ""
	Local nDprAcum		:= 0
	Local nDprMes		:= 0
	Local nDprBal		:= 0
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	cPlaq 		:= "000001"//teste

	//Define a régua		
	zProcRegua(oProcess2, Len(aFieldsATV), 5)

	//Percorre todos os ativos para baixa
	For nX := 1 To Len(aFieldsATV)
	
		cStBaixa	:= ""
		cStInclus	:= ""
		cStProces	:= ""
		cContab 	:= ""
		cBase		:= aFieldsATV[nX][05]
		cItem		:= aFieldsATV[nX][06]
		cGrpOri 	:= AllTrim(aFieldsATV[nX][04])
		nDprAcum	:= aFieldsATV[nX][15]
		nValOri 	:= aFieldsATV[nX][11]
		cMotivo		:= "10"
		nQtdBaixa	:= 1
		nPercBaix   := 100
		cMetDepr	:= "0"
		cBaixa		:= "0"
		cTpSaldo	:= "1"

		//Incrementa a régua
        zIncProc(oProcess2, cBase + cItem)

		//verifica se existe na tabela
		SN1->(DbSetOrder(1))
        If SN1->(DBSeek(FWXFilial('SN1') + cBase + cItem))
			SN3->(DbSetOrder(1))
			If SN3->(DBSeek(FWXFilial('SN3') + cBase + cItem))					
				cTipo		:= SN3->N3_TIPO
				cBaixaAtu	:= SN3->N3_BAIXA
				cHistor 	:= SN3->N3_HISTOR
				
				If cBaixaAtu = "0"
					aCab := { {"FN6_FILIAL" ,XFilial("FN6") ,NIL},;
					{"FN6_CBASE" 	,cBase 		,NIL},;
					{"FN6_CITEM" 	,cItem 		,NIL},;
					{"FN6_MOTIVO" 	,cMotivo 	,NIL},;
					{"FN6_BAIXA" 	,100 		,NIL},;
					{"FN6_QTDBX" 	,nQtdBaixa 	,NIL},;
					{"FN6_PERCBX" 	,nPercBaix 	,NIL},;
					{"FN6_DTBAIX" 	,dDatabase 	,NIL},;
					{"FN6_DEPREC" 	,cMetDepr 	,NIL}}
					
					aAtivo := {{"N3_FILIAL" ,XFilial("SN3") ,NIL},;
					{"N3_CBASE" 	,cBase 		,NIL},;
					{"N3_ITEM" 		,cItem 		,NIL},;
					{"N3_TIPO" 		,cTipo 		,NIL},;
					{"N3_BAIXA" 	,cBaixa 	,NIL},;
					{"N3_TPSALDO" 	,cTpSaldo	,NIL}}
					
					//Array contendo os parametros do F12
					aAdd( aParam, {"MV_PAR01", 1} ) //Pergunta 01 - Mostra Lanc. Contab? 1 = Sim ; 2 = Não
					aAdd( aParam, {"MV_PAR02", 2} ) //Pergunta 02 - Aglutina Lancamento Contabil ? 1 = Sim ; 2 = Não
					aAdd( aParam, {"MV_PAR03", 1} ) //Pergunta 03 - Contabaliza On-Line? 1 = Sim ; 2 = Não
					aAdd( aParam, {"MV_PAR04", 2} ) //Pergunta 04 - Visualização ? 2 = Tipos de Ativos   // deve se usar obrigatoriamente o número 2
					
					lMsErroAuto	:= .F.
					Begin Transaction
					MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,3,,.T./*lBaixaTodos*/,aParam)
					If lMsErroAuto
						nProcErr++
						cStBaixa	:= "Erro: Falha no execauto de baixa"
						cStInclus	:= "Erro: Falha na baixa"
						cStContab   := "Erro: Falha na baixa"
						cStProces	:= "Erro: Falha na baixa"
						aFieldsATV[nX][02] := oVermelho
						DisarmTransaction()
					Else
						cStBaixa	:= "Baixado com sucesso"

						//Grava para contabilização
						fGravaCT2(cBase, cItem, "1", nValOri, nDprAcum, cGrpOri)

						//Troca a filial para destino
						zAltFil(cDesGrp , cDesFil)

						cGrpDest	:= fTrocaGrp(cGrpOri)
						nQtd 		:= 1
						// cPlaq 		:= AllTrim(aFieldsATV[nX][09])//teste
						cPatrim 	:= "N"
						dAquisic	:= aFieldsATV[nX][07]
						dIndDepr 	:= aFieldsATV[nX][10]
						cDescric 	:= aFieldsATV[nX][08]
						nTaxa1 		:= aFieldsATV[nX][12]
						nDprMes		:= aFieldsATV[nX][14]
						nDprBal		:= aFieldsATV[nX][13]

						SNG->(DbSetOrder(1))
						If SNG->(DBSeek(FWXFilial('SNG') + cGrpDest))
							cContab	:= SNG->NG_CCONTAB
						EndIf
						aParam2 	:= {}
						aCab2 		:= {}
						aItens 		:= {}

						lMsErroAuto := .F.
						lMsHelpAuto := .T.

						cItem	:= SOMA1(cItem)//teste
						cPlaq	:= SOMA1(cPlaq)//teste

						AAdd(aCab2,{"N1_FILIAL" 	, cDesFil 	,NIL})
						AAdd(aCab2,{"N1_CBASE" 		, cBase 	,NIL})
						AAdd(aCab2,{"N1_ITEM" 		, cItem 	,NIL})
						AAdd(aCab2,{"N1_AQUISIC"	, dAquisic 	,NIL})
						AAdd(aCab2,{"N1_DESCRIC"	, cDescric 	,NIL})
						AAdd(aCab2,{"N1_QUANTD" 	, nQtd 		,NIL})
						AAdd(aCab2,{"N1_CHAPA" 		, cPlaq 	,NIL})
						AAdd(aCab2,{"N1_PATRIM" 	, cPatrim 	,NIL})
						AAdd(aCab2,{"N1_GRUPO" 		, cGrpDest 	,NIL})

						aItens := {}
						AAdd(aItens,{;
						{"N3_FILIAL" 	, cDesFil 	,NIL},;
						{"N3_CBASE" 	, cBase 	,NIL},;
						{"N3_ITEM" 		, cItem 	,NIL},;
						{"N3_TIPO" 		, cTipo 	,NIL},;
						{"N3_BAIXA" 	, "0" 		,NIL},;
						{"N3_HISTOR" 	, cDescric 	,NIL},;
						{"N3_CCONTAB" 	, cContab 	,NIL},;
						{"N3_DINDEPR" 	, dIndDepr	,NIL},;
						{"N3_VORIG1" 	, nValOri 	,NIL},;
						{"N3_TXDEPR1" 	, nTaxa1 	,NIL},;
						{"N3_VRDBAL1" 	, nDprBal 	,NIL},;
						{"N3_VRDMES1" 	, nDprMes 	,NIL},;
						{"N3_VRDACM1" 	, nDprAcum 	,NIL};
						})

						lMsErroAuto	:= .F.
						Begin Transaction
						MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab2,aItens,3,aParam2)
						If lMsErroAuto 
							nProcErr++
							cStInclus	:= "Erro: Falha no execauto de inclusao"
							cStContab   := "Erro: Falha na inclusao"
							cStProces	:= "Erro: Falha na inclusao"
							aFieldsATV[nX][02] := oVermelho
							DisarmTransaction()
						Else
							nProcOk++
							cStInclus	:= "Incluido com sucesso"
							cStContab   := "Pendente Contabilizacao"
							cStProces	:= "Pendente Contabilizacao"
							aFieldsATV[nX][02] := oVerde
						Endif
						End Transaction

						If cStInclus	= "Incluido com sucesso"
							//Grava para contabilização
							fGravaCT2(cBase, cItem, "2", nValOri, nDprAcum, cGrpDest)
						EndIf

						//Voltando o backup da empresa e filial
						zAltFil( , , .T.)

					EndIf
					End Transaction
				Else
					nProcErr++
					cStBaixa	:= "Erro: Ativo já baixado"
					cStInclus	:= "Erro: Falha na baixa"
					cStContab   := "Erro: Falha na baixa"
					cStProces	:= "Erro: Falha na baixa"
					aFieldsATV[nX][02] := oVermelho
				EndIf
			Else
				nProcErr++
				cStBaixa	:= "Erro: Nao encontrou ativo na SN3"
				cStInclus	:= "Erro: Falha na baixa"
				cStContab   := "Erro: Falha na baixa"
				cStProces	:= "Erro: Falha na baixa"
				aFieldsATV[nX][02] := oVermelho
			EndIf
		Else
		    nProcErr++
			cStBaixa	:= "Erro: Nao encontrou ativo na SN1"
			cStInclus	:= "Erro: Falha na baixa"
			cStContab   := "Erro: Falha na baixa"
			cStProces	:= "Erro: Falha na baixa"
			aFieldsATV[nX][02] := oVermelho
        EndIf

		//Grava log de processamento
		GravLog(cBase, cItem, cStBaixa, cStInclus, cStContab, cStProces)
	Next

	//Mensagem de finalizacao de baixas
	If nProcErr = 0 .AND. nProcOk > 0
		MsgInfo("Foram processados "+cValToChar(nProcOk)+" ativos com sucesso.","Processamento de Ativos")
	ElseIf nProcErr > 0 .AND. nProcOk > 0
		MsgInfo("Foram processados "+cValToChar(nProcOk)+" ativos com sucesso e "+cValToChar(nProcErr)+" ativos não foram processados.","Processamento de Ativos")
	ElseIf nProcErr > 0 .AND. nProcOk = 0
	    MsgInfo("Não foram processados nenhum ativo.","Processamento de Ativos")
	EndIf

	//Contabilizar
	If nProcOk > 0
		If msgYesNo("Deseja contabilizar as baixas e inclusões?","Contabilização") 
			fContaAux()
		EndIf
	EndIf

	//Atualiza Browse
	oBrw:SetArray(aFieldsATV)
	oBrw:bLine      := {|| {aFieldsATV[oBrw:nAT,01], aFieldsATV[oBrw:nAT,02],;
							aFieldsATV[oBrw:nAT,03], aFieldsATV[oBrw:nAT,04], aFieldsATV[oBrw:nAT,05],	aFieldsATV[oBrw:nAT,06],;
							aFieldsATV[oBrw:nAT,07], aFieldsATV[oBrw:nAT,08], aFieldsATV[oBrw:nAT,09], aFieldsATV[oBrw:nAT,10],;
							aFieldsATV[oBrw:nAT,11], aFieldsATV[oBrw:nAT,12], aFieldsATV[oBrw:nAT,13], aFieldsATV[oBrw:nAT,14],;
							aFieldsATV[oBrw:nAT,15], aFieldsATV[oBrw:nAT,16], aFieldsATV[oBrw:nAT,17], aFieldsATV[oBrw:nAT,18],;
							aFieldsATV[oBrw:nAT,19] }}

	(cAliasTmp)->(DbCloseArea())

	lProcess	:= .T.
	RestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  GravLog                                                      |
 | Desc:  Função que grava log de processamento                        |
 *---------------------------------------------------------------------*/
Static Function GravLog(_cBase, _cItem, _cStBaixa, _cStInclus, _cStContab, _cStProces)

    DbSelectArea("ZW1")
    RecLock("ZW1", .T.)	

    ZW1->ZW1_FILIAL     := xFilial("ZW1")
	ZW1->ZW1_CBASE     	:= _cBase
	ZW1->ZW1_ITEM     	:= _cItem     
	ZW1->ZW1_DTPROC     := dDataBase 
	ZW1->ZW1_HRPROC     := Time()
	ZW1->ZW1_GRPORI     := cOriGrp
    ZW1->ZW1_FILORI     := cOriFil 
	ZW1->ZW1_GRPDES     := cDesGrp     
	ZW1->ZW1_FILDES     := cDesFil 
	ZW1->ZW1_BAIXA     	:= _cStBaixa
	ZW1->ZW1_INCLUS     := _cStInclus 
	ZW1->ZW1_CONTAB     := _cStContab
	ZW1->ZW1_PROCES		:= _cStProces 
	ZW1->ZW1_USER     	:= cCodUser 
	ZW1->ZW1_NMUSER     := UsrRetName(cCodUser) 
    
    ZW1->(MsUnLock())

Return

/*---------------------------------------------------------------------*
 | Func:  fGravaCT2                                                    |
 | Desc:  Função para gravar dados para contabilizacao                 |
 *---------------------------------------------------------------------*/
Static Function fGravaCT2(_cBase, _cItem, _cTipo, _nValOri, _nValAcum, _cGrupo)
	Local nQtdTp1	:= 0
	Local nQtdTp2 	:= 0
	Local cHist     := ""
	Local nValor    := 0
	Local nX
	Local nY
	Local cTipLanc  := ""
	Local cEspecie  := ""
	Local cDebito   := ""
	Local cCredito  := ""
	Local _cDebito  := ""
	Local _cCredito := ""
	Local nTamGrp   := TamSx3("N1_GRUPO")[1]

	DbSelectArea("ZW2")
	If _cTipo	= "1"
		_cGrupo	:= PadR(_cGrupo, nTamGrp, " ")
		SNG->(DbSetOrder(1))
		If SNG->(DBSeek(FWXFilial('SNG') + _cGrupo))
			_cDebito	:= SNG->NG_CCDEPR
			_cCredito	:= SNG->NG_CCONTAB
		EndIf
		
    	For nX := 1 To 4
			nQtdTp1++

			Do Case
				Case nQtdTp1	= 1
					//Tipo: 1 Baixa - Especie: 1 Baixa do Item - Lancamento: 1 Debito
					cEspecie	:= "1"
					cTipLanc	:= "1"
					cDebito		:= "121102001"
					cCredito	:= ""
					cHist       := "BAIXA BEM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValOri
				Case nQtdTp1    = 2
					//Tipo: 1 Baixa - Especie: 1 Baixa do Item - Lancamento: 2 Credito
					cEspecie	:= "1"
					cTipLanc	:= "2"
					cDebito		:= ""
					cCredito	:= _cCredito
					cHist       := "BAIXA BEM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValOri
				Case nQtdTp1    = 3
					//Tipo: 1 Baixa - Especie: 2 Baixa Acumulado - Lancamento: 1 Debito
					cEspecie	:= "2"
					cTipLanc	:= "1"
					cDebito		:= _cDebito
					cCredito	:= ""
					cHist       := "BAIXA ACUM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValAcum
				Case nQtdTp1    = 4
					//Tipo: 1 Baixa - Especie: 2 Baixa Acumulado - Lancamento: 2 Credito
					cEspecie	:= "2"
					cTipLanc	:= "2"
					cDebito		:= ""
					cCredito	:= "121102001"
					cHist       := "BAIXA ACUM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValAcum
			End Case
    	
			RecLock("ZW2", .T.)	
			ZW2->ZW2_FILIAL     := xFilial("ZW2")
			ZW2->ZW2_GRPATV     := cOriGrp
			ZW2->ZW2_FILATV     := cOriFil
			ZW2->ZW2_CBASE     	:= _cBase
			ZW2->ZW2_ITEM     	:= _cItem     
			ZW2->ZW2_STATUS     := "2"
			ZW2->ZW2_DATA     	:= dDataBase 
			ZW2->ZW2_DC    		:= cTipLanc
			ZW2->ZW2_ESPECI     := cEspecie
			ZW2->ZW2_TIPO    	:= _cTipo
			ZW2->ZW2_DEBITO     := cDebito 
			ZW2->ZW2_CREDIT		:= cCredito
			ZW2->ZW2_VALOR     	:= nValor
			ZW2->ZW2_HIST		:= cHist
			ZW2->(MsUnLock())
		Next
	
	ElseIf _cTipo	= "2"
		_cGrupo	:= PadR(_cGrupo, nTamGrp, " ")
		SNG->(DbSetOrder(1))
		If SNG->(DBSeek(FWXFilial('SNG') + _cGrupo))
			_cDebito	:= SNG->NG_CCONTAB
			_cCredito	:= SNG->NG_CCDEPR
		EndIf
		For nY := 1 To 4
			nQtdTp2++

			Do Case
				Case nQtdTp2	= 1
					//Tipo: 2 Inclusao - Especie: 3 Inclusao de Ativo - Lancamento: 1 Debito
					cEspecie	:= "3"
					cTipLanc	:= "1"
					cDebito		:= _cDebito
					cCredito	:= ""
					cHist       := "INCLUSAO BEM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValOri
				Case nQtdTp2    = 2
					//Tipo: 2 Inclusao - Especie: 3 Inclusao de Ativo - Lancamento: 2 credito
					cEspecie	:= "3"
					cTipLanc	:= "2"
					cDebito		:= ""
					cCredito	:= "111104998"
					cHist       := "INCLUSAO BEM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValOri
				Case nQtdTp2    = 3
					//Tipo: 2 Inclusao - Especie: 4 Inclusao de Acumulado - Lancamento: 1 Debito
					cEspecie	:= "4"
					cTipLanc	:= "1"
					cDebito		:= "111104998"
					cCredito	:= ""
					cHist       := "INCLUSAO ACUM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValAcum
				Case nQtdTp2    = 4
					//Tipo: 2 Inclusao - Especie: 4 Inclusao de Acumulado - Lancamento: 2 credito
					cEspecie	:= "4"
					cTipLanc	:= "2"
					cDebito		:= ""
					cCredito	:= _cCredito
					cHist       := "INCLUSAO ACUM: " + AllTrim(_cBase) + " ITEM: " + AllTrim(_cItem)
					nValor     	:= _nValAcum
			End Case

			RecLock("ZW2", .T.)	
			ZW2->ZW2_FILIAL     := xFilial("ZW2")
			ZW2->ZW2_GRPATV     := cDesGrp
			ZW2->ZW2_FILATV     := cDesFil
			ZW2->ZW2_CBASE     	:= _cBase
			ZW2->ZW2_ITEM     	:= _cItem     
			ZW2->ZW2_STATUS     := "2"
			ZW2->ZW2_DATA     	:= dDataBase 
			ZW2->ZW2_DC    		:= cTipLanc
			ZW2->ZW2_ESPECI     := cEspecie
			ZW2->ZW2_TIPO    	:= _cTipo
			ZW2->ZW2_DEBITO     := cDebito 
			ZW2->ZW2_CREDIT		:= cCredito
			ZW2->ZW2_VALOR     	:= nValor
			ZW2->ZW2_HIST		:= cHist	
			ZW2->(MsUnLock())

		Next
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fContaAux                                                     |
 | Desc:  Função que inicia regua processamento e chama Contabilizacao  |
 *---------------------------------------------------------------------*/
Static Function fContaAux() 
	Local nTotZW2  	:= 0

	nTotZW2	:= fContaZW2()

	If nTotZW2 > 0
		//Ativa regua de processamento e chama funcao
		If msgYesNo("Deseja realizar a contabilizacao?","Contabilizar")
			oProcess3 := MsNewProcess():New({|| fContabil(nTotZW2) }, "Processando...", "Aguarde...", .T.)
			oProcess3:Activate()
		EndIf
	else
		MsgInfo("Nao existem ativos para contabilizar!", "Contabilizacao")
		Return
	EndIf

Return

/*---------------------------------------------------------------------*
 | Func:  fContabil                                                    |
 | Desc:  Função para contabilizar                                     |
 *---------------------------------------------------------------------*/
Static Function fContabil(_nTotZW2)
	Local aItens 		:= {}
	Local aCab 			:= {}
	Local cQryBx        := ""
	Local cAliasBx 		:= GetNextAlias()
	Local cQryInc       := ""
	Local cAliasInc		:= GetNextAlias()
	Local cLinha        := ""
	Local cAliasCon     := ""
	Local cLote			:= ""
	Local cSbLote 		:= ""
	Local cDoc    		:= ""
	Local cStContab		:= ""
	Local cStProces		:= ""
	Local nContErr      := 0
	Local nContOK       := 0
	Local nSeq          := 1
	Private lMsErroAuto := .F.

	//Define a régua		
	zProcRegua(oProcess3, _nTotZW2, 5)

	//Busca dados da Baixa
	cQryBx := "SELECT ZW2_GRPATV, ZW2_FILATV, ZW2_TIPO, ZW2_CBASE, ZW2_ITEM, ZW2_STATUS, ZW2_DC, ZW2_DEBITO, ZW2_CREDIT, ZW2_VALOR, ZW2_HIST "
	cQryBx += "FROM "+RetSqlName("ZW2")+" ZW2 "
	cQryBx += "WHERE ZW2_STATUS='2' AND ZW2_TIPO = '1' "
	cQryBx += "AND ZW2.D_E_L_E_T_ = '' "
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQryBx),cAliasBx,.F.,.T.)
	(cAliasBx)->(DbGoTop())

	//Busca dados da Inclusao
	cQryInc := "SELECT ZW2_GRPATV, ZW2_FILATV, ZW2_TIPO, ZW2_CBASE, ZW2_ITEM, ZW2_STATUS, ZW2_DC, ZW2_DEBITO, ZW2_CREDIT, ZW2_VALOR, ZW2_HIST "
	cQryInc += "FROM "+RetSqlName("ZW2")+" ZW2 "
	cQryInc += "WHERE ZW2_STATUS='2' AND ZW2_TIPO = '2' "
	cQryInc += "AND ZW2.D_E_L_E_T_ = '' "
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQryInc),cAliasInc,.F.,.T.)
	(cAliasInc)->(DbGoTop())

	//Verifica se esta no processo de baixa ou inclusao
	While nSeq <= 2
		If nSeq = 1
			If cEmpAnt <> (cAliasBx)->ZW2_GRPATV .OR. cFilAnt <> (cAliasBx)->ZW2_FILATV
					MsgStop("Grupo Origem e Filial Origem devem ser os mesmos do Processamento: Grupo: "+(cAliasBx)->ZW2_GRPATV+" e Filial: "+(cAliasBx)->ZW2_FILATV, "Bloqueio")
				Return
			EndIf
			cAliasCon		:= cAliasBx
			cLote			:= "008860"
			cSbLote 		:= "001"
			cDoc    		:= fDocNum((cAliasBx)->ZW2_FILATV, cLote, cSbLote)
		ElseIf nSeq = 2
			zAltFil((cAliasInc)->ZW2_GRPATV , (cAliasInc)->ZW2_FILATV)
			cAliasCon		:= cAliasInc
			cLote			:= "008860"
			cSbLote 		:= "001"
			cDoc    		:= fDocNum((cAliasInc)->ZW2_FILATV, cLote, cSbLote)	
		EndIf	

		If !(cAliasCon)->(EOF())
			aItens 		:= {}
			aCab 		:= {}
			cLinha     	:= "001"

			//Incrementa a régua
			zIncProc(oProcess3, (cAliasCon)->ZW2_CBASE + (cAliasCon)->ZW2_ITEM )

			aCab	:= {{'DDATALANC'	,dDataBase 	,NIL},;
						{'CLOTE' 		,cLote 		,NIL},;
						{'CSUBLOTE' 	,cSbLote 	,NIL},;
						{'CDOC' 		,cDoc 		,NIL},;
						{'CPADRAO' 		,'' 		,NIL},;
						{'NTOTINF' 		,0 			,NIL},;
						{'NTOTINFLOT' 	,0 			,NIL} }
			While !(cAliasCon)->(EOF())
				aAdd(aItens,{;
							{'CT2_FILIAL'	,(cAliasCon)->ZW2_FILATV 	, NIL},;
							{'CT2_LINHA' 	,cLinha				 		, NIL},;
							{'CT2_MOEDLC' 	,"1" 						, NIL},;
							{'CT2_DC' 		,(cAliasCon)->ZW2_DC		, NIL},;
							{'CT2_DEBITO' 	,(cAliasCon)->ZW2_DEBITO 	, NIL},;
							{'CT2_CREDIT' 	,(cAliasCon)->ZW2_CREDIT 	, NIL},;
							{'CT2_VALOR' 	,(cAliasCon)->ZW2_VALOR  	, NIL},;
							{'CT2_ORIGEM' 	,'MSEXECAUT - Contabilizacao'		, NIL},;
							{'CT2_HIST' 	,(cAliasCon)->ZW2_HIST		, NIL}})
				cLinha	:= Soma1(cLinha)
				(cAliasCon)->( DbSkip() )
			EndDo

			//Execauto
			lMsErroAuto	:= .F.
			Begin Transaction
			MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aItens, 3)
			If lMsErroAuto 
				MostraErro()
				cStContab	:= "Erro: Falha no execauto de Contabilizacao"
				cStProces	:= "Erro: Falha na contabilizacao"
				DisarmTransaction()
				nContErr++
			Else
				cStContab	:= "Incluido com sucesso"
				cStProces	:= "Processado com sucesso"
			Endif
			End Transaction

			If nSeq = 2
				//Voltando o backup da empresa e filial
				zAltFil( , , .T.)
			EndIf

			If cStContab = "Incluido com sucesso"
				(cAliasCon)->(DbGoTop())
				ZW2->(DbSetOrder(1))
				ZW2->(DbGoTop())
				If ZW2->(DBSeek(xFilial("ZW2") + (cAliasCon)->ZW2_CBASE + (cAliasCon)->ZW2_ITEM))
					While (cAliasCon)->ZW2_CBASE + (cAliasCon)->ZW2_ITEM = ZW2->ZW2_CBASE + ZW2->ZW2_ITEM .AND. (cAliasCon)->ZW2_TIPO = ZW2->ZW2_TIPO
						RecLock("ZW2", .F.)	
						ZW2->ZW2_STATUS     := "1"
						ZW2->(MsUnLock())
						nContOK++
						ZW2->(DbSkip())
					EndDo
				EndIf
			EndIf

			ZW1->(DbSetOrder(1))
			If ZW1->(DBSeek(xFilial("ZW1") + (cAliasCon)->ZW2_CBASE + (cAliasCon)->ZW2_ITEM))
				RecLock("ZW1", .F.)	
				ZW1->ZW1_CONTAB     := cStContab
				ZW1->ZW1_PROCES		:= cStProces
				ZW1->(MsUnLock())
			EndIf
		EndIf
		nSeq++
	EndDo

	(cAliasBx)->(DbCloseArea())
	(cAliasInc)->(DbCloseArea())

	//Mensagem de finalizacao de baixas
	If _nTotZW2 > 0
		If nContErr = 0 .AND. nContOK > 0
			MsgInfo("Foram contabilizados "+cValToChar(nContOK)+" ativos com sucesso.","Contabiliza Ativos")
		ElseIf nContErr > 0 .AND. nContOK > 0
			MsgInfo("Foram contabilizados "+cValToChar(nContOK)+" ativos com sucesso e "+cValToChar(nContErr)+" ativos não foram contabilizados.","Contabiliza Ativos")
		ElseIf nContErr > 0 .AND. nContOK = 0
			MsgInfo("Não foram contabilizados nenhum ativo.","Contabiliza Ativos")
		EndIf
	Else
		MsgInfo("Não foram encontrados ativos para contabilizar.","Contabiliza Ativos")
	EndIf
Return

/*---------------------------------------------------------------------*
 | Func:  fTrocaGrp                                                    |
 | Desc:  Função para Trocar grupo                                     |
 *---------------------------------------------------------------------*/
Static Function fTrocaGrp(_cGrpOri)
	Local cGrpDest	:= ""
	Local nTamGrp	:= TamSx3("N1_GRUPO")[1]

	Do Case
		Case _cGrpOri = "012"
		    cGrpDest := "01"
		Case _cGrpOri = "005"
		    cGrpDest := "03"
		Case _cGrpOri = "008"
		    cGrpDest := "04"
		Case _cGrpOri = "014"
		    cGrpDest := "05"
		Case _cGrpOri = "004"
		    cGrpDest := "06"
		Case _cGrpOri = "037"
		    cGrpDest := "07"
		Case _cGrpOri = "015"
		    cGrpDest := "08"
		Case _cGrpOri = "035"
		    cGrpDest := "09"
		Case _cGrpOri = "013"
		    cGrpDest := "10"
		Case _cGrpOri = "036"
		    cGrpDest := "11"
        EndCase

		//Ajuste tamanho	
		cGrpDest    := PadR(cGrpDest, nTamGrp, " ")

Return cGrpDest

/*---------------------------------------------------------------------*
 | Func:  fDocNum                                                      |
 | Desc:  Função para definir numero do documento                      |
 *---------------------------------------------------------------------*/
Static Function fDocNum(_cFil, _cLote, _cSbLote)	

	Local cDocNum	:= ""
	Local cQueryCT2 := ""
	Local cAliasCT2 := GetNextAlias()

    //Query que conta, quantidade de documentos do lote 8860
    cQueryCT2 := "SELECT MAX(CT2_DOC) AS QTDREG "
    cQueryCT2 += "FROM "+RetSqlName("CT2") + " CT2 "
    cQueryCT2 += "WHERE CT2_LOTE= '"+_cLote+"' "
    cQueryCT2 += "AND CT2_SBLOTE= '"+_cSbLote+"' "
	cQueryCT2 += "AND CT2_FILIAL= '"+_cFil+"' "
    cQueryCT2 += "AND CT2.D_E_L_E_T_=' ' "
    cQueryCT2 := ChangeQuery(cQueryCT2)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQueryCT2),cAliasCT2,.F.,.T.)
	(cAliasCT2)->(DbGoTop())

    //Define numero do documento
    If Empty((cAliasCT2)->QTDREG)
        cDocNum := "000001"
    else
        cDocNum := Soma1((cAliasCT2)->QTDREG)
    EndIf

Return cDocNum

/*---------------------------------------------------------------------*
 | Func:  fContaZW2                                                    |
 | Desc:  Função para contar ativos na ZW2 para contabilizar           |
 *---------------------------------------------------------------------*/
Static Function fContaZW2()

	Local cQuery	:= ""
	Local cAliasZW2 := GetNextAlias()
	Local nTotZW2	:= 0

	//Verifica se possui ativos para contabilizar
	cQuery := "SELECT ZW2_CBASE, ZW2_ITEM, ZW2_STATUS "
	cQuery += "FROM "+RetSqlName("ZW2")+" ZW2 "
	cQuery += "WHERE ZW2_STATUS='2' "
	cQuery += "AND ZW2.D_E_L_E_T_ = '' "
	DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasZW2,.F.,.T.)
	(cAliasZW2)->(DbGoTop())
	Count To nTotZW2

	ZW2->(DbCloseArea())

Return nTotZW2

/*---------------------------------------------------------------------*
 | Func:  fMostrMov                                                    |
 | Desc:  Função para mostrar Movimentos Contabeis                     |
 *---------------------------------------------------------------------*/
Static Function fMostrMov()
    Local aArea       	:= GetArea()
    Local cTabela     	:= "ZW2"
	Local aIndex 		:= {}
	Local cFiltro 		:= "ZW2_STATUS='2'" //Expressao do Filtro
    Private cCadastro 	:= "Movimentos Contabeis"
    Private aRotina   	:= {}
	Private bFiltraBrw 	:= { || FilBrowse( cTabela , @aIndex , @cFiltro ) }

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
    aAdd(aRotina,{"Incluir",    "AxInclui", 0, 3})
    aAdd(aRotina,{"Alterar",    "AxAltera", 0, 4})
    aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})

	 //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
    
	
    //Montando o Browse
	Eval( bFiltraBrw )
    mBrowse(6, 1, 22, 75, cTabela)
	EndFilBrw( cTabela , @aIndex )
     
    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)

Return

/*---------------------------------------------------------------------*
 | Func:  fMostrLog                                                    |
 | Desc:  Função para mostrar log                                      |
 *---------------------------------------------------------------------*/
Static Function fMostrLog()
    Local aArea       := GetArea()
    Local cTabela     := "ZW1"
    Private cCadastro := "Log de Processamento"
    Private aRotina   := {}

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})

	 //Selecionando a tabela e ordenando
    DbSelectArea(cTabela)
    (cTabela)->(DbSetOrder(1))
     
    //Montando o Browse
    mBrowse(6, 1, 22, 75, cTabela)
     
    //Encerrando a rotina
    (cTabela)->(DbCloseArea())
    RestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  TratNum                                                      |
 | Desc:  Função que trata dados numericos                             |
 *---------------------------------------------------------------------*/
Static Function TratNum(_nNum)
    Local nRet  := 0

    If _nNum == ""
        nRet := 0
    Else
        nRet := StrTran(_nNum, '.', '')
        nRet := VAL(AllTrim(StrTran(nRet, ',', '.')))
    EndIf

Return nRet

/*---------------------------------------------------------------------*
 | Func:  ChamaCons                                                    |
 | Desc:  Função que chama consulta padrão                             |
 *---------------------------------------------------------------------*/
Static Function ChamaCons(consulta,campo,Chamada)

    If (Chamada = "FilOri" .AND. Empty(cOriDesGrp)) .OR. (Chamada = "FilDes" .AND. Empty(cDesDesGrp))
		MsgStop("Insira primeiro o grupo e em seguida a filial", "Bloqueio")
	Else
		//Chama consulta padrão
		if ConPad1(NIL,NIL,NIL,consulta)
			campo    := aCpoRet[1]
		endif

		//Busca descrições do grupo e filial
		If Chamada	= "GrpOri"
			cOriDesGrp 	:= FWGrpName(campo)		
		ElseIf Chamada 	= "FilOri"
			cOriDesFil	:= FwFilialName( cOriGrp, campo, 1 )
		ElseIf Chamada	 = "GrpDes"
			cDesDesGrp 	:= FWGrpName(campo)
		ElseIf Chamada 	= "FilDes"
			cDesDesFil 	:= FwFilialName( cDesGrp, campo, 1 )
		EndIf
	EndIf
	
Return campo

/*---------------------------------------------------------------------*
 | Func:  fLegendaATV                                                  |
 | Desc:  Função mostra legenda                                        |
 *---------------------------------------------------------------------*/
Static Function fLegendaATV()

	Private cCadLegen := "Legenda Browse"

	Private aCores2 := {{         ,"      ====  STATUS DE IMPORTACAO   ====     " },;
		{ "BR_VERDE"			  ,"Importado com Sucesso"              },;
		{                         ,"__________________________________" },;
		{                         ,"      ==== STATUS DE PROCESSAMENTO ====     " },;
		{ "BR_CINZA"              ,"Nao Iniciado"                     },; 
		{ "BR_VERMELHO"           ,"Nao Processado"                     },; 
		{ "BR_VERDE"              ,"Processado"                         }}  


	BrwLegenda(cCadLegen,"Status dos Ativos",aCores2)

Return(.T.)

/*---------------------------------------------------------------------*
 | Func:  zAltFil                                                      |
 | Desc:  Função para alterar empresa e filial                         |
 *---------------------------------------------------------------------*/
Static Function zAltFil(cEmpNov, cFilNov, lVolta)
    Local aArea := FWGetArea()
    Default cEmpNov := cEmpAnt
    Default cFilNov := cFilAnt
    Default lVolta  := .F.
  
    //Se for para voltar o backup
    If lVolta
        //Se tiver empresa e filial de backup
        If ! Empty(cEmpBkp) .And. ! Empty(cFilBkp)
            cEmpAnt := cEmpBkp
            cFilAnt := cFilBkp
            cNumEmp := cEmpAnt + cFilAnt
  
            //Agora zera os backups
            cEmpBkp := ""
            cFilBkp := ""
        EndIf
  
    //Se não, será feito a troca para a filial
    Else
	//Se não tiver backup da empresa, realiza
        If Empty(cEmpBkp)
            cEmpBkp := cOriGrp
        EndIf
  
        //Se não tiver backup da filial, realiza
        If Empty(cFilBkp)
            cFilBkp := cOriFil
        EndIf
  
        //Se os parâmetros vieram vazios, coloca conteúdo default para não dar problema na troca
        If Empty(cEmpNov)
            cEmpNov := cEmpAnt
        EndIf
        If Empty(cFilNov)
            cFilNov := cFilAnt
        EndIf
  
        //Realiza a troca de filial para as novas
        cEmpAnt := cEmpNov
        cFilAnt := cFilNov
        cNumEmp := cEmpAnt + cFilAnt
    EndIf
	//Realiza a troca da empresa e filial
    OpenFile(cNumEmp)
  
    FWRestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  zProcRegua                                                   |
 | Desc:  Função para preparar regua de processamento                  |
 *---------------------------------------------------------------------*/
Static Function zProcRegua(oProcess, nTotal, nPercent)
    Local aArea      := FWGetArea()
    Default nTotal   := 0
    Default nPercent := 2
 
    If ValType(oProcess) != "U"
        //Divide o percentual por 100
        nPercent := nPercent / 100
 
        //Define as variáveis estáticas (que irão existir na memória somente nesse prw)
        nTotRegua := nTotal
        nAtuRegua := 0
 
        //Define a quantidade de registros a cada pulo da régua conforme o % (caso não haja, define como 1)
        nPerRegua := Round(nTotRegua * nPercent, 0)
        If Empty(nPerRegua)
            nPerRegua := 1
        EndIf
 
        //Agora seta o tamanho da régua (a primeira terá 3 pulos a cada 30%, a segunda terá "n" pulos conforme o percentual)
        aRegua1 := {.F., .F., .F.}
        oProcess:SetRegua1(Len(aRegua1))
        oProcess:SetRegua2(nPercent)
    EndIf
 
    FWRestArea(aArea)
Return

/*---------------------------------------------------------------------*
 | Func:  zIncProc                                                     |
 | Desc:  Função para inicia regua de processamento                    |
 *---------------------------------------------------------------------*/
Static Function zIncProc(oProcess, cMessage, lShow)
    Local aArea      := FWGetArea()
    Local nPercAtu   := 0
    Default cMessage := ""
    Default lShow    := .T.
 
    If ValType(oProcess) != "U"
        //Adiciona 1 na régua atual
        nAtuRegua += 1
 
        //Se o registro atual fizer parte do 2%, ai sim irá incrementar a régua
        //   (se for a cada  2, será  2%,  4%,  6%, etc)
        //   (se for a cada  5, será  5%, 10%, 15%, etc)
        //   (se for a cada 10, será 10%, 20%, 30%, etc)
        //   e assim por diante
        If Mod(nAtuRegua, nPerRegua) == 0
            //Pega o percentual atual
            nPercAtu := NoRound((nAtuRegua * 100) / nTotRegua, 0)
 
            //Se for exibir a quantidade de registros
            If lShow
                cMessage := "[" + cValToChar(nAtuRegua) + " de " + cValToChar(nTotRegua) + "] " + cMessage
            EndIf
            cMessage := "[" + cValToChar(nPercAtu) + "%]" + cMessage
 
            //Incrementa a segunda régua, mostrando a mensagem
            oProcess:IncRegua2(cMessage)
 
            //Se for maior que 30% e ainda não ter incrementado a primeira régua
            If nPercAtu >= 30 .And. ! aRegua1[1]
                oProcess:IncRegua1("Processando...")
                aRegua1[1] := .T.
            EndIf
 
            //Se for maior que 60% e ainda não ter incrementado a primeira régua
            If nPercAtu >= 60 .And. ! aRegua1[2]
                oProcess:IncRegua1("Processando...")
                aRegua1[2] := .T.
            EndIf
 
            //Se for maior que 90% e ainda não ter incrementado a primeira régua
            If nPercAtu >= 90 .And. ! aRegua1[3]
                oProcess:IncRegua1("Processando...")
                aRegua1[3] := .T.
            EndIf
        EndIf
    EndIf
 
    FWRestArea(aArea)
Return
