*&---------------------------------------------------------------------*
*& Report  YRE00005UPDJP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT yre00005updjp MESSAGE-ID yac.

INCLUDE yre00005updjp_top.
INCLUDE yre00005updjp_frm.

INITIALIZATION.
  p_erdat = sy-datum - 1.
  PERFORM get_fkart.

START-OF-SELECTION.
  PERFORM get_data.

END-OF-SELECTION.
  IF NOT gt_ytrt00001[] IS INITIAL .
    IF p_test EQ ''.
      PERFORM update_table.
      MESSAGE i000 WITH 'Dados criados com sucesso.'.
    ENDIF.
    PERFORM list_values.
  ELSE.
    MESSAGE i000 WITH 'Não tem valores a listar.'.
  ENDIF.
