/***
* Getdur.ch
*
* @ GET During command.
*/

#command @ <row>, <col> GET <var>                                   ;
                        [<clauses,...>]                             ;
                        DURING <b> EVERY <n>                        ;
                        [<moreClauses,...>]                         ;
                                                                    ;
    => @ <row>, <col> GET <var>                                     ;
                      [<clauses>]                                   ;
                      SEND reader := {|oGet|                        ;
                                      GetDuring(oGet, <{b}>, <n>) } ;
                      [<moreClauses>]
