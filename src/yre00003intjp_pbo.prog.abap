*----------------------------------------------------------------------*
***INCLUDE YRE00003INTJP_PBO .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  STATUS_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE status_0100 OUTPUT.

  IF gv_save IS INITIAL AND rb_op3 IS INITIAL.
    SET PF-STATUS 'YRE00003'.
  ELSE.
    SET PF-STATUS 'YRE00003' EXCLUDING 'VALIDAR'.
  ENDIF.

  SET TITLEBAR 'TITLE'.

ENDMODULE.                 " STATUS_0100  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INSTANCE_GRID_0100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE instance_grid_0100 OUTPUT.
*** Se o o custom control está vazio, atribuir o custom container
*** ao custom control do écran

  IF container IS INITIAL.
** Cria o objecto custom_container, no custom control
    CREATE OBJECT container
      EXPORTING
        container_name = 'CCCONTAINER'.
** Cria o objecto alv_grid no custom_container
    CREATE OBJECT alv_grid
      EXPORTING
        i_parent = container.
*  ENDIF.
    CALL METHOD alv_grid->register_edit_event
      EXPORTING
        i_event_id = cl_gui_alv_grid=>mc_evt_modified.
* Cria o objecto que vai receber os eventos e prepara-o para receber os
* eventos que se quiser
    CREATE OBJECT event_receiver.
    SET HANDLER event_receiver->handle_toolbar FOR alv_grid.
    SET HANDLER event_receiver->handle_data_changed FOR alv_grid.
* coloca o cursor na lista alv
    CALL METHOD cl_gui_control=>set_focus
      EXPORTING
        control = alv_grid.

    PERFORM load_grid.
  ENDIF.

ENDMODULE.                 " INSTANCE_GRID_0100  OUTPUT
