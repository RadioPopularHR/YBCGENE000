*&---------------------------------------------------------------------*
*& Report  YRE00014INTJP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT yre00014intjp NO STANDARD PAGE HEADING MESSAGE-ID yac.

TABLES: ytrt1001, ytrt1002, ytrt1003, ytrt1004, ytrt1005, ytrt1006,
        ytrt1007, ytrt1008, ytrt1009, ytrt1010, ytrt1011, ytrt1012,
        ytrt1013, t001k.

DATA: gt_ytrt1001 LIKE TABLE OF ytrt1001 WITH HEADER LINE,
      gt_ytrt1002 LIKE TABLE OF ytrt1002 WITH HEADER LINE,
      gt_ytrt1003 LIKE TABLE OF ytrt1003 WITH HEADER LINE,
      gt_ytrt1004 LIKE TABLE OF ytrt1004 WITH HEADER LINE,
      gt_ytrt1005 LIKE TABLE OF ytrt1005 WITH HEADER LINE,
      gt_ytrt1006 LIKE TABLE OF ytrt1006 WITH HEADER LINE,
      gt_ytrt1007 LIKE TABLE OF ytrt1007 WITH HEADER LINE,
      gt_ytrt1008 LIKE TABLE OF ytrt1008 WITH HEADER LINE,
      gt_ytrt1009 LIKE TABLE OF ytrt1009 WITH HEADER LINE,
      gt_ytrt1010 LIKE TABLE OF ytrt1010 WITH HEADER LINE,
      gt_ytrt1011 LIKE TABLE OF ytrt1011 WITH HEADER LINE,
      gt_ytrt1012 LIKE TABLE OF ytrt1012 WITH HEADER LINE,
      gt_ytrt1013 LIKE TABLE OF ytrt1013 WITH HEADER LINE.

DATA: new1001 LIKE ytrt1001 OCCURS 0 WITH HEADER LINE,
      new1002 LIKE ytrt1002 OCCURS 0 WITH HEADER LINE,
      new1003 LIKE ytrt1003 OCCURS 0 WITH HEADER LINE,
      new1004 LIKE ytrt1004 OCCURS 0 WITH HEADER LINE,
      new1005 LIKE ytrt1005 OCCURS 0 WITH HEADER LINE,
      new1006 LIKE ytrt1006 OCCURS 0 WITH HEADER LINE,
      new1007 LIKE ytrt1007 OCCURS 0 WITH HEADER LINE,
      new1008 LIKE ytrt1008 OCCURS 0 WITH HEADER LINE,
      new1009 LIKE ytrt1009 OCCURS 0 WITH HEADER LINE,
      new1010 LIKE ytrt1010 OCCURS 0 WITH HEADER LINE,
      new1011 LIKE ytrt1011 OCCURS 0 WITH HEADER LINE,
      new1012 LIKE ytrt1012 OCCURS 0 WITH HEADER LINE,
      new1013 LIKE ytrt1013 OCCURS 0 WITH HEADER LINE.

DATA: lv_tabix LIKE sy-tabix.

RANGES: wa_werks FOR ytrt1001-werks.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS  p_spmon TYPE spmon OBLIGATORY.
SELECT-OPTIONS: so_werks FOR ytrt1001-werks NO INTERVALS NO-EXTENSION OBLIGATORY,
                sd_werks FOR ytrt1001-werks OBLIGATORY.
SELECTION-SCREEN END OF BLOCK b1.

DEFINE val_duplicar.

  select *
    into corresponding fields of table &1
    from &2
    where werks     in so_werks
      and spmon     eq p_spmon
      and eliminado eq ''
      and desactivo eq ''.

END-OF-DEFINITION.

DEFINE copiar_valores.

  loop at &1.
    move-corresponding &1 to &2.
    move-corresponding sy to &2.
    &2-werks = &3.
    append &2. clear &2.
  endloop.

END-OF-DEFINITION.

DEFINE ler_valores.

  select *
    into corresponding fields of table &1
    from &2
    where spmon eq p_spmon
      and werks in sd_werks.

END-OF-DEFINITION.

DEFINE delete_val.

  delete &1 where eliminado eq 'X'.
  delete &1 where desactivo eq 'X'.

END-OF-DEFINITION.

START-OF-SELECTION.

  DATA: lv_txt(50) TYPE c,
        lv_answer(1).

  CONCATENATE 'As lojas serão criadas por cópia da' so_werks-low
    INTO lv_txt SEPARATED BY space.
  CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
    EXPORTING
      defaultoption = 'N'
      textline1     = lv_txt
      textline2     = 'Deseja continuar?'
      titel         = 'Aviso'
      start_column  = 25
      start_row     = 6
    IMPORTING
      answer        = lv_answer.
  IF lv_answer EQ 'J'.

    REFRESH wa_werks. CLEAR wa_werks.
*    wa_werks-sign = 'I'.
*    wa_werks-option = 'EQ'.
*    SELECT werks
*      INTO wa_werks-low
*      FROM t001w.
*      CHECK wa_werks-low IN sd_werks.
*      APPEND wa_werks.
*    ENDSELECT.

    select werks as low into corresponding fields of table wa_werks
      from t001w
     where werks in sd_werks.
    wa_werks-sign = 'I'.
    wa_werks-option = 'EQ'.
    modify wa_werks from wa_werks transporting sign option
     where sign = space.

    CLEAR wa_werks.

* ler valores para centro de origem
    val_duplicar gt_ytrt1001 ytrt1001.
    val_duplicar gt_ytrt1002 ytrt1002.
    val_duplicar gt_ytrt1003 ytrt1003.
    val_duplicar gt_ytrt1004 ytrt1004.
    val_duplicar gt_ytrt1005 ytrt1005.
    val_duplicar gt_ytrt1006 ytrt1006.
    val_duplicar gt_ytrt1007 ytrt1007.
    val_duplicar gt_ytrt1008 ytrt1008.
    val_duplicar gt_ytrt1009 ytrt1009.
    val_duplicar gt_ytrt1010 ytrt1010.
    val_duplicar gt_ytrt1011 ytrt1011.
    val_duplicar gt_ytrt1012 ytrt1012.
    val_duplicar gt_ytrt1013 ytrt1013.

    perform delete_source_duplicates.

* duplicar valores do centro de origem para os centros de destino
    LOOP AT wa_werks.
      copiar_valores gt_ytrt1001 new1001 wa_werks-low.
      copiar_valores gt_ytrt1002 new1002 wa_werks-low.
      copiar_valores gt_ytrt1003 new1003 wa_werks-low.
      copiar_valores gt_ytrt1004 new1004 wa_werks-low.
      copiar_valores gt_ytrt1005 new1005 wa_werks-low.
      copiar_valores gt_ytrt1006 new1006 wa_werks-low.
      copiar_valores gt_ytrt1007 new1007 wa_werks-low.
      copiar_valores gt_ytrt1008 new1008 wa_werks-low.
      copiar_valores gt_ytrt1009 new1009 wa_werks-low.
      copiar_valores gt_ytrt1010 new1010 wa_werks-low.
      copiar_valores gt_ytrt1011 new1011 wa_werks-low.
      copiar_valores gt_ytrt1012 new1012 wa_werks-low.
      copiar_valores gt_ytrt1013 new1013 wa_werks-low.
    ENDLOOP.

* limpar tabelas
    REFRESH: gt_ytrt1001, gt_ytrt1002, gt_ytrt1003,
             gt_ytrt1004, gt_ytrt1005, gt_ytrt1006,
             gt_ytrt1007, gt_ytrt1008, gt_ytrt1009,
             gt_ytrt1010, gt_ytrt1011, gt_ytrt1012,
             gt_ytrt1013.
    CLEAR:   gt_ytrt1001, gt_ytrt1002, gt_ytrt1003,
             gt_ytrt1004, gt_ytrt1005, gt_ytrt1006,
             gt_ytrt1007, gt_ytrt1008, gt_ytrt1009,
             gt_ytrt1010, gt_ytrt1011, gt_ytrt1012,
             gt_ytrt1013.

* ler tabelas eliminando linhas eliminadas e desactivas
    ler_valores gt_ytrt1001 ytrt1001. delete_val gt_ytrt1001.
    ler_valores gt_ytrt1002 ytrt1002. delete_val gt_ytrt1002.
    ler_valores gt_ytrt1003 ytrt1003. delete_val gt_ytrt1003.
    ler_valores gt_ytrt1004 ytrt1004. delete_val gt_ytrt1004.
    ler_valores gt_ytrt1005 ytrt1005. delete_val gt_ytrt1005.
    ler_valores gt_ytrt1006 ytrt1006. delete_val gt_ytrt1006.
    ler_valores gt_ytrt1007 ytrt1007. delete_val gt_ytrt1007.
    ler_valores gt_ytrt1008 ytrt1008. delete_val gt_ytrt1008.
    ler_valores gt_ytrt1009 ytrt1009. delete_val gt_ytrt1009.
    ler_valores gt_ytrt1010 ytrt1010. delete_val gt_ytrt1010.
    ler_valores gt_ytrt1011 ytrt1011. delete_val gt_ytrt1011.
    ler_valores gt_ytrt1012 ytrt1012. delete_val gt_ytrt1012.
    ler_valores gt_ytrt1013 ytrt1013. delete_val gt_ytrt1013.

* verificar se existem chaves duplicadas nas tabelas
* a tabela gt_ytrt1001 fica com as linhas a eliminar da base de dados
    LOOP AT gt_ytrt1001.
      lv_tabix = sy-tabix.
      READ TABLE new1001 WITH KEY spmon = gt_ytrt1001-spmon
                                  werks = gt_ytrt1001-werks
                                  zzwgru3 = gt_ytrt1001-zzwgru3
                                  ycond   = gt_ytrt1001-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1001.
        MOVE-CORRESPONDING gt_ytrt1001 TO new1001.
        new1001-desactivo = 'X'.
        new1001-eliminado = 'X'.
        APPEND new1001.
      ELSE.
        DELETE gt_ytrt1001 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1001 BY spmon ASCENDING
                    werks ASCENDING
                    zzwgru3 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1001 FROM TABLE gt_ytrt1001.
    INSERT ytrt1001 FROM TABLE new1001.

    LOOP AT gt_ytrt1002.
      lv_tabix = sy-tabix.
      READ TABLE new1002 WITH KEY spmon = gt_ytrt1002-spmon
                                  werks = gt_ytrt1002-werks
                                  zzwgru2 = gt_ytrt1002-zzwgru2
                                  ycond   = gt_ytrt1002-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1002.
        MOVE-CORRESPONDING gt_ytrt1002 TO new1002.
        new1002-desactivo = 'X'.
        new1002-eliminado = 'X'.
        APPEND new1002.
      ELSE.
        DELETE gt_ytrt1002 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1002 BY spmon ASCENDING
                    werks ASCENDING
                    zzwgru2 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1002 FROM TABLE gt_ytrt1002.
    INSERT ytrt1002 FROM TABLE new1002.

    LOOP AT gt_ytrt1003.
      lv_tabix = sy-tabix.
      READ TABLE new1003 WITH KEY spmon = gt_ytrt1003-spmon
                                  werks = gt_ytrt1003-werks
                                  zzwgru1 = gt_ytrt1003-zzwgru1
                                  ycond   = gt_ytrt1003-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1003.
        MOVE-CORRESPONDING gt_ytrt1003 TO new1003.
        new1003-desactivo = 'X'.
        new1003-eliminado = 'X'.
        APPEND new1003.
      ELSE.
        DELETE gt_ytrt1003 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1003 BY spmon ASCENDING
                    werks ASCENDING
                    zzwgru1 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1003 FROM TABLE gt_ytrt1003.
    INSERT ytrt1003 FROM TABLE new1003.

    LOOP AT gt_ytrt1004.
      lv_tabix = sy-tabix.
      READ TABLE new1004 WITH KEY spmon = gt_ytrt1004-spmon
                                  werks = gt_ytrt1004-werks
                                  matkl = gt_ytrt1004-matkl
                                  ycond = gt_ytrt1004-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1004.
        MOVE-CORRESPONDING gt_ytrt1004 TO new1004.
        new1004-desactivo = 'X'.
        new1004-eliminado = 'X'.
        APPEND new1004.
      ELSE.
        DELETE gt_ytrt1004 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1004 BY spmon ASCENDING
                    werks ASCENDING
                    matkl ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1004 FROM TABLE gt_ytrt1004.
    INSERT ytrt1004 FROM TABLE new1004.

    LOOP AT gt_ytrt1005.
      lv_tabix = sy-tabix.
      READ TABLE new1005 WITH KEY spmon = gt_ytrt1005-spmon
                                  werks = gt_ytrt1005-werks
                                  prdha = gt_ytrt1005-prdha
                                  zzwgru3 = gt_ytrt1005-zzwgru3
                                  ycond   = gt_ytrt1005-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1005.
        MOVE-CORRESPONDING gt_ytrt1005 TO new1005.
        new1005-desactivo = 'X'.
        new1005-eliminado = 'X'.
        APPEND new1005.
      ELSE.
        DELETE gt_ytrt1005 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1005 BY spmon ASCENDING
                    werks ASCENDING
                    prdha ASCENDING
                    zzwgru3 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1005 FROM TABLE gt_ytrt1005.
    INSERT ytrt1005 FROM TABLE new1005.

    LOOP AT gt_ytrt1006.
      lv_tabix = sy-tabix.
      READ TABLE new1006 WITH KEY spmon = gt_ytrt1006-spmon
                                  werks = gt_ytrt1006-werks
                                  prdha = gt_ytrt1006-prdha
                                  zzwgru2 = gt_ytrt1006-zzwgru2
                                  ycond   = gt_ytrt1006-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1006.
        MOVE-CORRESPONDING gt_ytrt1006 TO new1006.
        new1006-desactivo = 'X'.
        new1006-eliminado = 'X'.
        APPEND new1006.
      ELSE.
        DELETE gt_ytrt1006 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1006 BY spmon ASCENDING
                    werks ASCENDING
                    prdha ASCENDING
                    zzwgru2 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1006 FROM TABLE gt_ytrt1006.
    INSERT ytrt1006 FROM TABLE new1006.

    LOOP AT gt_ytrt1007.
      lv_tabix = sy-tabix.
      READ TABLE new1007 WITH KEY spmon = gt_ytrt1007-spmon
                                  werks = gt_ytrt1007-werks
                                  prdha = gt_ytrt1007-prdha
                                  zzwgru1 = gt_ytrt1007-zzwgru1
                                  ycond   = gt_ytrt1007-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1007.
        MOVE-CORRESPONDING gt_ytrt1007 TO new1007.
        new1007-desactivo = 'X'.
        new1007-eliminado = 'X'.
        APPEND new1007.
      ELSE.
        DELETE gt_ytrt1007 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1007 BY spmon ASCENDING
                    werks ASCENDING
                    prdha ASCENDING
                    zzwgru1 ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1007 FROM TABLE gt_ytrt1007.
    INSERT ytrt1007 FROM TABLE new1007.

    LOOP AT gt_ytrt1008.
      lv_tabix = sy-tabix.
      READ TABLE new1008 WITH KEY spmon = gt_ytrt1008-spmon
                                  werks = gt_ytrt1008-werks
                                  prdha = gt_ytrt1008-prdha
                                  matkl = gt_ytrt1008-matkl
                                  ycond = gt_ytrt1008-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1008.
        MOVE-CORRESPONDING gt_ytrt1008 TO new1008.
        new1008-desactivo = 'X'.
        new1008-eliminado = 'X'.
        APPEND new1008.
      ELSE.
        DELETE gt_ytrt1008 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1008 BY spmon ASCENDING
                    werks ASCENDING
                    prdha ASCENDING
                    matkl ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1008 FROM TABLE gt_ytrt1008.
    INSERT ytrt1008 FROM TABLE new1008.

    LOOP AT gt_ytrt1009.
      lv_tabix = sy-tabix.
      READ TABLE new1009 WITH KEY spmon = gt_ytrt1009-spmon
                                  werks = gt_ytrt1009-werks
                                  prdha = gt_ytrt1009-prdha
                                  ycond = gt_ytrt1009-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1009.
        MOVE-CORRESPONDING gt_ytrt1009 TO new1009.
        new1009-desactivo = 'X'.
        new1009-eliminado = 'X'.
        APPEND new1009.
      ELSE.
        DELETE gt_ytrt1009 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1009 BY spmon ASCENDING
                    werks ASCENDING
                    prdha ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1009 FROM TABLE gt_ytrt1009.
    INSERT ytrt1009 FROM TABLE new1009.

    LOOP AT gt_ytrt1010.
      lv_tabix = sy-tabix.
      READ TABLE new1010 WITH KEY spmon = gt_ytrt1010-spmon
                                  werks = gt_ytrt1010-werks
                                  matnr = gt_ytrt1010-matnr
                                  ycond = gt_ytrt1010-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1010.
        MOVE-CORRESPONDING gt_ytrt1010 TO new1010.
        new1010-desactivo = 'X'.
        new1010-eliminado = 'X'.
        APPEND new1010.
      ELSE.
        DELETE gt_ytrt1010 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1010 BY spmon ASCENDING
                    werks ASCENDING
                    matnr ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1010 FROM TABLE gt_ytrt1010.
    INSERT ytrt1010 FROM TABLE new1010.

    LOOP AT gt_ytrt1011.
      lv_tabix = sy-tabix.
      READ TABLE new1011 WITH KEY spmon = gt_ytrt1011-spmon
                                  werks = gt_ytrt1011-werks
                                  ycond = gt_ytrt1011-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1011.
        MOVE-CORRESPONDING gt_ytrt1011 TO new1011.
        new1011-desactivo = 'X'.
        new1011-eliminado = 'X'.
        APPEND new1011.
      ELSE.
        DELETE gt_ytrt1011 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1011 BY spmon ASCENDING
                    werks ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1011 FROM TABLE gt_ytrt1011.
    INSERT ytrt1011 FROM TABLE new1011.

    LOOP AT gt_ytrt1012.
      lv_tabix = sy-tabix.
      READ TABLE new1012 WITH KEY spmon = gt_ytrt1012-spmon
                                  werks = gt_ytrt1012-werks
                                  zzsfac = gt_ytrt1012-zzsfac
                                  ycond  = gt_ytrt1012-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1012.
        MOVE-CORRESPONDING gt_ytrt1012 TO new1012.
        new1012-desactivo = 'X'.
        new1012-eliminado = 'X'.
        APPEND new1012.
      ELSE.
        DELETE gt_ytrt1012 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1012 BY spmon ASCENDING
                    werks ASCENDING
                    zzsfac ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1012 FROM TABLE gt_ytrt1012.
    INSERT ytrt1012 FROM TABLE new1012.

    LOOP AT gt_ytrt1013.
      lv_tabix = sy-tabix.
      READ TABLE new1013 WITH KEY spmon = gt_ytrt1013-spmon
                                  werks = gt_ytrt1013-werks
                                  zest_art = gt_ytrt1013-zest_art
                                  ycond   = gt_ytrt1013-ycond.
      IF sy-subrc EQ 0.
        CLEAR new1013.
        MOVE-CORRESPONDING gt_ytrt1013 TO new1013.
        new1013-desactivo = 'X'.
        new1013-eliminado = 'X'.
        APPEND new1013.
      ELSE.
        DELETE gt_ytrt1013 INDEX lv_tabix.
      ENDIF.
    ENDLOOP.
    SORT new1013 BY spmon ASCENDING
                    werks ASCENDING
                    zest_art ASCENDING
                    ycond ASCENDING.
    DELETE ytrt1013 FROM TABLE gt_ytrt1013.
    INSERT ytrt1013 FROM TABLE new1013.

    MESSAGE i000 WITH 'Valores transferidos com sucesso.'.

  ENDIF.
*&---------------------------------------------------------------------*
*&      Form  DELETE_SOURCE_DUPLICATES
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form DELETE_SOURCE_DUPLICATES .
  SORT gt_ytrt1001 BY spmon ASCENDING
                      werks ASCENDING
                      zzwgru3 ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1001
    comparing spmon werks zzwgru3 ycond.

  SORT gt_ytrt1002 BY spmon ASCENDING
                   werks ASCENDING
                   zzwgru2 ASCENDING
                   ycond ASCENDING
                   datum descending
                   uzeit descending.
  delete adjacent duplicates from gt_ytrt1002
    comparing spmon werks zzwgru2 ycond.

  SORT gt_ytrt1003 BY spmon ASCENDING
                   werks ASCENDING
                   zzwgru1 ASCENDING
                   ycond ASCENDING
                   datum descending
                   uzeit descending.
  delete adjacent duplicates from gt_ytrt1003
    comparing spmon werks zzwgru1 ycond.

  SORT gt_ytrt1004 BY spmon ASCENDING
                      werks ASCENDING
                      matkl ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1004
    comparing spmon werks matkl ycond.

  SORT gt_ytrt1005 BY spmon ASCENDING
                      werks ASCENDING
                      prdha ASCENDING
                      zzwgru3 ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1005
    comparing spmon werks prdha zzwgru3 ycond.

  SORT gt_ytrt1006 BY spmon ASCENDING
                      werks ASCENDING
                      prdha ASCENDING
                      zzwgru2 ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1006
    comparing spmon werks prdha zzwgru2 ycond.

  SORT gt_ytrt1007 BY spmon ASCENDING
                      werks ASCENDING
                      prdha ASCENDING
                      zzwgru1 ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1007
    comparing spmon werks prdha zzwgru1 ycond.

  SORT gt_ytrt1008 BY spmon ASCENDING
                      werks ASCENDING
                      prdha ASCENDING
                      matkl ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1008
    comparing spmon werks prdha matkl ycond.

  SORT gt_ytrt1009 BY spmon ASCENDING
                      werks ASCENDING
                      prdha ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1009
    comparing spmon werks prdha ycond.

  SORT gt_ytrt1010 BY spmon ASCENDING
                      werks ASCENDING
                      matnr ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1010
    comparing spmon werks matnr ycond.

  SORT gt_ytrt1011 BY spmon ASCENDING
                      werks ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1011
    comparing spmon werks ycond.

  SORT gt_ytrt1012 BY spmon ASCENDING
                      werks ASCENDING
                      zzsfac ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1012
    comparing spmon werks zzsfac ycond.

  SORT gt_ytrt1013 BY spmon ASCENDING
                      werks ASCENDING
                      zest_art ASCENDING
                      ycond ASCENDING
                      datum descending
                      uzeit descending.
  delete adjacent duplicates from gt_ytrt1013
    comparing spmon werks zest_art ycond.



endform.                    " DELETE_SOURCE_DUPLICATES
