*---------------------------------------------------------------------*
*    program for:   TABLEFRAME_YTRT00002
*---------------------------------------------------------------------*
FUNCTION TABLEFRAME_YTRT00002          .

  PERFORM TABLEFRAME TABLES X_HEADER X_NAMTAB DBA_SELLIST DPL_SELLIST
                            EXCL_CUA_FUNCT
                     USING  CORR_NUMBER VIEW_ACTION VIEW_NAME.

ENDFUNCTION.
