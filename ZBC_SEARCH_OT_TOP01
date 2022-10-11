*&---------------------------------------------------------------------*
*&  Include           ZBC_SEARCH_OT_TOP01
*&---------------------------------------------------------------------*


TABLES: e070, e071, e07t, e070create, ctsproject, e070a, tcedeli, tcerele, tcetarg, tcetarghdr, e071k.
TABLES: adr6.


TYPE-POOLS : slis,
             ctslg.

TYPES: BEGIN OF ty_e070,
         trkorr     TYPE e070-trkorr,
         trfunction TYPE e070-trfunction,
         strkorr    TYPE e070-strkorr,
         as4user    TYPE e070-as4user,
         as4date    TYPE e070-as4date,
         externalps TYPE ctsproject-externalps,
         externalid TYPE ctsproject-externalid,
       END OF ty_e070,

       BEGIN OF ty_ctsproject,
         trkorr     TYPE ctsproject-trkorr,
         externalps TYPE ctsproject-externalps,
         externalid TYPE ctsproject-externalid,
       END OF ty_ctsproject,

       BEGIN OF ty_final,
         trkorr         TYPE e070-trkorr,
         trfunction     TYPE ddtext,
         trfunctn_l(20) TYPE c,
         strkorr        TYPE e070-strkorr,
         as4user        TYPE e070-as4user,
         trstatus       TYPE ddtext,
         as4date        TYPE e070-as4date,
         as4time        TYPE e070-as4time,
         trstatus_t(20) TYPE c,
         reference      TYPE e070a-reference,
         as4text        TYPE e07t-as4text,
         cre_date       TYPE e070create-cre_date,
         cre_time       TYPE e070create-cre_time,
         externalps     TYPE ctsproject-externalps,
         externalid     TYPE ctsproject-externalid,
         env_1          TYPE tmscsys-sysnam,
         mandt_1        TYPE mandt,
         cr_1           TYPE icon_d,
         date_1         TYPE e070-as4date,
         heure_1        TYPE e070-as4time,
         env_2          TYPE tmscsys-sysnam,
         mandt_2        TYPE mandt,
         cr_2           TYPE icon_d,
         date_2         TYPE e070-as4date,
         heure_2        TYPE e070-as4time,
         env_3          TYPE tmscsys-sysnam,
         mandt_3        TYPE mandt,
         cr_3           TYPE icon_d,
         date_3         TYPE e070-as4date,
         heure_3        TYPE e070-as4time,
         env_4          TYPE tmscsys-sysnam,
         mandt_4        TYPE mandt,
         cr_4           TYPE icon_d,
         date_4         TYPE e070-as4date,
         heure_4        TYPE e070-as4time,
         env_5          TYPE tmscsys-sysnam,
         mandt_5        TYPE mandt,
         cr_5           TYPE icon_d,
         date_5         TYPE e070-as4date,
         heure_5        TYPE e070-as4time,
         env_6          TYPE tmscsys-sysnam,
         mandt_6        TYPE mandt,
         cr_6           TYPE icon_d,
         date_6         TYPE e070-as4date,
         heure_6        TYPE e070-as4time,
         env_7          TYPE tmscsys-sysnam,
         mandt_7        TYPE mandt,
         cr_7           TYPE icon_d,
         date_7         TYPE e070-as4date,
         heure_7        TYPE e070-as4time,
         env_8          TYPE tmscsys-sysnam,
         mandt_8        TYPE mandt,
         cr_8           TYPE icon_d,
         date_8         TYPE e070-as4date,
         heure_8        TYPE e070-as4time,
         light(4),""
         systemid       TYPE tarsystem, " target system
         date_imp       TYPE e070-as4date,
         heure_imp      TYPE e070-as4time,
         type_ob        TYPE e071k-mastertype,
         obj_cat        TYPE e071k-mastername,
         obj_list       TYPE e071k-tabkey,
         obj_name       TYPE e071-obj_name,
         objet          TYPE e071-object,

       END OF ty_final.

DATA  lv_mandt       TYPE char3.

DATA: gt_e070 TYPE TABLE OF ty_e070.
DATA: gt_wa_e070 TYPE ty_e070.

DATA: gt_ctsproject TYPE TABLE OF ty_ctsproject.
DATA: gt_wa_ctsproject TYPE ty_ctsproject.

DATA : gt_results TYPE STANDARD TABLE OF ty_final,
       ls_result  TYPE ty_final,

       lt_custom  TYPE TABLE OF e071k.

DATA: gt_envs  TYPE TABLE OF intsys,
      gt_s_env TYPE intsys.

DATA: gt_t_e070 TYPE TABLE OF e070,
      gt_s_e070 TYPE e070,
      lv_t_e070 TYPE TABLE OF e070,
      lv_s_e070 TYPE e070.


DATA: gt_e071k TYPE TABLE OF e071k,
      gs_e071k TYPE e071k.

DATA: gt_e071 TYPE TABLE OF ty_final,
      gs_e071 TYPE ty_final.

DATA: gt_s_e07t       TYPE e07t,
      gt_s_e070create TYPE e070create,
      gt_s_ctsproject TYPE ctsproject,
      gt_s_e070a      TYPE e070a.

DATA: gt_fieldcat TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ls_fieldcat TYPE slis_fieldcat_alv,
      gs_layout   TYPE slis_layout_alv.

DATA: gt_fieldcatt TYPE slis_t_fieldcat_alv WITH HEADER LINE,
      ls_fieldcatt TYPE slis_fieldcat_alv,
      gs_layoutt   TYPE slis_layout_alv.

TYPES : BEGIN OF ty_env,
          sysnam  TYPE tmssysnam,
          holdcon	TYPE flag,
          mandant TYPE mandt,
        END OF ty_env,

        BEGIN OF ty_result,
          id     TYPE i,
          env    TYPE intsys,
          mandt  TYPE mandant,
          groupe TYPE consys,
          level  TYPE i,
        END OF ty_result,

        BEGIN OF ty_current,
          env    TYPE intsys,
          mandt  TYPE mandant,
          groupe TYPE consys,
        END OF ty_current,

        BEGIN OF ty_iddesc,
          externalid TYPE ctsproject-externalid,
          descriptn  TYPE ctsproject-descriptn,
        END OF ty_iddesc,

        BEGIN OF info,
          systemid,
          clientid,
          rc,
          date,
          time,
        END OF info,

        BEGIN OF ty_range_ot,
          sign   TYPE ddsign,
          option TYPE ddoption,
          low    TYPE trkorr,
          high   TYPE trkorr,
        END OF ty_range_ot.

DATA: gt_range_ot TYPE TABLE OF ty_range_ot,
      ls_range_ot  TYPE ty_range_ot.

DATA: gt_list_envs TYPE TABLE OF ty_env,
      ls_list_env  TYPE ty_env.

DATA : gt_repid TYPE syrepid,
       lt_fcat  TYPE slis_t_fieldcat_alv.

DATA: gt_s_request                 TYPE ctslg_request_info,
      gt_s_header                  TYPE trwbo_request_header,
      gt_username                  TYPE e070-as4user,
      gt_s_cofile_systems          TYPE ctslg_system,
      gt_s_cofile_steps            TYPE ctslg_step,
      lv_nb_s_cofile_steps_actions TYPE i,
      gt_color_t                   TYPE char4,
      gt_t_tmscsyslst_typ          TYPE TABLE OF tmscsyslst,
      gt_s_tmscsyslst_typ          TYPE tmscsyslst,
      lv_s_actions                 TYPE ctslg_action.

DATA: gt_trfunctions TYPE TABLE OF dd07v,
      gt_trstatus    TYPE TABLE OF dd07v,
      ls_trfunction  TYPE dd07v,
      ls_trstatus    TYPE dd07v.

DATA : idd07v TYPE TABLE OF  dd07v WITH HEADER LINE.

DATA : t_header      TYPE slis_t_listheader,
       wa_header     TYPE slis_listheader,
       t_line        LIKE wa_header-info,
       ld_lines      TYPE i,
       ld_linesc(10) TYPE c,
       i_sort        TYPE slis_t_sortinfo_alv.

DATA: itab TYPE TABLE OF info,
      data LIKE LINE OF itab.

DATA: es_cofile TYPE ctslg_cofile,
      system    TYPE ctslg_system,
      step      TYPE ctslg_step,
      action    TYPE ctslg_action.

CONSTANTS:    lc_vir           TYPE char3  VALUE 'VIR',
              lc_s4h           TYPE char3  VALUE 'S4H',
              lc_color_0       TYPE char4  VALUE '@5B@',
              lc_color_4       TYPE char4  VALUE '@5D@',
              lc_color_8       TYPE char4  VALUE '@5C@',
              lc_scp           TYPE char15 VALUE 'SAP_CTS_PROJECT',
              lc_d             TYPE char1  VALUE 'D',
              lc_modif         TYPE char10 VALUE 'Modifiable',
              lc_modif_p       TYPE char19 VALUE 'Modifiable, protégé',
              lc_r             TYPE char1  VALUE 'R',
              lc_l             TYPE char1  VALUE 'L',
              lc_o             TYPE char1  VALUE 'O',
              lc_n             TYPE char1  VALUE 'N',
              lc_w             TYPE char1  VALUE 'W',
              lc_k             TYPE char1  VALUE 'K',
              lc_t             TYPE char1  VALUE 'T',
              lc_v             TYPE char1  VALUE 'V',
              lc_i             TYPE char1  VALUE 'I',
              lc_libere        TYPE char6  VALUE 'Libéré',
              lc_libere_oth    TYPE char58 VALUE 'Libéré (protection contre import active pr objets réparés)',
              lc_others        TYPE char5  VALUE 'Autre',
              lc_workbench     TYPE char9  VALUE 'Workbench',
              lc_custo         TYPE char11 VALUE 'Customizing',
              lc_cc            TYPE char1  VALUE '/',
              gc_translayer_zp TYPE translayer VALUE 'Z%'
              .

TYPES: BEGIN OF ty_custom,
         mastertype TYPE e071k-mastertype,
         mastername TYPE e071k-mastername,
         tabkey     TYPE e071k-tabkey,
         obj_name   TYPE e071-obj_name,
         object     TYPE e071-object,
       END OF ty_custom.

DATA: it_e070   TYPE TABLE OF e070,
      it_s_e070 TYPE e070.


DATA: lt_columns TYPE STANDARD TABLE OF ty_iddesc.


DATA: gv_xstring      TYPE xstring,  " cl_salv_table wich will be converted to xstring
      email           TYPE adr6-smtp_addr,
      gv_xlen         TYPE int4,
      gr_request      TYPE REF TO cl_bcs, "to create the send request
      gv_body_text    TYPE bcsy_text,
      gv_subject      TYPE so_obj_des,
      gv_att          TYPE so_obj_des,
      gr_recipient    TYPE REF TO if_recipient_bcs,  "create list of recipient to distribute emails
      gr_document     TYPE REF TO cl_document_bcs,   "message
      gv_size         TYPE so_obj_len,
      it_receivers    TYPE STANDARD TABLE OF  somlreci1,
      wa_it_receivers LIKE LINE OF it_receivers,
      it_message      TYPE STANDARD TABLE OF solisti1,
      wa_it_message   LIKE LINE OF it_message,
      c1(99)          TYPE c,
      c2(15)          TYPE c,
      ls_sflight      TYPE sflight,
      gt_data_csv     TYPE TABLE OF string,
      ls_data_csv     TYPE string,
      lv_price        TYPE string,
      lv_seatsmax     TYPE string,
      lv_seatsocc     TYPE string,
      main_text       TYPE bcsy_text.
