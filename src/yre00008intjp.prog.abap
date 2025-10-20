*&---------------------------------------------------------------------*
*& Report  YRE00008INTJP
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*
REPORT yre00008intjp NO STANDARD PAGE HEADING MESSAGE-ID yac.

INCLUDE yre00008intjp_class.
INCLUDE yre00008intjp_top.
INCLUDE yre00008intjp_def.
INCLUDE yre00008intjp_frm.
INCLUDE yre00008intjp_pbo.
INCLUDE yre00008intjp_pai.

START-OF-SELECTION.
  loaded_grid = space.
  REFRESH: gt_dados01[], gt_dados02[], gt_job[].
  PERFORM get_dados.
  CHECK NOT gt_dados01[] IS INITIAL.
*  CHECK NOT gt_dados02[] IS INITIAL.
  CHECK NOT gt_job[] IS INITIAL.
* INI - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III
  perform get_active_salesman.
* FIM - ROFF - VN/MJB - Oc.3890172 - Com.Vendas - 2010.04.30 - III
  PERFORM valores_premio.
  PERFORM valores_objectivos.
* calculo do valor do premio por cada linha calculada
  PERFORM calculo_premio.
* JC - 13052009
  perform premio_loja.
* JC

END-OF-SELECTION.
* IF NOT gt_dados03[] IS INITIAL.
    PERFORM transf_values.
    IF NOT gt_dados04[] IS INITIAL.
      PERFORM transf_premios.
    ENDIF.
    CALL SCREEN 100.
*  else.
*    MESSAGE i000 WITH 'Não tem valores a listar.'.
*  ENDIF.
