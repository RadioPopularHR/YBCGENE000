*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTFI00013.......................................*
DATA:  BEGIN OF STATUS_YTFI00013                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTFI00013                     .
CONTROLS: TCTRL_YTFI00013
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTFI00013                     .
TABLES: YTFI00013                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
