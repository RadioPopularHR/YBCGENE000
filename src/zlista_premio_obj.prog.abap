*&---------------------------------------------------------------------*
*& Report  ZLISTA_PREMIO_OBJ
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT zlista_premio_obj NO STANDARD PAGE HEADING.

TYPE-POOLS: slis.

TABLES: dd02l, ytrt1001.

TYPES: BEGIN OF ty_tabs,
        tabname LIKE dd02l-tabname,
       END OF ty_tabs.

TYPES: BEGIN OF ty_level_txt,
         class LIKE klah-class,
         klagr LIKE klah-klagr,
         kschl LIKE swor-kschl,
       END OF ty_level_txt.

TYPES: BEGIN OF ty_matkl_txt,
         matkl LIKE t023t-matkl,
         wgbez LIKE t023t-wgbez,
       END OF ty_matkl_txt.

TYPES: BEGIN OF ty_zest_art_txt,
         zest_art like ytre00005-zest_art,
         descricao like ytre00005-descricao,
       END OF ty_zest_art_txt.

TYPES: BEGIN OF ty_matnr_txt,
         matnr type matnr,
         maktx type maktx,
       END OF ty_matnr_txt.

TYPES: BEGIN OF ty_prdha_txt,
         prdha type prodh_d,
         vtext_prdha type bezei40,
       END OF ty_prdha_txt.

TYPES: BEGIN OF ty_zzsfac_txt,
         zzsfac type kschl,
         vtext_zzsfac type VTXTK,
       END OF ty_zzsfac_txt.

TYPES: BEGIN OF ty_werks_txt,
         werks type yloja,
         name1 type name1,
       END OF ty_werks_txt.

DATA: lt_level1_txt TYPE TABLE OF ty_level_txt WITH HEADER LINE,
      lt_level2_txt TYPE TABLE OF ty_level_txt WITH HEADER LINE,
      lt_level3_txt TYPE TABLE OF ty_level_txt WITH HEADER LINE,
      lt_level4_txt TYPE TABLE OF ty_matkl_txt WITH HEADER LINE,
      lt_zest_art_txt TYPE TABLE OF ty_zest_art_txt WITH HEADER LINE,
      lt_matnr_txt TYPE TABLE OF ty_matnr_txt WITH HEADER LINE,
      lt_prdha_txt TYPE TABLE OF ty_prdha_txt WITH HEADER LINE,
      lt_zzsfac_txt TYPE TABLE OF ty_zzsfac_txt WITH HEADER LINE,
      lt_werks_txt TYPE TABLE OF ty_werks_txt WITH HEADER LINE.

DATA: it_tabs TYPE TABLE OF ty_tabs,
      wa_tabs TYPE ty_tabs.

DATA: r_tabs TYPE RANGE OF dd02l-tabname WITH HEADER LINE.

TYPES: BEGIN OF ty_premio,
        spmon TYPE spmon,
        werks TYPE yloja,
        name1 type name1,
        zzwgru3 TYPE yhie3,
        kschl3  TYPE klschl,
        zzwgru2 TYPE yhie2,
        kschl2  TYPE klschl,
        zzwgru1 TYPE yhie1,
        kschl1  TYPE klschl,
        matkl TYPE matkl,
        wgbez TYPE wgbez,
        prdha TYPE prodh_d,
        vtext_prdha type BEZEI40,
        matnr TYPE matnr,
        maktx type maktx,
        zzsfac TYPE kschl,
        vtext_zzsfac type VTXTK,
        zest_art TYPE yest_art,
        descricao type YDESC,
        ycond TYPE ycond,
        ypvpmin TYPE ypvpmin,
        ymont TYPE kbetr_kond,
        tipo TYPE ytipo,
        fixo TYPE char01,
        mult TYPE numc_3,
       END OF ty_premio.

DATA: it_premio TYPE TABLE OF ty_premio,
      wa_premio TYPE ty_premio.

TYPES: BEGIN OF ty_obj,
        spmon TYPE spmon,
        werks TYPE yloja,
        name1 type name1,
        zzwgru3 TYPE yhie3,
        kschl3  TYPE klschl,
        zzwgru2 TYPE yhie2,
        kschl2  TYPE klschl,
        zzwgru1 TYPE yhie1,
        kschl1  TYPE klschl,
        matkl TYPE matkl,
        wgbez TYPE wgbez,
        zzprdha TYPE prodh_d,
        vtext_prdha type BEZEI40,
        matnr TYPE matnr,
        maktx type maktx,
        zzsfac TYPE kschl,
        vtext_zzsfac type VTXTK,
        zest_art TYPE yest_art,
        descricao type ydesc,
        kunnr TYPE kunnr,
        sname TYPE smnam,
        yhoras TYPE yhoras,
        ymont TYPE kbetr_kond,
       END OF ty_obj.

DATA: it_obj TYPE TABLE OF ty_obj,
      wa_obj TYPE ty_obj.

DATA: it_fcat TYPE slis_t_fieldcat_alv,
      wa_fcat TYPE slis_fieldcat_alv,
      it_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat TYPE lvc_s_fcat.

DATA: ls_table TYPE REF TO data,
      ls_line TYPE REF TO data.

FIELD-SYMBOLS: <l_table> TYPE ANY TABLE,
               <l_line> TYPE ANY,
               <l_field> TYPE ANY.

*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK 001 WITH FRAME.

PARAMETERS: p_prm RADIOBUTTON GROUP rsel DEFAULT 'X',
            p_obj RADIOBUTTON GROUP rsel.

SELECTION-SCREEN END OF BLOCK 001.


SELECTION-SCREEN BEGIN OF BLOCK 002 WITH FRAME.

SELECT-OPTIONS: s_spmon FOR ytrt1001-spmon,
                s_werks FOR ytrt1001-werks,
                s_tab FOR dd02l-tabname.

SELECTION-SCREEN END OF BLOCK 002.

*&---------------------------------------------------------------------*
START-OF-SELECTION.

  PERFORM get_tabs.
  PERFORM get_data.
  PERFORM display_data.


*&---------------------------------------------------------------------*
*&      Form  get_tabs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_tabs.

* Build r_tabs
  r_tabs-sign = 'I'.
  r_tabs-option = 'CP'.
  IF p_prm EQ 'X'.
    r_tabs-low = 'YTRT1*'.
  ELSE.
    r_tabs-low = 'YTRT2*'.
  ENDIF.
  APPEND r_tabs.

  SELECT tabname FROM dd02l INTO TABLE it_tabs
    WHERE tabname IN s_tab
    AND tabname IN r_tabs.

ENDFORM.                    "get_tabs

*&---------------------------------------------------------------------*
*&      Form  get_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_data.

  LOOP AT it_tabs INTO wa_tabs.
*   Create dinamic it
    FREE: it_fcat, it_fcat, it_fieldcat, ls_table, ls_line.
    CLEAR: wa_fcat, wa_fieldcat.

    CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name = wa_tabs-tabname
      CHANGING
        ct_fieldcat      = it_fcat.

    LOOP AT it_fcat INTO wa_fcat.
      MOVE-CORRESPONDING wa_fcat TO wa_fieldcat.
      wa_fieldcat-ref_field = wa_fcat-fieldname.
      wa_fieldcat-ref_table = wa_fcat-ref_tabname.
      APPEND wa_fieldcat TO it_fieldcat.
    ENDLOOP.

    CALL METHOD cl_alv_table_create=>create_dynamic_table
      EXPORTING
        it_fieldcatalog = it_fieldcat
      IMPORTING
        ep_table        = ls_table.

    ASSIGN ls_table->* TO <l_table>.
    CREATE DATA ls_line LIKE LINE OF <l_table>.
    ASSIGN ls_line->* TO <l_line>.

    SELECT * FROM (wa_tabs-tabname) INTO TABLE <l_table>
      WHERE spmon IN s_spmon
      AND werks IN s_werks
      AND eliminado EQ space
      AND desactivo EQ space.


    LOOP AT <l_table> ASSIGNING <l_line>.
      IF p_prm EQ 'X'.
        CLEAR wa_premio.
        MOVE-CORRESPONDING <l_line> TO wa_premio.
        APPEND wa_premio TO it_premio.
      ELSE.
        CLEAR wa_obj.
        MOVE-CORRESPONDING <l_line> TO wa_obj.

*       Nome Colaborador
        SELECT SINGLE sname FROM pa0001 INTO wa_obj-sname
          WHERE pernr EQ wa_obj-kunnr
          AND endda GE sy-datum
          AND begda LE sy-datum.

        APPEND wa_obj TO it_obj.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  IF p_prm EQ 'X'.
    PERFORM get_descriptions_pre.
  ELSE.
    PERFORM get_descriptions_obj.
  ENDIF.

ENDFORM.                    "get_data


*&---------------------------------------------------------------------*
*&      Form  display_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM display_data.

  PERFORM build_layout.

  IF p_prm EQ 'X'.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat        = it_fcat
        i_save             = 'X'
        i_callback_program = sy-repid
      TABLES
        t_outtab           = it_premio
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
  ELSE.
    CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
      EXPORTING
        it_fieldcat        = it_fcat
        i_save             = 'X'
        i_callback_program = sy-repid
      TABLES
        t_outtab           = it_obj
      EXCEPTIONS
        program_error      = 1
        OTHERS             = 2.
  ENDIF.

ENDFORM.                    "display_data


*&---------------------------------------------------------------------*
*&      Form  build_layout
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM build_layout.

  FREE it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'SPMON'.
  wa_fcat-reptext_ddic = 'Período'.
  wa_fcat-key = 'X'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'WERKS'.
  wa_fcat-reptext_ddic = 'Loja'.
  wa_fcat-key = 'X'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'NAME1'.
  wa_fcat-reptext_ddic = 'Design. Loja'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ZZWGRU3'.
  wa_fcat-reptext_ddic = 'Nível 1'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'KSCHL3'.
  wa_fcat-reptext_ddic = 'Descr. Nív. 1'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ZZWGRU2'.
  wa_fcat-reptext_ddic = 'Nível 2'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'KSCHL2'.
  wa_fcat-reptext_ddic = 'Descr. Nív. 2'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ZZWGRU1'.
  wa_fcat-reptext_ddic = 'Nível 3'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'KSCHL1'.
  wa_fcat-reptext_ddic = 'Descr. Nív. 3'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'MATKL'.
  wa_fcat-reptext_ddic = 'Nível 4'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'WGBEZ'.
  wa_fcat-reptext_ddic = 'Descr. Nív. 4'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  IF p_prm EQ 'X'.
    CLEAR wa_fcat.
    wa_fcat-fieldname = 'PRDHA'.
    wa_fcat-reptext_ddic = 'Marca'.
    APPEND wa_fcat TO it_fcat.
  ELSE.
    CLEAR wa_fcat.
    wa_fcat-fieldname = 'ZZPRDHA'.
    wa_fcat-reptext_ddic = 'Marca'.
    APPEND wa_fcat TO it_fcat.
  ENDIF.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'VTEXT_PRDHA'.
  wa_fcat-reptext_ddic = 'Design. Marca'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'MATNR'.
  wa_fcat-reptext_ddic = 'Artigo'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'MAKTX'.
  wa_fcat-reptext_ddic = 'Design. Artigo'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ZZSFAC'.
  wa_fcat-reptext_ddic = 'Tipo Crédito'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'VTEXT_ZZSFAC'.
  wa_fcat-reptext_ddic = 'Desc. Tp. Créd.'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'ZEST_ART'.
  wa_fcat-reptext_ddic = 'Estado Artigo'.
  APPEND wa_fcat TO it_fcat.

  CLEAR wa_fcat.
  wa_fcat-fieldname = 'DESCRICAO'.
  wa_fcat-reptext_ddic = 'Design. Est. Artigo'.
  wa_fcat-outputlen = 20.
  APPEND wa_fcat TO it_fcat.

  IF p_prm EQ 'X'.
    CLEAR wa_fcat.
    wa_fcat-fieldname = 'YCOND'.
    wa_fcat-reptext_ddic = 'Condicional'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'YPVPMIN'.
    wa_fcat-reptext_ddic = 'PVP Mínimo'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'YMONT'.
    wa_fcat-reptext_ddic = 'Prémio'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'TIPO'.
    wa_fcat-reptext_ddic = 'Tipo'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'FIXO'.
    wa_fcat-reptext_ddic = 'Fixo'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'MULT'.
    wa_fcat-reptext_ddic = 'Múltiplos'.
    APPEND wa_fcat TO it_fcat.
  ELSE.
    CLEAR wa_fcat.
    wa_fcat-fieldname = 'KUNNR'.
    wa_fcat-reptext_ddic = 'Colaborador'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'SNAME'.
    wa_fcat-reptext_ddic = 'Nome Colaborador'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'YHORAS'.
    wa_fcat-reptext_ddic = 'Nº Horas'.
    APPEND wa_fcat TO it_fcat.

    CLEAR wa_fcat.
    wa_fcat-fieldname = 'YMONT'.
    wa_fcat-reptext_ddic = 'Valor Obj'.
    APPEND wa_fcat TO it_fcat.
  ENDIF.

ENDFORM.                    "build_layout


*&---------------------------------------------------------------------*
*&      Form  get_descriptions_pre
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_descriptions_pre.


  clear: lt_level1_txt, lt_level2_txt, lt_level3_txt, lt_level4_txt,
         lt_zest_art_txt, lt_matnr_txt.

  refresh: lt_level1_txt, lt_level2_txt, lt_level3_txt, lt_level4_txt,
           lt_zest_art_txt, lt_matnr_txt.

  FIELD-SYMBOLS: <fs_premio> TYPE ty_premio.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level1_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_premio
    WHERE class EQ it_premio-zzwgru3
      AND klagr LIKE 'GM_NIVEL1'.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level2_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_premio
    WHERE class EQ it_premio-zzwgru2
      AND klagr LIKE 'GM_NIVEL2'.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level3_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_premio
    WHERE class EQ it_premio-zzwgru1
      AND klagr LIKE 'GM_NIVEL3'.

  SELECT matkl wgbez
    INTO CORRESPONDING FIELDS OF TABLE lt_level4_txt
    FROM t023t
     FOR ALL ENTRIES IN it_premio
    WHERE spras EQ sy-langu
      AND matkl EQ it_premio-matkl.

  select zest_art descricao
    into corresponding fields of table lt_zest_art_txt
    from ytre00005
     for all entries in it_premio
   where zest_art eq it_premio-zest_art and
         spras eq sy-langu.

  select matnr maktx
    into corresponding fields of table lt_matnr_txt
    from makt
     for all entries in it_premio
   where matnr eq it_premio-matnr and
         spras eq sy-langu.

  select prodh as prdha vtext as vtext_prdha
    into corresponding fields of table lt_prdha_txt
    from t179t
     for all entries in it_premio
   where spras eq sy-langu and
         prodh eq it_premio-prdha.

  select kschl as zzsfac vtext as vtext_zzsfac
    into corresponding fields of table lt_zzsfac_txt
    from t685t
     for all entries in it_premio
   where spras eq sy-langu and
         kvewe eq 'A' and
         kappl eq 'V' and
         kschl eq it_premio-zzsfac.

  select werks name1
    into corresponding fields of table lt_werks_txt
    from t001w
     for all entries in it_premio
   where spras eq sy-langu and
         werks eq it_premio-werks.

  LOOP AT it_premio ASSIGNING <fs_premio>.
    IF <fs_premio>-zzwgru3 IS NOT INITIAL.
      READ TABLE lt_level1_txt WITH KEY class = <fs_premio>-zzwgru3.
      IF sy-subrc = 0.
        <fs_premio>-kschl3 = lt_level1_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_premio>-zzwgru2 IS NOT INITIAL.
      READ TABLE lt_level2_txt WITH KEY class = <fs_premio>-zzwgru2.
      IF sy-subrc = 0.
        <fs_premio>-kschl2 = lt_level2_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_premio>-zzwgru1 IS NOT INITIAL.
      READ TABLE lt_level3_txt WITH KEY class = <fs_premio>-zzwgru1.
      IF sy-subrc = 0.
        <fs_premio>-kschl1 = lt_level3_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_premio>-matkl IS NOT INITIAL.
      READ TABLE lt_level4_txt WITH KEY matkl = <fs_premio>-matkl.
      IF sy-subrc = 0.
        <fs_premio>-wgbez = lt_level4_txt-wgbez.
      ENDIF.
    ENDIF.
    IF <fs_premio>-zest_art IS NOT INITIAL.
      READ TABLE lt_zest_art_txt WITH KEY zest_art = <fs_premio>-zest_art.
      IF sy-subrc = 0.
        <fs_premio>-descricao = lt_zest_art_txt-descricao.
      ENDIF.
    ENDIF.
    IF <fs_premio>-matnr IS NOT INITIAL.
      READ TABLE lt_matnr_txt WITH KEY matnr = <fs_premio>-matnr.
      IF sy-subrc = 0.
        <fs_premio>-maktx = lt_matnr_txt-maktx.
      ENDIF.
    ENDIF.
    IF <fs_premio>-prdha IS NOT INITIAL.
      READ TABLE lt_prdha_txt WITH KEY prdha = <fs_premio>-prdha.
      IF sy-subrc = 0.
        <fs_premio>-vtext_prdha = lt_prdha_txt-vtext_prdha.
      ENDIF.
    ENDIF.
    IF <fs_premio>-zzsfac IS NOT INITIAL.
      READ TABLE lt_zzsfac_txt WITH KEY zzsfac = <fs_premio>-zzsfac.
      IF sy-subrc = 0.
        <fs_premio>-vtext_zzsfac = lt_zzsfac_txt-vtext_zzsfac.
      ENDIF.
    ENDIF.
    IF <fs_premio>-werks IS NOT INITIAL.
      READ TABLE lt_werks_txt WITH KEY werks = <fs_premio>-werks.
      IF sy-subrc = 0.
        <fs_premio>-name1 = lt_werks_txt-name1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  sort it_premio by spmon werks zzwgru3 zzwgru2 zzwgru1 matkl
                    matnr zest_art prdha zzsfac ycond.


ENDFORM.                    "get_descriptions_pre


*&---------------------------------------------------------------------*
*&      Form  get_descriptions_obj
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM get_descriptions_obj.

  FIELD-SYMBOLS: <fs_obj> TYPE ty_obj.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level1_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_obj
    WHERE class EQ it_obj-zzwgru3
      AND klagr LIKE 'GM_NIVEL1'.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level2_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_obj
    WHERE class EQ it_obj-zzwgru2
      AND klagr LIKE 'GM_NIVEL2'.

  SELECT k~class k~klagr s~kschl
    INTO CORRESPONDING FIELDS OF TABLE lt_level3_txt
    FROM swor AS s INNER JOIN klah AS k
                   ON k~clint EQ s~clint
    FOR ALL ENTRIES IN it_obj
    WHERE class EQ it_obj-zzwgru1
      AND klagr LIKE 'GM_NIVEL3'.

  SELECT matkl wgbez
    INTO CORRESPONDING FIELDS OF TABLE lt_level4_txt
    FROM t023t
     FOR ALL ENTRIES IN it_obj
    WHERE spras EQ sy-langu
      AND matkl EQ it_obj-matkl.

  select zest_art descricao
    into corresponding fields of table lt_zest_art_txt
    from ytre00005
     for all entries in it_obj
   where zest_art eq it_obj-zest_art and
         spras eq sy-langu.

  select matnr maktx
    into corresponding fields of table lt_matnr_txt
    from makt
     for all entries in it_obj
   where matnr eq it_obj-matnr and
         spras eq sy-langu.

  select prodh as prdha vtext as vtext_prdha
    into corresponding fields of table lt_prdha_txt
    from t179t
     for all entries in it_obj
   where spras eq sy-langu and
         prodh eq it_obj-ZZPRDHA.

  select kschl as zzsfac vtext as vtext_zzsfac
    into corresponding fields of table lt_zzsfac_txt
    from t685t
     for all entries in it_obj
   where spras eq sy-langu and
         kvewe eq 'A' and
         kappl eq 'V' and
         kschl eq it_obj-zzsfac.

  select werks name1
    into corresponding fields of table lt_werks_txt
    from t001w
     for all entries in it_obj
   where spras eq sy-langu and
         werks eq it_obj-werks.

  LOOP AT it_obj ASSIGNING <fs_obj>.
    IF <fs_obj>-zzwgru3 IS NOT INITIAL.
      READ TABLE lt_level1_txt WITH KEY class = <fs_obj>-zzwgru3.
      IF sy-subrc = 0.
        <fs_obj>-kschl3 = lt_level1_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_obj>-zzwgru2 IS NOT INITIAL.
      READ TABLE lt_level2_txt WITH KEY class = <fs_obj>-zzwgru2.
      IF sy-subrc = 0.
        <fs_obj>-kschl2 = lt_level2_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_obj>-zzwgru1 IS NOT INITIAL.
      READ TABLE lt_level3_txt WITH KEY class = <fs_obj>-zzwgru1.
      IF sy-subrc = 0.
        <fs_obj>-kschl1 = lt_level3_txt-kschl.
      ENDIF.
    ENDIF.
    IF <fs_obj>-matkl IS NOT INITIAL.
      READ TABLE lt_level4_txt WITH KEY matkl = <fs_obj>-matkl.
      IF sy-subrc = 0.
        <fs_obj>-wgbez = lt_level4_txt-wgbez.
      ENDIF.
    ENDIF.
    IF <fs_obj>-zest_art IS NOT INITIAL.
      READ TABLE lt_zest_art_txt WITH KEY zest_art = <fs_obj>-zest_art.
      IF sy-subrc = 0.
        <fs_obj>-descricao = lt_zest_art_txt-descricao.
      ENDIF.
    ENDIF.
    IF <fs_obj>-matnr IS NOT INITIAL.
      READ TABLE lt_matnr_txt WITH KEY matnr = <fs_obj>-matnr.
      IF sy-subrc = 0.
        <fs_obj>-maktx = lt_matnr_txt-maktx.
      ENDIF.
    ENDIF.
    IF <fs_obj>-ZZPRDHA IS NOT INITIAL.
      READ TABLE lt_prdha_txt WITH KEY prdha = <fs_obj>-ZZPRDHA.
      IF sy-subrc = 0.
        <fs_obj>-vtext_prdha = lt_prdha_txt-vtext_prdha.
      ENDIF.
    ENDIF.
    IF <fs_obj>-zzsfac IS NOT INITIAL.
      READ TABLE lt_zzsfac_txt WITH KEY zzsfac = <fs_obj>-zzsfac.
      IF sy-subrc = 0.
        <fs_obj>-vtext_zzsfac = lt_zzsfac_txt-vtext_zzsfac.
      ENDIF.
    ENDIF.
    IF <fs_obj>-werks IS NOT INITIAL.
      READ TABLE lt_werks_txt WITH KEY werks = <fs_obj>-werks.
      IF sy-subrc = 0.
        <fs_obj>-name1 = lt_werks_txt-name1.
      ENDIF.
    ENDIF.
  ENDLOOP.

  sort it_obj by spmon werks zzwgru3 zzwgru2 zzwgru1 matkl
                 matnr zzprdha zzsfac zest_art.

ENDFORM.                    "get_descriptions_obj
