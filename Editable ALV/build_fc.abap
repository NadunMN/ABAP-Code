*----------------------------------------------------------------------*
***INCLUDE ZMM_STC_PRINT_BUILD_FCF01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form build_fc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM build_fc .
  CLEAR gt_fieldcat.

  "-------------------------------------------------------------------*
  " 1. Checkbox - Tick to Print
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'PRINT_OP'.
  gs_fieldcat-seltext_s = 'Tick'.
  gs_fieldcat-seltext_m = 'Tick to Print'.
  gs_fieldcat-seltext_l = 'Tick to Print'.
  gs_fieldcat-checkbox  = abap_true.
  gs_fieldcat-edit      = abap_true.
*  gs_fieldcat-input     = abap_true.
  gs_fieldcat-outputlen = 5.
  gs_fieldcat-col_pos   = 1.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 2. Number of Prints
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'NUMBER_PRINT'.
  gs_fieldcat-seltext_s = 'No. Print'.
  gs_fieldcat-seltext_m = 'Number of Print'.
  gs_fieldcat-seltext_l = 'Number of Print'.
  gs_fieldcat-edit      = abap_true.
  gs_fieldcat-input     = abap_true.
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos   = 2.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 3. Material Document
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'MATERIAL_DOC'.
  gs_fieldcat-seltext_s = 'Mat. Doc.'.
  gs_fieldcat-seltext_m = 'Material Document'.
  gs_fieldcat-seltext_l = 'Material Document Number'.
  gs_fieldcat-key       = abap_true.
  gs_fieldcat-edit      = abap_false.
  gs_fieldcat-outputlen = 20.
  gs_fieldcat-col_pos   = 3.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 4. Line Item
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'LINE_ITEM'.
  gs_fieldcat-seltext_s = 'Item'.
  gs_fieldcat-seltext_m = 'Line Item'.
  gs_fieldcat-seltext_l = 'Material Document Line Item'.
  gs_fieldcat-key       = abap_true.
  gs_fieldcat-edit      = abap_false.
  gs_fieldcat-outputlen = 10.
  gs_fieldcat-col_pos   = 4.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 5. Material
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'MATERIAL'.
  gs_fieldcat-seltext_s = 'Material'.
  gs_fieldcat-seltext_m = 'Material'.
  gs_fieldcat-seltext_l = 'Material Number'.
  gs_fieldcat-edit      = abap_false.
  gs_fieldcat-outputlen = 20.
  gs_fieldcat-col_pos   = 5.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 6. Material Description
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'MATERIAL_DES'.
  gs_fieldcat-seltext_s = 'Des.'.
  gs_fieldcat-seltext_m = 'Material Description'.
  gs_fieldcat-seltext_l = 'Material Description'.
  gs_fieldcat-edit      = abap_false.
  gs_fieldcat-outputlen = 30.
  gs_fieldcat-col_pos   = 6.

  APPEND gs_fieldcat TO gt_fieldcat.


  "-------------------------------------------------------------------*
  " 7. Number of Sacks
  "-------------------------------------------------------------------*
  CLEAR gs_fieldcat.

  gs_fieldcat-fieldname = 'NO_OF_SACKS'.
  gs_fieldcat-seltext_s = 'Sacks'.
  gs_fieldcat-seltext_m = 'No. of Sacks'.
  gs_fieldcat-seltext_l = 'Number of Sacks'.
  gs_fieldcat-edit      = abap_false.
  gs_fieldcat-outputlen = 20.
  gs_fieldcat-col_pos   = 7.

  APPEND gs_fieldcat TO gt_fieldcat.
ENDFORM.



