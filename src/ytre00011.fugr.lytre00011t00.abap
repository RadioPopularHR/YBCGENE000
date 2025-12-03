*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRE00011.......................................*
DATA:  BEGIN OF STATUS_YTRE00011                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRE00011                     .
CONTROLS: TCTRL_YTRE00011
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *YTRE00011                     .
TABLES: YTRE00011                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
