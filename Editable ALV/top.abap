*&---------------------------------------------------------------------*
*& Include          ZMM_STC_PRINT_TOP
*&---------------------------------------------------------------------*
DATA:
  gt_fieldcat TYPE slis_t_fieldcat_alv,
  gs_fieldcat TYPE slis_fieldcat_alv,
  gs_layout   TYPE slis_layout_alv.


*&---------------------------------------------------------------------*
*& Include          ZMM_STC_PRINT_SEL
*&---------------------------------------------------------------------*
" SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-001.

"   PARAMETERS: p_doc_no TYPE mblnr.


"   SELECT-OPTIONS:s_dl FOR zmm_stc_print-zeile,
"                  s_plant FOR marc-werks OBLIGATORY.

" SELECTION-SCREEN END OF BLOCK b1.




*AT SELECTION-SCREEN.

START-OF-SELECTION.
  PERFORM build_fc.
END-OF-SELECTION.
  PERFORM display_data.