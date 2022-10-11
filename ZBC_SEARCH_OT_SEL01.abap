*&---------------------------------------------------------------------*
*&  Include           ZBC_SEARCH_OT_SEL01
*&---------------------------------------------------------------------*

"Critère de Recherche
SELECTION-SCREEN BEGIN OF BLOCK sel02 WITH FRAME TITLE text-003.
PARAMETERS: s_ot     RADIOBUTTON GROUP rad DEFAULT 'X' USER-COMMAND aaa1,
            s_o_cust RADIOBUTTON GROUP rad,
            s_o_work RADIOBUTTON GROUP rad.
SELECTION-SCREEN END OF BLOCK sel02.

"Recherche d'OT
SELECTION-SCREEN BEGIN OF BLOCK select01 WITH FRAME TITLE text-004.
SELECT-OPTIONS: p_ot    FOR e070-trkorr  NO INTERVALS MODIF ID a,
                p_nni   FOR e070-as4user NO INTERVALS MODIF ID a.
PARAMETERS:     p_idpro TYPE ctsproject-externalid MODIF ID a.
SELECTION-SCREEN END OF BLOCK select01.

"Recherche d'objet Custominzing
SELECTION-SCREEN BEGIN OF BLOCK select02 WITH FRAME TITLE text-004.
SELECT-OPTIONS: typ_ob  FOR e071k-mastertype NO INTERVALS MODIF ID aa,
                nom1_ob FOR e071k-mastername NO INTERVALS MODIF ID aa,
                nom2_ob FOR e071k-tabkey     NO INTERVALS MODIF ID aa.
SELECTION-SCREEN END OF BLOCK select02.

"Recherche d'objet Workbench
SELECTION-SCREEN BEGIN OF BLOCK select03 WITH FRAME TITLE text-004.
SELECT-OPTIONS: nam_obj FOR e071-obj_name NO INTERVALS MODIF ID aaa,
                obj     FOR e071-object   NO INTERVALS MODIF ID aaa.
SELECTION-SCREEN END OF BLOCK select03.


AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_idpro.
  IF s_ot = abap_true.
    CLEAR lt_columns[].

    SELECT externalid descriptn FROM ctsproject INTO TABLE lt_columns ORDER BY externalid ASCENDING.
    CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
      EXPORTING
        retfield        = 'EXTERNALID'
        dynpprog        = sy-cprog
        dynpnr          = sy-dynnr
        dynprofield     = 'p_idpro'
        window_title    = 'Selection OT avec code projet'
        value_org       = 'S'
      TABLES
        value_tab       = lt_columns
      EXCEPTIONS
        parameter_error = 1
        no_values_found = 2
        OTHERS          = 3.
    IF sy-subrc <> 0. ENDIF.
  ENDIF.

AT SELECTION-SCREEN OUTPUT.
  LOOP AT SCREEN.
    IF s_ot EQ abap_true AND screen-group1 = 'A'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF s_o_cust EQ abap_true AND screen-group1 = 'AA'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF s_o_work EQ abap_true AND screen-group1 = 'AAA'.
      screen-active = 1.
      MODIFY SCREEN.
      CONTINUE.

    ELSEIF s_ot EQ '' AND screen-group1 = 'A'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF s_o_cust EQ '' AND screen-group1 = 'AA'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.
    ELSEIF s_o_work EQ '' AND screen-group1 = 'AAA'.
      screen-active = 0.
      MODIFY SCREEN.
      CONTINUE.

    ENDIF.
  ENDLOOP.
