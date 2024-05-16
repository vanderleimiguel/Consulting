#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.CH"
#include 'dbtree.ch'

//Variáveis que existirão mesmo após sair do prw
Static cEmpBkp := ""
Static cFilBkp := ""

/*/{Protheus.doc} INPUTM21
Funcao para processamneto de ativos
@author Wagner Neves
@since 06/05/2024
@version 1.0
@type function
/*/
User Function INPUTM21()
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
	Private oBtnCar, oBtnExp, oBtnSai, oBtnLeg
	Private oSayOGrp, oGetOGrp, oGetOGrp2, oSayODG1, oGetODG1, oSayOFil, oGetOFil, oGetOFil2, oSayODE1, oGetODE1
	Private oSayDGrp, oGetDGrp, oGetDGrp2, oSayDDG1, oGetDDG1, oSayDFil, oGetDFil, oGetDFil2, oSayDDE1, oGetDDE1
	Private oBtnGrv
	Private oBtnVis
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
	oBtnVis  := TButton():New(010,550,"   Importar Arquivo" ,oDlg,({|| Processa({|| fImpArq(cDir)}, "Importação de Registros", "Importando...")}),70,20,,,.F.,.T.,.F.,,.F.,,,.F. )
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

	oBtnGrv := TButton():New(353,410,"   Processa"     	  ,oDlg,{|| fProcessa()         },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExp := TButton():New(353,480,"   Ver Log" 		  ,oDlg,{|| MostraLog() },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnSai := TButton():New(353,550,"   Encerrar"        ,oDlg,{|| oDlg:End()        },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )

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
 | Func:  fImpArq                                                      |
 | Desc:  Função que importa arquivo para browse e monta tabela        |
 *---------------------------------------------------------------------*/
Static Function fImpArq(cArqOri) 
	Local cArea:=getArea() 
    Local nTotLinhas  := 0
    Local cLinAtu     := ""
    Local nLinhaAtu   := 0
    Local aLinha      := {}
    Local aColSN1     := {}
    Local aColSN3     := {}    
    Local oArquivo
    Local aLinhas
    Local cChave	:= ""
    Local cCodGrp   := ""
    Local cCodBem   := ""
    Local cItem     := ""
    Local dDtAquis
    Local cDescBem  := ""
    Local cPlaqueta := ""
    Local dIniDepr
    Local nVlrOrig  := 0
    Local nTaxa     := 0
    Local nDeprBal  := 0
    Local nDeprMes  := 0
    Local nDeprAcu  := 0
	Local nSaldo    := 0
    Local dDataBaix 
    Local cObserv   := ""
    Local cGrupo    := ""
	Local dDtValid  
	Local nLinInic  := 0
	Local nLinImp   := 0
	Private aCampos 	:= {}
	Private aColunas 	:= {}
	Private oTempTable

   //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            // ProcRegua(nTotLinhas)
             
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
                // IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

				//Define linhas a processar
				dDtValid  	:= CTOD(aLinha[5])
				If dDtValid > CTOD("01/01/2000") .AND. ValType(dDtValid) = "D"               
                // If nLinhaAtu >= 3 .AND. nLinhaAtu <= 100
					nLinInic++

                    cChave		:= aLinha[1]
                    cCodGrp		:= PadL(aLinha[2],4,"0")                 
                    cCodBem   	:= aLinha[3]
                    cItem  		:= PadL(aLinha[4],4,"0")
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
	  aFieldsATV := {oCancela, oVermelho, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","",""}
	  (cAliasTmp)->(DbCloseArea())
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
		MsgInfo("Foram importados: " + cValToChar(nLinImp) + " registros de um total de: " + cValToChar(nLinInic) + " registros!", "Registros importados!")
	EndIf
	
	oBrw:SetArray(aFieldsATV)
	oBrw:bLine      := {|| {oVerde, oCinza,;
							aFieldsATV[oBrw:nAT,03], aFieldsATV[oBrw:nAT,04], aFieldsATV[oBrw:nAT,05],	aFieldsATV[oBrw:nAT,06],;
							aFieldsATV[oBrw:nAT,07], aFieldsATV[oBrw:nAT,08], aFieldsATV[oBrw:nAT,09], aFieldsATV[oBrw:nAT,10],;
							aFieldsATV[oBrw:nAT,11], aFieldsATV[oBrw:nAT,12], aFieldsATV[oBrw:nAT,13], aFieldsATV[oBrw:nAT,14],;
							aFieldsATV[oBrw:nAT,15], aFieldsATV[oBrw:nAT,16], aFieldsATV[oBrw:nAT,17], aFieldsATV[oBrw:nAT,18],;
							aFieldsATV[oBrw:nAT,19] }}
					
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
	ElseIf msgYesNo("Este processo realizará a o processamento de todos os ativos listado. Deseja continuar?","PERGUNTA")
		Processa({|| ProcAtivo()}, "Processamento de Ativos", "Processando...")
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
    Local cPlaq 		:= "00001"
    Local cPatrim 		:= ""
    Local cGrupo 		:= ""
    Local dAquisic 
    Local dIndDepr 
    Local cDescric 		:= ""
    Local cHistor 		:= ""
    Local cContab 		:= ""
    Local cCusto 		:= ""
    Local cSubCon 		:= ""
    Local cClvlCon 		:= ""
    Local nValor1 		:= 0
    Local nTaxa1 		:= 0
	Local nValor 		:= 0
    Local nTaxa 		:= 0
    Local aParam2 		:= {}
    Local aCab2 		:= {}
    Local aItens 		:= {}	
	Local cStBaixa		:= ""
	Local cStInclus		:= ""
	Local cStProces		:= ""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	//Percorre todos os ativos para baixa
	For nX := 1 To Len(aFieldsATV)

		cStBaixa	:= ""
		cStInclus	:= ""
		cStProces	:= ""
		cBase		:= aFieldsATV[nX][05]
		cItem		:= aFieldsATV[nX][06]
		cMotivo		:= "10"
		nQtdBaixa	:= 1
		cMetDepr	:= "0"
		cBaixa		:= "0"
		cTpSaldo	:= "1"

		SN3->(DbSetOrder(1))
        If SN3->(DBSeek(FWXFilial('SN3') + cBase + cItem))
			cTipo		:= SN3->N3_TIPO
			cBaixaAtu	:= SN3->N3_BAIXA
    		cHistor 	:= SN3->N3_HISTOR
    		cContab 	:= SN3->N3_CCONTAB
    		cCusto 		:= SN3->N3_CUSTBEM
    		cSubCon 	:= SN3->N3_SUBCCON
    		cClvlCon 	:= SN3->N3_CLVLCON
			
			If cBaixaAtu = "0"
				aCab := { {"FN6_FILIAL" ,XFilial("FN6") ,NIL},;
				{"FN6_CBASE" 	,cBase 		,NIL},;
				{"FN6_CITEM" 	,cItem 		,NIL},;
				{"FN6_MOTIVO" 	,cMotivo 	,NIL},;
				{"FN6_BAIXA" 	,100 		,NIL},;
				{"FN6_QTDBX" 	,nQtdBaixa 	,NIL},;
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
				
				Begin Transaction
				MsExecAuto({|a,b,c,d,e,f|ATFA036(a,b,c,d,e,f)},aCab,aAtivo,3,,.T./*lBaixaTodos*/,aParam)
				If lMsErroAuto
					nProcErr++
					cStBaixa	:= "Erro: Falha no execauto de baixa"
					cStInclus	:= "Erro: Falha na baixa"
					cStProces	:= "Erro: Falha na baixa"
					aFieldsATV[nX][02] := oVermelho
					DisarmTransaction()
				Else
					cStBaixa	:= "Baixado com sucesso"
    				nQtd 		:= 1
    				// cPlaq 		:= AllTrim(aFieldsATV[nX][09])
    				cPatrim 	:= "N"
    				cGrupo 		:= aFieldsATV[nX][04]
    				dAquisic	:= aFieldsATV[nX][07] //:= dDataBase //:= CTOD("01/06/20")//dDataBase
    				dIndDepr 	:= aFieldsATV[nX][10]//:= RetDinDepr(dDataBase)
    				cDescric 	:= aFieldsATV[nX][08]
    				nValor1 	:= aFieldsATV[nX][11]
    				nTaxa1 		:= aFieldsATV[nX][12]
    				aParam2 	:= {}
    				aCab2 		:= {}
    				aItens 		:= {}

					lMsErroAuto := .F.
					lMsHelpAuto := .T.

					//Troca a filial para a nova
    				zAltFil(cDesGrp , cDesFil)

					cItem	:= SOMA1(cItem)
					cPlaq	:= SOMA1(cPlaq)

					AAdd(aCab2,{"N1_FILIAL" 	, cDesFil 	,NIL})
					AAdd(aCab2,{"N1_CBASE" 		, cBase 	,NIL})
					AAdd(aCab2,{"N1_ITEM" 		, cItem 	,NIL})
					AAdd(aCab2,{"N1_AQUISIC"	, dAquisic 	,NIL})
					AAdd(aCab2,{"N1_DESCRIC"	, cDescric 	,NIL})
					AAdd(aCab2,{"N1_QUANTD" 	, nQtd 		,NIL})
					AAdd(aCab2,{"N1_CHAPA" 		, cPlaq 	,NIL})
					AAdd(aCab2,{"N1_PATRIM" 	, cPatrim 	,NIL})
					AAdd(aCab2,{"N1_GRUPO" 		, cGrupo 	,NIL})
					//Coloque os campos desejados aqui 

					aItens := {}
					AAdd(aItens,{;
					{"N3_FILIAL" 	, cDesFil 	,NIL},;
					{"N3_CBASE" 	, cBase 	,NIL},;
					{"N3_ITEM" 		, cItem 	,NIL},;
					{"N3_TIPO" 		, cTipo 	,NIL},;
					{"N3_BAIXA" 	, "0" 		,NIL},;
					{"N3_HISTOR" 	, cHistor 	,NIL},;
					{"N3_CCONTAB" 	, cContab 	,NIL},;
					{"N3_CUSTBEM" 	, cCusto 	,NIL},;
					{"N3_CDEPREC" 	, cContab 	,NIL},;
					{"N3_CDESP" 	, cContab 	,NIL},;
					{"N3_CCORREC" 	, cContab 	,NIL},;
					{"N3_CCUSTO" 	, cCusto 	,NIL},;
					{"N3_DINDEPR" 	, dIndDepr	,NIL},;
					{"N3_VORIG1" 	, nValor1 	,NIL},;
					{"N3_TXDEPR1" 	, nTaxa1 	,NIL},;
					{"N3_VORIG2" 	, nValor 	,NIL},;
					{"N3_TXDEPR2" 	, nTaxa 	,NIL},;
					{"N3_VORIG3" 	, nValor 	,NIL},;
					{"N3_TXDEPR3" 	, nTaxa 	,NIL},;
					{"N3_VORIG4" 	, nValor 	,NIL},;
					{"N3_TXDEPR4" 	, nTaxa 	,NIL},;
					{"N3_VORIG5" 	, nValor 	,NIL},;
					{"N3_SUBCCON" 	, cSubCon 	,NIL},;
					{"N3_CLVLCON" 	, cClvlCon 	,NIL},;
					{"N3_TXDEPR5" 	, nTaxa 	,NIL};
					})

					Begin Transaction
					MSExecAuto({|x,y,z| Atfa012(x,y,z)},aCab2,aItens,3,aParam2)
					If lMsErroAuto 
					    nProcErr++
						cStInclus	:= "Erro: Falha no execauto de inclusao"
						cStProces	:= "Erro: Falha na inclusao"
						aFieldsATV[nX][02] := oVermelho
						DisarmTransaction()
					Else
						nProcOk++
						cStInclus	:= "Incluido com sucesso"
						cStProces	:= "Processado com sucesso"
						aFieldsATV[nX][02] := oVerde
					Endif
					End Transaction
			
					//Voltando o backup da empresa e filial
					zAltFil( , , .T.)
				EndIf
				End Transaction
			Else
		    	nProcErr++
				cStBaixa	:= "Erro: Ativo já baixado"
				cStInclus	:= "Erro: Falha na baixa"
				cStProces	:= "Erro: Falha na baixa"
				aFieldsATV[nX][02] := oVermelho
			EndIf
		Else
		    nProcErr++
			cStBaixa	:= "Erro: Nao encontrou ativo"
			cStInclus	:= "Erro: Falha na baixa"
			cStProces	:= "Erro: Falha na baixa"
			aFieldsATV[nX][02] := oVermelho
        EndIf

		//Grava log de processamento
		GravLog(cBase, cItem, cStBaixa, cStInclus, cStProces)
	Next


	//Mensagem de finalizacao de baixas
	If nProcErr = 0 .AND. nProcOk > 0
		MsgInfo("Foram processados "+cValToChar(nProcOk)+" ativos com sucesso.","Processamento de Ativos")
	ElseIf nProcErr > 0 .AND. nProcOk > 0
		MsgInfo("Foram processados "+cValToChar(nProcOk)+" ativos com sucesso e "+cValToChar(nProcErr)+" ativos não foram processados.","Processamento de Ativos")
	ElseIf nProcErr > 0 .AND. nProcOk = 0
	    MsgInfo("Não foram processados nenhum ativo.","Processamento de Ativos")
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
Static Function GravLog(_cBase, _cItem, _cStBaixa, _cStInclus, _cStProces)

    DbSelectArea("ZW1")
    RecLock("ZW1", .T.)	

    ZW1->ZW1_FILIAL     := cOriFil
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
	ZW1->ZW1_PROCES		:= _cStProces 
	ZW1->ZW1_USER     	:= cCodUser 
	ZW1->ZW1_NMUSER     := UsrRetName(cCodUser) 
    
    ZW1->(MsUnLock())

Return

/*---------------------------------------------------------------------*
 | Func:  MostraLog                                                    |
 | Desc:  Função para mostrar log                                      |
 *---------------------------------------------------------------------*/
Static Function MostraLog()
    Local aArea       := GetArea()
    Local cTabela     := "ZW1"
    Private cCadastro := "Log de Processamento"
    Private aRotina   := {}

    //Montando o Array aRotina, com funções que serão mostradas no menu
    aAdd(aRotina,{"Pesquisar",  "AxPesqui", 0, 1})
    aAdd(aRotina,{"Visualizar", "AxVisual", 0, 2})
    // aAdd(aRotina,{"Incluir",    "AxInclui", 0, 3})
    // aAdd(aRotina,{"Alterar",    "AxAltera", 0, 4})
    // aAdd(aRotina,{"Excluir",    "AxDeleta", 0, 5})

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
