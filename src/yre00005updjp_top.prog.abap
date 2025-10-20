*&---------------------------------------------------------------------*
*&  Include           YRE00005UPDJP_TOP
*&---------------------------------------------------------------------*

TABLES: vbrk, vbrp, konv, marc, vbpa, tvfk, ytrt00001.

TYPE-POOLS: slis.
DATA: gs_layout TYPE slis_layout_alv,
      gs_fieldcat TYPE slis_t_fieldcat_alv.

DATA: gt_00001 LIKE ytrt00001 OCCURS 0 WITH HEADER LINE.

DATA: BEGIN OF gt_ytrt00001 OCCURS 0.
        INCLUDE STRUCTURE ytrt00001.
DATA: END OF gt_ytrt00001.

DATA: wa_ytrt00001 LIKE gt_ytrt00001.

DATA: BEGIN OF wa_temp.
        INCLUDE STRUCTURE ytrt00001.
DATA:   knumv TYPE knumv,
        xblnr TYPE xblnr_v1,
        vbtyp TYPE vbtyp,
        fksto TYPE fksto,
        mwsbp TYPE mwsbp,
        vgbel type vgbel,
        vgpos type vgpos,
        pospa type pospa.
DATA: END OF wa_temp.

RANGES: rg_fkart FOR vbrk-fkart.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-001.
PARAMETERS: p_erdat TYPE vbrk-erdat.
SELECTION-SCREEN END OF BLOCK b1.

SELECTION-SCREEN BEGIN OF BLOCK b2 WITH FRAME TITLE text-002.
PARAMETERS: p_test AS CHECKBOX.
SELECTION-SCREEN END OF BLOCK b2.
