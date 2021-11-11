
# include "INKEY.CH"
# include "PAN.CH"
# include "RCH.CH"
# include "SETCURS.CH"
# define  HEADSEP    "ÄÂÄ"
# define  COLSEP     " ³ "
# define  FOOTSEP    "ÄÁÄ"

********************
function MOVIMENTO()
********************
local GETLIST:={} , TELA_VENDA
Mostra_Cliente := .F.
if Testa_EData("Lan‡amento das Vendas ‚ Efetuado Apenas No Mes Corrente.." )
   Return nil
endif
if !TRotina(2)
   Return nil
endif
apaga(.T.)
HelpVar("<ESC> Encerra Venda <F10> Calculadora <F2> Produto",80,23,00)
apaga(.T.)
moldura(04,01,21,78,.f.," Caixa ")
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
set order to 1
do while .t.
 set key K_F2 to Help_Produto()
 TELA_VENDA := savescreen(0,0,maxrow(),maxcol())
 select _MOVIMENT
 Set order to 1
 inic_var()
 FCodCli := 0
 dbgobottom()
 if Lastrec() = 0
    FMovCod = 1
 else
    FMovCod = MovCod + 1
 endif
 FMovDt := date()
 FMovHr := Time()
 FMovOper:=1
 @ 05,62 say "Hora : " + FMovHr
 OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
 if lastrec()=0
    Alerta(11,15,"N„o H  Nenhuma Opera‡„o Cadastrada!!")
    close Database
    return nil
 endif
 @ 05,04 say "N.Documento :" + alltrim(str(FMovCod))
 @ 05,25 say    "Opera‡„o :" get FMovOper  pict "99" ;
   valid(pesquisa(06,25,12,65,"_OPERACOE",FMovOper,"OperCod","OperNome"," Opera‡ao ") ;
   .and. !Empty(FMovOper) .and. testa("_OPERACOE",FMovOper,,05,39,"OperNome"))
 read
 select _OPERACOE
 set order to 1
 if dbseek(FMovOper)
    if OperTipo = "N"
       Mostra_Cliente := .T.
       Nova_Lin := 06
    else
       Mostra_Cliente := .F.
       Nova_Lin := 07
    endif
    Nova_Lin := 07
 endif
 close _OPERACOE
 OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
 if lastrec()=0
    Alerta(11,15,"N„o H  Nenhum Funmcion rio Cadastrado!!")
    close Database
    return nil
 endif
 select _MOVIMENT
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
    set key K_F2 to
    close _MOVIMENT
    close _FUNCIONA
    return nil
 endif
 HelpVar("<ENTER> Visualizar Dados de Funcion rio <ESC> Retorna <F10> Calculadora",80,23,00)
 @ 6,04 say "Funcion rio :" get FMovFunc PICT "99" ;
   valid(pesquisa2(08,10,14,50,"_FUNCIONA",FMovFunc,"FunCod","FuncNome"," Funcion rios ") ;
   .and. !Empty(FMovFunc) .and. testa("_FUNCIONA",FMovFunc,,Nova_Lin,22,"FuncNome"))
 read
 OPEN CARGOS ALIAS "_CARGOS" INDEX CargCod,CargNome SHARED
 set order to 1
 dbgotop()
 dbseek(_FUNCIONA->FuncCarg)
 if HabilitaVC <> "S"
    Alerta(11,15,"Funcion rio N„o Est  Habilitado Para Execu‡„o da Fun‡„o..")
    restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
    close _FUNCIONA
    close _CARGOS
    loop
 endif
 close _FUNCIONA
 close _CARGOS

 OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
 if lastrec()=0
    Alerta(11,15,"N„o H  Nenhum Cliente Cadastrado!!")
    close Database
    return nil
 endif
 @ 7,04 say "Cod.Cliente :" get FCodCli PICT "999" ;
   valid(pesquisa2(08,03,14,53,"_CLIENTES",FCodCli,"ClCod","ClNome"," Clientes ") ;
.and. !Empty(FCodCli) .and. testa("_Clientes",FCodCli,,07,22,"ClNome"))
 read
 close _CLIENTES

 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
    close _MOVIMENT
    return nil
 endif
 set key K_F2 to
 OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
 TbVenda(FMovCod,FMovOper,FMovFunc,FCodCli)
 close _PRODUTOS
 restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
    loop
 endif
enddo
close _MOVIMENT
release VCOD ; release VQTD ; release VSUBTOTAL
release VPRE ; release NInserir
restscreen(0,0,maxrow(),maxcol(),TELA_VENDA)
return NIL

***********************************************************
Function TbFecha_Venda(FMovCod1,FMovOper,FMovFunc,FCodCli)
***********************************************************
 local INDICE , Conf := space(01), Cont_Err:=0
 local Cor_Antiga := Setcolor() , Tela_Fechamento := savescreen(0,0,maxrow(),maxcol())
 public Total_Pago := 0, Total_Custo:= Total_Liquido := Total_Desconto := 0 , Total_Pagar := SomaTotal(.F.,.F.)
 SetColor("W/Bg+")
 Set Cursor on
 OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
 dbseek(FMovOper)
 Nome_Operacao := alltrim(OperNome)
 Paga_Comissao := Paga_Com
 Tipo_Operacao := OperTipo
 Percentual    := "%"
 FDesconto     := 0
 Liquido:= Total_Pagar
 for I := 1 to Len(VPCUSTO)
    Total_Custo    += VPCUSTO[I]
 next
 Moldura(08,30,17,64,.f.," Fechamento da Venda ")
 @ 09,32 say "   Total Custo (R$):" + transf(Total_Custo,"999,999.99")
 @ 10,32 say "   Total Bruto (R$):" + transf(Total_Pagar,"999,999.99")
 @ 11,40 say "Desconto: " Get FDesconto Pict "999,999.99" valid FDesconto>=0
 @ 12,31 say "% ou Valor(% / V): " Get Percentual Pict "!" valid( Percentual $ "%V") // .and. Testa_Desconto())
 read
 if Percentual=="%"
    Liquido:= Total_Pagar-(Total_Pagar*(FDesconto/100))
 else
    Liquido:= Total_Pagar-FDesconto
    set decimals to 9
    FDesconto:=(FDesconto/Total_Pagar)*100
    set decimals to 2
 endif
 if Liquido<=0
    alert("Opera‡„o Imposs¡vel!!!; Valor L¡quido Deu Negativo!!!!")
    SetColor(Cor_Antiga)
    restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
    close _OPERACOE
    return nil
 endif
 if Liquido < Total_Custo
    if alert("Valor L¡quido Menor;Que Pre‡o de Custo;;Deseja Continuar",{"Sim","N„o"}) <> 1
       SetColor(Cor_Antiga)
       restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
       close _OPERACOE
       return nil
    endif
 endif
 @ 13,41 say "Liquido: " + str(Liquido,10,2)
 Total_Pago:=Liquido
 if (Nome_Operacao<>"ORCAMENTO" .and. Nome_Operacao<>"OR€AMENTO")
     @ 13,32 say "   Valor Pago  (R$):" Get Total_Pago Pict "999,999.99" ;
      valid (Testa_Troco(Total_Pago,Liquido))
    Read
    @ 14,31 say "          Troco (R$):" + str((Total_Pago - Liquido),10,2)
 endif
 if lastkey()=K_ESC
    SetColor(Cor_Antiga)
    restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
    close _OPERACOE
    return nil
 endif
 if Nome_Operacao=="ORCAMENTO" .or. Nome_Operacao=="OR€AMENTO"
    @ 16,31 say "Imprime<" +alltrim(Nome_Operacao)+"> (S/N)?" Get Conf Pict "@!" valid( Conf $ "SN")
    Read
  else
    @ 16,31 say "Confirma <" +alltrim(Nome_Operacao)+"> (S/N)" Get Conf Pict "@!" valid( Conf $ "SN")
    Read
 endif
 close _OPERACOE
 if lastkey()=K_ESC
    SetColor(Cor_Antiga)
    restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
    return nil
 endif
 if (Conf == "S") .and. (Nome_Operacao=="ORCAMENTO" .or. Nome_Operacao=="OR€AMENTO")
    if (FT_ISPRINTER(), IMP_VENDA(VCOD,VQTD,VPRE,Total_Pago), alert("Or‡amento conclu¡do.;Pressione algo para continuar!"))
 elseif Conf=="S"
   if (FT_ISPRINTER(), IMP_VENDA(VCOD,VQTD,VPRE,Total_Pago), alert("Venda conclu¡da.;Pressione algo para continuar!"))
   if LEN(VCOD) > 0
      do while .t.
         Cont_Err++
         USE N_DOC ALIAS "_N_DOC" EXCLUSIVE NEW
         if NETERR()
            if select("N_DOC") > 0
               close _N_DOC
            endif
            if Cont_Err>100
               alert("Erro de abertura; de Arquivo!!!")
               quit
            endif
            loop
         else
             set index to NOVODOC
             exit
         endif
      enddo
      select _MOVIMENT
      set order to 1
      dbgobottom()
      select _N_DOC
      set order to 1
      dbgotop()
      if eof()
         dbappend()
         replace N_DOC with 0
      endif
      FMovCod:= N_DOC+1
      replace N_DOC with FMovCod
      select _MOVIMENT
      set order to 1
      FTotal_Mov := Liquido
      do while !N_ADDREC() ; enddo
      REPLY_VAR(.F.)
      unlock
      OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
      Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
      set order to 1
      dbgobottom()
      Soma_Comis := 0
      for INDICE=1 to Len(VCOD)
          if VCOD[INDICE] > 0
             do while !N_ADDREC() ; enddo
             FImCod := FMovCod
             field->ImCod   := FImCod
             field->ImCdPro := VCOD[INDICE]
             field->ImQtd   := VQTD[INDICE]
             field->ImPreco := VPRE[INDICE]
             field->ImData  := FMovDt
             field->Desconto:= FDesconto
             select _Produtos
             dbseek(VCOD[INDICE])
             select _GRUPOS
             dbseek(_PRODUTOS->PrGrupo)
             if _GRUPOS->GPCOM = "S"
                Soma_Comis += (VQTD[INDICE]*VPRE[INDICE])-((VQTD[INDICE]*VPRE[INDICE])*(FDesconto/100))
             endif
             select _ITENSMOV
             unlock
          endif
       next
       If Soma_Comis > 0 .and. Paga_Comissao == "S"
          OPEN ESTFUNC ALIAS "_ESTFUNC" INDEX EST_VEND SHARED
          set order to 1
          dbgotop()
          if Dbseek(dtos(FMovDt)+str(FMovFunc))
             rlock()
             FTotal_Venda := TotalVenda
             FTotal_Cli   := Total_Cli
             field-> TotalVenda := (FTotal_Venda + Soma_Comis)
             field-> Total_Cli  := (FTotal_Cli+1)
             unlock
          else
             do while !N_ADDREC() ; enddo
             field-> COD_FUNC   := FMovFunc
             field-> DATA_VENDA := FMovDt
             field-> TotalVenda := Soma_Comis
             field-> Total_Cli  := 1
             unlock
          endif
          close _ESTFUNC
       endif
       close _N_DOC
       close _GRUPOS
       close _ITENSMOV
       If Tipo_Operacao  = "S" .or. Tipo_Operacao  = "N"
          // Estatistica de Grupo
          OPEN ESTGRUP ALIAS "_ESTGRUP" INDEX EST_GRUP SHARED
          set order to 1
          dbgotop()
          For INDICE := 1 to LEN(VCOD)
             if Dbseek(dtos(FMovDt)+str(VCGRUPO[INDICE],2))
                rlock()
                FTotal_Venda := TotalVenda
                field-> TotalVenda := FTotal_Venda + (VQTD[INDICE]*VPRE[INDICE])-((VQTD[INDICE]*VPRE[INDICE])*(FDesconto/100))
                unlock
             else
                do while !N_ADDREC() ; enddo
                field-> COD_GRUPO  := VCGRUPO[INDICE]
                field-> DATA_VENDA := FMovDt
                field-> TotalVenda := (VQTD[INDICE]*VPRE[INDICE])-((VQTD[INDICE]*VPRE[INDICE])*(FDesconto/100))
                unlock
             endif
          next
          close _ESTGRUP
       endif
       MV_ESTOQUE(.T.,LEN(VCOD),VCOD,VQTD,"S")
   endif
   if FCodCli > 0
      OPEN ITENSREC ALIAS "_ITENSREC" INDEX IRCodDt SHARED
      OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
      Select _RECEB
      Set Order to 1
      dbgobottom()
      do while !N_ADDREC() ; enddo
      field->Rec_Cod   := FMovCod
      field->Rec_Dt    := FMovDt
      field->Rec_Cli   := FCodCli
      field->Rec_Hr    := FMovHr
      field->Total_Rec := FTotal_Mov
      select _ITENSREC
      set order to 1
      dbgobottom()
      for INDICE=1 to Len(VCOD)
         if VCOD[INDICE] > 0
            do while !N_ADDREC() ; enddo
            FIrCod := FMovCod
            FIrDt  := FMovDt
            field->IrCod   := FIrCod
            field->IrDt    := FIrDt
            field->IrCdPro := VCOD[INDICE]
            field->IrQtd   := VQTD[INDICE]
            field->IrPreco := VPRE[INDICE]
            field->Desconto:= FDesconto
            unlock
         endif
      next
      OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
      set order to 1
      dbgotop()
      if dbseek(FCodCli)
         rlock()
         Total := CLValor
         field->CLValor   := FTotal_Mov + Total
         unlock
      else
         Alerta(11,10,"Erro de Iconsitencia, Avise o Programador..!")
      endif
      close _CLIENTES
      close _RECEB
      close _ITENSREC
   Endif
 Endif
 VCOD:={}; VQTD:={} ; VSUBTOTAL:={} ; VPRE:={}
 keyboard chr(27)
 NInserir := .F.
 TESTE:=.T.
 SetColor(Cor_Antiga)
 restscreen(0,0,maxrow(),maxcol(),Tela_Fechamento)
return nil
 
************************************************************
static function TbVenda(FMovCod,FMovOper,FMovFunc,FCodCli)
************************************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
public VCOD:={},VQTD:={},VSUBTOTAL:={},VPCUSTO:={},VPRE:={},VCGRUPO:={}
public NInserir,TESTE:=.F.
set cursor off
OBJETO           := tbrowsenew(09,02,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
@ 08,02 to 08,78
@ 08,01 say "Ã"
@ 08,78 say "´"
NInserir := .T.
if LEN(VCOD)=0
   TbVendaInsert()
endif
if len(VCOD) == 0
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
oCol:picture := "99999.999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Pre‡o Unit.", {|| Ret_PRECO(VCOD[ponteiro])})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Tot.Bruto", {|| Ret_Subtotal(VCOD[ponteiro],VQTD[ponteiro])})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

// oCol := TBCOLUMNNEW("Desconto", {|| VDEC[ponteiro]})
// oCol:picture := "999999999.99"
// OBJETO:addColumn(oCol)

// oCol := TBCOLUMNNEW("Tot.Liquido ", {|| VLIQUIDO[ponteiro]})
// oCol:picture := "999999999.99"
// OBJETO:addColumn(oCol)

NInserir := .T.
objeto:freeze := 2
objeto:colpos := objeto:freeze+1
while .T.
   if NInserir == .F.
      set cursor on
      Return nil
   endif
   if LEN(VCOD)=0 .AND. !NInserir
      TbVendaInsert()
   endif
   dispbegin()
   objeto:refreshall()
   while !objeto:stabilize() ; end
   dispend()
   if TESTE
      TbVendaInsert()
   endif
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
          HelpVar("Mensagem: <Enter+Enter>Fechar <Enter>Inserir <Del>Excluir <Space>Editar",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  TBMoveCursor( NKEY, OBJETO, Ponteiro )
  if objeto:colpos < (objeto:freeze+1)
      objeto:colpos := objeto:freeze+1
  endif
enddo
restscreen(0,0,24,79,TELA01)
return nil
                                                   
****************************************************
static function TbMoveCursor( NKEY, OOBJ, PONTEIRO )
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
   do case
      case nkey = K_ENTER
           TbVendaInsert()
      case nkey = K_SPACE
           TbVendaEdit(ponteiro)
      case nkey = K_DEL
           TbVendaDel(PONTEIRO)
   endcase
   return (NFOUND != 0)

*****************************
function TbVendaInsert()
*****************************
local GETLIST:={}, TELA_INSERT:=savescreen(0,0,24,79)
local QTDVENDA:=PRECO:=0
moldura(05,31,12,77,.f.," Vendas")
CODIGO:=0
HelpVar("Mensagem: <F10> Calculadora <F2> Pesquisa Produto",80,23,00)
@ 23,60 say "Incluindo Item!!" color [W*/gr+]
set cursor on
set key K_F2 to Produto_Help()
@ 06,39 say "    Produto:" get CODIGO pict "9999" valid (TESTA_PRO(CODIGO,@PRECO))
@ 07,39 say "  Descri‡ao:"
@ 08,39 say "Pre‡o Venda:"
read
set key K_F2 to
if Codigo == 0 .and. len(VCOD) > 0 .or. lastkey()==K_ESC
   TESTE:=.F.
   restscreen(0,0,24,79,TELA_INSERT)
   if lastkey()<>K_ESC
      TbFecha_Venda(FMovCod,FMovOper,FMovFunc,FCodCli)
   endif
   if len(VCOD) == 0
      NInserir := .F.
   endif
   return nil
endif
if Codigo <> 0
   @ 09,39 say "Pre‡o Custo:" +transf(PrPCusto,"999,999.99")
   @ 10,46 say "Qtde:" get QTDVENDA   pict "9999.999" valid ;
                       (QTDVENDA>0 .and. TESTA_QUANTIDADE(CODIGO,QTDVENDA,0,.T.)) ;
                       when (Codigo>0)
   read
   // @ 11,39 say "   Desconto:" Get FDesconto Pict "999,999.99" valid FDesconto>=0
   // @ 12,33 say "% ou Valor(% / V):" Get Percentual Pict "!" valid( Percentual $ "%V")
   /*if lastkey()<>K_ESC
      Total_Pagar := PRECO*QTDVENDA
      if Percentual=="%"
         Liquido:= Total_Pagar-(Total_Pagar*(FDesconto/100))
      else
         Liquido:= Total_Pagar-FDesconto
         set decimals to 9
         FDesconto:=(FDesconto/Total_Pagar)*100
         set decimals to 2
      endif
      if Liquido<=0
         alert("Opera‡„o Imposs¡vel!!!; Valor L¡quido Deu Negativo!!!!")
         SetColor(Cor_Antiga)
         restscreen(0,0,24,79,TELA_INSERT)
         return nil
      endif
   endif*/
endif
if lastkey()==K_ESC .or. Codigo == 0
   restscreen(0,0,24,79,TELA_INSERT)
   TESTE:=.F.
   if len(VCOD) == 0
      NInserir := .F.
   endif
   return nil
endif
set cursor off
restscreen(0,0,24,79,TELA_INSERT)
aadd(VCOD  , CODIGO)
aadd(VQTD  , QTDVENDA)
aadd(VPRE  , PRECO)
aadd(VSUBTOTAL, PRECO*QTDVENDA)
// aadd(VDEC,FDesconto)
aadd(VPCUSTO,PrPCusto*QTDVENDA)
aadd(VCGRUPO , PrGrupo)
NInserir := .T.
SomaTotal(.F.,.F.)
TESTE:=.T.
keyboard chr(24)+chr(25)
return nil

*************************
function TbVendaEdit(IND)
*************************
local GETLIST := {}, TELA_EDIT := savescreen(0,0,24,79)
local QTDVENDA:=0 , PRECO:=0
CODIGO := 0
moldura(05,31,12,77,.f.," Vendas")
HelpVar("Mensagem: <F10> Calculadora <F2> Pesquisa Produto",80,23,00)
@ 23,60 say "Editando Item!!" color [W*/gr+]
set key K_F2 to Produto_Help()
set cursor on
CODIGO     := VCOD[IND]
QTDVENDA   := VQTD[IND]
// FDESCONTO  := VDEC[IND]
Percentual := "%"
@ 06,43 say ""
TESTA_PRO(CODIGO,@PRECO)
@ 06,43 say "Produto:"    get CODIGO     pict "9999" valid ;
   (TESTA_PRO(CODIGO,@PRECO) .and. CODIGO > 0)
@ 07,41 say "Descri‡ao:"
@ 08,39 say "Pre‡o Venda:"
read
@ 09,39 say "Pre‡o Custo:" +transf(PrPCusto,"999,999.99")
if lastkey()<>K_ESC
   @ 10,46 say "Qtde:" get QTDVENDA   pict "9999.999" valid (QTDVENDA<>0 .and. ;
           TESTA_QUANTIDADE(CODIGO,QTDVENDA,IND,.T.)) when CODIGO<>0
   set key K_F2 to
   read
   /*@ 11,39 say "   Desconto:" Get FDesconto Pict "999,999.99" valid FDesconto>=0
   @ 12,33 say "% ou Valor(% / V):" Get Percentual Pict "!" valid( Percentual $ "%V")
   read
   Total_Pagar := PRECO*QTDVENDA
   if Percentual=="%"
      Liquido:= Total_Pagar-(Total_Pagar*(FDesconto/100))
   else
      Liquido:= Total_Pagar-FDesconto
      set decimals to 9
      FDesconto:=(FDesconto/Total_Pagar)*100
      set decimals to 2
   endif
   if Liquido<=0
      alert("Opera‡„o Imposs¡vel!!!; Valor L¡quido Deu Negativo!!!!")
      SetColor(Cor_Antiga)
      restscreen(0,0,maxrow(),maxcol(),TELA_EDIT)
      return nil
   endif*/
endif
if lastkey()==K_ESC
   restscreen(0,0,24,79,TELA_EDIT)
   return nil
endif
set cursor off
restscreen(0,0,24,79,TELA_EDIT)
VCOD[IND]     := CODIGO
VQTD[IND]     := QTDVENDA
VPRE[IND]     := PRECO
VSUBTOTAL[IND]:= PRECO*QTDVENDA
VPCUSTO[IND]  := PrPCusto*QTDVENDA
VCGRUPO[Ind]  := PrGrupo
// VDEC[IND]     := FDesconto
SomaTotal(.F.,.F.)
TESTE:=.T.
return nil

************************
function TbVendaDel(IND)
************************
adel(VCOD,IND)
adel(VQTD,IND)
adel(VPRE,IND)
adel(VSUBTOTAL,IND)
adel(VPCUSTO,IND)
// adel(VDEC,IND)
// adel(VLIQUIDO,IND)
adel(VCGRUPO,Ind)
asize(VCGRUPO,len(VCOD)-1)
asize(VQTD,len(VCOD)-1)
asize(VSUBTOTAL,len(VCOD)-1)
asize(VPCUSTO,len(VCOD)-1)
asize(VPRE,len(VCOD)-1)
// asize(VDEC,len(VCOD)-1)
// asize(VLIQUIDO,len(VCOD)-1)
asize(VCOD,len(VCOD)-1)
SomaTotal(.F.,.F.)
if len(VCOD) == 0
   NInserir := .F.
endif
return nil

**********************
function CMOVIMENTO()
**********************
local GETLIST:={} , CONF := " "
public VNOMEPRO:={} , NDoc := 0
public VCOD:={},VQTD:={},VSUBTOTAL:={},VPRE:={},VDEC:={}, VLIQUIDO:={}
if Testa_EData("Cancelamento das Vendas ‚ Efetuado Apenas No Mes Corrente..")
   Return nil
endif
if !TRotina(3)
   Return nil
endif
apaga(.T.)
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
Set order to 1
moldura(16,40,18,65,.F.," Cancelamento da Venda ")
@ 17,42 say "Documento :"  get NDoc  pict "9999999" valid (!EMPTY(NDoc) .or. NDoc > 0)
read
TbCVendaDoc(NDoc)
close _OPERACOE
close _FUNCIONA
close _MOVIMENT
set delimiters off
return NIL

**********************************
static function TbCVendaDoc(NDoc)
**********************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
set cursor off
OBJETO           := tbrowsenew(08,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
Rel_Doc(NDoc)
if LEN(VCOD)=0
   return nil
endif
select _MOVIMENT
set order to 1
dbseek(NDOC)
moldura(04,02,21,78,.F.," Cancelamento de Venda ")
@ 05,05 say "Documento : " color ["&cor_Apresentacao"]
@ 05,17 say + alltrim(str(NDoc))
@ 05,35 say "Funcion rio :" color ["&cor_Apresentacao"]
@ 05,49 say + alltrim(str(MovFunc)) + " - "
testa("_FUNCIONA",MovFunc,,05,53,"FuncNome")
@ 06,06 say "Opera‡„o : " color ["&cor_Apresentacao"]
@ 06,17 say + alltrim(str(MovOper)) + " - "
testa("_OPERACOE",MovOper,,06,21,"OperNome")
SomaTotal(.F.,.F.)
@ 07,03 to 07,77
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}


oCol := TBCOLUMNNEW( "C¢digo", {|| VCOD[ponteiro]})
oCol:picture := "9999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Produto", {|| VNOMEPRO[ponteiro]})
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
TBVTeclas(OBJETO,Ponteiro)
return nil

*************************************
function TBVTeclas(OBJETO,Ponteiro)
*************************************
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
          msg(23,00,"")
          setcursor(SC_NONE)
       elseif OBJETO:hitBottom
          tone(1000,2)
          HelpVar("Mensagem: Fim de arquivo!",80,23,00)
          setcursor(SC_NONE)
       else
          HelpVar("Mensagem: <Esc> Encerra Cancelamento <ENTER> Cancela Venda",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TbTeclas( NKEY, OBJETO, Ponteiro )
      if ( nKey == K_ESC )
         exit
      elseif (nKey == K_ENTER)
         Cancela_Venda()
         return nil
      endif
   endif
enddo
return nil

**************************
Function Cancela_Venda()
**************************
local Conf := " "
Cor_Antiga := SetColor()
SetColor("W/Bg+")
Set Cursor on
moldura(15,20,17,55,.f.," Cancelamento de Venda ")
@ 16,22 say "Confirma Cancelamento (S/N) ?" get Conf pict "@!" valid( Conf$"SN" )
Read
SetColor(Cor_Antiga)
if Conf = "S"
   @ 23,00 say Space(80)
   @ 23,00 say "Aguarde Atualizado Arquivos de Movimento e Produto" color ["W+*"]
   OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
   OPEN ESTGRUP ALIAS "_ESTGRUP" INDEX EST_GRUP SHARED
   OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
   Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
   set order to 1
   dbgotop()
   Dbseek(NDoc,.T.)
   do while .T.
     if ImCod >= NDOC
        dbskip(-1)
     elseif ImCod < NDOC
        exit
     endif
     if BOF()
        exit
     endif
   enddo
   Soma_Comis := 0
   do while !eof()
      if NDoc = ImCod
         Select _PRODUTOS
         set order to 1
         dbgotop()
         if dbseek(_ITENSMOV->ImCdPro)
            Est_Anterior := PrEAtual
            Est_Anterior := Est_Anterior + _ITENSMOV->ImQtd
            rlock()
            field->PrEAtual := Est_Anterior
            unlock
         endif
         select _GRUPOS
         set order to 1
         dbseek(_PRODUTOS->PrGrupo)
         if _GRUPOS->GPCOM = "S"
            Soma_Comis += (_ITENSMOV->ImPreco*_ITENSMOV->ImQtd)
         endif              
         select _ESTGRUP
         set order to 1
         if Dbseek(dtos(_MOVIMENT->MovDt)+str(_PRODUTOS->PrGrupo,2))
            rlock()
            FTotal_Venda := TOTALVENDA
            field-> TotalVenda := (FTotal_Venda-(_ITENSMOV->ImPreco*_ITENSMOV->ImQtd))
            unlock
         endif
         select _ITENSMOV
         do while .t.
            if n_reclock()
                delete
                exit
            endif
         enddo
         unlock
      elseif NDoc < ImCod
         exit
      endif
      dbskip()
   enddo
   If Soma_Comis > 0
      OPEN ESTFUNC ALIAS "_ESTFUNC" INDEX EST_VEND SHARED
      set order to 1
      dbgotop()
      if Dbseek(dtos(_MOVIMENT->MovDt)+str(_MOVIMENT->MovFunc))
         rlock()
         FTotal_Venda := TOTALVENDA
         FTotal_Cli   := Total_Cli
         field-> TotalVenda := (FTotal_Venda - Soma_Comis)
         field-> Total_Cli  := (FTotal_Cli-1)
         unlock
      endif
      close _ESTFUNC
   endif
   close _ESTGRUP
   close _GRUPOS
   close _PRODUTOS
   close _ITENSMOV
//////////////////////////////////////////////////////////////////////////
   if _MOVIMENT->MOVOPER = 2
      OPEN ITENSREC ALIAS "_ITENSREC" INDEX IRCodDt SHARED
      OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
      select _ITENSREC
      set order to 1
      dbgotop()
      Dbseek(str(NDOC-1,6)+Dtos(ctod("01/01/1995")),.T.)
      do while .T.
         if IrCod >= NDOC
            dbskip(-1)
         elseif IrCod < NDOC
            exit
         endif
         if BOF()
            exit
         endif
      enddo
      do while !eof()
         if IrCod=NDOC
            do while .t.
               if n_reclock()
                  delete
                  exit
               endif
            enddo
          elseif IrCod > NDOC
            exit
         endif
         dbskip()
      enddo
      FCodCli:=0
      Select _RECEB
      Set Order to 1
      dbgotop()
      Dbseek(str(NDOC-1,6)+Dtos(ctod("01/01/1995")),.T.)
      do while .T.
         if Rec_Cod >= NDOC
            dbskip(-1)
         elseif Rec_Cod < NDOC
            exit
         endif
         if BOF()
            exit
         endif
      enddo
      do while !eof()
         if Rec_Cod=NDOC
            FCodCli:=Rec_Cli
            do while .t.
               if n_reclock()
                  delete
                  exit
               endif
            enddo
          elseif Rec_Cod > NDOC
            exit
         endif
         dbskip()
      enddo
      OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
      set order to 1
      dbgotop()
      if FCodCli>0 .and. dbseek(FCodCli)
         rlock()
         Total := CLValor
         field->CLValor   := Total-_MOVIMENT->TOTAL_MOV
         unlock
      else
         Alerta(11,10,"Erro de Iconsitencia, Avise o Programador..!")
      endif
      close _CLIENTES
      close _RECEB
      close _ITENSREC
   Endif
/////////////////////////////////////////////////////////////////////////////
   select _MOVIMENT
   Set order to 1
   do while .t.
      if n_reclock()
         delete
         exit
      endif
   enddo
   unlock
endif
return nil

******************************************
function IMP_VENDA(CODI,QUANTI,PREC,PAGO)
******************************************
local OPERACAO , NFUNCIONARIO , I:=Total:=0
set device to print
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
set order to 1
dbseek(FMovOper)
OPERACAO := OperNome
CLOSE _OPERACOE
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
set order to 1
dbseek(FMovFunc)
NFUNCIONARIO:=FuncNome
close _FUNCIONA
OPEN UNMEDIDA  ALIAS "_UNMEDIDA" INDEX COD_UNMED,NOME_UNMED SHARED
@ prow(),pcol() say chr(15)
@ PROW()+1,0 say FIRMA
@ PROW()+1,0 say "Data: "+dtoc(FMovDt)
@ PROW(),36  say "Hora: "+FMovHr
@ PROW()+1,0 say substr(OPERACAO,1,25)
@ PROW(),36  say "DOC: "+alltrim(str(FMovCod))
@ PROW()+1,0 SAY "Funcion rio: " + substr(NFUNCIONARIO,1,35)
@ PROW()+1,0 SAY REPLICATE("=",55)
@ PROW()+1,0 say "Produto"
@ PROW(),36  say "Unidade de Medida"
@ PROW()+1,0 SAY REPLICATE("=",55)
L:=Prow()+1
select _PRODUTOS
set order to 1
FOR I=1 TO LEN(CODI)
   dbseek(CODI[I])
   @ L,0  say alltrim(substr(PrNome,1,35))
   select _UnMedida
   set order to 1
   dbseek(_PRODUTOS->PrUnidMed)
   @ L,36 say + alltrim(substr(Nome_UnMed,1,18))
   select _PRODUTOS
   l++
   @ L,04 say padl(str(QUANTI[I],8,3),8) + " X " + padl(str(PREC[I],11,2),11)+" = "+padl(str(PREC[I]*QUANTI[I],11,2),11)
   Total += (PREC[I]*QUANTI[I])
   L++
next
@ PROW()+1,00 SAY REPLICATE("=",55)
@ PROW()+1,20 say "Total Bruto "+padl(str(Total_Pagar,13,2),13)
@ PROW()+1,20 say "Desconto"+ padl(str(FDESCONTO,4),13)+"%"
if Nome_Operacao=="ORCAMENTO" .or. Nome_Operacao=="OR€AMENTO"
   @ PROW()+1,20 say "Total Pagar "+padl(str(Total_Pagar-(Total_Pagar*FDesconto/100),13,2),13)
else
   @ PROW()+1,20 say "Liquido     "+padl(str(Liquido,13,2),13)
   @ PROW()+1,20 say "Total pago  "+padl(str(Total_Pago,13,2),13)
   @ PROW()+1,20 say "     Troco  "+padl(str(Total_Pago-Liquido),13)
endif
@ PROW()+1,00 SAY "============= DOCUMENTO SEM VALOR FISCAL =============+"
@ PROW()+2,00 SAY ""

OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
if lastrec()=0
   Alerta(11,15,"N„o H  Nenhum Cliente Cadastrado!!")
   close Database
   return nil
else
   dbseek(FCodCli)
endif
@ PROW()+1,00 SAY REPLICATE("_",40)
@ PROW()+1,00 say ClNome
close _CLIENTES

select _PRODUTOS
set order to 1
@ prow(),pcol() say chr(18)
SET DEVICE TO SCREEN
alert(MSG_IMPRESSAO_COMPLETA)
close _UNMEDIDA
return NIL

**************************
function Baixa_Pagamento()
**************************
local GETLIST:={} , CONF := " " , NDoc := 0 , Cod_For := 0 , Achou := .F.
public NF:={}, DTCOMPR:={}, VALORCOM :={}, DOC_COMPR := {}
if Testa_EData("Baixa de Pagamento ‚ Efetuado Apenas No Mes Corrente..")
   Return nil
endif
if !TRotina(8)
   Return nil
endif
apaga(.T.)
OPEN PAGAMENT ALIAS "_PAGAMENT" INDEX CO10_PGT,PGTODOC,PGTOFOR SHARED
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
Set order to 1
inic_var()
moldura(16,40,18,74,.F.," Baixa de Pagamentos ")
HelpVar("<Esc> - Sai <F2> Pesquisa Fornecedor",70,23,10)
set key K_F2 to For_Help()
@ 17,42 say "C¢digo Fornecedor :" get Cod_For pict "999"    valid (!EMPTY(Cod_For) .or. Cod_For > 0)
read
set key K_F2 to
if lastkey()=K_ESC
   CLOSE _PAGAMENT
   CLOSE _FORNECED
   return nil
Endif
if Dbseek(Cod_For)
   TbMostraPgto(Cod_For)
else
   Alert("N„o Houve Compra;Desse Fornecedor")
endif
CLOSE _FORNECED
CLOSE _PAGAMENT
set delimiters off
return NIL

**************************************
static function TbMostraPgto(Cod_For)
*************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
private DOC_PGTO:=0, DATA_PGTO:=ctod("")
set cursor off
OBJETO           := tbrowsenew(07,03,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS

Rel_Pgtos(Cod_For)  //gerar vetores

if LEN(NF)=0
   Alert("N„o H  Pagamento(s);A Ser(em) Feito(s);A Esse Fornecedor")
   return nil
endif
moldura(04,02,21,78,.F.," Baixa de Pagamento ")
@ 05,03 say "C¢d. Fornecedor: " color ["&cor_Apresentacao"]
@ 05,22 say + alltrim(str(Cod_For)) + " - "
testa("_FORNECED",Cod_For,,05,26,"ForNome")
select _PAGAMENT
@ 06,03 to 06,77

OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(NF)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(NF)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(NF)}
OBJETO : goTopblock := {||ponteiro := 1}

OCOLUNA := tbcolumnnew(" û" , {|| iif((DOC_COMPR[ponteiro]=DOC_PGTO .and. DTCOMPR[ponteiro]=DATA_PGTO)," û", "  ")})
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
          HelpVar("Mensagem: <Enter> Baixa Pgto <Space> Seleciona Pgto a ser baixado",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TBBPGTeclas(NKEY,OBJETO,Ponteiro)
      if ( nKey == K_ESC ) .or. (nKey == K_ENTER)
         restscreen(0,0,24,79,TELA01)
         exit
      endif
  endif
enddo
return nil                           

****************************
Function Rel_Pgtos(Cod_For)
****************************
select _PAGAMENT
set order to 3
dbgotop()
Dbseek(Cod_For,.T.)
do while .t.
  if val(right(str(PGNUMDOC),3)) >= Cod_For
     dbskip(-1)
  elseif val(right(str(PGNUMDOC),3)) < Cod_For
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if val(right(str(PGNUMDOC),3)) == Cod_For .and. PGVALOR=0
      aadd(NF,val(left(str(PGNUMDOC,9),6)))
      aadd(DOC_COMPR,NDoc_Com)
      aadd(DtCompr,PgDataPrv)
      aadd(ValorCom,PgValorPrv)
   elseif val(right(str(PGNUMDOC),3)) > Cod_For
      exit
   endif
   dbskip()
enddo
return nil

*****************************************
function TBBPGTeclas(NKEY,OBJETO,Ponteiro)
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
        if DOC_PGTO <>0 .and.  DATA_PGTO <> ctod("")
           Fecha_Pgto(DOC_PGTO,DATA_PGTO)
        else
          alert("Vocˆ necessita selecionar ;algum pgto a ser baixado!!!!")
        endif
      case nkey = K_SPACE
         if DOC_PGTO = DOC_COMPR[ponteiro] .and.  DATA_PGTO = DTCOMPR[ponteiro]
            DOC_PGTO := 0
            DATA_PGTO:= ctod("")
         else
            DOC_PGTO := DOC_COMPR[ponteiro]
            DATA_PGTO:= DTCOMPR[ponteiro]
         endif
   endcase
return (NFOUND != 0)

***********************************
Function Fecha_Pgto(Doc,Data_Pgto)
***********************************
local GETLIST:={}
apaga(.T.)
select _Pagament
set order to 2
dbgotop()
Dbseek(Doc,.T.)
do while .t.
  if NDoc_Com >= Doc
     dbskip(-1)
  elseif NDoc_Com < Doc
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while !eof()
   if Doc = NDoc_Com .and. PgDataPrv = Data_Pgto
      igual_var()
      FPgValor := FPgValorPrv
      FPgData := date()
      moldura(07,25,17,65,.f.," Baixa de Pagamento ")
      @ 08,26 say "Fornecedor : "
      Codigo := val(right(str(FPgNumDoc),3))
      select _FORNECED
      set order to 1
      dbgotop()
      dbseek(Codigo)
      @ 08,39 say alltrim(substr(ForNome,1,20))
      select _PAGAMENT
      @ 10,26 say repl("Ä",38)
      @ 10,29 say " Previs„o "
      @ 11,27 say "Data  : " + transf(Dtoc(FPgDataPrv),"99/99/99")
      @ 12,27 say "Valor : " + str(FPgValorPrv)
      @ 14,26 say repl("Ä",38)
      @ 14,29 say " Pagamento "
      @ 15,27 say "Data  :" Get FPgData Pict "99/99/99" valid(!Empty(FPgData))
      @ 16,27 say "Valor :" Get FPgValor Valid(FPgValor>=FPgValorPrv)
      Read
      if confirma(" Confirma Grava‡„o ?") == 1
         do while ! rlock()
         enddo
         reply_var(.T.)
      endif
      unlock
      exit
   endif
   dbskip()
enddo
return nil

****************************************************
function MV_ESTOQUE(PRODUCAO,TAM,NPRO,NQTD,TIPOMOV)
***************************************************
local I
select _PRODUTOS
set order to 1
for I=1 to TAM
 if dbseek (NPRO[I])
  do while !RLOCK() // Trava Registro
  enddo
  if PrEst = "S"
     FPrEAtual := PrEAtual
     FIELD->PrEAtual:= IF(PRODUCAO,;
                    if(TIPOMOV=="S",FPrEAtual-NQTD[I],FPrEAtual+NQTD[I]),;
                    if(TIPOMOV=="E",FPrEAtual+NQTD[I],FPrEAtual-NQTD[I]))
  endif
 endif
 unlock
next
return nil

***********************
function Ret_PRO(COD)
***********************
if COD == 0
   return .T.
endif
select _PRODUTOS
set order to 1
if dbseek(COD)
  Return substr(PrNome,1,35)
else
  Alerta(05,15,"Produto N„o Cadastrado No Sistema..")
  return .F.
endif
Return nil

***********************
function Ret_PRECO(COD)
***********************
if COD == 0
   return .T.
endif
select _PRODUTOS
set order to 1
if dbseek(COD)
  Return PrPVenda
else
  Alerta(05,15,"Produto N„o Cadastrado No Sistema..")
  return .F.
endif
return nil

*********************************
function Ret_SubTotal(COD,QTDE)
*********************************
if COD == 0
   return .T.
endif
select _PRODUTOS
set order to 1
if dbseek(COD)
  Return (PrPVenda*QTDE)
else
  Alerta(05,15,"Produto N„o Cadastrado No Sistema..")
  return .F.
endif
return nil

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

**********************
function RECEBIMENTO()
**********************
local GETLIST:={},TELA_RECEBIMENTO := savescreen(0,0,24,79)
FDT_RECEB:=date()
if Testa_EData("Baixa No Recebimeto ‚ Efetuado Apenas No Mes Corrente..")
   Return nil
endif
if !TRotina(11)
   Return nil
endif
apaga(.T.)
HelpVar("<ESC> Retorna <Enter> Help do Cliente <F10> Calculadora",80,23,00)
moldura(05,03,21,78,.f.," Recebimento de Clientes ")
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
OPEN ITENSREC ALIAS "_ITENSREC" INDEX IRCodDt SHARED
OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
set order to 2
do while .t.
 FRec_Cli := 0
 @ 06,05 say   "C¢digo Cliente:" get FRec_Cli  pict "999" ;
   valid(pesquisa(07,18,15,67,"_Clientes",FRec_Cli ,"ClCod","ClNome"," Clientes ");
   .and. testa("_CLIENTES",FRec_Cli,,06,25,"ClNome"))
 @ 07,05 say " Data Receb.:" get FDT_RECEB
 read
 if FRec_Cli > 0
    RecebCli(FRec_Cli)
 endif
 if lastkey()==K_ESC
    exit
 endif
enddo
restscreen(0,0,24,79,TELA_RECEBIMENTO)
close _PRODUTOS
close _CLIENTES
close _ITENSREC
close _RECEB
return nil

**************************************
static function RecebCli(FRec_Cli)
**************************************
local getlist:={},OBJETO,TELA01:=savescreen(0,0,24,79),OCOLUNA,L,C
local CONT:=1, PONTEIRO:=1, PRECO:=0
public VCOD:={}, VHr:={} , VSUBTOTAL:={} , VDATA := {} , SELECIONADO := {} , Sair_TB := .F.
set cursor off
@ 07,04 to 07,76
OBJETO           := tbrowsenew(08,04,19,77)
OBJETO:colSep    := COLSEP
OBJETO:headSep   := HEADSEP
OBJETO:footSep   := FOOTSEP
OBJETO:colorSpec := MYCOLORS
select _RECEB
set order to 2 // Por Cliente
if dbseek(FRec_Cli)
   do while .T.
      dbskip(-1)
      if Rec_Cli < FRec_Cli .or. bof()
         exit
      endif
   enddo
else
  alert("Cliente n„o possui nenhuma compra")
  set cursor on
  @ 06,05 say space(50)
  return nil
endif
I := 0
do while !eof()
   if FRec_Cli == Rec_Cli
      aadd(VCOD,Rec_Cod)
      aadd(VDATA,Rec_Dt)
      aadd(VHR,Rec_Hr)
      aadd(VSUBTOTAL,Total_REC)
   elseif FRec_Cli < Rec_Cli
      exit
   endif
   dbskip()
enddo
SomaTotal(.F.,.F.)
OBJETO : skipblock := {|Tam| nMoved := if(abs(Tam) >= ;
                        if(Tam >= 0,Len(VCOD)-ponteiro,ponteiro-1),;
                        if(Tam >= 0,Len(VCOD)-ponteiro,1-ponteiro),;
                        Tam),ponteiro += nMoved,nMoved}

OBJETO : goBottomblock := {||ponteiro := len(VCOD)}
OBJETO : goTopblock := {||ponteiro := 1}


OCOLUNA := tbcolumnnew(" û" , {|| iif(Ascan(SELECIONADO, {|aVal| aVal==PONTEIRO})>0;
                                 , " û", "  ")})
OBJETO:addColumn(OCOLUNA)

oCol := TBCOLUMNNEW( "Documento", {|| VCOD[ponteiro]})
oCol:picture := "999999"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( " Data", {|| VDATA[ponteiro]})
oCol:picture := "99/99/99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Hora", {|| VHr[ponteiro]})
oCol:picture := "99:99:99"
OBJETO:addColumn(oCol)

oCol := TBCOLUMNNEW( "Sub.Total", {|| VSUBTOTAL[ponteiro]})
oCol:picture := "999999999.99"
OBJETO:addColumn(oCol)

NInserir := .T.
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
          HelpVar("Mensagem: <Enter> Fechar Recebimento <Space> Seleciona Recebimento",80,23,00)
       endif
       setpos(L,C)
  endif
  NKEY:=inkey(0)
  if !TBCursor( NKEY, OBJETO, Ponteiro )
     if NKEY == K_ESC
        exit
     endif
  endif
  if Sair_TB
     restscreen(0,0,24,79,TELA01)
     @ 06,05 say space(50)
     set cursor on
     return nil
  endif
enddo
restscreen(0,0,24,79,TELA01)
return nil

**************************
FUNCTION Selecao(PONTEIRO)
**************************
local nElem := Ascan(SELECIONADO, {|aVal| aVal==PONTEIRO})
if nElem > 0
   adel(SELECIONADO, nElem)
   asize(SELECIONADO, len(SELECIONADO) - 1)
 else
   aadd(SELECIONADO,PONTEIRO)
endif
return nil

************************************************
static function TbCursor( NKEY, OOBJ, PONTEIRO )
************************************************
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
           TbimpFecha()
           Sair_TB := .T.
      case nkey = K_SPACE
           Selecao(PONTEIRO)
   endcase
return (NFOUND != 0)

********************
FUNCTION TBimpFecha()
********************
local L,Soma_Total := 0
L := 0
P := 1
ASORT(SELECIONADO)
if Len(SELECIONADO) = 0
   return nil
endif
if confirma("Imprime Fechamento ?") == 1
   CONF := VF_PRINTER_CONF(.T.)
   if CONF
      set device to printer
      set printer on
   else
      Return nil
   endif
   For I = 1 to Len(SELECIONADO)
       if L==0
           select _RECEB
           set order to 1
           dbseek(str(VCOD[SELECIONADO[I]])+Dtos(VDATA[SELECIONADO[I]]))
           select _Clientes
           dbseek(_RECEB->Rec_Cli)
           Novo_Cab("Recebimento Venda a Prazo do Cliente " + substr(ClNome,1,15),{"Doc.","Data","Produto","Qtde","Preco Unit.","SubTotal"},{01,09,19,41,48,61})
           L+=6
           select _RECEB
       endif
       @ L,01 say alltrim(str(VCOD[SELECIONADO[I]]))
       @ L,09 say DTOC(VDATA[SELECIONADO[I]])
       select _ITENSREC
       set order to 1
       dbseek(str(VCOD[SELECIONADO[I]])+Dtos(VDATA[SELECIONADO[I]]))
       do while .T.
          dbskip(-1)
          if IrCod < VCOD[SELECIONADO[I]] .or. BOF()
             exit
          endif
       enddo
       do while !eof()
          if VCOD[SELECIONADO[I]] = IrCod .and. VDATA[SELECIONADO[I]] = IrDt
             select _PRODUTOS
             dbseek(_ITENSREC->IrCdPro)
             @ L,19 say substr(PrNome,1,20)
             select _ITENSREC
             @ L,41 say alltrim(str(IrQtd))
             @ L,48 say str(IrPreco,6,2)
             @ L,61 say str((IrPreco*IrQtd),6,2)
             L++
          elseif IrCod > VCOD[SELECIONADO[I]]
            exit
          endif
          dbskip()
       enddo
       @ L,45 say "TOTAL DOCUMENTO " + str(VSUBTOTAL[SELECIONADO[I]],6,2)
       L++
       @ L,0 say repl("-",76)
       L++
       Soma_Total += VSUBTOTAL[SELECIONADO[I]]
   next
   @ L,50 say "TOTAL GERAL: " + str(Soma_Total,9,2)
   L++
   @ L,0 say repl("-",76)
   L++
   @ L,1 say "TeraByte Informatica"
   Set device to screen
   Set print off
   select _RECEB
endif
if confirma("Fechar Recebimento Agora ?") == 1
   OPEN VPRAZOPG ALIAS "_VPRAZOPG" INDEX DT_RECEB SHARED
   OPEN IVPRAZPG ALIAS "_IVPRAZPG" INDEX IRVPPG SHARED
   @ 23,11 say space(68)
   @ 23,12 say "Aguarde, Efetuando Baixa dos Recebimentos Selecionados"  color ["W+*"]
   For I = 1 to Len(SELECIONADO)
       select _ITENSREC
       set order to 1
       dbseek(str(VCOD[SELECIONADO[I]])+Dtos(ctod("01/01/91")),.T.)
       do while .T.
          dbskip(-1)
          if IrCod < VCOD[SELECIONADO[I]] .or. BOF()
             exit
          endif
       enddo
       do while !eof()
          if VCOD[SELECIONADO[I]] = IrCod .and. VDATA[SELECIONADO[I]] = IrDt
             select _IVPrazPg
             set order to 1
	     do while !N_ADDREC() ; enddo
	     field -> IRCod   := _ITENSREC->IRCod
	     field -> IRDt    := _ITENSREC->IRDt
	     field -> IRCDPRO := _ITENSREC->IRCDPRO
	     field -> IRQTD   := _ITENSREC->IRQTD
	     field -> IRPRECO := _ITENSREC->IRPRECO
	     unlock
	     select _ITENSREC
	     set order to 1
             rlock()
             delete
             unlock
          elseif IrCod > VCOD[SELECIONADO[I]]
             exit
          endif
          dbskip()
       enddo
       select _RECEB
       set order to 1
       dbseek(str(VCOD[SELECIONADO[I]])+Dtos(VDATA[SELECIONADO[I]]))
       select _VPRAZOPG
       set order to 1
       do while !N_ADDREC() ; enddo
       field -> Rec_Cod   := _RECEB->Rec_Cod
       field -> Rec_Dt	  := _RECEB->Rec_Dt
       field -> Rec_Cli   := _RECEB->Rec_Cli
       field -> Rec_Hr    := _RECEB->Rec_Hr
       field -> Total_Rec := _RECEB->Total_Rec
       field -> Dt_Receb  := FDt_Receb
       unlock
       select _RECEB
       rlock()
       delete
       unlock
   next
   close _VPRAZOPG
   close _IVPRAZPG
endif
@ 23,11 say space(68)
VCOD:={} ; VHr:={} ; VSUBTOTAL:={} ; VDATA := {} ; SELECIONADO := {}
return nil

*****************************
Function Baixa_Recebimento()
*****************************
local GETLIST:={}, Cliente := 0, conf:=space(01)
apaga(.T.)
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
OPEN MOVREC   ALIAS "_MOVREC"   INDEX MRecCli,MRecDt SHARED
inic_var()
dbgobottom()
select _CLIENTES
set order to 1
@ 23,00 say "<ESC> Retorna <Enter> Help do Cliente <F10> Calculadora"
dbgotop()
moldura(07,25,20,65,.f.," Recebimento de Cliente ")
@ 08,26 say "C¢digo Cliente :" Get Cliente pict "999" valid(pesquisa(06,18,15,67,"_Clientes",Cliente,"ClCod","ClNome"," Clientes "))
//valid(Cliente > 0)
read
if dbseek(Cliente)
   FData_Rec := date()
   @ 09,26 say "          Nome : " + alltrim(substr(ClNome,1,20))
   FCl_Cliente := Cliente
   FValor_Doc  := ClValor
   FPendente   := ClPendente
   if FValor_Doc > 0 .or. FPendente > 0
      select _MOVREC
      @ 10,26 say repl("Ä",38)
      @ 11,27 say "Data Recebimento  :" Get FData_Rec Pict "99/99/99" valid(!Empty(FData_Rec))
      @ 13,27 say "Valor do Documento:" + str(FValor_Doc)
      @ 15,27 say "Valor Pendente    :" + str(FPendente)
      @ 17,27 say "            Total :" + str(FPendente+FValor_Doc)
      @ 19,27 say "       Valor Pago :" Get FValor_Rec Pict "999,999.99" valid(FValor_Rec>0)
      Read
      @ 23,00 say Space(80)
      @ 23,00 say "Mensagem: Confirma Grava‡ao (S/N) ?" get CONF pict "@!" valid CONF $"SN"
      read
      if CONF=="S"
         FPendente := (FValor_Doc + FPendente) - FValor_Rec
         rlock()
         Dbappend()
         reply_var(.T.)
         unlock
         select _CLIENTES
         rlock()
         field ->DtPendente := FData_Rec
         field ->CLValor    := 0
         field ->CLPendente := FPendente
         unlock
      endif
   else
     Alerta(11,15," N„o Existe Nenhum Recebimento Pendente !!")
   endif
endif
close _CLIENTES
close _MOVREC
return nil

