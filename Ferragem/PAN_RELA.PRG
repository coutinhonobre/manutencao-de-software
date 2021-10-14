
# include "INKEY.CH"
# include "PAN.CH"
# include "RCH.CH"

******************************
function RCCLEXTRATIFICADO()
******************************
local getlist:={} ,L:=Soma_Total:=Cod_Cliente:=Soma_Desconto:=Tam_Rel:=0
local Total_Documento:=0
local DATA_INI:=DATA_FIM:= DATE()
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol()) , inicio , Fim
set intens on
set cursor on
@ 23,12 say "Digite o c¢digo do cliente para a emissao do relat¢rio"
beep(2)
moldura(7,43,11,74,.F.," Contas a Receber ")
@ 08,45 say "C¢digo do Cliente :" get Cod_Cliente pict "999" valid Cod_Cliente>0
@ 09,45 say "     Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 10,45 say "     Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
set intens off
set cursor off
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Extratificado Por Cliente" color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
select _Clientes
dbseek(Cod_Cliente)
Nome := ClNome
OPEN ITENSREC ALIAS "_ITENSREC" INDEX IRCodDt SHARED
OPEN RECEB    ALIAS "_RECEB"    INDEX RCodDt,RCodCli,RecDt SHARED
set order to 2
dbgotop()
Dbseek(Cod_Cliente,.T.)
do while .t.
  if Rec_Cli >= Cod_Cliente
     dbskip(-1)
  elseif Rec_Cli < Cod_Cliente
     exit
  endif
  if BOF()
     exit
  endif
enddo
if Imp_OK
 do while ! eof()
  if L==0
     Novo_Cab("Contas a Receber de " + substr(Nome,1,30),{"Doc.","Data","Produto","Qtde","Val Un","SubTotal"},{00,08,18,50,58,66})
     L+=6
  endif
  if Rec_Cli = Cod_Cliente .and. REC_DT >= DATA_INI .and. REC_DT <= DATA_FIM
     Tam_Rel := 1
     Total_Documento:=0
     @ L,00 say alltrim(str(REC_COD))
     @ L,08 say DTOC(REC_DT)
     // Pesquisar C¢digo em Itens de Recebimento
     select _ITENSREC
     set order to 1
     dbseek(str(_RECEB->REC_COD)+Dtos(_RECEB->REC_DT))
     do while .T.
        dbskip(-1)
        if IrCod < _RECEB->REC_COD .or. BOF()
           exit
        endif
     enddo
     // Relacionado os produtos disponiveis
     do while !eof()
        if _RECEB->REC_COD = IrCod .and. _RECEB->REC_DT = IrDt
           select _PRODUTOS
           dbseek(_ITENSREC->IrCdPro)
           @ L,18 say substr(PrNome,1,30)
           select _ITENSREC
           @ L,50 say alltrim(str(IrQtd))
           @ L,58 say str(IrPreco,6,2)
           @ L,66 say str((IrPreco*IrQtd),6,2)
           Total_Documento += IrPreco*IrQtd
           FDesconto := Desconto
           L++
        elseif IrCod > _RECEB->REC_COD
          exit
        endif
        dbskip()
     enddo
     @ L,40 say "TOTAL SEM DESCONTO: " + alltrim(str(Total_Documento,6,2))
     L++
     @ L,40 say "DESCONTO DOCUMENTO: " + alltrim(str(FDESCONTO,5,2))+" % "
     L++
     @ L,58 say repl("-",10)
     IF FDESCONTO > 0
        FDESCONTO := Total_Documento-((Total_Documento*FDESCONTO)/100)
     else
        FDESCONTO := Total_Documento
     Endif
     @ L,48 say "   TOTAL DOCUMENTO: " + str(FDESCONTO,6,2)
     L++
     @ L,0 say repl("-",76)
     L++
     Soma_Total += Total_Documento
     Soma_Desconto += FDESCONTO
     select _RECEB
  endif
  dbskip()
  If eof()
     If L < 50
        L:=50
     endif
     L++
     @ L,30 say replicate ("-",30)
     L++
     @ L,35 say " Assinatura do Cliente"
  endif
  if L = 58 .or. Eof()
     if eof()
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,40 say "TOTAL SEM DESCONTO: " + str(Soma_Total,9,2)
        L++
        FDesconto := ((Soma_Total-Soma_Desconto)*100)/Soma_Total
        @ L,40 say "   TOTAL DESCONTO : " + str(FDesconto,9,2) + " % "
        L++
        @ L,59 say repl("-",10)
        L++
        @ L,40 say "       TOTAL GERAL: " + str(Soma_Desconto,9,2)
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V" .and. Tam_Rel > 0
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
elseif Tam_Rel = 0
   alert("N„o Existe Pagt. de Cliente em Atraso;Pressione algo para continuar!")
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

***********************
function RCONTAS_CL()
***********************
local nElem:=0,AVCOD:={}, AVNOMECLI:={} , AVALOR:={}
local getlist:={} , L := Soma_Total := 0, Cod_Cliente := 0
local Tam_Rel := 0
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol()) , inicio , Fim
if lastkey() == K_ESC
   return nil
endif
set intens off
set cursor off
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Contas a Receber de Todso os Cliente" color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
set order to 1
dbgotop()
do while !eof()
   aadd(AVCOD,CLCOD)
   aadd(AVNOMECLI,CLNOME)
   aadd(AVALOR,0)
   dbskip()
enddo
close _CLIENTES
OPEN RECEB    ALIAS "_RECEB"  INDEX RCodDt,RCodCli,RecDt SHARED
set order to 2
dbgotop()
if Imp_OK
 do while ! eof()
    nElem:=Ascan(AVCOD,REC_CLI)
    if nElem > 0
       Valor_Anterior := AVALOR[nElem]
       AVALOR[nElem] := Valor_Anterior + Total_Rec
    endif
    dbskip()
 enddo
 For I:= 1 to len(AVCOD)
  if L==0
     Novo_Cab("Relat¢rio de Contas a Receber",{"C¢digo","Nome do Cliente","Total do Doc."},{01,12,60})
     L+=6
  endif
  if AVALOR[I] > 0
     @ L,02 say AVCOD[I]
     @ L,12 say alltrim(substr(AVNOMECLI[I],1,30))
     @ L,61 say AVALOR[I] pict "999,999.99"
     Soma_Total += AVALOR[I]
     L++
  endif
  if L = 58 .or. I = len(AVCOD)
     if I = len(AVCOD)
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,51 say "Total :"
        @ L,61 say Soma_Total pict "999,999.99"
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 next
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
close _RECEB
return nil


************************
function R_CONTASRCL()
************************
local getlist:={} , L := Soma_Total := 0, Cod_Cliente := 0
local Tam_Rel := 0
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol()) , inicio , Fim
set intens on
set cursor on
@ 23,12 say "Digite o c¢digo do cliente para a emissao do relat¢rio"
beep(2)
moldura(7,43,9,71,.F.," Contas a Receber ")
@ 08,45 say "C¢digo do Cliente :" get Cod_Cliente pict "99" valid Cod_Cliente>0
read
if lastkey() == K_ESC
   return nil
endif
set intens off
set cursor off
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Contas a Receber Por Cliente" color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
OPEN RECEB    ALIAS "_RECEB"    INDEX RCodDt,RCodCli,RecDt SHARED
set order to 2
dbgotop()
Dbseek(Cod_Cliente,.T.)
do while .t.
  if Rec_Cli >= Cod_Cliente
     dbskip(-1)
  elseif Rec_Cli < Cod_Cliente
     exit
  endif
  if BOF()
     exit
  endif
enddo
if Imp_OK
 do while ! eof()
  if L==0
     Novo_Cab("Relat¢rio de Contas a Receber Por Cliente",{"N§ do Doc.","Nome do Cliente","Data da Compra","Total do Doc."},{01,12,43,60})
     L+=6
  endif
  if Rec_Cli = Cod_Cliente
     @ L,02 say Rec_Cod
     select _CLIENTES
     set order to 1
     dbgotop()
     dbseek(_RECEB->Rec_Cli)
     @ L,12 say alltrim(substr(ClNome,1,30))
     select _RECEB
     @ L,45 say Rec_Dt pict "99/99/99"
     @ L,61 say Total_Rec pict "999,999.99"
     Soma_Total += Total_Rec
     L++
     Tam_Rel := 1
  elseif Rec_Cli > Cod_Cliente
     dbgobottom()
  endif
  dbskip()
  if L = 58 .or. Eof()
     if eof()
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,51 say "Total :"
        @ L,61 say Soma_Total pict "999,999.99"
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V" .and. Tam_Rel > 0
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
elseif Tam_Rel = 0
   alert("N„o Existe Pagt. de Cliente em Atraso;Pressione algo para continuar!")
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
close _CLIENTES
close _RECEB
return nil

************************
function Rel_Cliente()
************************
local getlist:={} , CNumCliente := L :=0 , DATA_INI:=DATA_FIM:= DATE()
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
private Cod_Cliente := 0
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
set order to 1
Dbgotop()
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
apaga(.T.)
set key K_F2 to Cli_Help()
moldura(08,35,10,77,.F.," Relat¢rio Cliente Por C¢digo")
@ 09,37 say "C¢d. Cliente:"  get Cod_Cliente pict "99" valid (Cod_Cliente>0 .and. ;
  testa("_CLIENTES",Cod_Cliente,,09,54,"ClNome"))
read
set key K_F2 to
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Cadastro de Cliente " color ["W+*"]
Imp_OK := Imp_Doc()
if lastkey()==K_ESC
   Close Databases
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
dbseek(Cod_Cliente)
L:=0
@ L,01 say chr(14) + FIRMA
L++
@ L,00 say repl("-",76)
L++
@ L,00 say padc("C A D A S T R O  DE  C L I E N T E S",76)
L++
@ L,00 say repl("-",76)
L++
@ L,07 say "C¢digo : [" + str(ClCod) + "]"
@ L,26 say "Nome : [" + alltrim(ClNome) + "]"
L:=L+2
@ L,05 say "Endereco : [ "  + alltrim(ClEnd) + " ]"
L:=L+2
@ L,07 say "Bairro : [ "    + alltrim(ClBairro) + " ]"
@ L,42 say "Cidade : [ "    + alltrim(ClCid) + " ]"
L:=L+2
@ L,10 say "Cep : [ " + transf(ClCep,"@R 99999-999") + " ]"
if ! empty(Clfone)
   @ L,40 say "Telefone : [ " + transf(ClFone,"@R (999) 999-9999") + " ]"
else
   @ L,40 say "Telefone : [ " + space(15) + " ]"
endif
L:=L+2
@ L,05 say "N§ do RG : [ "  + alltrim(ClRG) + " ]"
@ L,45 say "CPF : [ " + alltrim(ClCPF) + " ]"
L:=L+2
@ L,00 say "Dt Nascimento : [ "  + transf(CLDTNASC,"99/99/99") + " ]"
L:=L+2
@ L,10 say "PAI : [ "+ alltrim(ClMAE) + " ]"
L:=L+2
@ L,10 say "MAE : [ " + alltrim(ClPAI) + " ]"
L:=L+2
@ L,00 say "Local Trabalho : [ "+ alltrim(ClTRAB) + " ]"
L++
@ L,00 say repl("-",76)
L++
@ L,00 say "Data Emissao Relatorio: "+dtoc(Date())
L++
@ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
eject
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

****************************
function Rel_CCliente(Ind)
****************************
local getlist:={} , L :=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
local CNumCliente := 0
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
set order to Ind
Dbgotop()
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Cadastro de Cliente " color ["W+*"]
Imp_OK := Imp_Doc()
if lastkey()==K_ESC
   Close Databases
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
P := 1
do while ! eof()
  if L==0 .and. !eof()
     Novo_Cab("Listagem de Clientes ",{"C¢digo","Nome do Cliente","Telefone"},{01,10,47})
     L+=6
  endif
  @ L,01 say ClCod
  @ L,10 say alltrim(ClNome)
  if ! empty(Clfone)
     @ L,48 say alltrim(ClFone) pict "@R (999) 999-9999"
  else
     @ L,48 say space(15)
  endif
  CNumCliente++
  L++
  dbskip()
  if L = 58 .or. Eof()
     if !Eof()
        L:=59
     else
        L++
     endif
     @ L,00 say repl("-",76)
     L++
     @ L,00 say "Total de Clientes Cadastrados : " + alltrim(str(CNumCliente))
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
enddo
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

*************************
function Rel_LCliente()
*************************
local getlist:={} , L :=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
local CNumCliente := 0
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
set order to Ind
Dbgotop()
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Cadastro de Cliente " color ["W+*"]
Imp_OK := Imp_Doc()
if lastkey()==K_ESC
   Close Databases
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
P := 1
do while ! eof()
  if L==0 .and. !eof()
     Novo_Cab("Listagem de Clientes ",{"C¢digo","Nome do Cliente","Telefone"},{01,10,47})
     L+=6
  endif
  @ L,01 say ClCod
  @ L,10 say alltrim(ClNome)
  if ! empty(Clfone)
     @ L,48 say alltrim(ClFone) pict "@R (999) 999-9999"
  else
     @ L,48 say space(15)
  endif
  CNumCliente++
  L++
  dbskip()
  if L = 58 .or. Eof()
     if !Eof()
        L:=59
     else
        L++
     endif
     @ L,00 say repl("-",76)
     L++
     @ L,00 say "Total de Clientes Cadastrados : " + alltrim(str(CNumCliente))
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
enddo
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

*************************
function Rel_CGRUPO(Ind)
*************************
local getlist:={} , L :=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
set order to Ind
Dbgotop()
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Cadastro Por Grupo " color ["W+*"]
if lastkey()==K_ESC
   Close Databases
   set cursor on
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
Imp_OK := Imp_Doc()
P := 1
do while ! eof()
  if L==0 .and. !eof()
     Novo_Cab("Listagem de Grupos ",{"C¢digo","Nome do Grupo","Pagt. de Comiss„o"},{01,10,48})
     L+=6
  endif
  @ L,01 say GpCod
  @ L,10 say alltrim(GpNome)
  iif(GpCom == "S",Texto:="Sim",Texto:="Nao")
  @ L,55 say Texto
  L++
  dbskip()
  if L = 58 .or. Eof()
     if !Eof()
        L:=59
     else
        L++
     endif
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
enddo
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

***********************************
function RESTOQUE_GP(Status)
***********************************
local getlist:={} , L :=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
private Cod_Grupo := SQuantidade := 0
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
Dbgotop()
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
apaga(.T.)
set key K_F2 to Gru_Help()
moldura(08,35,10,77,.F.," Relat¢rio Estoque Por Grupo")
@ 09,37 say "C¢d. Grupo :"  get Cod_Grupo pict "99" valid (Cod_Grupo>0 .and. ;
  testa("_GRUPOS",Cod_Grupo,,09,53,"GpNome"))
read
set key K_F2 to
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Produto Por Grupo " color ["W+*"]
if lastkey()==K_ESC
   Close Databases
   set cursor on
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
Imp_OK := Imp_Doc()
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 4
dbgotop()
dbseek(str(Cod_Grupo-1,2),.T.)
do while ! eof()
  if L==0 .and. !eof()
     Novo_Cab("Relat¢rio Produto/Grupo "+_GRUPOS->GpNome,{"C¢digo","Produto","Estoque Atual"},{01,10,53})
     L+=6
  endif
  if PrGrupo = Cod_Grupo
     Imprime := .F.
     if Status == 1 .and. PrEAtual > 0
        Imprime := .T.
     elseif Status == 2
        Imprime := .T.
     endif
     if Imprime
        @ L,01 say PrCod
        @ L,10 say PrNome
        @ L,55 say transf(PrEAtual,"9999.99")
        SQuantidade += PrEAtual
        L++
     endif
  elseif PrGrupo > Cod_Grupo
     dbgobottom()
  endif
  dbskip()
  if L = 58 .or. Eof()
     if !Eof()
        L:=59
     else
        L++
     endif
     @ L,00 say repl("-",76)
     L++
     @ L,35 say "Total Quantidade: " + transf(SQuantidade,"999999.99")
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
enddo
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

****************************
function Venda_Documento()
****************************
local getlist:={} , L , Soma , DATA_INI:=DATA_FIM:= DATE() , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
local inicio := fim := time() , HORA_INI:="06:00:00", HORA_FIM:=TIME()
local Tot_Vista:=0, Tot_Prazo:=0,Tot_Bonific:=0,Tot_Consumo:=0
apaga(.T.)
@ 23,12 say "Digite as Informa‡oes Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(05,43,10,71,.F.," Venda Por Documento ")
@ 06,45 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 07,45 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM)))
@ 08,45 say "Hora Inicial :"  get HORA_INI  pict "99:99:99" valid (!EMPTY(HORA_INI))
@ 09,45 say "Hora Final ..:"  get HORA_FIM  pict "99:99:99" valid (!EMPTY(HORA_FIM))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Venda por Documento " color ["W+*"]
Imp_OK := Imp_Doc()
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
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
  elseif MovDt < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
L := Tela := Soma := 0
P := 1
if Imp_OK
   do while ! eof()
      if L==0
         NCab(DATA_INI,DATA_FIM,"Venda Por Documento",{"N§.Doc.","Funcionario","Operacao","Data","Hora","Valor"},{00,08,23,39,48,59})
         L+=7
      endif
      if (MovDt>=DATA_INI) .and. (MovDt<=DATA_FIM) .and.;
         (MovHr>=HORA_INI) .and. (MovHr<=HORA_FIM)
         @ L,01 say alltrim(str(MovCod))
         select _FUNCIONA
         set order to 1
         dbgotop()
         dbseek(_MOVIMENT->MovFunc)
         @ L,08 say substr(FuncNome,1,15)
         select _OPERACOE
         set order to 1
         dbgotop()
         dbseek(_MOVIMENT->MovOper)
         @ L,24 say substr(OperNome,1,12)
         select _MOVIMENT
         if _OPERACOE->OperTipo== "S"
            Tot_Vista +=Total_Mov
         elseif _OPERACOE->OperTipo= "N"
            Tot_Prazo +=Total_Mov
         elseif _OPERACOE->OperTipo= "B"
            Tot_Bonific +=Total_Mov
         endif
         @ L,37 say MovDt
         @ L,47 say substr(MovHr,1,5)
         @ L,54 say Total_Mov
         Soma += Total_Mov
         L++
      endif
      dbskip()
      if L = 58 .or. Eof()
         if !Eof()
            L:=59
         else
            L++
         endif
         @ L,00 say repl("-",76)
         L++
         @ L,37 say "Total a  Vista:" + str(Tot_Vista)
         L++
         @ L,37 say "Total a  Prazo:" + str(Tot_Prazo)
         L++
         @ L,37 say "Total Bonific.:" + str(Tot_Bonific)
         L++
         @ L,37 say "Total Consumo.:" + str(Tot_Consumo)
         L++
         @ L,37 say "   Total Geral:" + str(Soma)
         L++
         @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
         eject
         P++
         L := 0
      endif
   enddo
endif
set device to screen
set printer off
set printer to
fim := time()
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

**************************
function LR_CPRODUTO()
*************************
local getlist:={} , L:=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
private Cod_Grupo := 0
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
@ 23,12 say "Digite a Informa‡ao Acima Para a Emissao do Relat¢rio"
beep(2)
apaga(.T.)
set key K_F2 to Gru_Help()
moldura(08,35,10,77,.F.," Relat¢rio Produto Por Grupo")
@ 09,37 say "C¢d. Grupo :"  get Cod_Grupo pict "99" valid (Cod_Grupo>0 .and. ;
  testa("_GRUPOS",Cod_Grupo,,09,53,"GpNome"))
read
set key K_F2 to
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio Produto Por Grupo " color ["W+*"]
if lastkey()==K_ESC
   Close Databases
   set cursor on
   restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
   return nil
endif
Imp_OK := Imp_Doc()
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 4
dbgotop()
dbseek(str(Cod_Grupo-1,2),.T.)
do while ! eof()
  if L==0
     Novo_Cab("Relat¢rio Produto/Grupo "+_GRUPOS->GpNome,{"C¢digo","Produto","Pre‡o de Venda"},{01,10,59})
     L+=6
  endif
  if PrGrupo = Cod_Grupo
     @ L,01 say PrCod
     @ L,10 say substr(PrNome,1,35)
     @ L,55 say PrPVenda pict "999,999.99"
     L++
  elseif PrGrupo > Cod_Grupo
     Dbgobottom()
  endif
  dbskip()
  if L = 58 .or. Eof()
     if !Eof()
        L:=59
     else
        L++
     endif
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
enddo
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

**************************
function LR_PRODUTO(Ind)
*************************
local getlist:={}, COD_INI:=0, COD_FIN:=0, C_INIC:=space(1), Conf:=space(1), TODOS:=.F.
local C_FINAL:=space(1),L:=0,TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
cor := setcolor()
apaga(.T.)
@ 23,12 say "Digite o Produto Inicial e Final Para a emissao do Relat¢rio"
beep(2)
if IND = 1
   moldura(12,50,15,78,.F.," Listagem de Pre‡o ")
   @ 13,52 say "Produto Inicial :" get COD_INI   pict "9999" valid (COD_INI>0)
   @ 14,52 say "Poduto Final ...:" get COD_FIN   pict "9999" valid (COD_FIN>=COD_INI)
else
   moldura(08,30,11,78,.F.," Listagem de Pre‡o ")
   @ 09,32 say "Caracter Inicial:" get C_INIC    pict "@!A" valid(!empty(C_INIC))
   @ 09,52 say "Caracter Final..:" get C_FINAL   pict "@!A" valid (!empty(C_FINAL) .AND. C_INIC<=C_FINAL)
   @ 10,32 say "Salta Linha Ap¢s Inicio do Pr¢ximo Caracter:" get Conf Pict ;
                "@!" valid( Conf $ "SN")
endif
read
if alert("Imprimir produtos; com estoque zero?",{"Sim","N„o"})==1
   TODOS:=.T.
else
   TODOS:=.F.
endif
if lastkey() == K_ESC
   return nil
endif
@ 23,12 say Space(68)
apaga(.F.)
setcolor("&cor")
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Tabela de Pre‡o de Venda "color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN UNMEDIDA  ALIAS "_UNMEDIDA" INDEX COD_UNMED,NOME_UNMED SHARED
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to Ind
dbgotop()
if IND=1
   dbseek(COD_INI,.T.)
else
   dbseek(alltrim(C_INIC)+"AAA",.T.)
endif
            
if DESTINO <> "V"
   if Imp_OK
      do while ! eof()
        Imprimir:=.F.
        if IND=1
           if (PrCod>=COD_INI).and.(PrCod<=COD_FIN)
              Imprimir:=.T.
           endif
         else
           if (left(PRNOME,1)>=C_INIC .and. left(PRNOME,1)<=C_FINAL)
              Imprimir:=.T.
              Produto_Anterior := Left(PrNome,1)
           endif
        endif
        if Imprimir
           if L==0
              Novo_Cab("Tabela de Pre‡os de Venda",{"C¢digo","Descricao do Produto","Unid.Medida","Pre‡o de Venda"},{01,10,42,57})
              L+=6
           endif
           if TODOS=.F.
              if PrEAtual>0
                 @ L,01 say PrCod
                 @ L,10 say PrNome
                 select _UnMedida
                 set order to 1
                 dbseek(_PRODUTOS->PrUnidMed)
                 @ L,45 say + alltrim(substr(Nome_UnMed,1,10))
                 select _PRODUTOS
                 @ L,56 say PrPVenda pict "999,999.99"
                 L++
              endif
           else
             @ L,01 say PrCod
             @ L,10 say PrNome
             select _UnMedida
             set order to 1
             dbseek(_PRODUTOS->PrUnidMed)
             @ L,45 say + alltrim(substr(Nome_UnMed,1,10))
             select _PRODUTOS
             @ L,56 say PrPVenda pict "999,999.99"
             l++
           endif
        else
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           exit
        endif
        dbskip()
        if Conf=="S"
           if Ind==2
              if Produto_Anterior <> Left(PrNome,1)
                  L := 58
              endif
           endif
        endif
        if L = 58 .or. Eof()
           if !Eof()
              L:=59
           else
              L++
           endif
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      enddo
   endif
else
   use RelTela alias Rel new
   Select _PRODUTOS
   do while ! eof()
      Sair := Imprimir:=.F.
      if IND=1
         if (PrCod>=COD_INI).and.(PrCod<=COD_FIN)
            Imprimir:=.T.
         elseif (PrCod > COD_FIN)
            Sair := .T.
         endif
      else
         if (left(PRNOME,1)>=C_INIC .and. left(PRNOME,1)<=C_FINAL)
            Imprimir:=.T.
         elseif (left(PRNOME,1)>C_FINAL)
            Sair := .T.
         endif
      endif
      if Imprimir
         Nvar := str(PrCod) + space(5) + alltrim(PrNome)
         Tam  := 35 - Len(alltrim(PrNome))
         NVar := NVar + repl(".",Tam) + space(2)
         select _UnMedida
         set order to 1
         dbseek(_PRODUTOS->PrUnidMed)
         NVar := NVar + alltrim(substr(Nome_UnMed,1,10))
         Tam  := 10 - Len(alltrim(Nome_UnMed))
         select _PRODUTOS
         NVar := NVar + space(Tam) + transf(PrPVenda,"999,999.99")
         Select Rel
         Dbappend()
         field->Observacao  := NVar
         Select _PRODUTOS
      endif
      if Sair
         exit
      endif
      dbskip()
   enddo
endif
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,02,21,78,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   Select Rel
   dbgotop()
   NCAMP := "C¢digo" + space(02) + "Descricao do Produto" + space(12) + "Und.Medida" +space(8) + "Pre‡o de Venda"
   Dbedit(04,03,20,77,,,,NCAMP,"Ä")
   zap
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

********************************
function LR_CUSTO_PRODUTO(Ind)
********************************
local getlist:={}
local L := 0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Tabela de Pre‡os Gerencial" color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to Ind
dbgotop()
if DESTINO = "I"
   if Imp_OK
      do while ! eof()
        if L==0
           Novo_Cab("Tabela de Pre‡os Gerencial",{"C¢d.","Produto",;
           "Pre‡o Venda","Pre‡o Custo","% Ganho"},{01,06,44,56,68})
           L+=6
        endif
        @ L,01 say PrCod
        @ L,06 say substr(PrNome,1,35)
        @ L,42 say PrPVenda pict "999,999.99"
        @ L,54 say PrPCusto pict "999,999.99"
        @ L,65 say ((PrPVenda-PrPCusto)/PrPVenda)*100 pict "99,999.99%"
        L++
        dbskip()
        if L = 58 .or. Eof()
           if !Eof()
              L:=59
           else
              L++
           endif
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      enddo
   endif
elseif DESTINO = "V"
   use RelTela alias Rel new
   Select _PRODUTOS
   do while ! eof()
      Nvar := str(PrCod) + space(2) + alltrim(PrNome)
      Tam  := 35 - Len(alltrim(PrNome))
      NVar := NVar + repl(".",Tam) + space(2) + transf(PrPVenda,"999,999.99")
      NVar := NVar + transf(PrPCusto,"999,999.99") + space(1) +;
       transf(((PrPVenda-PrPCusto)/PrPVenda)*100,"99,999.99%")
      dbskip()
      Select Rel
      Dbappend()
      field->Observacao  := NVar
      Select _PRODUTOS
   enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,02,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   Select Rel
   dbgotop()
   NCAMP := "C¢d." + space(02) + "Produto" + space(30) + "Pre‡o Venda" + ;
            space(2) + "Pre‡o Custo" + space(2) + "% Ganho"
   Dbedit(04,03,20,78,,,,NCAMP,"Ä")
   zap
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

***************************
function LR_VESTOQUE(Ind)
***************************
local getlist:={}, Nome_Rel:=" "
local L := Total:=0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Valorizacao do Estoque Atual " color ["W+*"]
Imp_OK := Imp_Doc()
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
use parament alias _parament new
Tipo_Rel = Par_PC_PV
close _parament
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to Ind
dbgotop()
if DESTINO = "I"
   if Imp_OK
      do while ! eof()
        if L==0
           if Tipo_Rel=="PC"
              Nome_Rel:="Pre‡o Custo Final"
           elseif Tipo_Rel=="PV"
              Nome_Rel:= "Pre‡o Venda"
           elseif Tipo_Rel=="PN"
              Nome_Rel:="Pre‡o Custo N.F."
           endif
           Novo_Cab("Valorizacao do Estoque Atual",{"C¢d.","Produto",;
           "Est. Atual",Nome_Rel,"Valor Atual"},{01,06,38,51,64})
           L+=6
        endif
        if PrEAtual > 0
           @ L,01 say PrCod
           @ L,06 say substr(PrNome,1,35)
           @ L,42 say transf(PrEAtual,"9999.999")
           if Tipo_Rel = "PC"
              Preco = PrPCusto
           elseif Tipo_Rel = "PV"
              Preco = PrPVenda
           elseif Tipo_Rel = "PN"
              select _ITENSCOMP
              set order to 2
              if dbseek(_PRODUTOS->PrCod)
                 set order to 5
                 dbseek(str(_PRODUTOS->PrCod-1,4),.T.)
                 Data:=ctod("01/01/98")
                 do while !EOF()
                    if ICDATA>=Data .and. ICCODPR=_PRODUTOS->PrCod
                       Preco:=PCustoIni   //Preco Item em Ultima Compra
                       Data:=ICDATA
                    endif
                    dbskip()
                    if ICCODPR>_PRODUTOS->PrCod
                       exit
                    endif
                 enddo
              else
                 Preco = _PRODUTOS->PrPCusto
              endif
              select _PRODUTOS
              if Preco=0
                 Preco:=PrPCusto
              endif
           endif
           @ L,52 say Preco pict "999,999.99"
           @ L,63 say PrEAtual*Preco pict "999,999.99"
           Total += PrEAtual*Preco
           L++
        endif
        dbskip()
        if L = 56 .or. Eof()
           L:=57
           @ L,00 say repl("-",80)
           L++
           @ L,58 say "Total:" + transf(Total,"999,999.99")
           L++
           @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
           eject
           P++
           L := 0
        endif
      enddo
   endif
elseif DESTINO = "V"
   use RelTela alias Rel new
   Select _PRODUTOS
   Total := 0
   do while ! eof()
      if PrEAtual > 0
         Nvar := str(PrCod) + space(2) + alltrim(PrNome)
         Tam  := 35 - Len(alltrim(PrNome))
         NVar := NVar + repl(".",Tam) + space(2) + transf(PrEAtual,"9999.999")

         if Tipo_Rel = "PC"
            Preco = PrPCusto
         elseif Tipo_Rel = "PV"
            Preco = PrPVenda
         elseif Tipo_Rel = "PN"
            select _ITENSCOMP
            set order to 2
            if dbseek(_PRODUTOS->PrCod)
               set order to 5
               dbseek(str(_PRODUTOS->PrCod-1,4),.T.)
               Data:=ctod("01/01/98")
               do while !EOF()
                  if ICDATA>=Data .and. ICCODPR=_PRODUTOS->PrCod
                     Preco:=PCustoIni   //Preco Item em Ultima Compra
                     Data:=ICDATA
                  endif
                  dbskip()
                  if ICCODPR>_PRODUTOS->PrCod
                     exit
                  endif
               enddo
             else
               Preco = _PRODUTOS->PrPCusto
            endif
            select _PRODUTOS
            if Preco=0
               Preco:=PrPCusto
            endif
         endif
         NVar := NVar + transf(Preco,"999,999.99") + space(2) +;
         transf(PrEAtual*Preco,"999,999.99")
         Total += PrEAtual*Preco
      endif
      if PrEst = "S" .and. PrEAtual > 0
         Select Rel
         Dbappend()
         field->Observacao  := NVar
         Select _PRODUTOS
      endif
      dbskip()
   enddo
   NVar := space(56) + "Total: " + transf(Total,"999,999.99")
   Select Rel
   Dbappend()
   field->Observacao  := NVar
   Select _PRODUTOS
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,02,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   Select Rel
   dbgotop()
   if Tipo_Rel=="PC"
      Nome_Rel:="Pre‡o Custo Final"
   elseif Tipo_Rel=="PV"
      Nome_Rel:= "Pre‡o Venda"
   elseif Tipo_Rel=="PN"
      Nome_Rel:="Pre‡o Custo N.F."
   endif
   NCAMP := "C¢d." + space(02) + "Produto" + space(25) + "Est. Atual" + ;
            space(2) + Nome_Rel + space(2) + "Valor Atual"
   Dbedit(04,03,20,78,,,,NCAMP,"Ä")
   zap
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil

*******************************
function RESTOQUE(Rotina,Ind)
*******************************
local getlist:={}
local C_INIC:=space(1),C_FINAL:=space(1),Imprimir:=.F.
local L,COD_INI:=COD_FIN:=0,Mensagem:=space(80)
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
cor := setcolor()
apaga(.T.)
@ 23,12 say "Digite o Produto Inicial e Final Para a emissao do Relat¢rio"
beep(2)
if Rotina == 1
   moldura(12,50,15,78,.F.," Relat¢rio Estoque Atual ")
   Mensagem := "Aguarde, Gerando Relat¢rio Estoque Atual "
elseif Rotina == 2
   moldura(12,41,15,78,.F.," Relat¢rio Estoque N„o Controlado ")
   Mensagem := "Aguarde, Gerando Relat¢rio Estoque Nao Controlado "
else
   moldura(12,41,15,78,.F.," Relat¢rio Estoque M¡nimo ")
   Mensagem := "Aguarde, Gerando Relat¢rio Estoque M¡nimo "
endif
if IND = 1
   @ 13,52 say "Produto Inicial :" get COD_INI   pict "9999" valid (COD_INI>0)
   @ 14,52 say "Poduto Final ...:" get COD_FIN   pict "9999" valid (COD_FIN>=COD_INI)
else
   @ 13,52 say "Caracter Inicial:" get C_INIC    pict "@!A" valid(!empty(C_INIC))
   @ 14,52 say "Caracter Final..:" get C_FINAL   pict "@!A" valid (!empty(C_FINAL) .AND. C_INIC<=C_FINAL)
endif
read
if lastkey() == K_ESC
   return nil
endif
@ 23,12 say Space(68)
apaga(.F.)
setcolor("&cor")
inicio := time()
@ 23,12 say space(69)
@ 23,12 say Mensagem color ["W+*"]
Imp_OK := Imp_Doc()
L := Tela := 0
P := 1
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to Ind
dbgotop()
if DESTINO <> "V"
   if Imp_OK
      do while ! eof()
         if L==0
            if Rotina == 1
               Novo_Cab("Estoque Atual",{"C¢digo","Nome do Produto","Estoque atual"},{01,09,50})
            elseif Rotina == 2
               Novo_Cab("Estoque Nao Controlado",{"C¢digo","Nome do Produto"},{01,09})
            else
               Novo_Cab("Estoque Abaixo do M¡nimo Estipulado",{"C¢digo","Nome do Produto","Est.Atual","Est.M¡nimo","Diferen‡a"},{01,10,36,47,58})
            endif
            L+=6
         endif
         Imprimir:=.F.
         if IND=1
           if (PrCod>=COD_INI).and.(PrCod<=COD_FIN)
              Imprimir:=.T.
           endif
         else
           if (left(PRNOME,1)>=C_INIC .and. left(PRNOME,1)<=C_FINAL)
              Imprimir:=.T.
           endif
         endif
         if Rotina == 1
            if Imprimir .and. PrEst = "S"
               @ L,01 say PrCod
               @ L,10 say PrNome
               @ L,55 say transform(PrEAtual,"9999.99")
               L++
            endif
         elseif Rotina == 2
            if Imprimir .and. PrEst = "N"
               @ L,01 say PrCod
               @ L,10 say PrNome
               L++
            endif
         else
            if PrEAtual<PrEMin .and. PrEst = "S"
               @ L,01 say PrCod                 pict "9999"
               @ L,06 say alltrim(substr(PrNome,1,35))
               @ L,42 say PrEAtual              pict "999"
               @ L,50 say PrEMin                pict "999"
               @ L,59 say (PrEAtual - PrEMin)   pict "9999"
               L++
            endif
         endif
         dbskip()
         if L = 58 .or. Eof()
            if !Eof()
              L:=59
            else
              L++
            endif
            @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
            eject
            P++
            L := 0
         endif
      enddo
   endif
else
   use RelTela alias Rel new
   Select _PRODUTOS
   do while ! eof()
      Imprimir:=.F.
      if IND=1
         if (PrCod>=COD_INI).and.(PrCod<=COD_FIN)
            Imprimir:=.T.
         endif
      else
         if (left(PRNOME,1)>=C_INIC .and. left(PRNOME,1)<=C_FINAL)
            Imprimir:=.T.
         endif
      endif
      if Rotina == 1
         if Imprimir .and. PrEst = "S"
             Nvar := str(PrCod) + space(5) + Alltrim(PrNome)
             Tam  := 35 - Len(alltrim(PrNome))
             NVar := NVar + repl(".",Tam) + space(2) + transf(PrEAtual,"9999.99")
             Select Rel
             Dbappend()
             field->Observacao  := NVar
             Select _PRODUTOS
         endif
      elseif Rotina == 2
         if Imprimir .and. PrEst = "N"
             Nvar := str(PrCod) + space(5) + PrNome
             Select Rel
             Dbappend()
             field->Observacao  := NVar
             Select _PRODUTOS
         endif
      else
         if PrEAtual<PrEMin .and. PrEst = "S"
            Nvar := str(PrCod) + space(5) + alltrim(PrNome)
            Tam  := 35 - Len(alltrim(PrNome))
            NVar := NVar + repl(".",Tam) + space(2) + transf(PrEAtual,"999") ;
                    + space(5)  + transf(PrEMin,"999") + space(5)  + transf(PrEAtual - PrEMin,"9999")
            Select Rel
            Dbappend()
            field->Observacao  := NVar
            Select _PRODUTOS
         endif
      endif
      dbskip()
   enddo
endif
Fim := Time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,16,21,70,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   Select Rel
   dbgotop()
   if Rotina == 1
      NCAMP := "C¢digo" + space(02) + "Produto" + space(25) + "Estoque Atual"
      Dbedit(04,17,20,69,,,,NCAMP,"Ä")
   elseif Rotina == 2
      NCAMP := "C¢digo" + space(02) + "Produto"+ space(25)
      Dbedit(04,17,20,69,,,,NCAMP,"Ä")
   else
      moldura(03,02,21,79,.F.," Impress„o na Tela ")
      NCAMP := "C¢digo" + space(02) + "Produto" + space(25) + "Est.Atual" + space(2) + "Est.M¡n." + space(2) + "Diferen‡a"
      Dbedit(04,03,20,78,,,,NCAMP,"Ä")
   endif
   zap
endif
Close Databases
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return NIL

**************************
function CR_PRODUTO(Ind)
**************************
local getlist:={} , L , DATA_INI:=DATA_FIM:= DATE() , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
Produto := {}
Valor   := {}
Nome    := {}
cor := setcolor()
apaga(.T.)
@ 23,12 say "Digite a Data Inicial e Final Para a Emissao do Relat¢rio"
beep(2)
moldura(11,43,14,71,.F.," Produto ")
@ 12,45 say "Data inicial .:" get DATA_INI  valid !empty(dtoc(DATA_INI))
@ 13,45 say "Data final ...:" get DATA_FIM  valid (!empty(dtoc(DATA_FIM));
 .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
setcolor("&cor")
inicio := inicio1 := time()
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Estat¡stica Por Produto " color ["W+*"]
Imp_OK := Imp_Doc()
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to Ind
dbgotop()
do while !eof()
   aadd(Produto,PrCod)
   aadd(Valor,0)
   aadd(Nome,substr(PrNome,1,35))
   dbskip()
enddo
close  _PRODUTOS
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
soma := 0
do while ! eof()
  if ImData >= DATA_INI .and. ImData  <= DATA_FIM
     select _MOVIMENT
     set order to 1
     if dbseek(_ITENSMOV->ImCod)
        select _OPERACOE
        set order to 1
        dbseek(_MOVIMENT->MovOper)
        select _ITENSMOV
        if _OPERACOE->OperTipo == "S" .OR. _OPERACOE->OperTipo == "N"
            nElem:=Ascan(Produto,ImcdPro)
            if nElem>0
               Novo_Valor := Valor[nElem]
               Valor[nElem] := Novo_Valor + ((100-Desconto)*(ImQtd * ImPreco))/100
               Soma += ((100-Desconto)*(ImQtd * ImPreco))/100
            endif
        endif
     endif
  elseif ImData > DATA_FIM
     exit
  endif
  dbskip()
enddo
L := Tela := 0
P := 1
if Imp_OK
 For i := 1 to Len(Produto)
  if L==0
     NCab(DATA_INI,DATA_FIM,"Estatistica Por Produto",{"C¢digo","Produto","Faturamento","%"},{01,10,47,62})
     L+=7
  endif
  if Valor[i] <> 0
    @ L,01 say Produto[i]
    @ L,10 say alltrim(Nome[i])
    @ L,47 say Valor[i] pict "999,999.99"
    @ L,59 say (Valor[i]*100)/Soma  pict "9999.99"
    L++
  endif
  if L = 58 .or. i==Len(Produto)
     L := 59
     @ L,00 say replicate ("-",76)
     L++
     @ L,40 say "Total :" + transf(soma,"999,999.99")
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
     eject
     P++
     L := 0
  endif
 next
endif
set device to screen
set printer off
set printer to
fim := time()
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

*************************
function R_FIM_CAIXA()
*************************
local getlist:={}
local SF_Vista := SF_Prazo := L := 0,Tot_Prazo:=0
local NCliente_Vista := NCliente_Prazo := 0
local DATA_INI:=DATA_FIM:=date() , FOperTipo := space(01)
local HORA_INI:="06:00:00", HORA_FIM:=TIME()
apaga(.T.)
@ 23,12 say "Digite as Informa‡oes Acima Para a Emissao do Relat¢rio"
beep(2)
moldura(05,43,10,71,.F.," Fechamento do Caixa ")
@ 06,45 say "Data Inicial :"  get DATA_INI  pict "99/99/99" valid (!EMPTY(dtoc(DATA_INI)))
@ 07,45 say "Data Final ..:"  get DATA_FIM  pict "99/99/99" valid (!EMPTY(dtoc(DATA_FIM)))
@ 08,45 say "Hora Inicial :"  get HORA_INI  pict "99:99:99" valid (!EMPTY(HORA_INI) .and. ;
  Testa_Hora(HORA_INI))
@ 09,45 say "Hora Final ..:"  get HORA_FIM  pict "99:99:99" valid (!EMPTY(HORA_FIM) .and. ;
  Testa_Hora(HORA_FIM))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Fechamento de Caixa " color ["W+*"]
Imp_OK := Imp_Doc()
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
set order to 2
dbgotop()
dbseek(Data_Ini,.T.)
do while .T.
  if MovDt >= Data_Ini
     dbskip(-1)
  elseif MovDt < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
inicio := seconds()
do while !eof()
   if (MovDt>=DATA_INI) .and. (MovDt<=DATA_FIM) .and.;
      (MovHr>=HORA_INI) .and. (MovHr<=HORA_FIM)
       select _OPERACOE
       set order to 1
       dbgotop()
       dbseek(_MOVIMENT->MovOper)
       select _MOVIMENT
       if _OPERACOE->OperTipo == "S"
          SF_Vista += Total_Mov
          NCliente_Vista++
       elseif _OPERACOE->OperTipo == "N"
          SF_Prazo += Total_Mov
          NCliente_Prazo++
       endif
    elseif MovDt>DATA_FIM
      exit
   endif
   dbskip()
enddo
OPEN MOVREC   ALIAS "_MOVREC"   INDEX MRecCli,MRecDt SHARED
set order to 2
dbseek(DATA_INI-1,.T.)
do while !eof()
   if (Data_Rec>=DATA_INI) .and. (Data_Rec<=DATA_FIM)
      Tot_Prazo+=Valor_Rec
   elseif Data_Rec>DATA_FIM
      exit
   endif
   dbskip()
enddo
select _MOVIMENT
Fim := seconds() - inicio
if DESTINO<>"V"
   L:=iif(prow()<=58,prow()+2,1)
else
   L:=0
endif
if Imp_OK
 @ L+1,1  SAY replicate ("=",36)
 @ L+2,7  SAY FIRMA
 @ L+3,1  SAY replicate ("=",36)
 @ L+4,1  SAY "Data Inicial: " + dtoc(DATA_INI)
 @ L+5,1  SAY "Data Final .: " + dtoc(DATA_FIM)
 @ L+6,1  SAY "Hora Inicial: " + HORA_INI
 @ L+7,1  SAY "Hora Final .: " + HORA_FIM
 @ L+8,1  SAY replicate ("=",36)
 @ L+9,1  SAY "Vendas a Vista : " + str(SF_Vista,10,2)
 @ L+10,1 SAY "Vendas a Prazo : " + str(SF_Prazo,10,2)
 @ L+11,1 SAY "  Total Vendas : " + str(SF_Vista+SF_Prazo,10,2)
 @ L+12,1 SAY replicate ("=",36)
 @ L+13,1 SAY "N§ Clientes Compra a Vista : " + alltrim(str(NCliente_Vista))
 @ L+14,1 SAY "N§ Clientes Compra a Prazo : " + alltrim(str(NCliente_Prazo))
 @ L+15,1 SAY "Total de Clientes Atendidos: " +alltrim(str(NCliente_Vista+NCliente_Prazo))
 @ L+16,1 SAY replicate ("=",36)
 @ L+17,1 SAY "Receb.Vendas a Prazo : " + str(Tot_Prazo,10,2)
 @ L+18,1 SAY replicate ("=",36)
 @ L+19,1 SAY "Dinheiro em Caixa    : " + str(SF_Vista+Tot_Prazo,10,2)
 @ L+20,1 SAY replicate ("=",36)
 @ L+21,1 SAY "TeraByte - Inform tica"
endif
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(05,25,21,64,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela " + "Tempo Gasto: " + ltrim(str(fim)) + " segundos"
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,06,26,20,63,.F.)
elseif DESTINO ="I"
   alert("Impress„o completa;Pressione algo para continuar!")
endif
Close Databases
return nil

**********************
function Real_CAIXA()
**********************
local getlist:={} , SF_Bonific := SF_Vista := SF_Prazo := NCliente := L := 0
local TSF_Bonific := TSF_Vista := TSF_Prazo := TNCliente := 0
local DATA_INI:=DATA_FIM:=date() , inicio , fim
local Dia_Ini := 0 , Dia_Fim := 0
NData := {} ; VAvista := {} ; VPrazo := {} ; VCliente := {} ; VBonif := {}
inicio := seconds()
@ 23,10 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Fechamento de Caixa Di rio " color ["W+*"]
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
set order to 2
apaga(.T.)
@ 23,12 say "Digite as Informa‡oes Acima Para a Emissao do Relat¢rio  "
beep(2)
moldura(05,43,08,71,.F.," Estatistica de Movimento ")
@ 06,45 say "Dia Inicial :"  get Dia_Ini  pict "99" valid (dia_Ini >= 1 .and. dia_Ini <= 31)
@ 07,45 say "Dia Final ..:"  get Dia_Fim  pict "99" valid (dia_Fim >= dia_Ini .and. dia_Fim <= 31)
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
@ 23,12 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Estatistica de Venda " color ["W+*"]
if Nova_Data < date()
   do case
      case Month(Nova_Data) = 4 .or. Month(Nova_Data)=6 .or. Month(Nova_Data)=9 .or. Month(Nova_Data)=11
           if Dia_Ini > 30
              Dia_Ini := 30
           endif
           if Dia_Fim > 30
              Dia_Fim := 30
           endif
      case Month(Nova_Data) = 2
         if mod(year(Nova_Data),4)=0
            if Dia_Ini > 29
               Dia_Ini := 29
            endif
            if Dia_Fim > 29
               Dia_Fim := 29
            endif
         else
            if Dia_Ini > 28
               Dia_Ini := 28
            endif
            if Dia_Fim > 28
               Dia_Fim := 28
            endif
         endif
   endcase
else
   if Dia_Ini > Day(Date())
      Dia_Ini := Day(Date())
   endif
   if Dia_Fim > Day(Date())
      Dia_Fim := Day(Date())
   endif
endif
DATA_INI := ctod(alltrim(str(Dia_Ini)) + "/" + alltrim(str(Month(Nova_Data)))  + "/" + alltrim(str(year(Nova_Data))))
DATA_FIM := ctod(alltrim(str(Dia_Fim)) + "/" + alltrim(str(Month(Nova_Data)))  + "/" + alltrim(str(year(Nova_Data))))
For I := Dia_Ini To Dia_Fim
    aadd(NData,alltrim(str(I)) + "/" + alltrim(str(Month(Nova_Data)))  + "/" + alltrim(str(year(Nova_Data))))
    aadd(VAvista,0)
    aadd(VPrazo,0)
    aadd(VCliente,0)
    aadd(VBonif,0)
Next
Imp_OK := Imp_Doc()
P := 1
dbgotop()
dbseek(ctod(NData[1]),.T.)
do while .T.
  if MovDt >= ctod(NData[1])
     dbskip(-1)
  elseif MovDt < ctod(NData[1])
     exit
  endif
  if BOF()
     exit
  endif
enddo
inicio := seconds()
Reg_Atual := Recno()
For I := 1 To len(NData)
  goto Reg_Atual
  SF_Vista := SF_Prazo := SF_Bonific:= NCliente := 0
  do while !eof()
     if MovDt = ctod(NData[I])
        NCliente++
        select _OPERACOE
        set order to 1
        dbgotop()
        dbseek(_MOVIMENT->MovOper)
        FOperTipo := OperTipo
        select _MOVIMENT
        if FOperTipo = "S"
          SF_Vista += Total_Mov
        elseif FOperTipo = "N"
          SF_Prazo += Total_Mov
        elseif FOperTipo = "B"
          SF_Bonific += Total_Mov
          NCliente--
        endif
     elseif MovDt > ctod(NData[I])
      Reg_Atual := Recno()
      exit
     endif
     dbskip()
  enddo
  VAvista[I]  := SF_Vista
  VPrazo[I]   := SF_Prazo
  VBonif[I]   := SF_Bonific
  VCliente[I] := NCliente
  TSF_Vista += VAvista[I]
  TSF_Prazo += VPrazo[I]
  TSF_Bonific += VBonif[I]
  TNCliente += VCliente[I]
next
Fim := seconds() - inicio
setprc(0,0)
if Imp_OK
   For I := 1 To Len(NData)
     If I = 1
          NCab(DATA_INI,DATA_FIM,"Estatistica de Movimento",{"Data","Cliente","Venda Vista","Venda Prazo","Bonific.","Total"},{02,15,27,42,55,65})
          L+=7
     endif
     @ L,00 say NData[i]
     @ L,17 say alltrim(str(VCliente[i]))
     @ L,29 say alltrim(str(VAvista[i]))
     @ L,44 say alltrim(str(VPrazo[i]))
     @ L,55 say alltrim(str(VBonif[i]))
     @ L,65 say alltrim(str(VAvista[i]+VPrazo[i]+VBonif[i]))
     L++
     if L = 58 .or. i==Len(NData)
        if L=58
           L := 59
        else
           L++
        endif
        @ L,00 say replicate ("-",76)
        L++
        @ L,01 say "Total:"
        @ L,17 say alltrim(str(TNCliente))
        @ L,29 say alltrim(str(TSF_Vista))
        @ L,44 say alltrim(str(TSF_Prazo))
        @ L,55 say alltrim(str(TSF_Bonific))
        @ L,65 say alltrim(str(TSF_Vista+TSF_Prazo+TSF_Bonific))
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",26)
        if L>=61 .or. i==Len(NData)
           eject
           P++
           L := 0
        endif
     endif
   next
endif
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela " + "Tempo Gasto: " + ltrim(str(fim)) + " segundos"
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
elseif DESTINO ="I"
   alert("Impress„o completa;Pressione algo para continuar!")
endif
Close Databases
return nil

***********************
function CR_FUNC(Ind)
***********************
local getlist:={}, L, Soma := SCliente := nElem := 0 , inicio , fim, TOTAL:=0
local DATA_INI:=DATA_FIM:= DATE() , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
EstFunc:={}
apaga(.T.)
@ 23,12 say "Digite a Data Inicial e Final Para a Emissao do Relat¢rio"
beep(2)
moldura(12,43,15,71,.F.," Funcion rio ")
@ 13,45 say "Data inicial .:" get DATA_INI  valid !empty(dtoc(DATA_INI))
@ 14,45 say "Data final ...:" get DATA_FIM  valid (!empty(dtoc(DATA_FIM)) ;
 .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
@ 23,11 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Estat¡stica Por Funcion rio "  color ["W+*"]
Imp_OK := Imp_Doc()
use parament alias _parament new
Comissao = Com_Func
close _parament
OPEN ESTFUNC ALIAS "_ESTFUNC" INDEX EST_VEND SHARED
OPEN CARGOS ALIAS "_CARGOS" INDEX CargCod,CargNome SHARED
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
set order to Ind
dbgotop()
inicio := time()
do while !eof()
   select _CARGOS
   set order to 1
   dbseek(_FUNCIONA->FuncCarg)
   if CargTipPg == "C"
      aadd(EstFunc,{_FUNCIONA->FunCod,0,0})
   endif
   select _FUNCIONA
   dbskip()
enddo
select _ESTFUNC
set order to 1
dbgotop()
dbseek(dtos(Data_Ini)+str(0),.T.)
do while .T.
  if DATA_VENDA >= Data_Ini
     dbskip(-1)
  elseif DATA_VENDA < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while ! eof()
  if DATA_VENDA>= DATA_INI .and. DATA_VENDA<= DATA_FIM
     nElem:=Ascan(EstFunc, {|aVal| aVal[1]==COD_FUNC})
     if nElem>0
        EstFunc[nElem,2]:=(EstFunc[nElem,2]+TOTAL_CLI)
        EstFunc[nElem,3]:=(EstFunc[nElem,3]+TOTALVENDA)
        SCliente+=TOTAL_CLI
        Soma+=TOTALVENDA
     endif
  elseif DATA_VENDA > DATA_FIM
     exit
  endif
  dbskip()
enddo
L := Tela := 0
P := 1
if DESTINO<>"V"
   L:=iif(prow()<=58,prow()+2,1)
   @ L,01 say chr(14) + FIRMA
   L++
   @ L,20 say alltrim("Estatistica Por Funcion rio")
   L++
   @ L,54 say "Data Inicial: "+dtoc(DATA_INI)
   L++
   @ L,00 say "Data Emissao Relatorio: "+dtoc(Date())
   @ L,54 say "Data Final  : "+dtoc(DATA_FIM)
   L++
   @ L,00 say replicate ("=",76)
   L++
   @ L,02 say "Funcionario"
   @ L,37 say "Faturam."
   @ L,49 say "%"
   @ L,52 say "Client"
   @ L,62 say "%"
   @ L,67 say "Com."+alltrim(str(Comissao))+"%"
   L++
   @ L,00 say replicate ("=",76)
   L++
else
   L:=0
endif
if Imp_OK
 For i := 1 to Len(EstFunc)
  if EstFunc[i,2]>0 .and. EstFunc[i,3]>0
     if L==0
        NCab(DATA_INI,DATA_FIM,"Estatistica Por Funcion rio",{"Funcion rio","Faturam.","%","Client","%","Com."+alltrim(str(Comissao))+"%"},{02,37,49,52,62,66})
        L+=7
     endif
     Select _FUNCIONA
     set order to 1
     dbseek(EstFunc[i,1])
     @ L,00 say EstFunc[i,1]
     @ L,03 say substr(alltrim(FuncNome),1,30)
     @ L,35 say EstFunc[i,3] pict "999,999.99"
     @ L,47 say (EstFunc[i,3]*100)/Soma  pict "999.99"
     @ L,55 say alltrim(str(EstFunc[i,2]),4)
     @ L,60 say (EstFunc[i,2]*100)/SCliente pict "999.99"
     Comissao :=  (EstFunc[i,3] * (Comissao/100))
     @ L,68 say Comissao pict "99999.99"
     L++
  endif
  if L = 58 .or. i==Len(EstFunc)
     if L=58
        L := 59
     else
        L++
     endif
     @ L,00 say replicate ("-",76)
     L++
     @ L,18 say "Faturamento :" + transf(soma,"999,999.99")
     @ L,46 say "Clientes: " + alltrim(str(SCliente))
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",26)
     if L>=61
        eject
        P++
        L := 0
     endif
  endif
 next
endif
set device to screen
set printer off
set printer to
fim := time()
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo Gasto: " + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

***********************
function CR_GRUPO(Ind)
***********************
local getlist:={}, L, Soma := nElem := 0 , inicio , fim
local DATA_INI:=DATA_FIM:= DATE() , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
EstFunc:={}
apaga(.T.)
@ 23,12 say "Digite a Data Inicial e Final Para a Emissao do Relat¢rio"
beep(2)
moldura(12,43,15,71,.F.," Grupos ")
@ 13,45 say "Data inicial .:" get DATA_INI  valid !empty(dtoc(DATA_INI))
@ 14,45 say "Data final ...:" get DATA_FIM  valid (!empty(dtoc(DATA_FIM)) ;
 .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
@ 23,11 say space(70)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Estat¡stica Por Grupo "  color ["W+*"]
Imp_OK := Imp_Doc()
OPEN ESTGRUP ALIAS "_ESTGRUP" INDEX EST_GRUP SHARED
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
set order to Ind
dbgotop()
inicio := time()
do while !eof()
   aadd(EstFunc,{GpCod,0})
   dbskip()
enddo
select _ESTGRUP
set order to 1
dbgotop()
dbseek(dtos(Data_Ini)+str(0,2),.T.)
do while .T.
  if DATA_VENDA >= Data_Ini
     dbskip(-1)
  elseif DATA_VENDA < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
do while ! eof()
  if DATA_VENDA>= DATA_INI .and. DATA_VENDA<= DATA_FIM
     nElem:=Ascan(EstFunc, {|aVal| aVal[1]==COD_GRUPO})
     if nElem>0
        Venda_Anterior :=  EstFunc[nElem,2]
        EstFunc[nElem,2]:= TOTALVENDA + Venda_Anterior
        Soma+=TOTALVENDA
     endif
  elseif DATA_VENDA > DATA_FIM
     exit
  endif
  dbskip()
enddo
L := Tela := 0
P := 1
if DESTINO<>"V"
   L:=iif(prow()<=58,prow()+2,1)
   @ L,01 say chr(14) + FIRMA
   L++
   @ L,20 say alltrim("Estatistica Por Grupos")
   L++
   @ L,54 say "Data Inicial: "+dtoc(DATA_INI)
   L++
   @ L,00 say "Data Emissao Relatorio: "+dtoc(Date())
   @ L,54 say "Data Final  : "+dtoc(DATA_FIM)
   L++
   @ L,00 say replicate ("=",76)
   L++
   @ L,02 say "Funcionario"
   @ L,37 say "Faturam."
   @ L,49 say "%"
   @ L,52 say "Client"
   @ L,62 say "%"
   @ L,67 say "Com.2,5%"
   L++
   @ L,00 say replicate ("=",76)
   L++
else
   L:=0
endif
if Imp_OK
 For i := 1 to Len(EstFunc)
  if EstFunc[i,2]>0
     if L==0
        NCab(DATA_INI,DATA_FIM,"Estatistica Por Grupo",{"C¢digo","Grupo","Faturamento","%"},{01,10,32,56})
        L+=7
     endif
     Select _Grupos
     set order to 1
     dbseek(EstFunc[i,1])
     @ L,00 say EstFunc[i,1]
     @ L,08 say substr(alltrim(GpNome),1,30)
     @ L,30 say EstFunc[i,2] pict "999,999.99"
     @ L,55 say ((EstFunc[i,2]*100)/Soma) pict "999.99"
     L++
  endif
  if L = 58 .or. i==Len(EstFunc)
     if L=58
        L := 59
     else
        L++
     endif
     @ L,00 say replicate ("-",76)
     L++
     @ L,18 say "Faturamento :"
     @ L,33 say soma pict "999,999.99"
     L++
     @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",26)
     if L>=61
        eject
        P++
        L := 0
     endif
  endif
 next
endif
set device to screen
set printer off
set printer to
fim := time()
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo Gasto: " + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

*********************
function R_CONTASP()
*********************
local getlist:={}
local L , DATA_INI:=DATA_FIM:= DATE() ,TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
cor := setcolor()
apaga(.T.)
@ 23,12 say "Digite a Data Inicial e Final Para a Emissao do Relat¢rio"
beep(2)
moldura(7,43,10,71,.F.," Contas a Pagar ")
@ 08,45 say "Data Inicial .:" get DATA_INI  valid !empty(dtoc(DATA_INI))
@ 09,45 say "Data Final ...:" get DATA_FIM  valid (!empty(dtoc(DATA_FIM));
 .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
setcolor("&cor")
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Contas a Pagar " color ["W+*"]
Imp_OK := Imp_Doc()
L := Tela := 0
P := 1
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
OPEN PAGAMENT ALIAS "_PAGAMENT" INDEX CO10_PGT,PGTODOC,PGTOFOR SHARED
set order to 1
dbgotop()
i := 1
Soma := 0
if Imp_OK
 do while ! eof()
  if L==0
     Novo_Cab("Relat¢rio de Contas a Pagar",{"N§ do Doc.","Nome Fornecedor","Dt. Venc.","Valor","Situa‡„o"},{01,12,33,45,60})
     L+=6
  endif
  if PgDataPrv >= DATA_INI .and. PgDataPrv <= DATA_FIM ;
     .and. Empty(PgData) .and. Empty(PgValor)
     @ L,02 say PgNumDoc
     Codigo := val(right(str(PgNumDoc),3))
     select _FORNECED
     set order to 1
     dbgotop()
     dbseek(Codigo)
     @ L,12 say alltrim(substr(ForNome,1,20))
     select _PAGAMENT
     @ L,33 say PgDataPrv  pict "99/99/99"
     @ L,45 say PgValorPrv pict "999,999.99"
     Soma += PgValorPrv
     Situacao := ""
     if year(date()) = year(PgDataPrv)
        if month(date()) > month(PgDataPrv)
           Situacao := "-- Atrasado --"
        elseif month(date()) = month(PgDataPrv)
           if day(Date()) > day(PgDataPrv)
              Situacao := "-- Atrasado --"
           else
              Situacao := "-- ** --"
           endif
       else
          Situacao := "-- ** --"
       endif
     elseif year(date()) > year(PgDataPrv)
        Situacao := "-- Atrasado --"
     else
        Situacao := "-- ** --"
     endif
     @ L,60 say Situacao
     L++
  endif
  dbskip()
  if L = 58 .or. Eof()
     if eof()
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,36 say "Total :"
        @ L,46 say soma pict "999,999.99"
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

*************************
function R_CONTASR(Ind)
*************************
local getlist:={} , L := Soma_Total := 0
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol()) , inicio , Fim
inicio := time()
@ 23,12 say space(69)
If Ind == 1
   @ 23,12 say "Aguarde, Gerando Relat¢rio de Contas a Receber Por Cliente" color ["W+*"]
else
   @ 23,12 say "Aguarde, Gerando Relat¢rio de Dias Sem Acerto do Contas a Receber" color ["W+*"]
   Data_Atual = date()
endif
Imp_OK := Imp_Doc()
P := 1
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
set order to 1
dbgotop()
if Imp_OK
 do while ! eof()
  if L==0
     if Ind == 1
        Novo_Cab("Relat¢rio de Contas a Receber",{"C¢digo","Nome do Cliente","Data Pendente","Total"},{01,08,43,65})
     else
        Novo_Cab("Relat¢rio de Contas a Receber",{"C¢digo","Nome do Cliente","Data Pendente","N§ Dias Sem Acerto"},{01,08,40,57})
     endif
     L+=6
  endif
  @ L,02 say str(ClCod)
  @ L,08 say alltrim(substr(ClNome,1,30))
  @ L,47 say DTPendente pict "99/99/99"
  if Ind == 1
     Total_Rec := ClValor + ClPendente
     @ L,61 say Total_Rec pict "999,999.99"
     Soma_Total += Total_Rec
  else
     @ L,61 say Data_Atual - DTPendente pict "999,999.99"
  endif
  L++
  dbskip()
  if L = 58 .or. Eof()
     if eof()
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,51 say "Total :"
        @ L,61 say Soma_Total pict "999,999.99"
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil

*********************
function R_CONTASR2()
*********************
local getlist:={} , L := Soma_Total := Soma_Doc := 0, DATA_INI:=DATA_FIM:= DATE()
local TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol()) , inicio , Fim
apaga(.T.)
@ 23,12 say "Digite a Data Inicial e Final Para a Emissao do Relat¢rio"
beep(2)
moldura(7,43,10,71,.F.," Contas a Receber ")
@ 08,45 say "Data Inicial .:" get DATA_INI  valid !empty(dtoc(DATA_INI))
@ 09,45 say "Data Final ...:" get DATA_FIM  valid (!empty(dtoc(DATA_FIM));
 .and. Testa_Data(dtoc(DATA_INI),dtoc(DATA_FIM)))
read
if lastkey() == K_ESC
   return nil
endif
apaga(.F.)
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio de Contas a Receber " color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
OPEN ITENSREC ALIAS "_ITENSREC" INDEX IRCodDt SHARED
OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
set order to 3
dbgotop()
Dbseek(Data_Ini,.T.)
do while .t.
  if Rec_Dt >= Data_Ini
     dbskip(-1)
  elseif Rec_Dt < Data_Ini
     exit
  endif
  if BOF()
     exit
  endif
enddo
Soma_Total := Soma_Doc := 0
if Imp_OK
 do while ! eof()
  if L==0
     Novo_Cab("Relat¢rio de Contas a Receber",{"N§ do Doc.","Nome do Cliente","Data da Compra","Total do Doc."},{01,12,43,60})
     L+=6
  endif
  if Rec_Dt >= DATA_INI .and. Rec_Dt <= DATA_FIM
     Codigo :=  Rec_Cod
     @ L,02 say Rec_Cod
     select _CLIENTES
     set order to 1
     dbgotop()
     dbseek(_RECEB->Rec_Cli)
     @ L,12 say alltrim(substr(ClNome,1,30))
     select _RECEB
     @ L,45 say Rec_Dt pict "99/99/99"
     Soma_Doc := 0
     select _ITENSREC
     set order to 1
     dbgotop()
     Dbseek(Codigo,.T.)
     do while .t.
        if IrCod >= Codigo
           dbskip(-1)
        elseif IrCod < Codigo
           exit
        endif
        if BOF()
           exit
        endif
     enddo
     do while ! eof()
        if IrCod = Codigo
           Soma_Doc += (IrQtd * IrPreco)
        elseif IrCod > Codigo
           exit
        endif
        dbskip()
     enddo
     Soma_Total += Soma_Doc
     select _RECEB
     @ L,61 say Soma_Doc pict "999,999.99"
     L++
  endif
  dbskip()
  if L = 58 .or. Eof()
     if eof()
        L:=59
        @ L,00 say replicate ("-",76)
        L++
        @ L,51 say "Total :"
        @ L,61 say Soma_Total pict "999,999.99"
        L++
        @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
        eject
     else
        L := 59
        @ L,00 say repl("-",28) + " TeraByte Inform tica " + repl("-",29)
        eject
        P++
        L := 0
     endif
  endif
 enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,01,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   texto := memoread("Tela.Prn")
   memoedit(Texto,04,02,20,78,.F.)
endif
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
Close Databases
return nil


*************************
function LR_ICMS_RETIDO()
*************************
local getlist:={}, DATA_ANTERIOR:=DATE(),ICMSC:=0,TEMICMSR:="N", PRECOCUSTO:=0
local L := 0 , TELA_RELATORIO := savescreen(0,0,maxrow(),maxcol())
inicio := time()
@ 23,12 say space(69)
@ 23,12 say "Aguarde, Gerando Relat¢rio ICMS Retido" color ["W+*"]
Imp_OK := Imp_Doc()
P := 1
OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC SHARED
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
set order to 2
dbgotop()
if DESTINO = "I"
   if Imp_OK
      do while ! eof()
         if L==0
            Novo_Cab("Tabela de Pre‡os Gerencial",{"C¢d.","Produto",;
            "Pre‡o Venda","Pre‡o Custo","ICMS Ret."},{01,06,44,56,68})
            L+=6
         endif
         DATA_ANTERIOR:=ctod("01/01/91")
         ICMSC:=0
         TEMICMSR:="N"
         PRECOCUSTO:=0
         select _ITENSCOMP
         set order to 2
         if dbseek(_PRODUTOS->PrCod)
            dbseek(_PRODUTOS->PrCod-1,.T.)
            do while !EOF()
               if _PRODUTOS->PrCod= ICCODPR
                  select _COMPRAS
                  set order to 5
                  dbseek(_ITENSCOMP->NDOC_COM)
                  if DATA_ANTERIOR<=CPDATA
                     DATA_ANTERIOR:= CPDATA
                     ICMSC        := _ITENSCOMP->IcPrICMC
                     TEMICMSR   := _ITENSCOMP->TemICMSRet
                     PRECOCUSTO := _ITENSCOMP->PCustoIni
                  endif
               elseif _PRODUTOS->PrCod< ICCODPR
                  exit
               endif
               select _ITENSCOMP
               set order to 2
               dbskip()
            enddo
         endif
         select _PRODUTOS
         if TEMICMSR=="S"
            @ L,01 say PrCod
            @ L,06 say substr(PrNome,1,35)
            @ L,42 say PrPVenda pict "999,999.99"
            @ L,54 say PRECOCUSTO pict "999,999.99"
            @ L,65 say ICMSC    pict "99,999.99"
            L++
            dbskip()
            if L = 58 .or. Eof()
               if !Eof()
                  L:=59
               else
                  L++
               endif
               @ L,00 say repl("-",25) + " TeraByte Inform tica " + repl("-",25)
               eject
               P++
               L := 0
            endif
         else
            dbskip()
         endif
      enddo
   endif
elseif DESTINO = "V"
   use RelTela alias Rel new
   Select _PRODUTOS
   do while ! eof()
      DATA_ANTERIOR:=ctod("01/01/91")
      ICMSC:=0
      TEMICMSR:="N"
      PRECOCUSTO:=0
      select _ITENSCOMP
      set order to 2
      if dbseek(_PRODUTOS->PrCod)
         dbseek(_PRODUTOS->PrCod-1,.T.)
         do while !EOF()
            if _PRODUTOS->PrCod= ICCODPR
               select _COMPRAS
               set order to 5
               dbseek(_ITENSCOMP->NDOC_COM)
               if DATA_ANTERIOR<=CPDATA
                  DATA_ANTERIOR:= CPDATA
                  ICMSC        := _ITENSCOMP->IcPrICMC
                  TEMICMSR     := _ITENSCOMP->TemICMSRet
                  PRECOCUSTO := _ITENSCOMP->PCustoIni
               endif
            elseif _PRODUTOS->PrCod< ICCODPR
               exit
            endif
            select _ITENSCOMP
            set order to 2
            dbskip()
         enddo
      endif
      select _PRODUTOS
      if TEMICMSR=="S"
         Nvar := str(PrCod) + space(2) + alltrim(PrNome)
         Tam  := 35 - Len(alltrim(PrNome))
         NVar := NVar + repl(".",Tam) + space(2) + transf(PrPVenda,"999,999.99")
         NVar := NVar + transf(PRECOCUSTO,"999,999.99") + space(1) +;
          transf(ICMSC,"99,999.99")
         dbskip()
         Select Rel
         Dbappend()
         field->Observacao  := NVar
      else
         dbskip()
      endif
   enddo
endif
Fim := time()
set device to screen
set printer off
set printer to
if DESTINO ="V"
   moldura(03,02,21,79,.F.," Impress„o na Tela ")
   @ 23,11 say space(70)
   Mensagem := "<ESC> - Retorna " + chr(24) + " Sobe Tela " + chr(25) + " Desce Tela" + " Tempo :" + elaptime(inicio,fim)
   @ 23,11 say Mensagem
   Select Rel
   dbgotop()
   NCAMP := "C¢d." + space(02) + "Produto" + space(30) + "Pre‡o Venda" + ;
            space(2) + "Pre‡o Custo" + space(2) + "ICMS Ret."
   Dbedit(04,03,20,78,,,,NCAMP,"Ä")
   zap
endif
Close Databases
set cursor on
restscreen(0,0,maxrow(),maxcol(),TELA_RELATORIO)
return nil






 
