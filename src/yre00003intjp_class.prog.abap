*&---------------------------------------------------------------------*
*&  Include           YRE00003INTJP_CLASS
*&---------------------------------------------------------------------*

CLASS lcl_event_receiver DEFINITION DEFERRED.

*----------------------------------------------------------------------*
*   INCLUDE Z_MM_TRAMIT_VIEWS_CLASS                                    *
*----------------------------------------------------------------------*
*  Este include contém a definição e os métodos das classes
*----------------------------------------------------------------------*
* Definition:
* ~~~~~~~~~~~
CLASS lcl_event_receiver DEFINITION.

  PUBLIC SECTION.
* § 2. Define a method for each print event you need.
    METHODS:
    handle_toolbar
        FOR EVENT toolbar OF cl_gui_alv_grid
        IMPORTING e_object
                  e_interactive,

**Handler to Check the Data Change
    handle_data_changed FOR EVENT data_changed
                         OF cl_gui_alv_grid
                         IMPORTING er_data_changed
                                   e_onf4
                                   e_onf4_before
                                   e_onf4_after.

  PRIVATE SECTION.
    DATA: e_ucomm LIKE sy-ucomm.

ENDCLASS.                    "lcl_event_receiver DEFINITION

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class c_event_receiver (Implementation)
*
CLASS lcl_event_receiver IMPLEMENTATION.
*Método para tratar o evento de double click.

  METHOD handle_toolbar.
    DATA: ls_toolbar  TYPE stb_button.

*    CHECK e_interactive = 'X'.
**    ls_toolbar-icon = ICON_TOGGLE_DISPLAY_CHANGE.
*    ls_toolbar-quickinfo = 'Exibir / Modificar'.
*    ls_toolbar-function = 'ZZZZ'.
*    MOVE ' ' TO ls_toolbar-text.
*    MOVE ' ' TO ls_toolbar-disabled.
*    APPEND ls_toolbar TO e_object->mt_toolbar.

    DELETE e_object->mt_toolbar WHERE function = '&LOCAL&COPY_ROW'.
*    delete e_object->mt_toolbar
*              where function = '&LOCAL&INSERT_ROW'.

  ENDMETHOD.                    "handle_toolbar

**Handle Data Change
  METHOD handle_data_changed.

    data: ls_mod_cell type LVC_S_MODI,
          wa_line type yegn00001.

    data: nlines type i.

*    break roffdev.

    loop at ER_DATA_CHANGED->MT_mod_CELLS into ls_mod_cell.
      read table <tab>
           index ls_mod_Cell-row_id into wa_line.

      wa_line-changed = 'X'.

* flag new data
      modify <tab> from wa_line index ls_mod_Cell-row_id.
* flag old data
      describe table gt_yegn00001 lines nlines.
      modify gt_yegn00001 from wa_line index ls_mod_Cell-row_id.
    endloop.
*    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
*      EXPORTING
*        functioncode           = 'ACTUALIZA'
*      EXCEPTIONS
*        function_not_supported = 1
*        OTHERS                 = 2.
*    IF sy-subrc <> 0.
*      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*    ENDIF.

  ENDMETHOD.                    "HANDLE_DATA_CHANGED

ENDCLASS.                    "lcl_event_receiver IMPLEMENTATION

*** Definição do objecto que vai receber os eventos
DATA: event_receiver TYPE REF TO lcl_event_receiver.
* OO
