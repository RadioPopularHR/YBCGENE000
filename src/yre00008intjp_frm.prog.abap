*&---------------------------------------------------------------------*
*&  Include           YRE00008INTJP_FRM
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_DADOS
*&---------------------------------------------------------------------*
FORM get_dados.

  get_dados01 wa_dados01 gt_dados01 ytrt1001.
  get_dados01 wa_dados01 gt_dados01 ytrt1002.
  get_dados01 wa_dados01 gt_dados01 ytrt1003.
  get_dados01 wa_dados01 gt_dados01 ytrt1004.
  get_dados01 wa_dados01 gt_dados01 ytrt1005.
  get_dados01 wa_dados01 gt_dados01 ytrt1006.
  get_dados01 wa_dados01 gt_dados01 ytrt1007.
  get_dados01 wa_dados01 gt_dados01 ytrt1008.
  get_dados01 wa_dados01 gt_dados01 ytrt1009.
  get_dados01 wa_dados01 gt_dados01 ytrt1010.
  get_dados01 wa_dados01 gt_dados01 ytrt1011.
  get_dados01 wa_dados01 gt_dados01 ytrt1012.
  get_dados01 wa_dados01 gt_dados01 ytrt1013.

  DELETE gt_dados01 WHERE NOT zzwgru3 IN s_gru3.
  DELETE gt_dados01 WHERE NOT matnr IN s_matnr.

  get_dados02 wa_dados02 gt_dados02 ytrt2001.
  get_dados02 wa_dados02 gt_dados02 ytrt2002.
  get_dados02 wa_dados02 gt_dados02 ytrt2003.
  get_dados02 wa_dados02 gt_dados02 ytrt2004.
  get_dados02 wa_dados02 gt_dados02 ytrt2005.
  get_dados02 wa_dados02 gt_dados02 ytrt2006.
  get_dados02 wa_dados02 gt_dados02 ytrt2007.
  get_dados02 wa_dados02 gt_dados02 ytrt2008.
  get_dados02 wa_dados02 gt_dados02 ytrt2009.
  get_dados02 wa_dados02 gt_dados02 ytrt2010.
  get_dados02 wa_dados02 gt_dados02 ytrt2011.
  get_dados02 wa_dados02 gt_dados02 ytrt2012.
  get_dados02 wa_dados02 gt_dados02 ytrt2013.

  DELETE gt_dados02 WHERE NOT zzwgru3 IN s_gru3.
  DELETE gt_dados02 WHERE NOT matnr IN s_matnr.
* INI - ROFF - VN/MJB - Comissões Vendas - 2010.04.27 - I
  delete gt_dados02 where YMONT = 0.
* FIM - ROFF - VN/MJB - Comissões Vendas - 2010.04.27 - I

  LOOP AT gt_dados02 INTO wa_dados02.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = wa_dados02-kunnr
      IMPORTING
        output = wa_dados02-kunnr.

    IF wa_dados02-kunnr NOT IN s_kunnr.
      DELETE gt_dados02.
    ENDIF.
  ENDLOOP.

*  DELETE gt_dados02 WHERE NOT kunnr IN s_kunnr.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_job
    FROM ytrt00001
    WHERE spmon EQ p_spmon
      AND werks IN s_werks
      AND zzwgru3 IN s_gru3
      AND matnr IN s_matnr
      AND pernr IN s_kunnr.

  DELETE gt_job WHERE pernr IS INITIAL.

* JC - 13052009
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_job_lj
    FROM ytrt00001
    WHERE spmon EQ p_spmon
      AND werks IN s_werks.

* Vendas por loja
  LOOP AT gt_job_lj INTO wa_job_lj.
    MOVE-CORRESPONDING wa_job_lj TO wa_lj.
    COLLECT wa_lj INTO gt_lj.
  ENDLOOP.
*

* Objectivos por loja
  LOOP AT gt_dados02 INTO wa_dados02
    WHERE tabela EQ 'YTRT2011'.

    MOVE-CORRESPONDING wa_dados02 TO wa_obj_lj.
    APPEND wa_obj_lj TO gt_obj_lj.
  ENDLOOP.
*

* Prémios por loja
  LOOP AT gt_dados01 INTO wa_dados01
    WHERE tabela EQ 'YTRT1011'.

    MOVE-CORRESPONDING wa_dados01 TO wa_prm_lj.
    APPEND wa_prm_lj TO gt_prm_lj.
  ENDLOOP.
*

* Colaboradores por loja
  SELECT * FROM ytrt5001 INTO TABLE gt_dados05
    WHERE spmon EQ p_spmon
    AND werks IN s_werks
    AND valido = 'X'.

* JC - 13052009

ENDFORM.                    " GET_DADOS

*&---------------------------------------------------------------------*
*&      Form  VALORES_OBJECTIVOS
*&---------------------------------------------------------------------*
FORM valores_objectivos.

  DATA: lv_tabela(15) TYPE c,
        lv_table(15) TYPE c.

  DATA: lv_ok TYPE xflag.

  REFRESH gt_dados03.

  LOOP AT gt_dados02 INTO wa_dados02.

*   JC - 13052009
    CHECK wa_dados02-tabela NE 'YTRT2011'.
*

*-->JC - 04032009
*   Registo Prémio
    CLEAR wa_dados01.
    READ TABLE gt_dados01 INTO wa_dados01
      WITH KEY spmon = wa_dados02-spmon
               werks = wa_dados02-werks
               zzwgru3 = wa_dados02-zzwgru3
               zzwgru2 = wa_dados02-zzwgru2
               zzwgru1 = wa_dados02-zzwgru1
               matkl = wa_dados02-matkl
               prdha = wa_dados02-zzprdha
               matnr = wa_dados02-matnr
               zzsfac = wa_dados02-zzsfac
               zest_art = wa_dados02-zest_art.

*--< JC

    lv_table = wa_dados02-tabela.
    lv_table+4(1) = '1'.
    MOVE-CORRESPONDING wa_dados02 TO wa_dados03.
    LOOP AT gt_job INTO wa_job WHERE spmon EQ wa_dados02-spmon
                                 AND werks EQ wa_dados02-werks
                                 AND pernr EQ wa_dados02-kunnr.

*-->  JC - 04032009
*     Validar preço base com valor minimo prémio
      IF NOT wa_dados01-ypvpmin IS INITIAL.
        IF wa_job-kbetr LT wa_dados01-ypvpmin.
          CONTINUE.
        ENDIF.
      ENDIF.

      IF wa_dados01-ymont LT 0 AND wa_job-fkart EQ 'ZCD8'.
        wa_job-netwr = wa_job-netwr * -1.
      ENDIF.
*--< JC

*para a tabela 11 so tem mesmo de verificar a loja as outras validacoes nao fazem sentido
      IF wa_dados02-tabela+6(2) EQ '11'.
        PERFORM save_dados03.
      ELSE.
*-->    JC - 08042009
        lv_ok = 'X'.

        IF NOT wa_dados02-matnr IS INITIAL.
          IF wa_dados02-matnr = wa_job-matnr.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zzwgru1 IS INITIAL.
          IF NOT wa_dados02-zzwgru1 = wa_job-zzwgru1.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zzwgru2 IS INITIAL.
          IF NOT wa_dados02-zzwgru2 = wa_job-zzwgru2.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zzwgru3 IS INITIAL.
          IF NOT wa_dados02-zzwgru3 = wa_job-zzwgru3.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-matkl IS INITIAL.
          IF NOT wa_dados02-matkl = wa_job-matkl.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zzprdha IS INITIAL.
          IF NOT wa_dados02-zzprdha = wa_job-prodh.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zzsfac IS INITIAL.
          IF NOT wa_dados02-zzsfac = wa_job-zzsfac.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

        CHECK NOT lv_ok IS INITIAL.

        IF NOT wa_dados02-zest_art IS INITIAL.
          IF NOT wa_dados02-zest_art = wa_job-zest_art.
            CLEAR lv_ok.
          ENDIF.
        ENDIF.

*        IF ( wa_dados02-matnr    = wa_job-matnr AND NOT wa_dados02-matnr IS INITIAL AND NOT wa_job-matnr IS INITIAL )
*        OR ( wa_dados02-zzwgru1  = wa_job-zzwgru1 AND NOT wa_dados02-zzwgru1 IS INITIAL AND NOT wa_job-zzwgru1 IS INITIAL )
*        OR ( wa_dados02-zzwgru2  = wa_job-zzwgru2 AND NOT wa_dados02-zzwgru2 IS INITIAL AND NOT wa_job-zzwgru2 IS INITIAL )
*        OR ( wa_dados02-zzwgru3  = wa_job-zzwgru3 AND NOT wa_dados02-zzwgru3 IS INITIAL AND NOT wa_job-zzwgru3 IS INITIAL )
*        OR ( wa_dados02-matkl    = wa_job-matkl AND NOT wa_dados02-matkl IS INITIAL AND NOT wa_job-matkl IS INITIAL )
*        OR ( wa_dados02-zzprdha  = wa_job-prodh AND NOT wa_dados02-zzprdha IS INITIAL AND NOT wa_job-prodh IS INITIAL )
*        OR ( wa_dados02-zzsfac   = wa_job-zzsfac AND NOT wa_dados02-zzsfac IS INITIAL AND NOT wa_job-zzsfac IS INITIAL )
*        OR ( wa_dados02-zest_art = wa_job-zest_art AND NOT wa_dados02-zest_art IS INITIAL AND NOT wa_job-zest_art IS INITIAL ).

        IF NOT lv_ok IS INITIAL.
*<--    JC - 08042009

          PERFORM save_dados03.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

  LOOP AT gt_dados02 INTO wa_dados02.
    LOOP AT gt_dados03 INTO wa_dados03
      WHERE spmon EQ wa_dados02-spmon
      AND werks EQ wa_dados02-werks
      AND kunnr EQ wa_dados02-kunnr
      AND zzwgru3 EQ wa_dados02-zzwgru3
      AND zzwgru2 EQ wa_dados02-zzwgru2
      AND zzwgru1 EQ wa_dados02-zzwgru1
      AND matkl EQ wa_dados02-matkl
      AND zzprdha EQ wa_dados02-zzprdha
      AND matnr EQ wa_dados02-matnr
      AND zzsfac EQ wa_dados02-zzsfac
      AND zest_art EQ wa_dados02-zest_art.

      IF wa_dados03-yrealizado GE wa_dados03-ymont.
        wa_dados03-ypagar = 'X'.
        MODIFY gt_dados03 FROM wa_dados03 INDEX sy-tabix.
      ENDIF.
    ENDLOOP.

    IF sy-subrc NE 0.
      MOVE-CORRESPONDING wa_dados02 TO wa_dados03.
      CLEAR wa_dados03-ypagar.
      CLEAR wa_job-netwr.
      PERFORM save_dados03.
    ENDIF.
  ENDLOOP.

ENDFORM.                    " VALORES_OBJECTIVOS

*&---------------------------------------------------------------------*
*&      Form  VALORES_PREMIO
*&---------------------------------------------------------------------*
FORM valores_premio.

  DATA: lv_ok TYPE xflag.

* tabela gt_dados01 contem os valores dos premios
* tabela gt_job contem a informacao dos items vendidos

  LOOP AT gt_dados01 INTO wa_dados01.

*   JC - 13052009
    CHECK wa_dados01-tabela NE 'YTRT1011'.
*
* INI - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III
*    LOOP AT gt_job INTO wa_job WHERE spmon EQ wa_dados01-spmon
*                                 AND werks EQ wa_dados01-werks.
* FIM SUBST
    LOOP AT gt_job INTO wa_job WHERE spmon EQ wa_dados01-spmon and
                                     werks EQ wa_dados01-werks and
                                     pernr in r_salesman.
* FIM - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III

*-->  JC - 08042009
      lv_ok = 'X'.

      IF NOT wa_dados01-matnr IS INITIAL.
        IF wa_dados01-matnr = wa_job-matnr.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-zzwgru1 IS INITIAL.
        IF NOT wa_dados01-zzwgru1 = wa_job-zzwgru1.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-zzwgru2 IS INITIAL.
        IF NOT wa_dados01-zzwgru2 = wa_job-zzwgru2.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-zzwgru3 IS INITIAL.
        IF NOT wa_dados01-zzwgru3 = wa_job-zzwgru3.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-matkl IS INITIAL.
        IF NOT wa_dados01-matkl = wa_job-matkl.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-prdha IS INITIAL.
        IF NOT wa_dados01-prdha = wa_job-prodh.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-zzsfac IS INITIAL.
        IF NOT wa_dados01-zzsfac = wa_job-zzsfac.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.

      CHECK NOT lv_ok IS INITIAL.

      IF NOT wa_dados01-zest_art IS INITIAL.
        IF NOT wa_dados01-zest_art = wa_job-zest_art.
          CLEAR lv_ok.
        ENDIF.
      ENDIF.


*      IF ( wa_dados01-matnr    = wa_job-matnr AND NOT wa_dados01-matnr IS INITIAL AND NOT wa_job-matnr IS INITIAL )
*      OR ( wa_dados01-zzwgru1  = wa_job-zzwgru1 AND NOT wa_dados01-zzwgru1 IS INITIAL AND NOT wa_job-zzwgru1 IS INITIAL )
*      OR ( wa_dados01-zzwgru2  = wa_job-zzwgru2 AND NOT wa_dados01-zzwgru2 IS INITIAL AND NOT wa_job-zzwgru2 IS INITIAL )
*      OR ( wa_dados01-zzwgru3  = wa_job-zzwgru3 AND NOT wa_dados01-zzwgru3 IS INITIAL AND NOT wa_job-zzwgru3 IS INITIAL )
*      OR ( wa_dados01-matkl    = wa_job-matkl AND NOT wa_dados01-matkl IS INITIAL AND NOT wa_job-matkl IS INITIAL )
*      OR ( wa_dados01-prdha    = wa_job-prodh AND NOT wa_dados01-prdha IS INITIAL AND NOT wa_job-prodh IS INITIAL )
*      OR ( wa_dados01-zzsfac   = wa_job-zzsfac AND NOT wa_dados01-zzsfac IS INITIAL AND NOT wa_job-zzsfac IS INITIAL )
*      OR ( wa_dados01-zest_art = wa_job-zest_art AND NOT wa_dados01-zest_art IS INITIAL AND NOT wa_job-zest_art IS INITIAL ).

      IF NOT lv_ok IS INITIAL.
*--< JC - 08042009


* verificar se o valor da venda ultrapassa o que esta definido como valor relevante nos premios
        IF wa_job-kbetr GE wa_dados01-ypvpmin.

*-->  JC - 05032009
          IF wa_dados01-ymont LT 0 AND wa_job-fkart EQ 'ZCD8'.
            wa_job-netwr = wa_job-netwr * -1.
          ENDIF.
*--< JC

          PERFORM save_dados04.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.                    " VALORES_PREMIO

*&---------------------------------------------------------------------*
*&      Form  TRANSF_VALUES
*&---------------------------------------------------------------------*
FORM transf_values.

  CHECK rb_sim IS INITIAL.

* eliminar todas as entradas para o periodo em analise
* marcar os dados ja existentes nas tabelas como eliminados
  DELETE FROM ytrt3001 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3002 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3003 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3004 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3005 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3006 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3007 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3008 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3009 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3010 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3011 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3012 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt3013 WHERE spmon EQ p_spmon.

* transferir valores do volume de vendas por objectivo para as tabelas
  LOOP AT gt_dados03 INTO wa_dados03.
    CASE wa_dados03-tabela.
      WHEN 'YTRT3001'.
        insert_values wa_dados03 wa_ytrt3001 ytrt3001.
      WHEN 'YTRT3002'.
        insert_values wa_dados03 wa_ytrt3002 ytrt3002.
      WHEN 'YTRT3003'.
        insert_values wa_dados03 wa_ytrt3003 ytrt3003.
      WHEN 'YTRT3004'.
        insert_values wa_dados03 wa_ytrt3004 ytrt3004.
      WHEN 'YTRT3005'.
        insert_values wa_dados03 wa_ytrt3005 ytrt3005.
      WHEN 'YTRT3006'.
        insert_values wa_dados03 wa_ytrt3006 ytrt3006.
      WHEN 'YTRT3007'.
        insert_values wa_dados03 wa_ytrt3007 ytrt3007.
      WHEN 'YTRT3008'.
        insert_values wa_dados03 wa_ytrt3008 ytrt3008.
      WHEN 'YTRT3009'.
        insert_values wa_dados03 wa_ytrt3009 ytrt3009.
      WHEN 'YTRT3010'.
        insert_values wa_dados03 wa_ytrt3010 ytrt3010.
      WHEN 'YTRT3011'.
        insert_values wa_dados03 wa_ytrt3011 ytrt3011.
      WHEN 'YTRT3012'.
        insert_values wa_dados03 wa_ytrt3012 ytrt3012.
      WHEN 'YTRT3013'.
        insert_values wa_dados03 wa_ytrt3013 ytrt3013.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " TRANSF_VALUES

*&---------------------------------------------------------------------*
*&      Form  TRANSF_PREMIOS
*&---------------------------------------------------------------------*
FORM transf_premios.

  CHECK rb_sim IS INITIAL.

* eliminar todas as entradas para o periodo em analise
* marcar os dados ja existentes nas tabelas como eliminados
  DELETE FROM ytrt4001 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4002 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4003 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4004 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4005 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4006 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4007 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4008 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4009 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4010 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4011 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4012 WHERE spmon EQ p_spmon.
  DELETE FROM ytrt4013 WHERE spmon EQ p_spmon.

* transferir valores do volume de vendas por objectivo para as tabelas
  LOOP AT gt_dados04 INTO wa_dados04.
    CASE wa_dados04-tabela.
      WHEN 'YTRT4001'.
        insert_values wa_dados04 wa_ytrt4001 ytrt4001.
      WHEN 'YTRT4002'.
        insert_values wa_dados04 wa_ytrt4002 ytrt4002.
      WHEN 'YTRT4003'.
        insert_values wa_dados04 wa_ytrt4003 ytrt4003.
      WHEN 'YTRT4004'.
        insert_values wa_dados04 wa_ytrt4004 ytrt4004.
      WHEN 'YTRT4005'.
        insert_values wa_dados04 wa_ytrt4005 ytrt4005.
      WHEN 'YTRT4006'.
        insert_values wa_dados04 wa_ytrt4006 ytrt4006.
      WHEN 'YTRT4007'.
        insert_values wa_dados04 wa_ytrt4007 ytrt4007.
      WHEN 'YTRT4008'.
        insert_values wa_dados04 wa_ytrt4008 ytrt4008.
      WHEN 'YTRT4009'.
        insert_values wa_dados04 wa_ytrt4009 ytrt4009.
      WHEN 'YTRT4010'.
        insert_values wa_dados04 wa_ytrt4010 ytrt4010.
      WHEN 'YTRT4011'.
        insert_values wa_dados04 wa_ytrt4011 ytrt4011.
      WHEN 'YTRT4012'.
        insert_values wa_dados04 wa_ytrt4012 ytrt4012.
      WHEN 'YTRT4013'.
        insert_values wa_dados04 wa_ytrt4013 ytrt4013.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " TRANSF_PREMIOS

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
      it_outtab                     = gt_dados04
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

ENDFORM.                    " LOAD_GRID

*&---------------------------------------------------------------------*
*&      Form  EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
FORM exclude_tb_functions CHANGING pt_exclude TYPE ui_functions.

  DATA ls_exclude TYPE ui_func.

  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_delete_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_append_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_insert_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_move_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_copy.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_cut.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
  APPEND ls_exclude TO pt_exclude.
  ls_exclude = cl_gui_alv_grid=>mc_fc_loc_undo.
  APPEND ls_exclude TO pt_exclude.

ENDFORM.                    " EXCLUDE_TB_FUNCTIONS

*&---------------------------------------------------------------------*
*&      Form  FILL_FIELDCATALOG
*&---------------------------------------------------------------------*
FORM fill_fieldcatalog .

  DATA: l_fieldcat TYPE lvc_s_fcat,
        lv_tabname LIKE dd02l-tabname.

*** Define o layout
  CLEAR ls_layout.

  ls_layout-zebra = 'X'.
  ls_layout-col_opt = 'X'.

*  MOVE p_table TO lv_tabname.
*  TRANSLATE lv_tabname TO UPPER CASE.

  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      i_structure_name = 'YEGN00006'
    CHANGING
      ct_fieldcat      = tab_fieldcat.

  LOOP AT tab_fieldcat INTO l_fieldcat.
    CLEAR l_fieldcat-key.
    CASE l_fieldcat-fieldname.
      WHEN 'LINE_COLOR' OR 'ELIMINADO' OR 'DESACTIVO' OR 'NAME1' OR 'NAME1_KUN' OR
           'KSCHL' OR 'WGBEZ' OR 'VTEXT_PRDHA' OR 'MAKTX' OR 'VTEXT_ZZSFAC' OR
           'DESCRICAO' OR 'YDATA' OR 'YUSER'.
        l_fieldcat-no_out = 'X'.
      WHEN 'YCOND'.
        wa_fieldcat-reptext = 'Condicional'.
      WHEN 'YMONT'.
        CLEAR: l_fieldcat-reptext, l_fieldcat-scrtext_l,
               l_fieldcat-scrtext_m, l_fieldcat-scrtext_s,
               l_fieldcat-ref_table.
        wa_fieldcat-reptext = l_fieldcat-scrtext_l = l_fieldcat-scrtext_m = l_fieldcat-scrtext_s = 'Objectivo'.
      WHEN 'PREMIO'.
        CLEAR: l_fieldcat-reptext, l_fieldcat-scrtext_l,
               l_fieldcat-scrtext_m, l_fieldcat-scrtext_s,
               l_fieldcat-ref_table.
        wa_fieldcat-reptext = 'Valor do Prémio'.
        l_fieldcat-scrtext_l = 'Valor do Prémio'.
        l_fieldcat-scrtext_m = 'Valor Prémio'.
        l_fieldcat-scrtext_s = 'Val. Pagar'.
    ENDCASE.
    MODIFY tab_fieldcat FROM l_fieldcat INDEX sy-tabix.
  ENDLOOP.

ENDFORM.                    " FILL_FIELDCATALOG

*&---------------------------------------------------------------------*
*&      Form  SAVE_DADOS04
*&---------------------------------------------------------------------*
FORM save_dados04.

  DATA: wa_temp TYPE tp_dados04.

  MOVE-CORRESPONDING wa_dados01 TO wa_dados04.
  MOVE: wa_job-pernr TO wa_dados04-pernr,
        wa_job-netwr TO wa_dados04-netwr,
        wa_job-fkimg TO wa_dados04-fkimg.
* mudar tabela para as YTRT40XX
  wa_dados04-tabela = wa_dados01-tabela.
  wa_dados04-tabela+4(1) = '4'.
* verificar se valores a transferir ja existem na tabela
  READ TABLE gt_dados04 INTO wa_temp WITH KEY spmon    = wa_dados04-spmon
                                              werks    = wa_dados04-werks
                                              zzwgru3  = wa_dados04-zzwgru3
                                              zzwgru2  = wa_dados04-zzwgru2
                                              zzwgru1  = wa_dados04-zzwgru1
                                              matkl    = wa_dados04-matkl
                                              prdha    = wa_dados04-prdha
                                              matnr    = wa_dados04-matnr
                                              zzsfac   = wa_dados04-zzsfac
                                              zest_art = wa_dados04-zest_art
                                              pernr    = wa_dados04-pernr
                                              ycond    = wa_dados04-ycond.
  IF sy-subrc EQ 0.
    ADD wa_temp-netwr TO wa_dados04-netwr.
    ADD wa_temp-fkimg TO wa_dados04-fkimg.
    MODIFY gt_dados04 FROM wa_dados04 INDEX sy-tabix.
  ELSE.
    APPEND wa_dados04 TO gt_dados04.
  ENDIF.

ENDFORM.                    " SAVE_DADOS04

*&---------------------------------------------------------------------*
*&      Form  SAVE_DADOS03
*&---------------------------------------------------------------------*
FORM save_dados03.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      input  = wa_dados03-kunnr
    IMPORTING
      output = wa_dados03-kunnr.
* mudar tabela para as YTRT30XX
  wa_dados03-tabela+4(1) = '3'.
  wa_dados03-yrealizado = wa_job-netwr.
  wa_dados03-ydata = sy-datum.
  wa_dados03-yuser = sy-uname.
  DATA: wa_temp TYPE tp_dados03.
  READ TABLE gt_dados03 INTO wa_temp WITH KEY spmon = wa_dados03-spmon
                                              werks = wa_dados03-werks
                                              kunnr = wa_dados03-kunnr
                                              zzwgru3 = wa_dados03-zzwgru3
                                              zzwgru2 = wa_dados03-zzwgru2
                                              zzwgru1 = wa_dados03-zzwgru1
                                              matkl = wa_dados03-matkl
                                              zzprdha = wa_dados03-zzprdha
                                              matnr = wa_dados03-matnr
                                              zzsfac = wa_dados03-zzsfac
                                              zest_art = wa_dados03-zest_art
                                              ycond    = wa_dados04-ycond.
  IF sy-subrc EQ 0.
    wa_dados03-yrealizado = wa_dados03-yrealizado + wa_temp-yrealizado.
    MODIFY gt_dados03 FROM wa_dados03 INDEX sy-tabix.
  ELSE.
    APPEND wa_dados03 TO gt_dados03.
  ENDIF.

ENDFORM.                    " SAVE_DADOS03

*&---------------------------------------------------------------------*
*&      Form  CALCULO_PREMIO
*&---------------------------------------------------------------------*
FORM calculo_premio .

  DATA: lv_tabix TYPE sytabix.
  DATA: lv_pagar TYPE xflag.

* INI - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
  data: lv_realizado type YREALIZADO.
* FIM - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I

  LOOP AT gt_dados04 INTO wa_dados04.
    lv_tabix = sy-tabix.

**-->JC - 17042009 - Pelo menos 1 objectivo
*    READ TABLE gt_dados03 INTO wa_dados03
*      WITH KEY spmon = wa_dados04-spmon
*               werks = wa_dados04-werks
*               kunnr = wa_dados04-pernr.
*
*    CHECK sy-subrc EQ 0.
**-->JC - 17042009


*-->JC - 04032009 - Verificar objectivo


    READ TABLE gt_dados03 INTO wa_dados03
      WITH KEY spmon = wa_dados04-spmon
               werks = wa_dados04-werks
               zzwgru3 = wa_dados04-zzwgru3
               zzwgru2 = wa_dados04-zzwgru2
               zzwgru1 = wa_dados04-zzwgru1
               matkl = wa_dados04-matkl
               zzprdha = wa_dados04-prdha
               matnr = wa_dados04-matnr
               zzsfac = wa_dados04-zzsfac
               zest_art = wa_dados04-zest_art
               kunnr = wa_dados04-pernr
               ycond    = wa_dados04-ycond.

    IF sy-subrc EQ 0.
*     Só paga prémio se atingir objectivo
      CHECK NOT wa_dados03-ypagar IS INITIAL.
    ENDIF.
*--<JC - 04032009 - Verificar objectivo

*-->JC - 08042009 -
*   Se fôr condicional todos os objectivos tem de ser atingidos
    lv_pagar = 'X'.

    IF NOT wa_dados04-ycond IS INITIAL.
* INI - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
      lv_realizado = 0.
* FIM - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
      LOOP AT gt_dados03 INTO wa_dados03
        WHERE spmon = wa_dados04-spmon
        AND werks = wa_dados04-werks
        AND kunnr = wa_dados04-pernr.
* INI - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
*        IF wa_dados03-ypagar IS INITIAL.
*          CLEAR lv_pagar.
*        ENDIF.
        lv_realizado = lv_realizado + wa_dados03-YREALIZADO.
* FIM SUBST
* FIM - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
      ENDLOOP.
* INI - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
      if sy-subrc = 0.
        if wa_dados03-ymont > lv_realizado.
          clear lv_pagar.
        endif.
      endif.
* FIM - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - I
    ENDIF.

    CHECK NOT lv_pagar IS INITIAL.
*--<JC - 08042009

    IF wa_dados04-fixo IS NOT INITIAL AND wa_dados04-tipo EQ '%'.
      wa_dados04-premio = ( wa_dados04-ymont / 100 ) * wa_dados04-netwr.
    ELSEIF wa_dados04-fixo IS NOT INITIAL AND wa_dados04-tipo EQ '€'.
      wa_dados04-premio = wa_dados04-ymont.
    ENDIF.

    IF wa_dados04-fixo IS INITIAL AND wa_dados04-tipo EQ '€'.
* verificar se os valores sao negativos
      IF wa_dados04-ymont LT 0 AND wa_dados04-fkimg LT 0.
        wa_dados04-fkimg = wa_dados04-fkimg * -1.
      ENDIF.
      wa_dados04-premio = TRUNC( wa_dados04-fkimg / wa_dados04-mult ) * wa_dados04-ymont.
    ENDIF.
    MODIFY gt_dados04 FROM wa_dados04 INDEX lv_tabix.
  ENDLOOP.

ENDFORM.                    " CALCULO_PREMIO


*&---------------------------------------------------------------------*
*&      Form  premio_loja
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM premio_loja.

  DATA: lv_tabix TYPE sytabix.

* Colaborador que recebem prémio de lojas
  LOOP AT gt_dados05 INTO wa_dados05.
*   Vendas da loja
    READ TABLE gt_lj INTO wa_lj
      WITH KEY spmon = wa_dados05-spmon
               werks = wa_dados05-werks.

    IF sy-subrc EQ 0.
*     Objectivo da loja
      READ TABLE gt_obj_lj INTO wa_obj_lj
        WITH KEY spmon = wa_lj-spmon
                 werks = wa_lj-werks.

      IF sy-subrc EQ 0.
        IF wa_lj-netwr GE wa_obj_lj-ymont.
*         Prémio da loja
          READ TABLE gt_prm_lj INTO wa_prm_lj
            WITH KEY spmon = wa_lj-spmon
                     werks = wa_lj-werks.

          IF sy-subrc EQ 0.
            clear wa_dados04.
            MOVE-CORRESPONDING wa_dados05 TO wa_dados04.
            wa_dados04-pernr = wa_dados05-kunnr.
            wa_dados04-premio = wa_prm_lj-ymont.
            APPEND wa_dados04 TO gt_dados04.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.                    "premio_loja
* INI - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III
*&---------------------------------------------------------------------*
*&      Form  GET_ACTIVE_SALESMAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
form GET_ACTIVE_SALESMAN .
  refresh r_salesman.
  loop at gt_dados02[] into wa_dados02.
    r_salesman-option = 'EQ'.
    r_salesman-sign = 'I'.
    r_salesman-low = wa_dados02-kunnr.
    read table r_salesman transporting no fields
         with key low = wa_dados02-kunnr.
    if sy-subrc <> 0.
      append r_salesman.
    endif.
  endloop.
endform.                    " GET_ACTIVE_SALESMAN
* FIM - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III
