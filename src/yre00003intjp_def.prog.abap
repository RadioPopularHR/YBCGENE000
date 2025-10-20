*&---------------------------------------------------------------------*
*&  Include           YRE00003INTJP_DEF
*&---------------------------------------------------------------------*

* campos dos descritivos para aparecerem na listagem
DEFINE field_names.

  read table tab_fieldcat into l_fieldcat
                          with key fieldname = &1.
  if &4 is initial.
    clear: l_fieldcat-no_out,
           l_fieldcat-edit.
  else.
    clear: l_fieldcat-no_out.
  endif.
*  l_fieldcat-outputlen = &2.
  l_fieldcat-intlen = &2.
  clear: l_fieldcat-reptext, l_fieldcat-scrtext_l,
         l_fieldcat-scrtext_m, l_fieldcat-scrtext_s,
         l_fieldcat-ref_table.
  l_fieldcat-reptext = &3.
  modify tab_fieldcat from l_fieldcat index sy-tabix.

END-OF-DEFINITION.

* descricao para as niveis de produtos
DEFINE desc_nivel.

  select single kschl
    into corresponding fields of gt_yegn00001
    from swor as s inner join klah as k
                   on k~clint eq s~clint
    where class eq &1
      and klagr eq &2.
  if sy-subrc ne 0.
    gv_erro_txt = 'Valor Inválido para o Nível!'.
    message e000 with gv_erro_txt.
  else.
    clear gv_erro_txt.
  endif.

END-OF-DEFINITION.

* descricao do grupo de mercadorias
DEFINE grp_merc.

  select single wgbez
    into gt_yegn00001-wgbez
    from t023t
    where spras eq sy-langu
      and matkl eq &1.

END-OF-DEFINITION.

* descricao para a hierarquia de produtos
DEFINE desc_hier.

  select single vtext
    into gt_yegn00001-vtext_prdha
    from t179t
    where spras eq sy-langu
      and prodh eq &1.

END-OF-DEFINITION.

* descricao do material
DEFINE desc_mat.

  select single maktx
    into corresponding fields of gt_yegn00001
    from makt
    where spras eq sy-langu
      and matnr eq &1.

END-OF-DEFINITION.

* descricao do estado do artigo
DEFINE desc_est.

  select single descricao
    into corresponding fields of gt_yegn00001
    from ytre00005
    where zest_art eq &1
      and spras eq sy-langu.
  if sy-subrc ne 0.
    gv_erro_txt = 'Valor Inválido para o Estado do Artigo!'.
    message e000 with gv_erro_txt.
  else.
    clear gv_erro_txt.
  endif.

END-OF-DEFINITION.

DEFINE ler_valores.

  select *
    into corresponding fields of table &1
    from &2
    where spmon eq p_spmon
      and werks in s_werks.

END-OF-DEFINITION.

* descritivo para o tipo de condicao
DEFINE desc_tpcond.

  select single vtext
    into gt_yegn00001-vtext_zzsfac
    from t685t
    where spras eq sy-langu
      and kvewe eq 'A'
      and kappl eq 'V'
      and kschl eq &1.
  if sy-subrc ne 0.
    gv_erro_txt = 'Valor Inválido para o Tipo de Condição!'.
    message e000 with gv_erro_txt.
  else.
    clear gv_erro_txt.
  endif.

END-OF-DEFINITION.

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

DEFINE delete_val.

  delete &1 where eliminado eq 'X'.
  delete &1 where desactivo eq 'X'.

END-OF-DEFINITION.
