CLASS lhc_ewaybill DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ewaybill RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ewaybill RESULT result.
    METHODS generateeway FOR MODIFY
      IMPORTING keys FOR ACTION ewaybill~generateeway RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR ewaybill RESULT result.
    METHODS onselectbilling FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ewaybill~onselectbilling.
    METHODS canceleway FOR MODIFY
      IMPORTING keys FOR ACTION ewaybill~canceleway RESULT result.
    METHODS genaratepdf FOR MODIFY
      IMPORTING keys FOR ACTION ewaybill~genaratepdf RESULT result.
    METHODS generateewaypartb FOR MODIFY
      IMPORTING keys FOR ACTION ewaybill~generateewaypartb RESULT result.

ENDCLASS.

CLASS lhc_ewaybill IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD generateeway.

    DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper=>ty_response.

    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Build JSON payload (example values, replace with entity data if needed)
          lv_json = lo_api->build_ewaybill_payload(
                       iv_docnum = CONV string( <ls_result>-documentno )
                       iv_documenttype = CONV string( <ls_result>-documenttype )
            iv_supplytype    = CONV string( <ls_result>-supplytype )
        iv_subsupplytype  = CONV string( <ls_result>-subtype )
        iv_subsupplytypedesc = CONV string( <ls_result>-subsupplytypedesc )
       iv_transactiontype = CONV string( <ls_result>-transactiontype )
        iv_transid  = CONV string( <ls_result>-transporterid )
         iv_transname = CONV string( <ls_result>-transportername )
         iv_transmode = CONV int4( <ls_result>-trmode )
         iv_distance  =  <ls_result>-distance
         iv_transdocno = CONV string( <ls_result>-transporterdocno )
         iv_transdocdt  = CONV string( <ls_result>-transporterdocdate )
         iv_vehno    = CONV string( <ls_result>-vehicleno )
        iv_vehtype  = CONV string( <ls_result>-vehicletype )
        iv_refrenceno  = CONV string( <ls_result>-refrenceno ) ) .
        ENDLOOP.
        " Call API
        lv_result = lo_api->generate_ewaybill( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-documentno ) ).

        " Parse response JSON into structure
        ls_response = lo_api->get_eway_response( iv_json = lv_result ).

        " Check success
        IF ls_response-govt_response-success = 'Y'.

          " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
          DATA(lv_ewbdt) = ``.
          DATA(lv_ewbvalidtill) = ``.
          DATA(lv_errorresponse) = ``.
          IF ls_response-govt_response-ewbdt IS NOT INITIAL.
            lv_ewbdt = ls_response-govt_response-ewbdt+0(4) &&
             ls_response-govt_response-ewbdt+5(2) &&
             ls_response-govt_response-ewbdt+8(2).
          ENDIF.

          IF ls_response-govt_response-ewbvalidtill IS NOT INITIAL.
            lv_ewbvalidtill = ls_response-govt_response-ewbvalidtill+0(4) &&
             ls_response-govt_response-ewbvalidtill+5(2) &&
             ls_response-govt_response-ewbvalidtill+8(2).

          ENDIF.




          " Update entity fields
          MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
            ENTITY ewaybill
            UPDATE FIELDS ( ewaybillno ewaybilldate ewaybillexirationdate postingerrorresponse postingbody )
            WITH VALUE #(
              FOR ls_keys IN keys (
                %tky                  = ls_keys-%tky

                ewaybillno            = ls_response-govt_response-ewbno
                ewaybilldate          = lv_ewbdt
                ewaybillexirationdate = lv_ewbvalidtill
                postingerrorresponse  = ''
                postingbody           = lv_json

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
                     text     = |E-Way Bill Generated: { ls_response-govt_response-ewbno }|
                     severity = if_abap_behv_message=>severity-success )
          ) TO reported-ewaybill.

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


          MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
         ENTITY ewaybill
         UPDATE FIELDS ( postingbody postingerrorresponse )
         WITH VALUE #(
           FOR ls_keys IN keys (
             %tky                  = ls_keys-%tky

             postingbody            = lv_json
             postingerrorresponse   = lv_errorresponse

           )
         )
         REPORTED DATA(lttt_reported)
         FAILED   DATA(lttt_failed).
          " Handle reported records
          "reported = CORRESPONDING #( DEEP lttt_reported ).
        ENDIF.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
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
        ) TO reported-ewaybill.
    ENDTRY.

  ENDMETHOD.



  METHOD get_instance_features.
    " Read final state of entities for returning result
    READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
      ENTITY ewaybill
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
                        %features-%action-generateeway = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL OR ls_result-%is_draft = '01'
                                                       THEN if_abap_behv=>fc-o-disabled
                                                       ELSE if_abap_behv=>fc-o-enabled )
                        %features-%field-cancellationresion = COND #( WHEN ls_result-ewaycancellationdate IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                        %features-%field-cancelremark = COND #( WHEN ls_result-ewaycancellationdate IS NOT INITIAL
                                                       THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-comapnycode = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                        THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-distance = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                          %features-%field-documentno = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-refrenceno = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-documenttype = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                     THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-ewaybilldate = if_abap_behv=>fc-f-read_only
                         %features-%field-ewaybillexirationdate = if_abap_behv=>fc-f-read_only
                          %features-%field-ewaybillno = if_abap_behv=>fc-f-read_only
                         %features-%field-ewaycancellationdate = if_abap_behv=>fc-f-read_only
                         %features-%field-fiscalyera = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                    THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-place = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                     THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                          %features-%field-postingbody = if_abap_behv=>fc-f-read_only
                         %features-%field-postingerrorresponse = if_abap_behv=>fc-f-read_only
*
*                         %features-%field-stategstcode = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                      THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-subsupplytypedesc = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                          %features-%field-subtype = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-supplytype = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                          %features-%field-transactiontype = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                       THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-transporterdocdate = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                      THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                          %features-%field-transportercode = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-transporterdocno = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                     THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                           %features-%field-transporterid = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                      THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-transportername = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                       THEN if_abap_behv=>fc-f-read_only
                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                          %features-%field-trmode = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                      THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-upadtedate = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                     THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-updatereason = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                    THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-updateremark = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                       THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                          %features-%field-vehicleno = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                    THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
*                         %features-%field-vehicletype = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
*                                                       THEN if_abap_behv=>fc-f-read_only
*                                                       ELSE if_abap_behv=>fc-f-unrestricted )
                         %features-%field-zipcode = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL
                                                 THEN if_abap_behv=>fc-f-read_only
                                                      ELSE if_abap_behv=>fc-f-unrestricted )
                        %features-%field-ewaypdfattach = if_abap_behv=>fc-f-read_only

                        %features-%action-canceleway = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL AND ls_result-ewaycancellationdate IS INITIAL
                                                       THEN if_abap_behv=>fc-o-enabled
                                                       ELSE if_abap_behv=>fc-o-disabled )
                       %features-%action-generateewaypartb = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL AND ls_result-ewaycancellationdate IS INITIAL AND ls_result-upadtedate IS INITIAL
                                                       THEN if_abap_behv=>fc-o-enabled
                                                       ELSE if_abap_behv=>fc-o-disabled )
                        %features-%action-genaratepdf = COND #( WHEN ls_result-ewaybillno IS NOT INITIAL OR ls_result-%is_draft = '00'
                                                       THEN if_abap_behv=>fc-o-enabled
                                                       ELSE if_abap_behv=>fc-o-disabled )
                        ) ).
  ENDMETHOD.

  METHOD onselectbilling.

    " Read final state of entities for returning result
    READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
      ENTITY ewaybill
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt1_result)
      REPORTED DATA(ltt1_reported)
      FAILED   DATA(ltt1_failed).

    LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

      " Document number dynamic leading zero padding to 10 chars
      DATA:lv_docno TYPE string.
      lv_docno = <ls_result>-documentno.

      DATA(lv_len) = strlen( lv_docno ).
      IF lv_len < 10.
        DATA(lv_missing) = 10 - lv_len.
        lv_docno = |{ repeat( val = '0' occ = lv_missing ) }{ lv_docno }|.
      ENDIF.

      " Use padded value for DB select
      SELECT SINGLE billingdocumenttype
        FROM i_billingdocument WITH PRIVILEGED ACCESS
        WHERE billingdocument = @lv_docno
        INTO @DATA(lv_billingdoctype).

      DATA: lv_supplytype    TYPE string,
            lv_subsupplytype TYPE string,
            lv_documenttype  TYPE string.

      IF lv_billingdoctype = 'F8' OR lv_billingdoctype = 'JSTO'.
        lv_supplytype   = 'OUTWARD'.
        lv_documenttype = 'CHL'.
      ENDIF.

      " Update entity fields
      MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
        ENTITY ewaybill
        UPDATE FIELDS ( supplytype documenttype refrenceno )
        WITH VALUE #(
          FOR ls_keys IN keys (
            %tky         = ls_keys-%tky
            supplytype   = lv_supplytype
            documenttype = lv_documenttype
            refrenceno   = <ls_result>-documentno
          )
        )
        REPORTED DATA(lt_reported)
        FAILED   DATA(lt_failed).

    ENDLOOP.

  ENDMETHOD.

  METHOD canceleway.
    DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper=>ty_ewaybill_cancel_response.

    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).
          lv_json = lo_api->build_ewaybill_payload_cancel( iv_cancelrmrk = CONV string( <ls_result>-cancelremark )
                                                          iv_cancelrsncode = CONV string( <ls_result>-cancellationresion )
                                                          iv_ewaybillno = CONV string( <ls_result>-ewaybillno )
                                                          iv_docnum = CONV string( <ls_result>-documentno ) ).
          " Call API
          lv_result = lo_api->cancel_ewaybill( iv_json = lv_json iv_docnum = CONV string( <ls_result>-documentno ) ).

          " Parse response JSON into structure
          ls_response = lo_api->get_eway_cancel_response( iv_json = lv_result ).
          " Check success


          " Convert API timestamps (YYYY-MM-DD HH:MM:SS → YYYYMMDD)
          DATA(lv_ewbdt) = ``.
          DATA(lv_ewbvalidtill) = ``.
          DATA(lv_errorresponse) = ``.
          IF ls_response-ewbstatus = 'CANCELLED'.

            " Update entity fields
            MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
              ENTITY ewaybill
              UPDATE FIELDS ( ewaycancellationdate postingbody postingerrorresponse )
              WITH VALUE #(
                FOR ls_keys IN keys (
                  %tky                  = ls_keys-%tky
                    ewaycancellationdate = cl_abap_context_info=>get_system_date( )
                    postingbody           = lv_json
                    postingerrorresponse  = ''
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
            ) TO reported-ewaybill.
          ELSE.
            " Error messages from API


            lv_errorresponse = |{ lv_errorresponse } Error { ls_response-errordetails-error_code }: { ls_response-errordetails-error_message }\n|.


*          APPEND VALUE #(
*            %tky = keys[ 1 ]-%tky
*            %msg = new_message_with_text(
*                     text     = |Error in E-Way generation|
*                     severity = if_abap_behv_message=>severity-error )
*          ) TO reported-ewaybill.



            MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
           ENTITY ewaybill
           UPDATE FIELDS ( postingbody postingerrorresponse )
           WITH VALUE #(
             FOR ls_keys IN keys (
               %tky                  = ls_keys-%tky

               postingbody            = lv_json
               postingerrorresponse   = lv_errorresponse

             )
           )
           REPORTED DATA(lttt_reported)
           FAILED   DATA(lttt_failed).
            " Handle reported records
            "reported = CORRESPONDING #( DEEP lttt_reported ).
          ENDIF.

        ENDLOOP.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
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
        ) TO reported-ewaybill.
    ENDTRY.

  ENDMETHOD.

  METHOD genaratepdf.

    DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA lv_result TYPE string.
    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Call API
          lv_result = lo_api->generate_eway_pdf( ewabillno = CONV string( <ls_result>-ewaybillno )  iv_docnum = CONV string( <ls_result>-documentno ) ).
          MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
      ENTITY ewaybill
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
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
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
        ) TO reported-ewaybill.
    ENDTRY.



  ENDMETHOD.

  METHOD generateewaypartb.


    DATA(lo_api)    = NEW zune_cls_helper( ).
    DATA: lv_result   TYPE string,
          lv_json     TYPE string,
          ls_response TYPE zune_cls_helper=>ty_ewaybill_partb_response.

    TRY.
        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
          ALL FIELDS
          WITH CORRESPONDING #( keys )
          RESULT DATA(lt1_result)
          REPORTED DATA(ltt1_reported)
          FAILED   DATA(ltt1_failed).
        LOOP AT lt1_result ASSIGNING FIELD-SYMBOL(<ls_result>).

          " Build JSON payload (example values, replace with entity data if needed)
          lv_json = lo_api->build_ewaybill_payload_partb(
                       iv_docnum = CONV string( <ls_result>-documentno )
                       iv_ewaybillnum = CONV string( <ls_result>-ewaybillno )
                       iv_fromplace = CONV string( <ls_result>-place )
                       iv_fromstate = CONV string( <ls_result>-stategstcode )
                       iv_reasoncode = CONV string( <ls_result>-updatereason )
                       iv_reasonremark = CONV string( <ls_result>-updateremark )
                       iv_transdocno = CONV string( <ls_result>-transporterdocno )
                       iv_transdocdt  = CONV string( <ls_result>-transporterdocdate )
                       iv_transmode = CONV int4( <ls_result>-trmode )
                       iv_distance  =  <ls_result>-distance
                       iv_vehno    = CONV string( <ls_result>-vehicleno )
                       iv_vehtype  = CONV string( <ls_result>-vehicletype )
                       iv_refrenceno  = CONV string( <ls_result>-refrenceno ) ) .
        ENDLOOP.
        " Call API
        lv_result = lo_api->generate_ewaybill_partb( iv_json = lv_json  iv_docnum = CONV string( <ls_result>-documentno ) ).

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




          " Update entity fields
          MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
            ENTITY ewaybill
            UPDATE FIELDS ( upadtedate ewaybillexirationdate postingerrorresponse postingbody )
            WITH VALUE #(
              FOR ls_keys IN keys (
                %tky                  = ls_keys-%tky

                upadtedate          = lv_updatedate
                ewaybillexirationdate = lv_ewbvalidtill
                postingerrorresponse  = ''
                postingbody           = lv_json

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
          ) TO reported-ewaybill.

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


          MODIFY ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
         ENTITY ewaybill
         UPDATE FIELDS ( postingbody postingerrorresponse )
         WITH VALUE #(
           FOR ls_keys IN keys (
             %tky                  = ls_keys-%tky

             postingbody            = lv_json
             postingerrorresponse   = lv_errorresponse

           )
         )
         REPORTED DATA(lttt_reported)
         FAILED   DATA(lttt_failed).
          " Handle reported records
          "reported = CORRESPONDING #( DEEP lttt_reported ).
        ENDIF.

        " Read final state of entities for returning result
        READ ENTITIES OF zune_rv_ewaybill IN LOCAL MODE
          ENTITY ewaybill
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
        ) TO reported-ewaybill.
    ENDTRY.


  ENDMETHOD.

ENDCLASS.
