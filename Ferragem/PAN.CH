//# DEFINE FIRMA                  "Eletrofer"
# DEFINE FIRMA                  "CONEFER Ferragens Conexäes Ltda."
// # DEFINE FIRMA               "Panificadora O P„o Nosso"
# DEFINE MSG_FALTA_ARQUIVO      "Falta arquivo entre em contato com o suporte!"
# DEFINE MSG_GRAVA_TERMINADA    "Grava‡„o terminada.;Tecle algo para continuar."
# DEFINE MSG_EXCLUSAO           "Exclus„o terminada.;Tecle algo para continuar."
# DEFINE MSG_IMPOSSIVEL_EXCLUIR "C¢digo impossivel de excluir.; Tecle algo para continuar."
# DEFINE MSG_CONFIRMA_S_N       "Confirma (S/N)?"
# DEFINE MSG_AGUARDE_IMP        "Aguarde imprimindo relat¢rio!"
# DEFINE MSG_IMPRESSAO_COMPLETA "Impress„o completa.;Tecle algo para continuar."
# DEFINE MSG_GRAVA_S_N          "Grava (S/N) ou Exclui (E)?"
# DEFINE PICT_PRECO_VENDA       pict "99,999,999.99"
# DEFINE MSG_CODIGO_INEXISTENTE "C¢digo inexistente.; Tecle algo para continuar."
# DEFINE FRAME1 "ÚÄ¿³ÙÄÀ³²"
# DEFINE FRAME2 "ÉÍ»º¼ÍÈº°"

# COMMAND ESC OUT  => IF LASTKEY()=27 ; EXIT ; ENDIF

*****
* Comando...: OPEN <expC1> [ALIAS <expC2>] [INDEX <expC3,expCn>]
*             [EXCLUSIVE/SHARED] [ALIAS] [READONLY] [FOREVER]
* Sintaxe...:
* Objetivo..: abrir um arquivo em rede na proxima area de buffer disponivel
*             verificando se houve sucesso na abertura. Se nao houve
*             sucesso, fecha os arquivos anteriores e retorna a procedure
*             chamadora
* Parametros: <expC1> e o nome do arquivo a ser aberto
*             <expC2> e um alias para o arquivo
*             <expC3> a
*             <expCn) indices a serem abertos (ate 15)
* Opcoes....: EXCLUSIVE/SHARED indicam se o arquivo sera aberto em modo
*             compartilhado ou exclusivo
*             READONLY abre o arquivo somente para leitura
*             FOREVER  indica que serao feitas tentativas de abrir o arquivo
*             ate ser obtido sucesso. O default e aproximadamente dois
*             segundos
*

#command OPEN <(db)> [ALIAS <a>] ;
         [<ex: EXCLUSIVE>] [<sh: SHARED>] [<ro: READONLY>] [<fo: FOREVER>] ;
         [INDEX <(index1)> [, <(indexn)>]] ;
=> ;
         seconds := 3 ;
         ; while (<.fo.> .or. seconds > 0) ;
            ; __dbUse(.T., NIL, <(db)>, <(a)>, if(<.sh.> .or. <.ex.>, !<.ex.>, NIL), <.ro.> ) ;
            ; if ! neterr() ;
               [; __dbSetIndex( <(index1)> )] ;
               [; __dbSetIndex( <(indexn)> )] ;
               ; exit ;
            ; end ;
            ; inkey(1) ;
            ; --seconds ;
         ; end ;
         ; if neterr() ;
            ; __dbCloseAll() ;
            ; tlant=SAVESCREEN(14,13,18,60);
            ; RESTSCREEN(14,13,18,60,tlant);
            ; inkey(3) ;
            ; return ;
         ; end

*
* EOCom OPEN
*****

