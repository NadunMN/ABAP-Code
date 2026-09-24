
* Adobe form related declarations
DATA: gv_fm_name       TYPE rs38l_fnam,
      gs_outputparams  TYPE sfpoutputparams,
      gs_docparams     TYPE sfpdocparams,
      gv_formname      TYPE fpname VALUE 'ZSAMPLE_PROCESS_00001720_AF'. "<-- your form name

* Exceptions
DATA: gv_exception TYPE REF TO cx_root,
      gv_msg       TYPE string.




*----------------------------------------------------------------------
* FORM print_forms - Loop and print row by row
*----------------------------------------------------------------------
  " Step 1: Get the generated function module name for the form (only once)
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = gv_formname
    IMPORTING
      e_funcname = gv_fm_name
    EXCEPTIONS
      no_form                = 1
      no_function_module     = 2
      OTHERS                 = 3.

  IF sy-subrc <> 0.
    MESSAGE 'Error getting function module name' TYPE 'E'.
  ENDIF.

  " Step 2: Loop through internal table - ONE PRINT PER ROW
  LOOP AT gt_customer INTO gs_customer.

    " ---- Open a new spool job for EACH row ----
    CLEAR gs_outputparams.
    gs_outputparams-nodialog = 'X'.   " no print dialog popup
    gs_outputparams-getpdf   = ' '.   " set 'X' if you want PDF binary instead of print
    gs_outputparams-preview  = ' '.   " set 'X' to preview instead of print
    gs_outputparams-reqnew   = 'X'.   " new spool request every time
    gs_outputparams-dest     = 'LP01'." your output device, adjust or leave blank for dialog

    CALL FUNCTION 'FP_JOB_OPEN'
      CHANGING
        ie_outputparams = gs_outputparams
      EXCEPTIONS
        cancel          = 1
        usage_error     = 2
        system_error    = 3
        internal_error  = 4
        OTHERS          = 5.

    IF sy-subrc <> 0.
      MESSAGE 'Error in FP_JOB_OPEN' TYPE 'E'.
    ENDIF.

    " ---- Set document params (optional language, form language) ----
    CLEAR gs_docparams.
    gs_docparams-langu = sy-langu.
    gs_docparams-country = 'US'.       " optional

    " ---- Call generated function module, passing ONLY the structure ----
    TRY.
        CALL FUNCTION gv_fm_name
          EXPORTING
            /1bcdwb/docparams = gs_docparams
            is_data           = gs_customer     " <-- your structure interface param name
          EXCEPTIONS
            usage_error       = 1
            system_error      = 2
            internal_error    = 3
            OTHERS            = 4.

        IF sy-subrc <> 0.
          MESSAGE ID sy-msgid TYPE 'I' NUMBER sy-msgno
                  WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
                  INTO gv_msg.
          MESSAGE gv_msg TYPE 'I'.
        ENDIF.

      CATCH cx_root INTO gv_exception.
        gv_msg = gv_exception->get_text( ).
        MESSAGE gv_msg TYPE 'I'.
    ENDTRY.

    " ---- Close the job for THIS row (finalizes one print/spool output) ----
    CALL FUNCTION 'FP_JOB_CLOSE'
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.

    IF sy-subrc <> 0.
      MESSAGE 'Error in FP_JOB_CLOSE' TYPE 'E'.
    ENDIF.

  ENDLOOP.

  MESSAGE 'All forms printed successfully' TYPE 'S'.
