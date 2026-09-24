

*-----------------------------------------------------------------------
* Data declarations
*-----------------------------------------------------------------------
CONSTANTS:
  gc_form_name TYPE fpname VALUE 'ZSAMPLE_PROCESS_00001720_AF'.

DATA:
  gv_fm_name      TYPE rs38l_fnam,
  gs_outputparams TYPE sfpoutputparams,
  gs_docparams    TYPE sfpdocparams,
  gs_jobresult    TYPE sfpjoboutput.

*-----------------------------------------------------------------------
* Get the generated function module name
*-----------------------------------------------------------------------

  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name     = gc_form_name
    IMPORTING
      e_funcname = gv_fm_name
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
            TYPE 'E'
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


*-----------------------------------------------------------------------
* Open one Adobe Forms print job
*-----------------------------------------------------------------------


  CLEAR gs_outputparams.

  gs_outputparams-dest     = 'LP01'.
  gs_outputparams-nodialog = abap_true.
  gs_outputparams-preview  = abap_true.
  gs_outputparams-getpdf   = abap_false.

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
    MESSAGE ID sy-msgid
            TYPE 'E'
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.



*-----------------------------------------------------------------------
* Call the Adobe Form once for every internal-table row
*-----------------------------------------------------------------------


  CLEAR gs_docparams.

  gs_docparams-langu   = sy-langu.
  gs_docparams-country = 'US'.

  LOOP AT gt_customer INTO gs_customer.

    CALL FUNCTION gv_fm_name
      EXPORTING
        /1bcdwb/docparams = gs_docparams
        is_row            = gs_customer
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.

      DATA(lv_error_text) =
        |Adobe Form failed|.

      "Close the job before stopping
      CALL FUNCTION 'FP_JOB_CLOSE'
        EXCEPTIONS
          usage_error    = 1
          system_error   = 2
          internal_error = 3
          OTHERS         = 4.

      MESSAGE lv_error_text TYPE 'E'.

    ENDIF.

  ENDLOOP.



*-----------------------------------------------------------------------
* Close print job and create spool request
*-----------------------------------------------------------------------


  CALL FUNCTION 'FP_JOB_CLOSE'
    IMPORTING
      e_result       = gs_jobresult
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid
            TYPE 'E'
            NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

