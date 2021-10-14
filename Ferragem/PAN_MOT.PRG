# include "INKEY.CH"
# include "PAN.CH"
# include "RCH.CH"
# include "SETCURS.CH"
# define  HEADSEP    "ÄÂÄ"
# define  COLSEP     " ³ "
# define  FOOTSEP    "ÄÁÄ"

***********************
function MVPeriodo()
***********************
local getlist:={},DATA_INI:=DATA_Fim:=date()
local Soma_Bruto := Soma_Liquido :=0 ,inicio := fim := time()
public VCOD:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEPRO:={}
public VDEC:={}, VLIQUIDO:={}
apaga(.T.)
@ 23,12 say "Digite as Informa‡oes Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(13,40,16,78,.F.," Monitoramento de Venda Por Periodo ")
@ 14,42 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 15,42 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   release VCOD ; release VQTD ; release VSUBTOTAL ; release VPRE
   release VNOMEPRO ; release VDEC ; release VLIQUIDO
   return nil
Endif
@ 23,12 say space(68)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Data " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_Data(DATA_INI,DATA_FIM)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Per¡odo",{"C¢d","Produto","Qtde","PVenda","Tot.Bruto"},{01,08,45,55,63})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,06 say alltrim(VNOMEPRO[I])
        @ L,42 say + transf(VQTD[I],"999999.99")
        @ L,52 say + transf(VPRE[I],"999,999.99")
        @ L,62 say + transf(VSUBTOTAL[I],"999,999.99")
        L++
        Soma_Bruto   += VSUBTOTAL[I]
        Soma_Liquido += VLIQUIDO[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,02 say "T. Bruto: " + transf(Soma_Bruto,"999,999.99")
           @ L,26 say "T. L¡quido: " + transf(Soma_Liquido,"999,999.99")
           @ L,52 say "T. Desconto: " + transf((1-(Soma_Liquido/Soma_Bruto))*100,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelData(DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,12 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
release VCOD ; release VQTD ; release VSUBTOTAL; release VLIQUIDO
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

*******************************************
static function TbRelData(DATA_INI,DATA_FIM)
*******************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,02,19,78)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Data(DATA_INI,DATA_FIM)
if LEN(VCOD)=0
   return nil
endif
moldura(04,01,21,79,.F.," Monitoramento de Venda Por Periodo ")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,32 say "Data Final : "   + DTOC(Data_Fim)
SomaTotal(.T.,.T.)
@ 06,02 to 06,78
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock    := {||ponteiro := 1}

oCol := TBCOLUMNNEW("C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW(" Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Qtde", {|| VQTD[ponteiro]})
oCol:picture := "999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Bruto", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

**************************************
Function Rel_Data(DATA_INI,DATA_FIM)
**************************************
local nElem:=0,AVCOD:={}, AVQTD:={} , AVSUBTOTAL:={} , AVPRE:={}
local AVNOMEPRO:={}, AVDEC := {} , AVLIQUIDO:={}
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 2
dbgotop()
do while !eof()
   aadd(AVCOD,PrCod)
   aadd(AVNOMEPRO,PrNome)
   aadd(AVQTD,0)
   aadd(AVPRE,0)
   aadd(AVSUBTOTAL,0)
   aadd(AVDEC,0)
   aadd(AVLIQUIDO,0)
   dbskip()
enddo
close _PRODUTOS
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if ImData >= Data_Ini
     dbskip(-1)
  elseif ImData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if (ImData>=DATA_INI) .and. (ImData<=DATA_FIM)
      select _MOVIMENT
      set order to 1
      dbseek(_ITENSMOV->ImCod)
      select _OPERACOE
      set order to 1
      dbseek(_MOVIMENT->MovOper)
      select _ITENSMOV
      if _OPERACOE->OperTipo <> "B"
         nElem:=Ascan(AVCOD,ImcdPro)
         AVQTD[nElem]:=(AVQTD[nElem]+ImQtd)
         AVPRE[nElem]:=ImPreco
         AVSUBTOTAL[nElem]:=(AVSUBTOTAL[nElem]+(ImQtd*ImPreco))
         Total_Bruto := AVSUBTOTAL[nElem]
         AVLIQUIDO[nElem]:=(AVLIQUIDO[nElem]+((ImQtd*ImPreco)-((ImQtd*ImPreco)*Desconto/100)))
         Total_Liquido := AVLIQUIDO[nElem]
         AVDEC[nElem]:=   (1-(Total_Liquido/Total_Bruto))*100
      endif
   elseif ImData > DATA_FIM
       exit
   endif
   dbskip()
enddo
for I=1 to Len(AVCOD)
   if AVQTD[I]<>0
      aadd(VCOD,AVCOD[I])
      aadd(VNOMEPRO,AVNOMEPRO[I])
      aadd(VQTD,AVQTD[I])
      aadd(VPRE,AVPRE[I])
      aadd(VSUBTOTAL,AVSUBTOTAL[I])
      aadd(VDEC,AVDEC[I])
      aadd(VLIQUIDO, AVLIQUIDO[I])
   endif
next
if Len(VCOD) = 0
   close _ITENSMOV
   close _MOVIMENT
   close _OPERACOE
   @ 23,11 say space(70)
   Alerta(05,15,"Nao Houve Movimento Neste Periodo..")
   return nil
endif
close _ITENSMOV
close _MOVIMENT
close _OPERACOE
return nil

**********************
function MDocumento()
**********************
local getlist:={},DATA_INI:=DATA_Fim:=date()
local NDoc := Soma_Bruto := Soma_Liquido :=0 ,inicio := fim := time()
public VCOD:={},VQTD:={},VSUBTOTAL:={},VPRE:={},VNOMEPRO:={}
public VDEC:={}, VLIQUIDO:={}
public Nome_Operacao:=space(15)
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(16,40,18,74,.F.," Monit. de Venda Por Documento ")
@ 17,42 say "Documento :"  get NDoc  pict "9999999" valid (!EMPTY(NDoc) .or. NDoc > 0)
read
if lastkey() == K_ESC
   release VCOD ; release VQTD ; release VSUBTOTAL
   release VPRE ; release VNOMEPRO; release VDEC ; release VLIQUIDO
   return nil
Endif
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
set order to 1
dbgotop()
dbseek(NDoc)
select _OPERACOE
dbseek(_MOVIMENT->MovOper)
Nome_Operacao := OperNome
close _OPERACOE
close _MOVIMENT
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Documento " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_Doc(NDoc)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Documento",{"C¢d","Produto","Qtde","PVenda","Tot.Bruto"},{01,08,45,55,63})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,06 say alltrim(VNOMEPRO[I])
        @ L,42 say + transf(VQTD[I],"999999.99")
        @ L,52 say + transf(VPRE[I],"999,999.99")
        @ L,62 say + transf(VSUBTOTAL[I],"999,999.99")
        L++
        Soma_Bruto   += VSUBTOTAL[I]
        Soma_Liquido += VLIQUIDO[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,02 say "T. Bruto: " + transf(Soma_Bruto,"999,999.99")
           @ L,26 say "T. L¡quido: " + transf(Soma_Liquido,"999,999.99")
           @ L,52 say "T. Desconto: " + transf((1-(Soma_Liquido/Soma_Bruto))*100,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelDoc(NDoc)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,11 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
release VCOD ; release VQTD ; release VSUBTOTAL, VLIQUIDO
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

********************************
static function TbRelDoc(NDoc)
********************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,02,19,78)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Doc(NDoc)
if LEN(VCOD)=0
   return nil
endif
moldura(04,01,21,79,.F.," Monitoramento de Venda Por Documento ")
@ 05,05 say "Documento : " + str(NDoc)
@ 05,45 say "Operacao  : " + alltrim(Nome_Operacao)
SomaTotal(.T.,.T.)
@ 06,02 to 06,78

OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock    := {||ponteiro := 1}

oCol := TBCOLUMNNEW("C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW(" Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Qtde", {|| VQTD[ponteiro]})
oCol:picture := "999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Bruto", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

***********************
Function Rel_Doc(NDoc)
***********************
Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
set order to 1
dbgotop()
Dbseek(NDoc-1,.T.)
do while !eof()
   if ImCod == NDoc
      aadd(VCOD,ImcdPro)
      aadd(VQTD,ImQtd)
      aadd(VPRE,ImPreco)
      aadd(VSUBTOTAL,ImQtd*ImPreco)
      Total_Bruto := ImQtd*ImPreco
      aadd(VLIQUIDO,((ImQtd*ImPreco)-((ImQtd*ImPreco)*Desconto/100)))
      Total_Liquido := ((ImQtd*ImPreco)-((ImQtd*ImPreco)*Desconto/100))
      aadd(VDEC,(1-(Total_Liquido/Total_Bruto))*100)
   elseif ImCod > NDoc
      exit
   endif
   dbskip()
enddo
if Len(VCOD) = 0
   @ 23,11 say space(70)
   close _ITENSMOV
   Alerta(05,15,"Nao Houve Movimento Com Este Documento..")
   return nil
endif
close _ITENSMOV
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
For Indice := 1 To Len(VCOD)
    AADD(VNOMEPRO,Ret_PRO(VCOD[Indice]))
next
close _PRODUTOS
return nil

*********************
function MProduto()
*********************
local getlist:={}, inicio := fim := time(),HORA_INI:="00:00:00",HORA_FIM:="23:00:00"
local Soma_Qtde := Soma_Bruto := Soma_Liquido :=0
local  DATA_INI:=DATA_Fim:=date() , nome_prod := space(40)
private Cod_Prod:=0
public VDATA:={},VQTD:={},VSUBTOTAL:={},VPRE:={},VNOMEFUNC:={},VDOC:={}
public VHORA:={},VDEC:={}, VLIQUIDO:={}
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 1
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(13,38,19,72,.F.," Monit. de Venda Por Produto ")
set key K_F2 to Pro_Help()
HelpVar("<Esc> - Sai <F2> Pesquisa Produto ",68,23,12)
@ 14,40 say "C¢d. Produto :"  get Cod_Prod pict "9999" valid (!EMPTY(Cod_Prod) .or. Cod_Prod>0)
@ 15,40 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 16,40 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
@ 17,40 say "Hora Inicial :"  get HORA_INI  pict "99:99:99" valid (!EMPTY(HORA_INI) .and. ;
   Testa_Hora(HORA_INI))
@ 18,40 say "Hora Final ..:"  get HORA_FIM  pict "99:99:99" valid (!EMPTY(HORA_FIM) .and. ;
   Testa_Hora(HORA_FIM))
read
set key K_F2 to
if !dbseek(Cod_Prod) .or. lastkey() == K_ESC
   close _PRODUTOS
   return nil
else
   nome_prod := PrNome
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Produto " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_Prod(Cod_Prod,DATA_INI,DATA_FIM, HORA_INI, HORA_FIM)
      For I = 1 to Len(VDATA)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Produto - "+ alltrim(substr(nome_prod,1,30)),{"Doc","Data","Hora","Funcionario","Qtde","PVenda","Tot.Bruto"},{01,09,16,26,49,59,69})
           L+=7
        endif
        @ L,00 say alltrim(str(VDOC[I]))
        @ L,07 say VDATA[I]
        @ L,16 say VHORA[I]
        @ L,26 say substr(alltrim(VNOMEFUNC[I]),1,20)
        @ L,46 say + transf(VQTD[I],"999,999.99")
        @ L,56 say + transf(VPRE[I],"999,999.99")
        @ L,68 say + transf(VSUBTOTAL[I],"999,999.99")
        L++
        Soma_Qtde+=VQTD[I]
        Soma_Bruto   += VSUBTOTAL[I]
        Soma_Liquido += VLIQUIDO[I]
        if L = 58 .or. I==Len(VDATA)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,00 say "T.Qtde:" + transf(Soma_Qtde,"999,999.99")
           @ L,19 say "T.Bruto:" + transf(Soma_Bruto,"999,999.99")
           @ L,39 say "T.L¡quido:" + transf(Soma_Liquido,"999,999.99")
           @ L,60 say "T.Desc.: " + transf((1-(Soma_Liquido/Soma_Bruto))*100,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelProd(Cod_Prod,DATA_INI,DATA_FIM, HORA_INI, HORA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,11 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release VNOMEPRO ; release DESTINO
release VDEC
close _PRODUTOS
return nil

**************************************************************************
static function TbRelProd(Cod_Prod,DATA_INI,DATA_FIM, HORA_INI, HORA_FIM)
**************************************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,02,19,78)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Prod(Cod_Prod,DATA_INI,DATA_FIM, HORA_INI, HORA_FIM)
if LEN(VDATA)=0
   return nil
endif
moldura(03,01,21,79,.F.," Monitoramento de Venda Por Produto ")
@ 04,05 say "Produto : " + str(Cod_Prod)
Testa("_PRODUTOS",Cod_Prod,,04,21,"PrNome")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,57 say "Data Final : " + DTOC(Data_Fim)
SomaQtd()
SomaTotal(.T.,.T.)
@ 06,02 to 06,78
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VDATA)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VDATA)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VDATA)}
OBJETO : goTopblock := {||ponteiro := 1}

oCol := TBCOLUMNNEW( "Doc.", {|| VDOC[ponteiro]})
oCol:picture := "999999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Funcionario", {|| VNOMEFUNC[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Data", {|| VDATA[ponteiro]})
oCol:picture := "99/99/99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Hora", {|| VHORA[ponteiro]})
oCol:picture := "99:99:99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Qtde", {|| VQTD[ponteiro]})
oCol:picture := "999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Bruto", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

******************************************************************
Function Rel_Prod(Cod_Prod,DATA_INI,DATA_FIM, HORA_INI, HORA_FIM)
******************************************************************
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
set order to 2
if !Dbseek(Cod_Prod)
   close _ITENSMOV
   close _FUNCIONA
   close _MOVIMENT
   close _OPERACOE
   Alerta(05,15,"Nao Existe Movimento Com Este Produto..")
   return nil
endif
dbgotop()
Dbseek(Cod_Prod,.T.)
do while .t.
   if ImCdPro>= Cod_Prod
      dbskip(-1)
   elseif ImCdPro< Cod_Prod
      exit
   endif
   if BOF()
      exit
   endif
enddo
do while !eof()
  if (ImData>=DATA_INI) .and. (ImData<=DATA_FIM) .and. (ImcdPro = Cod_Prod)
     select _MOVIMENT
     set order to 1
     if dbseek(_ITENSMOV->ImCod)
        if Hora_Ini<= MovHr .and.  Hora_Fim>=MovHr
           select _OPERACOE
           set order to 1
           dbseek(_MOVIMENT->MovOper)
           select _MOVIMENT
           if _OPERACOE->OperTipo <> "B"
               aadd(VQTD,_ITENSMOV->ImQtd)
               aadd(VPRE,_ITENSMOV->ImPreco)
               aadd(VSUBTOTAL,_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)
               Total_Bruto := _ITENSMOV->ImQtd*_ITENSMOV->ImPreco
               aadd(VDATA,_ITENSMOV->ImData)
               aadd(VDOC,_ITENSMOV->ImCod)
               aadd(VHORA,MovHr)
               aadd(VLIQUIDO,((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)-((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)*_ITENSMOV->Desconto/100)))
               Total_Liquido := (_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)-((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)*_ITENSMOV->Desconto/100)
               aadd(VDEC,(1-(Total_Liquido/Total_Bruto))*100)
               select _FUNCIONA
               dbseek(_MOVIMENT->MovFunc)
               aadd(VNOMEFUNC,substr(FuncNome,1,20))
           endif
        endif
     endif
     select _ITENSMOV
  endif
  if ImCdPro > Cod_Prod
      exit
  endif
  dbskip()
enddo
if Len(VDATA) = 0
   Alerta(05,15,"Nao Existe Movimento Com Este Produto..")
endif
close _ITENSMOV
close _FUNCIONA
close _MOVIMENT
close _OPERACOE
return nil

*********************
function MGrupo()
*********************
local getlist:={}
local Soma_Qtde := Soma_Bruto := Soma_Liquido :=0
local DATA_INI:=DATA_Fim:=date() , inicio := fim := time()
public VCOD:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEPRO:={}
public VDEC:={}, VLIQUIDO:={}
private Cod_Grupo := 0
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
set key K_F2 to Gru_Help()
moldura(16,38,20,72,.F.," Monit. de Venda Por Grupo ")
HelpVar("<Esc> - Sai <F2> Pesquisa Grupo ",68,23,12)
@ 17,40 say "C¢digo do Grupo :"  get Cod_Grupo pict "99" valid (!EMPTY(Cod_Grupo) .or. Cod_Grupo>0)
@ 18,40 say "   Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 19,40 say "   Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
set key K_F2 to
if lastkey() == K_ESC
   close _GRUPOS
   return nil
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Grupo " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_Grupo(Cod_Grupo,DATA_INI,DATA_FIM)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Grupo",{"C¢d","Produto","Qtde","PVenda","Tot.Bruto"},{01,08,45,55,63})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,06 say alltrim(VNOMEPRO[I])
        @ L,42 say + transf(VQTD[I],"999999.99")
        @ L,52 say + transf(VPRE[I],"999,999.99")
        @ L,62 say + transf(VSUBTOTAL[I],"999,999.99")
        L++
        Soma_Bruto   += VSUBTOTAL[I]
        Soma_Liquido += VLIQUIDO[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,02 say "T. Bruto: " + transf(Soma_Bruto,"999,999.99")
           @ L,26 say "T. L¡quido: " + transf(Soma_Liquido,"999,999.99")
           @ L,52 say "T. Desconto: " + transf((1-(Soma_Liquido/Soma_Bruto))*100,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelGrupo(Cod_Grupo,DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,11 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
close _GRUPOS
release VCOD ; release VQTD ; release VSUBTOTAL; release VLIQUIDO
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

********************************************************
static function TbRelGrupo(Cod_Grupo,DATA_INI,DATA_FIM)
********************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,02,19,78)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Grupo(Cod_Grupo,DATA_INI,DATA_FIM)
if LEN(VCOD)=0
   return nil
endif
moldura(03,01,21,79,.F.," Monitoramento de Venda Por Grupo ")
@ 06,02 to 06,78
@ 04,05 say "Grupo : " + str(Cod_Grupo)
Testa("_GRUPOS",Cod_Grupo,,04,21,"GpNome")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,57 say "Data Final : " + DTOC(Data_Fim)
SomaTotal(.T.,.T.)
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}

oCol := TBCOLUMNNEW( "C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Qtde", {|| VQTD[ponteiro]})
oCol:picture := "999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Bruto", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

************************************************
Function Rel_Grupo(Cod_Grupo,DATA_INI,DATA_FIM)
************************************************
local nElem:=0,AVCOD:={}, AVQTD:={}, AVSUBTOTAL:={}, AVPRE:={}
local AVNOMEPRO:={}, AVDEC := {} , AVLIQUIDO:={}
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 1
dbgotop()
do while !eof()
   If Cod_Grupo == PrGrupo
      aadd(AVCOD,PrCod)
      aadd(AVNOMEPRO,PrNome)
      aadd(AVQTD,0)
      aadd(AVPRE,0)
      aadd(AVSUBTOTAL,0)
      aadd(AVDEC,0)
      aadd(AVLIQUIDO,0)
   endif
   dbskip()
enddo
close _PRODUTOS
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if ImData >= Data_Ini
     dbskip(-1)
  elseif ImData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
  if (ImData>=DATA_INI) .and. (ImData<=DATA_FIM)
     select _MOVIMENT
     set order to 1
     dbseek(_ITENSMOV->ImCod)
     select _OPERACOE
     set order to 1
     dbseek(_MOVIMENT->MovOper)
     select _ITENSMOV
     if _OPERACOE->OperTipo <> "B"
        nElem:=Ascan(AVCOD,ImcdPro)
        if nElem > 0
           AVQTD[nElem]:=(AVQTD[nElem]+ImQtd)
           AVPRE[nElem]:=ImPreco
           AVSUBTOTAL[nElem]:=(AVSUBTOTAL[nElem]+(ImQtd*ImPreco))
           Total_Bruto := AVSUBTOTAL[nElem]
           AVLIQUIDO[nElem]:=(AVLIQUIDO[nElem]+((ImQtd*ImPreco)-((ImQtd*ImPreco)*Desconto/100)))
           Total_Liquido := AVLIQUIDO[nElem]
           AVDEC[nElem] := (1-(Total_Liquido/Total_Bruto))*100
        endif
     endif
  elseif ImData > DATA_FIM
    exit
  endif
  dbskip()
enddo
for I=1 to Len(AVCOD)
   if AVQTD[I]<>0
      aadd(VCOD,AVCOD[I])
      aadd(VNOMEPRO,AVNOMEPRO[I])
      aadd(VQTD,AVQTD[I])
      aadd(VPRE,AVPRE[I])
      aadd(VSUBTOTAL,AVSUBTOTAL[I])
      aadd(VDEC,AVDEC[I])
      aadd(VLIQUIDO,AVLIQUIDO[I])
   endif
next
if Len(VCOD) = 0
   Alerta(05,15,"Nao Existe Movimento Com Este Grupo..")
endif
close _MOVIMENT
close _ITENSMOV
close _OPERACOE
return nil

*********************
function MOperacao()
*********************
local getlist:={},Soma_Qtde:=Soma_Bruto:=Soma_Liquido:=0,inicio:=fim:=time()
local DATA_INI:=DATA_Fim:=date()
public VCOD:={},VQTD:={},VSUBTOTAL:={},VPCUSTO:={},VPRE:={},VNOMEPRO:={}
public VDEC:={},VLIQUIDO:={}
private Cod_Operacao := 0
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emiss„o do Relat¢rio"
beep(2)
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
set key K_F2 to Gru_Help()
moldura(16,38,20,72,.F.," Monit. de Venda Por Opera‡„o ")
HelpVar("<Esc> - Sai <F2> Pesquisa Grupo ",68,23,12)
@ 17,40 say "C¢d.da Operacao :"  get Cod_Operacao pict "99" valid (!EMPTY(Cod_Operacao) .or. Cod_Operacao>0)
@ 18,40 say "   Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 19,40 say "   Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
set key K_F2 to
if lastkey() == K_ESC
   close _GRUPOS
   return nil
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monit. Por Opera‡„o" color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_Oper(Cod_Operacao,DATA_INI,DATA_FIM)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Operacao",{"C¢d.","Produto","Qtde","PVenda","Tot.Bruto"},{01,11,46,55,65})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,06 say alltrim(VNOMEPRO[I])
        @ L,42 say + transf(VQTD[I],"999999.99")
        @ L,52 say + transf(VPRE[I],"999,999.99")
        @ L,62 say + transf(VSUBTOTAL[I],"999,999.99")
        L++
        Soma_Qtde+=VQTD[I]
        Soma_Bruto   += VSUBTOTAL[I]
        Soma_Liquido += VLIQUIDO[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,00 say "T.Qtde:" + transf(Soma_Qtde,"999,999.99")
           @ L,19 say "T.Bruto:" + transf(Soma_Bruto,"999,999.99")
           @ L,39 say "T.L¡quido:" + transf(Soma_Liquido,"999,999.99")
           @ L,60 say "T.Desc.: " + transf((1-(Soma_Liquido/Soma_Bruto))*100,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelOper(Cod_Operacao,DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,11 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
close _GRUPOS
release VCOD ; release VQTD ; release VSUBTOTAL; release VPCUSTO
release VLIQUIDO; release VPRE ; release VNOMEPRO ; release DESTINO
return nil

********************************************************
static function TbRelOper(COD_OPERACAO,DATA_INI,DATA_FIM)
********************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,02,19,78)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Oper(COD_OPERACAO,DATA_INI,DATA_FIM)
if LEN(VCOD)=0
   return nil
endif
moldura(03,01,21,79,.F.," Monitoramento de Venda Por Opera‡„o")
@ 06,02 to 06,78
@ 04,05 say "Operacao : " + str(Cod_Operacao)
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Testa("_OPERACOE",Cod_Operacao,,04,21,"OperNome")
close _OPERACOE
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,57 say "Data Final : " + DTOC(Data_Fim)
SomaTotal(.T.,.T.)
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Qtde", {|| VQTD[ponteiro]})
oCol:picture := "999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Bruto", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

************************************************
Function Rel_Oper(Cod_Operacao,DATA_INI,DATA_FIM)
************************************************
local nElem:=0,AVDoc:={}
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
set order to 2
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if MovDt >= Data_Ini
     dbskip(-1)
  elseif MovDt< Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   If Cod_Operacao == MovOper
      aadd(AVDoc,MovCod)
   endif
   dbskip()
   if MovDt > Data_Fim
      exit
   endif
enddo
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if ImData >= Data_Ini
     dbskip(-1)
  elseif ImData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
  if (ImData>=DATA_INI) .and. (ImData<=DATA_FIM)
      nElem:=Ascan(AVDoc,Imcod)
      if nElem>0
         aadd(VCOD,ImCdPro)
         aadd(VQTD,ImQtd)
         select _PRODUTOS
         set order to 1
         dbseek(_ITENSMOV->ImCdPro)
         aadd(VPRE,_ITENSMOV->ImPreco)
         aadd(VPCUSTO,_ITENSMOV->ImQtd*PrPCusto)
         aadd(VSUBTOTAL,_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)
         Total_Bruto := _ITENSMOV->ImQtd*_ITENSMOV->ImPreco
         aadd(VLIQUIDO,((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)-((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)*_ITENSMOV->Desconto/100)))
         Total_Liquido := ((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)-((_ITENSMOV->ImQtd*_ITENSMOV->ImPreco)*_ITENSMOV->Desconto/100))
         aadd(VNOMEPRO,PRNOME)
         aadd(VDEC,(1-(Total_Liquido/Total_Bruto))*100)
         select _ITENSMOV
         set order to 3
      endif
  elseif ImData > DATA_FIM
    exit
  endif
  dbskip()
enddo
if Len(VCOD) = 0
   Alerta(05,15,"Nao Existe Movimento Com Esta Opera‡„o..")
endif
close _MOVIMENT
close _PRODUTOS
close _ITENSMOV
return nil

***************************************//**************************************
// Monitoracao por Compra

***********************
function MCPeriodo()
***********************
local getlist:={} , DATA_INI:=DATA_Fim:=date(),Soma:=0 , inicio := fim := time()
public VCOD:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEPRO:={}
apaga(.T.)
@ 23,12 say "Digite as Informa‡oes Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(13,40,16,78,.F.," Monitoramento de Compra Por Periodo ")
@ 14,42 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 15,42 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   release VCOD ; release VQTD ; release VSUBTOTAL
   release VPRE ; release VNOMEPRO
   return nil
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Data " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_CData(DATA_INI,DATA_FIM)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Per¡odo",{"C¢d","Produto","Qtde","Preco Venda","Sub-Total"},{01,08,36,50,65})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,09 say substr(alltrim(VNOMEPRO[I]),1,20)
        @ L,28 say VQTD[I]
        @ L,48 say VPRE[I]      pict "999,999.99"
        @ L,63 say VSUBTOTAL[I] pict "999,999.99"
        L++
        soma += VQTD[I] * VPRE[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,59 say "Total: " + alltrim(str(soma,10,2))
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelCData(DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,11 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(2)
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

*********************************************
static function TbRelCData(DATA_INI,DATA_FIM)
*********************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_CData(DATA_INI,DATA_FIM)
if LEN(VCOD)=0
   return nil
endif
moldura(04,02,21,78,.F.," Monitoramento de Compra Por Per¡odo ")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,32 say "Data Final : " + DTOC(Data_Fim)
SomaTotal(.F.,.F.)
@ 06,03 to 06,77
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Quantidade", {|| VQTD[ponteiro]})
oCol:picture := "9999.999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)


oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)
ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

**************************************
Function Rel_CData(DATA_INI,DATA_FIM)
**************************************
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if ICData >= Data_Ini
     dbskip(-1)
  elseif ICData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if (ICData>=DATA_INI) .and. (ICData<=DATA_FIM)
       Codigo := ICCod
       aadd(VCOD,ICCodPr)
       aadd(VQTD,ICQtd)
       aadd(VPRE,ICPUni)
       aadd(VSUBTOTAL,ICQtd*ICPUni)
   elseif ICData > DATA_FIM
       exit
   endif
   dbskip()
enddo
if Len(VCOD) = 0
   close _ITENSCOMP
   @ 23,11 say space(70)
   Alerta(05,15,"Nao Houve Compra Neste Periodo..")
   return nil
endif
if Len(VCOD) > 1
   For I := 1 To Len(VCOD)
     For J := I+1 To Len(VCOD)
        if VCOD[I] == VCOD[J] .and. VPRE[I] == VPRE[J]
           Qtd := VQTD[I]
           Qtd += VQTD[J]
           VQTD[I] := Qtd
           VSUBTOTAL[I] := VQTD[I] * VPRE[I]
           adel(VCOD,J)
           adel(VQTD,J)
           adel(VPRE,J)
           adel(VSUBTOTAL,J)
           asize(VQTD,len(VCOD)-1)
           asize(VPRE,len(VCOD)-1)
           asize(VSUBTOTAL,len(VCOD)-1)
           asize(VCOD,len(VCOD)-1)
           J--
        endif
     next
   next
endif
close _ITENSCOMP
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
For Indice := 1 To Len(VCOD)
    AADD(VNOMEPRO,Ret_PRO(VCOD[Indice]))
next
close _PRODUTOS
return nil

*********************
function MCProduto()
*********************
local getlist:={}, Soma_Qtde := Soma := 0 , DATA_INI:=DATA_Fim:=date()
local inicio := fim := time()
private Cod_Prod:=0
public VDATA:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEFUNC:={}
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(16,38,20,72,.F.," Monit. de Compra Por Produto ")
set key K_F2 to Pro_Help()
HelpVar("<Esc> - Sai <F2> Pesquisa Produto ",68,23,12)
@ 17,40 say "C¢d. Produto :"  get Cod_Prod pict "9999" valid (!EMPTY(Cod_Prod) .or. Cod_Prod>0)
@ 18,40 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 19,40 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
set key K_F2 to
if lastkey() == K_ESC
   close _PRODUTOS
   return nil
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Produto " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_CProd(Cod_Prod,DATA_INI,DATA_FIM)
      For I = 1 to Len(VDATA)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Produto",{"Data","Funcionario","Qtde","Preco Unit.","Sub-Total"},{01,11,36,50,65})
           L+=7
        endif
        @ L,01 say VDATA[I]
        @ L,11 say substr(alltrim(VNOMEFUNC[I]),1,20)
        @ L,34 say VQTD[I]
        @ L,48 say VPRE[I]      pict "999,999.99"
        @ L,63 say VSUBTOTAL[I] pict "999,999.99"
        L++
        Soma_Qtde+=VQTD[I]
        Soma += VQTD[I] * VPRE[I]
        if L = 58 .or. I==Len(VDATA)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,35 say "Total Qtde: " + alltrim(str(Soma_Qtde))
           @ L,59 say "Total: " + alltrim(str(soma,10,2))
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelCProd(Cod_Prod,DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,12 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(1)
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release VNOMEPRO ; release DESTINO
close _PRODUTOS
return nil

*******************************************************
static function TbRelCProd(Cod_Prod,DATA_INI,DATA_FIM)
*******************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_CProd(Cod_Prod,DATA_INI,DATA_FIM)
if LEN(VDATA)=0
   return nil
endif
moldura(03,02,21,78,.F.," Monitoramento de Compra Por Produto ")
@ 04,05 say "Produto : " + str(Cod_Prod)
Testa("_PRODUTOS",Cod_Prod,,04,21,"PrNome")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,57 say "Data Final : " + DTOC(Data_Fim)
SomaQtd()
SomaTotal(.F.,.F.)
@ 06,03 to 06,77
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VDATA)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VDATA)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VDATA)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "Data", {|| VDATA[ponteiro]})
oCol:picture := "99/99/99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Fornecedor", {|| VNOMEFUNC[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Quantidade", {|| VQTD[ponteiro]})
oCol:picture := "9999.999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)


oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)
ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

***********************************************
Function Rel_CProd(Cod_Prod,DATA_INI,DATA_FIM)
***********************************************
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
set order to 2
if !Dbseek(Cod_Prod)
   close _ITENSCOMP
   close _FORNECED
   Alerta(05,15,"Nao Existe Movimento Com Este Produto..")
   return nil
endif
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if ICData >= Data_Ini
     dbskip(-1)
  elseif ICData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
  if (ICData>=DATA_INI) .and. (ICData<=DATA_FIM) .and. (IcCodPr = Cod_Prod)
        aadd(VQTD,ICQtd)
        aadd(VPRE,ICPuni)
        aadd(VSUBTOTAL,ICQtd*ICPuni)
        aadd(VDATA,IcData)
        Codigo := val(right(alltrim(str(IcCod)),3))
        select _FORNECED
        set order to 1
        dbseek(Codigo)
        aadd(VNOMEFUNC,substr(ForNome,1,20))
        select _ITENSCOMP
   elseif IcData > Data_Fim
      exit
  endif
  dbskip()
enddo
if Len(VDATA) = 0
   Alerta(05,15,"Nao Existe Movimento Com Este Produto..")
endif
close _ITENSCOMP
close _FORNECED
return nil

**********************
function MCDocumento()
**********************
local getlist:={} , NDoc := Cod_For := 0 , DATA_INI:=DATA_Fim:=date(),Soma:=0
local inicio := fim := time()
public VCOD:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEPRO:={}
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(16,40,19,74,.F.," Monit. de Compra Por NF ")
HelpVar("<Esc> - Sai <F2> Pesquisa Fornecedor",70,23,10)
@ 17,42 say "   N§ Nota Fiscal :" get NDoc    pict "999999" valid (!EMPTY(NDoc) .or. NDoc > 0)
set key K_F2 to For_Help()
@ 18,42 say "C¢digo Fornecedor :" get Cod_For pict "999"    valid (!EMPTY(Cod_For) .or. Cod_For > 0)
read
set key K_F2 to
if lastkey() == K_ESC
   close _FORNECED
   release VCOD ; release VQTD ; release VSUBTOTAL
   release VPRE ; release VNOMEPRO
   return nil
Endif
inicio := inicio1 := time()
@ 23,10 say space(70)
@ 23,11 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Documento " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_CDoc(NDoc,Cod_For)
      For I = 1 to Len(VCOD)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por NF",{"C¢d","Produto","Qtde","Preco Venda","Sub-Total"},{01,08,36,50,65})
           L+=7
        endif
        @ L,01 say VCOD[I]
        @ L,09 say substr(alltrim(VNOMEPRO[I]),1,20)
        @ L,28 say VQTD[I]
        @ L,48 say VPRE[I]      pict "999,999.99"
        @ L,63 say VSUBTOTAL[I] pict "999,999.99"
        L++
        soma += VQTD[I] * VPRE[I]
        if L = 58 .or. I==Len(VCOD)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,59 say "Total: " + alltrim(str(soma,10,2))
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelCDoc(NDoc,Cod_For)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,12 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(1)
close _FORNECED
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

*********************************
function TbRelCDoc(NDoc,Cod_For)
*********************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(08,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_CDoc(NDoc,Cod_For)
if LEN(VCOD)=0
   return nil
endif
moldura(04,02,21,78,.F.," Monitoramento de Compra Por NF ")
@ 05,06 say "N§ Nota Fiscal: " color ["&cor_Apresentacao"]
@ 05,22 say + alltrim(str(NDoc))
@ 05,33 say "C¢d. Fornecedor: " color ["&cor_Apresentacao"]
@ 05,50 say + alltrim(str(Cod_For)) + " - "
testa("_FORNECED",Cod_For,,05,55,"ForNome")
OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC SHARED
Set order to 1
dbseek(NDoc)
if CpNParc = 0
   @ 06,03 say "Tipo de Pagamento: " color ["&cor_Apresentacao"]
   @ 06,22 say "A Vista"
else
   @ 06,03 say "Tipo de Pagamento: " color ["&cor_Apresentacao"]
   @ 06,22 say "A Prazo"
   @ 06,34 say "N§ de Parcelas: " color ["&cor_Apresentacao"]
   @ 06,50 say + alltrim(str(CpNParc))
endif
close _COMPRAS
SomaTotal(.F.,.F.)
@ 07,03 to 07,77
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Quantidade", {|| VQTD[ponteiro]})
oCol:picture := "9999.999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)


oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)
ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

********************************
Function Rel_CDoc(NDoc,Cod_For)
*********************************
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
set order to 1
dbgotop()
Num_Doc := val(alltrim(str(NDoc) + strzero(Cod_For,3)))
Dbseek(NDoc-1,.T.)
do while !eof()
   if IcCod == Num_Doc
      aadd(VCOD,IcCodPr)
      aadd(VQTD,IcQtd)
      aadd(VPRE,IcPUni)
      aadd(VSUBTOTAL,IcQtd*IcPUni)
   elseif IcCod > Num_Doc
      exit
   endif
   dbskip()
enddo
if Len(VCOD) = 0
   @ 23,11 say space(70)
   close _ITENSCOMP
   Alerta(05,15,"Documento Nao Encontrado ...")
   return nil
endif
close _ITENSCOMP
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
For Indice := 1 To Len(VCOD)
    AADD(VNOMEPRO,Ret_PRO(VCOD[Indice]))
next
close _PRODUTOS
return nil

*********************
function MCFor()
*********************
local getlist:={}, Soma_Qtde := Soma := 0 , DATA_INI:=DATA_Fim:=date()
local inicio := fim := time()
private Cod_For:=0
public VDATA:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEFUNC:={}
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
apaga(.T.)
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(16,38,20,72,.F.," Monit. de Compra Por Fornecedor ")
set key K_F2 to For_Help()
HelpVar("<Esc> - Sai <F2> Pesquisa Fornecedor",68,23,12)
@ 17,40 say "C¢d. Fornecedor :"  get Cod_For   pict "999"      valid (!EMPTY(Cod_For) .or. Cod_For>0)
@ 18,40 say "   Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 19,40 say "   Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM));
   .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
set key K_F2 to
if lastkey() == K_ESC
   close _FORNECED
   return nil
Endif
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Monitora‡ao Por Fornecedor " color ["W+*"]
Imp_OK := Imp_Doc()
L := 0
P := 1
if DESTINO <> "V"
   if Imp_OK
      Rel_CProd(Cod_For,DATA_INI,DATA_FIM)
      For I = 1 to Len(VDATA)
        if L==0
           NCab(DATA_INI,DATA_FIM,"Monitoramento Por Fornecedor",{"Data","Produto","Qtde","Preco Unit.","Sub-Total"},{01,11,36,50,65})
           L+=7
        endif
        @ L,01 say VDATA[I]
        @ L,11 say substr(alltrim(VNOMEFUNC[I]),1,20)
        @ L,34 say VQTD[I]
        @ L,48 say VPRE[I]      pict "999,999.99"
        @ L,63 say VSUBTOTAL[I] pict "999,999.99"
        L++
        Soma_Qtde+=VQTD[I]
        Soma += VQTD[I] * VPRE[I]
        if L = 58 .or. I==Len(VDATA)
           L := 59
           @ L,00 say replicate ("-",76)
           L++
           @ L,35 say "Total Qtde: " + alltrim(str(Soma_Qtde))
           @ L,59 say "Total: " + alltrim(str(soma,10,2))
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      Next
   endif
else
  set device to screen
  set printer off
  set printer to
  TbRelCFor(Cod_For,DATA_INI,DATA_FIM)
endif
set device to screen
set printer off
set printer to
fim := time()
@ 23,10 say space(70)
@ 23,12 say "Tempo Gasto Para Gerar Relat¢rio:" + elaptime(inicio,fim) color ["W+*"]
inkey(1)
close _FORNECED
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release VNOMEPRO ; release DESTINO
return nil

*******************************************************
static function TbRelCFor(Cod_For,DATA_INI,DATA_FIM)
*******************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(07,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_CFor(Cod_For,DATA_INI,DATA_FIM)
if LEN(VDATA)=0
   return nil
endif
moldura(03,02,21,78,.F.," Monitoramento de Compra Por Fornecedor ")
@ 04,05 say "Fornecedor : " + str(Cod_For)
Testa("_FORNECED",Cod_For,,04,23,"ForNome")
@ 05,05 say "Data Inicial : " + DTOC(Data_Ini)
@ 05,57 say "Data Final : " + DTOC(Data_Fim)
SomaQtd()
SomaTotal(.F.,.F.)
@ 06,03 to 06,77
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VDATA)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VDATA)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VDATA)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "Data", {|| VDATA[ponteiro]})
oCol:picture := "99/99/99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEFUNC[ponteiro]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Quantidade", {|| VQTD[ponteiro]})
oCol:picture := "9999.999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| VPRE[ponteiro] })
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)


oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)
ateclas :=   {{K_F10 ,"CALC()"       },;
              {K_F1  ,"HelpBrowse()" }}
TBrTeclas(OBJETO,Ponteiro,ateclas)
return nil

***********************************************
Function Rel_CFor(Cod_For,DATA_INI,DATA_FIM)
***********************************************
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC SHARED
set order to 3
if !Dbseek(Cod_For)
   close _PRODUTOS
   close _ITENSCOMP
   close _COMPRAS
   Alerta(05,15,"Nao Existe Compras Com Este Fornecedor..")
   return nil
endif
set order to 2
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if CpData >= Data_Ini
     dbskip(-1)
  elseif CpData < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
  if (CpData>=DATA_INI) .and. (CpData<=DATA_FIM) .and. (CpFor = Cod_For)
        Num_Doc := val(alltrim(str(CpCod) + strzero(CpFor,3)))
        select _ITENSCOMP
        set order to 1
        dbgotop()
        Dbseek(Num_Doc,.T.)
        do while .t.
          if IcCod >= Num_Doc
             dbskip(-1)
          elseif IcCod < Num_Doc
             exit
          endif
          if BOF()
             exit
          endif
        enddo
        do while !eof()
           if IcCod = Num_Doc
              aadd(VQTD,ICQtd)
              aadd(VPRE,ICPuni)
              aadd(VSUBTOTAL,ICQtd*ICPuni)
              aadd(VDATA,IcData)
              Codigo := IcCodPr
              select _PRODUTOS
              set order to 1
              dbseek(Codigo)
              aadd(VNOMEFUNC,substr(PrNome,1,20))
              select _ITENSCOMP
           elseif IcCod > Num_Doc
              exit
           endif
           dbskip()
        enddo
   elseif CpData > DATA_FIM
       exit
   endif
   select _COMPRAS
   dbskip()
enddo
if Len(VDATA) = 0
   Alerta(05,15,"Nao Existe Movimento Com Este Fornecedor..")
endif
close _PRODUTOS
close _ITENSCOMP
close _COMPRAS
return nil

*******************************************
function TBrTeclas(OBJETO,Ponteiro,ateclas)
*******************************************
objeto:freeze := 2
objeto:colpos := objeto:freeze+1
while .T.
   dispbegin()
   objeto:refreshall()
   while !objeto:stabilize() ; end
   dispend()
   if OBJETO:stable
     L:=row() ; C:=col()
     OBJETO:colorRect({OBJETO:rowPos,1,OBJETO:rowPos,OBJETO:colCount},{2,2})
     do while ! OBJETO:stabilize() ; enddo
       if OBJETO:hitTop
          tone(1000,2)
          HelpVar("Mensagem: In¡cio de arquivo!",80,23,00)
          setcursor(SC_NONE)
       elseif OBJETO:hitBottom
          tone(1000,2)
          HelpVar("Mensagem: Fim de arquivo!",80,23,00)
          setcursor(SC_NONE)
       else
          HelpVar("Mensagem: <Esc> - Encerra Monitora‡ao <F1> - Ajuda <F10> - Calculadora",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TbTeclas( NKEY, OBJETO, Ponteiro,ateclas)
      if ( nKey == K_ESC )
         exit
      endif
   endif
   if objeto:colpos < (objeto:freeze+1)
      objeto:colpos := objeto:freeze+1
   endif
enddo
return nil

*******************************************************
static function TbTeclas( NKEY,OOBJ,PONTEIRO,ateclas)
*******************************************************
local NFOUND
  do case
  case NKEY == K_DOWN       ;  eval({|B|B:down()},OOBJ)
  case NKEY == K_UP         ;  eval({|B|B:up()},OOBJ)
  case NKEY == K_PGDN       ;  eval({|B|B:pageDown()},OOBJ)
  case NKEY == K_PGUP       ;  eval({|B|B:pageUp()},OOBJ)
  case NKEY == K_HOME       ;  eval({|B|B:goTop()},OOBJ)
  case NKEY == K_END        ;  eval({|B|B:goBottom()},OOBJ)
  case NKEY == K_RIGHT      ;  eval({|B|B:right()},OOBJ)
  case NKEY == K_LEFT       ;  eval({|B|B:left()},OOBJ)
  case NKEY == K_HOME       ;  eval({|B|B:home()},OOBJ)
  case NKEY == K_END        ;  eval({|B|B:end()},OOBJ)
  case NKEY == K_CTRL_LEFT  ;  eval({|B|B:panLeft()},OOBJ)
  case NKEY == K_CTRL_RIGHT ;  eval({|B|B:panRight()},OOBJ)
  case NKEY == K_CTRL_HOME  ;  eval({|B|B:panHome()},OOBJ)
  case NKEY == K_CTRL_END   ;  eval({|B|B:panEnd()},OOBJ)
  case NKEY == K_ESC        ;  return(.f.)
  otherwise
    if valtype(ateclas)=="A"
       NFOUND := ascan(ateclas, {|a| NKEY == a[1]})
       if NFOUND != 0
          eval(&("{||"+ateclas[NFOUND,2]+"}"))
       endif
    endif
  endcase
return(.t.)
