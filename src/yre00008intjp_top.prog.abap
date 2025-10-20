*&---------------------------------------------------------------------*
*&  Include           YRE00008INTJP_TOP
*&---------------------------------------------------------------------*
TYPE-POOLS: slis.

TYPES: BEGIN OF tp_dados01.
        INCLUDE STRUCTURE yegn00001.
TYPES   tabela(15) TYPE c.
TYPES  END OF tp_dados01.

TYPES: BEGIN OF tp_dados02.
        INCLUDE STRUCTURE yegn00002.
TYPES   tabela(15) TYPE c.
* INI - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - II
TYPES   acumul type yrealizado.
* FIM - ROFF - VN/MJB - Comissões de Vendas - 2010.04.27 - II
TYPES  END OF tp_dados02.

TYPES: BEGIN OF tp_dados03.
        INCLUDE STRUCTURE yegn00005.
TYPES   tabela(15) TYPE c.
TYPES  END OF tp_dados03.

TYPES: BEGIN OF tp_dados04.
        INCLUDE STRUCTURE yegn00006.
TYPES   tabela(15) TYPE c.
TYPES  END OF tp_dados04.

TYPES: BEGIN OF tp_job.
        INCLUDE STRUCTURE ytrt00001.
TYPES   tabela(15) TYPE c.
TYPES  END OF tp_job.

* JC - 13052009
TYPES: BEGIN OF tp_lj,
        spmon LIKE ytrt2011-spmon,
        werks LIKE ytrt2011-werks,
        netwr LIKE vbrp-netwr,
       END OF tp_lj.

TYPES: BEGIN OF tp_obj_lj,
        spmon LIKE ytrt2011-spmon,
        werks LIKE ytrt2011-werks,
        ymont LIKE ytrt2011-ymont,
       END OF tp_obj_lj.

TYPES: BEGIN OF tp_prm_lj,
        spmon LIKE ytrt1011-spmon,
        werks LIKE ytrt1011-werks,
        ymont LIKE ytrt1011-ymont,
       END OF tp_prm_lj.
*

TABLES: ytrt1001, ytrt2001, ytrt3001,
        ytrt1002, ytrt2002, ytrt3002,
        ytrt1003, ytrt2003, ytrt3003,
        ytrt1004, ytrt2004, ytrt3004,
        ytrt1005, ytrt2005, ytrt3005,
        ytrt1006, ytrt2006, ytrt3006,
        ytrt1007, ytrt2007, ytrt3007,
        ytrt1008, ytrt2008, ytrt3008,
        ytrt1009, ytrt2009, ytrt3009,
        ytrt1010, ytrt2010, ytrt3010,
        ytrt1011, ytrt2011, ytrt3011,
        ytrt1012, ytrt2012, ytrt3012,
        ytrt1013, ytrt2013, ytrt3013.

TABLES: yegn00001, yegn00002, yegn00005.

* OO
DATA: alv_grid     TYPE REF TO cl_gui_alv_grid,
      container    TYPE REF TO cl_gui_custom_container,
      ls_layout    TYPE lvc_s_layo,
      tab_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat  TYPE lvc_s_fcat,
      okcode       LIKE sy-ucomm.

*** Definição do objecto que vai receber os eventos
DATA: event_receiver TYPE REF TO lcl_event_receiver.
* OO

DATA: gt_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv.

DATA: gt_dados01 TYPE tp_dados01 OCCURS 0,
      wa_dados01 TYPE tp_dados01,
      gt_dados02 TYPE tp_dados02 OCCURS 0,
      wa_dados02 TYPE tp_dados02,
      gt_dados03 TYPE tp_dados03 OCCURS 0,
      wa_dados03 TYPE tp_dados03,
      gt_dados04 TYPE tp_dados04 OCCURS 0,
      wa_dados04 TYPE tp_dados04,
      gt_job     TYPE tp_job OCCURS 0,
      wa_job     TYPE tp_job,
      gt_job_fnl TYPE tp_job OCCURS 0,
      wa_job_fnl TYPE tp_job,
* JC - 13052009
      gt_job_lj  TYPE tp_job OCCURS 0,
      wa_job_lj  TYPE tp_job,
      gt_lj TYPE tp_lj OCCURS 0,
      wa_lj TYPE tp_lj,
      gt_obj_lj TYPE tp_obj_lj OCCURS 0,
      wa_obj_lj TYPE tp_obj_lj,
      gt_prm_lj TYPE tp_prm_lj OCCURS 0,
      wa_prm_lj TYPE tp_prm_lj,
      gt_dados05 TYPE ytrt5001 OCCURS 0,
      wa_dados05 TYPE ytrt5001.
* JC

DATA: wa_ytrt3001 LIKE ytrt3001,
      wa_ytrt3002 LIKE ytrt3002,
      wa_ytrt3003 LIKE ytrt3003,
      wa_ytrt3004 LIKE ytrt3004,
      wa_ytrt3005 LIKE ytrt3005,
      wa_ytrt3006 LIKE ytrt3006,
      wa_ytrt3007 LIKE ytrt3007,
      wa_ytrt3008 LIKE ytrt3008,
      wa_ytrt3009 LIKE ytrt3009,
      wa_ytrt3010 LIKE ytrt3010,
      wa_ytrt3011 LIKE ytrt3011,
      wa_ytrt3012 LIKE ytrt3012,
      wa_ytrt3013 LIKE ytrt3013,
      wa_ytrt4001 LIKE ytrt4001,
      wa_ytrt4002 LIKE ytrt4002,
      wa_ytrt4003 LIKE ytrt4003,
      wa_ytrt4004 LIKE ytrt4004,
      wa_ytrt4005 LIKE ytrt4005,
      wa_ytrt4006 LIKE ytrt4006,
      wa_ytrt4007 LIKE ytrt4007,
      wa_ytrt4008 LIKE ytrt4008,
      wa_ytrt4009 LIKE ytrt4009,
      wa_ytrt4010 LIKE ytrt4010,
      wa_ytrt4011 LIKE ytrt4011,
      wa_ytrt4012 LIKE ytrt4012,
      wa_ytrt4013 LIKE ytrt4013.

data: loaded_grid type flag.

* INI - ROFF - VN/MJB - Oc.Oc.3890172 Com.Vendas - 2010.04.30 - III
ranges: r_salesman for pernr.
* FIM - ROFF - VN/MJB - Oc.Oc.3890172 Com.Vendas - 2010.04.30 - III

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
SELECT-OPTIONS: s_werks FOR yegn00002-werks.
PARAMETERS: p_spmon LIKE yegn00002-spmon OBLIGATORY.
SELECT-OPTIONS: s_gru3 FOR yegn00002-zzwgru3,
                s_matnr FOR yegn00002-matnr,
                s_kunnr FOR yegn00002-kunnr.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: rb_int   RADIOBUTTON GROUP rb,
            rb_final RADIOBUTTON GROUP rb,
            rb_sim   RADIOBUTTON GROUP rb DEFAULT 'X'.
SELECTION-SCREEN END OF BLOCK b2.
