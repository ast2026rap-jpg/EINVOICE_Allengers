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
    METHODS generateewaypartb FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~generateewaypartb RESULT result.
    METHODS duplicateentry FOR VALIDATE ON SAVE
      IMPORTING keys FOR einvoice~duplicateentry.
    METHODS genaratepdf FOR MODIFY
      IMPORTING keys FOR ACTION einvoice~genaratepdf RESULT result.
    METHODS checkexportinvoice FOR VALIDATE ON SAVE
      IMPORTING keys FOR einvoice~checkexportinvoice.
    METHODS precheck_delete FOR PRECHECK
      IMPORTING keys FOR DELETE einvoice.
    METHODS checktransactiontype FOR VALIDATE ON SAVE
      IMPORTING keys FOR einvoice~checktransactiontype.

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
                        %features-%action-GenaratePdf = COND #( WHEN ls_result-Ewaybillno IS NOT INITIAL OR ls_result-%is_draft = '01'
                                                      THEN if_abap_behv=>fc-o-enabled
                                                      ELSE if_abap_behv=>fc-o-disabled )
                         %features-%field-ewaypdfattach = if_abap_behv=>fc-f-read_only

                          %field-Irncanceldate = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                         %field-Irngeneratedate = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                          %field-Irnno = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                         %field-Irnqr = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                          %field-Irnqrpartb = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                         %field-Acknowledgedate = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                         %field-Acknowledgeno = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                               %field-Irnstatus = COND #( WHEN          ls_result-Irnno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                                   %field-Ewaybillcanceldate = COND #( WHEN          ls_result-Ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                                %field-Ewaybilldate = COND #( WHEN          ls_result-Ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                               %field-Ewaybillno = COND #( WHEN          ls_result-Ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                                %field-Ewaybillstatus = COND #( WHEN          ls_result-Ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                              %field-Ewaybillvalidto = COND #( WHEN          ls_result-Ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
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
                       iv_suptyp = CONV string( <ls_result>-supplytype )
                       iv_contryCode = CONV string( <ls_result>-countryforexp )
                       iv_Portno = CONV string( <ls_result>-portno )
                       iv_transactionType = CONV string( <ls_result>-transactiontype )
                       ).

          " Call API
          lv_result = lo_api->generate_einvoie( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-billingdocnum ) ).
          " Parse response JSON into structure
          ls_response = lo_api->get_einvoice_response( iv_json = lv_result ).

          DATA: lv_json_trunc        TYPE string,
           lv_errorresp_trunc   TYPE string.
           lv_json_trunc = lv_json.
            IF strlen( lv_json_trunc ) > 8000.
              lv_json_trunc = lv_json_trunc+0(8000).
            ENDIF.

          " Check success
          IF ls_response-govt_response-success = 'Y'.

            " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
            DATA(lv_ackdt) = ``.
            DATA(lv_ewbvalidtill) = ``.
            DATA(lv_errorresponse) = ``.
            DATA(lv_qrpartA) = ``.
            DATA(lv_qrpartB) = ``.
            IF ls_response-govt_response-ackdt IS NOT INITIAL.
              lv_ackdt = ls_response-govt_response-ackdt+0(4) &&
               ls_response-govt_response-ackdt+5(2) &&
               ls_response-govt_response-ackdt+8(2).


            ENDIF.

             "------------------------------------------------------------
            " Split the signed QR code into Part A / Part B.
            " The government-signed QR string can exceed the field length
            " (1333 characters) that a single DB field can hold, so if it
            " does, the first 1333 characters go into Part A and whatever
            " remains goes into Part B. If it's within the limit, the
            " whole value goes into Part A and Part B stays blank.
            "------------------------------------------------------------

            Data(lv_qrlength) = numofchar( ls_response-govt_response-signedqrcode ).
          "  DATA(lv_qrlength) = charlen( 'eyJ4NXQiOiJhZ' ).

            IF lv_qrlength > 1333.
              lv_qrpartA = ls_response-govt_response-signedqrcode+0(1333).
              lv_qrpartB = ls_response-govt_response-signedqrcode+1333.
            ELSE.
              lv_qrpartA = ls_response-govt_response-signedqrcode.
              lv_qrpartB = ``.
            ENDIF.

            " Update entity fields
            MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
              ENTITY einvoice
              UPDATE FIELDS ( acknowledgeno acknowledgedate irnno irngeneratedate irnqr Irnqrpartb irnstatus  postingjson resposnsejson )
              WITH VALUE #(
                FOR ls_keys IN keys (
                  %tky                  = ls_keys-%tky

                  acknowledgeno            = ls_response-govt_response-ackno
                  acknowledgedate          = lv_ackdt
                  irnno = ls_response-govt_response-irn
                  irngeneratedate  = lv_ackdt
                  irnqr           = lv_qrpartA
                  Irnqrpartb = lv_qrpartB
                  irnstatus = ls_response-govt_response-status
                  postingjson = lv_json_trunc
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

               lv_errorresp_trunc = lv_errorresponse.
                IF strlen( lv_errorresp_trunc ) > 1333.
                  lv_errorresp_trunc = lv_errorresp_trunc+0(1333).
                ENDIF.


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

               postingjson            = lv_json_trunc
               resposnsejson   = lv_errorresp_trunc

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
    try.
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
   CATCH cx_root
                  INTO DATA(lx_err).
                  data(a) = ''.
        endTRY.

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
                       iv_transactiontype = CONV string( <ls_result>-transactiontype )
                       iv_irn = CONV string( <ls_result>-irnno )
                       iv_transdocdt = <ls_result>-transportdocumentdate
                       iv_transdocno = CONV string( <ls_result>-transportdocumentnumber )
                       iv_transid = CONV string( <ls_result>-transportergstinnumber )
                       iv_transmode = CONV string( <ls_result>-modeoftransport )
                       iv_transname = CONV string( <ls_result>-transportername )
                       iv_vehno = CONV string( <ls_result>-vehiclenumber )
                       iv_vehtype = CONV string( <ls_result>-vehicletype )
                       iv_supplyType = CONV string( <ls_result>-supplytype )
                       iv_port = CONV string( <ls_result>-portno )
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
              data : lv_distance type string.
              IF line_exists( ls_result1-govt_response-info[ 1 ] ).

              lv_distance = ls_result1-govt_response-info[ 1 ]-desc.
              REPLACE FIRST OCCURRENCE OF 'Pin-Pin calc distance: '
    IN lv_distance
    WITH ''.
        REPLACE FIRST OCCURRENCE OF 'KM'
    IN lv_distance
    WITH ''.
    else.
    lv_distance = <ls_result>-Transportdistanceinkm.

    endif.
              " Update entity fields
              MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
                ENTITY einvoice
                UPDATE FIELDS ( ewaybillno ewaybilldate ewaybillstatus ewaybillvalidto  resposnsejson postingjson Transportdistanceinkm )
                WITH VALUE #(
                  FOR ls_keys IN keys (
                    %tky                  = ls_keys-%tky

                    ewaybillno            = ls_result1-govt_response-ewbno
                    ewaybilldate          = lv_ewbdt
                    ewaybillstatus        = ls_result1-govt_response-status
                    ewaybillvalidto       = lv_ewbvalidtill
                    resposnsejson         = lv_result
                    postingjson           = lv_json
                    Transportdistanceinkm = lv_distance

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

  METHOD GenerateEwayPartB.

  DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper=>ty_ewaybill_partb_response.

    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY Einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Build JSON payload (example values, replace with entity data if needed)
          lv_json = lo_api->build_ewaybill_payload_partb(
                       iv_docnum = CONV string( <ls_result>-Billingdocnum )
                       iv_ewaybillnum = CONV string( <ls_result>-ewaybillno )
                       iv_fromplace = CONV string( <ls_result>-place )
                       iv_fromstate = CONV string( <ls_result>-stategstcode )
                       iv_reasoncode = CONV string( <ls_result>-updatereason )
                       iv_reasonremark = CONV string( <ls_result>-updateremark )
                       iv_transdocno = CONV string( <ls_result>-transportdocumentnumber )
                       iv_transdocdt  = CONV string( <ls_result>-transportdocumentdate )
                       iv_transmode = CONV int4( <ls_result>-modeoftransport )
                       iv_distance  =  <ls_result>-transportdistanceinkm
                       iv_vehno    = CONV string( <ls_result>-vehiclenumber )
                       iv_vehtype  = CONV string( <ls_result>-vehicletype )
                       iv_refrenceno  = CONV string( <ls_result>-refrenceno ) ) .
        ENDLOOP.
        " Call API
        lv_result = lo_api->generate_ewaybill_partb( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-Billingdocnum ) ).

        " Parse response JSON into structure
        ls_response = lo_api->get_eway_partb_response( iv_json = lv_result ).

        " Check success
        IF ls_response-errors IS INITIAL.

          " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
          DATA(lv_updatedate) = ``.
          DATA(lv_ewbvalidtill) = ``.
          DATA(lv_errorresponse) = ``.
          IF ls_response-updateddate IS NOT INITIAL.
            " Extract DD/MM/YYYY part safely
            DATA(lv_datepart) = ls_response-updateddate(10).          " '19/11/2025'
            lv_updatedate =  lv_datepart+6(4) &&    " YYYY
                              lv_datepart+3(2) &&   " MM
                              lv_datepart+0(2).   " DD
          ENDIF.

          IF ls_response-validupto IS NOT INITIAL.
            " Extract DD/MM/YYYY part safely
            DATA(lv_datepartvalid) = ls_response-validupto(10).          " '19/11/2025'
            lv_ewbvalidtill = lv_datepartvalid+6(4) &&    " YYYY
                              lv_datepartvalid+3(2) &&   " MM
                              lv_datepartvalid+0(2).   " DD


          ENDIF.




          " Update entity fie
          MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
            ENTITY Einvoice
            UPDATE FIELDS ( upadtedate ewaybillexirationdate resposnsejson postingjson )
            WITH VALUE #(
              FOR ls_keys IN keys (
                %tky                  = ls_keys-%tky

                upadtedate          = lv_updatedate
                ewaybillexirationdate = lv_ewbvalidtill
                resposnsejson  = ''
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
                     text     = |E-Way Bill Part B Generated: { ls_response-ewbnumber }|
                     severity = if_abap_behv_message=>severity-success )
          ) TO reported-einvoice.

        ELSE.
          " Error messages from API
          LOOP AT ls_response-errors INTO DATA(ls_err).

            lv_errorresponse = |{ lv_errorresponse } Error { ls_err-error_code }: { ls_err-error_message }\n|.


*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.
          ENDLOOP.


          MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
         ENTITY Einvoice
         UPDATE FIELDS ( Postingjson Resposnsejson )
         WITH VALUE #(
           FOR ls_keys IN keys (
             %tky                  = ls_keys-%tky

             Postingjson            = lv_json
             Resposnsejson   = lv_errorresponse

           )
         )
         REPORTED DATA(lttt_reported)
         FAILED   DATA(lttt_failed).
          " Handle reported records
          "reported = CORRESPONDING #( DEEP lttt_reported ).
        ENDIF.

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

  METHOD DuplicateEntry.

" 1. Read buffer data for Billingdocnum
  READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
    ENTITY Einvoice
      FIELDS ( Billingdocnum )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(ltt_failed)
    REPORTED DATA(ltt_reported).

  IF lt_result IS INITIAL.
    RETURN.
  ENDIF.

  " 2. Check database for existing duplicates
  SELECT billingdocnum
    FROM zune_dt_einv_h  " <-- Replace with your actual database table
    FOR ALL ENTRIES IN @lt_result
    WHERE billingdocnum = @lt_result-Billingdocnum
    INTO TABLE @DATA(lt_existing_docs).

  " 3. Validate each record being saved
  LOOP AT lt_result INTO DATA(ls_einvoice).
     APPEND VALUE #(
      %tky        = ls_einvoice-%tky
      %state_area = 'VALIDATE_BILLING_DOC'
    ) TO reported-einvoice.
    IF ls_einvoice-Billingdocnum IS INITIAL.
      CONTINUE.
    ENDIF.

    " If the billing document already exists in DB
    IF line_exists( lt_existing_docs[ Billingdocnum = ls_einvoice-Billingdocnum ] ).

      " Block the save operation
      APPEND VALUE #( %tky = ls_einvoice-%tky ) TO failed-einvoice.

      " Display error message highlighted on the Billingdocnum field in Fiori
      APPEND VALUE #(
        %tky        = ls_einvoice-%tky
        %state_area = 'VALIDATE_BILLING_DOC'
        %msg        = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Billing Document { ls_einvoice-Billingdocnum } already exists.|
                      )
        %element-Billingdocnum = if_abap_behv=>mk-on
      ) TO reported-einvoice.

    ENDIF.

  ENDLOOP.

  ENDMETHOD.

  METHOD GenaratePdf.
    DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA lv_result TYPE string.
    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
          ENTITY Einvoice
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Call API
          lv_result = lo_api->generate_eway_pdf( ewabillno = CONV string( <ls_result>-ewaybillno )  iv_docnum = CONV string( <ls_result>-Billingdocnum ) ).
          MODIFY ENTITIES OF zune_rv_einv_h IN LOCAL MODE
      ENTITY Einvoice
      UPDATE FIELDS ( filename mimetype ewaypdfattach )
      WITH VALUE #(
        FOR ls_keys IN keys (
          %tky                  = ls_keys-%tky

          filename   = <ls_result>-ewaybillno
          mimetype   = 'application/pdf'
          ewaypdfattach = lv_result

        )
      )
      REPORTED DATA(lttt_reported)
      FAILED   DATA(lttt_failed).

        ENDLOOP.

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

  METHOD CheckExportInvoice.

" 1. Read buffer data for Billingdocnum
  READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
    ENTITY Einvoice
      FIELDS ( supplytype countryforexp Billingdocnum portno )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(ltt_failed)
    REPORTED DATA(ltt_reported).

  IF lt_result IS INITIAL.
    RETURN.
  ENDIF.
LOOP AT lt_result into data(ls_result).
  DATA:lv_docno TYPE string.
    lv_docno = ls_result-Billingdocnum.

    DATA(lv_len) = strlen( lv_docno ).
    IF lv_len < 10.
      DATA(lv_missing) = 10 - lv_len.
      lv_docno = |{ repeat( val = '0' occ = lv_missing ) }{ lv_docno }|.
    ENDIF.

  SELECT SINGLE
       b~addressid,d~YY1_BPFullName_bus as lglname,e~BPTaxNumber as ShipGST
      " f~text AS statecode,e~AddresseeFullName AS lglname,e~StreetName AS addr1, e~cityname AS location,e~postalcode AS pin

       FROM  i_billingdocumentitem WITH PRIVILEGED ACCESS AS a
      LEFT OUTER JOIN I_BillingDocumentPartner WITH PRIVILEGED ACCESS AS b ON a~BillingDocument = b~BillingDocument
      LEFT OUTER JOIN I_BusinessPartner WITH PRIVILEGED ACCESS AS d ON b~customer = d~BusinessPartner
       LEFT OUTER JOIN i_buspartaddrdepdnttaxnmbr WITH PRIVILEGED ACCESS AS e
    ON  d~BusinessPartner  = e~businesspartner
    AND b~addressid = e~businesspartneraddressid
      WHERE a~billingdocument = @lv_docno  AND b~partnerfunction = 'WE'
      INTO  @DATA(addressid).


     Select
      f~text AS statecode,a~AddresseeFullName AS lglname,concat_with_space( concat_with_space( concat_with_space( concat_with_space( concat_with_space(
      concat_with_space( concat_with_space( a~StreetName,StreetPrefixName1,1 ),StreetPrefixName2,1 ),StreetSuffixName1,1 ),StreetSuffixName2,1 ),HouseNumber,1 ) ,Building, 1 ),RoomNumber,1 )  AS addr1, a~cityname AS location,a~postalcode AS pin
      ,a~Country
      from I_OrganizationAddress WITH PRIVILEGED ACCESS as a
    left outer join zune_cds_stategst WITH PRIVILEGED ACCESS AS f ON f~value_low = a~region

    Where a~AddressID = @addressid-AddressID into @DATA(expshippingadd).
  endSELECT.

   APPEND VALUE #(
      %tky        = ls_result-%tky
      %state_area = 'VALIDATE_Export_DOC'
    ) TO reported-einvoice.
    IF ls_result-Billingdocnum IS INITIAL.
      CONTINUE.
    ENDIF.

    IF expshippingadd-Country <> 'IN' and ( ls_result-countryforexp is INITIAL or ls_result-supplytype is INITIAL or ls_result-portno is INITIAL ).

      " Block the save operation
      APPEND VALUE #( %tky = ls_result-%tky ) TO failed-einvoice.

      " Display error message highlighted on the Billingdocnum field in Fiori
      APPEND VALUE #(
        %tky        = ls_result-%tky
        %state_area = 'VALIDATE_Export_DOC'
        %msg        = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Supply type,country-{ expshippingadd-Country } and Port for Export|
                      )
        %element-Billingdocnum = if_abap_behv=>mk-on
      ) TO reported-einvoice.

    ENDIF.
endloop.


  ENDMETHOD.

  METHOD precheck_delete.
  READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
     ENTITY Einvoice
    ALL FIELDS
     WITH CORRESPONDING #( keys )
     RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data).

 if ls_data-Irnno is not iniTIAL.

        APPEND VALUE #(
          %tky = ls_data-%tky
        ) TO failed-einvoice.

        APPEND VALUE #(
          %tky = ls_data-%tky
          %msg = new_message(
            id       = 'ZMSG'
            number   = '001'
            v1       = 'Deletion not allowed'
            severity = if_abap_behv_message=>severity-error )
        ) TO reported-einvoice.
endIF.


    ENDLOOP.
  ENDMETHOD.

  METHOD CheckTransactionType.
  " 1. Read buffer data for Billingdocnum
  READ ENTITIES OF zune_rv_einv_h IN LOCAL MODE
    ENTITY Einvoice
      FIELDS ( transactiontype )
      WITH CORRESPONDING #( keys )
    RESULT DATA(lt_result)
    FAILED DATA(ltt_failed)
    REPORTED DATA(ltt_reported).


LOOP AT lt_result into data(ls_result).


     APPEND VALUE #(
      %tky        = ls_result-%tky
      %state_area = 'VALIDATE_Transaction_type'
    ) TO reported-einvoice.
    IF ls_result-transactiontype is INITIAL.

      " Block the save operation
      APPEND VALUE #( %tky = ls_result-%tky ) TO failed-einvoice.

      APPEND VALUE #(
        %tky        = ls_result-%tky
        %state_area = 'VALIDATE_Transaction_type'
        %msg        = new_message_with_text(
                        severity = if_abap_behv_message=>severity-error
                        text     = |Transaction Type is required|
                      )
        %element-transactiontype = if_abap_behv=>mk-on
      ) TO reported-einvoice.

    ENDIF.

ENDLOOP.
  ENDMETHOD.

ENDCLASS.
