#include 'totvs.ch'                                                                                                                
#include 'topconn.ch'
#include "tbiconn.ch"
#include "tbicode.ch"

//.=================================================================================.
//|                             Merieux NutriScience	                			|
//|---------------------------------------------------------------------------------|
//| Programa : EnviaNFSe() | Autor: Raphael Koury Giusti	 		  		        |
//|---------------------------------------------------------------------------------|
//| E-mail: raphael.giusti@mxns.com	                                                |		  
//|---------------------------------------------------------------------------------|
//| Nome do relatório: Envia NFSe.													|
//|---------------------------------------------------------------------------------|
//| Descricao: 	Realiza a impressão do boleto, relatório de medições e envia        |
//| ao cliente junto com o link de acesso á NFSe via prefeitura.					|
//| Obs. Para que o boleto e o rel de medição sejam enviados deve ser criado um		|
//| mapeamento na estação do usuário apontado para a pasta "nfs_prefeituras" abaixo |
//| do "Protheus_data" (variável "cOrigArq")										|																	  
//|---------------------------------------------------------------------------------|
//| Data criacao  : 12/03/2018 			  | Ultima alteracao:              			|
//|---------------------------------------------------------------------------------|
//.=================================================================================.

user function EnviaNFSe()
local cPerg := Alltrim(upper(FunName()))
private lCargaTela := .T.
	//Valida as perguntas
	fValidPerg(cPerg)
	if pergunte(cPerg,.T.)
		execQuery()
		if lCargaTela
			Processa({|lEnd|carregaTela()})
		endif
	endif
return

//------------------------------------------|
// Carrega a tela com os RPS's para seleção	|
//------------------------------------------|
static function carregaTela()
local oBtn1,oBtn2,oGrp,oDlg,oList
local oOk    	:= loadBitmap(getResources(),"LBOK")
local oNo    	:= loadBitmap(getResources(),"LBNO")    
local oVermelho := loadBitmap(GetReSources(), "BR_VERMELHO")
local oVerde 	:= loadBitmap(GetReSources(), "BR_VERDE")   
local oAzul		:= loadBitmap(GetReSources(), "BR_AZUL")
local aLista 	:= {}
local lRetorno  := .f.
local aButtons  := {}

	QRYRPS->(dbGoTop())
	while QRYRPS->(!eof())
		aadd(aLista,{.F.,iif(substring(alltrim(QRYRPS->ENVNF),1,1)=="E",oVerde,iif(substring(alltrim(QRYRPS->ENVNF),1,1)=="P",oAzul,oVermelho)),alltrim(posicione("SA1",1,xFilial("SA1")+QRYRPS->CLIENTE,"A1_NOME")),alltrim(QRYRPS->LOJA),alltrim(QRYRPS->PROPOSTA),;
		alltrim(QRYRPS->DOC),alltrim(QRYRPS->SERIE),QRYRPS->VALOR,alltrim(QRYRPS->EMAIL),alltrim(QRYRPS->NUMBOR), QRYRPS->EMISSAO,alltrim(QRYRPS->FILIAL),;
		alltrim(QRYRPS->NFSE),alltrim(QRYRPS->PEDIDO),QRYRPS->RECNOSF2,alltrim(QRYRPS->PREFIXO),alltrim(QRYRPS->CLIENTE)})
		QRYRPS->(dbSkip())
	enddo
	
  DEFINE MSDIALOG oDlg TITLE "Envio de RPS" FROM 000, 000  TO 480, 1060 PIXEL
  	
  	aadd( aButtons, {"LEGENDA", {|| legenda()}, "Legenda", "Legenda" , {|| .T.}} )
  	
    @ 032, 002 GROUP oGrp TO 225, 530 OF oDlg PIXEL
    @ 041, 006 SAY "Selecione as RPS's a serem enviadas:" SIZE 146, 007 OF oDlg PIXEL
    
    @ 052,005 LISTBOX oList FIELDS HEADER "","","Cliente","Loja","Prop.Comercial","RPS","Serie","Valor","E-mail" PIXEL SIZE 522,168 OF oDlg; 
        ON dblClick ( aLista[oList:Nat,1] := !aLista[oList:Nat,1], oList:refresh() )
        oList:setArray(aLista) 
        oList:bLine := {|| { if(aLista[oList:Nat,1],oOk,oNo) ,aLista[oList:Nat,2] ,aLista[oList:Nat,3] ,aLista[oList:Nat,4], aLista[oList:Nat,5],;
         						aLista[oList:Nat,6], aLista[oList:Nat,7], transform(aLista[oList:Nat,8],"@E 999,999,999.99"),aLista[oList:Nat,9],;
         						aLista[oList:Nat,10],aLista[oList:Nat,11],aLista[oList:Nat,12],aLista[oList:Nat,13],aLista[oList:Nat,14],;
          						aLista[oList:Nat,15],aLista[oList:Nat,16],aLista[oList:Nat,17]} }
        
        SetKey( VK_F4, { || retPerg(oDlg)} ) //Realiza a chamada das perguntas novamente.
 
  ACTIVATE MSDIALOG oDlg CENTERED On Init EnchoiceBar(oDlg,{||executaEnvio(aLista,oDlg)},{||oDlg:End()},,@aButtons)
  SetKey( VK_F4, 		{ || Nil } )
Return

//----------------------------------------------|
// Executa a query para carregamento das RPS's	|
// a serem selecionadas para a impressão.		|
//----------------------------------------------|
static function execQuery()
local cQry := ""

if	select("QRYRPS") > 0
	QRYRPS->(dbCloseArea())
endif	
	//|----------------------------------------------|
	//| Variaveis utilizadas para parametros   		 |
	//| mv_par01               Cliente de      		 |
	//| mv_par02               Cliente até     		 |
	//| mv_par03               RPS de    		 	 |
	//| mv_par04               RPS ate  		 	 |
	//| mv_par05               Serie RPS 			 |
	//| mv_par06               Emissao de 			 |
	//| mv_par07               Emissao até			 |
	//|----------------------------------------------|
cQry += " SELECT "
cQry += " 	F2.F2_FILIAL FILIAL, " 
cQry += " 	F2.F2_CLIENTE CLIENTE, "
cQry += " 	F2.F2_LOJA LOJA, "
cQry += " 	F2.F2_DOC DOC, "
cQry += " 	F2.F2_SERIE SERIE, "
cQry += " 	F2.F2_NFELETR NFSE, "
cQry += " 	F2.F2_PREFIXO PREFIXO, "
cQry += " 	F2.R_E_C_N_O_ RECNOSF2, "
cQry += " 	E1.E1_ZZEMAI EMAIL, "  
cQry += " 	F2.F2_VALBRUT VALOR, "
cQry += " 	E1.E1_NUMBOR NUMBOR, "
cQry += " 	E1.E1_ZZPROP PROPOSTA, "
cQry += " 	E1.E1_EMISSAO EMISSAO, "
cQry += " 	E1.E1_PEDIDO PEDIDO, "
cQry += " 	CASE WHEN E1.E1_ZZENVNF = 'S' THEN 'Enviado' 
cQry += " 	     WHEN E1.E1_ZZENVNF = 'P' THEN 'Portal' ELSE 'Nao Enviado' END ENVNF, "
cQry += " 	E1.E1_ZZDTEM DTENVNF "
cQry += " FROM "+retSQLName("SF2")+" F2  "
cQry += " INNER JOIN "+retSQLName("SE1")+" E1 ON (E1.E1_FILORIG = F2.F2_FILIAL AND E1.E1_NUM = F2.F2_DOC AND E1.E1_SERIE = F2.F2_SERIE AND E1.E1_CLIENTE = F2.F2_CLIENTE AND E1.E1_LOJA = F2.F2_LOJA AND E1.D_E_L_E_T_ = '') 
cQry += " WHERE " 
cQry += " 		F2.F2_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "
cQry += " 	AND F2.F2_CLIENTE BETWEEN '"+mv_par04+"' AND '"+mv_par05+"' "
cQry += " 	AND F2.F2_DOC BETWEEN '"+mv_par06+"' AND '"+mv_par07+"' "
cQry += " 	AND F2.F2_SERIE = '"+mv_par08+"' "
cQry += " 	AND F2.F2_EMISSAO BETWEEN '"+dtos(mv_par09)+"' AND '"+dtos(mv_par10)+"' "
cQry += " 	AND F2.F2_NFELETR <> '' "
cQry += " 	AND F2.F2_CODNFE <> '' "
cQry += " 	AND F2.D_E_L_E_T_ = '' "

if(mv_par03 == 2) //enviados
	cQry += " 	AND E1.E1_ZZENVNF = 'S' "
elseif(mv_par03 == 3) //não enviados
	cQry += " 	AND E1.E1_ZZENVNF = ' ' "
elseif(mv_par03 == 4) // portal
	cQry += " 	AND E1.E1_ZZENVNF = 'P' "
endif

cQry += "GROUP BY  "
cQry += " 	F2.F2_FILIAL, " 
cQry += "	F2.F2_CLIENTE , "
cQry += "	F2.F2_LOJA , "
cQry += "	F2.F2_DOC , "
cQry += "	F2.F2_SERIE , "
cQry += "	F2.F2_NFELETR , "
cQry += "	F2.F2_PREFIXO, "
cQry += "	F2.R_E_C_N_O_, "
cQry += "	F2.F2_VALBRUT, "
cQry += "	E1.E1_NUMBOR , "
cQry += "	E1.E1_EMISSAO , "
cQry += "	E1.E1_PEDIDO , "
cQry += "	E1.E1_ZZENVNF, "
cQry += "	E1.E1_ZZDTEM,  "
cQry += "	E1.E1_ZZEMAI,  "
cQry += "	E1.E1_ZZPROP,  "
cQry += "	E1.E1_FILORIG  "
cQry += " ORDER BY E1.E1_FILORIG ,F2.F2_DOC "


dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQry),'QRYRPS',.F.,.T.)

count to nQRYRPS

if nQRYRPS <= 0
	MsgStop("Dados não encontrados, verifique os parâmetros informados!",funName())
	lCargaTela := .F.
	return 
endIf

return nil

//---------------------------------------|
// Executa o envio do e-mail ao cliente. |
//---------------------------------------|
static function executaEnvio(aLista,oDlg)
local oedtEmail, oDlg, oRPS, oCodCliLoj, oNomFant
local cRPS 		  := "" 
local cCodCliLoj  := ""
local cNomFant    := ""
local cLocal      := ""
local cOrigArq	  := ""    
local cArq01 	  := ""
local cArq02 	  := ""
local cHtml	 	  := ""
local cAssunto	  := ""
local cPara		  := space(250)
local aParam := {}
local lAltEm 
local lEnviado

if(mv_par12 == 1)
	lAltEm := .t.
else
	lAltEm := .f.
endif

for n := 1 to len(aLista)
	if(aLista[n][1])
		cPara  := space(250)
		cLocal := Alltrim(mv_par11)+"\"+Alltrim(Posicione("SM0",1,SM0->M0_CODIGO+aLista[n][12],"M0_CIDCOB"))+"\"+Alltrim(Posicione("SM0",1,SM0->M0_CODIGO+aLista[n][12],"M0_CGC"))+"\"
		cOrigArq := "\nfs_prefeituras\"+Alltrim(Posicione("SM0",1,SM0->M0_CODIGO+aLista[n][12],"M0_CIDCOB"))+"\"+Alltrim(Posicione("SM0",1,SM0->M0_CODIGO+aLista[n][12],"M0_CGC"))
		//Se a fatura contiver borderô, o boleto será impresso
		if(!empty(aLista[n][10]))
			Processa({ |lEnd| u_GeraBolPDF(aLista[n][12],aLista[n][17],aLista[n][4],aLista[n][6],aLista[n][16],StoD(aLista[n][11]),cLocal),OemToAnsi('Gerando boleto bancário.')}, OemToAnsi('Aguarde...'))
		endif
		
		aParam:= {aLista[n][6],cLocal,aLista[n][14],aLista[n][12]}  //Configura os parâmetros do relatório.
		
		If ExistBlock( "BIFATR08" )
			ExecBlock( "BIFATR08", .F., .F., aParam )
		EndIf
			
			if(empty(aLista[n][9]))
				lAltEm := .t.
			else
				cPara	:= alltrim(aLista[n][9])
			endif
			
			if(lAltEm)
				cPara := alteraEmail(aLista[n][3],aLista[n][4],aLista[n][6],aLista[n][5],StoD(aLista[n][11]),@cPara)
			endif
			
			if alltrim(cPara) != "Portal" .and. !empty(cPara)
				cAssunto	:= "NFS-e referente a RPS "+aLista[n][6] 
				cArq01	:= "\"+cOrigArq+"\bol"+aLista[n][6]+".pdf
				cArq02 := "\"+cOrigArq+"\relmed"+aLista[n][6]+".pdf" 
			    cHtml := geraHTML(aLista[n][14],aLista[n][15],aLista[n][10])

				Processa({|lEnd|TEnvMail1(cPara,cAssunto,cHtml,cArq01,cArq02,aLista[n][10],aLista[n][15])})

			else
				if(!empty(cPara))
					gravaEnvio(aLista[n][15],cPara)
				endif
			endif
				
	endif
next n
	msgAlert("Envio de e-mails realizado com sucesso!")
	oDlg:end()
	execQuery()
	if lCargaTela
		Processa({|lEnd|carregaTela()})
	endif
return

//---------------------------------------------
// Valida as perguntas novamente via tecla F4
//---------------------------------------------
static function retPerg(oDlg)

	if pergunte("ENVIANFSE",.T.)
		oDlg:end()
		execQuery()
		if lCargaTela
			Processa({|lEnd|carregaTela()})
		endif
	endif

return 

//-------------------------------------------
// Função que realiza a alteração do e-mail 
// á ser enviado ao cliente.
//-------------------------------------------
static function alteraEmail(cCliente,cLoja,cRps,cProcCom,dEmissao,cPara)
local oDlg2,oGrp,oLoja,oNomFant,oRps,oProcCom,oEmissao,oEmail,oChkBox,oBtn1,oBtn2   
local lChkBox	 := .f.
local cEmail   	 := iif(empty(cPara),space(250),cPara+(space(250)))


 DEFINE MSDIALOG oDlg2 TITLE "Ajusta e-mail" FROM 000, 000  TO 315, 600 PIXEL

    @ 005, 005 GROUP oGrp TO 153, 299 OF oDlg2 PIXEL
    @ 015, 007 SAY "Cliente" SIZE 049, 007 OF oDlg2 PIXEL
    @ 023, 007 MSGET oNomFant VAR cCliente SIZE 185, 010 OF oDlg2 PIXEL when .f.
    @ 015, 240 SAY "Loja" SIZE 025, 007 OF oDlg2 PIXEL
    @ 023, 240 MSGET oLoja VAR cLoja SIZE 019, 010 OF oDlg2 PIXEL when .f.
    @ 045, 007 SAY "RPS" SIZE 025, 007 OF oDlg2 PIXEL
    @ 053, 007 MSGET oRps VAR cRps SIZE 056, 010 OF oDlg2 PIXEL when .f.
    @ 045, 085 SAY "Proc. Comercial" SIZE 043, 007 OF oDlg2 PIXEL
    @ 053, 085 MSGET oProcCom VAR cProcCom SIZE 060, 010 OF oDlg2 PIXEL when .f.
    @ 045, 163 SAY "Emissão" SIZE 025, 007 OF oDlg2 PIXEL
    @ 053, 163 MSGET oEmissao VAR DtoC(dEmissao) SIZE 060, 010 OF oDlg2 PIXEL when .f.
    @ 074, 007 SAY "E-mail" SIZE 025, 007 OF oDlg2 PIXEL
    @ 082, 007 MSGET oEmail VAR cEmail SIZE 273, 010 OF oDlg2 PIXEL message "Digite o endereço de e-mail do cliente."
    @ 053, 240 CHECKBOX oChkBox VAR lChkBox PROMPT "Portal" SIZE 048, 008 OF oDlg2 PIXEL
    
    @ 120, 159 BUTTON oBtn1 PROMPT "Salvar"   SIZE 042, 015 OF oDlg2 PIXEL action valPortal(@cEmail,lChkBox,@oDlg2)
    @ 120, 211 BUTTON oBtn2 PROMPT "Cancelar" SIZE 042, 015 OF oDlg2 PIXEL action(cEmail:="",oDlg2:end())

  ACTIVATE MSDIALOG oDlg2 CENTERED 

return cEmail

//-----------------------------------
// Valida se é enviado o e-mail ou 
// realizado o upload via portal.
//-----------------------------------
static function valPortal(cEmail,lValPort,oDlg2)
	if(lValPort)
		cEmail := "Portal"
	endif
oDlg2:end()
return 

//--------------------------------------------------
// Realiza o preparo do HTML para envio ao cliente
//--------------------------------------------------
static function geraHTML(cPedido,nRecSF2,cBordero)
local cLink  	:= ""
local _cHTML    := ""
local cNomeCli  := ""
local cProcCom  := ""

//Obtém dados para montagem dos Links das prefeituras
dbSelectArea("SF2")
dbGoTo(nRecSF2)

if !Empty(SF2->F2_NFELETR).AND. !Empty(SF2->F2_CODNFE)   //Validacao de campo inicio

	If Alltrim(SM0->M0_CIDCOB)=="PIRACICABA" //link Piracicaba                              
	//cLink:= "http://sistemas.pmp.sp.gov.br/semfi/simpliss/contrib/app/nfse/relatorio.aspx?cnpj="+Alltrim(SM0->M0_CGC)+"&ser=E&inum="+alltrim(SF2->F2_NFELETR)+"&icod="+alltrim(SF2->F2_CODNFE)
	
	cLink:= "https://piracicaba.simplissweb.com.br/contrib/app/nfse/relatorio?cnpj="+Alltrim(SM0->M0_CGC)+"&ser=E&inum="+alltrim(SF2->F2_NFELETR)+"&icod="+alltrim(SF2->F2_CODNFE)
	
	ElseIF Alltrim(SM0->M0_CIDCOB)=="MARINGA"
	cLink:= "https://isse.maringa.pr.gov.br/print/nfse/cnpj/"+Alltrim(SM0->M0_CGC)+"/numnfe/"+alltrim(SF2->F2_NFELETR)+"/codval/"+alltrim(SF2->F2_CODNFE)
	
	ElseIf Alltrim(SM0->M0_CIDCOB)=="SAO PAULO"
	cLink:= "https://nfe.prefeitura.sp.gov.br/contribuinte/notaprint.aspx?ccm="+Alltrim(SM0->M0_INSCM)+"&nf="+alltrim(SF2->F2_NFELETR)+"&cod="+alltrim(SF2->F2_CODNFE) 
	
	Elseif Alltrim(SM0->M0_CIDCOB)=="CANOAS"
	//cLink:= "https://www.e-nfs.com.br/e- nfs_canoas/servlet/wvalidarautenticidadenfse?"+Alltrim(SM0->M0_CGC)+","+cValToChar(SF2->F2_VALBRUT)+","+alltrim(SF2->F2_NFELETR)+","+alltrim(SF2->F2_CODNFE)
	//cLink:= "https://www.e-nfs.com.br/enfs_canoas/index.jsp?cnpj="+Alltrim(SM0->M0_CGC)+"&valor=%20%20%20%20%20%20%20%20"+cValToChar(SF2->F2_VALBRUT)+"&numero=%20%20%20%20%20%20%20%20"+alltrim(SF2->F2_NFELETR)+"&autenticidade="+alltrim(SF2->F2_CODNFE) 
	
	cLink:= "https://www.e-nfs.com.br/e-nfs_canoas/index.jsp?cnpj="+Alltrim(SM0->M0_CGC)+"&valor=%20%20%20%20%20%20%20%20"+cValToChar(SF2->F2_VALBRUT)+"&numero=%20%20%20%20%20%20%20%20"+alltrim(SF2->F2_NFELETR)+"&autenticidade="+alltrim(SF2->F2_CODNFE)
	
	
	Elseif Alltrim(SM0->M0_CIDCOB)=="RIO DE JANEIRO" 
	cLink:= "https://notacarioca.rio.gov.br/contribuinte/notaprint.aspx?ccm="+Alltrim(SM0->M0_INSCM)+"&nf="+alltrim(SF2->F2_NFELETR)+"&cod="+alltrim(SF2->F2_CODNFE)
	
	Elseif Alltrim(SM0->M0_CIDCOB)=="FORTALEZA" 
	cLink:="http://iss.fortaleza.ce.gov.br/grpfor/pagesPublic/consultarNota.seam?codigo="+alltrim(SF2->F2_CODNFE)+"&numero="+alltrim(SF2->F2_NFELETR)+"&chave=492573"
	
	Elseif Alltrim(SM0->M0_CIDCOB)=="CURITIBA"  
	cLink:= "http://isscuritiba.curitiba.pr.gov.br/portalnfse/Default.aspx?doc="+Alltrim(SM0->M0_CGC)+"&num="+alltrim(SF2->F2_NFELETR)+"&cod="+alltrim(SF2->F2_CODNFE) 

	Endif
	
	cNomeCli := posicione("SA1",1,xFilial("SA1")+SF2->F2_CLIENTE+SF2->F2_LOJA,"A1_NOME")
	cProcCom := posicione("SC5",1,xFilial("SC5")+cPedido,"C5_ZZPROCE")
	
	//Inicio Montagem Html
	_cHTML:='<HTML><HEAD><TITLE></TITLE>'
	_cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
	_cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
	_cHTML+='<BODY>' 
	_cHTML+= '<img src="cid:ID_cabecalho_email.jpg" height="76" />'
	_cHTML+='<H3>À empresa: '+alltrim(cNomeCli)+'</H3>'
	_cHTML+='<P>Segue anexo boleto bancário e relatório de conferencia referente a NFS-e emitida. E para sua comodidade o link para impressão da NFS-e na Prefeitura.</P>'
	_cHTML+='<P><H3>Dados da cobrança: </H3></P>'
	_cHTML+='<P>Tomador: '+SM0->M0_NOMECOM+'</P>'
	_cHTML+='<P>RPS: '+ SF2->(SF2->F2_DOC) +'</P>'
	_cHTML+='<P>NFS-e: '+ alltrim(SF2->F2_NFELETR) +'</P>'
	_cHTML+='<P>Valor: R$'+transform(SF2->F2_VALBRUT,"@E 999,999,999.99")+'</P>'
	
	if(SF2->F2_FILIAL == "04") //Para filial 04 - Rio de Janeiro o link é enviado junto com os dados para acesso á impressão da RPS.
		_cHTML+='<P>CNPJ Prestador: '+alltrim(SM0->M0_CGC)+'</P>'
		_cHTML+='<P>Código de Verificação: '+alltrim(SF2->F2_CODNFE)+'</P>'
	endif
	
	_cHTML+='<P>Proposta Comercial:'+ alltrim(cProcCom) +'</P>'
	_cHTML+='<P></P>'
	_cHTML+='<P>&nbsp;</P>'
	_cHTML+='<P><A href="'+cLink+'">Clique nesse link para visualizar a Nfs-e</P>'
	
	
	if(empty(cBordero))  //Se o título não estiver em borderô ele entra neste bloco - Raphael Koury Giusti 14/02/2018.
		_cHTML+='<P><i><strong>Caso sua forma de pagamento seja através de depósito em conta,</strong></i></P>'
		_cHTML+='<P><i><strong>segue abaixo os dados bancários para depósito:</strong></i></P>'
		_cHTML+='<P><strong>Banco do Brasil</strong></P>'
		_cHTML+='<P><strong>Agencia:</strong>3149-6</P>'
		_cHTML+='<P><strong>Conta Corrente:</strong>6055-0</P>'
		_cHTML+='<P><strong>CNPJ:</strong>04.830.624/0001-97</P>'
	endif
	_cHTML+='</A></P></BODY></HTML>'

endif

return _cHTML

//-----------------------------------------------
// Função que realiza o envio do e-mail para 
// o cliente.
//-----------------------------------------------
Static Function TEnvMail1(cPara,cAssunto,cMensagem,cArquivo,cArquivo2,cBord,nRecSF2)
	Local cMsg := ""
	Local xRet
	Local lOk := .t.
	Local cImagem := "" 
	// oServer, oMessage
	Local oServer 	:= TMailManager():New()
    Local oMessagle := TMailMessage():New()
	Local lMailAuth	:= .t.//SuperGetMv("MV_RELAUTH",,.T.)
	Local nPorta 	:= 587 //informa a porta que o servidor SMTP irá se comunicar, podendo ser 25 ou 587
 
	//A porta 25, por ser utilizada há mais tempo, possui uma vulnerabilidade maior a 
	//ataques e interceptação de mensagens, além de não exigir autenticação para envio 
	//das mensagens, ao contrário da 587 que oferece esta segurança a mais.
			
	Private cMailConta	:= NIL
	Private cMailServer	:= NIL
	Private cMailSenha	:= NIL
    Private cMailCopia  := NIL
     
   	cMailConta :=If(cMailConta  == NIL,GETMV("MV_CONTAEM"),cMailConta)             //Conta utilizada para envio do email
	cMailServer:=If(cMailServer == NIL,GETMV("MV_RELSER1"),cMailServer)           //Servidor SMTP
	cMailSenha :=If(cMailSenha  == NIL,GETMV("MV_SENHAEM"),cMailSenha)             //Senha da conta de e-mail utilizada para envio
   	oMessage:= TMailMessage():New()
	oMessage:Clear()
    oMessage:cDate	 := cValToChar( Date() )
	oMessage:cFrom 	 := cMailConta
    cMailCopia:=If(cMailCopia == NIL,GETMV("MV_MAILPRF"),cMailCopia)
	oMessage:cTo     := cPara +";"+ cMailCopia  //Parametro para conta de email paralela da Merieux
	oMessage:cSubject:= cAssunto
    oMessage:cBody   := cMensagem
	oMessage:MsgBodyType( "text/html" )  
	
	if(!empty(cBord))
		xRet := oMessage:AttachFile(cArquivo, nil, nil )
		if xRet < 0
			cMsg := "O Boleto " + cArquivo + " não foi anexado!"
			MsgAlert(cMsg,FunName())
			lOk := .f.
			return
		endif
	endif 
	
   	xRet := oMessage:AttachFile( cArquivo2, nil, nil )
	if xRet < 0         
		cMsg := "O Relatorio de Medicoes " + cArquivo2 + " não foi anexado!"
		alert( cMsg )
		lOk := .f.
		return
	endif 

	cImagem:= "\temp\Siga\cabecalho_email.jpg"      //Diretorio Cabecalho
	xRet := oMessage:AttachFile( cImagem )  
	oMessage:AddAttHTag( 'Content-ID:<ID_cabecalho_email.jpg>' )
	if xRet < 0         
	    cMsg := "Imagem " + cImagem + " não foi anexado!"
		alert( cMsg )
		lOk := .f.
		return
	endif
    
	oServer := tMailManager():New()
	oServer:SetUseTLS( .T. ) //Indica se será utilizará a comunicação segura através de SSL/TLS (.T.) ou não (.F.)
   
	xRet := oServer:Init( "", cMailServer, cMailConta, cMailSenha, 0, nPorta ) //inicilizar o servidor
	if xRet != 0
		alert("O servidor SMTP não foi inicializado: " + oServer:GetErrorString( xRet ) )
		lOk := .f.
		return
	endif
   
	xRet := oServer:SetSMTPTimeout( 120 ) //Indica o tempo de espera em segundos.
	if xRet != 0  
		alert("Não foi possível definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
		lOk := .f.
		return
	endif
   
	xRet := oServer:SMTPConnect()
	if xRet <> 0
		alert("Não foi possível conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		lOk := .f.
		return
	endif
   
	if lMailAuth
		//O método SMTPAuth ao tentar realizar a autenticação do 
		//usuário no servidor de e-mail, verifica a configuração 
		//da chave AuthSmtp, na seção [Mail], no arquivo de 
		//configuração (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( cMailConta, cMailSenha )
		if xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			alert( cMsg )
			oServer:SMTPDisconnect()
			lOk := .f.
			return
		endif
   	Endif
	xRet := oMessage:Send( oServer )
	if xRet <> 0  
		alert("Não foi possível enviar mensagem: " + oServer:GetErrorString( xRet ))
		lOk := .f.
		return
	endif
	xRet := oServer:SMTPDisconnect()
	if xRet <> 0
		alert("Não foi possível desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
		lOk := .f.
		return
	endif
	
	if(lOk)
		gravaEnvio(nRecSF2,cPara)
	endif
	
return 


//---------------------------------------
// Realiza a gravação do envio de e-mail 
//---------------------------------------
static function gravaEnvio(nRecSF2, cPara)
local cQrySE1 := ""	
local cFlag   := ""

if(cPara == "Portal")
	cFlag := "P"
else
	cFlag := "S"
endif

	dbSelectArea("SF2")
	dbGoTo(nRecSF2)
	

cQrySE1 += " SELECT " 
cQrySE1 += " 	E1.E1_FILORIG, E1.E1_PREFIXO, E1.E1_NUM, E1.E1_PARCELA, E1.E1_TIPO, E1.E1_ZZEMAI, E1.E1_ZZENVNF, E1.E1_ZZDTEM, E1.R_E_C_N_O_ RECNO "
cQrySE1 += " FROM "+RetSQLName("SE1")+" E1 "
cQrySE1 += " WHERE E1.D_E_L_E_T_ = '' " 
cQrySE1 += " 	AND E1.E1_NUM = '"+SF2->F2_DOC+"' "
cQrySE1 += "	AND E1.E1_CLIENTE = '"+SF2->F2_CLIENTE+"' "
cQrySE1 += "	AND E1.E1_LOJA = '"+SF2->F2_LOJA+"' "
cQrySE1 += "	AND E1.E1_TIPO = 'NF' "
cQrySE1 += "	AND E1.E1_FILORIG = '"+SF2->F2_FILIAL+"' "

memowrite("c:\QUERY\QSE1.sql",cQrySE1)

 	if select('QRYSE1') <> 0
		QRYSE1->(dbCloseArea())
	endIf

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQrySE1),'QRYSE1',.F.,.T.)

	dbSelectArea("SE1")
	
	while QRYSE1->(!eof())
		SE1->(dbGoTo(QRYSE1->RECNO))
		recLock("SE1",.F.)
			SE1->E1_ZZENVNF := cFlag //Atualiza campo de envio.
			SE1->E1_ZZDTEM	:= date()
		msUnLock("SE1") 
		QRYSE1->(DbSkip())  
	enddo
	SE1->(dbCloseArea())		
return

//----------------------------
// Função que cria a legenda.
//----------------------------
static function legenda()
	BrwLegenda("", "Legenda", {	{"BR_VERDE"   	,"E-mail enviado" 		},;							
							    {"BR_AZUL"	    ,"Portal"				},;
								{"BR_VERMELHO"	,"E-mail não enviado"	}})
return

//|-------------------------------------|
//| Função de validação das perguntas  	|
//|-------------------------------------|
static Function fValidPerg(cPerg)
	Local _sAlias := Alias()
	Local aRegs   := {}
	Local i,j
	
	//|----------------------------------------------|
	//| Variaveis utilizadas para parametros   		 |
	//| mv_par01               Cliente de      		 |
	//| mv_par02               Cliente até     		 |
	//| mv_par03               RPS de    		 	 |
	//| mv_par04               RPS ate  		 	 |
	//| mv_par05               Serie RPS 			 |
	//| mv_par06               Emissao de 			 |
	//| mv_par07               Emissao até			 |
	//|----------------------------------------------|
	
	dbSelectArea("SX1")
	dbSetOrder(1)
	
	cPerg := PADR(cPerg,Len(SX1->X1_GRUPO))
	
	// Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs, {cPerg, "01", "Filial de :  "   ,""  ,"" , "mv_ch1", "C"  ,TamSx3("F2_FILIAL")[1]  	 , 0, 0, "G","", "mv_par01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0"})
	aAdd(aRegs, {cPerg, "02", "Filial até :  "  ,""  ,"" , "mv_ch2", "C"  ,TamSx3("F2_FILIAL")[1]  	 , 0, 0, "G","", "mv_par02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SM0"})
	aAdd(aRegs, {cPerg, "03" ,"Filtra emitidos?",""	 ,"" , "mv_ch3", "N"  ,1						 , 0, 0, "C","", "mv_par03","Todos","","","","","Enviados","","","","","Não enviados","","","","","Portal","","","","","","","","","",""})
	aAdd(aRegs, {cPerg, "04", "Cliente de :  "  ,""  ,"" , "mv_ch4", "C"  ,TamSx3("A1_COD")[1]  	 , 0, 0, "G","", "mv_par04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1"})
	aAdd(aRegs, {cPerg, "05", "Cliente até:  "  ,""  ,"" , "mv_ch5", "C"  ,TamSx3("A1_COD")[1]  	 , 0, 0, "G","", "mv_par05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SA1"})
	aAdd(aRegs, {cPerg, "06", "RPS de: "  		,""  ,"" , "mv_ch6", "C"  ,TamSx3("F2_DOC")[1]  	 , 0, 0, "G","", "mv_par06", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF2"})
	aAdd(aRegs, {cPerg, "07", "RPS até:" 		,""  ,"" , "mv_ch7", "C"  ,TamSx3("F2_DOC")[1] 		 , 0, 0, "G","", "mv_par07", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "SF2"})
	aAdd(aRegs, {cPerg, "08", "Série RPS:" 		,""  ,"" , "mv_ch8", "C"  ,TamSx3("F2_SERIE")[1]	 , 0, 0, "G","", "mv_par08", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
	aAdd(aRegs, {cPerg, "09", "Emissão de:"     ,""  ,"" , "mv_ch9", "D"  ,TamSx3("F2_EMISSAO")[1]	 , 0, 0, "G","", "mv_par09", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
	aAdd(aRegs, {cPerg, "10", "Emissão até:"    ,""  ,"" , "mv_cha", "D"  ,TamSx3("F2_EMISSAO")[1]	 , 0, 0, "G","", "mv_par10", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
	aAdd(aRegs, {cPerg, "11", "Driver:"         ,""  ,"" , "mv_chb", "C"  ,2						 , 0, 0, "G","", "mv_par11", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", ""})
	aAdd(aRegs, {cPerg, "12" ,"Altera e-mail?"	,""	 ,"" , "mv_chc", "N"  ,1						 , 0, 0, "C","", "mv_par12","Sim","","","","","Nao","","","","","","","","","","","","","","","","","","","",""})
	
	
	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next
	
	dbSelectArea(_sAlias)  
Return .T.     


