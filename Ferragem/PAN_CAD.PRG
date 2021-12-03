
# include "BOX.CH"
# include "INKEY.CH"
# include "SETCURS.CH"
# include "PAN.CH"
# include "Getpass.ch"
# include "Getexit.ch"

********************
Function Cad_Pro()
********************
local GetList:={},  Conf, STela_Pro := savescreen(0,0,maxrow(),maxcol())
local Novo_Rec:=0,arq_atual,EProduto:=.F.
apaga(.T.)
@ 23,00 say Space(80)
OPEN UNMEDIDA  ALIAS "_UNMEDIDA" INDEX COD_UNMED,NOME_UNMED SHARED
if lastrec()=0
   Alerta(11,15,"Nao Ha Nenhuma Unidade de Medida Cadastrada!!")
   close all
   return nil
endif
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
if lastrec()=0
   Alerta(11,15,"Nao Ha Nenhum Grupo Cadastrado!!")
   close all
   return nil
endif
OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
SKDADO:={"_PRODUTOS","PrCod"}
set order to 1
dbgotop()
moldura(06,20,20,68,.f.," Cadastro de Produtos ")
@ 23,00 say "<ESC> Retorna <F2> Help do Produto <F9> Prox. Codigo <F10> Calculadora"
do while lastkey() <> K_ESC
 EProduto:=.F.
 Conf = space(01)
 Slinha := savescreen(00,00,24,80)
 inic_var()
 dbgobottom()
 FPrCod = 0
 set key K_F9 to Prox_Cod()
 set key K_F2 to Help_Produto()
 FPrCod := Prox_Cod()
 @ 07,21 say "Codigo :" Get FPrCod pict "9999" valid(FPrCod > 0)
 Read
 set key K_F9 to
 set key K_F2 to
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),STela_Pro)
    exit
 endif
 achou_Produto := ENCONTROU(FPrCod)
 if achou_Produto
    igual_var()
 endif
 testa("_GRUPOS",FPrGrupo,,18,37,"GpNome")
 testa("_UnMedida",FPrUnidMed,,15,44,"Nome_UnMed")
 @ 09,22 say "Nome  :" Get FPrNome pict "@!" ;
   valid(Ver_Cadastro(FPrNome,FPrCod,"Produto ja Cadastrado,<Pressione qualquer Tecla para continuar>");
   .and. !Empty(FPrNome)) when HelpVar("O Campo Nome deve Ser Diferente de Vazio..!",80,23,0)
 @ 10,21 say Repl("?",18) + " Preco " + Repl("?",18)
 @ 11,22 say "Custo :" Get FPrPCusto pict "@E 9,999,999.99" ;
             valid(FPrPCusto>=0);
             when HelpVar("O Campo Custo Aceita Preco de Custo Maior ou Igual a Zero..!",80,23,0)
 @ 11,43 say "Venda :" Get FPrPVenda pict "@E 9,999,999.99";
             valid(FPrPVenda>=0) ;
             when HelpVar("O Campo Venda Deve Ser Maior ou Igual ao Campo Custo..!",80,23,0)
 @ 12,21 say Repl("?",17) + " Estoque " + Repl("?",17)
 @ 13,22 say "Atual :"  Get FPrEAtual Pict "9999.999" ;
             when HelpVar("O Campo Atual Aceita Zero..!",80,23,0)
 @ 13,42 say "Minimo :" Get FPrEMin   Pict "999"
             //valid(FPrEAtual >= FPrEMin) ;
             //when HelpVar("O Campo M?nimo deve ser Menor que o Campo Atual..!",80,23,0)
 @ 14,21 say Repl("?",10) + " Informacoes Adicionais " + Repl("?",8)
 @ 15,22 say "Unidade Medida :" Get FPrUnidMed pict "999" ;
   valid(pesquisa(05,30,13,66,"_UnMedida",FPrUnidMed,"Cod_UnMed","Nome_UnMed"," Un. Medida ") ;
   .and. testa("_UnMedida",FPrUnidMed,,15,44,"Nome_UnMed")) ;
   when HelpVar("Pressione o Enter? Para Acessar Un.Medida",80,23,0)
 @ 16,22 say "Controla Estoque:" Get FPrEst Pict "@!" valid( FPrEst $ "SN") ;
             when HelpVar("Digite <S> P/ Controlar Estoque e <N> P/ Nao Controlar Estoque",80,23,0)
 @ 17,21 say Repl("?",18) + " Grupo " + Repl("?",18)
 @ 18,22 say "Grupo :" Get FPrGrupo pict "999" ;
   valid(pesquisa(05,33,13,65,"_Grupos",FPrGrupo,"GpCod","GpNome"," Grupos ") ;
   .and. testa("_GRUPOS",FPrGrupo,,18,37,"GpNome")) ;
   when HelpVar("Pressione ?Enter? Para Acessar Grupos",80,23,0)
 Read
 select _PRODUTOS
 @ 23,00 say Space(80)
 @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
 read
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),STela_Pro)
    exit
 endif
 if CONF=="S"
    if updated()
       rlock()
       if ! achou_Produto
          Dbappend()
       endif
       reply_var(.T.)
       unlock
    endif
 elseif CONF=="E"
    Novo_Rec  := recno()
    arq_atual := alias()
    Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
    IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
    IndIt2   := "ITCP" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
    IndIt3   := "ITDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
    OPEN "&Nome_Arq" ALIAS "_ITENSMOV" INDEX "&IndIt1","&IndIt2","&IndIt3"  SHARED
    set order to 2
    if dbseek(FPrCod)
       EProduto := .T.
    endif
    close _ITENSMOV
    if !EProduto
       OPEN ITENSCOMP ALIAS "_ITENSCOMP" INDEX CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP SHARED
       set order to 2
       if dbseek(FPrCod)
          EProduto := .T.
       endif
       close _ITENSCOMP
    endif
    select &arq_atual
    dbgoto(Novo_Rec)
    if EProduto
       Alerta(11,25,"Nao Posso Deletar Esse Registro")
    else
       do while .t.
          if n_reclock()
             if confirma("Excluir Produto ?") == 1
                OPEN PRANT ALIAS "_PRANT" INDEX COD_PRAN,NO_PRAN SHARED
                set order to 1
                dbappend()
                field ->PrCod    := _PRODUTOS->PrCod
                field ->PrNome   := _PRODUTOS->PrNome
                field ->PrGrupo  := _PRODUTOS->PrGrupo
                field ->PrPVenda := _PRODUTOS->PrPVenda
                field ->PrData   := date()
                field ->PrHora   := Time()
                close _PRANT
                select _PRODUTOS
                delete
             endif
             exit
          endif
       enddo
       unlock
    endif
 endif
 @ 07,21 clear to 17,64
 restscreen(00,00,24,80,Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Pro)
close _UNMEDIDA
close _GRUPOS
close _PRODUTOS
return nil

********************
Function Cad_Cli_Juridica()
********************
local GetList:={}, Achou_Cliente
local Conf, STela_Cli := savescreen(0,0,maxrow(),maxcol())
apaga(.T.)
OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
SKDADO:={"_CLIENTES","ClCod"}
@ 27,00 say Space(80)
moldura(04,02,22,75,.f.," Cadastro de Clientes - Pessoa Juridica ")
@ 27,00 say "<ESC> Retorna <Enter> Help do Cliente <F9> Prox. Codigo <F10> Calculadora"
do while lastkey() <> K_ESC
 Conf = space(01)
 Slinha := savescreen(23,00,23,maxcol())
 set order to 1
 rlock()
 inic_var()
 dbgobottom()
 FClCod := 0
 set key K_F9 to Prox_Cod()
 @ 05,14 say "Codigo :" Get FClCod pict "999" ;
  valid(pesquisa(06,18,15,67,"_Clientes",FClCod,"ClCod","ClNome"," Clientes "))
 Read
 set key K_F9 to
 if FClCod == 0
    loop
 endif
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),STela_Cli)
    exit
 endif
 Achou_Cliente := ENCONTROU(FClCod)
 if achou_Cliente
    igual_var()
 endif
 @ 05,27 say "Razao Social :"      Get FRAZAOSOCIAL pict "@!" ;
   valid(Ver_Cadastro(FRAZAOSOCIAL,FClCod,"Cliente ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
 @ 07,37 say "Nome Fantasia :"     Get FNOMEFANTASIA pict "@!"
 @ 09,12 say "Endereco :"  get FClEnd Pict "@!"
 @ 11,14 say "Bairro :"    get FClBairro Pict "@!"
 @ 11,45 say "Cidade :"    get FClCid Pict "@!"
 @ 13,17 say "Cep :"       get FClCep  Pict "@R 99999-999"
 @ 13,43 say "Telefone :"  get FNUMEROTELEFONE Pict "@R (99999) 9999-9999"
 @ 15,12 say "Situaçao Cadastral :"  get FSITUACAOCADASTRAL   Pict "@!"
 @ 15,48 say "CNPJ :"       get FCLCNPJ  Pict "99.999.999/9999-99"
 @ 17,07 say "Data abertura :"  get FDATAABERTURA  Pict "99/99/99"
 @ 19,17 say "CNAE :"    get FCNAE Pict "@!"
 @ 21,17 say "Cod Juridico :"    get FCODIGONATUREZAJURIDICA Pict "@!"
 @ 23,03 say "Email responsavel :"  get FEMAILRESPONSAVEL Pict "@!"
 Read
 FTIPOPESSOA := "JURIDICA"
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),STela_Cli)
    set order to 2
    exit
 endif
 @ 25,00 say Space(80)
 @ 25,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
 read
 if lastkey()==K_ESC
    restscreen(0,0,maxrow(),maxcol(),STela_Cli)
    set order to 2
    exit
 endif
 if CONF=="S"
    if updated()
       if ! achou_Cliente
          Dbappend()
       endif
       reply_var(.T.)
    endif
   elseif CONF=="E"
     OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
     Set Order to 2
     dbgotop()
     if dbseek(FClCod)
        Alerta(11,10,"Nao Posso Deletar Esse Registro, Existe Recebimento Pendente..!")
     else
        select _CLIENTES
        do while .t.
          if n_reclock()
             if confirma("Excluir Cliente ?") == 1
                delete
             endif
             exit
          endif
        enddo
        unlock
     endif
     close _RECEB
 endif
 select _CLIENTES
 unlock
 @ 05,03 clear to 21,74
 restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Cli)
set order to 2
close _CLIENTES
return nil

********************
Function Cad_Cli_Fisica()
   ********************
   local GetList:={}, Achou_Cliente
   local Conf, STela_Cli := savescreen(0,0,maxrow(),maxcol())
   apaga(.T.)
   OPEN CLIENTES ALIAS "_CLIENTES" INDEX ClCod,ClNome SHARED
   SKDADO:={"_CLIENTES","ClCod"}
   @ 23,00 say Space(80)
   moldura(04,02,22,75,.f.," Cadastro de Clientes - Pessoa Fisica ")
   @ 23,00 say "<ESC> Retorna <Enter> Help do Cliente <F9> Prox. Codigo <F10> Calculadora"
   do while lastkey() <> K_ESC
    Conf = space(01)
    Slinha := savescreen(23,00,23,maxcol())
    set order to 1
    rlock()
    inic_var()
    dbgobottom()
    FClCod := 0
    set key K_F9 to Prox_Cod()
    @ 05,14 say "Codigo :" Get FClCod pict "999" ;
     valid(pesquisa(06,18,15,67,"_Clientes",FClCod,"ClCod","ClNome"," Clientes "))
    Read
    set key K_F9 to
    if FClCod == 0
       loop
    endif
    if lastkey()==K_ESC
       restscreen(0,0,maxrow(),maxcol(),STela_Cli)
       exit
    endif
    Achou_Cliente := ENCONTROU(FClCod)
    if achou_Cliente
       igual_var()
    endif
    @ 05,27 say "Nome :"      Get FClNome pict "@!" ;
      valid(Ver_Cadastro(FClNome,FClCod,"Cliente ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
    @ 07,12 say "Endereco :"  get FClEnd Pict "@!"
    @ 09,14 say "Bairro :"    get FClBairro Pict "@!"
    @ 09,45 say "Cidade :"    get FClCid Pict "@!"
    @ 11,17 say "Cep :"       get FClCep  Pict "@R 99999-999"
    @ 11,43 say "Telefone :"  get FClFone Pict "@R (99999) 9999-9999"
    @ 13,12 say "Numero do RG :"  get FClRG   Pict "@!"
    @ 13,48 say "CPF :"       get FClCPF  Pict "999.999.999-99"
    @ 15,07 say "Dt Nascimento :"  get FCLDTNASC  Pict "99/99/99"
    @ 17,17 say "PAI :"    get FClMAE Pict "@!"
    @ 19,17 say "MAE :"    get FClPAI Pict "@!"
    @ 21,03 say "Local de Trabalho :"  get FClTRAB Pict "@!"
    Read
    FTIPOPESSOA := "FISICA"
    if lastkey()==K_ESC
       restscreen(0,0,maxrow(),maxcol(),STela_Cli)
       set order to 2
       exit
    endif
    @ 23,00 say Space(80)
    @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
    read
    if lastkey()==K_ESC
       restscreen(0,0,maxrow(),maxcol(),STela_Cli)
       set order to 2
       exit
    endif
    if CONF=="S"
       if updated()
          if ! achou_Cliente
             Dbappend()
          endif
          reply_var(.T.)
       endif
      elseif CONF=="E"
        OPEN RECEB ALIAS "_RECEB" INDEX RCodDt,RCodCli,RecDt SHARED
        Set Order to 2
        dbgotop()
        if dbseek(FClCod)
           Alerta(11,10,"Nao Posso Deletar Esse Registro, Existe Recebimento Pendente..!")
        else
           select _CLIENTES
           do while .t.
             if n_reclock()
                if confirma("Excluir Cliente ?") == 1
                   delete
                endif
                exit
             endif
           enddo
           unlock
        endif
        close _RECEB
    endif
    select _CLIENTES
    unlock
    @ 05,03 clear to 21,74
    restscreen(23,00,23,maxcol(),Slinha)
   enddo
   restscreen(0,0,maxrow(),maxcol(),STela_Cli)
   set order to 2
   close _CLIENTES
   return nil
   

**********************
Function Cad_Grupo()
**********************
local GetList:={}, EGrupo:=.F.
local STela_Grupo := savescreen(0,0,maxrow(),maxcol()),Conf
apaga(.T.)
OPEN GRUPOS  ALIAS "_GRUPOS" INDEX CO2_GRUP,NO2_GRUP SHARED
SKDADO:={"_GRUPOS","GpCod"}
set order to 1
HelpVar("<ESC> Retorna <Enter> Help do Grupo <F9> Prox. Codigo <F10> Calculadora",80,23,00)
moldura(10,20,17,64,.f.," Cadastro de Grupos ")
do while lastkey() <> K_ESC
   EGrupo:=.F.
   Conf = space(01)
   Slinha := savescreen(23,00,23,maxcol())
   rlock()
   inic_var()
   dbgobottom()
   FGpCod = 0
   set key K_F9 to Prox_Cod()
   @ 12,22 say "             Codigo :" Get FGpCod pict "999" ;
      valid(pesquisa(13,18,19,52,"_GRUPOS",FGpCod,"GpCod","GpNome"," Grupos "))
   Read
   set key K_F9 to
   if FGpCod == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Grupo)
      exit
   endif
   Achou_Grupo := ENCONTROU(FGpCod)
   if Achou_Grupo
      igual_var()
   endif
   @ 14,22 say "               Nome :" Get FGpNome pict "@!" ;
     valid(Ver_Cadastro(FGpNome,FGpCod,"Grupo ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
   @ 16,22 say "Gera Comissao(S/N)? :" Get FGpCom pict "@!" ;
     valid(FGpCom$"SN")
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Grupo)
      exit
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Grupo)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! achou_Grupo
            Dbappend()
         endif
         reply_var(.T.)
      endif
    elseif CONF=="E"
      codigo := GpCod
      Novo_Rec := recno()
      arq_atual := alias()
      OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
      set order to 3
      dbgotop()
      if dbseek(Codigo)
         EGrupo := .T.
      endif
      close _PRODUTOS
      select &arq_atual
      dbgoto(Novo_Rec)
      if EGrupo
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
       else
         do while .t.
            if n_reclock()
               if confirma("Excluir Grupo ?") == 1
                  delete
               endif
               exit
            endif
         enddo
      endif
   endif
   @ 11,21 clear to 16,63
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Grupo)
close _GRUPOS
return nil


********************
Function Cad_UnMed()
********************
local GetList:={}, EUnMed:=.F.
local STela_UnMed := savescreen(0,0,maxrow(),maxcol()),Conf
apaga(.T.)
OPEN UNMEDIDA  ALIAS "_UNMEDIDA" INDEX COD_UNMED,NOME_UNMED SHARED
SKDADO:={"_UNMEDIDA","COD_UNMED"}
set order to 1
HelpVar("<ESC> Retorna <Enter> Help de Un.Medida <F9> Prox. Codigo <F10> Calculadora",80,23,00)
moldura(10,20,17,64,.f.," Cadastro de Unidade de Medida ")
do while lastkey() <> K_ESC
   EUnMed:=.F.
   Conf = space(01)
   Slinha := savescreen(23,00,23,maxcol())
   rlock()
   inic_var()
   dbgobottom()
   FCod_UnMed = 0
   set key K_F9 to Prox_Cod()
   @ 12,22 say "        Codigo :" Get FCod_UnMed pict "999" ;
      valid(pesquisa(13,18,19,52,"_UNMEDIDA",FCod_UnMed,"Cod_UnMed","Nome_UnMed"," Un. Medida "))
   Read
   set key K_F9 to
   if FCod_UnMed == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_UnMed)
      exit
   endif
   Achou_UnMed := ENCONTROU(FCod_UnMed)
   if Achou_UnMed
      igual_var()
   endif
   @ 14,22 say "          Nome :" Get FNome_UnMed pict "@!" ;
     valid(Ver_Cadastro(FNome_UnMed,Cod_UnMed,"Un.Medida ja Cadastrada,<Pressione qualquer Tecla para continuar>"))
   @ 16,22 say "Inteiro (S/N)? :" Get FInteiro pict "@!" ;
     valid(FInteiro$"SN")
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_UnMed)
      exit
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_UnMed)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! achou_UnMed
            Dbappend()
         endif
         reply_var(.T.)
      endif
    elseif CONF=="E"
      codigo := Cod_UnMed
      Novo_Rec := recno()
      arq_atual := alias()
      OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
      set order to 1
      dbgotop()
      do while !eof()
         if PrUnidMed==FCod_UnMed
            EUnMed := .T.
            exit
         endif
         skip
      enddo
      close _PRODUTOS
      select &arq_atual
      dbgoto(Novo_Rec)
      if EUnMed
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
       else
         do while .t.
            if n_reclock()
               if confirma("Excluir Un. Medida ?") == 1
                  delete
               endif
               exit
            endif
         enddo
      endif
   endif
   @ 11,21 clear to 16,63
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_UnMed)
close _UnMedida
return nil

*********************
Function Cad_Func()
********************
local GetList:={}, EFunc := .F.
local STela_Func := savescreen(0,0,maxrow(),maxcol()),Conf
Tela_Func:=savescreen(0,0,maxrow(),maxcol())
apaga(.T.)
OPEN CARGOS ALIAS "_CARGOS" INDEX CargCod,CargNome SHARED
if lastrec()=0
   Alerta(11,15,"Nao Ha Nenhum Cargo Cadastrado!!")
   close all
   return nil
endif
OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
set order to 1
SKDADO:={"_FUNCIONA","FunCod"}
set key K_F6 to Carg_Help()
moldura(04,10,20,65,.f.," Cadastro de Funcionorios ")
HelpVar("<ESC> Retorna <Enter> Help do Funcionorio <F9> Prox. Codigo <F10> Calculadora",80,23,00)
do while lastkey() <> K_ESC
   Slinha := savescreen(23,00,23,maxcol())
   EFunc := .F.
   Conf = space(01)
   rlock()
   inic_var()
   dbgobottom()
   FFunCod := 0
   FCivil := space(01)
   set key K_F9 to Prox_Cod()
   @ 05,14 say "Codigo :" Get FFunCod pict "999" ;
      valid(pesquisa(06,18,15,67,"_FUNCIONA",FFunCod,"FunCod","FuncNome"," Funcionarios "))
   Read
   set key K_F9 to
   if FFunCod == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Func)
       exit
   endif
   Achou_Funcionario := ENCONTROU(FFunCod)
   if Achou_Funcionario
      igual_var()
   endif
   testa("_CARGOS",FFuncCarg,,19,27,"CargNome")
   @ 07,16 say "Nome :"          get FFuncNome Pict "@!" ;
     valid(Ver_Cadastro(FFuncNome,FFunCod,"Funcionario ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
   @ 09,12 say "Endereco :"      get FFuncEnd Pict "@!"
   @ 11,14 say "Bairro :"        get FFcBairro Pict "@!"
   @ 11,44 say "Cep :"           get FFunCep Pict "@R 99999-999"
   @ 13,12 say "Telefone :"      get FFuncFone Pict "@R (99999) 9999-9999"
   @ 13,41 say "Est.Civil :"     get FFuncEc Pict "@!" when ;
           HelpVar("'C'- Casado(a) 'S'- Solteiro(a) 'D'- Divorciado(a) 'V'- Viuvo 'P'- seParado(a)",80,23,0);
           valid(FFuncEc $ "CSDVP")
   @ 15,11 say repl("?",54)
   @ 15,25 say " Informacoes Adicionais " color ["&cor_Titulo"]
   @ 17,12 say "Dt. Admi.:" get FFuncDt Pict "99/99/99"
   @ 17,32 say "N. Carteira Trabalho :" get FFuncNc
   @ 19,15 say "Cargo :" get FFuncCarg Pict "99" ;
     valid(pesquisa2(15,33,21,62,"_Cargos",FFuncCarg,"CargCod","CargNome"," Cargos ") ;
     .and. testa("_CARGOS",FFuncCarg,,19,27,"CargNome"))
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Func)
      exit
   endif
   Select _CARGOS
   Set order to 1
   dbgotop()
   if dbseek(FFuncCarg)
      Nome_Cargo := CargNome
   endif
   select _FUNCIONA
   if Upper(Substr(Nome_Cargo,1,1)) <> "B"
      @ 19,45 say "Salario :" get FFuncSal pict "999.99"
      Read
   else
      @ 19,45 say "Salario Comissionado"
      FFuncSal := 0
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Func)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! achou_Funcionario
            Dbappend()
         endif
         reply_var(.T.)
      endif
    elseif CONF=="E"
      codigo := FunCod
      Novo_Rec := recno()
      arq_atual := alias()
      Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
      Mensagem := savescreen(0,0,maxrow(),maxcol())
      @ 23,00 say space(80)
      @ 23,01 say "Mensagem : Aguarde, Pesquisando Codigo do Funcionorio em vendas..!!" color ["W+*"]
      select "_CARGOS"
      set order to 1
      dbseek(FFuncCarg)
      select "_MOVIMENT"
      if _CARGOS->CargTippg = "B"
         locate for MovFunc = Codigo
         if found()
            EFunc := .T.
         else
            EFunc := .F.
         endif
      else
         EFunc := .F.
      endif
      restscreen(0,0,maxrow(),maxcol(),Mensagem)
      close _MOVIMENT
      select &arq_atual
      dbgoto(Novo_Rec)
      if EFunc
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
       else
         do while .t.
            if n_reclock()
               if confirma("Excluir Funcionario ?") == 1
                  delete
                  OPEN FCANT ALIAS "_FCANT" INDEX COD_FCANT SHARED
                  set order to 1
                  dbappend()
                  field ->FunCod   := _FUNCIONA->FunCod
                  field ->FuncNome := _FUNCIONA->FuncNome
                  field ->Data_EXC   := date()
                  field ->Hora_EXC   := Time()
                  close _FCANT
                  select _FUNCIONA
                  delete
               endif
               exit
            endif
         enddo
      endif
   endif
   @ 05,11 clear to 19,64
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Func)
close _FUNCIONA
close _CARGOS
set key K_F5 to
set key K_F6 to
return nil

************************
Function Cad_Operacao()
************************
local GetList:={},EOper := .F.
local STela_Oper := savescreen(0,0,maxrow(),maxcol()),Conf
apaga(.T.)
OPEN OPERACOE ALIAS "_OPERACOE" INDEX CO4_OPER,NO4_OPER SHARED
SKDADO:={"_OPERACOE","OperCod"}
set order to 1
HelpVar("<ESC> Retorna <Enter> Help do Operacao <F9> Prox. Codigo <F10> Calculadora",80,23,00)
moldura(10,20,20,55,.f.," Cadastro de Operacao ")
do while lastkey() <> K_ESC
   EOper := .F.
   Conf = space(01)
   Slinha := savescreen(23,00,23,maxcol())
   rlock()
   inic_var()
   dbgobottom()
   FOperCod := 0
   set key K_F9 to Prox_Cod()
   @ 12,22 say "Codigo :" Get FOperCod pict "99";
      valid(pesquisa(13,18,19,47,"_OPERACOE",FOperCod,"OperCod","OperNome"," Operacao "))
   Read
   set key K_F9 to
   if FOperCod == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Oper)
      exit
   endif
   Achou_OPeracao := ENCONTROU(FOperCod)
   if Achou_Operacao
      igual_var()
   endif
   @ 14,22 say "Nome   :" Get FOperNome pict "@!" ;
     valid(Ver_Cadastro(FOperNome,FOperCod,"Operacao ja Cadastrada,<Pressione qualquer Tecla para continuar>"))
   @ 16,22 say "Mov.a Vista(S/N),(B)Bonific.:" Get FOperTipo pict "@!" ;
               valid (FOperTipo $ "SNB")
   @ 18,22 say "Gera Comissao (S/N):" Get FPaga_Com pict "@!" ;
               valid (FPaga_Com $ "SN")
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Oper)
      exit
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Oper)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! Achou_Operacao
            Dbappend()
         endif
         reply_var(.T.)
      endif
    elseif CONF=="E"
      codigo := OperCod
      Novo_Rec := recno()
      arq_atual := alias()
      Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      IndM2    := "MDT" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
      OPEN "&Nome_Arq" ALIAS "_MOVIMENT" INDEX "&IndM1","&IndM2" SHARED
      set order to 1
      dbgotop()
      do while !eof()
         if MovOper = Codigo
            EOper := .T.
            exit
         endif
         dbskip()
      enddo
      close _MOVIMENT
      select &arq_atual
      dbgoto(Novo_Rec)
      if EOper
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
       else
         do while .t.
            if n_reclock()
               if confirma("Excluir Operacao ?") == 1
                  delete
               endif
               exit
            endif
         enddo
      endif
   endif
   @ 11,21 clear to 19,54
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Oper)
close _OPERACOE
return nil

********************
Function Cad_For()
********************
local GetList:={}, EFor := .F.
local STela_For := savescreen(0,0,maxrow(),maxcol()),Conf
apaga(.T.)
OPEN FORNECED ALIAS "_FORNECED" INDEX CO5_FOR,NO5_FOR SHARED
set order to 1
SKDADO:={"_FORNECED","ForCod"}
HelpVar("<ESC> Retorna <Enter> Help do Fornecedor <F9> Prox. Codigo <F10> Calculadora",80,23,00)
moldura(03,10,21,75,.f.," Cadastro de Fornecedores ")
do while lastkey() <> K_ESC
   EFor := .F.
   Conf = space(01)
   Slinha := savescreen(23,00,23,maxcol())
   rlock()
   inic_var()
   dbgobottom()
   FForCod := 0
   set key K_F9 to Prox_Cod()
   @ 04,14 say "Codigo :" Get FForCod pict "999" ;
      valid(pesquisa(05,15,15,73,"_FORNECED",FForCod,"ForCod","ForNome"," Fornecedor "))
   Read
   set key K_F9 to
   if FForCod == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_For)
      exit
   endif
   Achou_Fornecedor := ENCONTROU(FForCod)
   if achou_Fornecedor
      igual_var()
   endif
   checaest(FForUf,12,26)
   @ 06,16 say "Nome :"          get FForNome Pict "@!" ;
     valid(Ver_Cadastro(FForNome,FForCod,"Fornecedor ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
   @ 08,12 say "Endereco :"      get FForEnd Pict "@!"
   @ 10,14 say "Bairro :"        get FFrBairro Pict "@!"
   @ 10,45 say "Cidade :"        get FForCid Pict "@!"
   @ 12,14 say "Estado :"        get FForUf Pict "@!" ;
      valid(checaest(FForUf,12,26))
   @ 12,48 say "Cep :"           get FForCep  Pict "@R 99999-999"
   @ 14,12 say "Telefone :"      get FForFone Pict "@R (99999) 9999-9999"
   @ 16,11 say repl("?",64)
   @ 16,23 say " Informacoes do Contato do Fornecedor " color ["&cor_Titulo"]
   @ 18,16 say "Nome :"     get FForCont  Pict "@!"
   @ 20,12 say "Telefone :" get FFrFnCont Pict "@R (99999) 9999-9999"
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_For)
      exit
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_For)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! achou_Fornecedor
            Dbappend()
         endif
         reply_var(.T.)
      endif
     elseif CONF=="E"
      codigo := ForCod
      Novo_Rec := recno()
      arq_atual := alias()
      OPEN COMPRAS ALIAS "_COMPRAS" INDEX CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC SHARED
      set order to 1
      dbgotop()
      do while !eof()
         if CpFor = Codigo
            EFor := .T.
            exit
         endif
         dbskip()
      enddo
      close _COMPRAS
      select &arq_atual
      dbgoto(Novo_Rec)
      if EFor
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
        else
         do while .t.
            if n_reclock()
               if confirma("Excluir Fornecedor ?") == 1
                  delete
               endif
               exit
            endif
         enddo
      endif
   endif
   @ 04,11 clear to 20,74
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_For)
close _FORNECED
return nil

********************
Function Cad_Cargo()
********************
local GetList:={}, Achou_Cargo:=.F.
local STela_Cargo:= savescreen(0,0,maxrow(),maxcol()),Conf
apaga(.T.)
OPEN CARGOS ALIAS "_CARGOS" INDEX CargCod,CargNome SHARED
set order to 1
SKDADO:={"_CARGOS","CargCod"}
HelpVar("<ESC> Retorna <Enter> Help do Cargos <F9> Prox. Codigo <F10> Calculadora",80,23,00)
moldura(10,20,20,60,.f.," Cadastro de Cargos ")
do while lastkey() <> K_ESC
   Conf = space(01)
   Slinha := savescreen(23,00,23,maxcol())
   rlock()
   inic_var()
   dbgobottom()
   FCargCod = 0
   set key K_F9 to Prox_Cod()
   @ 12,22 say "Codigo :" Get FCargCod pict "99" ;
      valid(pesquisa(13,18,19,50,"_CARGOS",FCargCod,"CargCod","CargNome"," Cargos "))
   Read
   set key K_F9 to
   if FCargCod == 0
      loop
   endif
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Cargo)
      exit
   endif
   Achou_Cargo := ENCONTROU(FCargCod)
   if Achou_Cargo
      igual_var()
   endif
   @ 14,22 say "Nome   :" Get FCargNome pict "@!" ;
     valid(Ver_Cadastro(FCargNome,FCargCod,"Cargo ja Cadastrado,<Pressione qualquer Tecla para continuar>"))
   @ 16,22 say "Salario ou Comissao (S/C):" Get FCargTipPg pict "@!" ;
               valid (FCargTipPg $ "SC")
   @ 18,22 say "Habilitar Venda no Caixa (S/N):" Get FHabilitaVC pict "@!" ;
               valid (FHabilitaVC$ "SN")
   Read
   Read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Cargo)
      exit
   endif
   @ 23,00 say Space(80)
   @ 23,00 say "Mensagem: Grava (S/N) Exclui (E)?" get CONF pict "@!" valid CONF $"SNE"
   read
   if lastkey()==K_ESC
      restscreen(0,0,maxrow(),maxcol(),STela_Cargo)
      exit
   endif
   if CONF=="S"
      if updated()
         if ! achou_Cargo
            Dbappend()
         endif
         reply_var(.T.)
      endif
    elseif CONF=="E"
      codigo := FCargCod
      Novo_Rec := recno()
      arq_atual := alias()
      OPEN FUNCIONA ALIAS "_FUNCIONA" INDEX CO3_FUNC, NO3_FUNC, CargoFunc SHARED
      set order to 3
      dbgotop()
      if DBSeek(Codigo)
         select &arq_atual
         dbgoto(Novo_Rec)
         Alerta(11,25,"Nao Posso Deletar Esse Registro")
       else
         select &arq_atual
         dbgoto(Novo_Rec)
         do while .t.
            if n_reclock()
               if confirma("Excluir Cargo ?") == 1
                  delete
               endif
               exit
            endif
         enddo
      endif
      close _FUNCIONA
      select _CARGOS
      set order to 1
   endif
   @ 11,21 clear to 19,59
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
restscreen(0,0,maxrow(),maxcol(),STela_Cargo)
close _CARGOS
return nil

***************************
Function Cad_Paramentros()
***************************
apaga(.T.)
Tela_Senha := Savescreen(00,00,maxrow(),maxcol())
moldura(05,20,11,65,.f.," Cadastro de Paramentros ")
use parament alias _parament new
Do while .T.
   Tipo_Rel = Par_PC_PV
   Slinha := savescreen(23,00,23,maxcol())
   Tipo_Relatorio = 0
   @ 06,22 say "** Relatario de Valorizacao do Estoque **" color ["&cor_Apresentacao"]
   @ 07,22 say "Digite 1 - Para Preco de Custo Final"
   @ 08,22 say "Digite 2 - Para Preco de Venda "
   @ 09,22 say "Digite 3 - Para Preco de Custo N.F."
   @ 10,22 Say "Preco de Custo/Venda:" Get Tipo_Relatorio pict "9" Valid ;
     (Tipo_Relatorio >0 .and. Tipo_Relatorio <=3)
   Read
   if lastkey()==K_ESC
      Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
      exit
   else
      if confirma("Confirma gravacao ?") == 1
         if Tipo_Relatorio == 1
            replace Par_PC_PV with "PC"
         elseif Tipo_Relatorio == 2
            replace Par_PC_PV with "PV"
         else
            replace Par_PC_PV with "PN"
         endif
      endif
   endif
   exit
   restscreen(23,00,23,maxcol(),Slinha)
enddo
Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
close _parament
return nil

************************
Function Cad_Comissao()
************************
apaga(.T.)
Tela_Senha := Savescreen(00,00,maxrow(),maxcol())
moldura(05,20,08,65,.f.," Cadastro de Paramentros ")
use parament alias _parament new
dbgotop()
Do while .T.
   Tipo_Rel = Com_Func
   Slinha := savescreen(23,00,23,maxcol())
   @ 06,22 say "** Paramentro de Comissao de Funcionario **" color ["&cor_Apresentacao"]
   @ 07,22 Say "Comissao de Funcionario :" Get Tipo_Rel pict "99.99" Valid ;
     (Tipo_Rel >0)
   Read
   if lastkey()==K_ESC
      Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
      exit
   else
      if confirma("Confirma gravacao ?") == 1
         replace Com_Func with Tipo_Rel
      endif
   endif
   exit
   restscreen(23,00,23,maxcol(),Slinha)
enddo
Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
close _parament
return nil

**************************
Function Cad_CustoFixo()
**************************
apaga(.T.)
Tela_Senha := Savescreen(00,00,maxrow(),maxcol())
moldura(05,20,08,65,.f.," Cadastro de Paramentros ")
use parament alias _parament new
dbgotop()
Do while .T.
   Tipo_Rel = Custo_Fixo
   Slinha := savescreen(23,00,23,maxcol())
   @ 06,22 say "** Cadastro de Custo_Fixo **" color ["&cor_Apresentacao"]
   @ 07,22 Say "% de Custo Fixo :" Get Tipo_Rel pict "99.99" Valid ;
     (Tipo_Rel >0)
   Read
   if lastkey()==K_ESC
      Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
      exit
   else
      if confirma("Confirma gravacao ?") == 1
         replace Custo_Fixo with Tipo_Rel
      endif
   endif
   exit
   restscreen(23,00,23,maxcol(),Slinha)
enddo
Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
close _parament
return nil

***********************
Function Cad_Senha()
***********************
apaga(.T.)
Tela_Senha := Savescreen(00,00,maxrow(),maxcol())
moldura(03,20,21,57,.f.," Cadastro de Senha ")
OPEN SENHA ALIAS "_SENHA" INDEX SUSE SHARED
Set order to 1
Dbgotop()
Do while .T.
   inic_var()
   Slinha := savescreen(23,00,23,maxcol())
   T1 := T2 := T3 := T4 := T5 := T6 := space(01)
   T7 := T8 := T9 := T10:= T11:= T12:= space(01)
   @ 04,22 Say "Usuario:" Get FUser pict "@!" Valid (!empty(FUser))
   @ 05,22 Say "Senha..: "
   @ 06,21 say repl("?",36)
   @ 07,22 say "Permissao de Acesso Digite S ou N"
   @ 08,21 say repl("?",36)
   @ 09,22 say chr(4) +"       Venda" color["&cor_Titulo"]
   @ 10,24 say "   Lancamento:"
   @ 11,24 say " Cancelamento:"
   @ 12,24 say "Monitoramento:"
   @ 13,22 say chr(4) +"    Cadastro"  color["&cor_Titulo"]
   @ 14,22 say chr(4) +"      Compra"    color["&cor_Titulo"]
   @ 15,24 say "   Lancamento:"
   @ 16,24 say " Cancelamento:"
   @ 17,22 say chr(4) +"  Relatarios" color["&cor_Titulo"]
   @ 18,22 say chr(4) +"   Pagamento"  color["&cor_Titulo"]
   @ 19,22 say chr(4) +" Recebimento"  color["&cor_Titulo"]
   @ 20,22 say chr(4) +"  Utilitario" color["&cor_Titulo"]
   Read
   if lastkey()=K_ESC
      exit
   else
      achou_User := ENCONTROU(FUSer)
      if achou_User
         Alerta(11,25,"Usuario Cadastrado...!")
         if confirma("Deseja Alterar Senha ?") == 1
            igual_var()
            T1 := substr(FRotinas,1,1)
            T2 := substr(FRotinas,2,1)
            T3 := substr(FRotinas,3,1)
            T4 := substr(FRotinas,4,1)
            T5 := substr(FRotinas,5,1)
            T6 := substr(FRotinas,6,1)
            T7 := substr(FRotinas,7,1)
            T8 := substr(FRotinas,8,1)
            T9 := substr(FRotinas,9,1)
            T10:= substr(FRotinas,10,1)
            T11:= substr(FRotinas,11,1)
            T12:= substr(FRotinas,12,1)
            FSenha := space(10)
         else
            loop
         endif
      endif
   endif
   @ 05,31 Get FSenha PASSWORD Valid (!empty(FSenha))
   Read
   @ 09,39 Get T1  Pict "@!" valid(!empty(T1)  .and. T1 $ "SN")
   @ 10,39 Get T2  Pict "@!" valid(!empty(T2)  .and. T2 $ "SN")
   @ 11,39 Get T3  Pict "@!" valid(!empty(T3)  .and. T3 $ "SN")
   @ 12,39 Get T4  Pict "@!" valid(!empty(T4)  .and. T4 $ "SN")
   @ 13,39 Get T5  Pict "@!" valid(!empty(T5)  .and. T5 $ "SN")
   @ 14,39 Get T6  Pict "@!" valid(!empty(T6)  .and. T6 $ "SN")
   @ 15,39 Get T7  Pict "@!" valid(!empty(T7)  .and. T7  $ "SN")
   @ 16,39 Get T8  Pict "@!" valid(!empty(T8)  .and. T8  $ "SN")
   @ 17,39 Get T9  Pict "@!" valid(!empty(T9)  .and. T9  $ "SN")
   @ 18,39 Get T10 Pict "@!" valid(!empty(T10) .and. T10 $ "SN")
   @ 19,39 Get T11 Pict "@!" valid(!empty(T11) .and. T11 $ "SN")
   @ 20,39 Get T12 Pict "@!" valid(!empty(T12) .and. T12 $ "SN")
   Read
   TT := T1 + T2 + T3 + T4 + T5 + T6 + T7 + T8 + T9 + T10 + T11 + T12
   if lastkey()==K_ESC
      Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
      exit
   else
      if confirma("Confirma gravacao ?") == 1
         if ! achou_User
            Dbappend()
         endif
         if alltrim(FUser) = NUsuario
            NRotina := TT
         endif
         field->User      := FUser
         NSenha := Chr(Asc(Substr(FSenha,1,1))*2)
         For I := 2 to Len(FSenha)
            NSenha := NSenha + Chr(Asc(Substr(FSenha,I,1))*2)
         Next
         field->Senha   := NSenha
         field->Rotinas := TT
      endif
   endif
   @ 07,21 clear to 20,54
   unlock
   restscreen(23,00,23,maxcol(),Slinha)
enddo
Restscreen(00,00,maxrow(),maxcol(),Tela_Senha)
close _SENHA
return nil

proc GetPassword( oGet )
LOCAL nKey,              ;
      nChar,             ;
      cKey

  // read the GET if the WHEN condition is satisfied
  IF ( GetPreValidate(oGet) )
    // activate the GET for reading
    oGet:SetFocus()

    oGet:cargo := ""
    DO WHILE ( oGet:exitState == GE_NOEXIT )
      // check for initial typeout (no editable positions)
      IF ( oGet:typeOut )
        oGet:exitState := GE_ENTER
      ENDIF

      // apply keystrokes until exit
      DO WHILE ( oGet:exitState == GE_NOEXIT )
        nKey := InKey(0)
        IF nKey >= 32 .AND. nKey <= 255
          oGet:cargo += Chr(nKey)
          GetApplyKey(oGet, Asc("*"))
       	ELSEIF nKey == K_BS
          oGet:cargo := Substr(oGet:cargo, 1, Len(oGet:cargo) - 1)
          GetapplyKey(oGet, nKey)
        ELSEIF nKey == K_ENTER
          GetApplyKey(oGet, nKey)
        ENDIF
      ENDDO

      // disallow exit if the VALID condition is not satisfied
      IF ( !GetPostValidate(oGet) )
        oGet:exitState := GE_NOEXIT
      ENDIF
    ENDDO
    // de-activate the GET
    oGet:KillFocus()
  ENDIF
  IF oGet:exitState != GE_ESCAPE
    oGet:varPut(oGet:cargo)
  ENDIF
RETURN
