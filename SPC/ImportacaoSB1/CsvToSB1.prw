//Bibliotecas
#Include "TOTVS.ch"
#Include "TopConn.ch"

#Define STR_PULA    Chr(13)+Chr(10)

/*/{Protheus.doc} CsvToSB1
Função para gravar dados de CSV para CsvToSB1
@author Vanderlei
@since 26/07/2024
@version 1.0
@type function
/*/
User Function CsvToSB1()
	Local aArea     := GetArea()

	Private cArqOri := ""

	//Mostra o Prompt para selecionar arquivos
	cArqOri := tFileDialog( "CSV files (*.csv) ", 'Seleção de Arquivos', , , .F., )

	//Se tiver o arquivo de origem
	If ! Empty(cArqOri)

		//Somente se existir o arquivo e for com a extensão CSV
		If File(cArqOri) .And. Upper(SubStr(cArqOri, RAt('.', cArqOri) + 1, 3)) == 'CSV'
			Processa({|| fImpCsv() }, "Importando...")
		Else
			MsgStop("Arquivo e/ou extensão inválida!", "Atenção")
		EndIf
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fImpCsv                                                               |
 | Desc:  Função que importa os dados                                            |
 *-------------------------------------------------------------------------------*/
 
Static Function fImpCsv()
    Local aArea      := GetArea()
    Local nTotLinhas := 0
    Local cLinAtu    := ""
    Local nLinhaAtu  := 0
    Local aLinha     := {}
    Local aCols      := {}
    Local oArquivo
    Local aLinhas

    //Definindo o arquivo a ser lido
    oArquivo := FWFileReader():New(cArqOri)
     
    //Se o arquivo pode ser aberto
    If (oArquivo:Open())
 
        //Se não for fim do arquivo
        If ! (oArquivo:EoF())
 
            //Definindo o tamanho da régua
            aLinhas := oArquivo:GetAllLines()
            nTotLinhas := Len(aLinhas)
            ProcRegua(nTotLinhas)
             
            //Método GoTop não funciona (dependendo da versão da LIB), deve fechar e abrir novamente o arquivo
            oArquivo:Close()
            oArquivo := FWFileReader():New(cArqOri)
            oArquivo:Open()

            //Enquanto tiver linhas
            While (oArquivo:HasLine())
                aCols := {}
                //Incrementa na tela a mensagem
                nLinhaAtu++

                IncProc("Analisando linha " + cValToChar(nLinhaAtu) + " de " + cValToChar(nTotLinhas) + "...")
                 
                //Pegando a linha atual e transformando em array
                cLinAtu := oArquivo:GetLine()
                aLinha  := StrTokArr2(cLinAtu, ";", .T. )

                If nLinhaAtu >= 4 .AND. nLinhaAtu <= 2606

                    aadd(aCols, aLinha[1] )
                    aadd(aCols, aLinha[2] )
                    aadd(aCols, aLinha[3] )
                    aadd(aCols, aLinha[4] )
                    aadd(aCols, aLinha[5] )
                    aadd(aCols, aLinha[6] )
                    aadd(aCols, aLinha[7] )
                    aadd(aCols, aLinha[8] )
                    aadd(aCols, aLinha[9]   := fStrToNum(aLinha[9]) )
                    aadd(aCols, aLinha[10]  := fStrToNum(aLinha[10]) )
                    aadd(aCols, aLinha[11] )
                    aadd(aCols, aLinha[12] )
                    aadd(aCols, aLinha[13] )
                    aadd(aCols, aLinha[14] )
                    aadd(aCols, aLinha[15]  := fStrToNum(aLinha[15]) )
                    aadd(aCols, aLinha[16] )
                    aadd(aCols, aLinha[17] )
                    aadd(aCols, aLinha[18] )
                    aadd(aCols, aLinha[19]  := fStrToNum(aLinha[19]) )
                    aadd(aCols, aLinha[20]  := fStrToNum(aLinha[20]) )
                    aadd(aCols, aLinha[21] )
                    aadd(aCols, aLinha[22] )
                    aadd(aCols, aLinha[23] )
                    aadd(aCols, aLinha[24]  := fStrToNum(aLinha[24]) )
                    aadd(aCols, aLinha[25] )
                    aadd(aCols, aLinha[26] )
                    aadd(aCols, aLinha[27]  := fStrToNum(aLinha[27]) )
                    aadd(aCols, aLinha[28]  := fStrToNum(aLinha[28]) )
                    aadd(aCols, aLinha[29]  := fStrToNum(aLinha[29]) )
                    aadd(aCols, aLinha[30]  := fStrToNum(aLinha[30]) )
                    aadd(aCols, aLinha[31] )
                    aadd(aCols, aLinha[32]  := fStrToNum(aLinha[32]) )
                    aadd(aCols, CTOD(aLinha[33]) )
                    aadd(aCols, aLinha[34]  := fStrToNum(aLinha[34]) )
                    aadd(aCols, aLinha[35]  := fStrToNum(aLinha[35]) )
                    aadd(aCols, CTOD(aLinha[36]) )
                    aadd(aCols, aLinha[37] )
                    aadd(aCols, aLinha[38] )
                    aadd(aCols, aLinha[39]  := fStrToNum(aLinha[39]) )
                    aadd(aCols, aLinha[40] )
                    aadd(aCols, aLinha[41]  := fStrToNum(aLinha[41]) )
                    aadd(aCols, aLinha[42]  := fStrToNum(aLinha[42]) )
                    aadd(aCols, aLinha[43] )
                    aadd(aCols, aLinha[44] )
                    aadd(aCols, aLinha[45]  := fStrToNum(aLinha[45]) )
                    aadd(aCols, aLinha[46] )
                    aadd(aCols, aLinha[47] )
                    aadd(aCols, aLinha[48] )
                    aadd(aCols, aLinha[49] )
                    aadd(aCols, aLinha[50]  := fStrToNum(aLinha[50]) )
                    aadd(aCols, aLinha[51] )
                    aadd(aCols, aLinha[52] )
                    aadd(aCols, aLinha[53] )
                    aadd(aCols, aLinha[54] )
                    aadd(aCols, aLinha[55] )
                    aadd(aCols, aLinha[56] )
                    aadd(aCols, aLinha[57] )
                    aadd(aCols, CTOD(aLinha[58]) )
                    aadd(aCols, aLinha[59]  := fStrToNum(aLinha[59]) )
                    aadd(aCols, CTOD(aLinha[60]) )
                    aadd(aCols, aLinha[61] )
                    aadd(aCols, aLinha[62] )
                    aadd(aCols, aLinha[63]  := fStrToNum(aLinha[63]) )
                    aadd(aCols, aLinha[64] )
                    aadd(aCols, CTOD(aLinha[65]) )
                    aadd(aCols, aLinha[66]  := fStrToNum(aLinha[66]) )
                    aadd(aCols, aLinha[67]  := fStrToNum(aLinha[67]) )
                    aadd(aCols, aLinha[68]  := fStrToNum(aLinha[68]) )
                    aadd(aCols, aLinha[69] )
                    aadd(aCols, aLinha[70] )
                    aadd(aCols, CTOD(aLinha[71]) )
                    aadd(aCols, aLinha[72] )
                    aadd(aCols, aLinha[73] )
                    aadd(aCols, aLinha[74] )
                    aadd(aCols, aLinha[75] )
                    aadd(aCols, aLinha[76] )
                    aadd(aCols, aLinha[77] )
                    aadd(aCols, aLinha[78] )
                    aadd(aCols, aLinha[79] )
                    aadd(aCols, aLinha[80] )
                    aadd(aCols, aLinha[81] )
                    aadd(aCols, aLinha[82]  := fStrToNum(aLinha[82]) )
                    aadd(aCols, aLinha[83] )
                    aadd(aCols, aLinha[84] )
                    aadd(aCols, aLinha[85] )
                    aadd(aCols, aLinha[86] )
                    aadd(aCols, aLinha[87] )
                    aadd(aCols, aLinha[88] )
                    aadd(aCols, aLinha[89] )
                    aadd(aCols, aLinha[90] )
                    aadd(aCols, aLinha[91] )
                    aadd(aCols, aLinha[92] )
                    aadd(aCols, aLinha[93] )
                    aadd(aCols, aLinha[94] )
                    aadd(aCols, aLinha[95] )
                    aadd(aCols, aLinha[96] )
                    aadd(aCols, aLinha[97]  := fStrToNum(aLinha[97]) )
                    aadd(aCols, aLinha[98]  := fStrToNum(aLinha[98]) )
                    aadd(aCols, aLinha[99] )
                    aadd(aCols, aLinha[100] )
                    aadd(aCols, aLinha[101] )
                    aadd(aCols, aLinha[102] )
                    aadd(aCols, aLinha[103] )
                    aadd(aCols, aLinha[104]  := fStrToNum(aLinha[104]) )
                    aadd(aCols, aLinha[105] )
                    aadd(aCols, aLinha[106] )
                    aadd(aCols, aLinha[107] )
                    aadd(aCols, aLinha[108]  := fStrToNum(aLinha[108]) )
                    aadd(aCols, aLinha[109] )
                    aadd(aCols, aLinha[110] )
                    aadd(aCols, aLinha[111]  := fStrToNum(aLinha[111]) )
                    aadd(aCols, aLinha[112]  := fStrToNum(aLinha[112]) )
                    aadd(aCols, aLinha[113]  := fStrToNum(aLinha[113]) )
                    aadd(aCols, aLinha[114]  := fStrToNum(aLinha[114]) )
                    aadd(aCols, aLinha[115]  := fStrToNum(aLinha[115]) )
                    aadd(aCols, aLinha[116] )
                    aadd(aCols, aLinha[117] )
                    aadd(aCols, CTOD(aLinha[118]) )
                    aadd(aCols, aLinha[119] )
                    aadd(aCols, aLinha[120]  := fStrToNum(aLinha[120]) )
                    aadd(aCols, aLinha[121]  := fStrToNum(aLinha[121]) )
                    aadd(aCols, aLinha[122] )
                    aadd(aCols, aLinha[123] )
                    aadd(aCols, aLinha[124] )
                    aadd(aCols, aLinha[125]  := fStrToNum(aLinha[125]) )
                    aadd(aCols, aLinha[126]  := fStrToNum(aLinha[126]) )
                    aadd(aCols, aLinha[127] )
                    aadd(aCols, aLinha[128] )
                    aadd(aCols, aLinha[129] )
                    aadd(aCols, aLinha[130] )
                    aadd(aCols, aLinha[131] )
                    aadd(aCols, aLinha[132] )
                    aadd(aCols, aLinha[133] )
                    aadd(aCols, aLinha[134]  := fStrToNum(aLinha[134]) )
                    aadd(aCols, aLinha[135] )
                    aadd(aCols, aLinha[136]  := fStrToNum(aLinha[136]) )
                    aadd(aCols, aLinha[137]  := fStrToNum(aLinha[137]) )
                    aadd(aCols, aLinha[138] )
                    aadd(aCols, aLinha[139] )
                    aadd(aCols, aLinha[140] )
                    aadd(aCols, aLinha[141] )
                    aadd(aCols, aLinha[142] )
                    aadd(aCols, aLinha[143] )
                    aadd(aCols, aLinha[144] )
                    aadd(aCols, aLinha[145] )
                    aadd(aCols, aLinha[146] )
                    aadd(aCols, aLinha[147] )
                    aadd(aCols, aLinha[148] )
                    aadd(aCols, aLinha[149] )
                    aadd(aCols, aLinha[150]  := fStrToNum(aLinha[150]) )
                    aadd(aCols, aLinha[151]  := fStrToNum(aLinha[151]) )
                    aadd(aCols, aLinha[152]  := fStrToNum(aLinha[152]) )
                    aadd(aCols, aLinha[153] )
                    aadd(aCols, aLinha[154] )
                    aadd(aCols, aLinha[155] )
                    aadd(aCols, aLinha[156] )
                    aadd(aCols, aLinha[157] )
                    aadd(aCols, aLinha[158]  := fStrToNum(aLinha[158]) )
                    aadd(aCols, aLinha[159]  := fStrToNum(aLinha[159]) )
                    aadd(aCols, aLinha[160]  := fStrToNum(aLinha[160]) )
                    aadd(aCols, aLinha[161]  := fStrToNum(aLinha[161]) )
                    aadd(aCols, aLinha[162]  := fStrToNum(aLinha[162]) )
                    aadd(aCols, aLinha[163] )
                    aadd(aCols, aLinha[164]  := fStrToNum(aLinha[164]) )
                    aadd(aCols, aLinha[165] )
                    aadd(aCols, aLinha[166] )
                    aadd(aCols, aLinha[167] )
                    aadd(aCols, aLinha[168]  := fStrToNum(aLinha[168]) )
                    aadd(aCols, aLinha[169]  := fStrToNum(aLinha[169]) )
                    aadd(aCols, aLinha[170]  := fStrToNum(aLinha[170]) )
                    aadd(aCols, aLinha[171] )
                    aadd(aCols, aLinha[172] )
                    aadd(aCols, aLinha[173] )
                    aadd(aCols, aLinha[174] )
                    aadd(aCols, aLinha[175] )
                    aadd(aCols, aLinha[176]  := fStrToNum(aLinha[176]) )
                    aadd(aCols, aLinha[177]  := fStrToNum(aLinha[177]) )
                    aadd(aCols, aLinha[178] )
                    aadd(aCols, aLinha[179]  := fStrToNum(aLinha[179]) )
                    aadd(aCols, aLinha[180]  := fStrToNum(aLinha[180]) )
                    aadd(aCols, aLinha[181]  := fStrToNum(aLinha[181]) )
                    aadd(aCols, aLinha[182] )
                    aadd(aCols, aLinha[183] )
                    aadd(aCols, aLinha[184] )
                    aadd(aCols, aLinha[185] )
                    aadd(aCols, aLinha[186]  := fStrToNum(aLinha[186]) )
                    aadd(aCols, aLinha[187]  := fStrToNum(aLinha[187]) )
                    aadd(aCols, aLinha[188] )
                    aadd(aCols, aLinha[189] )
                    aadd(aCols, aLinha[190] )
                    aadd(aCols, aLinha[191] )
                    aadd(aCols, aLinha[192]  := fStrToNum(aLinha[192]) )
                    aadd(aCols, aLinha[193]  := fStrToNum(aLinha[193]) )
                    aadd(aCols, aLinha[194]  := fStrToNum(aLinha[194]) )
                    aadd(aCols, aLinha[195] )
                    aadd(aCols, aLinha[196]  := fStrToNum(aLinha[196]) )
                    aadd(aCols, aLinha[197] )
                    aadd(aCols, aLinha[198] )
                    aadd(aCols, aLinha[199] )
                    aadd(aCols, CTOD(aLinha[200]) )
                    aadd(aCols, CTOD(aLinha[201]) )
                    aadd(aCols, aLinha[202]  := fStrToNum(aLinha[202]) )
                    aadd(aCols, aLinha[203]  := fStrToNum(aLinha[203]) )
                    aadd(aCols, aLinha[204]  := fStrToNum(aLinha[204]) )
                    aadd(aCols, aLinha[205]  := fStrToNum(aLinha[205]) )
                    aadd(aCols, aLinha[206] )
                    aadd(aCols, aLinha[207] )
                    aadd(aCols, aLinha[208] )
                    aadd(aCols, aLinha[209] )
                    aadd(aCols, aLinha[210]  := fStrToNum(aLinha[210]) )
                    aadd(aCols, aLinha[211] )
                    aadd(aCols, aLinha[212] )
                    aadd(aCols, aLinha[213] )
                    aadd(aCols, aLinha[214] )
                    aadd(aCols, aLinha[215] )
                    aadd(aCols, aLinha[216] )
                    aadd(aCols, aLinha[217] )
                    aadd(aCols, aLinha[218] )
                    aadd(aCols, aLinha[219] )
                    aadd(aCols, aLinha[220] )
                    aadd(aCols, aLinha[221] )
                    aadd(aCols, aLinha[222]  := fStrToNum(aLinha[222]) )
                    aadd(aCols, aLinha[223] )
                    aadd(aCols, aLinha[224] )
                    aadd(aCols, aLinha[225] )
                    aadd(aCols, CTOD(aLinha[226]) )
                    aadd(aCols, aLinha[227]  := fStrToNum(aLinha[227]) )
                    aadd(aCols, aLinha[228] )
                    aadd(aCols, aLinha[229] )
                    aadd(aCols, aLinha[230] )
                    aadd(aCols, aLinha[231] )
                    aadd(aCols, aLinha[232] )
                    aadd(aCols, aLinha[233]  := fStrToNum(aLinha[233]) )
                    aadd(aCols, aLinha[234]  := fStrToNum(aLinha[234]) )
                    aadd(aCols, aLinha[235]  := fStrToNum(aLinha[235]) )
                    aadd(aCols, aLinha[236]  := fStrToNum(aLinha[236]) )
                    aadd(aCols, aLinha[237] )
                    aadd(aCols, aLinha[238] )
                    aadd(aCols, aLinha[239] )
                    aadd(aCols, aLinha[240] )
                    aadd(aCols, aLinha[241] )
                    aadd(aCols, aLinha[242] )
                    aadd(aCols, aLinha[243] )
                    aadd(aCols, aLinha[244] )
                    aadd(aCols, aLinha[245] )
                    aadd(aCols, aLinha[246] )
                    aadd(aCols, aLinha[247]  := fStrToNum(aLinha[247]) )
                    aadd(aCols, aLinha[248]  := fStrToNum(aLinha[248]) )
                    aadd(aCols, aLinha[249] )
                    aadd(aCols, aLinha[250] )
                    aadd(aCols, aLinha[251]  := fStrToNum(aLinha[251]) )
                    aadd(aCols, aLinha[252] )
                    aadd(aCols, aLinha[253] )
                    aadd(aCols, aLinha[254] )
                    aadd(aCols, aLinha[255] )
                    aadd(aCols, aLinha[256] )
                    aadd(aCols, aLinha[257] )
                    aadd(aCols, aLinha[258] )
                    aadd(aCols, aLinha[259] )
                    aadd(aCols, aLinha[260]  := fStrToNum(aLinha[260]) )
                    aadd(aCols, aLinha[261] )
                    aadd(aCols, aLinha[262] )
                    aadd(aCols, aLinha[263] )
                    aadd(aCols, aLinha[264] )
                    aadd(aCols, aLinha[265] )
                    aadd(aCols, aLinha[266] := fStrToNum(aLinha[266]) )
                    aadd(aCols, aLinha[267] )
                    aadd(aCols, aLinha[268] )
                    aadd(aCols, aLinha[269] )
                    aadd(aCols, aLinha[270] )
                    aadd(aCols, aLinha[271] )
                    aadd(aCols, aLinha[272] )
                    aadd(aCols, aLinha[273] )
                    aadd(aCols, aLinha[274] )
                    aadd(aCols, aLinha[275] )
                    aadd(aCols, aLinha[276] )
                    aadd(aCols, aLinha[277]  := fStrToNum(aLinha[277]) )
                    aadd(aCols, aLinha[278]  := fStrToNum(aLinha[278]) )
                    aadd(aCols, aLinha[279]  := fStrToNum(aLinha[279]) )
                    aadd(aCols, aLinha[280] )
                    aadd(aCols, aLinha[281] )
                    aadd(aCols, aLinha[282] )
                    aadd(aCols, aLinha[283] )
                    aadd(aCols, aLinha[284] )
                    aadd(aCols, aLinha[285]  := fStrToNum(aLinha[285]) )
                    aadd(aCols, aLinha[286] )
                    aadd(aCols, aLinha[287] )
                    aadd(aCols, aLinha[288] )
                    aadd(aCols, aLinha[289] )
                    aadd(aCols, CTOD(aLinha[290]) )   
                    aadd(aCols, aLinha[291] )              

                    GravSB1(aCols)
          
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
 
    RestArea(aArea)
Return


/*---------------------------------------------------------------------*
 | Func:  GravSB1                                                      |
 | Desc:  Função que grava Dados na SB1                                |
 *---------------------------------------------------------------------*/
 
Static Function GravSB1(_aCols)

    DbSelectArea("SB1")
    RecLock("SB1", .T.)	

    SB1->B1_AFAMAD  := _aCols[266]
    SB1->B1_FILIAL  := _aCols[1]
    SB1->B1_COD     := _aCols[2]
    SB1->B1_DESC    := _aCols[3]
    SB1->B1_TIPO    := _aCols[4]
    SB1->B1_CODITE  := _aCols[5]
    SB1->B1_UM      := _aCols[6]
    SB1->B1_LOCPAD  := _aCols[7]
    SB1->B1_GRUPO   := _aCols[8]
    SB1->B1_PICM    := _aCols[9]
    SB1->B1_IPI     := _aCols[10]
    SB1->B1_POSIPI  := _aCols[11]
    SB1->B1_ESPECIE := _aCols[12]
    SB1->B1_EX_NCM  := _aCols[13]
    SB1->B1_EX_NBM  := _aCols[14]
    SB1->B1_ALIQISS := _aCols[15]
    SB1->B1_CODISS  := _aCols[16]
    SB1->B1_TE      := _aCols[17]
    SB1->B1_TS      := _aCols[18]
    SB1->B1_PICMRET := _aCols[19]
    SB1->B1_PICMENT := _aCols[20]
    SB1->B1_IMPZFRC := _aCols[21]
    SB1->B1_BITMAP  := _aCols[22]
    SB1->B1_SEGUM   := _aCols[23]
    SB1->B1_CONV    := _aCols[24]
    SB1->B1_TIPCONV := _aCols[25]
    SB1->B1_ALTER   := _aCols[26]
    SB1->B1_QE      := _aCols[27]
    SB1->B1_PRV1    := _aCols[28]
    SB1->B1_EMIN    := _aCols[29]
    SB1->B1_CUSTD   := _aCols[30]
    SB1->B1_UCALSTD := _aCols[33]
    SB1->B1_UPRC    := _aCols[32]
    SB1->B1_MCUSTD  := _aCols[31]
    SB1->B1_UCOM    := _aCols[36]
    SB1->B1_PESO    := _aCols[34]
    SB1->B1_ESTSEG  := _aCols[35]
    SB1->B1_ESTFOR  := _aCols[37]
    SB1->B1_FORPRZ  := _aCols[38]
    SB1->B1_PE      := _aCols[39]
    SB1->B1_TIPE    := _aCols[40]
    SB1->B1_LE      := _aCols[41]
    SB1->B1_LM      := _aCols[42]
    SB1->B1_CONTA   := _aCols[43]
    SB1->B1_TOLER   := _aCols[45]
    SB1->B1_CC      := _aCols[44]
    SB1->B1_ITEMCC  := _aCols[46]
    SB1->B1_FAMILIA := _aCols[47]
    SB1->B1_QB      := _aCols[50]
    SB1->B1_PROC    := _aCols[48]
    SB1->B1_LOJPROC := _aCols[49]
    SB1->B1_APROPRI := _aCols[51]
    SB1->B1_TIPODEC := _aCols[53]
    SB1->B1_ORIGEM  := _aCols[54]
    SB1->B1_CLASFIS := _aCols[55]
    SB1->B1_FANTASM := _aCols[52]
    SB1->B1_RASTRO  := _aCols[56]
    SB1->B1_UREV    := _aCols[58]
    SB1->B1_DATREF  := _aCols[60]
    SB1->B1_FORAEST := _aCols[57]
    SB1->B1_COMIS   := _aCols[59]
    SB1->B1_MONO    := _aCols[61]
    SB1->B1_PERINV  := _aCols[63]
    SB1->B1_DTREFP1 := _aCols[65]
    SB1->B1_GRTRIB  := _aCols[64]
    SB1->B1_MRP     := _aCols[62]
    SB1->B1_NOTAMIN := _aCols[66]
    SB1->B1_PRVALID := _aCols[67]
    SB1->B1_NUMCOP  := _aCols[68]
    SB1->B1_CONINI  := _aCols[71]
    SB1->B1_CONTSOC := _aCols[69]
    SB1->B1_IRRF    := _aCols[70]
    SB1->B1_CODBAR  := _aCols[72]
    SB1->B1_GRADE   := _aCols[73]
    SB1->B1_CODGTIN := _aCols[286]
    SB1->B1_FORMLOT := _aCols[74]
    SB1->B1_LOCALIZ := _aCols[75]
    SB1->B1_FPCOD   := _aCols[76]
    SB1->B1_OPERPAD := _aCols[77]
    SB1->B1_DESC_P  := _aCols[79]
    SB1->B1_CONTRAT := _aCols[78]
    SB1->B1_DESC_GI := _aCols[80]
    SB1->B1_DESC_I  := _aCols[81]
    SB1->B1_VLREFUS := _aCols[82]
    SB1->B1_IMPORT  := _aCols[83]
    // SB1->B1_VM_I    := _aCols[]
    // SB1->B1_VM_GI   := _aCols[]
    // SB1->B1_VM_P    := _aCols[]
    SB1->B1_ANUENTE := _aCols[85]
    SB1->B1_OPC     := _aCols[84]
    SB1->B1_CODOBS  := _aCols[86]
    SB1->B1_SITPROD := _aCols[87]
    // SB1->B1_OBS     := _aCols[]
    SB1->B1_FABRIC  := _aCols[88]
    SB1->B1_MODELO  := _aCols[89]
    SB1->B1_SETOR   := _aCols[90]
    SB1->B1_BALANCA := _aCols[91]
    SB1->B1_TECLA   := _aCols[92]
    SB1->B1_PRODPAI := _aCols[93]
    SB1->B1_TIPOCQ  := _aCols[94]
    SB1->B1_SOLICIT := _aCols[95]
    SB1->B1_DESPIMP := _aCols[173]
    SB1->B1_GRUPCOM := _aCols[96]
    SB1->B1_QUADPRO := _aCols[157]
    SB1->B1_BASE3   := _aCols[240]
    SB1->B1_DESBSE3 := _aCols[239]
    SB1->B1_AGREGCU := _aCols[156]
    SB1->B1_NUMCQPR := _aCols[97]
    SB1->B1_CONTCQP := _aCols[98]
    SB1->B1_REVATU  := _aCols[99]
    SB1->B1_CODEMB  := _aCols[101]
    SB1->B1_INSS    := _aCols[100]
    SB1->B1_ESPECIF := _aCols[102]
    SB1->B1_MAT_PRI := _aCols[103]
    SB1->B1_REDINSS := _aCols[104]
    SB1->B1_NALNCCA := _aCols[105]
    SB1->B1_REDIRRF := _aCols[108]
    SB1->B1_NALSH   := _aCols[107]
    SB1->B1_ALADI   := _aCols[106]
    SB1->B1_TAB_IPI := _aCols[109]
    SB1->B1_GRUDES  := _aCols[110]
    SB1->B1_REDPIS  := _aCols[158]
    SB1->B1_REDCOF  := _aCols[159]
    SB1->B1_DATASUB := _aCols[118]
    SB1->B1_PCSLL   := _aCols[111]
    SB1->B1_PCOFINS := _aCols[112]
    SB1->B1_PPIS    := _aCols[113]
    SB1->B1_MTBF    := _aCols[114]
    SB1->B1_MTTR    := _aCols[115]
    SB1->B1_FLAGSUG := _aCols[116]
    SB1->B1_CLASSVE := _aCols[117]
    SB1->B1_MIDIA   := _aCols[119]
    SB1->B1_QTMIDIA := _aCols[120]
    SB1->B1_VLR_IPI := _aCols[121]
    SB1->B1_ENVOBR  := _aCols[122]
    SB1->B1_QTDSER  := _aCols[123]
    SB1->B1_SERIE   := _aCols[124]
    SB1->B1_FAIXAS  := _aCols[125]
    SB1->B1_NROPAG  := _aCols[126]
    SB1->B1_ISBN    := _aCols[127]
    SB1->B1_TITORIG := _aCols[128]
    SB1->B1_LINGUA  := _aCols[129]
    SB1->B1_EDICAO  := _aCols[130]
    SB1->B1_OBSISBN := _aCols[131]
    SB1->B1_CLVL    := _aCols[132]
    SB1->B1_ATIVO   := _aCols[133]
    SB1->B1_EMAX    := _aCols[160]
    SB1->B1_PESBRU  := _aCols[134]
    SB1->B1_TIPCAR  := _aCols[135]
    SB1->B1_FRACPER := _aCols[161]
    SB1->B1_VLR_ICM := _aCols[136]
    SB1->B1_INT_ICM := _aCols[162]
    SB1->B1_VLRSELO := _aCols[137]
    SB1->B1_CODNOR  := _aCols[138]
    SB1->B1_CORPRI  := _aCols[139]
    SB1->B1_CORSEC  := _aCols[140]
    SB1->B1_NICONE  := _aCols[141]
    SB1->B1_ATRIB1  := _aCols[142]
    SB1->B1_ATRIB2  := _aCols[143]
    SB1->B1_ATRIB3  := _aCols[144]
    SB1->B1_REGSEQ  := _aCols[145]
    SB1->B1_CPOTENC := _aCols[149]
    SB1->B1_POTENCI := _aCols[150]
    SB1->B1_QTDACUM := _aCols[151]
    SB1->B1_QTDINIC := _aCols[152]
    SB1->B1_REQUIS  := _aCols[153]
    SB1->B1_SELO    := _aCols[163]
    SB1->B1_LOTVEN  := _aCols[164]
    SB1->B1_OK      := _aCols[165]
    SB1->B1_USAFEFO := _aCols[166]
    SB1->B1_IAT     := _aCols[241]
    SB1->B1_IPPT    := _aCols[242]
    SB1->B1_CNATREC := _aCols[191]
    SB1->B1_TNATREC := _aCols[190]
    SB1->B1_AFASEMT := _aCols[279]
    SB1->B1_AIMAMT  := _aCols[278]
    SB1->B1_TERUM   := _aCols[280]
    SB1->B1_AFUNDES := _aCols[277]
    SB1->B1_CEST    := _aCols[276]
    SB1->B1_GRPCST  := _aCols[275]
    // SB1->B1_GRPTIDC := _aCols[]
    SB1->B1_GRPNATR := _aCols[225]
    SB1->B1_DTFIMNT := _aCols[226]
    SB1->B1_FECP    := _aCols[192]
    SB1->B1_MARKUP  := _aCols[248]
    SB1->B1_DTCORTE := _aCols[201]
    SB1->B1_CODPROC := _aCols[245]
    SB1->B1_LOTESBP := _aCols[251]
    SB1->B1_QBP     := _aCols[179]
    SB1->B1_VALEPRE := _aCols[250]
    SB1->B1_CODQAD  := _aCols[178]
    SB1->B1_PMACNUT := _aCols[176]
    SB1->B1_PMICNUT := _aCols[177]
    SB1->B1_AFABOV  := _aCols[205]
    SB1->B1_VIGENC  := _aCols[200]
    SB1->B1_VEREAN  := _aCols[213]
    SB1->B1_DIFCNAE := _aCols[229]
    SB1->B1_ESCRIPI := _aCols[218]
    SB1->B1_INTEG   := _aCols[281]
    SB1->B1_USERLGI := _aCols[282]
    SB1->B1_USERLGA := _aCols[283]
    SB1->B1_HREXPO  := _aCols[284]
    SB1->B1_CRICMS  := _aCols[197]
    SB1->B1_REFBAS  := _aCols[207]
    // SB1->B1_MOPC    := _aCols[]
    SB1->B1_UMOEC   := _aCols[168]
    SB1->B1_UVLRC   := _aCols[169]
    SB1->B1_PIS     := _aCols[146]
    SB1->B1_GCCUSTO := _aCols[174]
    SB1->B1_CCCUSTO := _aCols[175]
    SB1->B1_TALLA   := _aCols[243]
    SB1->B1_PARCEI  := _aCols[172]
    SB1->B1_GDODIF  := _aCols[246]
    SB1->B1_VLR_PIS := _aCols[180]
    SB1->B1_TIPOBN  := _aCols[252]
    SB1->B1_VLCIF   := _aCols[247]
    SB1->B1_TPPROD  := _aCols[208]
    SB1->B1_TPREG   := _aCols[212]
    SB1->B1_MSBLQL  := _aCols[155]
    // SB1->B1_VM_PROC := _aCols[]
    SB1->B1_DCRE    := _aCols[231]
    SB1->B1_DCR     := _aCols[232]
    SB1->B1_DCRII   := _aCols[233]
    SB1->B1_FUSTF   := _aCols[215]
    SB1->B1_DCI     := _aCols[230]
    SB1->B1_COEFDCR := _aCols[234]
    SB1->B1_CHASSI  := _aCols[211]
    SB1->B1_CLASSE  := _aCols[167]
    SB1->B1_APOPRO  := _aCols[291]
    SB1->B1_PRODSBP := _aCols[249]
    SB1->B1_GRPTI   := _aCols[274]
    SB1->B1_PRDORI  := _aCols[217]
    SB1->B1_CODANT  := _aCols[182]
    SB1->B1_PRODREC := _aCols[198]
    SB1->B1_ALFECOP := _aCols[193]
    SB1->B1_ALFECST := _aCols[194]
    SB1->B1_CFEMA   := _aCols[222]
    SB1->B1_FECPBA  := _aCols[227]
    SB1->B1_MSEXP   := _aCols[270]
    SB1->B1_PAFMD5  := _aCols[273]
    SB1->B1_CRDEST  := _aCols[170]
    SB1->B1_REGRISS := _aCols[216]
    SB1->B1_IDHIST  := _aCols[267]
    SB1->B1_FETHAB  := _aCols[183]
    SB1->B1_ESTRORI := _aCols[261]
    SB1->B1_CALCFET := _aCols[185]
    SB1->B1_PAUTFET := _aCols[186]
    SB1->B1_PRN944I := _aCols[209]
    SB1->B1_ALFUMAC := _aCols[196]
    SB1->B1_CARGAE  := _aCols[254]
    SB1->B1_TRIBMUN := _aCols[189]
    SB1->B1_RPRODEP := _aCols[188]
    SB1->B1_PRINCMG := _aCols[235]
    SB1->B1_PR43080 := _aCols[210]
    SB1->B1_RICM65  := _aCols[219]
    SB1->B1_SELOEN  := _aCols[189]
    SB1->B1_DESBSE2 := _aCols[253]
    SB1->B1_BASE2   := _aCols[256]
    SB1->B1_FRETISS := _aCols[184]
    SB1->B1_AFETHAB := _aCols[203]
    SB1->B1_VLR_COF := _aCols[187]
    SB1->B1_PRFDSUL := _aCols[181]
    SB1->B1_TIPVEC  := _aCols[258]
    SB1->B1_COLOR   := _aCols[262]
    SB1->B1_RETOPER := _aCols[154]
    SB1->B1_COFINS  := _aCols[147]
    SB1->B1_CSLL    := _aCols[148]
    SB1->B1_CNAE    := _aCols[171]
    SB1->B1_ADMIN   := _aCols[255]
    SB1->B1_GARANT  := _aCols[257]
    SB1->B1_PERGART := _aCols[260]
    SB1->B1_AFACS   := _aCols[204]
    SB1->B1_AJUDIF  := _aCols[237]
    SB1->B1_ALFECRN := _aCols[236]
    SB1->B1_CFEM    := _aCols[220]
    SB1->B1_CFEMS   := _aCols[221]
    SB1->B1_MEPLES  := _aCols[264]
    SB1->B1_REGESIM := _aCols[224]
    SB1->B1_RSATIVO := _aCols[238]
    SB1->B1_TFETHAB := _aCols[206]
    SB1->B1_TPDP    := _aCols[263]
    SB1->B1_CRDPRES := _aCols[202]
    SB1->B1_CRICMST := _aCols[228]
    SB1->B1_FECOP   := _aCols[195]
    SB1->B1_CODLAN  := _aCols[223]
    SB1->B1_IVAAJU  := _aCols[214]
    SB1->B1_BASE    := _aCols[259]
    SB1->B1_SITTRIB := _aCols[243]
    SB1->B1_PORCPRL := _aCols[265]
    SB1->B1_IMPNCM  := _aCols[285]
    SB1->B1_B_CTA   := _aCols[268]
    SB1->B1_XPRDFIS := _aCols[269]
    SB1->B1_CTBSHEL := _aCols[271]
    SB1->B1_CCSHELL := _aCols[272]
    SB1->B1_XCODFAT := _aCols[289]
    SB1->B1_XCODREQ := _aCols[287]
    SB1->B1_XFATURA := _aCols[290]
    SB1->B1_XNATUR  := _aCols[288]
    
    SB1->(MsUnLock())
Return

Static Function fStrToNum(_cNum)
    Local nNum  := 0

    If _cNum == "" .OR. AllTrim(_cNum) = "-"
        nNum := 0
    Else
        _cNum   := StrTran(_cNum, '.', '')
        nNum    := VAL(AllTrim(StrTran(_cNum, ',', '.')))
    EndIf

Return nNum
