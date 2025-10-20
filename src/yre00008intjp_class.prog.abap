*&---------------------------------------------------------------------*
*&  Include           YRE00003INTJP_CLASS
*&---------------------------------------------------------------------*

class lcl_event_receiver definition deferred.

*----------------------------------------------------------------------*
*   INCLUDE Z_MM_TRAMIT_VIEWS_CLASS                                    *
*----------------------------------------------------------------------*
*  Este include contém a definição e os métodos das classes
*----------------------------------------------------------------------*
* Definition:
* ~~~~~~~~~~~
class lcl_event_receiver definition.

  public section.
* § 2. Define a method for each print event you need.
    methods:
    handle_toolbar
        for event toolbar of cl_gui_alv_grid
        importing e_object
                  e_interactive,

**Handler to Check the Data Change
    handle_data_changed for event data_changed
                         of cl_gui_alv_grid
                         importing er_data_changed
                                   e_onf4
                                   e_onf4_before
                                   e_onf4_after.

  private section.
    data: e_ucomm like sy-ucomm.

endclass.                    "lcl_event_receiver DEFINITION

****************************************************************
* LOCAL CLASSES: Implementation
****************************************************************
*===============================================================
* class c_event_receiver (Implementation)
*
class lcl_event_receiver implementation.
*Método para tratar o evento de double click.

  method handle_toolbar.
    data: ls_toolbar  type stb_button.

    check e_interactive = 'X'.
**    ls_toolbar-icon = ICON_TOGGLE_DISPLAY_CHANGE.
*    ls_toolbar-quickinfo = 'Exibir / Modificar'.
*    ls_toolbar-function = 'ZZZZ'.
*    MOVE ' ' TO ls_toolbar-text.
*    MOVE ' ' TO ls_toolbar-disabled.
*    APPEND ls_toolbar TO e_object->mt_toolbar.

    delete e_object->mt_toolbar where function = '&LOCAL&COPY_ROW'.
*    delete e_object->mt_toolbar
*              where function = '&LOCAL&INSERT_ROW'.

  endmethod.                    "handle_toolbar

**Handle Data Change
  method handle_data_changed.

    call function 'SAPGUI_SET_FUNCTIONCODE'
      exporting
        functioncode           = 'ACTUALIZA'
      exceptions
        function_not_supported = 1
        others                 = 2.
    if sy-subrc <> 0.
      message id sy-msgid type sy-msgty number sy-msgno
      with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.

  endmethod.                    "HANDLE_DATA_CHANGED

endclass.                    "lcl_event_receiver IMPLEMENTATION
