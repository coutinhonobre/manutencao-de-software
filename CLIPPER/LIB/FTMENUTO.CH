/*
 * File......: TMENU.CH
 * Author....: Ted Means
 * Date......: $Date:   02 Apr 1991 18:26:20  $
 * Revision..: $Revision:   1.0  $
 * Log file..: $Logfile:   E:/nanfor/src/ftmenuto.chv  $
 * 
 * This is an original work by Ted Means and is placed in the
 * public domain.
 *
 * Modification history:
 * ---------------------
 *
 * $Log:   E:/nanfor/src/ftmenuto.chv  $
 *  
 *    Rev 1.0   02 Apr 1991 18:26:20   GLENN
 *  Nanforum Toolkit
 *
 */

/* These commands will simplify use of the FT_ATPROMPT() and
   FT_MENUTO() functions.  Refer to ATPROMPT.PRG and MENUTO.PRG
   These commands should replace the existing Clipper @ PROMPT / 
   MENU TO commands */

#command @ <PrRow>, <PrCol> PROMPT <Prompt>                     ;
                            [PROMPTCOLOR <PrAttr>]              ;
                            [MESSAGE <Message>]                 ;
                            [MSGROW <MsgRow>]                   ;
                            [MSGCOL <MsgCol>]                   ;
                            [MSGCOLOR <MsgColor>]               ;
                            [HOTKEY <HotKey>]                   ;
                            [HOTKEYCOLOR <HColor>]              ;
                            [BARCOLOR <BColor>]                 ;
                            [BARHOTKEYCOLOR <BHKColor>]         ;
                            [UP <Up>]                           ;
                            [DOWN <Down>]                       ;
                            [RIGHT <Right>]                     ;
                            [LEFT <Left>]                       ;
      => FT_Prompt( <PrRow>,  <PrCol>,  <Prompt>, <(PrAttr)>,   ;
         <MsgRow>, <MsgCol>, <Message>, <(MsgColor)>,           ;
         <HotKey>, <(HColor)>, <(BColor)>, <(BHKColor)>,        ;
         <Up>, <Down>, <Right>, <Left> )

#command MENU TO <v> [<SFlag: NOSNOW>] [<KFlag: KEEP>] [<CFlag: COLD>] ;
      => <v> := FT_MenuTo( {|_1| IIF( _1 == NIL, <v>, <v> := _1 ) },   ;
                           #<v>, <.SFlag.>, <.KFlag.>, <.CFlag.>       ;
                         )
                                   