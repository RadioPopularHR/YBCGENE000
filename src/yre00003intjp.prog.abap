*&---------------------------------------------------------------------*
*& Report  YRE00003INTJP
*&
*&---------------------------------------------------------------------*
*& Carregamento das tabelas YTRT1001 ate YTRT1013
*&
*&---------------------------------------------------------------------*
REPORT yre00003intjp NO STANDARD PAGE HEADING MESSAGE-ID yac.


INCLUDE yre00003intjp_top.
INCLUDE yre00003intjp_class.
INCLUDE yre00003intjp_def.
INCLUDE yre00003intjp_frm.
INCLUDE yre00003intjp_pbo.
INCLUDE yre00003intjp_pai.

START-OF-SELECTION.
  CLEAR: gv_save, gv_erro_txt.
* validar nome da tabela
  IF NOT p_table BETWEEN 'YTRT1001' AND 'YTRT1013'.
    MESSAGE i000 WITH 'Tipo de Condição errada.'.
  ELSE.
*    IF NOT so_werks IS INITIAL AND NOT sd_werks IS INITIAL.
*      DATA: lv_txt(50) TYPE c.
*      CONCATENATE 'As lojas serão criadas por cópia da' so_werks-low
*        INTO lv_txt SEPARATED BY space.
*      CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
*        EXPORTING
*          defaultoption = 'N'
*          textline1     = lv_txt
*          textline2     = 'Deseja continuar?'
*          titel         = 'Aviso'
*          start_column  = 25
*          start_row     = 6
*        IMPORTING
*          answer        = lv_answer.
*      IF lv_answer EQ 'J'.
*        PERFORM copia_completa.
*      ENDIF.
*    ELSE.
    IF rb_op1 EQ 'X'.
      IF p_spmon EQ p_ref.
        MESSAGE i000 WITH 'O período de referência não pode ser o próprio.'.
      ELSE.
        PERFORM get_data.
        IF gt_yegn00001[] IS INITIAL.
          MESSAGE i000 WITH 'Não tem registos para listar.'.
        ELSE.
          CALL SCREEN 100.
        ENDIF.
      ENDIF.
    ELSE.
      p_ref = p_spmon.
      PERFORM get_data.
      IF rb_op3 EQ 'X' AND gv_dados IS INITIAL.
        MESSAGE i000 WITH 'Não tem registos para listar.'.
      ELSE.
        CALL SCREEN 100.
      ENDIF.
    ENDIF.
*    ENDIF.
  ENDIF.

END-OF-SELECTION.
