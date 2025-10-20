*&---------------------------------------------------------------------*
*&  Include           YRE00003INTJP_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data.

  RANGES s_wtab FOR t001k-bwkey.

  CREATE DATA w_ref TYPE TABLE OF yegn00001.
  ASSIGN w_ref->* TO <tab>.
  ASSIGN yegn00001 TO <line>.

  IF NOT s_bukrs IS INITIAL.
    s_wtab-sign = 'I'.
    s_wtab-option = 'EQ'.
    SELECT bwkey
      INTO s_wtab-low
      FROM t001k
      WHERE bukrs IN s_bukrs.
      APPEND s_wtab.
    ENDSELECT.
  ENDIF.

  SELECT werks
    INTO gv_werks
    FROM t001w
    WHERE werks IN s_werks.
    CHECK gv_werks NE '0001'.
* colocar o pisco por defeito no campo 'Fixo' em criacao e modificacao
    IF rb_op1 EQ 'X' OR rb_op2 EQ 'X'.
      gt_yegn00001-fixo = 'X'.
    ENDIF.
    gt_global-mandt = sy-mandt.
    gt_global-spmon = p_spmon.
    gt_global-werks = gv_werks.
*-->JC 03042009
*    gt_global-ycond = p_cond.
*<--
    MOVE-CORRESPONDING gt_global TO gt_yegn00001.

*-->JC 03042009
    IF rb_op1 EQ 'X'.
      gt_yegn00001-ycond = p_cond.
    ENDIF.
*<--

    IF NOT p_ref IS INITIAL.
      SELECT *
        INTO CORRESPONDING FIELDS OF gt_yegn00001
        FROM (p_table)
        WHERE spmon EQ p_ref
          AND werks EQ gv_werks
          AND eliminado EQ ''
          AND desactivo EQ ''.
        PERFORM get_desc.
        gt_global-mandt = sy-mandt.
        gt_global-spmon = p_spmon.
        gt_global-werks = gv_werks.
*-->    JC 03042009
*        gt_global-ycond = p_cond.
*<--
        MOVE-CORRESPONDING gt_global TO gt_yegn00001.

*-->    JC 03042009
        IF rb_op1 EQ 'X'.
          gt_yegn00001-ycond = p_cond.
        ENDIF.
*<--
        APPEND gt_yegn00001.
* validar se foram encontrados dados por referencia
        gv_dados = 'X'.
      ENDSELECT.
    ENDIF.
    APPEND gt_yegn00001. CLEAR gt_yegn00001.
  ENDSELECT.

  perform sort_table.
  DELETE ADJACENT DUPLICATES FROM gt_yegn00001 COMPARING ALL FIELDS.
  DELETE gt_yegn00001 WHERE werks NOT IN s_wtab.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.

  DATA ls_exclude TYPE ui_func.

*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
*  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
*  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
*  APPEND ls_exclude TO pt_exclude.
*  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
*  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                               " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  fill_fieldcatalog
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM fill_fieldcatalog.
  DATA: l_fieldcat TYPE lvc_s_fcat,
        lv_tabname LIKE dd02l-tabname.

*** Define o layout
  CLEAR ls_layout.

  ls_layout-zebra = 'X'.
  ls_layout-info_fname = 'LINE_COLOR'.

  MOVE p_table TO lv_tabname.
  TRANSLATE lv_tabname TO UPPER CASE.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'YEGN00001'
    CHANGING
      ct_fieldcat      = tab_fieldcat.

  LOOP AT tab_fieldcat INTO l_fieldcat.
    CLEAR l_fieldcat-key.
    IF l_fieldcat-fieldname EQ 'ELIMINADO' OR
       l_fieldcat-fieldname EQ 'FIXO'.
      l_fieldcat-checkbox = 'X'.
    ENDIF.
    IF l_fieldcat-fieldname EQ 'MANDT' OR
       l_fieldcat-fieldname EQ 'SPMON' OR
       l_fieldcat-fieldname EQ 'WERKS'. " OR
*       l_fieldcat-fieldname EQ 'YCOND'. "JC 02042009
      CLEAR l_fieldcat-edit.
    ELSE.
      IF NOT rb_op3 EQ 'X'.
        l_fieldcat-edit = 'X'.
      ENDIF.
    ENDIF.
    l_fieldcat-no_out = 'X'.
*    l_fieldcat-col_opt = 'X'.
    CLEAR l_fieldcat-tabname.
    CASE l_fieldcat-fieldname.
      WHEN 'ZZWGRU1' OR 'ZZWGRU2' OR 'ZZWGRU3'.
        l_fieldcat-outputlen = 6.
      WHEN 'MATKL'.
        l_fieldcat-outputlen = 5.
      WHEN 'PRDHA'.
        l_fieldcat-outputlen = 8.
      WHEN 'MATNR'.
        l_fieldcat-outputlen = 10.
      WHEN 'ZZSFAC'.
        l_fieldcat-outputlen = 4.
      WHEN 'ZEST_ART'.
        l_fieldcat-outputlen = 4.
      WHEN 'YPVPMIN'.
        l_fieldcat-outputlen = 10.
      WHEN 'YMONT'.
        l_fieldcat-outputlen = 10.
      WHEN 'TIPO'.
        l_fieldcat-outputlen = 1.
    ENDCASE.
    MODIFY tab_fieldcat FROM l_fieldcat INDEX sy-tabix.
  ENDLOOP.

**********************************************************************
* determinar quais os campos a aparecer na listagem final baseado na
* tabela para a qual se esta a manter os dados
  DATA: lv_tab_name TYPE string,
        lv_return   TYPE /sapdii/dwb_bapiret2,
        lt_table    LIKE dd03l OCCURS 0 WITH HEADER LINE.

  lv_tab_name = lv_tabname.
  CALL FUNCTION '/SAPDII/DWB_GET_TABLE_FIELDS'
    EXPORTING
      tab_name     = lv_tab_name
    IMPORTING
      return       = lv_return
    TABLES
      table_fields = lt_table.

  LOOP AT lt_table WHERE fieldname NE 'MANDT'.
    CHECK lt_table-fieldname NE 'DESACTIVO'.
* coluna de eliminar apenas disponivel para opcao 2
    IF rb_op1 EQ 'X' OR rb_op3 EQ 'X'.
      CHECK lt_table-fieldname NE 'ELIMINADO'.
    ENDIF.
* determinar quais os campos de descritivos a apresentar no alv
    READ TABLE tab_fieldcat INTO l_fieldcat
                            WITH KEY fieldname = lt_table-fieldname.
    IF sy-subrc EQ 0.
      CLEAR l_fieldcat-no_out.
      MODIFY tab_fieldcat FROM l_fieldcat INDEX sy-tabix.
      CASE lv_tabname.
        WHEN 'YTRT1001' OR 'YTRT1002' OR 'YTRT1003'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'KSCHL' '30' 'Desc. Nível' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1004'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'WGBEZ' '20' 'Desc. Grp Merc.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1005' OR 'YTRT1006' OR 'YTRT1007'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'KSCHL' '40' 'Desc. Nível' ''.
          field_names 'VTEXT_PRDHA' '30' 'Desc. Hier. Prod.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1008'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'WGBEZ' '20' 'Desc. Grp Merc.' ''.
          field_names 'VTEXT_PRDHA' '40' 'Desc. Hier. Prod.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1009'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'VTEXT_PRDHA' '40' 'Desc. Hier. Prod.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1010'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'MAKTX' '40' 'Desc. Material' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1011'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1012'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'VTEXT_ZZSFAC' '20' 'Desc. Tipo Cond.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
        WHEN 'YTRT1013'.
          field_names 'NAME1' '20' 'Nome Loja' ''.
          field_names 'DESCRICAO' '40' 'Desc. Est. Art.' ''.
          field_names 'FIXO'  '1'  'Fixo' 'X'.
          field_names 'MULT'  '10' 'Multiplos' 'X'.
      ENDCASE.
    ENDIF.
  ENDLOOP.

**********************************************************************
  DATA: lv_tabix LIKE sy-tabix.
* transferir valores para sempre listados
  IF <tab>[] IS INITIAL.
    LOOP AT gt_yegn00001.
* ler os descritivos para as lojas
      SELECT SINGLE name1
        INTO gt_yegn00001-name1
        FROM t001w
        WHERE werks EQ gt_yegn00001-werks.
      MOVE-CORRESPONDING gt_yegn00001 TO <line>.
      APPEND <line> TO <tab>.
    ENDLOOP.
  ELSE.
    LOOP AT gt_yegn00001.
      lv_tabix = sy-tabix.
* ler os descritivos para as lojas
      SELECT SINGLE name1
        INTO gt_yegn00001-name1
        FROM t001w
        WHERE werks EQ gt_yegn00001-werks.
      MOVE-CORRESPONDING gt_yegn00001 TO <line>.
      MODIFY <tab> FROM <line> INDEX lv_tabix.
    ENDLOOP.
  ENDIF.
**********************************************************************
ENDFORM.                    "fill_fieldcatalog

*&---------------------------------------------------------------------*
*&      Form  TRATA_DADOS
*&---------------------------------------------------------------------*
FORM trata_dados USING flag TYPE c.

* V - condicao para verificacao de dados
* I - condicao para apenas gravar valores
* D - condicao para eliminar entradas e gravar valores
  FIELD-SYMBOLS <savet> TYPE ANY.

  CASE p_table.
    WHEN 'YTRT1001'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1001.
        ASSIGN w_ref->* TO <save>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1001.
          IF ytrt1001-eliminado EQ 'X'.
            ytrt1001-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1001.
          APPEND ytrt1001 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1001 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1001 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1001 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1001.
          INSERT ytrt1001 FROM ytrt1001.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1002'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1002.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1002 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1002.
          IF ytrt1002-eliminado EQ 'X'.
            ytrt1002-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1002.
          APPEND ytrt1002 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1002 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1002 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1002 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1002.
          INSERT ytrt1002 FROM ytrt1002.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1003'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1003.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1003 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1003.
          IF ytrt1003-eliminado EQ 'X'.
            ytrt1003-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1003.
          APPEND ytrt1003 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1003 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1003 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1003 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1003.
          INSERT ytrt1003 FROM ytrt1003.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1004'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1004.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1004 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1004.
          IF ytrt1004-eliminado EQ 'X'.
            ytrt1004-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1004.
          APPEND ytrt1004 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1004 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1004 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1004 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1004.
          INSERT ytrt1004 FROM ytrt1004.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1005'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1005.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1005 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1005.
          IF ytrt1005-eliminado EQ 'X'.
            ytrt1005-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1005.
          APPEND ytrt1005 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1005 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1005 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1005 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1005.
          INSERT ytrt1005 FROM ytrt1005.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1006'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1006.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1006 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1006.
          IF ytrt1006-eliminado EQ 'X'.
            ytrt1006-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1006.
          APPEND ytrt1006 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1006 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1006 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1006 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1006.
          INSERT ytrt1006 FROM ytrt1006.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1007'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1007.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1007 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1007.
          IF ytrt1007-eliminado EQ 'X'.
            ytrt1007-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1007.
          APPEND ytrt1007 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1007 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1007 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1007 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1007.
          INSERT ytrt1007 FROM ytrt1007.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1008'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1008.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1008 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1008.
          IF ytrt1008-eliminado EQ 'X'.
            ytrt1008-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1008.
          APPEND ytrt1008 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1008 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1008 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1008 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1008.
          INSERT ytrt1008 FROM ytrt1008.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1009'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1009.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1009 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1009.
          IF ytrt1009-eliminado EQ 'X'.
            ytrt1009-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1009.
          APPEND ytrt1009 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1009 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1009 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1009 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1009.
          INSERT ytrt1009 FROM ytrt1009.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1010'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1010.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1010 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1010.
          IF ytrt1010-eliminado EQ 'X'.
            ytrt1010-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1010.
          APPEND ytrt1010 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1010 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1010 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1010 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1010.
          INSERT ytrt1010 FROM ytrt1010.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1011'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1011.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1011 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1011.
          IF ytrt1011-eliminado EQ 'X'.
            ytrt1011-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1011.
          APPEND ytrt1011 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1011 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1011 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1011 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1011.
          INSERT ytrt1011 FROM ytrt1011.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1012'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1012.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1012 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1012.
          IF ytrt1012-eliminado EQ 'X'.
            ytrt1012-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1012.
          APPEND ytrt1012 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1012 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1012 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1012 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1012.
          INSERT ytrt1012 FROM ytrt1012.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
    WHEN 'YTRT1013'.
      IF flag EQ 'V'.
        CREATE DATA w_ref TYPE TABLE OF ytrt1013.
        ASSIGN w_ref->* TO <save>.
*        ASSIGN ytrt1013 TO <savet>.
        LOOP AT <tab> ASSIGNING <line>.
          MOVE-CORRESPONDING <line> TO gt_yegn00001.
          if gt_yegn00001-changed = space.
            continue.
          endif.
          MOVE-CORRESPONDING <line> TO ytrt1013.
          IF ytrt1013-eliminado EQ 'X'.
            ytrt1013-desactivo = 'X'.
          ENDIF.
          MOVE-CORRESPONDING sy TO ytrt1013.
          APPEND ytrt1013 TO <save>.
        ENDLOOP.
      ELSEIF flag EQ 'I'.
        INSERT ytrt1013 FROM TABLE <save>.
      ELSEIF flag EQ 'D'.
        DELETE ytrt1013 FROM TABLE <save>.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*        INSERT ytrt1013 FROM TABLE <save>.
* FIM SUBST
        loop at <save> into ytrt1013.
          INSERT ytrt1013 FROM ytrt1013.
        endloop.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
      ENDIF.
  ENDCASE.

ENDFORM.                    " TRATA_DADOS

*&---------------------------------------------------------------------*
*&      Form  LOAD_GRID
*&---------------------------------------------------------------------*
FORM load_grid .

  DATA: lt_exclude TYPE ui_functions.

* Exclude all edit functions in this example since we do not need them:
  PERFORM exclude_tb_functions CHANGING lt_exclude.

*** Define os campos a exibir
  PERFORM fill_fieldcatalog.

*** Gera o alv control no écran
  CALL METHOD alv_grid->set_table_for_first_display
    EXPORTING
      is_layout                     = ls_layout
      it_toolbar_excluding          = lt_exclude
    CHANGING
      it_outtab                     = <tab>
      it_fieldcatalog               = tab_fieldcat
    EXCEPTIONS
      invalid_parameter_combination = 1
      program_error                 = 2
      too_many_lines                = 3
      OTHERS                        = 4.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  LOOP AT tab_fieldcat INTO wa_fieldcat.
    CASE wa_fieldcat-fieldname.
      WHEN 'YCOND'.
        wa_fieldcat-reptext = 'Condicional'.
    ENDCASE.
    MODIFY tab_fieldcat FROM wa_fieldcat INDEX sy-tabix.
  ENDLOOP.
** Chama o método set_toolbar_interactive para despoletar o evento
** toolbar
*  CALL METHOD alv_grid->set_toolbar_interactive.

ENDFORM.                    " LOAD_GRID

*&---------------------------------------------------------------------*
*&      Form  GET_DESC
*&---------------------------------------------------------------------*
FORM get_desc.

  IF NOT gt_yegn00001-zzwgru3 IS INITIAL.
    desc_nivel gt_yegn00001-zzwgru3 'GM_NIVEL1'.
  ELSEIF NOT gt_yegn00001-zzwgru2 IS INITIAL.
    desc_nivel gt_yegn00001-zzwgru2 'GM_NIVEL2'.
  ELSEIF NOT gt_yegn00001-zzwgru1 IS INITIAL.
    desc_nivel gt_yegn00001-zzwgru1 'GM_NIVEL3'.
  ELSEIF  gt_yegn00001-zzwgru3 IS INITIAL AND gt_yegn00001-zzwgru2 IS INITIAL
                                      AND gt_yegn00001-zzwgru1 IS INITIAL.
    CLEAR gt_yegn00001-kschl.
  ENDIF.
  IF NOT gt_yegn00001-matkl IS INITIAL.
    grp_merc gt_yegn00001-matkl.
  ELSEIF gt_yegn00001-matkl IS INITIAL.
    CLEAR gt_yegn00001-wgbez.
  ENDIF.
  IF NOT gt_yegn00001-prdha IS INITIAL.
    desc_hier gt_yegn00001-prdha.
  ELSEIF gt_yegn00001-prdha IS INITIAL.
    CLEAR gt_yegn00001-vtext_prdha.
  ENDIF.
  IF NOT gt_yegn00001-matnr IS INITIAL.
    desc_mat gt_yegn00001-matnr.
  ELSEIF gt_yegn00001-matnr IS INITIAL.
    CLEAR gt_yegn00001-maktx.
  ENDIF.
  IF NOT gt_yegn00001-zest_art IS INITIAL.
    desc_est gt_yegn00001-zest_art.
  ELSEIF gt_yegn00001-zest_art IS INITIAL.
    CLEAR gt_yegn00001-descricao.
  ENDIF.
  IF NOT gt_yegn00001-zzsfac IS INITIAL.
    desc_tpcond gt_yegn00001-zzsfac.
  ELSEIF gt_yegn00001-zzsfac IS INITIAL.
    CLEAR gt_yegn00001-vtext_zzsfac.
  ENDIF.

ENDFORM.                    " GET_DESC

form sort_table.
  case p_table.
    WHEN 'YTRT1001'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           zzwgru3 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1002'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           zzwgru2 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1003'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           zzwgru1 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1004'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           matkl ASCENDING
                           ycond ascending.
    WHEN 'YTRT1005'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           prdha ASCENDING
                           zzwgru3 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1006'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           prdha ASCENDING
                           zzwgru2 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1007'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           prdha ASCENDING
                           zzwgru1 ASCENDING
                           ycond ascending.
    WHEN 'YTRT1008'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           prdha ASCENDING
                           matkl ASCENDING
                           ycond ascending.
    WHEN 'YTRT1009'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           prdha ASCENDING
                           ycond ascending.
    WHEN 'YTRT1010'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           matnr ASCENDING
                           ycond ascending.
    WHEN 'YTRT1011'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           ycond ascending.
    WHEN 'YTRT1012'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           zzsfac ASCENDING
                           ycond ascending.
    WHEN 'YTRT1013'.
      SORT gt_yegn00001 BY spmon ASCENDING
                           werks ASCENDING
                           zest_art ASCENDING
                           ycond ascending.

endcase.
endform.
