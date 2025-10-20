*&---------------------------------------------------------------------*
*&  Include           YRE00003INTJP_TOP
*&---------------------------------------------------------------------*

TABLES: ytrt1001, ytrt1002, ytrt1003, ytrt1004, ytrt1005, ytrt1006,
        ytrt1007, ytrt1008, ytrt1009, ytrt1010, ytrt1011, ytrt1012,
        ytrt1013, t001k.

TABLES: yegn00001.
DATA: gt_yegn00001 TYPE yegn00001 OCCURS 0 WITH HEADER LINE.

TYPE-POOLS: slis.

* OO
DATA: alv_grid     TYPE REF TO cl_gui_alv_grid,
      container    TYPE REF TO cl_gui_custom_container,
      ls_layout    TYPE lvc_s_layo,
      tab_fieldcat TYPE lvc_t_fcat,
      wa_fieldcat  TYPE lvc_s_fcat,
      okcode       LIKE sy-ucomm.


DATA: gt_layout   TYPE slis_layout_alv,
      gt_fieldcat TYPE slis_t_fieldcat_alv.

DATA: wa_ytrt1001 LIKE ytrt1001, wa_ytrt1002 LIKE ytrt1002,
      wa_ytrt1003 LIKE ytrt1003, wa_ytrt1004 LIKE ytrt1004,
      wa_ytrt1005 LIKE ytrt1005, wa_ytrt1006 LIKE ytrt1006,
      wa_ytrt1007 LIKE ytrt1007, wa_ytrt1008 LIKE ytrt1008,
      wa_ytrt1009 LIKE ytrt1009, wa_ytrt1010 LIKE ytrt1010,
      wa_ytrt1011 LIKE ytrt1011, wa_ytrt1012 LIKE ytrt1012,
      wa_ytrt1013 LIKE ytrt1013.

DATA: gt_ytrt1001 LIKE TABLE OF ytrt1001 WITH HEADER LINE,
      gt_ytrt1002 LIKE TABLE OF ytrt1002 WITH HEADER LINE,
      gt_ytrt1003 LIKE TABLE OF ytrt1003 WITH HEADER LINE,
      gt_ytrt1004 LIKE TABLE OF ytrt1004 WITH HEADER LINE,
      gt_ytrt1005 LIKE TABLE OF ytrt1005 WITH HEADER LINE,
      gt_ytrt1006 LIKE TABLE OF ytrt1006 WITH HEADER LINE,
      gt_ytrt1007 LIKE TABLE OF ytrt1007 WITH HEADER LINE,
      gt_ytrt1008 LIKE TABLE OF ytrt1008 WITH HEADER LINE,
      gt_ytrt1009 LIKE TABLE OF ytrt1009 WITH HEADER LINE,
      gt_ytrt1010 LIKE TABLE OF ytrt1010 WITH HEADER LINE,
      gt_ytrt1011 LIKE TABLE OF ytrt1011 WITH HEADER LINE,
      gt_ytrt1012 LIKE TABLE OF ytrt1012 WITH HEADER LINE,
      gt_ytrt1013 LIKE TABLE OF ytrt1013 WITH HEADER LINE.

DATA: new1001 LIKE ytrt1001 OCCURS 0 WITH HEADER LINE,
      new1002 LIKE ytrt1002 OCCURS 0 WITH HEADER LINE,
      new1003 LIKE ytrt1003 OCCURS 0 WITH HEADER LINE,
      new1004 LIKE ytrt1004 OCCURS 0 WITH HEADER LINE,
      new1005 LIKE ytrt1005 OCCURS 0 WITH HEADER LINE,
      new1006 LIKE ytrt1006 OCCURS 0 WITH HEADER LINE,
      new1007 LIKE ytrt1007 OCCURS 0 WITH HEADER LINE,
      new1008 LIKE ytrt1008 OCCURS 0 WITH HEADER LINE,
      new1009 LIKE ytrt1009 OCCURS 0 WITH HEADER LINE,
      new1010 LIKE ytrt1010 OCCURS 0 WITH HEADER LINE,
      new1011 LIKE ytrt1011 OCCURS 0 WITH HEADER LINE,
      new1012 LIKE ytrt1012 OCCURS 0 WITH HEADER LINE,
      new1013 LIKE ytrt1013 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_global OCCURS 0,
        mandt TYPE mandt,
        spmon TYPE spmon,
        werks TYPE werks_d,
*--> JC 03042009
*        ycond TYPE ycond,
*<-- JC 03042009
      END OF gt_global.

TYPES: BEGIN OF type_verify,
        ymont TYPE kbetr_kond,
        ypvpmin TYPE ypvpmin,
      END OF type_verify.
DATA: wa_verify TYPE type_verify.

DATA: w_ref TYPE REF TO data.
FIELD-SYMBOLS: <tab>  TYPE STANDARD TABLE,
               <save> TYPE STANDARD TABLE,
               <line> TYPE ANY.

DATA: gv_werks LIKE ytrt1001-werks,
      gv_save  TYPE c,
      gv_erro_txt(50),
      gv_dados TYPE c.

DATA: gt_dd02t LIKE TABLE OF dd02t WITH HEADER LINE.

*SELECTION-SCREEN BEGIN OF TABBED BLOCK tabb1 FOR 17 LINES.
*SELECTION-SCREEN TAB (15) text-100 USER-COMMAND ucomm1
*DEFAULT SCREEN 101.
*SELECTION-SCREEN TAB (15) text-200 USER-COMMAND ucomm2
*DEFAULT SCREEN 102.
*SELECTION-SCREEN END OF BLOCK tabb1.

*SELECTION-SCREEN BEGIN OF SCREEN 101 AS SUBSCREEN.
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_table TYPE tabname16 OBLIGATORY.
PARAMETERS  p_spmon TYPE spmon OBLIGATORY.
SELECT-OPTIONS: s_bukrs FOR t001k-bukrs,
                s_werks FOR ytrt1001-werks.
SELECTION-SCREEN SKIP 1.
PARAMETERS: p_cond AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS  p_ref TYPE spmon.
SELECTION-SCREEN END OF BLOCK b2.

SELECTION-SCREEN BEGIN OF BLOCK b4 WITH FRAME TITLE text-004.
PARAMETERS: rb_op1 RADIOBUTTON GROUP b3,
            rb_op2 RADIOBUTTON GROUP b3,
            rb_op3 RADIOBUTTON GROUP b3.
SELECTION-SCREEN END OF BLOCK b4.
*SELECTION-SCREEN END OF SCREEN 101.

*SELECTION-SCREEN BEGIN OF SCREEN 102 AS SUBSCREEN.
*SELECTION-SCREEN BEGIN OF BLOCK b3 WITH FRAME TITLE text-003.
*SELECT-OPTIONS: so_werks FOR ytrt1001-werks NO INTERVALS NO-EXTENSION,
*                sd_werks FOR ytrt1001-werks.
*SELECTION-SCREEN END OF BLOCK b3.
*SELECTION-SCREEN END OF SCREEN 102.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_table.
  PERFORM show_values.

*&---------------------------------------------------------------------*
*&      Form  show_values
*&---------------------------------------------------------------------*
FORM show_values.

  TYPES: BEGIN OF st_value_typ,
    value(50),
  END OF st_value_typ.

  DATA: it_value TYPE TABLE OF st_value_typ,
        wa_value LIKE LINE OF it_value.

  DATA: it_field_tab TYPE TABLE OF dfies,
        wa_field LIKE LINE OF it_field_tab,
        it_return_tab TYPE TABLE OF ddshretval,
        wa_return LIKE LINE OF it_return_tab.

  SELECT tabname ddtext
    FROM dd02t
    INTO CORRESPONDING FIELDS OF TABLE gt_dd02t
    WHERE ddlanguage = 'PT'
      AND tabname BETWEEN 'YTRT1001' AND 'YTRT1013'.

  CLEAR wa_field.
  wa_field-tabname = 'DD02T'.
  wa_field-fieldname = 'TABNAME'.
  APPEND wa_field TO it_field_tab.

  CLEAR wa_field.
  wa_field-tabname = 'DD02T'.
  wa_field-fieldname = 'DDTEXT'.
  APPEND wa_field TO it_field_tab.

  CLEAR it_value.
  LOOP AT gt_dd02t.
    wa_value-value = gt_dd02t-tabname.
    APPEND wa_value TO it_value.
    wa_value-value = gt_dd02t-ddtext.
    APPEND wa_value TO it_value.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'TABNAME'
    TABLES
      value_tab       = it_value
      field_tab       = it_field_tab
      return_tab      = it_return_tab
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
    WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    READ TABLE it_return_tab INTO wa_return INDEX 1.
    p_table = wa_return-fieldval.
  ENDIF.

ENDFORM.                    " show_values
