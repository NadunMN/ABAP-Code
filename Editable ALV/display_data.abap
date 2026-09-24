FORM display_data .

*  gs_layout-edit             = abap_true.  " whole grid becomes editable
  gs_layout-zebra            = abap_true.
*  gs_layout-colwidth_optimize = abap_true.
*  gs_layout-box_fieldname     = 'PRINT_OP'.      " puts a select-all checkbox in the column header

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program       = sy-repid
      i_callback_pf_status_set = 'PF_STATUS_SET'
      i_callback_user_command  = 'USER_COMMAND'
      is_layout                = gs_layout
      it_fieldcat              = gt_fieldcat
    TABLES
      t_outtab                 = gt_final
    EXCEPTIONS
      program_error            = 1
      OTHERS                   = 2.


ENDFORM.