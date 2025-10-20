*----------------------------------------------------------------------*
***INCLUDE YRE00005UPDJP_FRM .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  GET_FKART
*&---------------------------------------------------------------------*
FORM get_fkart.

  rg_fkart-sign = 'I'.
  rg_fkart-option = 'EQ'.

  SELECT fkart
    INTO rg_fkart-low
    FROM ytrt00002.
    APPEND rg_fkart.
  ENDSELECT.

ENDFORM.                    " GET_FKART

*&---------------------------------------------------------------------*
*&      Form  GET_DATA
*&---------------------------------------------------------------------*
FORM get_data .

  DATA: wklah LIKE wklah_026.

  SELECT erdat fkart vbeln zzsfac knumv xblnr fksto fkdat "JC 12052009
    INTO CORRESPONDING FIELDS OF wa_temp
    FROM vbrk
    WHERE erdat EQ p_erdat
      AND fkart IN rg_fkart.

    SELECT posnr matnr werks matkl prodh netwr
      mwsbp fkimg vgbel vgpos pospa
      INTO CORRESPONDING FIELDS OF wa_temp
      FROM vbrp
      WHERE vbeln EQ wa_temp-vbeln.

*      ADD wa_temp-mwsbp TO wa_temp-netwr.

** JC - 27052009 - As vezes não temos parceiro na factura
*  vamos à ordem
*      SELECT SINGLE pernr
*        INTO CORRESPONDING FIELDS OF wa_temp
*        FROM vbpa
*        WHERE vbeln EQ wa_temp-vbeln
*          AND posnr EQ wa_temp-posnr
*          AND parvw EQ 'ZM'.
*      IF sy-subrc NE 0.
*        SELECT SINGLE pernr
*          INTO CORRESPONDING FIELDS OF wa_temp
*          FROM vbpa
*          WHERE vbeln EQ wa_temp-vbeln
*            AND parvw EQ 'ZM'.
*      ENDIF.

*     Procura no item da factura
      CLEAR wa_temp-pernr.

*     Vamos usar o nº de segmento de parceiro(POSPA)

      SELECT SINGLE pernr
        INTO CORRESPONDING FIELDS OF wa_temp
        FROM vbpa
        WHERE vbeln EQ wa_temp-vbeln
          AND posnr EQ wa_temp-pospa "wa_temp-posnr
          AND parvw EQ 'ZM'.

      IF sy-subrc NE 0.
*       Procura no item da ordem venda
        SELECT SINGLE pernr
          INTO CORRESPONDING FIELDS OF wa_temp
          FROM vbpa
          WHERE vbeln EQ wa_temp-vgbel
            AND posnr EQ wa_temp-vgpos
            AND parvw EQ 'ZM'.

        IF sy-subrc NE 0.
*         Procura no cabeçalho da factura
          SELECT SINGLE pernr
            INTO CORRESPONDING FIELDS OF wa_temp
            FROM vbpa
            WHERE vbeln EQ wa_temp-vbeln
              AND posnr EQ space
              AND parvw EQ 'ZM'.

          IF sy-subrc NE 0.
*           Procura no cabeçalho da ordem venda
            SELECT SINGLE pernr
              INTO CORRESPONDING FIELDS OF wa_temp
              FROM vbpa
              WHERE vbeln EQ wa_temp-vgbel
                AND posnr EQ space
                AND parvw EQ 'ZM'.
          ENDIF.
        ENDIF.
      ENDIF.

** JC - 27052009

      SELECT SINGLE zest_art
        INTO CORRESPONDING FIELDS OF wa_temp
        FROM marc
        WHERE matnr EQ wa_temp-matnr
          AND werks EQ wa_temp-werks.

* verificar se o documento de facturacao nao se encontra estornado
      CHECK wa_temp-fksto IS INITIAL.

      SELECT SINGLE kbetr
        INTO wa_temp-kbetr
        FROM konv
        WHERE knumv EQ wa_temp-knumv
          AND kposn EQ wa_temp-posnr       "JC - 12052009
          AND kschl EQ 'VKP0'.

* determinar os valores para as hierarquias
      CALL FUNCTION 'WIS_GET_MERCHANDISE_GROUP_HIER'
        EXPORTING
          i_matkl    = wa_temp-matkl
          i_wresv    = '3'
          i_optimize = 'X'
        IMPORTING
          e_wklah    = wklah.
      IF sy-subrc EQ 0.
        wa_temp-zzwgru3 = wklah-wgru3.                      "Nivel 1
        wa_temp-zzwgru2 = wklah-wgru2.                      "Nivel 2
        wa_temp-zzwgru1 = wklah-wgru1.                      "Nivel 3
      ENDIF.

* actualizar o valor para o periodo respectivo
* JC - 12052009
*      wa_temp-spmon = wa_temp-erdat(6).
      wa_temp-spmon = wa_temp-fkdat(6).
* JC - 12052009

      SELECT SINGLE vbtyp
        INTO CORRESPONDING FIELDS OF tvfk
        FROM tvfk
        WHERE fkart EQ wa_temp-fkart.
* colocar valores negativos para os tipos de documentos de crédito
      IF sy-subrc EQ 0 AND tvfk-vbtyp EQ 'O'.
        wa_temp-fkimg = wa_temp-fkimg * -1.
*        wa_temp-netwr = wa_temp-netwr * -1.
*        wa_temp-kbetr = wa_temp-kbetr * -1.
      ENDIF.
      IF sy-subrc EQ 0 AND ( tvfk-vbtyp EQ 'N' OR tvfk-vbtyp EQ 'S' ).
* eliminar entrada existente na base de dados para o documento estornado
        DELETE FROM ytrt00001 WHERE vbeln = vbrk-xblnr.
      ENDIF.

      IF NOT ( tvfk-vbtyp EQ 'N' OR tvfk-vbtyp EQ 'S' ).
        MOVE-CORRESPONDING wa_temp TO wa_ytrt00001.
        APPEND wa_ytrt00001 TO gt_ytrt00001.
*        CLEAR: wa_temp, wa_ytrt00001.
      ENDIF.
    ENDSELECT.
  ENDSELECT.

* verificar se ja existem dados para o mesmo dia na tabela
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE gt_00001
    FROM ytrt00001
    WHERE erdat EQ p_erdat.

ENDFORM.                    " GET_DATA

*&---------------------------------------------------------------------*
*&      Form  LIST_VALUES
*&---------------------------------------------------------------------*
FORM list_values .

  PERFORM layout_init USING gs_layout.
  PERFORM fill_fieldcat USING gs_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      is_layout          = gs_layout
      it_fieldcat        = gs_fieldcat
    TABLES
      t_outtab           = gt_ytrt00001[]
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

ENDFORM.                    " LIST_VALUES

*&---------------------------------------------------------------------*
*&      Form  layout_init
*&---------------------------------------------------------------------*
FORM layout_init USING rs_layout TYPE slis_layout_alv.

  rs_layout-detail_popup      = 'X'.
  rs_layout-zebra             = 'X'.
  rs_layout-get_selinfos      = 'X'.
  rs_layout-colwidth_optimize = 'X'.

ENDFORM.                    "layout_init

*&---------------------------------------------------------------------*
*&      Form  fill_fieldcat
*&---------------------------------------------------------------------*
FORM fill_fieldcat USING gs_fieldcat TYPE slis_t_fieldcat_alv.

  DATA wa_fieldcat LIKE LINE OF gs_fieldcat.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      i_program_name         = sy-repid
      i_internal_tabname     = 'GT_YTRT00001'
      i_inclname             = sy-repid
    CHANGING
      ct_fieldcat            = gs_fieldcat
    EXCEPTIONS
      inconsistent_interface = 1
      program_error          = 2
      OTHERS                 = 3.

  LOOP AT gs_fieldcat INTO wa_fieldcat.
    wa_fieldcat-key = ' '.
*    CASE wa_fieldcat-fieldname.
*      WHEN '?????'.
*
*    ENDCASE.
    MODIFY gs_fieldcat FROM wa_fieldcat.
  ENDLOOP.

ENDFORM.                    " fill_fieldcat

*&---------------------------------------------------------------------*
*&      Form  UPDATE_TABLE
*&---------------------------------------------------------------------*
FORM update_table .

  IF gt_00001[] IS INITIAL.
* gravar novos valores na tabela
    INSERT ytrt00001 FROM TABLE gt_ytrt00001.
  ELSE.
* eliminar valores ja existentes e gravar novas entradas
* evitar short dump por duplicacao de registos
    DELETE ytrt00001 FROM TABLE gt_00001.
    INSERT ytrt00001 FROM TABLE gt_ytrt00001.
  ENDIF.

ENDFORM.                    " UPDATE_TABLE
