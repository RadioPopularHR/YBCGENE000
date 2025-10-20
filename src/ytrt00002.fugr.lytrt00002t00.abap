*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: YTRT00002.......................................*
DATA:  BEGIN OF STATUS_YTRT00002                     .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_YTRT00002                     .
CONTROLS: TCTRL_YTRT00002
            TYPE TABLEVIEW USING SCREEN '0001'.
*.........table declarations:.................................*
TABLES: *YTRT00002                     .
TABLES: YTRT00002                      .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
