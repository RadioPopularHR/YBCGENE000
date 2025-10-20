*----------------------------------------------------------------------*
***INCLUDE YRE00003INTJP_PAI .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0100  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE user_command_0100 INPUT.

  DATA: lv_cont TYPE i,
        lv_text1 TYPE string,
        lv_text2 TYPE string,
        lv_flag(1),
        lv_answer(1).

  DATA: lv_lines_tab  TYPE i,
        lv_lines_save TYPE i.

  DATA: verify(1),
        refresh(1).

  DATA: lv_tabix LIKE sy-tabix.

* guardar valores existem ja na base de dados.
  CASE p_table.
    WHEN 'YTRT1001'.
      ler_valores gt_ytrt1001 ytrt1001.
    WHEN 'YTRT1002'.
      ler_valores gt_ytrt1002 ytrt1002.
    WHEN 'YTRT1003'.
      ler_valores gt_ytrt1003 ytrt1003.
    WHEN 'YTRT1004'.
      ler_valores gt_ytrt1004 ytrt1004.
    WHEN 'YTRT1005'.
      ler_valores gt_ytrt1005 ytrt1005.
    WHEN 'YTRT1006'.
      ler_valores gt_ytrt1006 ytrt1006.
    WHEN 'YTRT1007'.
      ler_valores gt_ytrt1007 ytrt1007.
    WHEN 'YTRT1008'.
      ler_valores gt_ytrt1008 ytrt1008.
    WHEN 'YTRT1009'.
      ler_valores gt_ytrt1009 ytrt1009.
    WHEN 'YTRT1010'.
      ler_valores gt_ytrt1010 ytrt1010.
    WHEN 'YTRT1011'.
      ler_valores gt_ytrt1011 ytrt1011.
    WHEN 'YTRT1012'.
      ler_valores gt_ytrt1012 ytrt1012.
    WHEN 'YTRT1013'.
      ler_valores gt_ytrt1013 ytrt1013.
  ENDCASE.

  CASE okcode.
    WHEN '&F03' OR '&F15' OR '&F12'.
      IF rb_op3 IS INITIAL.
        PERFORM trata_dados USING 'V'.

        DESCRIBE TABLE <save> LINES lv_lines_save.
        IF lv_lines_save IS INITIAL OR NOT gv_save IS INITIAL.
          SET SCREEN 0. LEAVE SCREEN.
        ELSE.
          CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
            EXPORTING
              defaultoption = 'N'
              textline1     = 'Os valores serão perdidos!'
              titel         = 'Aviso'
              start_column  = 25
              start_row     = 6
            IMPORTING
              answer        = lv_answer.
          IF lv_answer EQ 'J'.
            SET SCREEN 0. LEAVE SCREEN.
          ENDIF.
        ENDIF.
      ELSE.
        SET SCREEN 0. LEAVE SCREEN.
      ENDIF.

    WHEN 'ACTUALIZA'.
      DATA: ls_stable      TYPE lvc_s_stbl,
            l_soft_refresh TYPE char01.
      ls_stable-col = 'X'.
      ls_stable-row = 'X'.
      l_soft_refresh = space.

**********************************************************************
* actualizar descritivos na listagem
      CLEAR gt_yegn00001. REFRESH gt_yegn00001.
      LOOP AT <tab> ASSIGNING <line>.
* validar que as hierarquias estao com descritivo
        MOVE-CORRESPONDING <line> TO gt_yegn00001.
        PERFORM get_desc.
        APPEND gt_yegn00001.
      ENDLOOP.

      PERFORM fill_fieldcatalog.
**********************************************************************
      CALL METHOD alv_grid->refresh_table_display
        EXPORTING
          is_stable      = ls_stable
          i_soft_refresh = l_soft_refresh.
    WHEN 'VALIDAR'.
      IF NOT gv_erro_txt IS INITIAL.
        MESSAGE e000 WITH gv_erro_txt.
      ENDIF.
      CHECK gv_erro_txt IS INITIAL.
**********************************************************************
* validar valores a serem gravados na base de dados
      CLEAR: lv_lines_tab, lv_lines_save.
      DESCRIBE TABLE <tab> LINES lv_lines_tab.

      PERFORM trata_dados USING 'V'.

      DESCRIBE TABLE <save> LINES lv_lines_save.
      IF lv_lines_save IS INITIAL.
        MESSAGE i000 WITH 'Não tem valores a gravar.'.
      ELSE.
**********************************************************************
        CASE p_table.
          WHEN 'YTRT1001'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks zzwgru3 ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1001 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              zzwgru3 = gt_yegn00001-zzwgru3
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1001-desactivo = 'X'.
                APPEND gt_ytrt1001 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1002'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks zzwgru2 ycond.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
            LOOP AT gt_yegn00001 where changed = 'X'.
              lv_tabix = sy-tabix.
* INI - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
*              READ TABLE gt_ytrt1002 WITH KEY spmon = gt_yegn00001-spmon
*                                              werks = gt_yegn00001-werks
*                                              zzwgru2 = gt_yegn00001-zzwgru2
*                                              eliminado = ''
*                                              desactivo = ''.
* FIM SUBST
              READ TABLE gt_ytrt1002 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              zzwgru2 = gt_yegn00001-zzwgru2
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
* FIM - ROFF - VN/MJB - Oc.3890172 - Alterações 2010.03.15
              IF sy-subrc EQ 0.
                gt_ytrt1002-desactivo = 'X'.
                APPEND gt_ytrt1002 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1003'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks zzwgru1 ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1003 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              zzwgru1 = gt_yegn00001-zzwgru1
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1003-desactivo = 'X'.
                APPEND gt_ytrt1003 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1004'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks matkl ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1004 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              matkl = gt_yegn00001-matkl
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1004-desactivo = 'X'.
                APPEND gt_ytrt1004 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1005'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks prdha zzwgru3 ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1005 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              prdha = gt_yegn00001-prdha
                                              zzwgru3 = gt_yegn00001-zzwgru3
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1005-desactivo = 'X'.
                APPEND gt_ytrt1005 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1006'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks prdha zzwgru2 ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1006 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              prdha = gt_yegn00001-prdha
                                              zzwgru2 = gt_yegn00001-zzwgru2
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1006-desactivo = 'X'.
                APPEND gt_ytrt1006 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1007'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks prdha zzwgru1 ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1007 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              prdha = gt_yegn00001-prdha
                                              zzwgru1 = gt_yegn00001-zzwgru1
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1007-desactivo = 'X'.
                APPEND gt_ytrt1007 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1008'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks prdha matkl ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1008 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              prdha = gt_yegn00001-prdha
                                              matkl = gt_yegn00001-matkl
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1008-desactivo = 'X'.
                APPEND gt_ytrt1008 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1009'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks prdha ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1009 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              prdha = gt_yegn00001-prdha
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1009-desactivo = 'X'.
                APPEND gt_ytrt1009 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1010'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks matnr ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1010 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              matnr = gt_yegn00001-matnr
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1010-desactivo = 'X'.
                APPEND gt_ytrt1010 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1011'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1011 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1011-desactivo = 'X'.
                APPEND gt_ytrt1011 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1012'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks zzsfac ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1012 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              zzsfac = gt_yegn00001-zzsfac
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1012-desactivo = 'X'.
                APPEND gt_ytrt1012 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.
          WHEN 'YTRT1013'.
            DELETE ADJACENT DUPLICATES FROM gt_yegn00001
                                       COMPARING spmon werks zest_art ycond.
            LOOP AT gt_yegn00001 WHERE changed = 'X'.
              lv_tabix = sy-tabix.
              READ TABLE gt_ytrt1013 WITH KEY spmon = gt_yegn00001-spmon
                                              werks = gt_yegn00001-werks
                                              zest_art = gt_yegn00001-zest_art
                                              ycond = gt_yegn00001-ycond
                                              eliminado = ''
                                              desactivo = ''.
              IF sy-subrc EQ 0.
                gt_ytrt1013-desactivo = 'X'.
                APPEND gt_ytrt1013 TO <save>.
                lv_flag = 1.
                gt_yegn00001-line_color = 'C610'.
                MODIFY gt_yegn00001 INDEX lv_tabix.
              ELSE.
                gt_yegn00001-line_color = ''.
                MODIFY gt_yegn00001 INDEX lv_tabix.
                IF NOT lv_flag EQ '1'.
                  lv_flag = 0.
                ENDIF.
              ENDIF.
            ENDLOOP.

        ENDCASE.

        PERFORM fill_fieldcatalog.
**********************************************************************
        CALL METHOD alv_grid->refresh_table_display
          EXPORTING
            is_stable      = ls_stable
            i_soft_refresh = l_soft_refresh.

**********************************************************************
        IF lv_flag EQ '1'.
          lv_text1 = 'As linhas vermelhas serão sobregravadas.'.
          lv_text2 = 'Deseja continuar?'.
        ELSEIF lv_flag EQ '0'.
          lv_text1 = 'Valores ok para gravar.'.
          lv_text2 = 'Deseja continuar?'.
        ENDIF.

        CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
          EXPORTING
            defaultoption = 'N'
            textline1     = lv_text1
            textline2     = lv_text2
            titel         = 'Gravação de Dados'
            start_column  = 25
            start_row     = 6
          IMPORTING
            answer        = lv_answer.
        IF lv_answer EQ 'J'.
          IF lv_flag EQ 0.
            PERFORM trata_dados USING 'I'.
          ELSEIF lv_flag EQ 1.
            PERFORM trata_dados USING 'D'.
          ENDIF.
          MESSAGE i000 WITH 'Dados gravados com sucesso.'.
          gv_save = 'X'.
          SET SCREEN 0. LEAVE SCREEN.
        ELSE.
          MESSAGE i000 WITH 'Dados não gravados.'.
        ENDIF.
      ENDIF.
  ENDCASE.

ENDMODULE.                 " USER_COMMAND_0100  INPUT
