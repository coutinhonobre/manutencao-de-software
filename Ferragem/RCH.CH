# COMMAND ESC OUT  => IF LASTKEY()=27 ; EXIT ; ENDIF

# COMMAND ESCNIL => IF LASTKEY()=27 ; RETURN NIL ; ENDIF

# COMMAND SELECIONE <XAREA> PARA <XORDEM>  => ;
                        dbselectarea(<(XAREA)>) ;  ordsetfocus(<(XORDEM)>)

# COMMAND SELECT <XAREA> [<XORDEM>]  => ;
                        dbselectarea(<(XAREA)>) ; [ordsetfocus(<(XORDEM)>)]

