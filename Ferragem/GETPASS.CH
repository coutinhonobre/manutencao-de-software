/***
* Getpass.ch
*
* Definition of GET PASSWORD command.
*/

#command @ <row>, <col> GET <var>                                ;
                        [<clauses,...>]                          ;
                        PASSWORD                                 ;
                        [<moreClauses,...>]                      ;
                                                                 ;
      => @ <row>, <col> GET <var>                                ;
                        [<clauses>]                              ;
                        SEND reader := {|oGet|                   ;
                                        GetPassword(oGet) }      ;
                        [<moreClauses>]

