# include "INKEY.CH"
# include "RCH.CH"
# include "PAN.CH"

***************
function MAIN()
***************
local MENU1:={{" Venda      ","Vendas Di rias         " ,{||MovVenda()}},;
              {" Cadastro   ","Cadastro Geral         " ,{||CADASTRO()}},;
              {" Compra     ","Lan‡amento das Compras " ,{||MovCompra()}},;
              {" Relat¢rios ","Relat¢rios Diversos    " ,{||RELATORIO()}},;
              {" Pagamento   ","Baixa de Pagamento     " ,{||BAIXA_PAGAMENTO()}},;
              {" Recebimento ","Recebimento de Clientes" ,{||Baixa_Recebimento()}},;
              {" Utilit rio ","Utilit rio do Sistema  " ,{||UtilSis()}},;
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
               {" Sobre       ","Informa‡ao Sobre o Sistema"       ,{||InfSis()}},;
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
LOCAL MENU1251:={{" Relat¢rio de Valoriza‡ao de Estoque","Define paramentro para relat¢rio valoriza‡ao de estoque "  ,{||Cad_Paramentros()}},;
                 {" Cadastro Custo Fixo                ","Define o custo fixo                                     "  ,{||Cad_CustoFixo()}},;
                 {" Paramentro -> Comissao Funcionario ","Define paramentro de comissao de funcionario            "  ,{||Cad_Comissao()}}}
LOCAL T_TELA:=0
MENUBLOCK(15,26,MENU1251,@T_TELA,.T.,,.F.)
return nil

********************
function MovCompra()
********************
LOCAL MENU14:={{" Lan‡amento     ","Lan‡amento das Compras Di rias "  ,{||COMPRA()}},;
               {" Cancelamento   ","Cancelamento das Compras Di rias" ,{||CCOMPRA()}},;
               {" Monitoramento ","Monitoramento das Compras Di rias",{||MonitCompra()}}}
LOCAL TelaMovVenda:=0
if TRotina(6)
   MENUBLOCK(8,12,MENU14,@TelaMovVenda,.T.,,.F.)
endif
return nil

**********************
function MonitCompra()
**********************
LOCAL MENU153:={{" Per¡odo     ","Monitoramento Por Per¡odo"    ,{||MCPeriodo()}},;
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
LOCAL MENU15:={{" Lan‡amento     ","Lan‡amento das Vendas Di rias  " ,{||MOVIMENTO()}},;
               {" Cancelamento   ","Cancelamento Vendas Di rias  "   ,{||CMOVIMENTO()}},;
               {" Monitoramento ","Monitoramento das Vendas Di rias",{||MonitVenda()}}}
LOCAL TelaMovVenda:=0
if TRotina(1)
   MENUBLOCK(6,12,MENU15,@TelaMovVenda,.T.,,.F.)
endif
return nil

**********************
function MonitVenda()
**********************
LOCAL MENU153:={{" Per¡odo   ","Monitoramento Por Per¡odo"   ,{||MVPeriodo()}},;
                {" Documento ","Monitoramento Por Documento" ,{||MDocumento()}},;
                {" Produto   ","Monitoramento Por Produto"   ,{||MProduto()}},;
                {" Opera‡„o  ","Monitoramento Por Operacao"  ,{||MOperacao()}},;
                {" Grupo     ","Monitoramento Por Grupo"     ,{||MGrupo()}}}
LOCAL TelaMonitVenda:=0
if TRotina(4)
   MENUBLOCK(10,22,MENU153,@TelaMonitVenda,.T.,,.F.)
endif
return nil

********************
function Cadastro()
********************
LOCAL MENU11:={{" Produtos     ","Cadastro de Produtos"          ,{||Cad_Pro()}},;
               {" Grupos       ","Cadastro de Grupos"            ,{||Cad_Grupo()}},;
               {" Un. de Medida","Cadastro Unidade de Medida"    ,{||Cad_UnMed()}},;
               {" Cargos       ","Cadastro de Cargos Funcinarios",{||Cad_Cargo()}},;
               {" Funcion rios ","Cadastro de Funcion rios"      ,{||Cad_Func()}},;
               {" Clientes     ","Cadastro de Clientes"          ,{||Cad_Cli()}},;
               {" Fornecedores ","Cadastro de Fornecedores"      ,{||Cad_For()}},;
               {" Opera‡”es    ","Cadastro de Opera‡”es"         ,{||Cad_Operacao()}}}
LOCAL telacadastro:=0
if TRotina(5)
   MENUBLOCK(7,12,MENU11,@TELACADASTRO,.T.,,.F.)
endif
return nil

********************
function RELATORIO()
********************
LOCAL MENU12:={{" Financeiro  ","Relat¢rios Financeiros"   ,{||RELA_FINANCEIRO()}},;
               {" Cadastro    ","Relat¢rios de Cadastro"   ,{||RELA_CADASTRO()}},;
               {" Estoque     ","Relat¢rios de Estoque"    ,{||RELA_ESTOQUE()}},;
               {" Estatistica ","Relat¢rios de Estatistica",{||RELA_ESTATISTICA()}}}
LOCAL TELARELATORIOS:=0
if TRotina(9)
   MENUBLOCK(9,12,MENU12,@TELARELATORIOS,.T.,,.F.)
endif
return nil

****************************
function RELA_FINANCEIRO()
****************************
LOCAL MENU122:={{" Fechamento do Caixa     ","Relat¢rio de Fechamento do Caixa"                 ,{||R_FIM_CAIXA()}},;
                {" Tabela Gerencial       ","Compara‡ao Entre Pre‡o de Venda e Pre‡o de Custo" ,{||LR_CPreco()}},;
                {" Venda Por Documento     ","Relat¢rio de Venda Por Documento"                 ,{||Venda_Documento()}},;
                {" Valoriza‡ao do Estoque ","Valoriza‡ao do Estoque Atual"                     ,{||LR_VEst()}},;
                {" Produtos com ICMS retido","Produtos com ICMS Retido"                         ,{||LR_ICMS_RETIDO()}},;
                {" Contas a Receber       ","Relat¢rio de Contas a Receber"                    ,{||R_ContasReceber()}},;
                {" Contas a Pagar          ","Relat¢rio de Contas a Pagar"                      ,{||R_CONTASP()}}}
LOCAL TELA_RELA_FINACEIRO:=0
MENUBLOCK(11,22,MENU122,@TELA_RELA_FINANCEIRO,.T.,,.F.)
return nil

*******************************
function R_ContasReceber()
*******************************
LOCAL MENU122:={{" Geral            ","Relat¢rio do Contas a Receber Por Cliente"        ,{||R_CONTASR(1)}},;
                {" Dias Sem Acerto  ","Relat¢rio de Dias Sem Acerto do Contas a Receber" ,{||R_CONTASR(2)}},;
                {" Extratificado    ","Relat¢rio de Contas a Receber Extratificado"      ,{||RCCLEXTRATIFICADO()}}}
//                {" Por Cliente     ","Relat¢rio de Contas a Receber Por Cliente "       ,{||R_CR_Cliente()}}}
LOCAL TELA_RELA_CR:=0
MENUBLOCK(17,44,MENU122,@TELA_RELA_CR,.T.,,.F.)
return nil

************************
function R_CR_Cliente()
************************
LOCAL MENU122:={{" Resumido ","Relat¢rio de Contas a Pagar Por Cliente        " ,{||R_CONTASRCL()}},;
                {" Todos    ","Relat¢rio de Contas a Pagar de Todos os Cliente" ,{||RCONTAS_CL()}}}
LOCAL TELA_RELA_CR:=0
MENUBLOCK(19,60,MENU122,@TELA_RELA_CR,.T.,,.F.)
return nil

*********************
function LR_VEst()
*********************
LOCAL MENU1224:={{" C¢digo ","Valoriza‡ao do Estoque Atual Classif. Por C¢digo" ,{||LR_VESTOQUE(1)}},;
                 {" Nome   ","Valoriza‡ao do Estoque Atual Classif. Por Nome"   ,{||LR_VESTOQUE(2)}}}
LOCAL T_R_VALORIZ_ESTOQUE:=0
MENUBLOCK(16,45,MENU1224,@T_R_VALORIZ_ESTOQUE,.T.,,.F.)
return nil

****************************
function LR_CPreco()
****************************
LOCAL MENU1223:={{" C¢digo ","Comp. Entre Pre‡o Venda e de Custo Classif. Por C¢digo",{||LR_CUSTO_PRODUTO(1)}},;
                 {" Nome   ","Comp. Entre Pre‡o Venda e de Custo Classif. Por Nome"  ,{||LR_CUSTO_PRODUTO(2)}}}
LOCAL T_R_TABELA_GERENCIAL:=0
MENUBLOCK(14,45,MENU1223,@T_R_TABELA_GERENCIAL,.T.,,.F.)
return nil

****************************
function RELA_CADASTRO()
****************************
LOCAL MENU122:={{" Listagem de Pre‡o   ","Rela‡„o de Pre‡o de Venda"       ,{||LR_LPreco()}},;
                {" Listagem de Grupo   ","Rela‡„o de Cadastro de Grupos"   ,{||LR_CGrupo()}},;
                {" Listagem de Cliente ","Rela‡„o de Cadastro de Clientes" ,{||LR_CCliente()}},;
                {" Cliente por C¢digo   ","Rela‡„o de Clientes Por C¢digo"  ,{||Rel_Cliente()}},;
                {" Produto Por Grupo    ","Rela‡„o de Produto Por Grupo"    ,{||LR_CPRODUTO()}}}
LOCAL TELA_RELA_CADASTRO:=0
MENUBLOCK(12,25,MENU122,@TELA_RELA_CADASTRO,.T.,,.F.)
return nil

**********************
function LR_CCliente()
**********************
LOCAL MENU1222:={{" C¢digo ","Rela‡„o de Cadastro de Cliente Classificado Por C¢digo" ,{||Rel_CCliente(1)}},;
                 {" Nome   ","Rela‡„o de Cadastro de Cliente Classificado Por Nome"   ,{||Rel_CCliente(2)}}}
LOCAL T_R_LCliente:=0
MENUBLOCK(16,45,MENU1222,@T_R_LCliente,.T.,,.F.)
return nil

**********************
function LR_CGrupo()
**********************
LOCAL MENU1222:={{" C¢digo ","Rela‡„o de Cadastro de Grupo Classificado Por C¢digo" ,{||Rel_CGRUPO(1)}},;
                 {" Nome   ","Rela‡„o de Cadastro de Grupo Classificado Por Nome"   ,{||Rel_CGRUPO(2)}}}
LOCAL T_R_LPRECO:=0
MENUBLOCK(15,45,MENU1222,@T_R_LPRECO,.T.,,.F.)
return nil

****************************
function LR_LPreco()
****************************
LOCAL MENU1222:={{" C¢digo ","Rela‡„o de Pre‡o de Venda Classificado Por C¢digo" ,{||LR_PRODUTO(1)}},;
                 {" Nome   ","Rela‡„o de Pre‡o de Venda Classificado Por Nome"   ,{||LR_PRODUTO(2)}}}
LOCAL T_R_LPRECO:=0
MENUBLOCK(14,45,MENU1222,@T_R_LPRECO,.T.,,.F.)
return nil

***********************
function RELA_ESTOQUE()
***********************
LOCAL MENU121:={{" Atual          ","Posi‡„o do Estoque Atual",                           {||LR_REST_ATUAL()}},;
                {" M¡nimo         ","Rela‡„o dos Produtos Com o Estoque Abaixo do M¡nimo",{||LR_REST_MIN()}},;
                {" Nao Controlado ","Rela‡„o dos Produtos Que Nao Controla Estoque"      ,{||LR_REST_NCON()}},;
                {" Por Grupo      ","Rela‡„o dos Estoque Por Grupo"                      ,{||LR_REST_GPROD()}}}
LOCAL TELA_RELA_ESTOQUE:=0
MENUBLOCK(13,22,MENU121,@TELA_RELA_ESTOQUE,.T.,,.F.)
return nil

****************************
function LR_REST_GPROD()
****************************
LOCAL MENU1212:={{" Resumido ","Rel. Resumido da Rela‡„o dos Estoque Por Grupo" ,{||RESTOQUE_GP(1)}},;
                 {" Todos    ","Rel. Total da Rela‡„o dos Estoque Por Grupo"    ,{||RESTOQUE_GP(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(18,35,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function LR_REST_MIN()
****************************
LOCAL MENU1212:={{" C¢digo ","Rel. Prod. C/ o Est. Abaixo do M¡n. Classif. Por C¢digo" ,{||RESTOQUE(3,1)}},;
                 {" Nome   ","Rel. Prod. C/ o Est. Abaixo do M¡n. Classif. Por Nome"   ,{||RESTOQUE(3,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(16,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function LR_REST_NCON()
****************************
LOCAL MENU1212:={{" C¢digo ","Rela‡„o dos Produtos Que Nao Controla Estoque Classif. Por C¢digo" ,{||RESTOQUE(2,1)}},;
                 {" Nome   ","Rela‡„o dos Produtos Que Nao Controla Estoque Classif. Por Nome"   ,{||RESTOQUE(2,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(17,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

*******************************
function LR_REST_ATUAL()
*******************************
LOCAL MENU1212:={{" C¢digo ","Posi‡„o do Estoque Atual Classif. Por C¢digo" ,{||RESTOQUE(1,1)}},;
                 {" Nome   ","Posi‡„o do Estoque Atual Classif. Por Nome"   ,{||RESTOQUE(1,2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(15,38,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

****************************
function RELA_ESTATISTICA()
****************************
LOCAL MENU123:={{" Produto     ","Estatistica das Vendas Por Produtos"     ,{||LR_EST_PRODUTO()}},;
                {" Grupo       ","Estatistica das Vendas Por Grupos"       ,{||LR_EST_GRUPO()}},;
                {" Funcion rio ","Estatistica das Vendas Por Funcion rio"  ,{||LR_EST_FUNC()}},;
                {" Venda        ","Estatistica das Vendas A Vista / A Prazo",{||Real_CAIXA()}}}
LOCAL TELA_RELA_ESTATISTICA:=0
MENUBLOCK(14,22,MENU123,@TELA_RELA_ESTATISTICA,.T.,,.F.)
return nil

**************************
function LR_EST_GRUPO()
**************************
LOCAL MENU1212:={{" C¢digo ","Estatistica das Vendas Por Grupos Classif. Por C¢digo" ,{||CR_GRUPO(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Grupos Classif. Por Nome"   ,{||CR_GRUPO(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(17,34,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

**************************
function LR_EST_PRODUTO()
**************************
LOCAL MENU1212:={{" C¢digo ","Estatistica das Vendas Por Produtos Classif. Por C¢digo" ,{||CR_PRODUTO(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Produtos Classif. Por Nome"   ,{||CR_PRODUTO(2)}}}
LOCAL T_R_RESTOQUE_MIN:=0
MENUBLOCK(16,34,MENU1212,@T_R_RESTOQUE_MIN,.T.,,.F.)
return nil

***********************
function LR_EST_FUNC()
***********************
LOCAL MENU1212:={{" C¢digo ","Estatistica das Vendas Por Funcion rio Classif. Por C¢digo" ,{||CR_FUNC(1)}},;
                 {" Nome   ","Estatistica das Vendas Por Funcion rio Classif. Por Nome"   ,{||CR_FUNC(2)}}}
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
 if ALERT("Abandona Sistema ?",{"Sim","N„o"}) == 1
    setcolor("w/n")
    cls
    quit
 Else
   MAIN()
 endif
Return nil
