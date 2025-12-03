*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00007.......................................*
DATA:  BEGIN OF STATUS_YTRE00007                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00007                     .
CONTROLS: TCTRL_YTRE00007
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTRE00007                     .
TABLES: YTRE00007                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
