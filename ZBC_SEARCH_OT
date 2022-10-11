*&---------------------------------------------------------------------*
*& Report ZBC_SEARCH_OT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZBC_SEARCH_OT.

INCLUDE zbc_search_ot_top01.
INCLUDE zbc_search_ot_sel01.
INCLUDE zbc_search_ot_for01.

START-OF-SELECTION.

  CLEAR gt_range_ot.

  PERFORM get_list_env.
  PERFORM data_prerequis.

  IF s_ot EQ abap_true.

    PERFORM get_data USING p_ot[].

  ELSEIF s_o_cust EQ abap_true.
    PERFORM search_custo.
    IF sy-subrc NE 0.

      MESSAGE 'Aucun résultat trouvé' TYPE 'W'.
      EXIT.

    ELSE.
      PERFORM get_data USING gt_range_ot.
    ENDIF.

  ELSEIF s_o_work EQ abap_true.
    PERFORM search_work.
    IF sy-subrc NE 0.

      MESSAGE 'Aucun résultat trouvé' TYPE 'W'.
      EXIT.

    ELSE.
      PERFORM get_data USING gt_range_ot.
    ENDIF.

  ENDIF.

  PERFORM get_fieldcat.
  PERFORM show.
