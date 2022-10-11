*&---------------------------------------------------------------------*
*&  Include           ZBC_SEARCH_OT_FOR01
*&---------------------------------------------------------------------*


FORM get_list_env .
  DATA : lt_result          TYPE TABLE OF ty_result,
         lt_tcetarg         TYPE TABLE OF tcetarg,
         lt_tcedeli         TYPE TABLE OF tcedeli,
         ls_result          TYPE ty_result,
         ls_current         TYPE ty_current,
         ls_first_env       TYPE tcerele,
         lv_tceversion_last TYPE tceversion,
         lv_id              TYPE i,
         lv_level           TYPE i.

  " Lecture de la dernière version
  SELECT version
    FROM tcerele
    INTO lv_tceversion_last
   UP TO 1 ROWS
   ORDER BY version DESCENDING.
  ENDSELECT.

  CHECK sy-subrc EQ 0.

  " Lecture du premier environnement sur la route des transports
  ADD 1 TO lv_id.
  ADD 1 TO lv_level.

  SELECT SINGLE *
    FROM tcerele
    INTO ls_first_env
   WHERE version    EQ   lv_tceversion_last
     AND translayer LIKE gc_translayer_zp.
  IF sy-subrc EQ 0.
    ls_result-id     = lv_id.
    ls_result-env    = ls_first_env-intsys.
    ls_result-mandt  = sy-mandt.
    ls_result-groupe = ls_first_env-consys.
    ls_result-level  = lv_level.
    APPEND ls_result TO lt_result.

    ls_current-env    = ls_first_env-intsys.
    ls_current-mandt  = sy-mandt.
    ls_current-groupe = ls_first_env-consys.
  ENDIF.

  " Lecture des environnements - Hiérarchie suivante
  DO.
    ADD 1 TO lv_level.

    SELECT *
      FROM tcetarg
      INTO TABLE @lt_tcetarg
     WHERE version    EQ @lv_tceversion_last
       AND targ_group EQ @ls_current-groupe
     ORDER BY tarsystem, tarclient.
    IF sy-subrc EQ 0.
      LOOP AT lt_tcetarg INTO DATA(ls_tcetarg).
        CLEAR : ls_result,
                ls_current.

        ADD 1 TO lv_id.

        ls_result-id     = lv_id.
        ls_result-env    = ls_tcetarg-tarsystem.
        ls_result-mandt  = ls_tcetarg-tarclient.
        ls_result-level  = lv_level.
        APPEND ls_result TO lt_result.

        ls_current-env    = ls_tcetarg-tarsystem.
        ls_current-mandt  = ls_tcetarg-tarclient.
        ls_current-groupe = ls_current-groupe.

        SORT lt_result BY id DESCENDING.
      ENDLOOP.
    ELSE.
      " Alternative - Lecture des environnements - Hiérarchie suivante
      SELECT *
        FROM tcedeli
        INTO TABLE lt_tcedeli
       WHERE version = lv_tceversion_last
         AND fromsystem = ls_current-env
         AND fromclient = ls_current-mandt.
      IF sy-subrc EQ 0.
        LOOP AT lt_tcedeli INTO DATA(ls_tcedeli).
          CLEAR : ls_result,
                  ls_current.

          ADD 1 TO lv_id.

          ls_result-id     = lv_id.

          IF ls_tcedeli-tosystem CA '.'.
            SPLIT ls_tcedeli-tosystem
               AT '.'
             INTO ls_result-env
                  ls_result-mandt.
          ELSE.
            ls_result-groupe = ls_tcedeli-tosystem.
          ENDIF.

          ls_result-level  = lv_level.

          APPEND ls_result TO lt_result.

          ls_current-env    = ls_result-env.
          ls_current-mandt  = ls_result-mandt.
          ls_current-groupe = ls_result-groupe.
        ENDLOOP.
      ELSE.
        EXIT.
      ENDIF.
    ENDIF.

  ENDDO.

  SORT lt_result BY id.

  DELETE lt_result WHERE env IS INITIAL.
  IF sy-subrc EQ 0.ENDIF.

  LOOP AT lt_result INTO ls_result.
    CLEAR ls_list_env.

    ls_list_env-mandant = ls_result-mandt.
    ls_list_env-sysnam = ls_result-env.

    APPEND ls_list_env TO gt_list_envs.
  ENDLOOP.

ENDFORM.


FORM get_data USING lt_data_range_ot LIKE gt_range_ot.

***  IF s_ot = abap_true.
  "si code projet non renseigné
  IF p_idpro IS INITIAL.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE gt_t_e070
      FROM e070
     WHERE trkorr  IN lt_data_range_ot
       AND as4user IN p_nni
       AND strkorr EQ space.
    IF sy-subrc NE 0.
      MESSAGE 'Aucun résultat trouvé' TYPE 'W'.
      EXIT.
    ENDIF.

  ELSE.
    SELECT a~trkorr a~trfunction a~trstatus a~tarsystem a~korrdev a~as4user a~as4date a~as4time a~strkorr
      INTO CORRESPONDING FIELDS OF TABLE gt_t_e070
      FROM e070 AS a
      LEFT OUTER JOIN e070a AS b ON a~trkorr = b~trkorr
      INNER JOIN ctsproject AS c ON b~reference = c~trkorr
      WHERE a~trkorr IN lt_data_range_ot
       AND a~as4user IN p_nni
       AND a~strkorr = space " Recherche uniquement les ordres
       AND c~externalid EQ p_idpro.
  ENDIF.


  LOOP AT gt_t_e070 INTO gt_s_e070.
    CLEAR : ls_result,
            gt_s_e07t,
            gt_s_e070a,
            gt_s_e070create,
            gt_s_ctsproject.

    " Attribution des autres variables sur la structure contenant l'ensemble des zones
    ls_result-trkorr = gt_s_e070-trkorr.

    " Recherche le libellé de l'OT
    SELECT SINGLE *
      FROM e07t
      INTO gt_s_e07t
      WHERE trkorr = gt_s_e070-trkorr.

    IF sy-subrc EQ 0.
      ls_result-as4text  = gt_s_e07t-as4text.
    ENDIF.

    DATA : lv_reference      TYPE trvalue,
           lv_tabix_loop_env TYPE i.

    " Recherche du EXTERNALID avec INNER JOIN
    SELECT SINGLE externalid
      FROM ctsproject AS a INNER JOIN e070a AS b ON a~trkorr EQ b~reference
      INTO ls_result-externalid
      WHERE b~attribute EQ lc_scp AND b~trkorr EQ ls_result-trkorr.

*   recherche zone customizing
    SELECT SINGLE * FROM e071k INTO gs_e071k WHERE trkorr = gt_s_e070-trkorr.
    CHECK sy-subrc = 0.

    "recherche zone workbench
    SELECT SINGLE *
      FROM e071
      INTO gs_e071
      WHERE trkorr = gt_s_e070-trkorr.

    ls_result-obj_name = gs_e071-obj_name.
    ls_result-objet = gs_e071-objet.

    " Recherche la date de création
    SELECT SINGLE *
      FROM e070create
      INTO gt_s_e070create
      WHERE trkorr = gt_s_e070-trkorr.

    IF sy-subrc EQ 0.
      IF gt_s_e070-trstatus = 'R'.
        ls_result-cre_date = gt_s_e070create-cre_date.
        ls_result-cre_time = gt_s_e070create-cre_time.
        ls_result-as4date = ' '.
        ls_result-as4time = ' '.
      ELSEIF gt_s_e070-trstatus = 'D'.
        ls_result-cre_date = ' '.
        ls_result-cre_time = ' '.
        ls_result-as4date = gt_s_e070-as4date.
        ls_result-as4time = gt_s_e070-as4time.
      ENDIF.
    ENDIF.

    " Type détaillé de l'OT
    ls_result-trfunction = gt_s_e070-trfunction.

    IF ls_result-trfunction = lc_w.
      ls_result-trfunction = lc_custo.
    ELSEIF ls_result-trfunction = lc_k.
      ls_result-trfunction = lc_workbench.
    ELSE.
      ls_result-trfunction = lc_others.
    ENDIF.

    " code retour
    CLEAR : gt_s_request, gt_s_header.
    gt_s_request-header-trkorr = ls_result-trkorr.

    " Récupération des données d'entête de l'OT
    CALL FUNCTION 'TRINT_READ_REQUEST_HEADER'
      EXPORTING
        iv_read_e070 = 'X'
        iv_read_e07t = 'X'
      CHANGING
        cs_request   = gt_s_request-header
      EXCEPTIONS
        OTHERS       = 1.
    IF sy-subrc <> 0.
      gt_s_request-header-trkorr = ls_result-trkorr.
    ELSE.
      gt_s_header = gt_s_request-header.
    ENDIF.

*     On boucle sur l'ensemble des environnement afin de récupérer chaque code retour (0, 4, 8 ou autres)
    LOOP AT gt_list_envs INTO ls_list_env.
      CLEAR : gt_s_tmscsyslst_typ,
              gt_t_tmscsyslst_typ,
              gt_s_request.

      lv_tabix_loop_env = sy-tabix.

      gt_s_tmscsyslst_typ-sysnam = ls_list_env.
      APPEND gt_s_tmscsyslst_typ TO gt_t_tmscsyslst_typ.

      CALL FUNCTION 'TR_READ_GLOBAL_INFO_OF_REQUEST'
        EXPORTING
          iv_trkorr       = ls_result-trkorr
          iv_dir_type     = 'T'
          it_comm_systems = gt_t_tmscsyslst_typ
        IMPORTING
          es_cofile       = gt_s_request-cofile
          ev_user         = gt_username
          ev_project      = gt_s_request-project.

      SORT gt_s_request-cofile-systems BY systemid.

      READ TABLE gt_s_request-cofile-systems INTO gt_s_cofile_systems
                                             WITH KEY systemid = ls_list_env
                                             BINARY SEARCH.
      IF sy-subrc EQ 0.
        DELETE gt_s_cofile_systems-steps WHERE clientid NE ls_list_env-mandant.
        SORT gt_s_cofile_systems-steps BY rc DESCENDING.

        READ TABLE gt_list_envs INTO DATA(ls_temp_list_env) INDEX lv_tabix_loop_env.
        IF sy-subrc EQ 0.ENDIF.

        IF lv_tabix_loop_env = 1.
          " Affectation des varaibles vers *_1
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_1 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_1 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_1 = lc_color_8.
            ELSE.
              ls_result-cr_1 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps
                                               WITH KEY stepid   = lc_i
                                                     clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0 .
            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_1  = lv_s_actions-date.
              ls_result-heure_1 = lv_s_actions-time.
            ENDIF.
          ELSE.
            ls_result-cr_1 = '@0V@'. " Uniquement dans le cas du premier environnement : Généralement : Développement
          ENDIF.

        ELSEIF lv_tabix_loop_env = 2.
          " Affectation des varaibles vers *_2
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_2 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_2 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_2 = lc_color_8.
            ELSE.
              ls_result-cr_2 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps WITH KEY stepid   = lc_i
                                                                               clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0.
            CLEAR lv_s_actions.

            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_2  = lv_s_actions-date.
              ls_result-heure_2 = lv_s_actions-time.
            ENDIF.
          ENDIF.

          " Affectation des varaibles vers *_3
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_3 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_3 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_3 = lc_color_8.
            ELSE.
              ls_result-cr_3 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps WITH KEY stepid   = lc_i
                                                                               clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0.
            CLEAR lv_s_actions.

            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_3  = lv_s_actions-date.
              ls_result-heure_3 = lv_s_actions-time.
            ENDIF.
          ENDIF.

          " Affectation des varaibles vers *_4
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_4 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_4 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_4 = lc_color_8.
            ELSE.
              ls_result-cr_4 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps WITH KEY stepid   = lc_i
                                                                               clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0.
            CLEAR lv_s_actions.

            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_4  = lv_s_actions-date.
              ls_result-heure_4 = lv_s_actions-time.
            ENDIF.
          ENDIF.


          " Affectation des varaibles vers *_5
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_5 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_5 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_5 = lc_color_8.
            ELSE.
              ls_result-cr_5 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps WITH KEY stepid   = lc_i
                                                                               clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0.
            CLEAR lv_s_actions.

            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_5  = lv_s_actions-date.
              ls_result-heure_5 = lv_s_actions-time.
            ENDIF.
          ENDIF.


          " Affectation des varaibles vers *_6
          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps INDEX 1. " Toujours prendre le premier
          IF sy-subrc EQ 0.
            IF gt_s_cofile_steps-rc EQ 0.
              ls_result-cr_6 = lc_color_0.
            ELSEIF gt_s_cofile_steps-rc EQ 4.
              ls_result-cr_6 = lc_color_4.
            ELSEIF gt_s_cofile_steps-rc EQ 8.
              ls_result-cr_6 = lc_color_8.
            ELSE.
              ls_result-cr_6 = lc_color_8.
            ENDIF.
          ENDIF.

          READ TABLE gt_s_cofile_systems-steps INTO gt_s_cofile_steps WITH KEY stepid   = lc_i
                                                                               clientid = ls_temp_list_env-mandant.
          IF sy-subrc EQ 0.
            CLEAR lv_s_actions.

            DESCRIBE TABLE gt_s_cofile_steps-actions LINES lv_nb_s_cofile_steps_actions.

            READ TABLE gt_s_cofile_steps-actions INTO lv_s_actions INDEX lv_nb_s_cofile_steps_actions.
            IF sy-subrc EQ 0.
              ls_result-date_6  = lv_s_actions-date.
              ls_result-heure_6 = lv_s_actions-time.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.


    ls_result-as4user  = gt_s_e070-as4user.
    ls_result-cre_date = gt_s_e070create-cre_date.
    ls_result-cre_time = gt_s_e070create-cre_time.
    ls_result-as4date  = gt_s_e070-as4date.
    ls_result-as4time  = gt_s_e070-as4time.
    ls_result-type_ob  = gs_e071k-mastertype.
    ls_result-obj_cat  = gs_e071k-mastername.
    ls_result-obj_list = gs_e071k-tabkey.


    READ TABLE gt_trstatus INTO ls_trstatus WITH KEY domvalue_l = gt_s_e070-trstatus BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_result-trstatus = ls_trstatus-ddtext.
    ENDIF.

    READ TABLE gt_trfunctions INTO ls_trfunction WITH KEY domvalue_l = gt_s_e070-trfunction BINARY SEARCH.
    IF sy-subrc EQ 0.
      ls_result-trfunction = ls_trfunction-ddtext.
    ENDIF.

    APPEND ls_result TO gt_results.
  ENDLOOP.

ENDFORM.

FORM get_fieldcat.

  DATA : lv_nb_env TYPE i.


  IF s_o_cust = abap_true.
    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'type_ob'.
    ls_fieldcat-seltext_m  = 'Type d''objet'.
    ls_fieldcat-emphasize = 'C200'.
    APPEND ls_fieldcat TO gt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'obj_cat'.
    ls_fieldcat-seltext_m  = 'Nom de la table/vue'.
    ls_fieldcat-emphasize = 'C100'.
    APPEND ls_fieldcat TO gt_fieldcat.

    CLEAR ls_fieldcat.
    ls_fieldcat-fieldname = 'obj_list'.
    ls_fieldcat-seltext_m  = 'Contenu de l''occurence'.
    ls_fieldcat-emphasize = 'C200'.
    APPEND ls_fieldcat TO gt_fieldcat.
  ENDIF.



  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'trkorr'.
  ls_fieldcat-seltext_m  = 'Ordre/Tâche'.
  ls_fieldcat-emphasize = 'C411'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'trstatus'.
  ls_fieldcat-seltext_m  = 'Status'.
  ls_fieldcat-emphasize = 'C200'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'as4date'.
  ls_fieldcat-seltext_m  = 'Créé le'.
  ls_fieldcat-emphasize = 'C100'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'cre_date'.
  ls_fieldcat-seltext_m  = 'Modifié le'.
  ls_fieldcat-emphasize = 'C200'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'trfunction'.
  ls_fieldcat-seltext_m  = 'Type'.
  ls_fieldcat-emphasize = 'C100'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'as4user'.
  ls_fieldcat-seltext_m  = 'Titulaire'.
  ls_fieldcat-emphasize = 'C200'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'as4text'.
  ls_fieldcat-seltext_m  = 'Description'.
  ls_fieldcat-emphasize = 'C100'.
  APPEND ls_fieldcat TO gt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-fieldname = 'externalid'.
  ls_fieldcat-seltext_m  = 'Code Projet'.
  ls_fieldcat-emphasize = 'C200'.
  APPEND ls_fieldcat TO gt_fieldcat.

  "Display data according to the number of envs (case 6max)
  DESCRIBE TABLE gt_list_envs LINES lv_nb_env.

  IF lv_nb_env >= 1.
    READ TABLE gt_list_envs INTO ls_list_env INDEX 1.
    IF sy-subrc EQ 0.
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'cr_1'.     "code retour
      CONCATENATE ls_list_env-sysnam
                  ls_list_env-mandant
             INTO ls_fieldcat-seltext_m
     SEPARATED BY '.'.
      ls_fieldcat-emphasize = 'C100'.
      APPEND ls_fieldcat TO gt_fieldcat.

      " Date
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'date_1'.
      CONCATENATE 'Date import/'
                  ls_list_env-sysnam
                  '.'
                  ls_list_env-mandant
             INTO ls_fieldcat-seltext_m.
      ls_fieldcat-emphasize = 'C200'.
      APPEND ls_fieldcat TO gt_fieldcat.
      " Heure
      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'heure_1' .
      CONCATENATE 'Heure import/'
               ls_list_env-sysnam
               '.'
               ls_list_env-mandant
          INTO ls_fieldcat-seltext_m.
      ls_fieldcat-emphasize = 'C100'.
      APPEND ls_fieldcat TO gt_fieldcat.
    ENDIF.
  ENDIF.

  IF lv_nb_env >= 2.
    READ TABLE gt_list_envs INTO ls_list_env INDEX 2.
    IF sy-subrc EQ 0.

      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'cr_2'.
      CONCATENATE ls_list_env-sysnam
                  ls_list_env-mandant
             INTO ls_fieldcat-seltext_m
     SEPARATED BY '.'.
      ls_fieldcat-emphasize = 'C200'.
      APPEND ls_fieldcat TO gt_fieldcat.

      CLEAR ls_fieldcat.
      ls_fieldcat-fieldname = 'date_2'.
      CONCATENATE 'Date import/'
                  ls_list_env-sysnam
                  '.'
                  ls_list_env-mandant
             INTO ls_fieldcat-seltext_m.
      ls_fieldcat-emphasize = 'C100'.
      APPEND ls_fieldcat TO gt_fieldcat.

      CLEAR ls_fieldcat.
      IF ls_result-trstatus = 'Modifiable'.
        ls_result-heure_imp = ' '.
      ELSE.
        ls_fieldcat-fieldname = 'heure_2' .
        CONCATENATE 'Heure import/'
                 ls_list_env-sysnam
                 '.'
                 ls_list_env-mandant
            INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.
      ENDIF.
    ENDIF.
*  ENDIF.

    IF lv_nb_env >= 3.
      READ TABLE gt_list_envs INTO ls_list_env INDEX 3.
      IF sy-subrc EQ 0.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'cr_3'.
        CONCATENATE ls_list_env-sysnam
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m
       SEPARATED BY '.'.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'date_3'.
        CONCATENATE 'Date import/'
                    ls_list_env-sysnam
                    '.'
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'heure_3' .
        CONCATENATE 'Heure import/'
                 ls_list_env-sysnam
                 '.'
                 ls_list_env-mandant
            INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.
      ENDIF.
    ENDIF.

    IF lv_nb_env >= 4.
      READ TABLE gt_list_envs INTO ls_list_env INDEX 4.
      IF sy-subrc EQ 0.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'cr_4'.
        CONCATENATE ls_list_env-sysnam
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m
       SEPARATED BY '.'.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'date_4'.
        CONCATENATE 'Date import/'
                    ls_list_env-sysnam
                    '.'
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'heure_4' .
        CONCATENATE 'Heure import/'
                 ls_list_env-sysnam
                 '.'
                 ls_list_env-mandant
            INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.
      ENDIF.
    ENDIF.

    IF lv_nb_env >= 5.
      READ TABLE gt_list_envs INTO ls_list_env INDEX 5.
      IF sy-subrc EQ 0.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'cr_5'.
        CONCATENATE ls_list_env-sysnam
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m
       SEPARATED BY '.'.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'date_5'.
        CONCATENATE 'Date import/'
                    ls_list_env-sysnam
                    '.'
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'heure_5' .
        CONCATENATE 'Heure import/'
                 ls_list_env-sysnam
                 '.'
                 ls_list_env-mandant
            INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.
      ENDIF.
    ENDIF.

    IF lv_nb_env >= 6.
      READ TABLE gt_list_envs INTO ls_list_env INDEX 6.
      IF sy-subrc EQ 0.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'cr_6'.
        CONCATENATE ls_list_env-sysnam
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m
       SEPARATED BY '.'.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'date_6'.
        CONCATENATE 'Date import/'
                    ls_list_env-sysnam
                    '.'
                    ls_list_env-mandant
               INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C200'.
        APPEND ls_fieldcat TO gt_fieldcat.

        CLEAR ls_fieldcat.
        ls_fieldcat-fieldname = 'heure_6' .
        CONCATENATE 'Heure import/'
                 ls_list_env-sysnam
                 '.'
                 ls_list_env-mandant
            INTO ls_fieldcat-seltext_m.
        ls_fieldcat-emphasize = 'C100'.
        APPEND ls_fieldcat TO gt_fieldcat.
      ENDIF.
    ENDIF.

    "Partie à mettre dans fieldcat CUSTO

    "ADD WORKBENCH ELEMENTS


  ENDIF.

ENDFORM.

FORM data_prerequis .

  CONSTANTS : lc_tr LIKE  dd07l-domname VALUE 'TRSTATUS',
              lc_fu LIKE  dd07l-domname VALUE 'TRFUNCTION'.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = lc_tr
      text           = 'X'
      langu          = 'F'
    TABLES
      dd07v_tab      = gt_trstatus
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    SORT gt_trstatus BY domvalue_l ASCENDING.
  ENDIF.

  CALL FUNCTION 'DD_DOMVALUES_GET'
    EXPORTING
      domname        = lc_fu
      text           = 'X'
      langu          = 'F'
    TABLES
      dd07v_tab      = gt_trfunctions
    EXCEPTIONS
      wrong_textflag = 1
      OTHERS         = 2.
  IF sy-subrc = 0.
    SORT gt_trfunctions BY domvalue_l ASCENDING.
  ENDIF.

ENDFORM.

FORM f_top_of_page.

  CLEAR t_header.
  wa_header-typ = 'H'.
  wa_header-info = 'Ordres de transport'.
  APPEND wa_header TO t_header.
  CLEAR wa_header.

  " Nombre de results
  DESCRIBE TABLE gt_results LINES ld_lines.
  ld_linesc = ld_lines.
  CONCATENATE 'Nombre d''entrées'
              ld_linesc
         INTO t_line
 SEPARATED BY space.

  wa_header-typ = 'A'.
  wa_header-info = t_line.
  APPEND wa_header TO t_header.
  CLEAR : wa_header, t_line.

  CALL FUNCTION 'REUSE_ALV_COMMENTARY_WRITE'
    EXPORTING
      it_list_commentary = t_header.

ENDFORM.

FORM show.

*Sorting----------
  DATA t_sort TYPE slis_t_sortinfo_alv.
  DATA wa_sort TYPE slis_sortinfo_alv.

  wa_sort-fieldname = 'trkorr'.

  APPEND wa_sort TO t_sort.
  "-----------------
  gs_layout-colwidth_optimize = abap_true.

*  IF s_ot = abap_true.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program     = sy-repid
      i_callback_top_of_page = 'F_TOP_OF_PAGE'
      is_layout              = gs_layout
      it_fieldcat            = gt_fieldcat[]
      it_sort                = t_sort
      i_save                 = 'A'
      i_default              = 'X'
    TABLES
      t_outtab               = gt_results
    EXCEPTIONS
      program_error          = 1
      OTHERS                 = 2.
  IF sy-subrc <> 0.
    MESSAGE i002(zmess).
  ENDIF.


ENDFORM.


**&---------------------------------------------------------------------*
**&      Form  SEARCH_CUSTO
**&---------------------------------------------------------------------*
FORM search_custo .

  DATA: lt_trkorr TYPE TABLE OF trkorr,
        lt_e071k  TYPE TABLE OF e071k.


  SELECT trkorr mastertype mastername tabkey
    FROM e071k
    INTO TABLE lt_e071k
    WHERE mastertype IN typ_ob
     AND  mastername IN nom1_ob
     AND  tabkey     IN nom2_ob.

     CHECK sy-subrc = 0.

     SELECT trkorr
       INTO TABLE lt_trkorr
     FROM e070
     FOR ALL ENTRIES IN lt_e071k
     WHERE trkorr  =  lt_e071k-trkorr
     AND strkorr = space.

  CHECK sy-subrc = 0.

  LOOP AT lt_trkorr INTO DATA(ls_trkorr) .
    CLEAR ls_range_ot.
    ls_range_ot-sign    = 'I'.
    ls_range_ot-option  = 'EQ'.
    ls_range_ot-low     = ls_trkorr.
    APPEND ls_range_ot TO gt_range_ot.
  ENDLOOP.

ENDFORM.
**&---------------------------------------------------------------------*
**&      Form  SEARCH_WORK
**&---------------------------------------------------------------------*
FORM search_work .
  DATA: lt_trkorr TYPE TABLE OF trkorr,
        lt_e071   TYPE TABLE OF e071.

  SELECT *
    INTO TABLE lt_e071
    FROM e071
    WHERE obj_name IN nam_obj
    AND  object    IN obj.

    CHECK sy-subrc = 0.

    SELECT trkorr
      INTO TABLE lt_trkorr
      FROM e070
      FOR ALL ENTRIES IN lt_e071
      WHERE trkorr  =  lt_e071-trkorr
      AND strkorr = space.

  CHECK sy-subrc = 0.

  LOOP AT lt_trkorr INTO DATA(ls_trkorr) .
    CLEAR ls_range_ot.
    ls_range_ot-sign    = 'I'.
    ls_range_ot-option  = 'EQ'.
    ls_range_ot-low     = ls_trkorr.
    APPEND ls_range_ot TO gt_range_ot.
  ENDLOOP.

ENDFORM.
