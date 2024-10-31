#include "protheus.ch"
/*{Protheus.doc} UPD4FIN
	upddistr - central 4fin
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
User Function UPD4FIN()
	MsApp():New( "SIGAFIN" )

	oApp:cInternet  := nil
	__cInterNet := nil
	__lPYME := .F.
	Set Dele On

	oApp:bMainInit  := { || ( oApp:lFlat := .F. , WizardSeq() , FnQuit(oApp) ) }
	oApp:CreateEnv()
	OpenSM0()

	PtSetTheme( "TEMAP10" )
	SetFunName( "UPD4FIN" )
	oApp:lMessageBar := .T.

	oApp:Activate()
return
/*{Protheus.doc} UPD4FIN
	upddistr - central 4fin
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
static function WizardSeq()
	local oWizard   as object
	local aBrowse   := {}
	local cMsg      as character

	if FindFunction( "MPDicInDB" ) .and. ! MPDicInDB()
		cMsg := "Este update NÃO PODE ser executado neste Ambiente." + CRLF + CRLF + ;
				"Os arquivos de dicionários NÃO se encontram no Banco de Dados e este update está preparado " + ;
				"para atualizar apenas ambientes com dicionários no banco."
		MsgInfo( cMsg )
		return
	endif

	oWizard := FwWizardControl():New()
	oWizard:ActiveUISteps()

	//----------------------------
	// Pagina 1 - Apresentação
	//----------------------------
	o1stPage := oWizard:AddStep("1STSTEP",{|Panel| cria_pn1(Panel)})
	o1stPage:SetStepDescription("Apresentação")
	o1stPage:SetNextTitle("Avançar")
	o1stPage:SetNextAction({||.T.})
	o1stPage:SetCancelAction({||.T.})

	//---------------------------------------
	// Pagina 2 - Escolha do grupo de empresas
	//---------------------------------------
	o2ndPage := oWizard:AddStep("2NDSTEP", {|Panel|cria_pn2(Panel,@aBrowse)})
	o2ndPage:SetStepDescription("Grupo de empresa")
	o2ndPage:SetNextTitle("Avançar")
	o2ndPage:SetPrevTitle("Retornar")
	o2ndPage:SetNextAction({|| .T.})
	o2ndPage:SetPrevWhen({|| .F. })
	o2ndPage:SetCancelAction({|| .T.})

	//---------------------------------------
	// Pagina 3 - Parametros
	//---------------------------------------
	o2ndPage := oWizard:AddStep("3RDSTEP", {|Panel|cria_pn3(Panel,aSx6)})
	o2ndPage:SetStepDescription("Parametros")
	o2ndPage:SetNextTitle("Avançar")
	o2ndPage:SetPrevTitle("Retornar")
	o2ndPage:SetNextAction({|| .T.})
	o2ndPage:SetPrevWhen({|| .F. })
	o2ndPage:SetCancelAction({|| .T.})

	//----------------------------
	// Pagina 4 - Aviso do backup
	//----------------------------
	o3rdPage := oWizard:AddStep("4THSTEP", {|Panel|cria_pn4(Panel,aBrowse)})
	o3rdPage:SetStepDescription("Avisos")
	o3rdPage:SetNextTitle("Concluir")
	o3rdPage:SetPrevTitle("Retornar")
	o3rdPage:SetNextAction({|| ExecFix(aBrowse) })
	o3rdPage:SetPrevAction({|| .T.})
	o3rdPage:SetCancelAction({|| .T.})

	oWizard:Activate()
	oWizard:Destroy()
Return
/*{Protheus.doc} UPD4FIN
	upddistr - pagina 1
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
Static Function cria_pn1(oPanel As Object)
	Local oFont := TFont():New( ,, -25, .T., .T.,,,,, )
	Local oFont2 := TFont():New("Arial",,-15,,.F.,,,,,,.F.,.F.)

	TSay():New(010,015, {|| "4FIN - UPDDISTR" }, oPanel,,oFont ,,,,.T.,CLR_BLUE, )
	TSay():New(045,015, {|| "Esta rotina tem como funcao fazer a atualizacao dos dicionarios do Protheus"}, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	TSay():New(060,015, {|| "Este processo deve ser executado em modo EXCLUSIVO, ou seja nao podem haver"}, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	TSay():New(075,015, {|| "outros usuarios ou jobs utilizando o sistema. E EXTREMAMENTE recomendavel" }, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	TSay():New(090,015, {|| "que se faca um BACKUP dos DICIONARIOS e da BASE DE DADOS antes desta" }, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	TSay():New(105,015, {|| "atualizacao, para que caso ocorram eventuais falhas, esse backup possa ser" }, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	TSay():New(120,015, {|| "restaurado." }, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
Return
/*{Protheus.doc} UPD4FIN
	upddistr - pagina 2
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
Static Function cria_pn2(oPanel,aBrowse)
	Local oMrkBrowse
	Local nX := 0
	Local oOk           := LoadBitMap(GetResources(), "LBOK")
	Local oNo           := LoadBitMap(GetResources(), "LBNO")

	aGrupo := FWAllGrpCompany()

	For nX := 1 to len(aGrupo)
		Aadd(aBrowse,{.F.,aGrupo[nX],FWGrpName(aGrupo[nX])})
	Next nX

	oMrkBrowse := TWBrowse():New( 010 , 010 , (oPanel:nClientWidth/2 - 020) , oPanel:nClientHeight/2 - 020  ,,,,oPanel,,,,,{|| IIF(!Empty(aBrowse[oMrkBrowse:nAt][2]), aBrowse[oMrkBrowse:nAt][1] := !aBrowse[oMrkBrowse:nAt][1] , '') , oMrkBrowse:Refresh() },,,,,,,.F.,,.T.,,.F.,,, )
	oMrkBrowse:SetArray(aBrowse)

	oMrkBrowse:AddColumn(TCColumn():New(""			, {|| Iif(aBrowse[oMrkBrowse:nAt][1],oOK,oNO)}  ,,,,'CENTER'    ,20,.T.,.F.,,,,.F.,))
	oMrkBrowse:AddColumn(TCColumn():New("EMPRESA"	, {|| aBrowse[oMrkBrowse:nAt][2] } ,,,,'LEFT'      ,40,.F.,.F.,,,,.F.,))
	oMrkBrowse:AddColumn(TCColumn():New("DESCRIÇÃO"	, {|| aBrowse[oMrkBrowse:nAt][3] }   ,,,,'LEFT'      ,70,.F.,.F.,,,,.F.,))

Return
/*{Protheus.doc} UPD4FIN
	upddistr - pagina 3
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
//--------------------------------------------------------------------
/*/{Protheus.doc} bGetPar2
Parametrizacao Solver

@author Ivan Caproni
@since  16/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function bGetPar2()
	local oSButton1
	local oSButton2
	local oParams
	local oDlg
	local aRet := {}
	local nOpc := 0
	local nI
	local aParams := {}

	aAdd(aParams,{'4F_TABOCOR','Caracter','[4Fin] Tabela que sera utilizada no cadastro de ocorrencias',Space(250)} )

	DEFINE MSDIALOG oDlg TITLE "Parametrização Protheus x Central 4Fin" FROM 000, 000  TO 500, 1200 COLORS 0, 16777215 PIXEL

		@ 000, 000 LISTBOX oParams Fields HEADER "Parametro","Tipo","Descricao","Conteudo" SIZE 300, 227 OF oDlg PIXEL ColSizes 50,50
		oParams:setArray(aParams)
		oParams:bLine := {|| {	aParams[oParams:nAt,1],;
								aParams[oParams:nAt,2],;
								aParams[oParams:nAt,3],;
								aParams[oParams:nAt,4]}}
		oParams:bLDblClick := {|| lEditCell(@aParams,oParams,,4),oParams:DrawSelect() }
		oParams:align := CONTROL_ALIGN_TOP

		DEFINE SBUTTON oSButton1 FROM 232, 100 TYPE 01 OF oDlg ENABLE ACTION (nOpc := 1,oDlg:End())
		DEFINE SBUTTON oSButton2 FROM 232, 165 TYPE 02 OF oDlg ENABLE ACTION oDlg:End()

	ACTIVATE MSDIALOG oDlg CENTERED VALID bValForm(aParams)

	If nOpc == 1
		aRet := aClone(aParams)
	EndIf
Return aRet
//--------------------------------------------------------------------
/*/{Protheus.doc} bValForm
Valida a dialog com os parametros

@author Ivan Caproni
@since  16/02/2021
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function bValForm(aParams)
	Local nI as numeric
	For nI := 1 To Len(aParams)
		If Empty(aParams[nI,4])
			MsgAlert("Preencha o conteudo de todos os parametros")
			Return .F.
		EndIf
	Next nI
Return MsgYesNo("Confirma os parametros informados?")
/*{Protheus.doc} UPD4FIN
	upddistr - pagina 4
	@type	 function
	@author	 ivan.caproni
	@since	 02/09/2024
	@version 1.0
*/
Static Function cria_pn3(oPanel As Object, aBrowse As Array)
	Local oSay0 AS Object
	Local oSay1 AS Object
	Local oFont AS Object
	Local oFont2 AS Object

	oFont := TFont():New( ,, -25, .T., .T.,,,,, )
	oFont2 := TFont():New("Arial",,-15,,.F.,,,,,,.F.,.F.)
	oSay0 := TSay():New(010,015, {|| "Verificação do ambiente" }, oPanel,,oFont ,,,,.T.,CLR_BLUE, )
	oSay1 := TSay():New(045,015, {|| "Execute o processo em modo exclusivo"}, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	oSay1 := TSay():New(060,015, {|| "Execute este DISTR em uma base de homologação para validar os ajustes"}, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
	oSay1 := TSay():New(075,015, {|| "Faça o backup do banco de dados antes de iniciar a execução"}, oPanel,,oFont2,,,,.T.,CLR_BLACK,)
Return

static function ExecFix(aBrowse)
	private aEmp := aClone(aBrowse)
	If MsgNoYes( "Confirma a atualização dos dicionários ?", "4FIN" )
		oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc() }, "Atualizando", "Aguarde, atualizando ...", .F. )
		oProcess:Activate()
	endif
return .T.

	/* Local   aSay      := {}
	Local   aButton   := {}
	Local   aMarcadas := {}
	Local   cTitulo   := "ATUALIZACAO DE DICIONARIOS E TABELAS"
	Local   cDesc1    := "Esta rotina tem como funcao fazer  a atualizacao  dos dicionarios do Protheus (4Fin)"
	Local   cDesc2    := "Este processo deve ser executado em modo EXCLUSIVO, ou seja nao podem haver outros"
	Local   cDesc3    := "usuarios  ou  jobs utilizando  o sistema.  E EXTREMAMENTE recomendavel  que  se  faca um"
	Local   cDesc4    := "BACKUP  dos DICIONARIOS  e da  BASE DE DADOS antes desta atualizacao, para que caso "
	Local   cDesc5    := "ocorram eventuais falhas, esse backup possa ser restaurado."
	Local   lOk       := .F.
	local	nPos	  as numeric
	Private oMainWnd  := NIL
	Private oProcess  := NIL
	Private _aPars	  := {}

	#IFDEF TOP
		TCInternal( 5, "*OFF" ) // Desliga Refresh no Lock do Top
	#ENDIF

	If ! Empty( aMarcadas ) .And. ( nPos := aScan(_aPars,{|aLin| AllTrim(Upper(aLin[2])) == "ST_TABELA"}) ) != 0

		Private __AliCXML 	:= AllTrim(_aPars[nPos,13])
		Private __PrefCXML 	:= IIF(SubStr(__AliCXML,1,1)=="S",SubStr(__AliCXML,2,2),__AliCXML)

		If MsgNoYes( "Confirma a atualização dos dicionários ?", cTitulo )
			oProcess := MsNewProcess():New( { | lEnd | lOk := FSTProc( @lEnd, aMarcadas ) }, "Atualizando", "Aguarde, atualizando ...", .F. )
			oProcess:Activate()

			If lOk
				Final( "Atualização Realizada." )
			Else
				Final( "Atualização não Realizada." )
			EndIf
		Else
			Final( "Atualização não Realizada." )
		EndIf
	Else
		Final( "Atualização não Realizada." )
	EndIf
Return */
//--------------------------------------------------------------------
/*/{Protheus.doc} FSTProc
Função de processamento da gravação dos arquivos

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSTProc()
	Local   aInfo     := {}
	Local   cFile     := ""
	Local   cMask     := "Arquivos Texto" + "(*.TXT)|*.txt|"
	Local   cTCBuild  := "TCGetBuild"
	Local   cTexto    := ""
	Local   cTopBuild := ""
	Local   lRet      := .T.
	Local   nI        := 0
	Local   nPos      := 0
	Local   nX        := 0
	Local   oDlg      := NIL
	Local   oFont     := NIL
	Local   oMemo     := NIL

	Private aArqUpd   := {}

	For nI := 1 To Len( aEmp )
		if aEmp[nI][1]
			If ! MyOpenSm0()
				MsgStop( "Atualização da empresa " + aEmp[nI][2] + " não efetuada." )
				Exit
			EndIf

			RpcSetEnv(aEmp[nI][2])
			FwSm0Util():SetSM0PositionBycFilAnt()

			lMsFinalAuto := .F.
			lMsHelpAuto  := .F.

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( "LOG DA ATUALIZAÇÃO DOS DICIONÁRIOS" )
			AutoGrLog( Replicate( " ", 128 ) )
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )
			AutoGrLog( " Dados Ambiente" )
			AutoGrLog( " --------------------" )
			AutoGrLog( " Empresa / Filial...: " + cEmpAnt + "/" + cFilAnt )
			AutoGrLog( " Nome Empresa.......: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_NOMECOM", cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " Nome Filial........: " + Capital( AllTrim( GetAdvFVal( "SM0", "M0_FILIAL" , cEmpAnt + cFilAnt, 1, "" ) ) ) )
			AutoGrLog( " DataBase...........: " + DtoC( dDataBase ) )
			AutoGrLog( " Data / Hora Ínicio.: " + DtoC( Date() )  + " / " + Time() )
			AutoGrLog( " Environment........: " + GetEnvServer()  )
			AutoGrLog( " StartPath..........: " + GetSrvProfString( "StartPath", "" ) )
			AutoGrLog( " RootPath...........: " + GetSrvProfString( "RootPath" , "" ) )
			AutoGrLog( " Versão.............: " + GetVersao(.T.) )
			AutoGrLog( " Usuário TOTVS .....: " + __cUserId + " " +  cUserName )
			AutoGrLog( " Computer Name......: " + GetComputerName() )

			aInfo   := GetUserInfo()
			If ( nPos    := aScan( aInfo,{ |x,y| x[3] == ThreadId() } ) ) > 0
				AutoGrLog( " " )
				AutoGrLog( " Dados Thread" )
				AutoGrLog( " --------------------" )
				AutoGrLog( " Usuário da Rede....: " + aInfo[nPos][1] )
				AutoGrLog( " Estação............: " + aInfo[nPos][2] )
				AutoGrLog( " Programa Inicial...: " + aInfo[nPos][5] )
				AutoGrLog( " Environment........: " + aInfo[nPos][6] )
				AutoGrLog( " Conexão............: " + AllTrim( StrTran( StrTran( aInfo[nPos][7], Chr( 13 ), "" ), Chr( 10 ), "" ) ) )
			EndIf
			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " " )

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( "Empresa : " + SM0->M0_CODIGO + "/" + SM0->M0_NOME + CRLF )

			oProcess:SetRegua1( 8 )

			//------------------------------------
			// Atualiza o dicionário SX2
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de arquivos" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX2() ; ProcessMessages()

			//------------------------------------
			// Atualiza o dicionário SX3
			//------------------------------------
			//FSAtuSX3() ; ProcessMessages()

			//------------------------------------
			// Atualiza o dicionário SIX
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de índices" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSIX() ; ProcessMessages()

			oProcess:IncRegua1( "Dicionário de dados" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			oProcess:IncRegua2( "Atualizando campos/índices" )

			// Alteração física dos arquivos
			/* __SetX31Mode( .F. )

			If FindFunction(cTCBuild)
				cTopBuild := &cTCBuild.()
			EndIf

			For nX := 1 To Len( aArqUpd )

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					If ( ( aArqUpd[nX] >= "NQ " .AND. aArqUpd[nX] <= "NZZ" ) .OR. ( aArqUpd[nX] >= "O0 " .AND. aArqUpd[nX] <= "NZZ" ) ) .AND.;
						!aArqUpd[nX] $ "NQD,NQF,NQP,NQT"
						TcInternal( 25, "CLOB" )
					EndIf
				EndIf

				If Select( aArqUpd[nX] ) > 0
					dbSelectArea( aArqUpd[nX] )
					dbCloseArea()
				EndIf

				X31UpdTable( aArqUpd[nX] )

				If __GetX31Error()
					Alert( __GetX31Trace() )
					MsgStop( "Ocorreu um erro desconhecido durante a atualização da tabela : " + aArqUpd[nX] + ". Verifique a integridade do dicionário e da tabela.", "ATENÇÃO" )
					AutoGrLog( "Ocorreu um erro desconhecido durante a atualização da estrutura da tabela : " + aArqUpd[nX] )
				EndIf

				If cTopBuild >= "20090811" .AND. TcInternal( 89 ) == "CLOB_SUPPORTED"
					TcInternal( 25, "OFF" )
				EndIf

			Next nX */

			//------------------------------------
			// Atualiza o dicionário SX6
			//------------------------------------
			oProcess:IncRegua1( "Dicionário de parâmetros" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuSX6() ; ProcessMessages()

			//------------------------------------
			// Atualiza os helps
			//------------------------------------
			oProcess:IncRegua1( "Helps de Campo" + " - " + SM0->M0_CODIGO + " " + SM0->M0_NOME + " ..." )
			//FSAtuHlp() ; ProcessMessages()

			AutoGrLog( Replicate( "-", 128 ) )
			AutoGrLog( " Data / Hora Final.: " + DtoC( Date() ) + " / " + Time() )
			AutoGrLog( Replicate( "-", 128 ) )

			RpcClearEnv()
		endif
	Next nI


	cTexto := LeLog()

	Define Font oFont Name "Mono AS" Size 5, 12

	Define MsDialog oDlg Title "Atualização concluida." From 3, 0 to 340, 417 Pixel

	@ 5, 5 Get oMemo Var cTexto Memo Size 200, 145 Of oDlg Pixel
	oMemo:bRClicked := { || AllwaysTrue() }
	oMemo:oFont     := oFont

	Define SButton From 153, 175 Type  1 Action oDlg:End() Enable Of oDlg Pixel // Apaga
	Define SButton From 153, 145 Type 13 Action ( cFile := cGetFile( cMask, "" ), If( cFile == "", .T., ;
	MemoWrite( cFile, cTexto ) ) ) Enable Of oDlg Pixel

	Activate MsDialog oDlg Center

Return lRet


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX2
Função de processamento da gravação do SX2 - Arquivos

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX2()
Local aEstrut   := {}
Local aSX2      := {}
Local cAlias    := ""
Local cCpoUpd   := "X2_ROTINA /X2_UNICO  /X2_DISPLAY/X2_SYSOBJ /X2_USROBJ /X2_POSLGT /"
Local cEmpr     := ""
Local cPath     := ""
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SX2" + CRLF )

aEstrut := { "X2_CHAVE"  , "X2_PATH"   , "X2_ARQUIVO", "X2_NOME"   , "X2_NOMESPA", "X2_NOMEENG", "X2_MODO"   , ;
			 "X2_TTS"    , "X2_ROTINA" , "X2_PYME"   , "X2_UNICO"  , "X2_DISPLAY", "X2_SYSOBJ" , "X2_USROBJ" , ;
			 "X2_POSLGT" , "X2_CLOB"   , "X2_AUTREC" , "X2_MODOEMP", "X2_MODOUN" , "X2_MODULO" }


dbSelectArea( "SX2" )
SX2->( dbSetOrder( 1 ) )
SX2->( dbGoTop() )
cPath := SX2->X2_PATH
cPath := IIf( Right( AllTrim( cPath ), 1 ) <> "\", PadR( AllTrim( cPath ) + "\", Len( cPath ) ), cPath )
cEmpr := Substr( SX2->X2_ARQUIVO, 4 )

//
// Tabela __AliCXML
//
aAdd( aSX2, { ;
	__AliCXML																, ; //X2_CHAVE
	cPath																	, ; //X2_PATH
	__AliCXML+cEmpr															, ; //X2_ARQUIVO
	'Campos Retorno - Solver'												, ; //X2_NOME
	'Campos Retorno - Solver'												, ; //X2_NOMESPA
	'Campos Retorno - Solver'												, ; //X2_NOMEENG
	'C'																		, ; //X2_MODO
	''																		, ; //X2_TTS
	''																		, ; //X2_ROTINA
	'S'																		, ; //X2_PYME
	__PrefCXML+'_FILIAL+'+__PrefCXML+'_TABELA+'+__PrefCXML+'_CAMPO'			, ; //X2_UNICO
	__PrefCXML+'_FILIAL+'+__PrefCXML+'_TABELA+'+__PrefCXML+'_CAMPO'			, ; //X2_DISPLAY
	'STRESTA1'																, ; //X2_SYSOBJ
	''																		, ; //X2_USROBJ
	'1'																		, ; //X2_POSLGT
	'2'																		, ; //X2_CLOB
	'2'																		, ; //X2_AUTREC
	'C'																		, ; //X2_MODOEMP
	'C'																		, ; //X2_MODOUN
	5																		} ) //X2_MODULO

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX2 ) )

dbSelectArea( "SX2" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX2 )

	oProcess:IncRegua2( "Atualizando Arquivos (SX2)..." )

	If !SX2->( dbSeek( aSX2[nI][1] ) )

		If !( aSX2[nI][1] $ cAlias )
			cAlias += aSX2[nI][1] + "/"
			AutoGrLog( "Foi incluída a tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .T. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If AllTrim( aEstrut[nJ] ) == "X2_ARQUIVO"
					FieldPut( FieldPos( aEstrut[nJ] ), SubStr( aSX2[nI][nJ], 1, 3 ) + cEmpAnt +  "0" )
				Else
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf
			EndIf
		Next nJ
		MsUnLock()

	Else

		If  !( StrTran( Upper( AllTrim( SX2->X2_UNICO ) ), " ", "" ) == StrTran( Upper( AllTrim( aSX2[nI][12]  ) ), " ", "" ) )
			RecLock( "SX2", .F. )
			SX2->X2_UNICO := aSX2[nI][12]
			MsUnlock()

			If MSFILE( RetSqlName( aSX2[nI][1] ),RetSqlName( aSX2[nI][1] ) + "_UNQ"  )
				TcInternal( 60, RetSqlName( aSX2[nI][1] ) + "|" + RetSqlName( aSX2[nI][1] ) + "_UNQ" )
			EndIf

			AutoGrLog( "Foi alterada a chave única da tabela " + aSX2[nI][1] )
		EndIf

		RecLock( "SX2", .F. )
		For nJ := 1 To Len( aSX2[nI] )
			If FieldPos( aEstrut[nJ] ) > 0
				If PadR( aEstrut[nJ], 10 ) $ cCpoUpd
					FieldPut( FieldPos( aEstrut[nJ] ), aSX2[nI][nJ] )
				EndIf

			EndIf
		Next nJ
		MsUnLock()

	EndIf

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX2" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX3
Função de processamento da gravação do SX3 - Campos

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX3()
Local aEstrut   := {}
Local aSX3      := {}
Local cAlias    := ""
Local cAliasAtu := ""
Local cSeqAtu   := ""
Local nI        := 0
Local nJ        := 0
Local nPosArq   := 0
Local nPosCpo   := 0
Local nPosOrd   := 0
Local nPosSXG   := 0
Local nPosTam   := 0
Local nPosVld   := 0
Local nSeqAtu   := 0
Local nTamSeek  := Len( SX3->X3_CAMPO )
local lNewX3	:= (GetRpoRelease() >= "12.1.2210")

local aTabs		as array
local nT		as numeric
local nC		as numeric
local cN		as character
local cT		as character

AutoGrLog( "Ínicio da Atualização" + " SX3" + CRLF )

aEstrut := { { "X3_ARQUIVO", 0 }, { "X3_ORDEM"  , 0 }, { "X3_CAMPO"  , 0 }, { "X3_TIPO"   , 0 }, { "X3_TAMANHO", 0 }, { "X3_DECIMAL", 0 }, { "X3_TITULO" , 0 }, ;
			 { "X3_TITSPA" , 0 }, { "X3_TITENG" , 0 }, { "X3_DESCRIC", 0 }, { "X3_DESCSPA", 0 }, { "X3_DESCENG", 0 }, { "X3_PICTURE", 0 }, { "X3_VALID"  , 0 }, ;
			 { "X3_USADO"  , 0 }, { "X3_RELACAO", 0 }, { "X3_F3"     , 0 }, { "X3_NIVEL"  , 0 }, { "X3_RESERV" , 0 }, { "X3_CHECK"  , 0 }, { "X3_TRIGGER", 0 }, ;
			 { "X3_PROPRI" , 0 }, { "X3_BROWSE" , 0 }, { "X3_VISUAL" , 0 }, { "X3_CONTEXT", 0 }, { "X3_OBRIGAT", 0 }, { "X3_VLDUSER", 0 }, { "X3_CBOX"   , 0 }, ;
			 { "X3_CBOXSPA", 0 }, { "X3_CBOXENG", 0 }, { "X3_PICTVAR", 0 }, { "X3_WHEN"   , 0 }, { "X3_INIBRW" , 0 }, { "X3_GRPSXG" , 0 }, { "X3_FOLDER" , 0 }, ;
			 { "X3_CONDSQL", 0 }, { "X3_CHKSQL" , 0 }, { "X3_IDXSRV" , 0 }, { "X3_ORTOGRA", 0 }, { "X3_TELA"   , 0 }, { "X3_POSLGT" , 0 }, { "X3_IDXFLD" , 0 }, ;
			 { "X3_AGRUP"  , 0 }, { "X3_MODAL"  , 0 }, { "X3_PYME"   , 0 } }

aEval( aEstrut, { |x| x[2] := SX3->( FieldPos( x[1] ) ) } )

//
// Campos Tabela __AliCXML
//
aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	__PrefCXML+'_FILIAL'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	2																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filial'																, ; //X3_TITULO
	'Sucursal'																, ; //X3_TITSPA
	'Branch'																, ; //X3_TITENG
	'Filial do Sistema'														, ; //X3_DESCRIC
	'Sucursal'																, ; //X3_DESCSPA
	'Branch of the System'													, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	1																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	''																		, ; //X3_VISUAL
	''																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	'033'																	, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	''																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	''																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	__PrefCXML+'_TABELA'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	6																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Tabela'																, ; //X3_TITULO
	'Tabela'																, ; //X3_TITSPA
	'Tabela'																, ; //X3_TITENG
	'Tabela'																, ; //X3_DESCRIC
	'Tabela'																, ; //X3_DESCSPA
	'Tabela'																, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'03'																	, ; //X3_ORDEM
	__PrefCXML+'_NOMTAB'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	30																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Nome Tabela'															, ; //X3_TITULO
	'Nome Tabela'															, ; //X3_TITSPA
	'Nome Tabela'															, ; //X3_TITENG
	'Nome da Tabelas'														, ; //X3_DESCRIC
	'Nome da Tabelas'														, ; //X3_DESCSPA
	'Nome da Tabelas'														, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	'Posicione("SX2",2,M->'+__PrefCXML+'_TABELA,"X2_NOME")'					, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'V'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	'Posicione("SX2",2,'+__AliCXML+'->'+__PrefCXML+'_TABELA,"X2_NOME")'		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'04'																	, ; //X3_ORDEM
	__PrefCXML+'_CAMPO'														, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	10																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Campo'																	, ; //X3_TITULO
	'Campo'																	, ; //X3_TITSPA
	'Campo'																	, ; //X3_TITENG
	'Campo'																	, ; //X3_DESCRIC
	'Campo'																	, ; //X3_DESCSPA
	'Campo'																	, ; //X3_DESCENG
	'@!'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																				, ; //X3_ARQUIVO
	'05'																					, ; //X3_ORDEM
	__PrefCXML+'_NOMCPO'																	, ; //X3_CAMPO
	'C'																						, ; //X3_TIPO
	12																						, ; //X3_TAMANHO
	0																						, ; //X3_DECIMAL
	'Nome Campo'																			, ; //X3_TITULO
	'Nome Campo'																			, ; //X3_TITSPA
	'Nome Campo'																			, ; //X3_TITENG
	'Nome do Campo'																			, ; //X3_DESCRIC
	'Nome do Campo'																			, ; //X3_DESCSPA
	'Nome do Campo'																			, ; //X3_DESCENG
	''																						, ; //X3_PICTURE
	''																						, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))									, ; //X3_USADO
	'Iif(!INCLUI,Posicione("SX3",2,'+__AliCXML+'->'+__PrefCXML+'_CAMPO,"X3_TITULO"),"")'	, ; //X3_RELACAO
	''																						, ; //X3_F3
	0																						, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))												, ; //X3_RESERV
	''																						, ; //X3_CHECK
	''																						, ; //X3_TRIGGER
	'U'																						, ; //X3_PROPRI
	'S'																						, ; //X3_BROWSE
	'A'																						, ; //X3_VISUAL
	'V'																						, ; //X3_CONTEXT
	''																						, ; //X3_OBRIGAT
	''																						, ; //X3_VLDUSER
	''																						, ; //X3_CBOX
	''																						, ; //X3_CBOXSPA
	''																						, ; //X3_CBOXENG
	''																						, ; //X3_PICTVAR
	''																						, ; //X3_WHEN
	'Posicione("SX3",2,'+__AliCXML+'->'+__PrefCXML+'_CAMPO,"X3_TITULO")'					, ; //X3_INIBRW
	''																						, ; //X3_GRPSXG
	''																						, ; //X3_FOLDER
	''																						, ; //X3_CONDSQL
	''																						, ; //X3_CHKSQL
	''																						, ; //X3_IDXSRV
	'N'																						, ; //X3_ORTOGRA
	''																						, ; //X3_TELA
	''																						, ; //X3_POSLGT
	'N'																						, ; //X3_IDXFLD
	''																						, ; //X3_AGRUP
	''																						, ; //X3_MODAL
	''																						} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'06'																	, ; //X3_ORDEM
	__PrefCXML+'_FILTR1'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filtro 1'																, ; //X3_TITULO
	'Filtro 1'																, ; //X3_TITSPA
	'Filtro 1'																, ; //X3_TITENG
	''																		, ; //X3_DESCRIC
	''																		, ; //X3_DESCSPA
	''																		, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'07'																	, ; //X3_ORDEM
	__PrefCXML+'_FILTR2'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	100																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Filtro 2'																, ; //X3_TITULO
	'Filtro 2'																, ; //X3_TITSPA
	'Filtro 2'																, ; //X3_TITENG
	''																		, ; //X3_DESCRIC
	''																		, ; //X3_DESCSPA
	''																		, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	__AliCXML																, ; //X3_ARQUIVO
	'08'																	, ; //X3_ORDEM
	__PrefCXML+'_FORMUL'													, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	250																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'Formula'																, ; //X3_TITULO
	'Formula'																, ; //X3_TITSPA
	'Formula'																, ; //X3_TITENG
	'Formula'																, ; //X3_DESCRIC
	'Formula'																, ; //X3_DESCSPA
	'Formula'																, ; //X3_DESCENG
	''																		, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x        ",Chr(254) + Chr(192))						, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	''																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SH6'																	, ; //X3_ARQUIVO
	'01'																	, ; //X3_ORDEM
	'H6_XPESSOA'															, ; //X3_CAMPO
	'N'																		, ; //X3_TIPO
	3																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'No Pessoas'															, ; //X3_TITULO
	'No Pessoas'															, ; //X3_TITSPA
	'No Pessoas'															, ; //X3_TITENG
	''																		, ; //X3_DESCRIC
	''																		, ; //X3_DESCSPA
	''																		, ; //X3_DESCENG
	'999'																	, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'S'																		, ; //X3_BROWSE
	'A'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aAdd( aSX3, { ;
	'SH6'																	, ; //X3_ARQUIVO
	'02'																	, ; //X3_ORDEM
	'H6_XIDSOLV'															, ; //X3_CAMPO
	'C'																		, ; //X3_TIPO
	16																		, ; //X3_TAMANHO
	0																		, ; //X3_DECIMAL
	'ID Solver'																, ; //X3_TITULO
	'ID Solver'																, ; //X3_TITSPA
	'ID Solver'																, ; //X3_TITENG
	'ID Solver'																, ; //X3_DESCRIC
	'ID Solver'																, ; //X3_DESCSPA
	'ID Solver'																, ; //X3_DESCENG
	'99999999999999999'														, ; //X3_PICTURE
	''																		, ; //X3_VALID
	Iif(lNewX3,;
	'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x',;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
	Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
	''																		, ; //X3_RELACAO
	''																		, ; //X3_F3
	0																		, ; //X3_NIVEL
	Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
	''																		, ; //X3_CHECK
	''																		, ; //X3_TRIGGER
	'U'																		, ; //X3_PROPRI
	'N'																		, ; //X3_BROWSE
	'V'																		, ; //X3_VISUAL
	'R'																		, ; //X3_CONTEXT
	''																		, ; //X3_OBRIGAT
	''																		, ; //X3_VLDUSER
	''																		, ; //X3_CBOX
	''																		, ; //X3_CBOXSPA
	''																		, ; //X3_CBOXENG
	''																		, ; //X3_PICTVAR
	''																		, ; //X3_WHEN
	''																		, ; //X3_INIBRW
	''																		, ; //X3_GRPSXG
	''																		, ; //X3_FOLDER
	''																		, ; //X3_CONDSQL
	''																		, ; //X3_CHKSQL
	''																		, ; //X3_IDXSRV
	'N'																		, ; //X3_ORTOGRA
	''																		, ; //X3_TELA
	''																		, ; //X3_POSLGT
	'N'																		, ; //X3_IDXFLD
	''																		, ; //X3_AGRUP
	''																		, ; //X3_MODAL
	''																		} ) //X3_PYME

aTabs := {"SC2","SB1","SG2","SH6"}
for nT := 1 to Len(aTabs)
	for nC := 1 to 5
		cN := StrZero(nC,1) // precisa ser somente 1, devido as tabelas que usam prefixo de 3 digitos, pois o tamanho do campo passaria de 10
		cT := Iif(Left(aTabs[nT],1)=="S",Right(aTabs[nT],2),aTabs[nT])
		aAdd( aSX3, { ;
			aTabs[nT]																, ; //X3_ARQUIVO
			StrZero(94+nC,2)														, ; //X3_ORDEM
			cT + '_XSCT' + cN														, ; //X3_CAMPO
			'C'																		, ; //X3_TIPO
			50																		, ; //X3_TAMANHO
			0																		, ; //X3_DECIMAL
			'Custom ' + cN															, ; //X3_TITULO
			'Custom ' + cN															, ; //X3_TITSPA
			'Custom ' + cN															, ; //X3_TITENG
			'Campo Custom ' + cN													, ; //X3_DESCRIC
			'Campo Custom ' + cN													, ; //X3_DESCSPA
			'Campo Custom ' + cN													, ; //X3_DESCENG
			''																		, ; //X3_PICTURE
			''																		, ; //X3_VALID
			Iif(lNewX3,;
			'x       x       x       x       x       x       x       x       x       x       x       x       x       x       x',;
			Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(128) + ;
			Chr(128) + Chr(128) + Chr(128) + Chr(128) + Chr(160))					, ; //X3_USADO
			''																		, ; //X3_RELACAO
			''																		, ; //X3_F3
			0																		, ; //X3_NIVEL
			Iif(lNewX3,"xxxxxx x",Chr(254) + Chr(192))								, ; //X3_RESERV
			''																		, ; //X3_CHECK
			''																		, ; //X3_TRIGGER
			'U'																		, ; //X3_PROPRI
			'N'																		, ; //X3_BROWSE
			'A'																		, ; //X3_VISUAL
			'R'																		, ; //X3_CONTEXT
			''																		, ; //X3_OBRIGAT
			''																		, ; //X3_VLDUSER
			''																		, ; //X3_CBOX
			''																		, ; //X3_CBOXSPA
			''																		, ; //X3_CBOXENG
			''																		, ; //X3_PICTVAR
			''																		, ; //X3_WHEN
			''																		, ; //X3_INIBRW
			''																		, ; //X3_GRPSXG
			''																		, ; //X3_FOLDER
			''																		, ; //X3_CONDSQL
			''																		, ; //X3_CHKSQL
			''																		, ; //X3_IDXSRV
			'N'																		, ; //X3_ORTOGRA
			''																		, ; //X3_TELA
			''																		, ; //X3_POSLGT
			'N'																		, ; //X3_IDXFLD
			''																		, ; //X3_AGRUP
			''																		, ; //X3_MODAL
			''																		} ) //X3_PYME
	next nC
next nT

//
// Atualizando dicionário
//
nPosArq := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ARQUIVO" } )
nPosOrd := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_ORDEM"   } )
nPosCpo := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_CAMPO"   } )
nPosTam := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_TAMANHO" } )
nPosSXG := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_GRPSXG"  } )
nPosVld := aScan( aEstrut, { |x| AllTrim( x[1] ) == "X3_VALID"   } )

aSort( aSX3,,, { |x,y| x[nPosArq]+x[nPosOrd]+x[nPosCpo] < y[nPosArq]+y[nPosOrd]+y[nPosCpo] } )

oProcess:SetRegua2( Len( aSX3 ) )

dbSelectArea( "SX3" )
dbSetOrder( 2 )
cAliasAtu := ""

For nI := 1 To Len( aSX3 )

	//
	// Verifica se o campo faz parte de um grupo e ajusta tamanho
	//
	If !Empty( aSX3[nI][nPosSXG] )
		SXG->( dbSetOrder( 1 ) )
		If SXG->( MSSeek( aSX3[nI][nPosSXG] ) )
			If aSX3[nI][nPosTam] <> SXG->XG_SIZE
				aSX3[nI][nPosTam] := SXG->XG_SIZE
				AutoGrLog( "O tamanho do campo " + aSX3[nI][nPosCpo] + " NÃO atualizado e foi mantido em [" + ;
				AllTrim( Str( SXG->XG_SIZE ) ) + "]" + CRLF + ;
				" por pertencer ao grupo de campos [" + SXG->XG_GRUPO + "]" + CRLF )
			EndIf
		EndIf
	EndIf

	SX3->( dbSetOrder( 2 ) )

	If !( aSX3[nI][nPosArq] $ cAlias )
		cAlias += aSX3[nI][nPosArq] + "/"
		aAdd( aArqUpd, aSX3[nI][nPosArq] )
	EndIf

	If !SX3->( dbSeek( PadR( aSX3[nI][nPosCpo], nTamSeek ) ) )

		//
		// Busca ultima ocorrencia do alias
		//
		If ( aSX3[nI][nPosArq] <> cAliasAtu )
			cSeqAtu   := "00"
			cAliasAtu := aSX3[nI][nPosArq]

			dbSetOrder( 1 )
			SX3->( dbSeek( cAliasAtu + "ZZ", .T. ) )
			dbSkip( -1 )

			If ( SX3->X3_ARQUIVO == cAliasAtu )
				cSeqAtu := SX3->X3_ORDEM
			EndIf

			nSeqAtu := Val( RetAsc( cSeqAtu, 3, .F. ) )
		EndIf

		nSeqAtu++
		cSeqAtu := RetAsc( Str( nSeqAtu ), 2, .T. )

		RecLock( "SX3", .T. )
		For nJ := 1 To Len( aSX3[nI] )
			If     nJ == nPosOrd  // Ordem
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), cSeqAtu ) )

			ElseIf aEstrut[nJ][2] > 0
				SX3->( FieldPut( FieldPos( aEstrut[nJ][1] ), aSX3[nI][nJ] ) )

			EndIf
		Next nJ

		dbCommit()
		MsUnLock()

		AutoGrLog( "Criado campo " + aSX3[nI][nPosCpo] )

	EndIf

	oProcess:IncRegua2( "Atualizando Campos de Tabelas (SX3)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX3" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSIX
Função de processamento da gravação do SIX - Indices

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSIX()
Local aEstrut   := {}
Local aSIX      := {}
Local lAlt      := .F.
Local lDelInd   := .F.
Local nI        := 0
Local nJ        := 0

AutoGrLog( "Ínicio da Atualização" + " SIX" + CRLF )

aEstrut := { "INDICE" , "ORDEM" , "CHAVE", "DESCRICAO", "DESCSPA"  , ;
			 "DESCENG", "PROPRI", "F3"   , "NICKNAME" , "SHOWPESQ" }

//
// Tabela __AliCXML
//
aAdd( aSIX, { ;
	__AliCXML																, ; //INDICE
	'1'																		, ; //ORDEM
	__PrefCXML+'_FILIAL+'+__PrefCXML+'_TABELA+'+__PrefCXML+'_CAMPO'			, ; //CHAVE
	'Tabela+Campo'															, ; //DESCRICAO
	'Tabela+Campo'															, ; //DESCSPA
	'Tabela+Campo'															, ; //DESCENG
	'U'																		, ; //PROPRI
	''																		, ; //F3
	''																		, ; //NICKNAME
	'S'																		} ) //SHOWPESQ

//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSIX ) )

dbSelectArea( "SIX" )
SIX->( dbSetOrder( 1 ) )

For nI := 1 To Len( aSIX )

	lAlt    := .F.
	lDelInd := .F.

	If !SIX->( dbSeek( aSIX[nI][1] + aSIX[nI][2] ) )
		AutoGrLog( "Índice criado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
	Else
		lAlt := .T.
		aAdd( aArqUpd, aSIX[nI][1] )
		If !StrTran( Upper( AllTrim( CHAVE )       ), " ", "" ) == ;
			StrTran( Upper( AllTrim( aSIX[nI][3] ) ), " ", "" )
			AutoGrLog( "Chave do índice alterado " + aSIX[nI][1] + "/" + aSIX[nI][2] + " - " + aSIX[nI][3] )
			lDelInd := .T. // Se for alteração precisa apagar o indice do banco
		EndIf
	EndIf

	RecLock( "SIX", !lAlt )
	For nJ := 1 To Len( aSIX[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSIX[nI][nJ] )
		EndIf
	Next nJ
	MsUnLock()

	dbCommit()

	If lDelInd
		TcInternal( 60, RetSqlName( aSIX[nI][1] ) + "|" + RetSqlName( aSIX[nI][1] ) + aSIX[nI][2] )
	EndIf

	oProcess:IncRegua2( "Atualizando índices..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SIX" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuSX6
Função de processamento da gravação do SX6 - Parâmetros

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuSX6()
Local aEstrut   := {}
Local aSX6      := {}
Local cAlias    := ""
Local lReclock  := .T.
Local nI        := 0
Local nJ        := 0
Local nTamFil   := Len( SX6->X6_FIL )
Local nTamVar   := Len( SX6->X6_VAR )

AutoGrLog( "Ínicio da Atualização" + " SX6" + CRLF )

aEstrut := { "X6_FIL"    , "X6_VAR"    , "X6_TIPO"   , "X6_DESCRIC", "X6_DSCSPA" , "X6_DSCENG" , "X6_DESC1"  , ;
			 "X6_DSCSPA1", "X6_DSCENG1", "X6_DESC2"  , "X6_DSCSPA2", "X6_DSCENG2", "X6_CONTEUD", "X6_CONTSPA", ;
			 "X6_CONTENG", "X6_PROPRI" , "X6_VALID"  , "X6_INIT"   , "X6_DEFPOR" , "X6_DEFSPA" , "X6_DEFENG" , ;
			 "X6_PYME"   }

For nI:=1 To Len(_aPars)
	AADD(aSX6,_aPars[nI])
	nTamDescric := Len(aSX6[nI,4])
	If nTamDescric > 100
		aSX6[nI,07] := SubStr(aSX6[nI,04],051,50) //X6_DESC1
		aSX6[nI,10] := SubStr(aSX6[nI,04],101,50) //X6_DESC2
		aSX6[nI,04] := SubStr(aSX6[nI,04],001,50) //X6_DESCRIC
	ElseIf nTamDescric > 50
		aSX6[nI,07] := SubStr(aSX6[nI,04],051,50) //X6_DESC1
		aSX6[nI,04] := SubStr(aSX6[nI,04],001,50) //X6_DESCRIC
	Endif
Next nI
//
// Atualizando dicionário
//
oProcess:SetRegua2( Len( aSX6 ) )

dbSelectArea( "SX6" )
dbSetOrder( 1 )

For nI := 1 To Len( aSX6 )
	lReclock := .Not. SX6->( dbSeek( PadR( aSX6[nI][1], nTamFil ) + PadR( aSX6[nI][2], nTamVar ) ) )

	If lReclock
		AutoGrLog( "Foi incluído o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	Else
		AutoGrLog( "Foi alterado o parâmetro " + aSX6[nI][1] + aSX6[nI][2] + " Conteúdo [" + AllTrim( aSX6[nI][13] ) + "]" )
	EndIf

	If !( aSX6[nI][1] $ cAlias )
		cAlias += aSX6[nI][1] + "/"
	EndIf

	RecLock( "SX6", lReclock )
	For nJ := 1 To Len( aSX6[nI] )
		If FieldPos( aEstrut[nJ] ) > 0
			FieldPut( FieldPos( aEstrut[nJ] ), aSX6[nI][nJ] )
		EndIf
	Next nJ
	dbCommit()
	MsUnLock()

	oProcess:IncRegua2( "Atualizando Arquivos (SX6)..." )

Next nI

AutoGrLog( CRLF + "Final da Atualização" + " SX6" + CRLF + Replicate( "-", 128 ) + CRLF )

Return NIL


//--------------------------------------------------------------------
/*/{Protheus.doc} FSAtuHlp
Função de processamento da gravação dos Helps de Campos

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function FSAtuHlp()
	Local aHlpPor   := {}
	Local aHlpEng   := {}
	Local aHlpSpa   := {}

	AutoGrLog( "Ínicio da Atualização" + " " + "Helps de Campos" + CRLF )

	oProcess:IncRegua2( "Atualizando Helps de Campos ..." )

	aHlpPor := {}
	aAdd( aHlpPor, 'Código que identifica a filial da' )
	aAdd( aHlpPor, 'empre-sa usuária do sistema.' )

	aHlpEng := {}
	aAdd( aHlpEng, 'Code identifying the branch of the' )
	aAdd( aHlpEng, "system's user company." )

	aHlpSpa := {}
	aAdd( aHlpSpa, 'Código que identifica la sucursal de la' )
	aAdd( aHlpSpa, 'empresa usuaria del sistema.' )

	PutSX1Help( "P"+__PrefCXML+"_FILIAL ", aHlpPor, aHlpEng, aHlpSpa, .T.,,.T. )
	AutoGrLog( "Atualizado o Help do campo " + __PrefCXML + "_FILIAL" )

	AutoGrLog( CRLF + "Final da Atualização" + " " + "Helps de Campos" + CRLF + Replicate( "-", 128 ) + CRLF )
Return {}
//--------------------------------------------------------------------
/*/{Protheus.doc} MyOpenSM0
Função de processamento abertura do SM0 modo exclusivo

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function MyOpenSM0()
	Local lOpen := .F.
	Local nLoop := 0

	For nLoop := 1 To 20
		If OpenSM0Excl(,.F.)
			lOpen := .T.
			Exit
		EndIf
		Sleep( 500 )
	Next nLoop

	If !lOpen
		MsgStop( "Não foi possível a abertura da tabela " + ;
		IIf( lShared, "de empresas (SM0).", "de empresas (SM0) de forma exclusiva." ), "ATENÇÃO" )
	EndIf
Return lOpen
//--------------------------------------------------------------------
/*/{Protheus.doc} LeLog
Função de leitura do LOG gerado com limitacao de string

@author TOTVS Protheus
@since  16/02/2021
@obs    Gerado por EXPORDIC - V.6.6.1.5 EFS / Upd. V.5.1.0 EFS
@version 1.0
/*/
//--------------------------------------------------------------------
Static Function LeLog()
Local cRet  := ""
Local cFile := NomeAutoLog()
Local cAux  := ""

FT_FUSE( cFile )
FT_FGOTOP()

While !FT_FEOF()

	cAux := FT_FREADLN()

	If Len( cRet ) + Len( cAux ) < 1048000
		cRet += cAux + CRLF
	Else
		cRet += CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		cRet += "Tamanho de exibição maxima do LOG alcançado." + CRLF
		cRet += "LOG Completo no arquivo " + cFile + CRLF
		cRet += Replicate( "=" , 128 ) + CRLF
		Exit
	EndIf

	FT_FSKIP()
End

FT_FUSE()

Return cRet

static function FnQuit(oApp)
	oApp:createEnv()
	Final( "Encerramento Normal" , "" )
return
