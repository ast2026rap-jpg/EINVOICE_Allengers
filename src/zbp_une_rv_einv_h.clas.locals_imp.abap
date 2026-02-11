CLASS lhc_einvoice DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR einvoice RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR einvoice RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR einvoice RESULT result.

    METHODS generateeinvoice FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~generateeinvoice RESULT result.
    METHODS canceleinv FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~canceleinv RESULT result.
    METHODS generateewaybill FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~generateewaybill RESULT result.
    METHODS cancelewaybill FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~cancelewaybill RESULT result.

ENDCLASS.

CLASS lhc_einvoice IMPLEMENTATION.

  METHOD get_instance_features.

   " Read final state of entities for returning result
    READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
      ENTITY Einvoice
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result)
      REPORTED DATA(ltt_reported)
      FAILED   DATA(ltt_failed).

       result = VALUE #( FOR ls_result IN lt_result
                        ( %tky = ls_result-%tky
*                          %features-%action-GenerateEway = COND #( WHEN ls_result-%is_draft <> '01'
*                                                         THEN if_abap_behv=>fc-o-enabled
*                                                         ELSE if_abap_behv=>fc-o-disabled )
                        %features-%action-GenerateEinvoice = COND #( WHEN ls_result-Irnno IS NOT INITIAL OR ls_result-%is_draft = '01'
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled )

                        %features-%action-GenerateEWaybill = COND #( WHEN ls_result-Ewaybillno IS NOT INITIAL OR ls_result-%is_draft = '01'
                                                      THEN if_abap_behv=>fc-o-disabled
                                                      ELSE if_abap_behv=>fc-o-enabled )


                                                       ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.



  METHOD generateeinvoice.
    TRY.
        DATA(lo_api)    = NEW zune_cls_helper_einv( ).
        DATA: lv_result   TYPE string,
              lv_json     TYPE string,
              ls_response TYPE zune_cls_helper_einv=>ty_response.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).
          " Build JSON payload (example values, replace with entity data if needed)
          lv_json = lo_api->build_einvoice_payload(
                       iv_docnum = CONV string( <ls_result>-billingdocnum )
                       iv_documenttype = CONV string( <ls_result>-documnenttype )
                       iv_companycode = CONV string( <ls_result>-companycode )
                       iv_fisyear = CONV string( <ls_result>-fiscalyear )
                       ).

          " Call API
          lv_result = lo_api->generate_einvoie( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-billingdocnum ) ).
          " Parse response JSON into structure
          ls_response = lo_api->get_einvoice_response( iv_json = lv_result ).

          " Check success
          IF ls_response-govt_response-success = 'Y'.

            " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
            DATA(lv_ackdt) = ``.
            DATA(lv_ewbvalidtill) = ``.
            DATA(lv_errorresponse) = ``.
            IF ls_response-govt_response-ackdt IS NOT INITIAL.
              lv_ackdt = ls_response-govt_response-ackdt+0(4) &&
               ls_response-govt_response-ackdt+5(2) &&
               ls_response-govt_response-ackdt+8(2).
            ENDIF.
            " Update entity fields
            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
              ENTITY einvoice
              UPDATE FIELDS ( acknowledgeno acknowledgedate irnno irngeneratedate irnqr irnstatus  postingjson resposnsejson )
              WITH VALUE #(
                FOR ls_keys IN keys (
                  %tky                  = ls_keys-%tky

                  acknowledgeno            = ls_response-govt_response-ackno
                  acknowledgedate          = lv_ackdt
                  irnno = ls_response-govt_response-irn
                  irngeneratedate  = lv_ackdt
                  irnqr           = ls_response-govt_response-signedqrcode
                  irnstatus = ls_response-govt_response-status
                  postingjson = lv_json
                  resposnsejson = ''

                )
              )
              REPORTED DATA(lt_reported)
              FAILED   DATA(lt_failed).
            " Handle reported records
            reported = CORRESPONDING #( DEEP lt_reported ).
            " Success message
            APPEND VALUE #(
              %tky = keys[ 1 ]-%tky
              %msg = new_message_with_text(
                       text     = |E-Invoice Generated: { ls_response-govt_response-irn }|
                       severity = if_abap_behv_message=>severity-success )
            ) TO reported-einvoice.
          ELSE.

            " Error messages from API
            LOOP AT ls_response-govt_response-errordetails INTO DATA(ls_err).

              lv_errorresponse = |{ lv_errorresponse } Error { ls_err-error_code }: { ls_err-error_message }\n|.


*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.
            ENDLOOP.


            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
           ENTITY einvoice
           UPDATE FIELDS ( postingjson resposnsejson )
           WITH VALUE #(
             FOR ls_keys IN keys (
               %tky                  = ls_keys-%tky

               postingjson            = lv_json
               resposnsejson   = lv_errorresponse

             )
           )
           REPORTED DATA(lttt_reported)
           FAILED   DATA(lttt_failed).
            " Handle reported records
            "reported = CORRESPONDING #( DEEP lttt_reported ).


          ENDIF.

          " Read final state of entities for returning result
          READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
            ENTITY einvoice
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_result)
            REPORTED DATA(ltt_reported)
            FAILED   DATA(ltt_failed).

          result = VALUE #( FOR ls_result IN lt_result
                              ( %tky = ls_result-%tky
                              %param-%data = ls_result-%data
                              ) ).

        ENDLOOP.

      CATCH cx_root
                INTO DATA(lx_err).

        " API technical error
        APPEND VALUE #(
          %tky = keys[ 1 ]-%tky
          %msg = new_message_with_text(
                   text     = lx_err->get_text( )
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-einvoice.

    ENDTRY.

  ENDMETHOD.

  METHOD canceleinv.
    DATA(lo_api)    = NEW zune_cls_helper_einv( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper_einv=>ty_response.

    " Read final state of entities for returning result
    READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
      ENTITY einvoice
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt1_result)
      REPORTED DATA(ltt1_reported)
      FAILED   DATA(ltt1_failed).
    LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).
      " Build JSON payload (example values, replace with entity data if needed)
      lv_json = lo_api->build_einvoice_payload_cancel(
                   iv_docnum = CONV string( <ls_result>-billingdocnum )
                   iv_irnno = CONV string( <ls_result>-irnno )
                   iv_cancelrsncode = CONV string( <ls_result>-irncanrsncode )
                   iv_cancelrmrk = CONV string( <ls_result>-irnremarks )
                   ).

      " Call API
      lv_result = lo_api->cancel_einvoice( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-billingdocnum ) ).
      " Parse response JSON into structure
      ls_response = lo_api->get_einvoice_response( iv_json = lv_result ).

      " Check success
      IF ls_response-govt_response-success = 'Y'.

        " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
        DATA(lv_ackdt) = ``.
        DATA(lv_candt) = ``.
        DATA(lv_ewbvalidtill) = ``.
        DATA(lv_errorresponse) = ``.
        IF ls_response-govt_response-ackdt IS NOT INITIAL.
          lv_ackdt = ls_response-govt_response-ackdt+0(4) &&
           ls_response-govt_response-ackdt+5(2) &&
           ls_response-govt_response-ackdt+8(2).

          lv_candt = ls_response-govt_response-canceldate+0(4) &&
          ls_response-govt_response-canceldate+5(2) &&
          ls_response-govt_response-canceldate+8(2).
        ENDIF.
        " Update entity fields
        MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY einvoice
          UPDATE FIELDS ( acknowledgeno acknowledgedate irnno irngeneratedate irnqr irnstatus  postingjson resposnsejson irncanceldate )
          WITH VALUE #(
            FOR ls_keys IN keys (
              %tky                  = ls_keys-%tky

              acknowledgeno            = ls_response-govt_response-ackno
              acknowledgedate          = lv_ackdt
              irnno = ls_response-govt_response-irn
              irngeneratedate  = lv_ackdt
              irnqr           = ls_response-govt_response-signedqrcode
              irnstatus = ls_response-document_status
              postingjson = lv_json
              resposnsejson = ''
              irncanceldate = lv_candt

            )
          )
          REPORTED DATA(lt_reported)
          FAILED   DATA(lt_failed).
        " Handle reported records
        reported = CORRESPONDING #( DEEP lt_reported ).
        " Success message
        APPEND VALUE #(
          %tky = keys[ 1 ]-%tky
          %msg = new_message_with_text(
                   text     = |E-Invoice Cancelled: { ls_response-govt_response-irn }|
                   severity = if_abap_behv_message=>severity-success )
        ) TO reported-einvoice.
      ELSE.

        " Error messages from API
        LOOP AT ls_response-govt_response-errordetails INTO DATA(ls_err).

          lv_errorresponse = |{ lv_errorresponse } Error { ls_err-error_code }: { ls_err-error_message }\n|.


*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.
        ENDLOOP.


        MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
       ENTITY einvoice
       UPDATE FIELDS ( postingjson resposnsejson )
       WITH VALUE #(
         FOR ls_keys IN keys (
           %tky                  = ls_keys-%tky

           postingjson            = lv_json
           resposnsejson   = lv_errorresponse

         )
       )
       REPORTED DATA(lttt_reported)
       FAILED   DATA(lttt_failed).
        " Handle reported records
        "reported = CORRESPONDING #( DEEP lttt_reported ).


      ENDIF.

      " Read final state of entities for returning result
      READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
        ENTITY einvoice
        ALL FIELDS
        WITH CORRESPONDING #( keys )
        RESULT DATA(lt_result)
        REPORTED DATA(ltt_reported)
        FAILED   DATA(ltt_failed).

      result = VALUE #( FOR ls_result IN lt_result
                          ( %tky = ls_result-%tky
                          %param-%data = ls_result-%data
                          ) ).

    ENDLOOP.

  ENDMETHOD.

  METHOD generateewaybill.
    TRY.
        DATA(lo_api)    = NEW zune_cls_helper_einv_ewb( ).
        DATA: lv_result       TYPE string,
              lv_json         TYPE string,
              ls_response     TYPE zune_cls_helper_einv_ewb=>tt_response,
              ls_response_err TYPE zune_cls_helper_einv_ewb=>tt_main.

        DATA lv_success TYPE string.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Build JSON payload (example values, replace with entity data if needed)
          lv_json = lo_api->build_ewbirn_payload(
                       iv_docnum = CONV string( <ls_result>-billingdocnum )
                       iv_companycode = CONV string( <ls_result>-companycode )
                       iv_fisyear = CONV string( <ls_result>-fiscalyear )
                       iv_distance = condense( CONV string( <ls_result>-transportdistanceinkm  ) )
                       iv_irn = CONV string( <ls_result>-irnno )
                       iv_transdocdt = <ls_result>-transportdocumentdate
                       iv_transdocno = CONV string( <ls_result>-transportdocumentnumber )
                       iv_transid = CONV string( <ls_result>-transportergstinnumber )
                       iv_transmode = CONV string( <ls_result>-modeoftransport )
                       iv_transname = CONV string( <ls_result>-transportername )
                       iv_vehno = CONV string( <ls_result>-vehiclenumber )
                       iv_vehtype = CONV string( <ls_result>-vehicletype )
                       ).



          " Call API
          lv_result = lo_api->generate_ewbirn( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-billingdocnum ) ).



          FIND REGEX '"Success"\s*:\s*"([^"]+)"' IN lv_result SUBMATCHES lv_success.





          IF lv_success = 'Y'.

            " Parse response JSON into structure
            ls_response = lo_api->get_ewbirn_response( iv_json = lv_result ).
            DATA iv_transid TYPE string.

            READ TABLE ls_response INTO DATA(ls_result1) INDEX 1.
            IF sy-subrc = 0.

              " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
              DATA(lv_ewbdt) = ``.
              DATA(lv_ewbvalidtill) = ``.
              DATA(lv_errorresponse) = ``.

              IF ls_result1-govt_response-ackdt IS NOT INITIAL.
                lv_ewbdt = ls_result1-govt_response-ackdt+0(4) &&
                 ls_result1-govt_response-ackdt+5(2) &&
                 ls_result1-govt_response-ackdt+8(2).
              ENDIF.

              IF ls_result1-govt_response-ewbvalidtill IS NOT INITIAL.
                lv_ewbvalidtill = ls_result1-govt_response-ewbvalidtill+0(4) &&
                 ls_result1-govt_response-ewbvalidtill+5(2) &&
                 ls_result1-govt_response-ewbvalidtill+8(2).
              ENDIF.

              " Update entity fields
              MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
                ENTITY einvoice
                UPDATE FIELDS ( ewaybillno ewaybilldate ewaybillstatus ewaybillvalidto  resposnsejson postingjson )
                WITH VALUE #(
                  FOR ls_keys IN keys (
                    %tky                  = ls_keys-%tky

                    ewaybillno            = ls_result1-govt_response-ewbno
                    ewaybilldate          = lv_ewbdt
                    ewaybillstatus        = ls_result1-govt_response-status
                    ewaybillvalidto       = lv_ewbvalidtill
                    resposnsejson         = lv_result
                    postingjson           = lv_json

                  )
                )
                REPORTED DATA(lt_reported)
                FAILED   DATA(lt_failed).
              " Handle reported records
              reported = CORRESPONDING #( DEEP lt_reported ).
              " Success message
              APPEND VALUE #(
                %tky = keys[ 1 ]-%tky
                %msg = new_message_with_text(
                         text     = |E-Way Bill Generated: { ls_result1-govt_response-ackno }|
                         severity = if_abap_behv_message=>severity-success )
              ) TO reported-einvoice.
            ENDIF.
          ELSE.

            ls_response_err = lo_api->get_ewbirn_response_err( iv_json = lv_result ).


            READ TABLE ls_response_err INTO DATA(ls_result2) INDEX 1.
            IF sy-subrc = 0.

              LOOP AT ls_result2-govt_response-errordetails INTO DATA(ls_err).

                lv_errorresponse = |{ lv_errorresponse } Error { ls_err-error_code }: { ls_err-error_message }\n|.

              ENDLOOP.

              " Update entity fields
              MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
                ENTITY einvoice
                UPDATE FIELDS ( ewaybillstatus resposnsejson postingjson )
                WITH VALUE #(
                  FOR ls_keys IN keys (
                    %tky                  = ls_keys-%tky


                    ewaybillstatus        = 'Not Genrated'
                    resposnsejson         = lv_errorresponse
                    postingjson           = lv_json

                  )
                )
                REPORTED DATA(lt_reporteder)
                FAILED   DATA(lt_faileder).
              " Handle reported records
              reported = CORRESPONDING #( DEEP lt_reporteder ).
              " Success message
*              APPEND VALUE #(
*                %tky = keys[ 1 ]-%tky
*                %msg = new_message_with_text(
*                         text     = |E-Way Bill not Generated: { ls_result1-govt_response-ackno }|
*                         severity = if_abap_behv_message=>severity-error )
*              ) TO reported-einvoice.

            ENDIF.

            " Error messages from API
*            LOOP AT ls_response-govt_response-errordetails INTO DATA(ls_err).
*
*              lv_errorresponse = |{ lv_errorresponse } Error { ls_err-error_code }: { ls_err-error_message }\n|.
*
*
*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.
*            ENDLOOP.

            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
            ENTITY einvoice
            UPDATE FIELDS ( postingjson resposnsejson )
            WITH VALUE #(
              FOR ls_keys IN keys (
                %tky                  = ls_keys-%tky

                postingjson            = lv_json
                resposnsejson   = lv_errorresponse

              )
            )
            REPORTED DATA(lttt_reported)
            FAILED   DATA(lttt_failed).
            " Handle reported records
            "reported = CORRESPONDING #( DEEP lttt_reported ).


          ENDIF.



          " Check success
          " Check success

          " Read final state of entities for returning result
          READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
            ENTITY einvoice
            ALL FIELDS
            WITH CORRESPONDING #( keys )
            RESULT DATA(lt_result)
            REPORTED DATA(ltt_reported)
            FAILED   DATA(ltt_failed).

          result = VALUE #( FOR ls_result IN lt_result
                              ( %tky = ls_result-%tky
                              %param-%data = ls_result-%data
                              ) ).

        ENDLOOP.
      CATCH cx_root
                  INTO DATA(lx_err).

        " API technical error
        APPEND VALUE #(
          %tky = keys[ 1 ]-%tky
          %msg = new_message_with_text(
                   text     = lx_err->get_text( )
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-einvoice.
    ENDTRY.
  ENDMETHOD.

  METHOD cancelewaybill.

    DATA(lo_api)    = NEW zune_cls_helper_einv_ewb( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper_einv_ewb=>ty_ewaybill_cancel_response.

    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).
          lv_json = lo_api->build_ewaybill_payload_cancel( iv_cancelrmrk = CONV string( <ls_result>-ewaybillcancelremarks )
                                                          iv_cancelrsncode = CONV string( <ls_result>-ewaybillcanreasoncode )
                                                          iv_ewaybillno = CONV string( <ls_result>-ewaybillno )
                                                          iv_docnum = CONV string( <ls_result>-billingdocnum ) ).
          " Call API
          lv_result = lo_api->cancel_ewaybill( iv_json = lv_json iv_docnum = CONV string( <ls_result>-billingdocnum ) ).

          " Parse response JSON into structure
          ls_response = lo_api->get_eway_cancel_response( iv_json = lv_result ).
          " Check success


          " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
          DATA(lv_ewbdt) = ``.
          DATA(lv_ewbvalidtill) = ``.
          DATA(lv_errorresponse) = ``.
          IF ls_response-ewbstatus = 'CANCELLED'.

            " Update entity fields
            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
              ENTITY einvoice
              UPDATE FIELDS ( ewaybillcanceldate postingjson resposnsejson )
              WITH VALUE #(
                FOR ls_keys IN keys (
                  %tky                  = ls_keys-%tky
                    ewaybillcanceldate = cl_abap_context_info=>get_system_date( )
                    postingjson           = lv_json
                    resposnsejson  = ''
                )
              )
              REPORTED DATA(lt_reported)
              FAILED   DATA(lt_failed).
            " Handle reported records
            "  reported = CORRESPONDING #( DEEP lt_reported ).
            " Success message
            APPEND VALUE #(
              %tky = keys[ 1 ]-%tky
              %msg = new_message_with_text(
                      text     = |E-Way Bill Cancelled Successfully|
                       severity = if_abap_behv_message=>severity-success )
            ) TO reported-einvoice.
          ELSE.
            " Error messages from API


            lv_errorresponse = |{ lv_errorresponse } Error { ls_response-errordetails-error_code }: { ls_response-errordetails-error_message }\n|.


*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.



            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
           ENTITY einvoice
           UPDATE FIELDS ( postingjson resposnsejson )
           WITH VALUE #(
             FOR ls_keys IN keys (
               %tky                  = ls_keys-%tky

               postingjson            = lv_json
               resposnsejson   = lv_errorresponse

             )
           )
           REPORTED DATA(lttt_reported)
           FAILED   DATA(lttt_failed).
            " Handle reported records
            "reported = CORRESPONDING #( DEEP lttt_reported ).
          ENDIF.

        ENDLOOP.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt_result)
          REPORTED DATA(ltt_reported)
          FAILED   DATA(ltt_failed).

        result = VALUE #( FOR ls_result IN lt_result
                            ( %tky = ls_result-%tky
                            %param-%data = ls_result-%data
                            ) ).

      CATCH cx_web_http_client_error
            cx_web_message_error
            cx_http_dest_provider_error INTO DATA(lx_err).

        " API technical error
        APPEND VALUE #(
          %tky = keys[ 1 ]-%tky
          %msg = new_message_with_text(
                   text     = lx_err->get_text( )
                   severity = if_abap_behv_message=>severity-error )
        ) TO reported-einvoice.
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
