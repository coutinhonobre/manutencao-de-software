# include "INKEY.CH"
# include "RCH.CH"
# include "PAN.CH"

***************
function MAIN()
***************
local MENU1:={{" Venda      ","Vendas Diárias         " ,{||MovVenda()}},;
              {" Cadastro   ","Cadastro Geral         " ,{||CADASTRO()}},;
              {" Compra     ","Lanamento das Compras " ,{||MovCompra()}},;
              {" Relatarios ","Relatarios Diversos    " ,{||RELATORIO()}},;
              {" Pagamento   ","Baixa de Pagamento     " ,{||BAIXA_PAGAMENTO()}},;
              {" Recebimento ","Recebimento de Clientes" ,{||Baixa_Recebimento()}},;
              {" Utilitario ","Utilitario do Sistema  " ,{||UtilSis()}},;
              {" Fim         ","Finaliza               " ,{||Saida()}}}
LOCAL telaprincipal:=0
set key K_F10 to CALC()
set key K_ALT_M TO MANUAL()
menublock(4,2,MENU1,@TELAPRINCIPAL,.F.,,.F.)
return nil

********************
function UtilSis()
********************
LOCAL MENU15:={{" Backup-Up   ","Backup do Sistema"                ,{||Backup_restore(1,"Backup")}},;
               {" Restore     ","Restore do Sistema"               ,{||Backup_restore(2,"Restore")}},;
               {" Sobre       ","Informacao Sobre o Sistema"       ,{||InfSis()}},;
               {" Senhas      ","Cadastro de Senha"                ,{||Cad_Senha()}},;
               {" Paramentos ","Cadastro de Paramentos do Sistema",{||Paramentros()}},;
               {" Cores      ","Configurar Cores do Sistema"      ,{||CORES()}},;
               {" Reorganizar ","Reorganizar Arquivo do Sistema"   ,{||Reorganizar()}}}
LOCAL TelaSis:=0
if TRotina(12)
   MENUBLOCK(12,12,MENU15,@TelaSis,.T.,,.F.)
endif
return nil

***********************
function Paramentros()
***********************
LOCAL MENU1251:={{" Relatorio de Valorizacao de Estoque","Define paramentro para relatorio valorizazao de estoque "  ,{||Cad_Paramentros()}},;
                 {" Cadastro Custo Fixo                ","Define o custo fixo                                     "  ,{||Cad_CustoFixo()}},;
                 {" Paramentro -> Comissao Funcionario ","Define paramentro de comissao de funcionario            "  ,{||Cad_Comissao()}}}
LOCAL T_TELA:=0
MENUBLOCK(15,26,MENU1251,@T_TELA,.T.,,.F.)
return nil

********************
function MovCompra()
********************
LOCAL MENU14:={{" Lancamento     ","Lancamento das Compras Diarias "  ,{||COMPRA()}},;
               {" Cancelamento   ","Cancelamento das Compras Diarias" ,{||CCOMPRA()}},;
               {" Monitoramento ","Monitoramento das Compras Diarias",{||MonitCompra()}}}
LOCAL TelaMovVenda:=0
if TRotina(6)
   MENUBLOCK(8,12,MENU14,@TelaMovVenda,.T.,,.F.)
endif
return nil

**********************
function MonitCompra()
**********************
LOCAL MENU153:={{" Periodo     ","Monitoramento Por Periodo"    ,{||MCPeriodo()}},;
                {" Nota Fiscal ","Monitoramento Por Nota Fiscal",{||MCDocumento()}},;
                {" Fornecedor  ","Monitoramento Por Fornecedor" ,{||MCFor()}},;
                {" Produto     ","Monitoramento Por Produto"    ,{||MCProduto()}}}
LOCAL TelaMonitCompra:=0
if TRotina(4)
   MENUBLOCK(12,22,MENU153,@TelaMonitCompra,.T.,,.F.)
endif
return nil

********************
function MovVenda()
********************
LOCAL MENU15:={{" Lancamento     ","Lancamento das Vendas Diarias  " ,{||MOVIMENTO()}},;
               {" Cancelamento   ","Cancelamento Vendas Diarias  "   ,{||CMOVIMENTO()}},;
               {" Monitoramento ","Monitoramento das Vendas Diarias",{||MonitVenda()}}}
LOCAL TelaMovVenda:=0
if TRotina(1)
   MENUBLOCK(6,12,MENU15,@TelaMovVenda,.T.,,.F.)
endif
return nil

**********************
function MonitVenda()
**********************
LOCAL MENU153:={{" Periodo   ","Monitoramento Por Periodo"   ,{||MVPeriodo()}},;
                {" Documento ","Monitoramento Por Documento" ,{||MDocumento()}},;
                {" Produto   ","Monitoramento Por Produto"   ,{||MProduto()}},;
                {" Operacao  ","Monitoramento Por Operacao"  ,{||MOperacao()}},;
                {" Grupo     ","Monitoramento Por Grupo"     ,{||MGrupo()}}}
LOCAL TelaMonitVenda:=0
if TRotina(4)
   MENUBLOCK(10,22,MENU153,@TelaMonitVenda,.T.,,.F.)
endif
return nil

********************
function Cadastro()
********************
LOCAL MENU11:={{" Produtos                      ","Cadastro de Produtos"          ,{||Cad_Pro()}},;
               {" Grupos                        ","Cadastro de Grupos"            ,{||Cad_Grupo()}},;
               {" Un. de Medida                 ","Cadastro Unidade de Medida"    ,{||Cad_UnMed()}},;
               {" Cargos                        ","Cadastro de Cargos Funcinarios",{||Cad_Cargo()}},;
               {" Funcionarios                  ","Cadastro de Funcionarios"      ,{||Cad_Func()}},;
               {" Clientes - Pessoa Juridica    ","Cadastro de Clientes Pessoa Fisica"          ,{||Cad_Cli_Juridica()}},;
               {" Clientes - Pessoa Fisica      ","Cadastro de Clientes Pessoa Juridica"          ,{||Cad_Cli_Fisica()}},;
               {" Fornecedores                  ","Cadastro de Fornecedores"      ,{||Cad_For()}},;
               {" Operacoes                     ","Cadastro de Operacoes"         ,{||Cad_Operacao()}}}
LOCAL telacadastro:=0
if TRotina(5)
   MENUBLOCK(7,12,MENU11,@TELACADASTRO,.T.,,.F.)
endif
return nil

********************
function RELATORIO()
********************
LOCAL MENU12:={{" Financeiro  ","Relatarios Financeiros"   ,{||RELA_FINANCEIRO()}},;
               {" Cadastro    ","Relatarios de Cadastro"   ,{||RELA_CADASTRO()}},;
               {" Estoque     ","Relatarios de Estoque"    ,{||RELA_ESTOQUE()}},;
               {" Estatistica ","Relatarios de Estatistica",{||RELA_ESTATISTICA()}}}
LOCAL TELARELATORIOS:=0
if TRotina(9)
   MENUBLOCK(9,12,MENU12,@TELARELATORIOS,.T.,,.F.)
endif
return nil

****************************
function RELA_FINANCEIRO()
****************************
LOCAL MENU122:={{" Fechamento do Caixa     ","Relatario de Fechamento do Caixa"                 ,{||R_FIM_CAIXA()}},;
                {" Tabela Gerencial       ","Comparacao Entre Preco de Venda e Preco de Custo" ,{||LR_CPreco()}},;
                {" Venda Por Documento     ","Relatorio de Venda Por Documento"                 ,{||Venda_Documento()}},;
                {" Valorizacao do Estoque ","Valorizacao do Estoque Atual"                     ,{||LR_VEst()}},;
                {" Produtos com ICMS retido","Produtos com ICMS Retido"                         ,{||LR_ICMS_RETIDO()}},;
                {" Contas a Receber       ","Relatorio de Contas a Receber"                    ,{||R_ContasReceber()}},;
                {" Contas a Pagar          ","Relatorio de Contas a Pagar"                      ,{||R_CONTASP()}}}
LOCAL TELA_RELA_FINACEIRO:=0
MENUBLOCK(11,22,MENU122,@TELA_RELA_FINANCEIRO,.T.,,.F.)
return nil

*******************************
function R_ContasReceber()
*******************************
LOCAL MENU122:={{" Geral            ","Relatorio do Contas a Receber Por Cliente"        ,{||R_CONTASR(1)}},;
                {" Dias Sem Acerto  ","Relatorio de Dias Sem Acerto do Contas a Receber" ,{||R_CONTASR(2)}},;
                {" Extratificado    ","Relatorio de Contas a Receber Extratificado"      ,{||RCCLEXTRATIFICADO()}}}
//                {" Por Cliente     ","Relatorio de Contas a Receber Por Cliente "       ,{||R_CR_Cliente()}}}
LOCAL TELA_RELA_CR:=0
MENUBLOCK(17,44,MENU122,@TELA_RELA_CR,.T.,,.F.)
return nil

************************
function R_CR_Cliente()
************************
LOCAL MENU122:={{" Resumido ","Relatorio de Contas a Pagar Por Cliente        " ,{||R_CONTASRCL()}},;
                {" Todos    ","Relatorio de Contas a Pagar de Todos os Cliente" ,{||RCONTAS_CL()}}}
LOCAL TELA_RELA_CR:=0
MENUBLOCK(19,60,MENU122,@TELA_RELA_CR,.T.,,.F.)
return nil

*********************
function LR_VEst()
*********************
LOCAL MENU1224:={{" Codigo ","Valorizacao do Estoque Atual Classif. Por Codigo" ,{||LR_VESTOQUE(1)}},;
                 {" Nome   ","Valorizacao do Estoque Atual Classif. Por Nome"   ,{||LR_VESTOQUE(2)}}}
LOCAL T_R_VALORIZ_ESTOQUE:=0
MENUBLOCK(16,45,MENU1224,@T_R_VALORIZ_ESTOQUE,.T.,,.F.)
return nil

****************************
function LR_CPreco()
****************************
LOCAL MENU1223:={{" Codigo ","Comp. Entre Preco Venda e de Custo Classif. Por Codigo",{||LR_CUSTO_PRODUTO(1)}},;
                 {" Nome   ","Comp. Entre Preco Venda e de Custo Classif. Por Nome"  ,{||LR_CUSTO_PRODUTO(2)}}}
LOCAL T_R_TABELA_GERENCIAL:=0
MENUBLOCK(14,45,MENU1223,@T_R_TABELA_GERENCIAL,.T.,,.F.)
return nil

****************************
function RELA_CADASTRO()
****************************
LOCAL MENU122:={{" Listagem de Preco   ","Relacao de Preco de Venda"       ,{||LR_LPreco()}},;
                {" Listagem de Grupo   ","Relacao de Cadastro de Grupos"   ,{||LR_CGrupo()}},;
                {" Listagem de Cliente ","Relacao de Cadastro de Clientes" ,{||LR_CCliente()}},;
                {" Cliente por Codigo   ","Relacao de Clientes Por Codigo"  ,{||Rel_Cliente()}},;
                {" Produto Por Grupo    ","Relacao de Produto Por Grupo"    ,{||LR_CPRODUTO()}}}
LOCAL TELA_RELA_CADASTRO:=0
MENUBLOCK(12,25,MENU122,@TELA_RELA_CADASTRO,.T.,,.F.)
return nil

**********************
function LR_CCliente()
**********************
LOCAL MENU1222:={{" Codigo ","Relacao de Cadastro de Cliente Classificado Por Codigo" ,{||Rel_CCliente(1)}},;
                 {" Nome   ","Relacao de Cadastro de Cliente Classificado Por Nome"   ,{||Rel_CCliente(2)}}}
LOCAL T_R_LCliente:=0
MENUBLOCK(16,45,MENU1222,@T_R_LCliente,.T.,,.F.)
return nil

**********************
function LR_CGrupo()
**********************
LOCAL MENU1222:={{" Codigo ","Relacao de Cadastro de Grupo Classificado Por Codigo" ,{||Rel_CGRUPO(1)}},;
                 {" Nome   ","Relacao de Cadastro de Grupo Classificado Por Nome"   ,{||Rel_CGRUPO(2)}}}
LOCAL T_R_LPRECO:=0
MENUBLOCK(15,45,MENU1222,@T_R_LPRECO,.T.,,.F.)
return nil

****************************
function LR_LPreco()
****************************
LOCAL MENU1222:={{" Codigo ","Relacao de Preco de Venda Classificado Por Codigo" ,{||LR_PRODUTO(1)}},;
                 {" Nome   ","Relacao de Preco de Venda Classificado Por Nome"   ,{||LR_PRODUTO(2)}}}
LOCAL T_R_LPRECO:=0
MENUBLOCK(14,45,MENU1222,@T_R_LPRECO,.T.,,.F.)
return nil

***********************
function RELA_ESTOQUE()
***********************
LOCAL MENU121:={{" Atual          ","Posicao do Estoque Atual",                           {||LR_REST_ATUAL()}},;
                {" Minimo         ","Relacao dos Produtos Com o Estoque Abaixo do Minimo",{||LR_REST_MIN()}},;
                {" Nao Controlado ","Relacao dos Produtos Que Nao Controla Estoque"      ,{||LR_REST_NCON()}},;
                {" Por Grupo      ","Relacao dos Estoque Por Grupo"                      ,{||LR_REST_GPROD()}}}
LOCAL TELA_RELA_ESTOQUE:=0
MENUBLOCK(13,22,MENU121,@TELA_RELA_ESTOQUE,.T.,,.F.)
return nil

****************************
function LR_REST_GPROD()
****************************
LOCAL MENU1212:={{" Resumido ","Rel. Resumido da Relacao dos Estoque Por Grupo" ,{||RESTOQUE_GP(1)}},;
                 {" Todos    ","Rel. Total da Relacao dos Estoque Por Grupo"    ,{||RESTOQUE_GP(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(18,35,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function LR_REST_MIN()
****************************
LOCAL MENU1212:={{" Codigo ","Rel. Prod. C/ o Est. Abaixo do Min. Classif. Por Codigo" ,{||RESTOQUE(3,1)}},;
                 {" Nome   ","Rel. Prod. C/ o Est. Abaixo do Min. Classif. Por Nome"   ,{||RESTOQUE(3,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(16,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function LR_REST_NCON()
****************************
LOCAL MENU1212:={{" Codigo ","Relacao dos Produtos Que Nao Controla Estoque Classif. Por Codigo" ,{||RESTOQUE(2,1)}},;
                 {" Nome   ","Relacao dos Produtos Que Nao Controla Estoque Classif. Por Nome"   ,{||RESTOQUE(2,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(17,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

*******************************
function LR_REST_ATUAL()
*******************************
LOCAL MENU1212:={{" Codigo ","Posicao do Estoque Atual Classif. Por Codigo" ,{||RESTOQUE(1,1)}},;
                 {" Nome   ","Posicao do Estoque Atual Classif. Por Nome"   ,{||RESTOQUE(1,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(15,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function RELA_ESTATISTICA()
****************************
LOCAL MENU123:={{" Produto     ","Estatistica das Vendas Por Produtos"     ,{||LR_EST_PRODUTO()}},;
                {" Grupo       ","Estatistica das Vendas Por Grupos"       ,{||LR_EST_GRUPO()}},;
                {" Funcionario ","Estatistica das Vendas Por Funcionario"  ,{||LR_EST_FUNC()}},;
                {" Venda        ","Estatistica das Vendas A Vista / A Prazo",{||Real_CAIXA()}}}
LOCAL TELA_RELA_ESTATISTICA:=0
MENUBLOCK(14,22,MENU123,@TELA_RELA_ESTATISTICA,.T.,,.F.)
return nil

**************************
function LR_EST_GRUPO()
**************************
LOCAL MENU1212:={{" Codigo ","Estatistica das Vendas Por Grupos Classif. Por Codigo" ,{||CR_GRUPO(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Grupos Classif. Por Nome"   ,{||CR_GRUPO(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(17,34,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

**************************
function LR_EST_PRODUTO()
**************************
LOCAL MENU1212:={{" Codigo ","Estatistica das Vendas Por Produtos Classif. Por Codigo" ,{||CR_PRODUTO(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Produtos Classif. Por Nome"   ,{||CR_PRODUTO(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(16,34,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

***********************
function LR_EST_FUNC()
***********************
LOCAL MENU1212:={{" Codigo ","Estatistica das Vendas Por Funcionario Classif. Por Codigo" ,{||CR_FUNC(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Funcionario Classif. Por Nome"   ,{||CR_FUNC(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(18,34,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************
function Cores()
****************
LOCAL MENU1224:={{" Marrom   ","Define cor Marrom            "  ,{||Def_Cor(1)}},;
                 {" Preto    ","Define cor Preto             "  ,{||Def_Cor(2)}},;
                 {" Vermelho ","Define cor Vermelha          "  ,{||Def_Cor(3)}},;
                 {" Azul     ","Define cor Azul              "  ,{||Def_Cor(4)}}}
LOCAL T_TELA:=0
MENUBLOCK(16,25,MENU1224,@T_TELA,.T.,,.F.)
return nil

****************
function Saida()
*****************
 if ALERT("Abandona Sistema ?",{"Sim","Nao"}) == 1
    setcolor("w/n")
    cls
    quit
 Else
   MAIN()
 endif
Return nil
