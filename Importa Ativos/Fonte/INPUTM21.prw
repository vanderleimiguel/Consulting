/*                          
+-----------------------------------------------------------------------+
¦Programa  ¦INPUTM21 ¦ Autor ¦ Inacio Silva           ¦ Data ¦01.03.2016¦
+----------+------------------------------------------------------------¦
¦Descriçào ¦Baixa Automática 2.0. Reformulação do processo utilizado    ¦
¦          ¦pelo departamento financeiro para baixa de CTE's de clientes¦
¦          ¦conforme planilha CSV.                                      ¦
¦          ¦                                                            ¦
+----------+------------------------------------------------------------¦
¦ Uso      ¦ ESPECIFICO PARA EXPRESSO NEPOMUCENO                        ¦
+-----------------------------------------------------------------------¦
¦           ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL            ¦
+-----------------------------------------------------------------------¦
¦PROGRAMADOR      ¦ DATA       ¦ MOTIVO DA ALTERACAO                    ¦
+-----------------+------------+----------------------------------------¦
¦                 |            ¦     ff                                   ¦                                                 
+-----------------------------------------------------------------------+
*/
#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.CH"
#include 'dbtree.ch'

User Function INPUTM21()
	************************************************************************************************************************
	*    Função principal que realiza a chamada da aplicação
	**
	***
	****
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

	Private oGroup, oGroupCli, oGroupCTE
	Private oSayDir, oSayDescNat
	Private oGetDir, oGetNomeBanco
	Private oBtnCar, oBtnExp, oBtnSai, oBtnLeg
	Private oSayOGrp, oGetOGrp, oGetOGrp2, oSayODG1, oGetODG1, oSayOFil, oGetOFil, oGetOFil2, oSayODE1, oGetODE1
	Private oSayDGrp, oGetDGrp, oGetDGrp2, oSayDDG1, oGetDDG1, oSayDFil, oGetDFil, oGetDFil2, oSayDDE1, oGetDDE1
	//private oSayCNPJ,oSayNome,oSayDtArq,oSayBanco,oSayAgencia,oSayConta,oSayNatureza,oSayValor,oSayQuant
	//Private oGetCNPJ,oGetNome,oGetDtArq,oGetBanco,oGetAgencia,oGetConta,oGetNatureza,oGetDescNat,oGetValor,oGetQuant
	//Private oBtnVal
	Private oBtnGrv
	//Private oBtnCan
	Private oBtnVis
	Private cDir := ""
	Private cNome, cCNPJ, cBanco, cAgencia, cConta, cNomeBanco, cNatureza, cDescNat, cLojDevNew, cStCteBx, cSTTitBx
	Private nValor, nQuant, nOpcLog
	Private cOriGrp, cOriDesGrp, cOriFil, cOriDesFil
	Private cDesGrp, cDesDesGrp, cDesFil, cDesDesFil
	Private dDtArq
	Private aHeaderCTE := {}
	Private aFieldsCTE := {}
	Private aLogBx     := {}
	Private lMarca     := .T.
	Private aFile      := {}

	nValor := 0
	nQuant := 0

	fMontaTela()

Return()


Static Function fMontaTela()
	************************************************************************************************************************
	*    Tela da baixa automatica 2.0.
	**
	***
	****

	Local cEstBT, cEstBTGrv, cEstBTCan, cEstBTExp, cEstBTSai, cEstBTVal, cEstBTImp, cEstBTLeg, cEstGet, cEstGet2, cEstPanel, cEstPanelBranco, cEstSay

	aHeaderCTE := {"Sel","Imp","Proc","Chave","Cod_Grupo","Cod_Bem", "Item", "Dt_Aquis", "Descr_Bem", "Plaqueta", "Inicio_Depr", "Valor_Orig", "Taxa_Depr", "Depr_Balanco",;
		"Depr_Mes", "Depr_Acum", "Saldo", "Data_Baixa", "Observação","Grupo"}

	Aadd(aFieldsCTE, {.F.,oCorSit,oCor,"", "", "", "", "", "", "", "", "", "", "", "","","","","","","","",""})

	cNatureza := Space(5)

	DEFINE DIALOG oDlg TITLE "Importação, Baixa e Geração Ativo Fixo" FROM 180,180 TO 230,345 // Usando o método New

//Esta parte é a responsável pela criação dos estilos que serão aplicados em cada objeto posteriormente
	cEstBT    := "QPushButton {background-image: url(rpo:totvsprinter_excel.png);background-repeat: none; margin: 2px;}"
	cEstBTGrv := "QPushButton {background-image: url(rpo:icone_ok.jpg);background-repeat: none; margin: 2px; font: bold 12px Arial;}"
	cEstBTCan := "QPushButton {background-image: url(rpo:bmpdel_mdi.png);background-repeat: none; margin: 4px; font: bold 12px Arial;}"
	cEstBTExp := "QPushButton {background-image: url(rpo:mdiexcel_mdi.png);background-repeat: none; margin: 4px; font: bold 12px Arial;}"
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
	//oBtnVal  := TButton():New(010,364,"   Validar Arquivo"  ,oDlg,{|| fValidArq()     },70,20,,,.F.,.T.,.F.,,.F.,,,.F. )
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
	oBtnLeg       := TButton():New(080,550,"   Legenda",oDlg,{|| fLegendaCTE() },70,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	oGroupCTE := TGroup()  :New(120,005,350,640,"Registros que compõem o arquivo",oDlg,,,.T.)
	oBrw      := TWBrowse():New(130,010,620,220,,aHeaderCTE,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.)
	oBrw:SetArray(aFieldsCTE)
	oBrw:blDblClick := {|| (aFieldsCTE[oBrw:nAT,01] := !aFieldsCTE[oBrw:nAT,01]),fVldMarcTit() }
	oBrw:bLine      := {|| {If(;
		aFieldsCTE[oBrw:nAT,01],_oOk,_oNo),;
		aFieldsCTE[oBrw:nAT,02],;
		aFieldsCTE[oBrw:nAT,03],;
		aFieldsCTE[oBrw:nAT,04],;
		aFieldsCTE[oBrw:nAT,05],;
		aFieldsCTE[oBrw:nAT,06],;
		aFieldsCTE[oBrw:nAT,07],;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,08],"@E 99/99/9999")),;
		aFieldsCTE[oBrw:nAT,09],;
		aFieldsCTE[oBrw:nAT,10],;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,11],"@E 99/99/9999")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,12],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,13],"@E 999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,14],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,15],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,16],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,17],"@E 999,999,999.99")),;
		AllTrim(Transform(aFieldsCTE[oBrw:nAT,18],"@E 99/99/9999")),;
		aFieldsCTE[oBrw:nAT,19],;
		aFieldsCTE[oBrw:nAT,20] }}

	//oBtnGrv := TButton():New(353,190,"   Processa"     	  ,oDlg,{|| fGravar()         },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oBtnCan := TButton():New(353,260,"   Limpar Browse"   ,oDlg,{|| fLimpaBrw()		 },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnGrv := TButton():New(353,410,"   Processa"     	  ,oDlg,{|| fGravar()         },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnExp := TButton():New(353,480,"   Exp Log Excel"   ,oDlg,{|| fCriaLog(nOpcLog) },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtnSai := TButton():New(353,550,"   Encerrar"        ,oDlg,{|| oDlg:End()        },70,23,,,.F.,.T.,.F.,,.F.,,,.F. )

/*Neste momento, para definirmos o estilo, usaremos a propriedade SetCss, no qual informaremos a ela a variavel que contém 
  o estilo que criamos anteriormente.*/
oGroup       :SetCss(cEstPanel)
oBtnCar      :SetCss(cEstBT) 
//oBtnVal      :SetCss(cEstBTVal)
oBtnVis      :SetCss(cEstBTVis)
oGetDir      :SetCss(cEstGet)

oGroupCli    :SetCss(cEstPanelBranco)
// oGetCNPJ     :SetCss(cEstGet2)
// oGetNome     :SetCss(cEstGet2)
//GetDtArq    :SetCss(cEstGet2)
//oGetBanco    :SetCss(cEstGet)
//oGetNomeBanco:SetCss(cEstGet)
//oGetAgencia  :SetCss(cEstGet)
//oGetConta    :SetCss(cEstGet)
//oGetNatureza :SetCss(cEstGet)
//oGetDescNat  :SetCss(cEstGet)
//oGetValor    :SetCss(cEstGet2)
//oGetQuant    :SetCss(cEstGet2)
oBtnLeg      :SetCss(cEstBTLeg)

oGroupCTE    :SetCss(cEstPanelBranco)

oBtnGrv      :SetCss(cEstBTGrv) 
//oBtnCan      :SetCss(cEstBTCan) 
oBtnExp      :SetCss(cEstBTExp) 
oBtnSai      :SetCss(cEstBTSai) 

ACTIVATE DIALOG oDlg CENTERED 

Return


Static Function fAbreDir(cDir)
************************************************************************************************************************
*    Chamada para a tela de abrir arquivo.
**
***
****           

cDir := cGetFile('Arquivo *|*.CSV|Arquivo CSV|*.CSV','Selecione arquivo',0,'C:\ArquivosCSV\',.T.,,.F.)


Return


Static Function fValidArq()
************************************************************************************************************************
*    Validação do arquivo selecionado.
**
***
****           

Local aRet := {}
Local nX, cX
Local aRow, aCab, cCGC, cCod, cCli, cFile, XBCO
Local nOpc1 := 1 //Criado temporariamente para testar a validação apenas
Local cCampo := ""
Local nContLin := 0

Private cChave

aFieldsCTE := {}

oBrw:SetArray(aFieldsCTE)
oBrw:blDblClick := {|| (aFieldsCTE[oBrw:nAT,01] := !aFieldsCTE[oBrw:nAT,01]),fVldMarcTit() }
oBrw:bLine      := {|| {If(aFieldsCTE[oBrw:nAT,01],_oOk,_oNo), aFieldsCTE[oBrw:nAT,02],;
						aFieldsCTE[oBrw:nAT,03], aFieldsCTE[oBrw:nAT,04], aFieldsCTE[oBrw:nAT,05], aFieldsCTE[oBrw:nAT,06],;
						aFieldsCTE[oBrw:nAT,07], aFieldsCTE[oBrw:nAT,08], aFieldsCTE[oBrw:nAT,09], aFieldsCTE[oBrw:nAT,10],;
						aFieldsCTE[oBrw:nAT,11], AllTrim(Transform(aFieldsCTE[oBrw:nAT,12],"@E 999,999,999.99")), aFieldsCTE[oBrw:nAT,13],;
						aFieldsCTE[oBrw:nAT,15], aFieldsCTE[oBrw:nAT,16], aFieldsCTE[oBrw:nAT,18], aFieldsCTE[oBrw:nAT,19], aFieldsCTE[oBrw:nAT,20] }}

If DDATABASE <= GETMV("MV_DATAFIN")

   MsgInfo("A data base não pode ser menor que a data de fechamento do parametro MV_DATAFIN")
   Return(.F.) 
   
EndIf

#Define XNAT "11101"	//Natureza Padrão do Titulo

If Empty(cDir)
	msgalert("Nenhum arquivo selecionado. Não é possível fazer a Validação.","ATENÇÃO")
	Return()
Else
             
	IF SM0->M0_CODIGO == "01"   // EXPRESSO NEPOMUCENO
	   XBCO:= "2373484 0010012" //Banco Agencia e Conta Padrão para Baixa
	ELSEIF SM0->M0_CODIGO == "09"   // NEPOMUCENO CARGAS
	   XBCO:= "C01220  220200 "
	ENDIF
		
	cFile := cDir
	aCab := {"CNPJ", "DATA", "SERIE;CTRC;VALOR"}
	aRow :={}

	If !Empty(cFile)
		
	   aFile := Directory(cFile)

		//	aFile[1,1] == C Nome do Arquivo
		//	aFile[1,2] == N Tamanho
		//	aFile[1,3] == D Data
		//	aFile[1,4] == C Horas
		//	aFile[1,5] == C Atributo
	      If FT_FUSE(cFile) > 0
	
	         Procregua(FT_FLASTREC())
	         FT_FGOTOP()
	         aRet := {}
	
	         //Valida Cabeçalho do Arquivo
	         For nX := 1 To Len(aCab)
		         cX := FT_FREADLN()
		         If ";"$(aCab[nX]) .And. Upper(cX) != Upper(aCab[nX])
			        MsgInfo("Arquivo Invalido - 01")
			        aRet:={}
			        Return(aRet)
		         Else
			        aAdd(aRet, StrToArray(cX, ";"))
		 	        If aCab[nX] != aRet[nX,1]
				       MsgInfo("Arquivo Invalido - 02")
				       aRet:={}
				       Return(aRet)
			        Endif
		         Endif
		         FT_FSKIP()
	         Next
	
	         aCab := aClone(aRet)
	         aRet := {}
	
	         //Obter Linhas do Arquivo
	         While !FT_FEOF()
		           IncProc()
		           
		           //Converte para Array
		           aAdd(aRet, StrToArray(FT_FREADLN(), ";"))
		           FT_FSKIP()
		           
		           nContLin += 1
		           
		           If nContLin > 1000
		              msginfo("Não é permitido gerar baixa com mais de 1000 CTE's. Favor refazer a planilha e tentar novamente.","ATENÇÃO")
		              Return()
		           EndIf
	         Enddo
			 FT_FUSE()

	
			 If len(aRet)==0 
			    Return(aRet)   
	       	 Endif
				   
	       //Valida CNPJ, Data e Cliente
			 SA1->(DbSetOrder(3))
			 cCGC  := aCab[1,2]
			 cCNPJ := aCab[1,2]
			 
			 //Remover Mascara do CNPJ
			 cCGC := StrTran(cCGC,".","")
			 cCGC := StrTran(cCGC,"/","")
			 cCGC := StrTran(cCGC,"-","")
			 dDtArq := CTOD(aCab[2,2])
			 
			 If !CGC(cCGC, Nil, .F.)
				MsgInfo("CNPJ ou CPF Invalido, Erro Nome do Arquivo")
	            Return(aRet)
			 ElseIf Empty(dDtArq)
				MsgInfo("Data Invalida, Erro Data do Arquivo")
				Return(aRet)
			 ElseIf !SA1->(DbSeek(xFilial("SA1")+cCGC))
			  	MsgInfo("Cliente não Cadastrado"+CRLF+"CNPJ/CPF "+cCGC)
				Return(aRet)
			 Endif
	       
			 _lDtOK:= .t. 
			 If dDatabase <> dDtArq
			    _lDtOK:= MSGYESNO("Database diferente Data Arquivo!!! Continua?")
	         Endif 
				
			 If !_lDtOK   
	  	        aRet:={}
	  	        cDir := ""
	   	 Endif
		   
		   cCod  := SA1->A1_COD
	      cLoj  := SA1->A1_LOJA
	      cNome := SA1->A1_NREDUZ
		  
		  Endif
	    
	Else
	   
	   MSGALERT("ARQUIVO VAZIO!! - FAVOR PREENCHER COM DADOS")
	   
	   aRet:={}                             
	
	EndIf
	   
	If Len(aRet) ==0
	   Return(aRet)
	Endif

EndIf

//Conta Padrão
SA6->(DbSetOrder(1))
If SA6->(DbSeek(xFilial("SA6")+XBCO))
	cBanco     := SA6->A6_COD
	cAgencia   := SA6->A6_AGENCIA
	cConta     := SA6->A6_NUMCON
Else
	MsgInfo("Banco Nao Cadastrado, Codigo: "+XBCO)
	Return(Nil)
Endif

//Natureza Padrão
SED->(DbSetOrder(1))
If SED->(DbSeek(xFilial("SED")+XNAT))
	cDescNat  := SED->ED_DESCRIC
	cNatureza := SED->ED_CODIGO
Else
	MsgInfo("Natureza Invalida: "+XNAT)
	Return(Nil)
Endif

If Empty(cCod)
	MsgInfo("Cliente Invalido CPF/CNPJ: "+cCGC)
	Return(Nil)
Endif

aFieldsCTE := {}

For nX := 1 To Len(aRet)

	cCampo := aRet[nX,2]   

	cCTE      := PadL(aRet[nX,2], 9, "0")
	cSerieCTE := aRet[nX,1]	
	cKey      := ""
	nVlPlan := Abs(Str2Val(aRet[nX,3]))

	MsAguarde({|| Aadd(aFieldsCTE, fBuscaCTE(cSerieCTE, cCTE, cCod, cLoj, nVlPlan)),"Aguarde - ", "Processando Arquivo"})
   
Next nX

If Empty(aFieldsCTE)
	
	Aadd(aFieldsCTE, {lMarca,oCorSit,oCor,"", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})

EndIf

nValor := 0
nQuant := 0

For nX := 1 To Len(aFieldsCTE)

If aFieldsCTE[nX,01]

	nValor += aFieldsCTE[nX,10]
	nQuant += 1

EndIf

Next(nX)

//Refresh nos campos do cabeçalho
//oGetCNPJ     :Refresh()
//oGetNome     :Refresh()
//oGetDtArq    :Refresh()
//oGetBanco    :Refresh()
//oGetAgencia  :Refresh()
//oGetConta    :Refresh()
//oGetNatureza :Refresh()
//oGetDescNat  :Refresh()


oBrw:SetArray(aFieldsCTE)
oBrw:blDblClick := {|| (aFieldsCTE[oBrw:nAT,01] := !aFieldsCTE[oBrw:nAT,01]),fVldMarcTit() }
oBrw:bLine      := {|| {If(aFieldsCTE[oBrw:nAT,01],_oOk,_oNo), aFieldsCTE[oBrw:nAT,02],;
						aFieldsCTE[oBrw:nAT,03], aFieldsCTE[oBrw:nAT,04], aFieldsCTE[oBrw:nAT,05], aFieldsCTE[oBrw:nAT,06],;
						aFieldsCTE[oBrw:nAT,07], aFieldsCTE[oBrw:nAT,08], aFieldsCTE[oBrw:nAT,09], aFieldsCTE[oBrw:nAT,10],;
						aFieldsCTE[oBrw:nAT,11], AllTrim(Transform(aFieldsCTE[oBrw:nAT,12],"@E 999,999,999.99")), aFieldsCTE[oBrw:nAT,13],;
						aFieldsCTE[oBrw:nAT,15], aFieldsCTE[oBrw:nAT,16], aFieldsCTE[oBrw:nAT,17], aFieldsCTE[oBrw:nAT,18], aFieldsCTE[oBrw:nAT,19] }}


Return()



Static Function fBuscaCTE(cSerieCTE, cCTE, cCli, cLoj, nVlPlan)
****************************************************************************************************************************
*    Função para buscar os CTEs de acordo com a planilha selecionada.
**
*** 
****
Local cQry, aRet1, aBrw, oBrw1, oDlg1, nX, cKey, _aArea, oBtnGrava, cEstBTGrv, cEstBrowse, aFieldReg
     
cQry := " SELECT DT6_FILDOC,DT6_DOC,DT6_DATEMI,DT6_PREFIX, DT6_NUM, DT6_TIPO, DT6_VALFAT, "
cQry += " DT6_CLIDEV,DT6_LOJDEV,DT6_VALIMP,DT6_XSTABX,DT6_XLOTBX,DT6_SERIE "
cQry += " FROM "+RetSQLName("DT6") "
cQry += " WHERE D_E_L_E_T_ = ' ' "
cQry += "   AND DT6_FILIAL = '"+xFilial("DT6")+"' "
cQry += "   AND DT6_SERIE  = '"+cSerieCTE+"'      "
cQry += "   AND DT6_DOC    = '"+cCTE+"' "
cQry += "   AND DT6_CLIDEV = '"+cCli+"' "
cQry += " ORDER BY DT6_PREFIX, DT6_NUM, DT6_TIPO"

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), 'TMPDT6', .F., .F.)

dbSelectArea("TMPDT6")
TMPDT6->(dbGoTop())

If TMPDT6->(Eof())

   lMarca  := .F.
   oCorSit := oCancela
   oCor    := oPreto
   cStCteBx:= "CTE NÃO PODE SER BAIXADO"
   cSTTitBx:= "CTE INEXISTENTE NO PROTHEUS"
   
  aRet1 := {lMarca,oCorSit, oCor, "", cSerieCTE, cCTE, nVlPlan, "", "", "", "", "", "", "", "", "", "", "", "", "",cStCteBx,cSTTitBx}

  TMPDT6->(DbCloseArea())
  
  Return(aRet1)
   
EndIf

aFieldReg := {}
aBrw      := {}
aRet1     := {}

While TMPDT6->(!Eof())                    

	Aadd(aFieldReg,{TMPDT6->DT6_FILDOC, TMPDT6->DT6_SERIE, TMPDT6->DT6_DOC, TMPDT6->DT6_VALFAT,;
		 		    	 TMPDT6->DT6_VALIMP, TMPDT6->DT6_NUM, TMPDT6->DT6_DATEMI, TMPDT6->DT6_PREFIX, TMPDT6->DT6_TIPO,;
		 		    	 TMPDT6->DT6_CLIDEV, TMPDT6->DT6_LOJDEV, TMPDT6->DT6_XSTABX, TMPDT6->DT6_XLOTBX}) 
	
	dbSkip()

End
       
For nX := 1 To Len(aFieldReg)

   If aFieldReg[nX,04] = nVlPlan
      oCorSit := oBandVerd
      cStCteBx:= "CTE = PLANILHA"
   ElseIf aFieldReg[nX,04] > nVlPlan
      lMarca := .F.
      oCorSit := oBandVerm
      cStCteBx:= "CTE > PLANILHA"
   Else
      lMarca := .F.
      oCorSit := oBandAmar
   	cStCteBx:= "CTE < PLANILHA"
   EndIf

   If Empty(aFieldReg[nX,03])
      lMarca := .F.
      oCorSit:= oCancela
      oCor   := oPreto
      cStCteBx := "CTE NÃO PODE SER BAIXADO"
      cSTTitBx := "CTE INEXISTENTE NO PROTHEUS"
   ElseIf aFieldReg[nX,12] $ "T|P"
      lMarca := .F.
      oCorSit:= oCancela
      ocor   := oVermelho
      cStCteBx:="CTE NÃO PODE SER BAIXADO"
      cSTTitBx:="TÍTULO JÁ BAIXADO NO PROTHEUS"
   Else
      
	  fVldTit(@oCorSit, @oCor, @cLojDevNew, aFieldReg[nX,10], aFieldReg[nX,11], aFieldReg[nX,08], aFieldReg[nX,06], aFieldReg[nX,09], @lMarca, @cStCteBx, @cSTTitBx) 
	  	   
   Endif

   If oCor = oAzul .And. (oCorSit = oBandVerm .Or. oCorSit = oBandAmar)
   	  lMarca := .F.
   EndIf
   
   If !Empty(cLojDevNew) .And. cLojDevNew != aFieldReg[nX,11]
      aFieldReg[nX,11] := cLojDevNew
   EndIf
				   
   //imposto retido
   _nVlimpret:=0

   dbSelectArea("SF3")
   dbSetOrder(5)

   dbSeek(aFieldReg[nX,01]+aFieldReg[nX,02]+aFieldReg[nX,03]+aFieldReg[nX,10]+ aFieldReg[nX,11])

   If !eof()
      _nVlimpret:= SF3->F3_ICMSRET
   Endif   
   
   If Len(aFieldReg) > 1   
       aAdd(aBrw, {lMarca,oCorSit, oCor, aFieldReg[nX,01],cSerieCTE, cCTE, nVlPlan, aFieldReg[nX,02], aFieldReg[nX,03], aFieldReg[nX,04],;
	  		       _nVlimpret, aFieldReg[nX,06], aFieldReg[nX,07], aFieldReg[nX,08], aFieldReg[nX,09], aFieldReg[nX,10], aFieldReg[nX,11],;
	  		       aFieldReg[nX,12], aFieldReg[nX,13], nVlPlan - aFieldReg[nX,04], cStCteBx, cSTTitBx })
   Else
      aRet1 := {lMarca,oCorSit, oCor, aFieldReg[nX,01], cSerieCTE, cCTE, nVlPlan, aFieldReg[nX,02], aFieldReg[nX,03], aFieldReg[nX,04],;
	 		    _nVlimpret, nVlPlan - aFieldReg[nX,04], aFieldReg[nX,06], aFieldReg[nX,07], aFieldReg[nX,08], aFieldReg[nX,09],;
	 		    aFieldReg[nX,10], aFieldReg[nX,11], aFieldReg[nX,12], aFieldReg[nX,13], cStCteBx, cSTTitBx}
   EndIf
   
Next(nX)

TMPDT6->(DbCloseArea())

If Len(aBrw) > 1

	aRet1 := {}

	nX := 1
	
	DEFINE DIALOG oDlg1 FROM 0,0 TO 220,700 PIXEL TITLE "SELEÇÃO TITULO x CTE"
	
	cEstBTGrv := "QPushButton {background-image: url(rpo:checked.png);background-repeat: none; margin: 2px; font: bold 12px Arial;}"
	
	@ 000,000 LISTBOX oBrw1 FIELDS SIZE 150,090 OF oDlg1 PIXEL

	oBrw1:Align := CONTROL_ALIGN_TOP
	oBrw1:bLDblClick:={|| nX := oBrw1:nAt, oDlg1:End()}
	oBrw1:AddColumn(TCColumn():New("Filial" ,{|| aBrw[oBrw1:nAt, 4]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("CTRC"   ,{|| aBrw[oBrw1:nAt, 6]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Emissao",{|| substr(aBrw[oBrw1:nAt, 13],7,2)+"/"},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Prefixo",{|| aBrw[oBrw1:nAt, 14]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Numero" ,{|| aBrw[oBrw1:nAt, 12]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Tipo"   ,{|| aBrw[oBrw1:nAt, 15]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Valor"  ,{|| aBrw[oBrw1:nAt, 10]},"@E 999,999,999.99",,,,40,.F.))
	oBrw1:AddColumn(TCColumn():New("Vl.Plan",{|| aBrw[oBrw1:nAt,  7]},"@E 999,999,999.99",,,,40,.F.))
	oBrw1:AddColumn(TCColumn():New("Vl.ImpR",{|| aBrw[oBrw1:nAt, 11]},"@E 999,999,999.99",,,,40,.F.))
	oBrw1:AddColumn(TCColumn():New("Cliente",{|| aBrw[oBrw1:nAt, 16]},,,,,25,.F.))
	oBrw1:AddColumn(TCColumn():New("Loja"   ,{|| aBrw[oBrw1:nAt, 17]},,,,,25,.F.))

    oBtnGrava := TButton():New(090,160,"      Confirmar"	,oDlg1,{|| nX := oBrw1:nAt, oDlg1:End() },50,20,,,.F.,.T.,.F.,,.F.,,,.F. )

	oBrw1:SetArray(aBrw)
	oDlg1:lEscClose:=.F.
	
	oBtnGrava:SetCss(cEstBTGrv) 
	
	ACTIVATE MSDIALOG oDlg1 CENTERED

	aRet1 := {aBrw[nX,1], aBrw[nX,2], aBrw[nX,3], aBrw[nX,4],aBrw[nX,5],aBrw[nX,6],aBrw[nX,7], aBrw[nX,8], aBrw[nX,9], aBrw[nX,10],;
			    aBrw[nX,11], aBrw[nX,20], aBrw[nX,12], aBrw[nX,13], aBrw[nX,14], aBrw[nX,15], aBrw[nX,16], aBrw[nX,17], aBrw[nX,18], aBrw[nX,19],;
			    aBrw[nX,21], aBrw[nX,22] }

Endif
  
Return(aRet1)



Static Function	fVldTit(oCorSit, oCor, cLojDevNew, cClidev, cLojDev, cPrefixo, cNumero, cTipo, lMarca, cStCteBx, cSTTitBx) 
****************************************************************************************************************************
*    Validar a Situação dos CTEs para identificar se podem ou não serem baixados
**
*** 
****
Local cQuery1

cQuery := " SELECT E1_CLIENTE, E1_LOJA, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, E1_VALOR, E1_SALDO, E1_NUMBOR "
cQuery += " FROM "+RetSQLName("SE1")+" (NOLOCK) "
cQuery += " WHERE D_E_L_E_T_ = '' "
cQuery += "   AND E1_CLIENTE = '"+cCliDev+"' "
cQuery += "   AND E1_PREFIXO = '"+cPrefixo+"' "
cQuery += "   AND E1_NUM     = '"+cNumero+"' " 

If cTipo != 'CTR'
	cQuery += "   AND E1_PARCELA = '0A' "
EndIf

cQuery += "   AND E1_TIPO    = '"+cTipo+"' " 

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TIT', .F., .F.)

dbSelectArea("TIT")
TIT->(dbGoTop())

If TIT->(! EOF())

	If TIT->E1_LOJA != cLojDev
		cLojDevNew := TIT->E1_LOJA
	EndIf
	
    If ! EMPTY(TIT->E1_NUMBOR)
		lMarca := .F.
      oCorSit:= oCancela
		oCor   := oRosa
		cStCteBx := "CTE NÃO PODE SER BAIXADO"
		cSTTitBx := "TITULO EM BORDERO"
    ElseIf TIT->E1_SALDO== 0
       lMarca := .F.
       oCorSit:= oCancela
       oCor := oVermelho
       cStCteBx := "CTE NÃO PODE SER BAIXADO"
       cSTTitBx := "TITULO JÁ BAIXADO NO PROTHEUS"
    ElseIf TIT->E1_SALDO != nVlPlan 
	   	If TIT->E1_SALDO > nVlPlan
	      oCorSit := oBandVerm
	      cStCteBx:= "CTE > PLANILHA"
         lMarca := .T.
	   	ElseIf TIT->E1_SALDO < nVlPlan
	   	  oCorSit := oBandAmar
	   	  cStCteBx:= "CTE < PLANILHA"
	   	  lMarca := .F.
	    	EndIf
         
         oCor := oVioleta
         cSTTitBx := "VALOR DA PLANILHA DIFERENTE DO VALOR DO TITULO "+TIT->E1_PREFIXO+TIT->E1_NUM+TIT->E1_TIPO
    Else
       lMarca := .T.
       oCorSit := oBandVerd
       oCor := oVerde
	   cStCteBx:= "CTE = PLANILHA"
       cSTTitBx := "CTE COM FATURA APTO A SER BAIXADO"
    Endif

Else
    lMarca := .T.
    oCor := oAzul
	cSTTitBx := "CTE SEM FATURA APTO A SER BAIXADO"
EndIf

TIT->(dbCloseArea())

Return()



Static Function fVldMarcTit()
************************************************************************************************************************
*    Valida a marcação dos CTEs para baixa.
**
***
****           

	If aFieldsCTE[oBrw:nAT,06] = ""
		aFieldsCTE[oBrw:nAT,01] := .F.
		Return(.F.)
	EndIf

	If aFieldsCTE[oBrw:nAT,02] = oCancela .Or. aFieldsCTE[oBrw:nAT,03] = oPreto .Or. aFieldsCTE[oBrw:nAT,03] = oVermelho
		msgAlert("O Título não pode ser marcado pois não está apto a ser faturado","ATENÇÃO!")
		aFieldsCTE[oBrw:nAT,01] := .F.
		Return(.F.)
	EndIf

	If aFieldsCTE[oBrw:nAT,01] .And. aFieldsCTE[oBrw:nAT,02] = oBandAmar .And. aFieldsCTE[oBrw:nAT,03] = oLaranja
		msgAlert("Saldo insuficiente para baixar o Título. Favor Verificar.","ATENÇÃO!")
		aFieldsCTE[oBrw:nAT,01] := .F.
		Return(.F.)
	EndIf

	If aFieldsCTE[oBrw:nAT,01] .And. aFieldsCTE[oBrw:nAT,02] = oBandAmar .And. aFieldsCTE[oBrw:nAT,03] = oAzul
		msgAlert("Existe diferença de valor. Favor fazer um RA manual e corrigir a planilha.","ATENÇÃO!")
		aFieldsCTE[oBrw:nAT,01] := .F.
		Return(.F.)
	EndIf

	If aFieldsCTE[oBrw:nAT,01] .And. aFieldsCTE[oBrw:nAT,02] = oBandVerm
		msgAlert("Será gerada automaticamente uma baixa parcial para esse título.","ATENÇÃO!")
	EndIf

	If aFieldsCTE[oBrw:nAT,01]
		nValor += aFieldsCTE[oBrw:nAT,10]
		nQuant += 1
	Else
		nValor -= aFieldsCTE[oBrw:nAT,10]
		nQuant -= 1
	EndIf

	// oGetValor:Refresh()
	// oGetQuant:Refresh()

Return()



Static Function fImpArq(cArqOri)
************************************************************************************************************************
*    Função para visualizar o Lote selecionado a partir da consulta padrão.
**
***
****    
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
	Private cCodUser  	:= RetCodUsr()
	Private aCampos 	:= {}
	Private cAliasTmp 	:= "SZZ_" + cCodUser
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
                    cItem  		:= PadL(aLinha[4],3,"0")
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

	(cAliasTmp)->(dbGoTop())
	
	If (cAliasTmp)->(Eof())
	
	  aFieldsCTE := {.F.,oCancela, oVermelho, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "","",""}
	
	  (cAliasTmp)->(DbCloseArea())
	  	   
	Else
	
		aFieldsCTE := {}
		While (cAliasTmp)->(!Eof())                    
			oCorTit := oVerde
			Aadd(aFieldsCTE,{.F., oCorTit, oVermelho, (cAliasTmp)->CHAVE, (cAliasTmp)->CODGRUP, (cAliasTmp)->CODBEM,;
								 (cAliasTmp)->ITEM, (cAliasTmp)->DTAQUIS , (cAliasTmp)->DESCBEM, (cAliasTmp)->PLAQUET,;
								 (cAliasTmp)->DTIDEPR, (cAliasTmp)->VALORIG, (cAliasTmp)->TAXA, (cAliasTmp)->DEPRBAL,;
								 (cAliasTmp)->DEPMES, (cAliasTmp)->DEPRACU, (cAliasTmp)->SALDO, (cAliasTmp)->DTBAIXA,;
								 (cAliasTmp)->OBSERV, (cAliasTmp)->GRUPO}) 
			nLinImp++
			dbSkip()
		End
			MsgInfo("Foram importados: " + cValToChar(nLinImp) + " registros de um total de: " + cValToChar(nLinInic) + " registros!", "Registros importados!")
	   
		  (cAliasTmp)->(DbCloseArea())

	EndIf
	
	oBrw:SetArray(aFieldsCTE)
	oBrw:bLine      := {|| {_oNo, oVerde, oVermelho,;
							aFieldsCTE[oBrw:nAT,04], aFieldsCTE[oBrw:nAT,05], aFieldsCTE[oBrw:nAT,06],	aFieldsCTE[oBrw:nAT,07],;
							aFieldsCTE[oBrw:nAT,08], aFieldsCTE[oBrw:nAT,09], aFieldsCTE[oBrw:nAT,10], aFieldsCTE[oBrw:nAT,11],;
							aFieldsCTE[oBrw:nAT,12], aFieldsCTE[oBrw:nAT,13], aFieldsCTE[oBrw:nAT,14], aFieldsCTE[oBrw:nAT,15],;
							aFieldsCTE[oBrw:nAT,16], aFieldsCTE[oBrw:nAT,17], aFieldsCTE[oBrw:nAT,18], aFieldsCTE[oBrw:nAT,19],;
							aFieldsCTE[oBrw:nAT,20] }}
					
	restArea(cArea)

Return




Static Function fGravar()
	************************************************************************************************************************
	*    Chamada para a geração dos titulos de baixa automatica.
	**
	***
	****

	If Empty(cDir)

		msgalert("Nenhum arquivo selecionado. Não é possível processar Baixa.","ATENÇÃO")

	ElseIf msgYesNo("Este processo realizará a baixa automática para todos os títulos selecionados. Deseja continuar?","PERGUNTA")

		fGeraBaixa()

	EndIf

Return()




Static Function fGeraBaixa()
	************************************************************************************************************************
	*    Função para gerar a baixa dos CTEs de acordo com as especificações do arquivo.
	**
	***
	****
	Local lRet
	Local lBaixa := .F.
	Local nC
	Local cLoteBxa := Soma1(GetMV("EN_LOTBXA"))
	Local cAcao

	ProcRegua(Len(aFieldsCTE))

	If Empty(aFieldsCTE)
		msginfo("Não é possível gerar baixa, pois, não existem CTE's selecionados","AVISO")
		Return(.F.)
	EndIf

//BEGIN TRANSACTION
//   1       2      3        4          5        6      7         8         9         10          11               12              13
//lMarca,oCorSit, oCor, DT6_FILDOC, cSerieCTE, cCTE, nVlPlan, DT6_SERIE, DT6_DOC, DT6_VALFAT, _nVlimpret, nVlPlan - DT6_VALFAT, DT6_NUM,
//    14         15         16          17          18           19          20        21       22
//DT6_DATEM, DT6_PREFIX, DT6_TIPO, DT6_CLIDEV, DT6_LOJDEV, DT6_XSTABX, DT6_XLOTBX, cStCteBx, cSTTitBx}

	For nC := 1 To Len(aFieldsCTE)

		If aFieldsCTE[nC,01]

			BEGIN TRANSACTION

				lBaixa := .T.

				//Condição para o  CTE já faturado, cujo saldo financeiro é igual ao valor da planilha
				If aFieldsCTE[nC,02] = oBandVerd .And. aFieldsCTE[nC,03] = oVerde
					cAcao := "1"

					//Condição para o CTE que não está faturado
				ElseIf aFieldsCTE[nC,03] = oAzul
					cAcao := "2"

					//Condição para o CTE que está faturado e o valor é diferente do valor da planilha
				ElseIf aFieldsCTE[nC,02] = oBandVerm .And. (aFieldsCTE[nC,03] = oLaranja .Or. aFieldsCTE[nC,03] = oVioleta)
					cAcao := "3"

				EndIf

				If MsAguarde( {||fAutoBXCTE(aFieldsCTE[nC,04], aFieldsCTE[nC,08], aFieldsCTE[nC,15], aFieldsCTE[nC,16], aFieldsCTE[nC,13], cNatureza, aFieldsCTE[nC,17],;
						aFieldsCTE[nC,18], aFieldsCTE[nC,14], aFieldsCTE[nC,09], aFieldsCTE[nC,07], aFieldsCTE[nC,10], cBanco,;
						cAgencia, cConta, cLoteBxa, cAcao, aFieldsCTE[nC,11], aFieldsCTE[nC,06])},;
						"Aguarde - ", "Processando Baixa Automatica para CTE: " + ALLTRIM(aFieldsCTE[nC,09]))

					DisarmTransaction()

					msgStop("Não foi possível realizar a baixa. Favor verificar log de erro.","ERRO")

					lRet := .F.

					Return(lRet)

				Else

					lRet := .T.

				EndIf

			END TRANSACTION

		EndIf

	Next(nC)

	If lRet

		PutMV("EN_LOTBXA", cLoteBxa)

		If RecLock("ZBH",.T.)
			Replace ZBH->ZBH_CHAVE  With cLoteBxa+"_"+UsrRetName(RetCodUsr())
			Replace ZBH->ZBH_NOME   With aFile[1,1] // C Nome do Arquivo
			Replace ZBH->ZBH_TAMANH With aFile[1,2] // N Tamanho
			Replace ZBH->ZBH_DATA   With aFile[1,3] // D Data
			Replace ZBH->ZBH_HORA   With aFile[1,4] // C Horas
			Replace ZBH->ZBH_ATRIB  With aFile[1,5] // C Atributo
			MsUnlock()
		EndIf

	EndIf

//

	If !lBaixa
		msgInfo("Não existem títulos aptos a Faturar.","AVISO")
		Return(.F.)
	EndIf

	If lRet

		fCriaLog(1)

		msgInfo("Lote "+cLoteBxa+" gerado com sucesso!", "AVISO")

		oDlg:End()

	EndIf

Return(lRet)



Static Function fAutoBXCTE(cFilDoc, cSerieCTE, cPrefix, cTipo, cNumTit, cNatur, cCliDev, cLojDev, dDataEmi, cNumCTE,;
		nValorPlan, nValorCTE, cBancoBx, cAgencBx, cContaBx, cLoteBxa, cAcao, nValImp, cCTEPlan)
	************************************************************************************************************************
	*    Executa a baixa dos títulos.
	**   cAcao = 1 (apenas faz a baixa do título)
	***  cAcao = 2 (cria o título no financeiro com o mesmo valor do CTE e baixa de acordo com a planilha)
	**** cAcao = 3 (Faz a baixa parcial do título de acordo com o valor da planilha)
	****
	****
	Local lRet
	Local nC
	Local aCabBx
	Local _nJur    := 0
	Local nValBx   := nValorPlan
	Local cNumGer  := GetMV("EN_NUMBXA")
	Local cNumBx   := cNumTit
	Local cHistBx  := "Baixa Automatica CTRC F"+cFilDoc+" "+cNumCTE+" L"+cLoteBxa
	Local cMsgBx   := ""
	Local cMsgTit  := "O Título foi vinculado ao lote "+cLoteBxa
	Local aAreaGrv := GetArea()

	lMsErroAuto := .F.

	//Condição para o CTE que não está faturado e o valor é igual ao da planilha
	If cAcao = "2"

		cNumBx  := Soma1(cNumGer)
		cPrefix := "FBA"
		cTipo   := "FT"

		aCabBx:={{"E1_PREFIXO" 	  ,cPrefix                    									,Nil},;
			{"E1_NUM"	  , cNumBx 				                     					,Nil},;
			{"E1_PARCELA" , "0A"                                  						,Nil},;
			{"E1_TIPO"	  , cTipo                                 						,Nil},;
			{"E1_XOPER"   , "05"                                  						,Nil},;
			{"E1_NATUREZ" , cNatur		                           						,Nil},;
			{"E1_CLIENTE" , cCliDev							         					,Nil},;
			{"E1_LOJA"	  , cLojDev							         					,Nil},;
			{"E1_EMISSAO" , dDataBase                             						,Nil},;
			{"E1_VENCTO"  , dDataBase                             						,Nil},;
			{"E1_HIST"	  , "Planilha CSV-CTRE: F"+cFilDoc+" "+cNumCTE+" L"+cLoteBxa	,Nil},;
			{"E1_VALOR"	  , nValorCTE								 					,Nil} }

		//Inclui Titulo SE1
		MSExecAuto({|x,y| Fina040(x,y)},aCabBx,3)

		If lMsErroAuto

			MostraErro()

		Else

			PutMV("EN_NUMBXA",cNumBx)

			//Cria um RA com o valor pago a maior na planilha
			If nValorCTE < nValorPlan
				cNumGer  := GetMV("EN_NUMBXA")

				aCabBx :={{"E1_PREFIXO" ,"RAF"                                  					,Nil},;
					{"E1_NUM"	   , cNumBx 				                   					,Nil},;
					{"E1_PARCELA" , "0A"                                  					,Nil},;
					{"E1_TIPO"	   , "RA"                                 					,Nil},;
					{"E1_XOPER"   , "08"                                  					,Nil},;
					{"E1_NATUREZ" , "11303"		                         					,Nil},;
					{"E1_CLIENTE" , cCliDev							          					,Nil},;
					{"E1_LOJA"	   , cLojDev							          					,Nil},;
					{"E1_EMISSAO" , dDataBase                             					,Nil},;
					{"E1_VENCTO"  , dDataBase                             					,Nil},;
					{"E1_VENCREA" , dDataBase                             					,Nil},;
					{"E1_VALOR"	, nValorPlan - nValorCTE					 					,Nil},;
					{"E1_HIST"	   , "RA CSV-CTRE: F"+cFilDoc+" "+cNumCTE 					,Nil},;
					{"cBancoAdt"  , cBancoBx                                            ,Nil},;
					{"cAgenciaAdt", cAgencBx                                            ,Nil},;
					{"cNumCon"    , cContaBx                                            ,Nil}}
				//Inclui Titulo SE1
				MSExecAuto({|x,y| Fina040(x,y)},aCabBx,3)

				nValBx  := nValorCTE

				If lMsErroAuto
					MostraErro()
				Else
					PutMV("EN_NUMBXA",cNumBx)
					cMsgTit := "O Titulo gerou o RA RAF"+cNumBx
				EndIf


			Else

				nValBx  := nValorPlan
				cHistBx := "Baixa Automatica CTRC F"+cFilDoc+" "+cNumCTE+" L"+cLoteBxa

			EndIf

		EndIf

	ElseIf cAcao = "3"

		nValBx  := nValorPlan
		cHistBx := "Baixa Automatica Parcial CTRC F"+cFilDoc+" "+cNumCTE+" L"+cLoteBxa

	EndIf

	//Sempre o programa vai passar por essa condição baixando o título
	If !lMsErroAuto

		If cTipo = "CTR"

			aCabBx := {{"E1_PREFIXO"  ,cPrefix							,Nil},;
				{"E1_NUM"	  ,cNumBx							,Nil},;
				{"E1_TIPO"	  ,cTipo							,Nil},;
				{"AUTBANCO"	  ,cBancoBx							,Nil},;
				{"AUTAGENCIA"  ,cAgencBx							,Nil},;
				{"AUTCONTA"	  ,cContaBx							,Nil},;
				{"AUTMOTBX"	  ,"NOR"							,Nil},;
				{"AUTDTBAIXA"  ,dDataBase						,Nil},;
				{"AUTDTCREDITO",dDataBase						,Nil},;
				{"AUTHIST"	  ,cHistBx							,Nil},;
				{"AUTVALREC"	  ,nValBx							,Nil},;
				{"AUTDECRESC"  ,_nJur							,Nil},;
				{"AUTACRESC"   ,_nJur							,Nil},;
				{"AUTMULTA"    ,_nJur							,Nil},;
				{"AUTJUROS"    ,_nJur							,Nil,.T.}}
		Else
			aCabBx := {{"E1_PREFIXO"   ,cPrefix							,Nil},;
				{"E1_NUM"	   ,cNumBx							,Nil},;
				{"E1_PARCELA"   ,"0A"		                    ,Nil},;
				{"E1_TIPO"	   ,cTipo							,Nil},;
				{"AUTBANCO"	   ,cBancoBx						,Nil},;
				{"AUTAGENCIA"   ,cAgencBx						,Nil},;
				{"AUTCONTA"	   ,cContaBx						,Nil},;
				{"AUTMOTBX"	   ,"NOR"							,Nil},;
				{"AUTDTBAIXA"   ,dDataBase						,Nil},;
				{"AUTDTCREDITO" ,dDataBase						,Nil},;
				{"AUTHIST"	   ,cHistBx							,Nil},;
				{"AUTVALREC"	   ,nValBx							,Nil},;
				{"AUTDECRESC"   ,_nJur							,Nil},;
				{"AUTACRESC"    ,_nJur							,Nil},;
				{"AUTMULTA"     ,_nJur							,Nil},;
				{"AUTJUROS"     ,_nJur							,Nil,.T.}}
		EndIf

		//Baixa Titulo
		MSExecAuto({|x,y| fina070(x,y)},aCabBx,3)

	EndIf

	If lMsErroAuto

		cHistBx := "Erro ao gerar a baixa automática para o titulo"

		cMsgTit := "Erro ao gerar a baixa automática para o titulo"

		mostraerro()

	Else

		If !fGravaDT6(cFilDoc, cNumCTE, cSerieCTE, cNumBx, cPrefix, cTipo, cLoteBxa, cAcao)

			msginfo("Inserir algo nesse ponto para informar no arquivo de log que não houve a vinculação do título ao CTE")

			cMsgTit := "Não foi possível vincular o lote "+cLoteBxa+" ao título "+cNumBx

		Endif

	EndIf

//Baixa, Fildoc, DocPlanilha, CTE, Titulo, Valor Planilha, Cli/Loja, Valor Fatura, Status Baixa, Status Titulo, Valor Imposto	
	Aadd(aLogBx, {"OK", cFilDoc, cCTEPlan, cNumCTE, cNumBx, nValorPlan, cCliDev+"/"+cLojDev, nValBx, cHistBx, cMsgTit, nValImp})

	RestArea(aAreaGrv)

Return(lMsErroAuto)




Static Function fGravaDT6(cFilCTE, cDocCTE, cSerCTE, cNumBx, cPrefix, cTipo, cLotBxa, cAcao)
	************************************************************************************************************************
	*    Função para gravar as informações de geração da baixa no CTE.
	**
	***
	****
	Local lRet := .T.
	Local aAreaCTE := GetArea()

	dbSelectArea("DT6")
	dbSetOrder(1)

	If dbSeek(xFilial("DT6")+cFilCTE+cDocCTE+cSerCTE)

		If cAcao = "C"

			If RecLock("DT6",.F.)
				DT6->DT6_PREFIX := ""
				DT6->DT6_NUM    := ""
				DT6->DT6_TIPO   := ""
				DT6->DT6_XSTABX := "C"
				DT6->DT6_XLOTBX := ""
				DT6->DT6_XDTBXA := STOD("")
				DT6->DT6_BAIXA  := STOD("")
				DT6->DT6_XDTCAN := dDataBase

				MsUnLock()

			Else

				msgAlert("Não foi possivel localizar o CTE para relacionar a baixa automatica. Favor entrar em contato com o T.I.","ATENÇÃO")

				lRet := .F.

			EndIf

		ElseIf cAcao = "2"

			If RecLock("DT6",.F.)
				DT6->DT6_PREFIX := cPrefix
				DT6->DT6_NUM    := cNumBx
				DT6->DT6_TIPO   := cTipo
				DT6->DT6_XSTABX := "T"
				DT6->DT6_XLOTBX := cLotBxa
				DT6->DT6_XDTBXA := dDataBase
				DT6->DT6_BAIXA  := dDataBase
				DT6->DT6_XDTCAN := STOD("")

				MsUnLock()

			Else

				msgAlert("Não foi possivel localizar o CTE para relacionar a baixa automatica. Favor entrar em contato com o T.I.","ATENÇÃO")

				lRet := .F.

			EndIf

		Else

			If RecLock("DT6",.F.)
				DT6->DT6_XSTABX := "T"
				DT6->DT6_XLOTBX := cLotBxa
				DT6->DT6_XDTBXA := dDataBase
				DT6->DT6_BAIXA  := dDataBase
				DT6->DT6_XDTCAN := STOD("")

				MsUnLock()

			Else

				msgAlert("Não foi possivel localizar o CTE para relacionar a baixa automatica. Favor entrar em contato com o T.I.","ATENÇÃO")

				lRet := .F.

			EndIf

		EndIf

	EndIf

	RestArea(aAreaCTE)

Return(lRet)



Static Function fLimpaBrw()
	************************************************************************************************************************
	*    Função para montar a tela com os lançamentos que compõem um determinado lote e serão excluidos.
	**
	***
	****
	Local cTitulo := ""
	Local oDlg1, oGrpLote, oBrw1, oDlgL, oGroupLot, oSayLote, oGetLote
	Local oBtnFec, oBtnConf, oBtnCLot
	Local oCorTit, oCorBx
	Local cQryExc
	Local lChave := .T.

	Local aHeader := {"St.Tit","St.Bx","Fil.Doc","Num.CTE","Serie","Valor","Cliente","Documento","Prefixo","Tipo"}
	Local aFields := {}
	Local cLoteCan := Space(7)

//If CONPAD1(,,,"ZBH","ZBH_CHAVE",,.F.)   // Recebe .T. ou .F. se a consulta padrão foi bem sucedida.

	oDlgL := TDialog():New(10,90,230,400,"Digite o Numero do Lote",,,,,,,,,.T.,,,,,)
	oDlgL:lCentered := .T.

	oGroupLot := TGroup():New(005,005,080,150,"",oDlgL,,,.T.,)

	oSayLote := TSay():New(017,015,{||"Lote    "},oDlgL,,,.F.,,,.T.,,,40,09)

	oGetLote := TGet():New(015,045,bSetGet(cLoteCan),OdlgL,040,11,"@!",{|| fValids("LT",cLoteCan)},,,,,,.T.,,,{|| .T.},,,,,,,,,,,)

	oBtnCLot := TButton():New(090,097,"Confirmar" ,oDlgL,{|| (oDlgL:End()) },40,12,,,.T.,.T.,,"Confirmar" ,,,,)

	oDlgL:Activate()

	cTitulo := "Lançamentos que compoem o Lote '"+cLoteCan+"' "

	cQryExc := " SELECT	DT6_FILDOC,DT6_DOC, DT6_SERIE, DT6_VALFAT, A1_CGC+' - '+A1_NOME AS CLIENTE, E1_NUM, E1_PREFIXO, E1_TIPO, E1_ORIGEM, "
	cQryExc += " 		E1_HIST, E1_LA, E1_SALDO, E1_VALOR, E5_BANCO, E5_AGENCIA, E5_CONTA, E5_VALOR, E5_LA, E5_LOTE, E5_RECONC, E5_DATA, "
	cQryExc += " 		SE1.R_E_C_N_O_ AS SE1REC, SE5.R_E_C_N_O_ AS SE5REC "
	cQryExc += " FROM "+RetSQLName("DT6")+" DT6(NOLOCK) "
	cQryExc += " INNER JOIN "+RetSQLName("SA1")+" SA1(NOLOCK) ON "
	cQryExc += " 		A1_COD = DT6_CLIDEV AND A1_LOJA = DT6_LOJDEV AND SA1.D_E_L_E_T_ = '' "
	cQryExc += " INNER JOIN "+RetSQLName("SE1")+" SE1(NOLOCK) ON "
	cQryExc += " 		E1_NUM = DT6_NUM AND E1_PREFIXO = DT6_PREFIX AND E1_TIPO = DT6_TIPO  "
	cQryExc += " 	AND E1_CLIENTE = DT6_CLIDEV AND E1_LOJA = DT6_LOJDEV AND SE1.D_E_L_E_T_ = '' "
	cQryExc += " LEFT JOIN "+RetSQLName("SE5")+" SE5(NOLOCK) ON "
	cQryExc += " 		E5_NUMERO = E1_NUM	AND E5_PREFIXO = E1_PREFIXO	AND E5_TIPO = E1_TIPO "
	cQryExc += " 	AND E5_CLIFOR = E1_CLIENTE AND E5_LOJA = E1_LOJA AND SE5.D_E_L_E_T_ = '' "
	cQryExc += " WHERE DT6.D_E_L_E_T_ = ' '  "
//	cQryExc += " 	AND DT6_XLOTBX = '"+SUBSTRING(ZBH->ZBH_CHAVE,1,7)+"' "
	cQryExc += " 	AND DT6_XLOTBX = '"+cLoteCan+"' "
	cQryExc += " ORDER BY DT6_PREFIX, DT6_NUM, DT6_TIPO "

	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQryExc), 'LOTEEXC', .F., .F.)

	dbSelectArea("LOTEEXC")
	LOTEEXC->(dbGoTop())

	If LOTEEXC->(Eof())

		Aadd(aFields,{Space(2),Space(2),"","","","","","","","",""})

		LOTEEXC->(DbCloseArea())

	Else

		aFields := {}

		While LOTEEXC->(!Eof())

			If LOTEEXC->E5_LA = 'S' .Or. LOTEEXC->E5_RECONC = 'x'
				oCorBx := oBandVerm
				lChave := .F.
			Else
				oCorBx := oBandVerd
			EndIf

			If LOTEEXC->E1_LA = 'S' .And. LOTEEXC->E1_PREFIXO = 'FBA' .And. LOTEEXC->E1_TIPO = 'FT'
				oCorTit := oVermelho
				lChave := .F.
			Else
				oCorTit := oVerde
			EndIf

			Aadd(aFields,{ oCorTit, oCorBx, LOTEEXC->DT6_FILDOC, LOTEEXC->DT6_DOC, LOTEEXC->DT6_SERIE, LOTEEXC->DT6_VALFAT,;
				LOTEEXC->CLIENTE, LOTEEXC->E1_NUM, LOTEEXC->E1_PREFIXO, LOTEEXC->E1_TIPO, LOTEEXC->E1_ORIGEM,;
				LOTEEXC->E5_DATA, LOTEEXC->E5_BANCO, LOTEEXC->E5_AGENCIA, LOTEEXC->E5_CONTA, LOTEEXC->SE1REC,;
				LOTEEXC->SE5REC, LOTEEXC->E5_VALOR})

			dbSkip()

		End

		LOTEEXC->(DbCloseArea())

	EndIf

//Else

//	Return()

//EndIf

	oDlg1 := TDialog():New(010,10,555,990,cTitulo,,,,,,,,,.T.,,,,,)
	oDlg1:lCentered := .T.

	oGrpLote := TGroup():New(005,005,245,485,"Documentos",oDlg1,,,.T.)

	oBrw1 := TWBrowse():New(015,010,470,225,,aHeader,,oDlg1,,,,,,,,,,,,.F.,,.T.,,.F.)
	oBrw1:SetArray(aFields)
	oBrw1:bLine   := {|| {aFields[oBrw1:nAT,01], aFields[oBrw1:nAT,02], aFields[oBrw1:nAT,03], ;
		aFields[oBrw1:nAT,04], aFields[oBrw1:nAT,05], aFields[oBrw1:nAT,06], ;
		aFields[oBrw1:nAT,07], aFields[oBrw1:nAT,08], aFields[oBrw1:nAT,09], ;
		aFields[oBrw1:nAT,10] }}

	oBtnLegCan:= TButton():New(253,010,"Legenda"         ,oDlg1, {|| fLegendaCan()            },40,12,,,.T.,.T.,,"Legenda"            ,,,,)
	oBtnConf  := TButton():New(253,390,"Confirmar"       ,oDlg1, {|| Processa( {||fConfCan(lChave, aFields, cLoteCan)},"Aguarde", "Processando...",.F.), oDlg1:End() },40,12,,,.T.,.T.,,"Confirmar Exclusão" ,,,,)
	oBtnFec   := TButton():New(253,440,"Fechar"          ,oDlg1, {|| oDlg1:End()              },40,12,,,.T.,.T.,,"Fechar tela"        ,,,,)

	oDlg1:Activate()

Return(.T.)




Static Function fConfCan(lChave, aFields, cChave)
	************************************************************************************************************************
	*    Função para gerar o cancelamento do Lote conforme seleção
	**
	***
	****

	Local nCan := 0
	Local aAreaFin := GetArea()
	Local aCabCan := {}
	Local cPrefixo, cTipo, cCliente, cOrigem, cNum, cSeqSE1, cSeqSE5, cUpdate
	Local lEntra := .T.
	lMsErroAuto := .F.

	ProcRegua(Len(aFields))

	If !lChave
		msginfo("Não é possível excluir o Lote, pois, alguns lançamentos possuem restrições.","AVISO!")
		Return()

	Else
//			Aadd(aFields,{ oCorTit, oCorBx, LOTEEXC->DT6_FILDOC, LOTEEXC->DT6_DOC, LOTEEXC->DT6_SERIE, LOTEEXC->DT6_VALFAT,;
//								LOTEEXC->CLIENTE, LOTEEXC->E1_NUM, LOTEEXC->E1_PREFIXO, LOTEEXC->E1_TIPO, LOTEEXC->E1_ORIGEM,;
//								LOTEEXC->E5_DATA, LOTEEXC->E5_BANCO, LOTEEXC->E5_AGENCIA, LOTEEXC->E5_CONTA, LOTEEXC->SE1REC, LOTEEXC->SE5REC}) 
		cPrefixo := aFields[01,09]
		cTipo 	 := aFields[01,10]
		cNum     := aFields[01,08]
		cCliente := aFields[01,07]
		cOrigem  := aFields[01,11]
		cSeqSE1  := aFields[01,16]
		cSeqSE5  := aFields[01,17]

		BEGIN TRANSACTION

			For nCan := 1 To Len(aFields)

				IncProc("Excluindo Lote. Aguarde "+CVALTOCHAR(nCan))

				If nCan = 1 .Or. cNum != aFields[nCan,08]
					#IFDEF TOP

						cUpdate := " UPDATE "+RetSqlName("SE5")+" SET D_E_L_E_T_ = '*' "
						cUpdate += " WHERE D_E_L_E_T_ = '' AND E5_MOTBX = 'NOR' "

						If cTipo != "CTR"
							cUpdate += " AND E5_PARCELA = '0A' "
						EndIf

						cUpdate += "   AND R_E_C_N_O_ IN ("+CVALTOCHAR(aFields[nCan,17])+") "

						tcSQLExec(cUpdate)

					#ENDIF

					If cPrefixo = 'FBA' .And. cTipo = 'FT'
						#IFDEF TOP
							cUpdate := " UPDATE "+RetSqlName("SE1")+" SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ "
							cUpdate += " WHERE D_E_L_E_T_ = '' "
							cUpdate += "   AND R_E_C_N_O_ IN ("+CVALTOCHAR(aFields[nCan,16])+") "

							tcSQLExec(cUpdate)
						#ENDIF

					Else //If AllTrim(cOrigem) $ ("TMSA491|TMSA850")
						#IFDEF TOP
							cUpdate := " UPDATE "+RetSqlName("SE1")+" SET E1_SALDO = E1_SALDO + " + CVALTOCHAR(aFields[01,18]) + ", E1_BAIXA = '' "
							cUpdate += " WHERE D_E_L_E_T_ = '' "
							cUpdate += "   AND R_E_C_N_O_ IN ("+CVALTOCHAR(aFields[nCan,16])+") "

							tcSQLExec(cUpdate)
						#ENDIF

					EndIf

					cPrefixo := aFields[nCan,09]
					cTipo 	 := aFields[nCan,10]
					cNum     := aFields[nCan,08]
					cCliente := aFields[nCan,07]
					cOrigem  := aFields[nCan,11]
					cSeqSE1  := aFields[nCan,16]
					cSeqSE5  := aFields[nCan,17]
					lEntra 	 := .F.

				EndIf

				If nCan > 1 .And. lEntra
					cSeqSE5 += ','+aFields[nCan,17]
				EndIf

				lEntra := .T.

				If !fGravaDT6(aFields[nCan,03], aFields[nCan,04], aFields[nCan,05], "", "", "", "", "C")
					msginfo("Não foi possível desvincular o lote. Favor entrar em contato com o T.I.", "AVISO")
					DisarmTransaction()
					Return()
				EndIf

			Next(nCan)

			RestArea(aAreaFin)

			dbSelectArea("ZBH")
			dbSetOrder(1)

			If dbSeek(xFilial("ZBH")+cChave)
				If RecLock("ZBH",.F.)

					Replace ZBH->ZBH_ATRIB  With "C"
					dbDelete()
					MsUnlock()

				EndIf
			EndIf

		END TRANSACTION

		msgInfo("Exclusão de Lote realizada com sucesso.", "AVISO")

	EndIf

Return()



Static Function fCriaLog(nOpcLog)
	************************************************************************************************************************
	*    Função para gerar arquivo de Log.
	**
	***
	****

	Local cDirLog
	Local cArquivo
	Local aCabLog
	Local aCabArq
	Local cHoras := time()
	Local nHandle
	Local cCrLf
	Local nx := 0

	cDirLog := "C:\Temp\log"

	If nOpcLog = 1
		cArquivo:=DTOS(dDatabase)+SUBSTR(cHoras,1,2)+ SUBSTR(cHoras,4,2)+SUBSTR(cCNPJ,1,8)+"_baixa"
	Else
		cArquivo:=DTOS(dDatabase)+SUBSTR(cHoras,1,2)+ SUBSTR(cHoras,4,2)+SUBSTR(cCNPJ,1,8)
	EndIf

	nHandle := MsfCreate(cDirLog+"\"+cArquivo+".CSV",0)

	cCrLf   := chr(13) + chr(10)

	aCabArq := {}

	aCabLog := {}

	AADD(aCabLog, {"OK"       ,	"C",01,0})
	AADD(aCabLog, {"FILDOC"   ,	"C",02,0})
	AADD(aCabLog, {"DOC PLAN" ,	"C",09,0})
	AADD(aCabLog, {"CTE"      ,	"C",09,0})
	AADD(aCabLog, {"TITULO"   ,	"C",13,0})
	AADD(aCabLog, {"VALOR"    ,	"N",14,2})
	AADD(aCabLog, {"CLIENTE"  ,	"C",16,0})
	AADD(aCabLog, {"VALFAT"   ,	"N",14,2})
	AADD(aCabLog, {"S. BX"    ,	"C",28,0})
	AADD(aCabLog, {"S. TIT"   ,	"C",01,0})
	AADD(aCabLog, {"VALIMP"   ,	"N",14,2})

	If nHandle >0

		IncProc( "Aguarde! Gerando arquivo de LOG em Excel...")

		aEval(aCabLog, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aCabLog), ";", "") ) } )
		fWrite(nHandle, cCrLf ) // Pula linha

		If nOpcLog = 1

			For nX := 1 to Len(aLogBx)

				fWrite(nHandle, aLogBx[nX,01]                                + ";" ) // BAIXA
				fWrite(nHandle, aLogBx[nX,02]                                + ";" ) // FILIAL DOC
				fWrite(nHandle, aLogBx[nX,03]                                + ";" ) // DOC PLANILHA
				fWrite(nHandle, aLogBx[nX,04]                                + ";" ) // CTR
				fWrite(nHandle, aLogBx[nX,05]                                + ";" ) // titulo
				fWrite(nHandle, Transform(aLogBx[nX,06], "@E 9,999,999.99" ) + ";" ) // VLO.PLAN
				fWrite(nHandle, aLogBx[nX,07]                                + ";" ) // CLIENTE/LOJA
				fWrite(nHandle, Transform(aLogBx[nX,08], "@E 9,999,999.99" ) + ";" ) // VLO.FATURA
				fWrite(nHandle, aLogBx[nX,09]                                + ";" ) // STATUS BAIXA
				fWrite(nHandle, aLogBx[nX,10]                                + ";" ) // STATUS TITULO
				fWrite(nHandle, Transform(aLogBx[nX,11], "@E 9,999,999.99" ) + ";" ) // valor imposto
				fWrite(nHandle, cCrLf ) // Pula linha

			Next

		Else

			For nX := 1 to Len(aFieldsCTE)

				fWrite(nHandle, Iif(aFieldsCTE[nX,01]==.T.,"X"," ") + ";" )              // BAIXA
				fWrite(nHandle, aFieldsCTE[nX,04] + ";" )                                // FILIAL DOC
				fWrite(nHandle, aFieldsCTE[nX,06] + ";" )                                // DOC PLANILHA
				fWrite(nHandle, aFieldsCTE[nX,09] + ";" )                                // CTR
				fWrite(nHandle, aFieldsCTE[nX,13] + ";" )                                // titulo
				fWrite(nHandle, Transform(aFieldsCTE[nX,07], "@E 9,999,999.99" )	+ ";" ) // VLO.PLAN
				fWrite(nHandle, aFieldsCTE[nX,17] + aFieldsCTE[nX,18] + ";" )            // CLIENTE/LOJA
				fWrite(nHandle, Transform(aFieldsCTE[nX,10], "@E 9,999,999.99" ) + ";" ) // VLO.FATURA
				fWrite(nHandle, aFieldsCTE[nX,21] + ";" )                                // STATUS BAIXA
				fWrite(nHandle, aFieldsCTE[nX,22] + ";" )                                // STATUS TITULO
				fWrite(nHandle, Transform(aFieldsCTE[nX,11], "@E 9,999,999.99" ) + ";" ) // valor imposto
				fWrite(nHandle, cCrLf ) // Pula linha

			Next

		EndIf

		fClose(nHandle)

		If ! ApOleClient( 'MsExcel' )
			MsgAlert( "MsExcel nao instalado!!" )
			Return
		EndIf

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cDirLog+"\"+cArquivo+".CSV" ) // Abre uma planilha
		oExcelApp:SetVisible(.T.)

	Else

		MsgAlert("Falha na criação do arquivo!!" )
		Return

	Endif

Return()



Static Function Str2Val(x) // --> N
	************************************************************************************************************************
	*    Converte String Para Valor Numerico.
	**
	***
	****

	If at(".",x) < at(",",x)
		x:=StrTran(x,".","")
		x:=StrTran(x,",",".")
	Else
		x:=StrTran(x,",","")
	Endif

Return(Val(x))



Static Function fLegendaCTE()
	****************************************************************************************************************************
	*    Função para montar a legenda.
	**
	***
	****

	Private cCadLegen := "Legenda Browse"

	Private aCores2 := {{         ,"      ====  STATUS DE IMPORTACAO   ====     " },;
		{ "BR_VERDE"			  ,"Importado com Sucesso"              },;
		{                         ,"__________________________________" },;
		{                         ,"      ==== STATUS DE PROCESSAMENTO ====     " },;
		{ "BR_VERMELHO"           ,"Nao Processado"                     },; 
		{ "BR_VERDE"              ,"Processado"                         }}  


	BrwLegenda(cCadLegen,"Situação dos CTE's",aCores2)

Return(.T.)



Static Function fLegendaCan()
	****************************************************************************************************************************
	*    Função para montar a legenda de cancelamento.
	**
	***
	****

	Private cLegenCan := "Legenda Cancelamento Lote"

	Private aCoresCan := {{       ,"== SITUAÇÃO INCLUSÃO TITULO =="      },;
		{ "BR_VERDE"              ,"Inclusão de Título não contabilizada"},;
		{ "BR_VERMELHO"           ,"Inclusão de Título contabilizada"    },;
		{                         ,"__________________________________"  },;
		{                         ,"== SITUAÇÃO BAIXA TITULO =="         },;
		{ "IC_TOOLBARSTATUS_GREEN","Baixa de Título não contabilizada"   },;
		{ "IC_TOOLBARSTATUS_RED"  ,"Baixa de Título contabilizada"       }}


	BrwLegenda(cLegenCan,"Situação dos Títulos",aCoresCan)

Return(.T.)


Static Function fValids(cTipo, cLote)
	****************************************************************************************************************************
	*    Função para validar a digitação do lote no cancelamento e visualização
	**
	***
	****
	Local lRet := .T.

	dbSelectArea("ZBH")
	dbSetOrder(1)

	If dbSeek(xFilial("ZBH")+cLote,.T.)
		lRet := .T.
	Else
		msginfo("Lote não encontrado.","ATENÇÃO")
		lRet := .F.
	EndIf

Return(lRet)

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
