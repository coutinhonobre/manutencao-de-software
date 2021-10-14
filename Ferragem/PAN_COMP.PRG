# include "INKEY.CH"
# include "PAN.CH"
# include "RCH.CH"
# include "SETCURS.CH"
# define  HEADSEP    "ÄÂÄ"
# define  COLSEP     " ³ "
# define  FOOTSEP    "ÄÁÄ"

*******************
function COMPRA()
*******************
local GETLIST:={}, TELA_COMPRA ; public ValorFixo
if Testa_EData("Lan‡amento das Compras ‚ Efetuado Apenas No Mes Corrente..")
   Return nil
endif
if !TRotina(7)
   Return nil
endif
apaga(.T.)
HelpVar("<ESC> Encerra Compra <F10> Calculadora",80,23,00)
moldura(04,01,21,78,.f.," M¢dulo de Compra ")
use parament alias _parament new
set decimals to 3
ValorFixo = Custo_Fixo
CLOSE _PARAMENT
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
dbgobottom()
if EOF()
   Alerta(11,15,"N„o H  Nenhum Produto Cadastrado!!")
   set decimals to 2
   close Database
   return nil
endif
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
if lastrec()=0
   Alerta(11,15,"N„o H  Nenhum Fornecedor Cadastrado!!")
   set decimals to 2
   close Database
   return nil
endif
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC SHARED
set order to 1
do while .t.
 TELA_COMPRA := savescreen(0,0,maxrow(),maxcol())
 inic_var()
 dbgobottom()
 FCpData := date()
 Salva_Linha := savescreen(23,0,23,maxcol())
 @ 05,04 say "N.Documento :" get FCpCod pict "999999" 
 @ 05,30 say   "Data :" get FCpData  pict "99/99/99" ;
   valid (!empty(FCpData))
 read
 ESC OUT
 @ 23,00 say "<ENTER> Visualizar Dados de Fornecedor <ESC> Retorna <F10> Calculadora"
 @ 07,05 say "Fornecedor :" get FCpFor PICT "999" ;
   valid(pesquisa(08,10,17,65,"_FORNECED",FCpFor,"ForCod","ForNome"," Fornecedores ") .and. ;
   FCpFor > 0 .and. testa("_FORNECED",FCpFor,,07,22,"ForNome"))
 read
 if lastkey()== K_ESC
    restscreen(0,0,maxrow(),maxcol(),TELA_COMPRA)
    loop
 endif
 Num_Doc := val(alltrim(str(FCpCod) + strzero(FCpFor,3)))
 if FCpCod>0
    Select _ITENSCOMP
    Set order to 1
    if dbseek(Num_Doc)
       Alerta(05,15,"Documento J  Cadastrado No Sistema...")
       restscreen(0,0,maxrow(),maxcol(),TELA_COMPRA)
       Select _COMPRAS
       loop
    endif
 endif
 Select _COMPRAS
 TbCompra(FCpCod,FCpFor)
 restscreen(0,0,maxrow(),maxcol(),TELA_COMPRA)
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),TELA_COMPRA)
 endif
enddo
set decimals to 2
CLOSE  _PRODUTOS
CLOSE  _FORNECED
CLOSE  _ITENSCOMP
CLOSE  _COMPRAS
return NIL

*****************************************
static function TbCompra(FCpCod,FCpFor)
*****************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
public VCOD:={}, VQTD:={} , VPrecoCusto:= {} , VPrecoVenda:={} , VPerc:={} , NInserir := .F.
public VICMS:={}, VIPI:= {} , VICMSC:= {}, VPRECOINI:={},VTEMICMSRET:={}
set cursor off
OBJETO           := tbrowsenew(09,02,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
@ 08,02 to 08,77
@ 08,01 say "Ã"
@ 08,78 say "´"
NInserir := .T.
if LEN(VCOD)=0
   TbCompraInsert()
endif
if NInserir == .F.
   Return nil
endif
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}
OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}
oCol := TBCOLUMNNEW( "C¢d.", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( " Produto", {|| Ret_Pro(VCOD[ponteiro])})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "Qtde", {|| VQTD[ponteiro]})
oCol:picture := "9999.999"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "PCusto Inicial", {|| VPRECOINI[ponteiro]})
oCol:picture := "999999999.999"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "% ICMS Retido", {|| VICMSC[ponteiro]})
oCol:picture := "99.999"
oCol := TBCOLUMNNEW( "Retem ICMS?", {|| VTEMICMSRET[ponteiro]})
oCol:picture := "!"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "% IPI Compra", {|| VIPI[ponteiro]})
oCol:picture := "99.99"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "PCusto Final", {|| VPrecoCusto[ponteiro]})
oCol:picture := "999999999.999"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "% ICMS Compra", {|| VICMS[ponteiro]})
oCol:picture := "99.999"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "Pre‡o Venda", {|| VPrecoVenda[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)
oCol := TBCOLUMNNEW( "% Lucro", {|| VPerc[ponteiro]})
oCol:picture := "999.99"
OBJETO:addColumn(oCol)
NInserir := .T.
while .T.
   if LEN(VCOD)=0 .AND. !NInserir
      TbCompraInsert()
   endif
   if NInserir == .F.
      restscreen(0,0,24,79,TELA01)
      set cursor on
      Return nil
   endif
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
          HelpVar("Mensagem: Inicio de Arquivo",80,23,00)
          setcursor(SC_NONE)
       elseif OBJETO:hitBottom
          tone(1000,2)
          HelpVar("Mensagem: Fim de Arquivo",80,23,00)
          setcursor(SC_NONE)
       else
          HelpVar("Mensagem: <Enter+Enter>Fechar <Enter>Inserir <Del>Excl. <Space>Editar",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  TBCMoveCursor( NKEY, OBJETO, Ponteiro )
enddo
restscreen(0,0,24,79,TELA01)
return nil

*******************************************************
static function TbCMoveCursor( NKEY, OOBJ, PONTEIRO )
*******************************************************
local NFOUND
AKEYS := ;
    { K_DOWN      , {|B| B:down()},;
      K_UP        , {|B| B:up()},;
      K_PGDN      , {|B| B:pageDown()},;
      K_PGUP      , {|B| B:pageUp()},;
      K_CTRL_PGUP , {|B| B:goTop()},;
      K_CTRL_PGDN , {|B| B:goBottom()},;
      K_RIGHT     , {|B| B:right()},;
      K_LEFT      , {|B| B:left()},;
      K_HOME      , {|B| B:home()},;
      K_END       , {|B| B:end()},;
      K_CTRL_LEFT , {|B| B:panLeft()},;
      K_CTRL_RIGHT, {|B| B:panRight()},;
      K_CTRL_HOME , {|B| B:panHome()},;
      K_CTRL_END  , {|B| B:panEnd()} }
   NFOUND := ascan( AKEYS, NKEY )
   if NFOUND != 0
      eval( AKEYS[++NFOUND], OOBJ )
   endif
   do case
      case nkey = K_ENTER
           TbCompraInsert()
      case nkey = K_SPACE
           TbCompraEdit(PONTEIRO)
      case nkey = K_DEL
           TbCompraDel(PONTEIRO)
      case nkey = K_F4
           TbFecha_Compra(FCpCod,FCpFor)
   endcase
return (NFOUND != 0)

************************
function TbCompraInsert()
************************
local GETLIST:={}, TELA_INSERT:=savescreen(0,0,24,79), DATA_ANTERIOR
local QTDVENDA:=0 , PRECO_CUSTO:=0 , PRECO_VENDA:=0 , PRECO := 0
local ICMS:= 0 , IPI:= 0 , Margem:=0,TEMICMSRET:=" "
local ICMSC:=0 , PRECO_INI:=0, CustoIni:=0
CODIGO := 0
DATA_ANTERIOR:=ctod("01/01/91") ; FORNECEDOR := 0
Select _PRODUTOS
Set Order to 1
moldura(04,02,21,74,.f.," M¢dulo de Compra ")
set cursor on
HelpVar("Mensagem: <F10> Calculadora <F2> Pesquisa Produto",80,23,00)
@ 23,60 say "Incluindo Item!!" color [W*/gr+]
Altera_Preco := .F.
do while .T.
 set key K_F2 to Produto_Help()
 @ 6,19 say "Produto:" get CODIGO pict "9999"
 @ 6,33 say "- "
 read
 set key K_F2 to
 dbseek(CODIGO)
 if CODIGO > 0
    if !found()
       Alerta(10,15," Produto N„o Cadastrado.!")
       loop
    endif
 endif
 if ! Altera_Preco
    PrecoVenda := PrPVenda
    ICMSC := ICMS := PrICMS
    IPI := PrIPI
    Margem := PrML
    PRECO_INI := PrPCusto
 endif
 testa("_PRODUTOS",CODIGO,,6,35,"PrNome")
 if CODIGO > 0
   select _ITENSCOMP
   set order to 2
   if dbseek(CODIGO)
      dbseek(CODIGO-1,.T.)
      do while !EOF()
         if CODIGO = ICCODPR
            select _COMPRAS
            set order to 5
            dbseek(_ITENSCOMP->NDOC_COM)
            if DATA_ANTERIOR<=CPDATA
               DATA_ANTERIOR:= CPDATA
               FORNECEDOR   := CPFOR
               ESTOQUE_ANT  := _ITENSCOMP->EST_ANT
               CustoIni     := _ITENSCOMP->PCustoIni
               ICMS         := _ITENSCOMP->IcPrICMS
               IPI          := _ITENSCOMP->IcPrIPI
               Margem       := _ITENSCOMP->IcPrML
               ICMSC        := _ITENSCOMP->IcPrICMC
               PRECO        := _ITENSCOMP->ICPuni
            endif
         elseif Codigo < ICCODPR
            exit
         endif
         select _ITENSCOMP
         set order to 2
         dbskip()
      enddo
      if FORNECEDOR <> 0
         @ 14,15 say "COMPRA ANTERIOR" color["&cor_Titulo"]
         @ 15,15 say "    Fornecedor: "
         testa("_FORNECED",FORNECEDOR,,15,32,"ForNome")
         @ 16,15 say "Data da Compra: " + dtoc(DATA_ANTERIOR)
         @ 16,42 say "       Est. Anterior: "+ str(ESTOQUE_ANT)
         @ 17,07 say "Pre‡o de Custo Inicial: " + alltrim(str(CustoIni,10,2))
         @ 17,42 say "Pre‡o de Venda Atual: " + alltrim(str(_PRODUTOS->PrPVenda,10,2))
         @ 18,09 say "ICMS Retido na Fonte: " + str(ICMSC)
         @ 18,59 say "IPI: " + str(IPI)
         @ 19,14 say "Margem de Lucro: " + str(Margem)
         @ 19,49 say "ICMS de Venda: " + str(ICMS)
         @ 20,09 say "Pre‡o de Custo Final: " + alltrim(str(Preco,10,2))
      endif
   else
      @ 13,15 say "COMPRA ANTERIOR" color ["&cor_Titulo"]
      @ 14,15 say "Nenhuma ocorrencia encontrada" color ["&cor_Titulo"]
      @ 16,15 say "Pre‡o de Venda Atual: " + alltrim(str(PrecoVenda,10,2))
   endif
   set order to 1
   Select _PRODUTOS
 endif
 if len(VCOD) == 0 .and. Codigo == 0
    restscreen(0,0,24,79,TELA_INSERT)
    NInserir := .F.
    return nil
 endif
 if Codigo == 0 .and. len(VCOD) > 0
    TbFecha_Compra(FCpCod,FCpFor)
    restscreen(0,0,24,79,TELA_INSERT)
    return nil
 endif
 if Altera_Preco
    Margem := FMargem
 endif
 @ 08,22 say "Qtde:" get QTDVENDA     pict "9999.999" valid(QTDVENDA>0 ;
        .and. TESTA_QUANTIDADE(CODIGO,QTDVENDA,0,.F.))
 @ 08,45 say "Preco Custo:" get PRECO_INI  pict "@E 9,999,999.999"  ;
         valid(PRECO_INI>0)
 @ 09,03 say "ICMS Retido?" get TEMICMSRET Pict "@!" valid( TEMICMSRET $ "SN")
 @ 09,22 say "ICMS Retido (%):" get ICMSC  pict "@E 99.99"
 @ 09,49 say "IPI (%):"  get IPI    pict "@E 99.99"
 @ 10,12 say "Custo Fixo (%):"  + str(ValorFixo)
 read
 PRECO_CUSTO := PRECO_INI * (1 + (ICMSC/100)+ (IPI/100) +(ValorFixo/100))
 @ 10,39 say "Preco Custo Final:" + str(PRECO_CUSTO,7,2)
 @ 11,13 say "ICMS Venda(%):" get ICMS  pict "@E 99.99"
 @ 11,37 say "Margem de Lucro (%):" get Margem pict "@E 999.99"
 read
 if lastkey()==K_ESC
    restscreen(0,0,24,79,TELA_INSERT)
    if len(VCOD) == 0
       NInserir := .F.
    endif
    return nil
 endif
 PRECO_VENDA:= PRECO_CUSTO * (1 +(ICMS/100) +(Margem/100))
 PRECO_ANT := PRECO_VENDA
 @ 12,15 say "Preco Venda:"  get PRECO_VENDA  pict "@E 9,999,999.99"  ;
                             valid(PRECO_VENDA>=PRECO_CUSTO)
 read
 if PRECO_ANT <> PRECO_VENDA
    FMargem := 100 * ((PRECO_VENDA/PRECO_CUSTO)-1-(ICMS/100))
    Altera_Preco := .T.
    loop
 endif
 if confirma(" Confirma Compra de ¡tem ?") == 2
    loop
 else
    exit
 endif
enddo
set cursor off
restscreen(0,0,24,79,TELA_INSERT)
aadd(VCOD , CODIGO)
aadd(VQTD , QTDVENDA)
aadd(VPrecoCusto , PRECO_CUSTO)
aadd(VPrecoVenda , PRECO_VENDA)
aadd(VPerc,Margem)
aadd(VICMS , ICMS)
aadd(VIPI  , IPI)
aadd(VICMSC,ICMSC)
aadd(VTEMICMSRET,TEMICMSRET)
aadd(VPRECOINI,PRECO_INI)
SomaCompra(.F.)
SomaCompra(.T.)
NInserir := .T.
keyboard chr(24)+chr(25)
return nil

****************************
function TbCompraEdit(IND)
****************************
local GETLIST:={}, TELA_INSERT:=savescreen(0,0,24,79)
CODIGO      := VCOD[IND]
CAnterior   := CODIGO
QTDVENDA    := VQTD[IND]
PRECO_CUSTO := VPrecoCusto[IND]
PRECO_VENDA := VPrecoVenda[IND]
ICMS        := VICMS[IND]
IPI         := VIPI[IND]
Margem      := VPerc[IND]
TEMICMSRET  := VTEMICMSRET[IND]
ICMSC       := VICMSC[IND]
PRECO_INI   := VPRECOINI[IND]
Select _PRODUTOS
Testa("_PRODUTOS",CODIGO,,06,35,"PrNome")
moldura(04,02,15,74,.f.," M¢dulo de Compra ")
set cursor on
HelpVar("Mensagem: <F10> Calculadora <F2> Pesquisa Produto",80,23,00)
@ 23,60 say "Editando Item!!" color [W*/gr+]
Altera_Preco := .F.
FMargem := 0
do while .T.
   set key K_F2 to Produto_Help()
   @ 6,19 say "Produto:"    get CODIGO     pict "9999" valid (Testa("_PRODUTOS",CODIGO,,6,35,"PrNome"))
   @ 6,33 say "- "
   read
   set key K_F2 to
   dbseek(CODIGO)
   if ! Altera_Preco .AND. CAnterior <> CODIGO
      PrecoVenda := PrPVenda
      ICMSC := ICMS := PrICMS
      IPI := PrIPI
      Margem := PrML
      PRECO_INI := PrPCusto
   endif
   if Altera_Preco
      Margem := FMargem
   endif
   @ 08,22 say "Qtde:" get QTDVENDA     pict "999.999" valid(QTDVENDA>0 ;
          .and. TESTA_QUANTIDADE(CODIGO,QTDVENDA,0,.F.))
   @ 08,45 say "Preco Custo:" get PRECO_INI  pict "@E 9,999,999.99"  ;
           valid(PRECO_INI>0)
   @ 09,03 say "ICMS Retido?" get TEMICMSRET Pict "@!" valid( TEMICMSRET $ "SN")
   @ 09,22 say "ICMS Retido (%):" get ICMSC  pict "@E 99.99"
   @ 09,49 say "IPI (%):"  get IPI    pict "@E 99.99"
   @ 10,12 say "Custo Fixo (%):"  + str(ValorFixo)
   read
   PRECO_CUSTO := PRECO_INI * (1 + (ICMSC/100)+ (IPI/100) +(ValorFixo/100))
   @ 10,39 say "Preco Custo Final:" + str(PRECO_CUSTO,7,2)
   @ 11,13 say "ICMS Venda(%):" get ICMS  pict "@E 99.99"
   @ 11,37 say "Margem de Lucro (%):" get Margem pict "@E 999.99"
   read
   if lastkey()==K_ESC
      restscreen(0,0,24,79,TELA_INSERT)
      if len(VCOD) == 0
         NInserir := .F.
      endif
      return nil
   endif
   PRECO_VENDA:= PRECO_CUSTO * (1 +(ICMS/100) +(Margem/100))
   PRECO_ANT := PRECO_VENDA
   @ 12,15 say "Preco Venda:"  get PRECO_VENDA  pict "@E 9,999,999.99"  ;
                               valid(PRECO_VENDA>=PRECO_CUSTO)
   read
   if PRECO_ANT <> PRECO_VENDA
      FMargem := 100* ((PRECO_VENDA/PRECO_CUSTO)-1-(ICMS/100))
      Altera_Preco := .T.
      loop
   endif
   if confirma(" Confirma Compra de ¡tem ?") == 2
      loop
   else
      exit
   endif
enddo
set cursor off
restscreen(0,0,24,79,TELA_INSERT)
VCOD[IND]       := CODIGO
VQTD[IND]       := QTDVENDA
VPrecoCusto[IND]:= PRECO_CUSTO
VPrecoVenda[IND]:= PRECO_VENDA
VPerc[IND]      := Margem
SomaCompra(.F.)
SomaCompra(.T.)
NInserir := .T.
keyboard chr(24)+chr(25)
return nil

*************************
function TbCompraDel(IND)
*************************
adel(VCOD,IND)
adel(VQTD,IND)
adel(VPrecoCusto,IND)
adel(VPrecoVenda,IND)
adel(VPerc,IND)
adel(VICMS,IND)
adel(VIPI,IND)
adel(VTEMICMSRET,IND)
adel(VICMSC,IND)
adel(VPRECOINI,IND)
asize(VQTD,len(VCOD)-1)
asize(VPrecoCusto,len(VCOD)-1)
asize(VPrecoVenda,len(VCOD)-1)
asize(VPerc,len(VCOD)-1)
asize(VICMS,len(VCOD)-1)
asize(VIPI,len(VCOD)-1)
asize(VTEMICMSRET,len(VCOD-1))
asize(VICMSC,len(VCOD)-1)
asize(VPRECOINI,len(VCOD)-1)
asize(VCOD,len(VCOD)-1)
SomaCompra(.F.)
SomaCompra(.T.)
if len(VCOD) == 0
   NInserir := .F.
endif
return nil

***************************************
Function TbFecha_Compra(FCpCod,FCpFor)
****************************************
local INDICE , Total_Pagar := SomaCompra(.T.) , Conf := space(01), Cont_Err:=0
local Cor_Antiga := Setcolor() , Tela_Fechamento := savescreen(0,0,maxrow(),maxcol())
Num_Doc := val(alltrim(str(FCpCod) + strzero(FCpFor,3)))
SetColor("W/Bg+")
Moldura(11,14,19,57,.f.," Fechamento da Compra ")
Set Cursor on
@ 12,37 say "Total: " + str(Total_Pagar,11,3)
@ 14,32 say "Confirma Compra ? (S/N)" Get Conf Pict "@!" valid( Conf $ "SN")
Read
if lastkey()=K_ESC
   SetColor(Cor_Antiga)
   restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
   return nil
endif
if Conf == "S"
   if LEN(VCOD) > 0
      do while .t.
         Cont_Err++
         USE N_DOCCOM ALIAS "_N_DOCCOM" EXCLUSIVE NEW
         if NETERR()
            if select("N_DOCCOM") > 0
               close _N_DOCCOM
            endif
            if Cont_Err>100
               alert("Erro de abertura; de Arquivo!!!")
               quit
            endif
            loop
           else
            set index to NDOCCOMP
            exit
         endif
      enddo
      dbgotop()
      if eof()
         dbappend()
         replace N_DOCCOMPR with 0
      endif
      FNDOC_COM:=(N_DOCCOMPR+1)
      replace N_DOCCOMPR with FNDOC_COM
      close _N_DOCCOM
      TipoPagt := P15 := P30 := space(01)
      @ 16,16 say "Forma de Pagamento (A Vista ou Prazo) : "
      @ 16,col() get TipoPagt pict "@!" valid( TipoPagt $ "PV") ;
        when(Help_Mensagem("Digite 'V' p/ Pag. A Vista ou 'P' p/ Pag. a Prazo ou 'ESC' Para Cancelar Compra "))
      Read
      if lastkey()=K_ESC
         SetColor(Cor_Antiga)
         restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
         return nil
      endif
      if TipoPagt == "V"
         FCpNParc := 0
      else
         Tela_Pagt := savescreen(05,15,18,60)
         Botao(06,15,18,60,.F.)
         QuantasPagt := 0
         Salva_Linha := savescreen(23,0,23,maxcol())
         @ 07,36  say "Numero de Parcelas :" color [B/W]
         @ 07,col() get QuantasPagt  pict "99" valid(QuantasPagt > 0) ;
           when(Help_Mensagem("Digite o N£mero de Parcelas ou 'ESC' Para Cancelar Compra"))
         Read
         FCpNParc := QuantasPagt ; Soma_Data := 0
         @ 08,16 say repl("-",43) color [n/w]
         @ 09,17 say "Digite o Intervalo Entre os Pagamentos :" color [B/W]
         @ 09,58 get Soma_Data pict "99" valid(Soma_Data>0 .and. Soma_Data<31);
                 send colorSpec := "b/w,r/w"
         read
         if lastkey()=K_ESC
            SetColor(Cor_Antiga)
            restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
            return nil
         endif
         restscreen(23,0,23,maxcol(),Salva_Linha)
         Declare VData[QuantasPagt] , VValor[QuantasPagt]
         Valor = Total_Pagar / QuantasPagt
         @ 11,17 say " Parcela " color [B/W]
         @ 11,27 say " Data " color [B/W]
         @ 11,40 say " Valor "   color [B/W]
         Lin := 11
         For i := 1 to QuantasPagt
            VData[i] := FCpData + Soma_Data*I
            VValor[i] := Valor
         EndFor
         ind := 1
         Velha_Cor := Setcolor()
         setcolor('w/w')
         For i := 1 to QuantasPagt
            @ Lin+ind,22 say alltrim(str(i))  color [B/W]
            @ Lin+ind,27 get VData[i]  pict "99/99/99" send colorSpec := "b/w,r/w"
            @ Lin+ind,40 get VValor[i]                 send colorSpec := "b/w,r/w"
            read
            if lastkey()=K_ESC
               SetColor(Cor_Antiga)
               restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
               return nil
            endif
            ind++
            if mod(i,5) == 0
               @ Lin+1,22 clear to Lin+ind-1,58
               ind := 1
            endif
         endfor
         SetColor("&Velha_Cor")
         restscreen(05,15,18,60,Tela_Pagt)
         OPEN PAGAMENT ALIAS "_PAGAMENT" INDEX CO10_PGT,PGTODOC,PGTOFOR SHARED
         set order to 1
         dbgobottom()
         For i := 1 to QuantasPagt
           do while !N_ADDREC()
           enddo
           field->PgNumDoc   := Num_Doc
           field->NDOC_COM   := FNDoc_Com
           field->PgValorPrv := VValor[i]
           field->PgDataPrv  := VData[i]
           unlock
         next
         close _PAGAMENT
      endif
      select _COMPRAS
      do while !N_ADDREC()
      enddo
      REPLY_VAR(.T.)
      unlock
      select _ITENSCOMP
      go bottom
      for INDICE=1 to LEN(VCOD)
       do while !N_ADDREC()
       enddo
       FIcCod := FCpCod
       field->NDOC_COM   := FNDoc_Com
       field->IcCod      := Num_Doc
       field->IcData     := FCpData
       field->IcCodPr    := VCOD[INDICE]
       field->IcQtd      := VQTD[INDICE]
       field->IcPUni     := VPrecoCusto[INDICE]
       field->IcPrICMS   := VICMS[INDICE]
       field->IcPrIPI    := VIPI[INDICE]
       field->IcPrML     := VPerc[INDICE]
       field->TemICMSRet := VTEMICMSRET[INDICE]
       field->IcPrICMC   := VICMSC[INDICE]
       field->PCustoIni  := VPRECOINI[INDICE]
       select _PRODUTOS
       set order to 1
       dbseek(VCOD[INDICE])
       select _ITENSCOMP
       field->Est_Ant  := _PRODUTOS->PREATUAL
       unlock
      next
      Select _PRODUTOS
      Set order to 1
      dbgotop()
      For Indice=1 to LEN(VCOD)
        dbseek(VCOD[INDICE])
        do while ! rlock()
        enddo
        field->PrPVenda := VPrecoVenda[INDICE]
        field->PrPCusto := VPrecoCusto[INDICE]
        field->PrICMS   := VICMS[INDICE]
        field->PrIPI    := VIPI[INDICE]
        field->PrML     := VPerc[INDICE]
        unlock
      next
      MV_ESTOQUE(.T.,LEN(VCOD),VCOD,VQTD,"E")
   endif
endif
VCOD :={}; VQTD :={}; VPrecoCusto :={}; VPrecoVenda :={}; VPerc :={}
VICM :={}; VIPI :={}
keyboard chr(27)
NInserir := .F.
SetColor(Cor_Antiga)
restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
return nil

*************************
function SomaCompra(Tipo)
*************************
Local Soma := 0 , I
for I := 1 to Len(VPrecoCusto)
  Soma+=(iif(!Tipo,VPrecoCusto[I],VPRECOINI[I])*VQTD[I])
next
if Tipo
   @ 20,15 say "TOTAL N.F.: " + str(Soma,11,3) color ["&cor_Titulo"]
else
   @ 20,55 say "TOTAL: " + str(Soma,11,3) color ["&cor_Titulo"]
endif
return Soma

*******************
function CCOMPRA()
*******************
local GETLIST:={} , CONF := " " , NDoc := 0 , Cod_For := 0 , Achou := .F.
public NF:={}, DTCOMPR:={} , VALORCOM :={} , TIPOPGTO:={} , DOC_COMPR := {}
if Testa_EData("Cancelamento das Compras ‚ Efetuado Apenas No Mes Corrente..")
   Return nil
endif
if !TRotina(8)
   Return nil
endif
apaga(.T.)
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC SHARED
Set order to 3
inic_var()
moldura(16,40,18,74,.F.," Cancelamento da Compra ")
HelpVar("<Esc> - Sai <F2> Pesquisa Fornecedor",70,23,10)
set key K_F2 to For_Help()
@ 17,42 say "C¢digo Fornecedor :" get Cod_For pict "999"    valid (!EMPTY(Cod_For) .or. Cod_For > 0)
read
set key K_F2 to
if lastkey()=K_ESC
   CLOSE _COMPRAS
   CLOSE _FORNECED
   CLOSE _ITENSCOMP
   return nil
Endif
if Dbseek(Cod_For)
   TbMostraCompra(Cod_For)
else
   Alert("N„o Houve Compra;Desse Fornecedor")
endif
close _COMPRAS
close _FORNECED
close _ITENSCOMP
set delimiters off
return NIL

*****************************************
static function TbMostraCompra(Cod_For)
*****************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
private DOC_CANCEL:=0
set cursor off
OBJETO           := tbrowsenew(07,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_MCompra(Cod_For)
if LEN(NF)=0
   return nil
endif
moldura(04,02,21,78,.F.," Cancelamento de Compra ")
@ 05,03 say "C¢d. Fornecedor: " color ["&cor_Apresentacao"]
@ 05,22 say + alltrim(str(Cod_For)) + " - "
testa("_FORNECED",Cod_For,,05,26,"ForNome")
select _COMPRAS
@ 06,03 to 06,77

OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(NF)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(NF)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(NF)}
OBJETO : goTopblock := {||ponteiro := 1}

OCOLUNA := tbcolumnnew(" û" , {|| iif(DOC_COMPR[ponteiro]=DOC_CANCEL," û", "  ")})
OBJETO:addColumn(OCOLUNA)

oCol := TBCOLUMNNEW( "Nota Fiscal", {|| NF[ponteiro]})
oCol:picture := "999999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Data da Compra", {|| DTCOMPR[ponteiro]})
oCol:picture := "99/99/9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Total da Compra", {|| VALORCOM[ponteiro]})
oCol:picture := "99999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Tipo de Pagamento", {|| TIPOPGTO[ponteiro] })
OBJETO:addColumn(oCol)
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
          HelpVar("Mensagem: Inicio de Arquivo",80,23,00)
          setcursor(SC_NONE)
       elseif OBJETO:hitBottom
          tone(1000,2)
          HelpVar("Mensagem: Fim de Arquivo",80,23,00)
          setcursor(SC_NONE)
       else
          HelpVar("Mensagem: <Enter> Cancelar Compra <Space> Seleciona/Exibe Itens",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TBcTeclas(NKEY,OBJETO,Ponteiro)
     if NKEY == K_ESC .or. NKEY==K_ENTER
        return nil
     endif
  endif
enddo
return nil

******************************
Function Rel_MCompra(Cod_For)
******************************
dbgotop()
Dbseek(Cod_For,.T.)
do while .t.
  if CpFor >= Cod_For
     dbskip(-1)
  elseif CpFor < Cod_For
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if CpFor == Cod_For
      aadd(NF,CpCod)
      aadd(DOC_COMPR,NDoc_Com)
      aadd(DtCompr,CpData)
      aadd(ValorCom,Ret_Total(NDoc_Com))
      aadd(TipoPGTO,(iif(CPNParc>0,"Prazo","Vista")))
   elseif CpFor > Cod_For
      exit
   endif
   dbskip()
enddo
return nil

*****************************
Function Ret_Total(ND_Compra)
*****************************
local Total := 0
Select _ITENSCOMP
set order to 4
dbgotop()
Dbseek(NDoc_Com,.T.)
do while .t.
  if NDoc_Com >= ND_Compra
     dbskip(-1)
  elseif NDoc_Com < ND_Compra
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if NDoc_Com == ND_Compra
      Total += (IcQTD*IcPUni)
   elseif NDoc_Com > ND_Compra
      exit
   endif
   dbskip()
enddo
Select _Compras
return Total

****************************************************
static function TbTeclas( NKEY, OOBJ, PONTEIRO )
****************************************************
local NFOUND
AKEYS := ;
    { K_DOWN      , {|B| B:down()},;
      K_UP        , {|B| B:up()},;
      K_PGDN      , {|B| B:pageDown()},;
      K_PGUP      , {|B| B:pageUp()},;
      K_CTRL_PGUP , {|B| B:goTop()},;
      K_CTRL_PGDN , {|B| B:goBottom()},;
      K_RIGHT     , {|B| B:right()},;
      K_LEFT      , {|B| B:left()},;
      K_HOME      , {|B| B:home()},;
      K_END       , {|B| B:end()},;
      K_CTRL_LEFT , {|B| B:panLeft()},;
      K_CTRL_RIGHT, {|B| B:panRight()},;
      K_CTRL_HOME , {|B| B:panHome()},;
      K_CTRL_END  , {|B| B:panEnd()} }

   NFOUND := ascan( AKEYS, NKEY )
   if NFOUND != 0
      eval( AKEYS[++NFOUND], OOBJ )
   endif
   return (NFOUND != 0)

*********************************
static function Mostra_IC(NDoc)
*********************************
local getlist:={},OBJ,T_MostraIc:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONT:=1, PRECO:=0, NKEY
public VCOD:={}, VQTD:={} , VSUBTOTAL:={} , VPRE:={} , VNOMEPRO:={} , Num_Doc := 0
set cursor off
OBJ           := tbrowsenew(08,03,19,77)
OBJ:colSep    := COLSEP
OBJ:headSep   := HEADSEP
OBJ:footSep   := FOOTSEP
OBJ:colorSpec := MYCOLORS

Select _ITENSCOMP
set order to 4
dbgotop()
Dbseek(NDoc,.T.)
do while .t.
  if NDoc_Com >= NDoc
     dbskip(-1)
  elseif NDoc_Com < NDoc
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if NDoc_Com == NDoc
      aadd(VCOD,IcCodPr)
      aadd(VQTD,IcQtd)
      aadd(VPRE,IcPUni)
      aadd(VSUBTOTAL,IcQtd*IcPUni)
   elseif NDoc_Com > NDoc
      exit
   endif
   dbskip()
enddo
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
For Indice := 1 To Len(VCOD)
    AADD(VNOMEPRO,Ret_PRO(VCOD[Indice]))
next
close _PRODUTOS
if LEN(VCOD)=0
   return nil
endif
moldura(04,02,21,78,.F.," Cancelamento de Compra ")
@ 05,06 say "Itens de Compra" color ["&cor_Apresentacao"]
@ 07,03 to 07,77
OBJ : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-pont,pont-1),;
                        if(Tam >= 0,Len(VCOD)-pont,1-pont),;
                        Tam),pont += nMoved,nMoved}

OBJ : goBottomblock := {||pont := len(VCOD)}
OBJ : goTopblock := {||pont := 1}


oCol := TBCOLUMNNEW( "C¢digo", {|| VCOD[pont]})
oCol:picture := "9999"
OBJ:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[pont]})
oCol:picture := "!!!!!!!!!!!!!!!!!!!!"
OBJ:addColumn(oCol)

oCol := TBCOLUMNNEW( "Quantidade", {|| VQTD[pont]})
oCol:picture := "9999.999"
OBJ:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| VPRE[pont] })
oCol:picture := "999999999.99"
OBJ:addColumn(oCol)

oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[pont]})
oCol:picture := "999999999.99"
OBJ:addColumn(oCol)
while .T.
   dispbegin()
   obj:refreshall()
   while !obj:stabilize() ; end
   dispend()
   if OBJ:stable
     L:=row() ; C:=col()
     OBJ:colorRect({OBJ:rowPos,1,OBJ:rowPos,OBJ:colCount},{2,2})
     do while ! OBJ:stabilize() ; enddo
       if OBJ:hitTop
          tone(1000,2)
          HelpVar("Mensagem: Inicio de Arquivo",80,23,00)
          setcursor(SC_NONE)
       elseif OBJ:hitBottom
          tone(1000,2)
          HelpVar("Mensagem: Fim de Arquivo",80,23,00)
          setcursor(SC_NONE)
       else
          HelpVar("Mensagem: <Esc> ou <ENTER> Retornar",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TbTeclas( NKEY, OBJ, Pont )
      if ( nKey == K_ESC ) .or. (nKey == K_ENTER)
         restscreen(0,0,24,79,T_MostraIc)
         exit
      endif
   endif
enddo
return nil

*****************************************
function TBcTeclas(NKEY,OBJETO,Ponteiro)
*****************************************
local NFOUND
AKEYS := ;
    { K_DOWN      , {|B| B:down()},;
      K_UP        , {|B| B:up()},;
      K_PGDN      , {|B| B:pageDown()},;
      K_PGUP      , {|B| B:pageUp()},;
      K_CTRL_PGUP , {|B| B:goTop()},;
      K_CTRL_PGDN , {|B| B:goBottom()},;
      K_RIGHT     , {|B| B:right()},;
      K_LEFT      , {|B| B:left()},;
      K_HOME      , {|B| B:home()},;
      K_END       , {|B| B:end()},;
      K_CTRL_LEFT , {|B| B:panLeft()},;
      K_CTRL_RIGHT, {|B| B:panRight()},;
      K_CTRL_HOME , {|B| B:panHome()},;
      K_CTRL_END  , {|B| B:panEnd()} }

   NFOUND := ascan( AKEYS, NKEY )
   if NFOUND != 0
      eval( AKEYS[++NFOUND], OBJETO )
   endif
   do case
      case nkey = K_ENTER
         if DOC_CANCEL <> 0
            Cancela_Compra(DOC_COMPR[ponteiro])
         else
            alert("Vocˆ necessita selecionar ;alguma compra para ser cancelado!!!!")
         endif
      case nkey = K_SPACE
         Mostra_IC(DOC_COMPR[ponteiro])
         DOC_CANCEL:=DOC_COMPR[ponteiro]
   endcase
return (NFOUND != 0)

*****************************
function Cancela_Compra(NDOC)
*****************************
local Excluir_Pagamento , Conf := " "
select _COMPRAS
if CpNParc = 0
   Excluir_Pagamento := .F.
else
  Excluir_Pagamento := .T.
endif
Cor_Antiga := SetColor()
SetColor("W/Bg+")
Set Cursor on
moldura(15,20,17,55,.f.," Cancelamento de Compra ")
@ 16,22 say "Confirma Cancelamento (S/N) ?" get Conf pict "@!" valid( Conf$"SN" )
Read
SetColor(Cor_Antiga)
if Conf = "S"
   @ 23,00 say Space(80)
   @ 23,00 say "Aguarde,Atualizado Arquivos de Compra,Produto e Pagamento" color ["W+*"]
   if Excluir_Pagamento
      OPEN PAGAMENT ALIAS "_PAGAMENT" INDEX CO10_PGT,PGTODOC,PGTOFOR SHARED
      set order to 2
      Dbgotop()
      Dbseek(NDoc,.T.)
      do while .T.
         if NDoc_Com >= NDoc
            Dbskip(-1)
          elseif NDoc_Com < NDoc
            exit
         endif
         if BOF()
            exit
         endif
       enddo
       do while !Eof()
          if NDoc = NDoc_Com
             rlock()
             delete
             unlock
          endif
          dbskip()
       enddo
       close _PAGAMENT
   endif
   OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
   select _ITENSCOMP
   set order to 4
   dbgotop()
   Dbseek(NDoc,.T.)
   do while .T.
      if NDoc_Com >= NDoc
         Dbskip(-1)
      elseif NDoc_Com < NDoc
        exit
      endif
      if BOF()
         exit
      endif
   enddo
   do while !Eof()
      if NDoc_Com = NDoc
         Codigo = IcCodPr
         Quantidade = IcQtd
         rlock()
         delete         
         unlock
         Select _PRODUTOS
         set order to 1
         dbgotop()
         if dbseek(Codigo)
            Est_Anterior := PrEAtual
            Est_Anterior := Est_Anterior - Quantidade
            rlock()
            field->PrEAtual := Est_Anterior
            unlock
            select _ITENSCOMP
         endif
      elseif NDoc_Com > NDoc
         exit
      endif
      dbskip()
   enddo
   select _COMPRAS
   set order to 5
   dbseek(NDoc)
   rlock()
   delete
   unlock
   close _PRODUTOS
   Alert("Cancelamento Efetuado..!")
endif
set delimiters off
return NIL
