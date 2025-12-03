*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00010.......................................*
DATA:  BEGIN OF STATUS_YTRE00010                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00010                     .
CONTROLS: TCTRL_YTRE00010
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTRE00010                     .
TABLES: YTRE00010                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
