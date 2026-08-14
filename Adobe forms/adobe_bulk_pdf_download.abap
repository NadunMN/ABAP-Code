CONSTANTS:
  gc_form_name TYPE fpname VALUE 'ZMM_STC_PRINT_FORM'.

DATA:
  lv_fm_name       TYPE rs38l_fnam,
  ls_outputparams  TYPE sfpoutputparams,
  ls_docparams     TYPE sfpdocparams,
  ls_jobresult     TYPE sfpjoboutput,

  lt_pdf_table     TYPE tfpcontent,
  lv_pdf_xstring   TYPE xstring,
  lt_pdf_binary    TYPE solix_tab,
  lv_pdf_size      TYPE i,

  lv_filename      TYPE string,
  lv_path          TYPE string,
  lv_fullpath      TYPE string,
  lv_user_action   TYPE i,

  lv_row_number    TYPE sy-tabix,
  lv_success_count TYPE i,
  lv_error_count   TYPE i.

*--------------------------------------------------------------------*
* Check whether there is data to print
*--------------------------------------------------------------------*
IF gt_print_final IS INITIAL.
  MESSAGE 'There is no data available to print'
    TYPE 'S'
    DISPLAY LIKE 'E'.
  RETURN.
ENDIF.

*--------------------------------------------------------------------*
* Determine generated Adobe Form function module
*--------------------------------------------------------------------*
CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
  EXPORTING
    i_name         = gc_form_name
  IMPORTING
    e_funcname     = lv_fm_name
  EXCEPTIONS
    usage_error    = 1
    system_error   = 2
    internal_error = 3
    OTHERS         = 4.

IF sy-subrc <> 0.
  MESSAGE ID sy-msgid
          TYPE 'E'
          NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4.
ENDIF.

*--------------------------------------------------------------------*
* Configure Adobe Forms output
*--------------------------------------------------------------------*
CLEAR:
  ls_outputparams,
  ls_docparams,
  ls_jobresult.

"Multiple form calls in one job
ls_outputparams-bumode = 'M'.

"Return multiple PDF output to ABAP
ls_outputparams-getpdf = 'M'.

"Assemble all generated forms into one PDF
ls_outputparams-assemble = 'X'.

"No print dialog and no preview
ls_outputparams-nodialog = abap_true.
ls_outputparams-preview  = abap_false.

"No printer or spool output
CLEAR:
  ls_outputparams-dest,
  ls_outputparams-reqnew,
  ls_outputparams-reqimm.

ls_docparams-langu   = sy-langu.
ls_docparams-country = 'LK'.

*--------------------------------------------------------------------*
* Open one Adobe Forms job
*--------------------------------------------------------------------*
CALL FUNCTION 'FP_JOB_OPEN'
  CHANGING
    ie_outputparams = ls_outputparams
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
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4.
ENDIF.

*--------------------------------------------------------------------*
* Generate one Adobe Form for each row
*--------------------------------------------------------------------*
CLEAR:
  lv_row_number,
  lv_success_count,
  lv_error_count.

LOOP AT gt_print_final INTO gwa_print_final.

  lv_row_number = sy-tabix.

  CALL FUNCTION lv_fm_name
    EXPORTING
      /1bcdwb/docparams = ls_docparams
      is_print_data     = gwa_print_final
    EXCEPTIONS
      usage_error       = 1
      system_error      = 2
      internal_error    = 3
      OTHERS            = 4.

  IF sy-subrc <> 0.

    lv_error_count = lv_error_count + 1.

    MESSAGE |Error generating form for row { lv_row_number }|
      TYPE 'S'
      DISPLAY LIKE 'E'.

    CONTINUE.

  ENDIF.

  lv_success_count = lv_success_count + 1.

  "Update only successfully generated rows
  gwa_print_final-pull_date = sy-datum.
  gwa_print_final-pull_time = sy-uzeit.

  MODIFY gt_print_final
    FROM gwa_print_final
    INDEX lv_row_number.

  CLEAR gwa_print_final.

ENDLOOP.

*--------------------------------------------------------------------*
* Close Adobe Forms job
*--------------------------------------------------------------------*
CALL FUNCTION 'FP_JOB_CLOSE'
  IMPORTING
    e_result       = ls_jobresult
  EXCEPTIONS
    usage_error    = 1
    system_error   = 2
    internal_error = 3
    OTHERS         = 4.

IF sy-subrc <> 0.
  MESSAGE ID sy-msgid
          TYPE 'E'
          NUMBER sy-msgno
          WITH sy-msgv1
               sy-msgv2
               sy-msgv3
               sy-msgv4.
ENDIF.

IF lv_success_count = 0.
  MESSAGE 'No forms were generated successfully'
    TYPE 'E'.
ENDIF.

*--------------------------------------------------------------------*
* Retrieve the assembled PDF
*--------------------------------------------------------------------*
REFRESH lt_pdf_table.
CLEAR lv_pdf_xstring.

CALL FUNCTION 'FP_GET_PDF_TABLE'
  IMPORTING
    e_pdf_table = lt_pdf_table.

IF lt_pdf_table IS INITIAL.
  MESSAGE 'Adobe Forms did not return any PDF data'
    TYPE 'E'.
ENDIF.

"With ASSEMBLE = X, the first row contains the combined PDF
READ TABLE lt_pdf_table
  INDEX 1
  INTO lv_pdf_xstring.

IF sy-subrc <> 0 OR lv_pdf_xstring IS INITIAL.
  MESSAGE 'The combined PDF could not be retrieved'
    TYPE 'E'.
ENDIF.

*--------------------------------------------------------------------*
* Convert PDF XSTRING into a binary table
*--------------------------------------------------------------------*
REFRESH lt_pdf_binary.
CLEAR lv_pdf_size.

CALL FUNCTION 'SCMS_XSTRING_TO_BINARY'
  EXPORTING
    buffer        = lv_pdf_xstring
  IMPORTING
    output_length = lv_pdf_size
  TABLES
    binary_tab    = lt_pdf_binary.

IF sy-subrc <> 0 OR lt_pdf_binary IS INITIAL.
  MESSAGE 'The combined PDF could not be converted'
    TYPE 'E'.
ENDIF.

*--------------------------------------------------------------------*
* Open file save dialog
*--------------------------------------------------------------------*
CLEAR:
  lv_filename,
  lv_path,
  lv_fullpath,
  lv_user_action.

CALL METHOD cl_gui_frontend_services=>file_save_dialog
  EXPORTING
    window_title      = 'Save combined Adobe Forms PDF'
    default_extension = 'pdf'
    default_file_name = 'STC_Forms.pdf'
    file_filter       = 'PDF files (*.pdf)|*.pdf|'
  CHANGING
    filename          = lv_filename
    path              = lv_path
    fullpath          = lv_fullpath
    user_action       = lv_user_action
  EXCEPTIONS
    cntl_error           = 1
    error_no_gui         = 2
    not_supported_by_gui = 3
    OTHERS               = 4.

IF sy-subrc <> 0.
  MESSAGE 'The PDF save dialog could not be opened'
    TYPE 'E'.
ENDIF.

IF lv_user_action = cl_gui_frontend_services=>action_cancel.
  MESSAGE 'PDF download was cancelled'
    TYPE 'S'.
  RETURN.
ENDIF.

IF lv_fullpath IS INITIAL.
  MESSAGE 'No PDF file location was selected'
    TYPE 'E'.
ENDIF.

*--------------------------------------------------------------------*
* Download the combined PDF
*--------------------------------------------------------------------*
CALL METHOD cl_gui_frontend_services=>gui_download
  EXPORTING
    bin_filesize = lv_pdf_size
    filename     = lv_fullpath
    filetype     = 'BIN'
  CHANGING
    data_tab     = lt_pdf_binary
  EXCEPTIONS
    file_write_error        = 1
    no_batch                = 2
    gui_refuse_filetransfer = 3
    invalid_type            = 4
    no_authority            = 5
    unknown_error           = 6
    header_not_allowed      = 7
    separator_not_allowed   = 8
    filesize_not_allowed    = 9
    header_too_long         = 10
    dp_error_create         = 11
    dp_error_send           = 12
    dp_error_write          = 13
    unknown_dp_error        = 14
    access_denied           = 15
    dp_out_of_memory        = 16
    disk_full               = 17
    dp_timeout              = 18
    file_not_found          = 19
    dataprovider_exception  = 20
    control_flush_error     = 21
    not_supported_by_gui    = 22
    error_no_gui            = 23
    OTHERS                  = 24.

IF sy-subrc <> 0.
  MESSAGE 'The combined PDF could not be downloaded'
    TYPE 'E'.
ENDIF.

*--------------------------------------------------------------------*
* Completion message
*--------------------------------------------------------------------*
IF lv_error_count = 0.

  MESSAGE
    |{ lv_success_count } forms downloaded as one PDF|
    TYPE 'S'.

ELSE.

  MESSAGE
    |PDF downloaded with { lv_success_count } forms; { lv_error_count } rows failed|
    TYPE 'S'
    DISPLAY LIKE 'W'.

ENDIF.