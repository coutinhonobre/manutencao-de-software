# include "BOX.CH"
# include "INKEY.CH"
# include "SETCURS.CH"
# include "PAN.CH"
# define  HEADSEP    "Õ—Õ"
# define  COLSEP     " ≥ "
# define  FOOTSEP    "ÕœÕ"

*************************
function TRotina(Pos)
*************************
if substr(NRotina,Pos,1) = "N"
   Alerta(11,25,"Caro Usuario , Vocà NÑo Tem Acesso..!")
   return(.F.)
endif
return(.T.)

*************************
function Apaga(Status)
*************************
if Status
   set cursor on
   set intens on
else
   set cursor off
   set intens off
endif

*******************************
Function Testa_EData(Mensagem)
*******************************
if Month(Nova_Data) <> Month(date())
   Tela_Mensagem := Savescreen(00,00,maxrow(),maxcol())
   Cor_Antiga := SetColor()
   SetColor("W/gr+")
   @ 17,15 clear to 20,77
   @ 17,15 to 20,77
   sombra( 17, 15, 20, 77)
   @ 18,17 say Mensagem
   @ 19,17 say "Pressione Qualquer Tecla Para Continuar..!"
   inkey(0)
   SetColor("&Cor_Antiga")
   Restscreen(00,00,maxrow(),maxcol(),Tela_Mensagem)
   return(.T.)
endif
return(.F.)

**********************
function SomaQtd()
**********************
Local Soma := 0 , I
for I := 1 to Len(VQTD)
  Soma+=VQTD[I]
next
@ 20,02 say chr(228) + "Qtde:" + transf(Soma,"9,999.99") color ["&cor_Titulo"]
return Soma

****************************************
Function Testa_Troco(PAGO,Total_Venda)
****************************************
if PAGO < Total_Venda
   Alerta(09,25,"Valor Pago Menor Que o Total da Venda")
   Return(.F.)
else
   Return(.T.)
endif

***************************************************
function SomaTotal(Mostra_Liquido,Mostra_Desconto)
**************************************************
Local Soma := 0 , Liquido:=Desconto:=0, I
for I := 1 to Len(VSUBTOTAL)
  Soma+=VSUBTOTAL[I]
  if Mostra_Liquido
     Liquido+=VLIQUIDO[I]
  endif
next
@ 20,02 say chr(228) + "Bruto: " + transf(Soma,"999,999.99") color ["&cor_Titulo"]
if Mostra_Liquido
   @ 20,21 say chr(228) +"L°quido: " + transf(Liquido,"999,999.99") color ["&cor_Titulo"]
endif
if Mostra_Desconto
   @ 20,42 say chr(228) +"Desc-"+chr(16)+"%"  + transf((1-(Liquido/Soma))*100,"99.99") color ["&cor_Titulo"]
   @ 20,58 say chr(228) +"Desc-"+chr(16)+"R$" + transf((Soma-Liquido),"999,999.99") color ["&cor_Titulo"]
endif
return Soma

****************************
function Testa_Hora(THora)
****************************
T_Mensagem := savescreen(0,0,maxrow(),maxcol())
if val(left(THora,2)) > 24 .or. val(substr(THora,4,2)) > 60 ;
   .or. val(substr(THora,7,2)) > 60
   Alerta(05,15,"-            Hora Inv†lida..! -")
   restscreen(0,0,maxrow(),maxcol(),T_Mensagem)
   return .F.
endif
return .T.

*****************************
function conv_mes(Nova_Data)
*****************************
local Num_Mes := Month(Nova_Data)
Mat := {'Janeiro','Fevereiro','Marco','Abril','Maio','Junho','Julho',;
         'Agosto','Setembro','Outubro','Novembro','Dezembro'}
return Mat[Num_Mes]

*********************************
FUNCTION Conf_CFG(cNome,cCod)
********************************
LOCAL I, cVideo
PRIVATE cArq
aFundo := { " CONEFER Ferragens e Conex‰es"           ,;
            "*   *   *  *  "                          ,;
            "∞∞∞∞∞±±±±±≤≤≤≤≤±±±±±" ,;
            "∞∞∞∞∞±±±±±∞∞∞∞∞≤≤≤≤≤" ,;
            "≤≤≤≤≤∞∞∞∞∞≤≤≤≤≤±±±±±" ,;
            "≤≤≤≤≤     ∞∞∞∞∞±±±±±" ,;
            "∞"                                       ,;
            "±"                                       ,;
            "≤"                                       ,;
            "¿ø¿ø"                                    ,;
            " ÀÀ "                                    ,;
            "¡¬¬¡"                                    ,;
            "√¥¥√"                                    ,;
            "πÃÃπ"                                    }
if cCod == nil
   cNome := UPPER(cNome)
   cArq := GETENV("ESTACAO")
   cArq := IF(EMPTY(cArq),"VIDEO.CFG",SUBSTR(cArq,1,8)+".CFG")
   IF FILE("&cArq.")
      cVideo := MEMOREAD("&cArq.")
   ELSE
      cVideo := "5"
      MEMOWRIT("&cArq.",cVideo)
  ENDIF
else
  cVideo := alltrim(str(cCod))
  MEMOWRIT("&cArq.",cVideo)
endif
IF cNome == "FUNDO"
   I := Val(substr(alltrim(cVideo),1,2))
   For Ind = 1 to len(aFundo)
       if Ind == I
          return(Ind)
       endif
   Next
endif
return nil

*******************************
FUNCTION HelpVar(NTexto,Tam,L,C)
*******************************
  @ L,C say Space(Tam)
  @ L,C say NTexto
Return (.T.)

***********************
function Reorganizar()
***********************
STela_Reorgan := savescreen(0,0,maxrow(),maxcol())
moldura(5,25,11,74,.f.," ReorganizaáÑo de Arquivos ")
@ 7,27 say "P/ reorganizar arquivo e necess†rio que somen-"
@ 8,27 say "te um computador na Rede esteja Funcionando.!"
if Alert("Deseja Iniciar Processo de Reorganizaáao ?",{"Sim","NÑo"}) == 1
   close all
   use produtos alias _produtos
   HelpVar("Reorganizado arquivo de Produto..!",47,9,27)
   pack
   close
   use GRUPOS alias _GRUPOS
   HelpVar("Reorganizado arquivo de Grupos..!",47,9,27)
   pack
   close
   use FUNCIONA alias _FUNCIONA
   HelpVar("Reorganizado arquivo de Funcion†rios..!",47,9,27)
   pack
   close
   use OPERACOE  alias _OPERACOE
   HelpVar("Reorganizado arquivo de Operaáoes..!",47,9,27)
   pack
   close
   use FORNECED alias _FORNECED
   HelpVar("Reorganizado arquivo de Fornecedores..!",47,9,27)
   pack
   close
   use MOVIMENT alias _MOVIMENT
   HelpVar("Reorganizado arquivo de Movimentos..!",47,9,27)
   pack
   close
   use ITENSMOV alias _ITENSMOV
   HelpVar("Reorganizado arquivo de Itens de Movimento..!",47,9,27)
   pack
   close
   use  COMPRAS alias _COMPRAS
   HelpVar("Reorganizado arquivo de Compras..!",47,9,27)
   pack
   close
   use ITENSCOMP alias _ITENSCOMP
   HelpVar("Reorganizado arquivo de Itens de Compras..!",47,9,27)
   pack
   close
   use PAGAMENT alias _PAGAMENT
   HelpVar("Reorganizado arquivo de Pagamentos..!",47,9,27)
   pack
   close
   HelpVar("",47,9,27)
   restscreen(0,0,maxrow(),maxcol(),STela_Reorgan)
   Alerta(05,15,"Processo de Reorganizaáao Finalizado..!")
   INDEXA(.T.)
else
   restscreen(0,0,maxrow(),maxcol(),STela_Reorgan)
endif
return nil

*********************************
function Help_Mensagem(Mensagem)
*********************************
 beep(2)
 @ 23,00 say Space(80)
 @ 23,00 say padc(Mensagem,80) color ["&cor_Fundo"]
return .t.
                               
*********************************
Function msgcenter(L,Texto,apaga)
*********************************
set cursor off
cs := (80-len(Texto))/2
@ l,cs clear to l,cs+len(Texto)
@ l,cs say alltrim(Texto)
inkey(0.3)
if apaga
   @ l,cs clear to l,cs+len(Texto)
endif
return nil

**********************
Function Telpadrao()
**********************
 set confirm on
 set date to british
 set delete on
 set scoreboard off
 set message to 23 center
 set wrap on
 set epoch to 1990
 cls
 setcolor("&Cor_Fundo")
 setcursor(0)
 @ 00,00 say space(80)
 @ 01,00 say space(80)
 @ 02,00 say space(80)
 @ 00,01 say " TeraByte Inform†tica " color["&cor_Titulo"]
 @ 01,01 say "RogÇrio Rosa≥9691-0305" color["&cor_Fundo"]
 @ 02,01 say "Sirlon Diniz≥8118-9560" color["&cor_Fundo"]
 @ 00,70 say "Data:"
 @ 01,69 say dtoc(Nova_Data)
 @ 02,68 say "VersÑo 4.3."
 @ 03,00 say space(80)
 @ 03,00 say replicate("ƒ",80)
 @ 23,00 say space(80)
 @ 23,01 say "Mensagem :"
 @ 24,00 say space(80)
 setcursor(1)
return nil

************************
function Help_Produto()
************************
local JPesquisa := savescreen(0,0,maxrow(),maxcol())
local arq_atual := alias() , Fechar_Arquiv := .F.
if select("_PRODUTOS") = 0
   OPEN PRODUTOS ALIAS "_PRODUTOS" INDEX CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP SHARED
   Fechar_Arquiv := .T.
endif
set order to 2
dbgotop()
declare FCAMPO[3],FNOME[3],FPICT[3]
FCAMPO[1]="PrCod"
FCAMPO[2]="PrNome"
FCAMPO[3]="PrPVenda"
FNOME[1]="Codigo"
FNOME[2]="Produto"
FNOME[3]="Preáo"
FPICT[1]=" 9999"
FPICT[2]="!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
FPICT[3]="999,999.99"
cor_antiga := setcolor()
setcolor("W+/R")
moldura(6,5,20,70,.f.," Produtos ")
dbedit(7,6,19,69,FCAMPO,"ProdutoPESQ",FPICT,FNOME,"ƒ")
setcolor("&cor_antiga")
if Fechar_Arquiv
   close _PRODUTOS
endif
select &arq_atual
set order to 1
restscreen(0,0,maxrow(),maxcol(),JPesquisa)
return .T.

*****************************************************************************************
function pesquisa(Lin_Ini,col_Ini,Lin_Fin,Col_Fin,arqbusca,chave,camp1,camp2,TITULO,Nome)
*****************************************************************************************
local JPesquisa := savescreen(0,0,maxrow(),maxcol())
public campo1 := camp1
declare NCAMP[3]
NCAMP[1] := CAMP1
NCAMP[2] := CAMP2
if lastkey() == K_ENTER
   arq_atual := alias()
   select &arqbusca
   set order to 2
   if dbseek(chave)
      restscreen(0,0,maxrow(),maxcol(),JPesquisa)
      set order to 1
      select &arq_atual
      return (.T.)
   else
      if chave <> 0
         set order to 1
         return (.T.)
      endif
      dbgotop()
      cor_antiga := setcolor()
      setcolor("W+/R")
      moldura(Lin_Ini,Col_Ini,Lin_Fin,Col_Fin,.f.,TITULO)
      dbedit(Lin_Ini+1,Col_Ini+1,Lin_Fin-1,Col_Fin-1,NCAMP,"TESTAPESQ")
      setcolor("&cor_antiga")
      restscreen(0,0,maxrow(),maxcol(),JPesquisa)
      set order to 1
      return (.T.)
   endif
else

   HelpVar("Pressione ÆEnterØ Para Acessar Grupos",80,23,00)
   inkey(2)
   restscreen(0,0,maxrow(),maxcol(),JPesquisa)
   set order to 1
   return (.F.)
endif

*****************************************************************
function HELPCENTER(VET1,VET2,VET3,AREA,LINE23,L,A,TITULO,ordem)
*****************************************************************
local getlist:={}
local FHELP:=space(30),TELA01:=savescreen(0,0,24,79), ARQATUAL:=ALIAS(), RE:=RECNO()
dbselectarea (AREA)
set order to iif(ordem=nil,2,ordem)
@ 23,00 say space(80)
@ 23,00 say LINE23 get FHELP pict "@!"
read
dbseek(FHELP,.T.)
HelpVar("Mensagem: <ESC> Abandona.",80,23,00)
IF MOD(L,2)=1
  L++
ENDIF
IF MOD(A,2)=0
  A--
ENDIF
CS:=INT((80-L)/2)
LS:=INT((25-A)/2)
moldura(LS-1,CS-1,LS+A+1,CS+L,.F.,TITULO)
dbedit(LS,CS,LS+A,CS+L-1,VET1,"TESTAPESQ2",VET2,VET3,"ƒ")
restscreen(0,0,24,79,TELA01)
dbselectarea (ARQATUAL)
set order to 1
dbgoto(RE)
return nil

*********************************
function TESTAPESQ(mode,counter)
*********************************
local Salva_Linha := savescreen(23,0,23,maxcol())
setcolor("&cor_antiga")
HelpVar("<ESC> Retorna <ENTER> Seleciona C¢digo <F4> Nome <F5> C¢digo",80,23,00)
set cursor on
do case
 case mode == 0
  return(1)
 case mode == 1
  HelpVar("Inicio de Arquivo",80,23,00)
  beep(9)
  return(1)
 case mode == 2
  HelpVar("Fim de Arquivo",80,23,00)
  beep(9)
  return(1)
 case mode == 3
  HelpVar("Arquivo Sem Conteudo",80,23,00)
  beep(9)
  return(0)
 case LASTKEY() == K_ENTER
     variavel := readvar()
     &variavel:= &campo1
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     RETURN(0)
 case lastkey() == K_ESC
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     return(0)
 case lastkey() == K_INS
      select &arq_atual
      RETURN(0)
 case lastkey() == K_F4
      PesquisaNome()
 case lastkey() == K_F5
      PesquisaCodigo()
 otherwise
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     return(0)
 endcase

*****************************************************************************************
function pesquisa2(Lin_Ini,col_Ini,Lin_Fin,Col_Fin,arqbusca,chave,camp1,camp2,TITULO,Nome)
*****************************************************************************************
local JPesquisa2 := savescreen(0,0,maxrow(),maxcol())
public campo2 := camp1
declare NCAMP[3]
NCAMP[1] := CAMP1
NCAMP[2] := CAMP2
arq_atual := alias()
select &arqbusca
set order to 1
if dbseek(chave)
   restscreen(0,0,maxrow(),maxcol(),JPesquisa2)
   select &arq_atual
   return (.T.)
else
   dbgotop()
   moldura(Lin_Ini,Col_Ini,Lin_Fin,Col_Fin,.f.,TITULO)
   dbedit(Lin_Ini+1,Col_Ini+1,Lin_Fin-1,Col_Fin-1,NCAMP,"TESTAPESQ2")
   restscreen(0,0,maxrow(),maxcol(),JPesquisa2)
   return (.T.)
endif

*********************************
function TESTAPESQ2(mode,counter)
*********************************
local Salva_Linha := savescreen(23,0,23,maxcol()), ARQ_ATUAL:=alias()
HelpVar("<ESC> Retorna <ENTER> Seleciona C¢digo",80,23,00)
set cursor on
do case
 case mode == 0
  return(1)
 case mode == 1
  HelpVar("Inicio de Arquivo",80,23,00)
  beep(9)
  return(1)
 case mode == 2
  HelpVar("Fim de Arquivo",80,23,00)
  beep(9)
  return(1)
 case mode == 3
  HelpVar("Arquivo Sem Conteudo",80,23,00)
  beep(9)
  return(0)
 case LASTKEY() == K_ENTER
     variavel := readvar()
     &VARIAVEL:=FIELDGET(1)
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     RETURN(0)
 case lastkey() == K_ESC
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     return(0)
 case lastkey() == K_INS
      JInsert := savescreen(0,0,maxrow(),maxcol())
      select &arq_atual
      return(0)
 otherwise
     restscreen(23,0,23,maxcol(),Salva_Linha)
     select &arq_atual
     return(0)
 endcase

************************************************
function Ver_Cadastro(Nome,Codigo,Mensagem)
************************************************
local Salva_Linha := savescreen(23,00,23,maxcol())
local Vregistro := recno()
@ 23,00 say space(80)
Set order to 2
if Empty(Nome)
   Beep(1)
   HelpVar("Campo Vazio..! <Pressione qualquer Tecla para continuar>",80,23,10)
   inkey(0)
   Restscreen(23,00,23,maxcol(),Salva_Linha)
   Set order to 1
   go Vregistro
   return (.F.)
else
   if dbseek(Nome)
      if Eval(FieldBlock(FieldName(1))) == Codigo
         Restscreen(23,00,23,maxcol(),Salva_Linha)
         Set order to 1
         go Vregistro
         return (.T.)
      else
         Beep(1)
         @ 23,10 say Mensagem
         inkey(0)
         Restscreen(23,00,23,maxcol(),Salva_Linha)
         go Vregistro
         Set order to 1
         return (.F.)
      endif
   else
      Restscreen(23,00,23,maxcol(),Salva_Linha)
      go Vregistro
      Set order to 1
      return (.T.)
   endif
endif

********************
function For_Help()
********************
HELPCENTER({"ForCod","ForNome"},{" 999","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Nome Fornecedor"},"_FORNECED","Fornecedor :",30,10," Fornecedor ")
return nil

************************
function Operac_Help()
************************
HELPCENTER({"OperCod","OperNome"},{" 999","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Nome OperaáÑo"},"_OPERACOE","OperaáÑo :",30,10," OperaáÑo ")
return nil

*******************
function Carg_Help()
*******************
HELPCENTER({"CargCod","CargNome"},{" 999","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Nome Cargo"},"_CARGOS","Cargos :",30,10," Cargos ")
return nil

*******************
function Func_Help()
*******************
HELPCENTER({"FunCod","FuncNome"},{" 999","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Nome Funcion†rio"},"_FUNCIONA","Funcion†rio :",30,10," Funcion†rio")
return nil

*******************
function Cli_Help()
*******************
HELPCENTER({"ClCod","ClNome"},{" 999","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Nome Cliente"},"_CLIENTES","Cliente :",30,10," Clientes ")
return nil

*******************
function Gru_Help()
*******************
HELPCENTER({"GpCod","GpNome"},{" 99","!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Grupo"},"_GRUPOS","Grupo :",30,10," Grupos ")
return nil

********************
function Pro_Help()
********************
HELPCENTER({"PrCod","PrNome"},{" 9999","!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"},;
        {"C¢digo","Produto"},"_PRODUTOS","Produto :",45,10," Produtos ",2)
return nil

***************************************
function TESTA_PRO(COD,PRE_UNI,CGrupo)
***************************************
if COD == 0
   return .T.
endif
select _PRODUTOS
set order to 1
if dbseek(COD)
  PRE_UNI := PrPVenda
  @ ROW()+1,52 say subst(PrNome,1,25)
  @ ROW()+1,51 say transf(PRE_UNI,"999,999.99")
  Cod_Grupo := PrGrupo
else
  Alerta(05,15,"Produto NÑo Cadastrado No Sistema..")
  return .F.
endif
return .T.

***************************
FUNCTION TESTA_PRO_2(COD,L)
***************************
arq_atual := alias()
select _PRODUTOS
set order to 1
if dbseek(COD)
  @ L,08 say subst(PrNome,1,20)
  select &arq_atual
  return .T.
endif

***************************************************
FUNCTION TESTA(ARQ_BUSCA,CHAVE1,MENSAGEM,L,C,CAMPO)
***************************************************
LOCAL ARQ_ATUAL:= select()
select &ARQ_BUSCA
set order to 1
if CHAVE1=0
   select &ARQ_ATUAL
   return .T.
endif
if dbseek(CHAVE1)
   @ L,C say alltrim(substr(&CAMPO,1,35))
   select &ARQ_ATUAL
   return .T.
else
   alert(MENSAGEM)
   select &ARQ_ATUAL
   return .F.
endif
return nil

*******************************************************
FUNCTION TESTA_QUANTIDADE(COD,QUANTIDADE,INDICE,TESTA)
*******************************************************
local arq_atual := alias(), QTDE_TOTAL:=0, I, ABRIU:=.F.
if Testa
   for I=1 to len(VQTD)
       if VCOD[I]==COD
          QTDE_TOTAL+=VQTD[I]
       endif
   endfor
  if INDICE > 0
     QTDE_TOTAL:=QUANTIDADE+QTDE_TOTAL-VQTD[INDICE]
  else
    QUANTIDADE:=QUANTIDADE+QTDE_TOTAL
  endif
endif
select _PRODUTOS
set order to 1
if dbseek(COD)
   Tipo_Quantidade := PrUnidMed
   Parte_Decimal := abs(Int(QUANTIDADE) - QUANTIDADE)
   if select("_UNMEDIDA")=0
      OPEN UNMEDIDA  ALIAS "_UNMEDIDA" INDEX COD_UNMED,NOME_UNMED SHARED
      ABRIU:=.T.
   endif
   select _UNMEDIDA
   set order to 1
   dbseek(Tipo_Quantidade)
   select _PRODUTOS
   if _UNMEDIDA->INTEIRO=="S" .and. Parte_Decimal > 0
      Alerta(11,25,"O Campo Quantidade NÑo Aceita Casas Decimais...!")
      select &arq_atual
      if ABRIU
         close _UNMEDIDA
      endif
      Return .F.
   endif
   if ABRIU
      close _UNMEDIDA
   endif
   if Testa
      if PrEst = "S"
         if (PrEAtual-QUANTIDADE)<=PrEMin
            Alerta(09,25,"Utilizando Estoque M°nimo")
         endif                       
         if QUANTIDADE > PrEAtual
            if PrEAtual > 0
               Mensagem := "Quantidade Em Estoque =" + str(PrEAtual)
             else
               Mensagem := "Estoque Esgotado..."
            endif
            Alerta(09,25,Mensagem)
            select &arq_atual
            // Return .F. para nao permitir estoque negativo
            return .T.
         endif                          
      endif
   endif
else
  Alerta(09,25," Produto Nao Cadastrado..!")
  select &arq_atual
  Return .F.
endif
return .T.

************************************************
function NCab(DIni,DFim,Nome_Rel,V_Nome,V_Col)
************************************************
Ind := len(V_Col)
@ 0,01 say chr(14) + FIRMA
@ 1,20 say alltrim(Nome_Rel)
@ 2,00 say "P†g.: "+str(P,3)
@ 2,54 say "Data Inicial: "+dtoc(DIni)
@ 3,00 say "Hora: "+time()
@ 3,54 say "Data Final  : "+dtoc(DFim)
@ 4,00 say replicate ("=",76)
For Ind := 1 To Len(V_Col)
  @ 5,V_Col[Ind] say alltrim(V_Nome[Ind])
next
@ 6,00 say replicate ("=",76)
return nil

*****************************************
function Novo_Cab(Nome_Rel,V_Nome,V_Col)
****************************************
Ind := len(V_Col)
@ 0,01 say chr(14) + FIRMA
@ 1,20 say alltrim(Nome_Rel)
@ 2,00 say "P†g.: "+str(P,3)
@ 2,20 say "Data: "+dtoc(date())
@ 2,60 say "Hora: "+time()
@ 3,00 say replicate ("=",76)
For Ind := 1 To Len(V_Col)
  @ 4,V_Col[Ind] say alltrim(V_Nome[Ind])
next
@ 5,00 say replicate ("=",76)
return nil

**************************
function PesquisaCodigo()
**************************
local CCod := 0, Area:=alias(), ordem:=IndexOrd()
local Salva_Linha := savescreen(23,00,23,maxcol())
setcursor(1)
set order to 1
@ 23,00 say space(80)
@ 23,01 say "Codigo :" get CCod pict "9999"
read
if Lastkey() <> K_ESC .or. !empty(CCod)
   npos := recno()
   dbgotop()
   if !dbseek(CCod)
      Alerta(05,15,"C¢digo NÑo Encontrado !")
      Dbgotop(npos)
    endif
endif
setcursor(0)
restscreen(23,00,23,maxcol(),Salva_Linha)
select (Area)
set order to Ordem
return nil

**************************
function PesquisaNome()
**************************
local Nome := space(30), Area:=alias(), ordem:=IndexOrd()
local Salva_Linha := savescreen(23,00,23,maxcol())
setcursor(1)
@ 23,00 say space(80)
@ 23,01 say "Nome: " get Nome pict "@!"
read
if Lastkey() <> K_ESC .or. !empty(Nome)
   npos := recno()
   set order to 2
   dbgotop()
   if ! Dbseek(Nome,.T.)
      Beep(1)
   endif
endif
setcursor(0)
set order to 1
restscreen(23,00,23,maxcol(),Salva_Linha)
select (Area)
set order to Ordem
return nil

***********************
function HelpBrowse()
***********************
local Tela_Browse := savescreen(0,0,maxrow(),maxcol())
HelpVar("Pressione Qualquer Tecla Para Sair do HELP",80,23,00)
cor := setcolor()
setcolor("W/R+")
setcursor(SC_NONE)
moldura(09,10,20,74,.f.," Ajuda Browse ")
@ 10,12 say "      ESC - Sai da Ajuda"
@ 11,12 say "      F10 - Calculadora"
@ 12,20 say chr(24) + " - Sobe Uma CÇlula"
@ 13,20 say chr(25) + " - Desce Uma CÇlula"
@ 14,20 say chr(26) + " - Percorre da Esquerda Para a Direita de Uma CÇlula"
@ 15,20 say chr(27) + " - Percorre da Direita Para a Esquerda de Uma CÇlula"
@ 16,12 say "Page Down - Desce Uma P†gina "
@ 17,12 say "  Page Up - Sobe Uma P†gina "
@ 18,12 say "     Home - Inicio da Tela"
@ 19,12 say "      End - Final da Tela"
inkey(0)
setcolor("&cor")
setcursor(SC_NORMAL)
restscreen(0,0,maxrow(),maxcol(),Tela_Browse)

*****************
function MANUAL()
*****************
LOCAL VAR:=memoread("MANUAL.TXT")
TelaManual := savescreen(0,0,maxrow(),maxcol())
exibtela()
@ 23,01 Say "Mensagem: Pressione ESC para voltar ao menu principal" color ["&cor_Fundo"]
memoedit(VAR,3,1,20,78,.F.)
restscreen(0,0,maxrow(),maxcol(),TelaManual)
return NIL

*******************
function InfSis()
*******************
Tela_Sobre:=savescreen(0,0,maxrow(),maxcol())
HelpVar("Pressione Qualquer Tecla Para Sair do Sobre",80,23,00)
cor := setcolor()
setcolor("W/R+")
setcursor(SC_NONE)
moldura(04,30,17,67,.f.," Sobre ")
@ 05,32 say "Sistema Financeiro Comercial"
@ 06,32 say "       Versao 4.3.          "
@ 08,32 say "  Empresa : TeraByte Inform†tica"
@ 09,32 say "Telefones : (062)9601-0305"
@ 10,32 say "            (062)8118-9560"
@ 12,32 say "Programador / Analista de Sistema"
@ 13,32 say "             RogÇrio Rosa Brandao"
@ 14,32 say "             Sirlon Diniz"
@ 16,32 say "Free BUG - Ano 2000      " color ["RG+/R"]
inkey(0)
setcolor("&cor")
setcursor(SC_NORMAL)
restscreen(0,0,maxrow(),maxcol(),Tela_Sobre)
return NIL

*******************
function Prox_Cod()
*******************
local ATUAL:=0,PROX:=0,ACHOU:=.F.,RE:=recno(), ARQATUAL:=ALIAS(), PCOD, TELA:=SAVESCREEN(00,00,maxrow(),maxcol())
select (SKDADO[1])   // VETOR DEVE SER DECLARADO COMO PUBLICO NO PROGRAMA
                     // DEVENDO CONTER COMO PRIMEIRO PARAMETRO O ALIAS DA AREA
                     // DESEJADA E COMO SEGUNDO PARAMETRO O NOME DO CAMPO A SER
                     // PESQUISADO
                     // EX. SKDADO:={"_OPERA","COD_OPE"}
@ 23,00 say space(80)
@ 23,01 say "Aguarde Pesquisando Pr¢ximo C¢digo dispon°vel ..." color ["W+*"]
set order to 1
dbgotop()
do while !eof()
   PROX:=FIELDGET(FIELDPOS(SKDADO[2]))
   if (PROX-ATUAL)>1
      PCOD:=ATUAL+1
      ACHOU:=.T.
      exit
   endif
   ATUAL:=PROX
   dbskip()
enddo
if !ACHOU
   PCOD:=LASTREC()+1
endif
VARIAVEL=READVAR()
&VARIAVEL:=PCOD
restscreen(00,00,maxrow(),maxcol(),TELA)
select(ARQATUAL)
dbgoto(RE)
return PCOD

************************
function Produto_Help()
************************
local getlist:={}
local J_ANTERIOR:=SAVESCREEN(00,00,24,79)
declare FCAMPO[3],FNOME[3],FPICT[3]
FCAMPO[1]="PrCod"
FCAMPO[2]="PrNome"
FCAMPO[3]="PrPVenda"
FNOME[1]="Codigo"
FNOME[2]="Produto"
FNOME[3]="Preáo"
FPICT[1]=" 9999"
FPICT[2]="!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
FPICT[3]="999,999.99"
FPrNome := space(40)
select _Produtos
set order to 2
dbgotop()
@ 23,00 say space(80)
@ 23,0 say "Produto: " get FPrNome pict "@!"
read
dbseek(FPrNome,.T.)
cor_antiga := setcolor()
setcolor("W+/R")
MOLDURA(5,15,22,77,.f.,"¥ Selecione registro e tecle <enter> √")
dbedit(6,16,21,76,FCAMPO,"ProdutoPESQ",FPICT,FNOME,"ƒ")
setcolor("&cor_antiga")
set order to 1
restscreen(00,00,24,79,J_ANTERIOR)
return nil

*************************************
FUNCTION ProdutoPESQ(mode, counter)
*************************************
setcolor("&cor_antiga")
HelpVar("<ESC> Retorna <Enter> Seleciona <F4> Pesquisa Nome <F5> Pesquisa C¢digo",80,23,00)
SET cursor ON
DO CASE
CASE mode=0
   RETURN(1)
CASE mode =1
   HelpVar("Inicio de Arquivo",20,23,55)
   INKEY(.5)
   RETURN (1)
CASE mode =2
   HelpVar("Fim de Arquivo",20,23,55)
   INKEY(.5)
   RETURN (1)
CASE mode= 3
   HelpVar("Arquivo Sem Conteudo",20,23,55)
   INKEY(1)
   RETURN (0)
CASE LASTKEY()=K_ESC
   RETURN (0)
CASE LASTKEY()=K_ENTER
   VARIAVEL=READVAR()
   FPrCod = VARIAVEL
   store PrCod to Novo_Codigo
   &VARIAVEL=Novo_Codigo
   RETURN(0)
CASE LASTKEY() == K_F4
   PesquisaNome()
CASE LASTKEY() == K_F5
   PesquisaCodigo()
OTHERWISE
   RETURN (0)
ENDCASE

************************
function Def_Cor(OP_COR)
************************
use cor alias _cor new
dbgotop()
do case
   case OP_COR=1
      rlock()              //Cor Fundo
      replace Frente with "W"
      replace Fundo  with "GR+"
      unlock
      dbskip()
      rlock()              //Cor Titulo
      replace Frente with "W"
      replace Fundo  with "GR"
      unlock
      dbskip()
      rlock()              //Cor Apresentacao
      replace Frente with "RG+"
      replace Fundo  with "GR"
      unlock
      dbskip()
      rlock()              //Cor MyColors1 (TBrowse)
      replace Frente with "W"
      replace Fundo  with "GR"
      unlock
      dbskip()
      rlock()              //Cor MyColors2 (TBrowse)
      replace Frente with "W+"
      replace Fundo  with "B"
      unlock
      dbskip()
      commit
   case OP_COR=2
      rlock()              //Cor Fundo
      replace Frente with "W"
      replace Fundo  with "N+"
      unlock
      dbskip()
      rlock()              //Cor Titulo
      replace Frente with "RG+"
      replace Fundo  with "N+"
      unlock
      dbskip()
      rlock()              //Cor Apresentacao
      replace Frente with "RG"
      replace Fundo  with "N+"
      unlock
      dbskip()
      rlock()              //Cor MyColors1 (TBrowse)
      replace Frente with "W"
      replace Fundo  with "N+"
      unlock
      dbskip()
      rlock()              //Cor MyColors2 (TBrowse)
      replace Frente with "W+"
      replace Fundo  with "B"
      unlock
      dbskip()
   case OP_COR=3
      rlock()              //Cor Fundo
      replace Frente with "W"
      replace Fundo  with "R"
      unlock
      dbskip()
      rlock()              //Cor Titulo
      replace Frente with "W+"
      replace Fundo  with "R"
      unlock
      dbskip()
      rlock()              //Cor Apresentacao
      replace Frente with "W+"
      replace Fundo  with "R"
      unlock
      dbskip()
      rlock()              //Cor MyColors1 (TBrowse)
      replace Frente with "W"
      replace Fundo  with "R"
      unlock
      dbskip()
      rlock()              //Cor MyColors2 (TBrowse)
      replace Frente with "W+"
      replace Fundo  with "B"
      unlock
      dbskip()
    case OP_COR=4
      rlock()              //Cor Fundo
      replace Frente with "W+"
      replace Fundo  with "B"
      unlock
      dbskip()
      rlock()              //Cor Titulo
      replace Frente with "GR+"
      replace Fundo  with "B"
      unlock
      dbskip()
      rlock()              //Cor Apresentacao
      replace Frente with "GR+"
      replace Fundo  with "B"
      unlock
      dbskip()
      rlock()              //Cor MyColors1 (TBrowse)
      replace Frente with "W"
      replace Fundo  with "B"
      unlock
      dbskip()
      rlock()              //Cor MyColors2 (TBrowse)
      replace Frente with "W+"
      replace Fundo  with "GR"
      unlock
      dbskip()
endcase
go top
public cor_Fundo  := Frente + "/" + Fundo
dbskip()
public cor_Titulo := Frente + "/" + Fundo
dbskip()
public cor_Apresentacao := Frente + "/" + Fundo
dbskip()
MyCor1 := Frente + "/" + Fundo
dbskip()
MyCor2 := Frente + "/" + Fundo
public MYCOLORS := MyCor1 + "," + MyCor2
close _cor
cls
telpadrao()
FUNDO()
@ 00,23 say "≥" + space(37) + "≥" color ["&cor_Fundo"]
@ 01,23 say "≥" + space(37) + "≥" color ["&cor_Fundo"]
@ 02,23 say "≥" + space(37) + "≥" color ["&cor_Fundo"]
@ 00,25 say "      …Õª …Õª ÀÕª …Õ …Õ …Õ …Õª      "    color ["&cor_Apresentacao"]
@ 01,25 say "      ∫   ∫ ∫ ∫ ∫ ÃÕ ÃÕ ÃÕ ∫Àº      "    color ["&cor_Apresentacao"]
@ 02,25 say "      »Õº »Õº – –  Õ –   Õ –”       "    color ["&cor_Apresentacao"]
//@ 00,25 say "  …ÕÀÕª …Õ ÀÕª ÀÕª …Õª ÀÕª …Õª …Õª  "    color ["&cor_Apresentacao"]
//@ 01,25 say "  ∫ ∫ ∫ ÃÕ ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫ ∫   ÃÕπ  "    color ["&cor_Apresentacao"]
//@ 02,25 say "  – – –  Õ – –  Õº »Õº – – »Àº – –  "    color ["&cor_Apresentacao"]
//@ 00,25 say "  …Õ À   …Õ …Àª …Õª …Õª …Õ …Õ …Õª   "    color ["&cor_Apresentacao"]
//@ 01,25 say "  ÃÕ ∫   ÃÕ  ∫  ∫Àº ∫ ∫ ÃÕ ÃÕ ∫Àº   "    color ["&cor_Apresentacao"]
//@ 02,25 say "   Õ »Õº  Õ  –  –”  »Õº –   Õ –”    "    color ["&cor_Apresentacao"]
@ 03,23 say "¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡" color ["&cor_Fundo"]
MAIN()
return nil

FUNCTION FUNDO(Conf)
LOCAL cCor := SETCOLOR(), nI, nF, cTela, aFundo := {}, cFundo := "",cFUN, nPersonal
LOCAL nFundo := Conf_CFG("FUNDO")
Conf := IF(Conf == NIL,.F.,.T.)
aFundo := { SUBSTR(ALLTRIM(FIRMA) + SPACE( 50 - (LEN(ALLTRIM(FIRMA)))),1,40),;
            "*             "                                                                ,;
            "∞∞∞∞∞∞∞∞∞∞±±±±±±±±±≤≤≤≤≤≤≤≤≤≤±±±±±±±±±±"                                       ,;
            "∞∞∞∞∞∞∞∞∞∞±±±±±±±±±∞∞∞∞∞∞∞∞∞∞≤≤≤≤≤≤≤≤≤≤"                                       ,;
            "≤≤≤≤≤≤≤≤≤≤∞∞∞∞∞∞∞∞∞≤≤≤≤≤≤≤≤≤≤±±±±±±±±±±"                                       ,;
            "≤≤≤≤≤≤≤≤≤≤         ∞∞∞∞∞∞∞∞∞∞±±±±±±±±±±"                                       ,;
            "∞"                                                                             ,;
            "±"                                                                             ,;
            "≤"                                                                             ,;
            "¿ø¿ø"                                                                          ,;
            " ÀÀ "                                                                          ,;
            "¡¬¬¡"                                                                          ,;
            "√¥¥√"                                                                          ,;
            "πÃÃπ"                                                                          }

IF Conf
   SetColor("R+/b,N/W")
   FOR nI := 1 TO LEN(aFundo)
      cFun := SUBSTR(aFundo[nI] + SPACE(40),1,40)
      @ 06+nI,03 PROMPT " "+cFun
   NEXT
   MENU TO nFundo
   IF LASTKEY() == 27
      SETCOLOR(cCor) ; SETCURSOR(0)
      RETURN NIL
   ENDIF
   Conf_CFG("FUNDO",nFundo)
   SETCOLOR(cCor)
ENDIF
IF nFundo == 1
   nPersonal  := (LEN(ALLTRIM(FIRMA) + SPACE( 50 - (LEN(ALLTRIM(FIRMA))))) - 50)
   cFundo     := ALLTRIM(FIRMA) + SPACE( 50 - (LEN(ALLTRIM(FIRMA)))) + SPACE( nPersonal )
ELSEIF nFundo == 2
   cFundo := aFundo[2]
ELSE
   cFundo := aFundo[nFundo]
ENDIF
IF nFundo < 10
   cFundo := SUBS(cFundo+REPL(cFundo,1840/LEN(cFundo)),1,1840)
ENDIF
FOR nF := 4 TO 22
   IF nFundo < 10
      @ nF,00 SAY SUBS(cFundo,nF*80-79,80)
   ELSE
      @ nF,00 SAY REPL(SUBS(cFundo,1,2),40)
      cFundo := SUBS(cFundo,3)+SUBS(cFundo,1,2)
   ENDIF
NEXT
IF Conf
   lFUND := .T.
ENDIF
RETURN .T.
