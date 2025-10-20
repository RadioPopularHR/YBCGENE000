*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00005.......................................*
DATA:  BEGIN OF STATUS_YTRE00005                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00005                     .
CONTROLS: TCTRL_YTRE00005
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *YTRE00005                     .
TABLES: YTRE00005                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
