Static Procedure WfRetorno( oProcess , lMsg )

Local cObs   	:=	oProcess:oHtml:RetByName("OBS")
Local cRecno 	:=	Upper(oProcess:oHtml:RetByName("NRECNO"))
Local cEmpTmp	:=	Upper(oProcess:oHtml:RetByName("CODEMP"))
Local cFilTmp	:=	Upper(oProcess:oHtml:RetByName("CODFIL"))
Local cResult	:=	Upper(oProcess:oHtml:RetByName("RBAPROVA"))      
Local aPar		:=	Nil 

Default lMsg 	:=	.f. 

cObs   			:=	iif( ValType(cObs) <> "C" , "" , Upper(cObs) )
aPar			:=	{ cEmpTmp , cFilTmp , cResult , cRecno , cObs , lMsg }

ConOut("")
ConOut("*********************")
ConOut("RETORNO DO WORKFLOW")
ConOut("EMPRESA   : " + cEmpTmp)
ConOut("FILIAL    : " + cFilTmp)
ConOut("RECNO     : " + cRecno )
ConOut("RESULT    : " + cResult)
ConOut("*********************")
ConOut("")

StartJob("U_XRETWFK",GetEnvServer(),.f.,aPar)	

Return ( .t. )

User Function xRetWfk(aPar)

Local cEmpTmp		:=	aPar[01]
Local cFilTmp		:=	aPar[02]
Local cResult		:=	aPar[03]
Local cRecno		:=	aPar[04]
Local cObser 		:=	aPar[05]
Local lMsgCb 		:=	aPar[06]

Local aStruct		:=	{}
Local xStruct		:=	{}
Local lIsBlind		:=	IsBlind() .or. Type("__LocalDriver") == "U"

if	lIsBlind
	RpcSetType(3)
	Prepare Environment Empresa cEmpTmp Filial cFilTmp
	SetModulo("SIGAFIN","FIN")
	ConOut("")
	ConOut("***********")
	ConOut("Iniciando o StarJob da Empresa " + cEmpTmp)
	ConOut("Empresa         : " + cEmpTmp )
	ConOut("Filial          : " + cFilTmp )
	ConOut("***********")
	ConOut("")
endif
