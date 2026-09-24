FUNCTION zsample_process_00001720.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_BSIS) LIKE  BSIS STRUCTURE  BSIS OPTIONAL
*"     REFERENCE(DUNNING_DATE) TYPE  LAUFD
*"     REFERENCE(DUNNING_ID) TYPE  LAUFI
*"     REFERENCE(COMPANY_CODE) TYPE  BUKRS
*"  CHANGING
*"     VALUE(C_SETTAB) LIKE  CCSET STRUCTURE  CCSET
*"     VALUE(CUSTOMER_CODE) TYPE  ZFI_DUNNING_TT
*"----------------------------------------------------------------------
*
*  TYPES : BEGIN OF ty_documents,
*            date        TYPE datum,
*            document_no TYPE belnr,
*            reference   TYPE xblnr1,
*            currency    TYPE waers,
*            value       TYPE char40,
*            vat         TYPE char40,
*            total_value TYPE char40,
*          END OF ty_documents.
*
*
*  TYPES: BEGIN OF ty_form,
*           dunning_date   TYPE laufd,
*           company_code   TYPE bukrs,
*           company_name   TYPE char40,
*           customer_name  TYPE char10,
*           address        TYPE char40,
*           contact_email  TYPE char40,
*           contact_number TYPE numc10,
*           contact_person TYPE char40,
*           documents      TYPE STANDARD TABLE OF ty_documents WITH EMPTY KEY,
*           value_total    TYPE char40,
*           vat_total      TYPE char40,
*           total_value    TYPE char40,
*         END OF ty_form.


  CONSTANTS:
    gc_vat_account TYPE bseg-hkont VALUE '10302006',
    gc_credit      TYPE shkzg      VALUE 'H'.


  DATA: gt_form      TYPE TABLE OF zfi_af_st,
        gwa_form     TYPE zfi_af_st,
        gs_documents TYPE zfi_af_doc_st.

  DATA: gt_customer TYPE TABLE OF zfi_af_st,
        gs_customer TYPE zfi_af_st.

  DATA: gv_total       TYPE char40 VALUE '0',
        gv_vat_total   TYPE char40 VALUE '0',
        gv_value_total TYPE char40 VALUE '0'.

  CLEAR : gt_form.

  DATA gr_customer TYPE RANGE OF kunnr.

  gr_customer = VALUE #(
    FOR lv_customer IN customer_code
    ( sign   = 'I'
      option = 'EQ'
      low    = lv_customer )
  ).

  SELECT *
  FROM mhnk
  WHERE laufd = @dunning_date
    AND laufi = @dunning_id
    AND bukrs = @company_code
    AND kunnr IN @gr_customer
  INTO TABLE @DATA(lt_data).

  SELECT name1, name2, kunnr, adrnr FROM kna1
  INTO TABLE @DATA(lt_customer).

  SELECT house_num1, street, str_suppl1, city1, addrnumber FROM adrc
  INTO TABLE @DATA(lt_address).

  SELECT ceml,cper , cnum ,  bukrs FROM zfi_dun_email
  INTO TABLE @DATA(lt_contact).

  SELECT * FROM mhnd
  WHERE laufd = @dunning_date AND laufi = @dunning_id
  INTO TABLE @DATA(lt_table_data).

  SELECT wrbtr, shkzg, bukrs, belnr, gjahr FROM bseg
  WHERE hkont = @gc_vat_account
  INTO TABLE @DATA(lt_vat).

  SELECT bukrs, butxt FROM t001
  INTO TABLE @DATA(lt_comapny_name).



  LOOP AT lt_data INTO DATA(ls_data).


    CLEAR : gwa_form, gv_total, gv_value_total, gv_vat_total.

    READ TABLE lt_customer WITH KEY kunnr = ls_data-kunnr INTO DATA(ls_customer).

    gwa_form-customer_name =
      |{ ls_customer-name1 } { ls_customer-name2 }|.
    gwa_form-company_code = ls_data-bukrs.

    READ TABLE lt_address WITH KEY addrnumber = ls_customer-adrnr INTO DATA(ls_address).

    gwa_form-customer_name =
     |{ ls_address-house_num1 } { ls_address-street } { ls_address-str_suppl1 } { ls_address-city1 } |.

    READ TABLE lt_contact WITH KEY bukrs = ls_data-bukrs INTO DATA(ls_contact).

    gwa_form-contact_email = ls_contact-ceml.
    gwa_form-contact_person = ls_contact-cper.
    gwa_form-contact_number = ls_contact-cnum.

    READ TABLE lt_comapny_name WITH KEY bukrs = ls_data-bukrs INTO DATA(ls_company_name).

    gwa_form-company_name = ls_company_name-butxt.

*    READ TABLE lt_table_data WITH KEY kunnr = ls_data-kunnr bukrs = ls_data-bukrs INTO DATA(ls_table_data).
    LOOP AT lt_table_data INTO DATA(ls_table_data).

      CLEAR gs_documents.
      gs_documents-date = ls_table_data-bldat.
      gs_documents-document_no = ls_table_data-belnr.
      gs_documents-reference = ls_table_data-xblnr.
      gs_documents-currency = ls_table_data-waers.

      READ TABLE lt_vat WITH KEY bukrs = ls_table_data-bukrs belnr = ls_table_data-belnr gjahr = ls_table_data-gjahr INTO DATA(ls_vat).

      IF ls_vat-shkzg = gc_credit .
        gs_documents-vat = -1 * ls_vat-wrbtr.
      ELSE.
        gs_documents-vat = ls_vat-wrbtr.
      ENDIF.

      IF ls_table_data-shkzg = gc_credit .
        gs_documents-total_value = -1 * ls_table_data-wrshb.
      ELSE.
        gs_documents-total_value = ls_table_data-wrshb.
      ENDIF.

      gs_documents-value = gs_documents-total_value - gs_documents-vat.

      gv_total = gv_total + gs_documents-total_value.
      gv_value_total = gv_value_total + gs_documents-value.
      gv_vat_total = gv_vat_total + gs_documents-vat.

      APPEND gs_documents TO gwa_form-documents.

    ENDLOOP.

    gwa_form-total_value = gv_total.
    gwa_form-value_total = gv_value_total.
    gwa_form-vat_total = gv_vat_total.

    APPEND gwa_form TO gt_form.

  ENDLOOP.




*  Adobe form generate

  gt_customer = CORRESPONDING #( gt_form ).



*-----------------------------------------------------------------------
* Data declarations
*-----------------------------------------------------------------------
  CONSTANTS:
    gc_form_name TYPE fpname VALUE 'ZSAMPLE_PROCESS_00001720_AF'.

  DATA:
    gv_fm_name      TYPE rs38l_fnam,
    gs_outputparams TYPE sfpoutputparams,
    gs_docparams    TYPE sfpdocparams,
    gs_jobresult    TYPE sfpjoboutput,
    lv_job_open     TYPE abap_bool.

*--------------------------------------------------------------------*
* Get generated Adobe Form function module
*--------------------------------------------------------------------*
  CALL FUNCTION 'FP_FUNCTION_MODULE_NAME'
    EXPORTING
      i_name         = gc_form_name
    IMPORTING
      e_funcname     = gv_fm_name
    EXCEPTIONS
      usage_error    = 1
      system_error   = 2
      internal_error = 3
      OTHERS         = 4.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

*--------------------------------------------------------------------*
* Output settings
*--------------------------------------------------------------------*
  CLEAR gs_outputparams.

  gs_outputparams-dest     = 'LP01'.
  gs_outputparams-nodialog = abap_true.
  gs_outputparams-preview  = abap_false.
  gs_outputparams-bumode   = 'M'.

*--------------------------------------------------------------------*
* Open Adobe job ONCE
*--------------------------------------------------------------------*
*  CALL FUNCTION 'FP_JOB_OPEN'
*    CHANGING
*      ie_outputparams = gs_outputparams
*    EXCEPTIONS
*      cancel          = 1
*      usage_error     = 2
*      system_error    = 3
*      internal_error  = 4
*      OTHERS          = 5.
*
*  IF sy-subrc <> 0.
*    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
*      WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  ENDIF.
*
*  lv_job_open = abap_true.

*--------------------------------------------------------------------*
* Document parameters
*--------------------------------------------------------------------*
  CLEAR gs_docparams.
  gs_docparams-langu = sy-langu.

*--------------------------------------------------------------------*
* Call form once per customer
*--------------------------------------------------------------------*
  LOOP AT gt_customer INTO gs_customer.

    CALL FUNCTION gv_fm_name
      EXPORTING
        /1bcdwb/docparams = gs_docparams
        it_data           = gs_customer
      EXCEPTIONS
        usage_error       = 1
        system_error      = 2
        internal_error    = 3
        OTHERS            = 4.

    IF sy-subrc <> 0.

      DATA(lv_subrc) = sy-subrc.
      DATA(lv_msgid) = sy-msgid.
      DATA(lv_msgno) = sy-msgno.
      DATA(lv_msgv1) = sy-msgv1.
      DATA(lv_msgv2) = sy-msgv2.
      DATA(lv_msgv3) = sy-msgv3.
      DATA(lv_msgv4) = sy-msgv4.

      EXIT.

    ENDIF.

  ENDLOOP.

*--------------------------------------------------------------------*
* Close Adobe job ONCE
*--------------------------------------------------------------------*
  IF lv_job_open = abap_true.

    CALL FUNCTION 'FP_JOB_CLOSE'
      IMPORTING
        e_result       = gs_jobresult
      EXCEPTIONS
        usage_error    = 1
        system_error   = 2
        internal_error = 3
        OTHERS         = 4.

    CLEAR lv_job_open.

  ENDIF.

*--------------------------------------------------------------------*
* Display saved form error
*--------------------------------------------------------------------*
  IF lv_subrc IS NOT INITIAL.
    MESSAGE |Adobe error { lv_subrc }: { lv_msgid }-{ lv_msgno } |
         && |{ lv_msgv1 } { lv_msgv2 } { lv_msgv3 } { lv_msgv4 }|
      TYPE 'E'.
  ENDIF.

ENDFUNCTION.