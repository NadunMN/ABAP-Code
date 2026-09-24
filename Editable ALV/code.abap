*----------------------------------------------------------------*
* User command handler
* IMPORTANT: by the time this FORM is called, gt_data already
* contains whatever the user typed/checked in the grid - the ALV
* framework syncs the generated screen back into your table for you.
*----------------------------------------------------------------*
FORM user_command USING r_ucomm     LIKE sy-ucomm
                         rs_selfield TYPE slis_selfield.


  DATA: lv_answer TYPE c LENGTH 1,
        lv_count  TYPE i,
        lo_grid   TYPE REF TO cl_gui_alv_grid.

  CASE r_ucomm.
    WHEN '&SAVE'.   " function code SAVE defined in GUI status ZSTATUS

      " Get ALV grid
      CALL FUNCTION 'GET_GLOBALS_FROM_SLVC_FULLSCR'
        IMPORTING
          e_grid = lo_grid.

      " Transfer checkbox changes from ALV to GT_FINAL
      IF lo_grid IS BOUND.
        lo_grid->check_changed_data( ).
      ENDIF.

    "   lv_count = 0.

    "   LOOP AT gt_final INTO gs_final WHERE print_op = abap_true.
    "     lv_count = lv_count + 1.
    "   ENDLOOP.

      IF lv_count = 0.
        MESSAGE 'No rows selected - nothing to Print.' TYPE 'S'
          DISPLAY LIKE 'W'.
        RETURN.
      ENDIF.

      " Optional confirmation popup before committing changes
      CALL FUNCTION 'POPUP_TO_CONFIRM'
        EXPORTING
          titlebar       = 'Confirm save'
          text_question  = 'Print the selected rows?'
          text_button_1  = 'Yes'
          text_button_2  = 'No'
          default_button = '1'
        IMPORTING
          answer         = lv_answer.

      IF lv_answer <> '1'.
        RETURN.
      ENDIF.

    "   PERFORM validate_data CHANGING sy-subrc.

      IF sy-subrc = 0.

        " PERFORM print_data.
        " PERFORM print_af.
*        PERFORM save_data_table.
        MESSAGE 'Changes saved successfully' TYPE 'S'.
      ENDIF.

      COMMIT WORK AND WAIT.

*      MESSAGE |{ lv_count } row(s) Printed successfully.| TYPE 'S'.

      " Clear checkboxes after save and refresh the list on screen
    "   LOOP AT gt_final INTO gs_final WHERE print_op = abap_true.
    "     gs_final-print_op = abap_false.
    "     gs_final-number_print = 0.
    "     MODIFY gt_final FROM gs_final TRANSPORTING print_op number_print.
    "   ENDLOOP.

*      if gv_count = 1.
*        lcl_pdf_preview=>do_save( ).
*      endif.


      rs_selfield-refresh = abap_true.

    WHEN '&BACK' OR '&EXIT' OR '&CANC'.
      SET SCREEN 0.
      LEAVE SCREEN.
  ENDCASE.
ENDFORM.