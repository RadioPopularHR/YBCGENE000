*&---------------------------------------------------------------------*
*&  Include           YRE00008INTJP_DEF
*&---------------------------------------------------------------------*

DEFINE get_dados01.

  select *
    into corresponding fields of &1
    from &3
    where spmon eq p_spmon
      and werks in s_werks
      and eliminado eq ''
      and desactivo eq ''.
    &1-tabela = '&3'.
    append &1 to &2.
    clear &1.
  endselect.

END-OF-DEFINITION.

DEFINE get_dados02.

  select *
    into corresponding fields of &1
    from &3
    where spmon eq p_spmon
      and werks in s_werks
      and eliminado eq ''
      and desactivo eq ''.
    &1-tabela = '&3'.
    append &1 to &2.
    clear &1.
  endselect.

END-OF-DEFINITION.

DEFINE insert_values.

  move-corresponding &1 to &2.
  move-corresponding sy to &2.
  insert into &3 values &2.

END-OF-DEFINITION.
