
# include "INKEY.CH"
# include "PAN.CH"

*************************
function INDEXA(REINDEXA)
*************************
LOCAL NUM_ERRO:=0, FATT:="        "
local TamDBF := 26 , TamNTx := 54, ContDBF := ContNTx := 0
local tela := savescreen(0,0,maxrow(),maxcol())
local fim := inicio := time()
REINDEXA:=IF(REINDEXA==NIL,.F.,REINDEXA)
IF REINDEXA
   HelpVar("Aguarde, apagando arquivos de indice!",68,23,12)
   CLOSE ALL
   run del *.ntx > NUL
endif
CORANTIGA:=SETCOLOR()
moldura(7,11,21,70,.f.," Indexa‡„o dos Arquivos ")
msgcenter(08,"A G U A R D E",.F.)
@ 23,12 say space(68)
@ 23,12 say "Criando Arquivo de Indice!" color ["W+*"]

@ 17,13 clear to 20,68
@ 17,13 to 20,30
@ 17,15 say " Total " color ["&cor_Apresentacao"]
@ 18,15 say "Arquivo : " + alltrim(str(TamDBF))
@ 19,15 say "Indices : " + alltrim(str(TamNTX))

@ 17,32 to 20,50
@ 17,34 say " Falta Indexar " color ["&cor_Apresentacao"]
@ 18,34 say "Arquivo : "
@ 19,34 say "Indices : "
@ 17,52 to 20,68
@ 17,54 say " Tempo " color ["&cor_Apresentacao"]
fim := time()
@ 18,54 say "Gasto : " + transf(right(elaptime(inicio,fim),5),"99:99")

@ 18,44 say + transf(TamDBF-ContDBF,"999,99")
@ 19,44 say + transf(TamNTX-ContNTX,"999,99")

select 1
ContDBF++
do while .t.
   IF NET_USE("PRODUTOS",.F.,10,"_PRODUTOS",.F.,.F.)
      ContNTX++
      if !FILE("CO1_PROD.NTX")
         HelpVar("Indexando Arquivo de Produtos por C¢digo",58,10,12)
         index on PrCod        to CO1_PROD eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      if !FILE("NO1_PROD.NTX")
         HelpVar("Indexando Arquivo de Produtos por Nome",58,10,12)
         index on PrNome       to NO1_PROD eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      if !FILE("CO1_GRUP.NTX")
         HelpVar("Indexando Arquivo de Produtos por C¢digo do Grupo",58,10,12)
         index on PrGrupo      to CO1_GRUP eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      if !FILE("Prod_GRUP.NTX")
         HelpVar("Indexando Arquivo de Produtos por C¢digo de Grupo/Descr.",58,10,12)
         index on str(PrGrupo,2)+substr(PrNome,1,5)  to Prod_GRUP eval percent()
      endif
      set index to CO1_PROD,NO1_PROD,CO1_GRUP,Prod_GRUP
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
      NUM_ERRO:=VALIDDBF("PRODUTOS")
      FATT:=GETFATTR("PRODUTOS.DBF")
      if ALERT("N„o foi poss¡vel abrir arquivo de produtos.;Erro " +alltrim(str(NUM_ERRO)) + FATT + ";Deseja continuar?",{"Sim","N„o"})==2
         quit
      endif
   endif
enddo
close all
fim := time()

select 2
ContDBF++
do while .t.
   IF NET_USE("GRUPOS",.F.,10,"_GRUPOS",.F.,.F.)
      ContNTX++
      IF ! FILE("CO2_GRUP.NTX")
         HelpVar("Indexando Arquivo de Grupos por C¢digo",58,10,12)
         index on GpCod   to CO2_GRUP eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("NO2_GRUP.NTX")
         HelpVar("Indexando Arquivo de Grupos por Nome",58,10,12)
         INDEX ON GpNome   TO NO2_GRUP eval percent()
      ENDIF
      set index to CO2_GRUP, NO2_GRUP
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("GRUPOS")
     FATT:=GETFATTR("GRUPOS.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de grupos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all
fim := time()
select 3
ContDBF++
do while .t.
   IF NET_USE("FUNCIONA",.F.,10,"_FUNCIONA",.F.,.F.)
      ContNTX++
      IF ! FILE("CO3_FUNC.NTX")
         HelpVar("Indexando Arquivo de Funcion rios por C¢digo",58,10,12)
         index on FunCod  to CO3_FUNC  eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("NO3_FUNC.NTX")
         HelpVar("Indexando Arquivo de Funcion rios por Nome",58,10,12)
         index on FuncNome TO NO3_FUNC eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CargoFunc.NTX")
         HelpVar("Indexando Arquivo de Funcion rios por Cargo",58,10,12)
         index on FuncCarg TO  CargoFunc eval percent()
      ENDIF
      set index to CO3_FUNC, NO3_FUNC, CargoFunc
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("FUNCIONA")
     FATT:=GETFATTR("FUNCIONA.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de funcionarios.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all
fim := time()
select 4
ContDBF++
do while .t.
   IF NET_USE("OPERACOE",.F.,10,"_OPERACOE",.F.,.F.)
      ContNTX++
      IF ! FILE("CO4_OPER.NTX")
         HelpVar("Indexando Arquivo de Opera‡oes por C¢digo",58,10,12)
         index on OPERCOD  to CO4_OPER eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("NO4_OPER.NTX")
         HelpVar("Indexando Arquivo de Opera‡oes por Nome",58,10,12)
         index on OPERNOME  to NO4_OPER eval percent()
      ENDIF
      set index to CO4_OPER,NO4_OPER
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("OPERACOE")
     FATT:=GETFATTR("OPERACOE.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de funcionarios.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 5
ContDBF++
do while .t.
   IF NET_USE("FORNECED",.F.,10,"_FORNECED",.F.,.F.)
      ContNTX++
      IF ! FILE("CO5_FOR.NTX")
         HelpVar("Indexando Arquivo de Fornecedor por C¢digo",58,10,12)
         index on FORCOD  to CO5_FOR  eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("NO5_FOR.NTX")
         HelpVar("Indexando Arquivo de Fornecedor por Nome",58,10,12)
         index on FORNOME  to NO5_FOR  eval percent()
      ENDIF
      set index to CO5_FOR,NO5_FOR
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("FORNECED")
     FATT:=GETFATTR("FORNECED.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Fornecedor.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 6
ContDBF++
do while .t.
   Nome_Arq := "Mov" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndM1    := "MCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndM2    := "MDT" + + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IF NET_USE(Nome_Arq,.F.,10,"_MOVIMENT",.F.,.F.)
      ContNTX++
      IF ! FILE("&IndM1"+".NTX")
         HelpVar("Indexando Arquivo de Movimentos por C¢digo",58,10,12)
         index on MOVCOD  to "&IndM1" eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("&IndM2"+".NTX")
         HelpVar("Indexando Arquivo de Movimentos por Data",58,10,12)
         index on MovDt to "&IndM2" eval percent()
      endif
      set index to "&IndM1","&IndM2"
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF(Nome_Arq)
     FATT:=GETFATTR(Nome_Arq+".DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de " + Nome_Arq + " .;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 7
ContDBF++
do while .t.
   Nome_Arq := "ITM" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt1   := "ITCD" + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt2   := "ITCP" + + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IndIt3   := "ITDT" + + alltrim(str(Month(Nova_Data))) + right(alltrim(str(year(Nova_Data))),2)
   IF NET_USE(Nome_Arq,.F.,10,"_ITENSMOV",.F.,.F.)
      ContNTX++
      IF ! FILE("&IndIt1"+".NTX")
         HelpVar("Indexando Arquivo de Itens De Movimentos por C¢digo",58,10,12)
         index on IMCOD  to "&IndIt1" eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("&IndIt2"+".NTX")
         HelpVar("Indexando Arquivo de Itens De Movimentos por Produto",58,10,12)
         index on ImCdPro to "&IndIt2" eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("&IndIt3"+".NTX")
         HelpVar("Indexando Arquivo de Itens De Movimentos por Data",58,10,12)
         index on ImData to "&IndIt3" eval percent()
      endif
      set index to "&IndIt1","&IndIt2","&IndIt3"
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF(Nome_Arq)
     FATT:=GETFATTR(Nome_Arq+".DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de " + Nome_Arq + " .;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 8
ContDBF++
do while .t.
   IF NET_USE("COMPRAS",.F.,10,"_COMPRAS",.F.,.F.)
      ContNTX++
      IF ! FILE("CO8_COMP.NTX")
         HelpVar("Indexando Arquivo de Compras por C¢digo",58,10,12)
         index on CPCOD  to CO8_COMP  eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CPDTCOMP.NTX")
         HelpVar("Indexando Arquivo de Compras por Data",58,10,12)
         index on dtos(CPDATA) to CPDTCOMP eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CPFORCP.NTX")
         HelpVar("Indexando Arquivo de Compras por Fornecedor",58,10,12)
         index on CPFOR to CPFORCP eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CPFORDOC.NTX")
         HelpVar("Indexando Arquivo de Compras por Fornecedor",58,10,12)
         index on val(alltrim(str(CpCod) + strzero(CpFor,3))) to CPFORDOC eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("COMPDOC.NTX")
         HelpVar("Indexando Arquivo de Pagtos por NDOC_COM",58,10,12)
         index on NDOC_COM to COMPDOC eval percent()
      endif
      set index to CO8_COMP,CPDTCOMP,CPFORCP,CPFORDOC,COMPDOC
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("COMPRAS")
     FATT:=GETFATTR("COMPRAS.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Movimentos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 9
ContDBF++
do while .t.
   IF NET_USE("ITENSCOMP",.F.,10,"_ITENSCOMP",.F.,.F.)
      ContNTX++
      IF ! FILE("CO9_ICOMP.NTX")
         HelpVar("Indexando Arquivo de Itens de Compras por C¢digo",58,10,12)
         index on ICCOD  to CO9_ICOMP  eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CPR_ICOMP.NTX")
         HelpVar("Indexando Arquivo de Itens de Compras por Produto",58,10,12)
         index on ICCODPR to CPR_ICOMP eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CDT_ICOMP.NTX")
         HelpVar("Indexando Arquivo de Itens de Compras por Data",58,10,12)
         index on ICDATA to CDT_ICOMP eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("ICOMPDOC.NTX")
         HelpVar("Indexando Arquivo de Itens de Compras por C¢digo",58,10,12)
         index on NDOC_COM to ICOMPDOC eval percent()
      endif
      ContNTX++
      IF ! FILE("CO9_ICDTP.NTX")
         HelpVar("Indexando Arquivo de Itens de Compras por Dt/C¢digo",58,10,12)
         index on str(ICCODPR,4)+ dtoc(ICDATA)  to CO9_ICDTP  eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      set index to CO9_ICOMP,CPR_ICOMP,CDT_ICOMP,ICOMPDOC,CO9_ICDTP
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("ITENSCOMP")
     FATT:=GETFATTR("ITENSCOMP.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Movimentos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 10
ContDBF++
do while .t.
   IF NET_USE("PAGAMENT",.F.,10,"_PAGAMENT",.F.,.F.)
      ContNTX++
      IF ! FILE("CO10_PGT.NTX")
         HelpVar("Indexando Arq. Itens de Pagamentos por C¢digo + Data",58,10,12)
         index on str(PGNUMDOC)+dtos(PGDATAPRV)  to CO10_PGT  eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("PGTODOC.NTX")
         HelpVar("Indexando Arquivo de Pagtos por NDOC_COM",58,10,12)
         index on NDOC_COM to PGTODOC eval percent()
      endif
      ContNTX++
      IF ! FILE("PGTOFOR.NTX")
         HelpVar("Indexando Arquivo de Pagtos por Fornecedor",58,10,12)
         index on val(right(str(PGNUMDOC),3)) to PGTOFOR eval percent()
      endif
      set index to CO10_PGT,PGTODOC,PGTOFOR
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("PAGAMENT")
     FATT:=GETFATTR("PAGAMENT.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Movimentos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 11
ContDBF++
do while .t.
   IF NET_USE("RECEB",.F.,10,"_RECEB",.F.,.F.)
      ContNTX++
      IF ! FILE("RCodDt.NTX")
         HelpVar("Indexando Arq. de Rec. Pelo C¢d. do Mov. + Data",58,10,12)
         index on str(Rec_Cod,6) + Dtos(Rec_Dt) to RCodDt eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("RCodCli.NTX")
         HelpVar("Indexando Arq. de Rec. Pelo C¢d. Cliente",58,10,12)
         index on Rec_Cli to RCodCli eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("RecDt.NTX")
         HelpVar("Indexando Arq. de Rec. Pela Data do Mov.",58,10,12)
         index on Rec_Dt to RecDt eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      set index to RCodDt,RCodCli,RecDt
      exit
   else
     NUM_ERRO:=VALIDDBF("RECEB")
     FATT:=GETFATTR("RECEB.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Recebimento.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 12
ContDBF++
do while .t.
   IF NET_USE("CARGOS",.F.,10,"_CARGOS",.F.,.F.)
      ContNTX++
      IF ! FILE("CargCod.NTX")
         HelpVar("Indexando Arq. de Cargos por C¢digo",58,10,12)
         index on CargCod to CargCod eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("CargNome.NTX")
         HelpVar("Indexando Arq. de Cargos por Nome",58,10,12)
         index on CargNome to CargNome eval percent()
      endi
      set index to CargCod,CargNome
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("CARGOS")
     FATT:=GETFATTR("CARGOS.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Cargos;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 13
ContDBF++
do while .t.
   IF NET_USE("CLIENTES",.F.,10,"_CLIENTES",.F.,.F.)
      ContNTX++
      IF ! FILE("ClCod.NTX")
         HelpVar("Indexando Arq. de Clientes por C¢digo",58,10,12)
         index on ClCod to ClCod eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("ClNome.NTX")
         HelpVar("Indexando Arq. de Clientes por Nome",58,10,12)
         index on ClNome to ClNome eval percent()
      endi
      set index to ClCod,ClNome
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("CLIENTES")
     FATT:=GETFATTR("CLIENTES.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Clientes;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 14
ContDBF++
do while .t.
   IF NET_USE("ITENSREC",.F.,10,"_ITENSREC",.F.,.F.)
      ContNTX++
      IF ! FILE("IRCodDt.NTX")
         HelpVar("Indexando Arq. de Itens Rec. Pelo C¢d. do Mov. + Data",58,10,12)
         index on str(IRCod,6) + Dtos(IRDt) to IRCodDt eval percent()
      endif
      set index to IRCodDt
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("ITENSREC")
     FATT:=GETFATTR("ITENSREC.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Ötens de Recebimento.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 16
ContDBF++
do while .t.
   IF NET_USE("SENHA",.F.,10,"_SENHA",.F.,.F.)
      ContNTX++
      IF ! FILE("SUSE.NTX")
         HelpVar("Indexando Arq. de Senha Por Usuario",58,10,12)
         index on User to SUSE eval percent()
      endif
      set index to SUSE
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("SENHA")
     FATT:=GETFATTR("SENHA.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Abertura.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 17
ContDBF++
do while .t.
   IF NET_USE("N_DOC",.F.,10,"_N_DOC",.F.,.F.)
      ContNTX++
      IF ! FILE("NOVODOC.NTX")
         HelpVar("Indexando Arq. de NovoDOC",58,10,12)
         index on N_DOC to NOVODOC eval percent()
      endif
      set index to NOVODOC
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("N_DOC")
     FATT:=GETFATTR("N_DOC.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de NovoDoc.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 18
ContDBF++
do while .t.
   IF NET_USE("N_DOCCOM",.F.,10,"_N_DOCCOM",.F.,.F.)
      ContNTX++
      IF ! FILE("NDOCCOMP.NTX")
         HelpVar("Indexando Arq. de NovoDocCompr",58,10,12)
         index on N_DOCCOMPR to NDOCCOMP eval percent()
      endif
      set index to NDOCCOMP
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("N_DOCCOM")
     FATT:=GETFATTR("N_DOCCOM.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de NovoDocCompr.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 19
ContDBF++
do while .t.
   IF NET_USE("ESTFUNC",.F.,10,"_ESTFUNC",.F.,.F.)
      ContNTX++
      IF ! FILE("EST_VEND.NTX")
         HelpVar("Indexando Arq. de Estat¡stica",58,10,12)
         index on dtos(DATA_VENDA) + str(Cod_Func) to EST_VEND eval percent()
      endif
      set index to EST_VEND
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("ESTFUNC")
     FATT:=GETFATTR("ESTFUNC.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Estat¡stica.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
close all

fim := time()
select 20
ContDBF++
do while .t.
   IF NET_USE("ESTGRUP",.F.,10,"_ESTGRUP",.F.,.F.)
      ContNTX++
      IF ! FILE("EST_GRUP.NTX")
         HelpVar("Indexando Arq. de Estat¡stica Por Grupo ",58,10,12)
         index on dtos(DATA_VENDA) + str(Cod_Grupo,2) to EST_GRUP eval percent()
      endif
      set index to EST_GRUP
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   else
     NUM_ERRO:=VALIDDBF("ESTGRUP")
     FATT:=GETFATTR("ESTGRUP.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Estat¡stica.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo

fim := time()
select 21
ContDBF++
do while .t.
   IF NET_USE("PRANT",.F.,10,"_PRANT",.F.,.F.)
      ContNTX++
      if !FILE("COD_PRAN.NTX")
         HelpVar("Indexando Arquivo de Produtos por C¢digo",58,10,12)
         index on PrCod        to COD_PRAN eval percent()
      endif
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      if !FILE("NO_PRAN.NTX")
         HelpVar("Indexando Arquivo de Produtos por Nome",58,10,12)
         index on PrNome       to NO_PRAN eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      set index to COD_PRAN,NO_PRAN
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
      NUM_ERRO:=VALIDDBF("PRANT")
      FATT:=GETFATTR("PRANT.DBF")
      if ALERT("N„o foi poss¡vel abrir arquivo de produtos.;Erro " +alltrim(str(NUM_ERRO)) + FATT + ";Deseja continuar?",{"Sim","N„o"})==2
         quit
      endif
   endif
enddo

select 22
ContDBF++
do while .t.
   IF NET_USE("FCANT",.F.,10,"_FCANT",.F.,.F.)
      ContNTX++
      IF ! FILE("COD_FCANT.NTX")
         HelpVar("Indexando Arquivo de Funcion rios por C¢digo",58,10,12)
         index on FunCod  to COD_FCANT  eval percent()
      ENDIF
      set index to COD_FCANT
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("FCANT")
     FATT:=GETFATTR("FCANT.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de funcionarios.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo

select 23
ContDBF++
do while .t.
   IF NET_USE("UNMEDIDA",.F.,10,"_UNMEDIDA",.F.,.F.)
      ContNTX++
      IF ! FILE("Cod_UnMED.NTX")
         HelpVar("Indexando Arquivo de Un. Medidas por C¢digo",58,10,12)
         index on Cod_UnMed   to Cod_UnMed eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("NOME_UNMED.NTX")
         HelpVar("Indexando Arquivo de Un. Medidas por Nome",58,10,12)
         INDEX ON NOME_UNMED  TO NOME_UNMED eval percent()
      ENDIF
      set index to Cod_UnMed, Nome_UnMed
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("UNMEDIDA")
     FATT:=GETFATTR("UNMEDIDA.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Un.Medida.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo

select 24
ContDBF++
do while .t.
   IF NET_USE("VPRAZOPG",.F.,10,"_VPRAZOPG",.F.,.F.)
      ContNTX++
      IF ! FILE("DT_RECEB.NTX")
         HelpVar("Indexando Arquivo de Receb.Venda Prazo por Dt. Rec.",58,10,12)
         index on DT_RECEB   to DT_RECEB eval percent()
      ENDIF
      set index to DT_RECEB
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("VPRAZOPG")
     FATT:=GETFATTR("VPRAZOPG.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Recebimentos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo

select 25
ContDBF++
do while .t.
   IF NET_USE("IVPRAZPG",.F.,10,"_IVPRAZPG",.F.,.F.)
      ContNTX++
      IF ! FILE("IRVPPG.NTX")
	 HelpVar("Indexando Arquivo de Itens Recebidos",58,10,12)
         index on IRCOD   to IRVPPG eval percent()
      ENDIF
      set index to IRVPPG
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("IVPRAZPG")
     FATT:=GETFATTR("IVPRAZPG.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Itens Recebidos.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo

select 26
ContDBF++
do while .t.
   IF NET_USE("MOVREC",.F.,10,"_MOVREC",.F.,.F.)
      ContNTX++
      IF ! FILE("MRecCli.NTX")
         HelpVar("Indexando Arquivo de Recebimento",58,10,12)
         index on Cl_Cliente   to MRecCli eval percent()
      ENDIF
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      ContNTX++
      IF ! FILE("MRecDt.NTX")
         HelpVar("Indexando Arquivo de Recebimento",58,10,12)
         INDEX ON Data_Rec  TO MRecDt eval percent()
      ENDIF
      set index to MRecCli , MRecDt
      Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
      exit
   ELSE
     NUM_ERRO:=VALIDDBF("MOVREC")
     FATT:=GETFATTR("MOVREC.DBF")
     if ALERT("N„o foi poss¡vel abrir arquivo de Recebimento.;Erro " +alltrim(str(NUM_ERRO)) + FATT +";Deseja continuar?",{"Sim","N„o"})==2
        quit
     endif
   endif
enddo
      
close all
fim := time()
close all
fim := time()
@ 18,54 say "Gasto : " + transf(right(elaptime(inicio,fim),5),"99:99")
@ 18,44 say + transf(TamDBF-ContDBF,"999,99")
@ 19,44 say + transf(TamNTX-ContNTX,"999,99")
inkey(1)
@ 23,11 say space(70)
setcolor("&CORANTIGA")
restscreen(0,0,maxrow(),maxcol(),tela)
return nil

**********************************************************
function Mostra_Ind(TamDBF,TamNTX,ContDBF,ContNTX, Inicio)
**********************************************************
fim := time()
@ 18,54 say "Gasto : " + transf(right(elaptime(inicio,fim),5),"99:99")
@ 18,44 say + transf(TamDBF-ContDBF,"999,99")
@ 19,44 say + transf(TamNTX-ContNTX,"999,99")
return nil
