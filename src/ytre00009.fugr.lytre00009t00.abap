*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00009.......................................*
DATA:  BEGIN OF STATUS_YTRE00009                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00009                     .
CONTROLS: TCTRL_YTRE00009
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTRE00009                     .
TABLES: YTRE00009                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
