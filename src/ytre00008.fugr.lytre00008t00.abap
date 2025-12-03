*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00008.......................................*
DATA:  BEGIN OF STATUS_YTRE00008                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00008                     .
CONTROLS: TCTRL_YTRE00008
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTRE00008                     .
TABLES: YTRE00008                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
