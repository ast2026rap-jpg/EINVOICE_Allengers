CLASS zune_cls_helper_einv_ewb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

 "----------------------------------------------------------------------
" Info Node
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_info,
         infcd TYPE string,
         desc  TYPE string,
       END OF ty_info.

TYPES tt_info TYPE STANDARD TABLE OF ty_info WITH EMPTY KEY.


    "----------------------------------------------------------------------
" Govt Response Node
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_govt_response,
         success      TYPE string,
         ackno        TYPE string,
         ackdt        TYPE string,
         irn          TYPE string,
         status       TYPE string,
         ewbno        TYPE string,
         ewbdt        TYPE string,
         ewbvalidtill TYPE string,
         info         TYPE tt_info,
       END OF ty_govt_response.



       " ExpShipDtls Node
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_exp_shipdtls,
         addr1 TYPE string,
         addr2 TYPE string,
         loc   TYPE string,
         pin   TYPE i,
         stcd  TYPE string,
         gstin Type string,
       END OF ty_exp_shipdtls.

"----------------------------------------------------------------------
" DispDtls Node
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_dispdtls,
         nm    TYPE string,
         addr1 TYPE string,
         addr2 TYPE string,
         loc   TYPE string,
         pin   TYPE i,
         stcd  TYPE string,
       END OF ty_dispdtls.

"----------------------------------------------------------------------


   "----------------------------------------------------------------------
" Main Response Structure
"----------------------------------------------------------------------
TYPES: BEGIN OF ty_response,
         transid       TYPE string,
         transname     TYPE string,
         transmode     TYPE string,
         distance      TYPE i,
         transdocno    TYPE string,
         transdocdt    TYPE string,
         vehno         TYPE string,
         irn           TYPE string,
         expshipdtls   TYPE ty_exp_shipdtls,
         dispdtls      TYPE ty_dispdtls,
         govt_response TYPE ty_govt_response,
         ewb_status    TYPE string,
       END OF ty_response.

TYPES tt_response TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY.

    "--------------------------------------------------------
    " METHODS

    " Build payload JSON for e-waybill generation
    METHODS build_ewbirn_payload
      IMPORTING
        iv_docnum      TYPE string
        iv_fisyear     TYPE string
        iv_companycode TYPE string
        iv_irn         TYPE string
        iv_distance    TYPE string
        iv_transactiontype TYPE string
        iv_transmode   TYPE string
        iv_transid     TYPE string
        iv_transname   TYPE string
        iv_transdocdt  TYPE datn
        iv_transdocno  TYPE string
        iv_vehno       TYPE string
        iv_vehtype     TYPE string
        iv_supplyType   Type string
        iv_port         TYPE string
      RETURNING
        VALUE(rv_json) TYPE string.

    "--------------------------------------------------------


   " ABAP Structure In Case of Error Response

    TYPES: BEGIN OF ty_error_details,
         error_code    TYPE string,
         error_message TYPE string,
         error_source  TYPE string,
       END OF ty_error_details.

TYPES: tt_error_details TYPE STANDARD TABLE OF ty_error_details WITH EMPTY KEY.

TYPES: BEGIN OF ty_govt_response_err,
         Success       TYPE string,
         Irn           TYPE string,
         ErrorDetails  TYPE tt_error_details,
       END OF ty_govt_response_err.

TYPES: BEGIN OF ty_expshipdtls_err,
         Addr1 TYPE string,
         Addr2 TYPE string,
         Loc   TYPE string,
         Pin   TYPE string,
         Stcd  TYPE string,
       END OF ty_expshipdtls_err.

TYPES: BEGIN OF ty_dispdtls_err,
         Nm    TYPE string,
         Addr1 TYPE string,
         Addr2 TYPE string,
         Loc   TYPE string,
         Pin   TYPE string,
         Stcd  TYPE string,
       END OF ty_dispdtls_err.

TYPES: BEGIN OF ty_main,
         TransId     TYPE string,
         TransName   TYPE string,
         TransMode   TYPE string,
         Distance    TYPE string,
         TransDocNo  TYPE string,
         TransDocDt  TYPE string,
         VehNo       TYPE string,
         Irn         TYPE string,
         ExpShipDtls TYPE ty_expshipdtls_err,
         DispDtls    TYPE ty_dispdtls_err,
         govt_response TYPE ty_govt_response_err,
       END OF ty_main.

TYPES: tt_main TYPE STANDARD TABLE OF ty_main WITH EMPTY KEY.

"--------------------------------------------------------
    " Cancel E-Waybill Response Structure
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_can_error_details,
             error_code    TYPE string,
             error_message TYPE string,
             error_source  TYPE string,
           END OF ty_can_error_details.

    TYPES: BEGIN OF ty_ewaybill_cancel_response,
             ownerid      TYPE string,
             gstin        TYPE string,
             irn          TYPE string,
             ewbnumber    TYPE int8,
             ewbstatus    TYPE string,
             errordetails TYPE ty_error_details,  "nested structure
           END OF ty_ewaybill_cancel_response.


    " Call API to generate e-Invoice
    METHODS generate_ewbirn
      IMPORTING
        iv_json            TYPE string
        iv_docnum          TYPE string
      RETURNING
        VALUE(rv_response) TYPE string
      RAISING
        cx_web_http_client_error
        cx_web_message_error
        cx_http_dest_provider_error.

    " Fetch e-invoice config (Base URL, Token, GSTIN) based on document number
    METHODS get_einv_config
      IMPORTING
        iv_docnum    TYPE string
      EXPORTING
        ev_baseurl   TYPE string
        ev_authtoken TYPE string
        ev_gstin     TYPE string.

    " Parse govt response JSON into ABAP structure
    METHODS get_ewbirn_response
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE tt_response.

        " Parse govt response error JSON into ABAP structure
    METHODS get_ewbirn_response_err
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE tt_main.

    " Call API to cancel e-Invoice
    METHODS cancel_ewbirn
      IMPORTING
        iv_json            TYPE string
        iv_docnum          TYPE string
      RETURNING
        VALUE(rv_response) TYPE string
      RAISING
        cx_web_http_client_error
        cx_web_message_error
        cx_http_dest_provider_error.

    " Build payload JSON for e-waybill cancellation
    METHODS build_ewbirn_payload_cancel
      IMPORTING
        iv_docnum        TYPE string
        iv_irnno         TYPE string
        iv_cancelrsncode TYPE string
        iv_cancelrmrk    TYPE string
      RETURNING
        VALUE(rv_json)   TYPE string.
    " Cancel EwayBill Payload JSON for e-waybill cancellation
        METHODS build_ewaybill_payload_cancel
        IMPORTING
        iv_docnum        TYPE string
        iv_ewaybillno    TYPE string
        iv_cancelrsncode TYPE string
        iv_cancelrmrk    TYPE string
        RETURNING
        VALUE(rv_json)   TYPE string.


    " Call API to cancel e-waybill
    METHODS cancel_ewaybill
      IMPORTING
        iv_json            TYPE string
        iv_docnum          TYPE string
      RETURNING
        VALUE(rv_response) TYPE string
      RAISING
        cx_web_http_client_error
        cx_web_message_error
        cx_http_dest_provider_error.

        " Parse cancel response JSON into ABAP structure
    METHODS get_eway_cancel_response
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE ty_ewaybill_cancel_response.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZUNE_CLS_HELPER_EINV_EWB IMPLEMENTATION.


  METHOD build_ewbirn_payload.

    "======================================================================
    " E-Way Bill by IRN payload.
    " NOTE: ShipDtls / DispDtls are intentionally NOT sent here for domestic
    " supplies - the government e-way bill system picks up ship-to and
    " dispatch-from details directly from the e-invoice (IRN) already
    " generated for this document, so they must not be duplicated here.
    "
    " EXCEPTION - Export supplies (EXPWP / EXPWOP):
    " For exports the buyer is a foreign party, so there is no real
    " "ship-to" on the e-invoice for the EWB system to inherit. In this
    " case the e-way bill payload must carry the PORT details as
    " ExpShipDtls (GSTIN fixed to 'URP'), looked up via iv_port.
    "======================================================================

    " Export ship-to (port) details - only populated for export supplies
    TYPES: BEGIN OF ty_expship_dtls,
             gstin TYPE string,
             nm    TYPE string,
             addr1 TYPE string,
             addr2 TYPE string,
             loc   TYPE string,
             pin   TYPE string,
             stcd  TYPE string,
           END OF ty_expship_dtls.

    " Header data payload (transporter / vehicle / IRN details + export ship-to)
    TYPES: BEGIN OF ty_hedtls,
             irn             TYPE string,
             distance        TYPE string,
             transactiontype TYPE string,
             transmode       TYPE string,
             transid         TYPE string,
             transname       TYPE string,
             transdocdt      TYPE string,
             transdocno      TYPE string,
             vehno           TYPE string,
             vehtype         TYPE string,
             expshipdtls     TYPE ty_expship_dtls,
           END OF ty_hedtls.

    TYPES: ty_t_ty_hedtls TYPE STANDARD TABLE OF ty_hedtls WITH DEFAULT KEY.

    DATA: ls_payload TYPE ty_t_ty_hedtls.
    DATA: lt_payload TYPE ty_hedtls.

    "----------------------------------------------------------------------
    " Format billing document number to 10 characters with leading zeros
    "----------------------------------------------------------------------
    DATA: lv_docno TYPE string.
    lv_docno = iv_docnum.

    DATA(lv_len) = strlen( lv_docno ).
    IF lv_len < 10.
      DATA(lv_missing) = 10 - lv_len.
      lv_docno = |{ repeat( val = '0' occ = lv_missing ) }{ lv_docno }|.
    ENDIF.

    "----------------------------------------------------------------------
    " Format transporter document date into DD/MM/YYYY (if supplied)
    "----------------------------------------------------------------------
    DATA: lv_date     TYPE d,   " YYYYMMDD
          lv_date_str TYPE string.
    IF iv_transdocdt IS NOT INITIAL.
      lv_date     = iv_transdocdt.
      lv_date_str = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date(4) }|.
    ELSE.
      lv_date_str = ''.
    ENDIF.

    "----------------------------------------------------------------------
    " Populate header details
    "----------------------------------------------------------------------
    lt_payload-irn             = iv_irn.
    lt_payload-distance        = iv_distance.
    lt_payload-transdocdt      = lv_date_str.
    lt_payload-transdocno      = iv_transdocno.
    lt_payload-transid         = iv_transid.
    lt_payload-transname       = iv_transname.
    lt_payload-vehno           = iv_vehno.
    lt_payload-vehtype         = iv_vehtype.
    lt_payload-transmode       = iv_transmode.
    lt_payload-transactiontype = iv_transactiontype.

    "----------------------------------------------------------------------
    " Export ship-to (port) details - export supplies only
    "----------------------------------------------------------------------
    CLEAR lt_payload-expshipdtls.

    IF iv_supplytype = 'EXPWP' OR iv_supplytype = 'EXPWOP'.
      SELECT SINGLE a~portgstpostalcode, a~portgststatecode, a~text
        FROM zorn_portno_vh AS a
        WHERE a~value_low = @iv_port
        INTO @DATA(lt_portdata).

      lt_payload-expshipdtls-nm    = lt_portdata-text.
      lt_payload-expshipdtls-addr1 = lt_portdata-text.
      lt_payload-expshipdtls-addr2 = ''.
      lt_payload-expshipdtls-loc   = lt_portdata-text.
      lt_payload-expshipdtls-pin   = lt_portdata-portgstpostalcode.
      lt_payload-expshipdtls-stcd  = lt_portdata-portgststatecode.
      lt_payload-expshipdtls-gstin = 'URP'.
    ENDIF.

    APPEND lt_payload TO ls_payload.

    "----------------------------------------------------------------------
    " JSON serialization mappings (ABAP → JSON field names)
    "----------------------------------------------------------------------
    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings,
          lv_json     TYPE string.

    lt_name_map = VALUE #(
      ( abap = 'IRN'             json = 'Irn' )
      ( abap = 'DISTANCE'        json = 'Distance' )
      ( abap = 'TRANSMODE'       json = 'TransMode' )
      ( abap = 'TRANSID'         json = 'TransId' )
      ( abap = 'TRANSNAME'       json = 'TransName' )
      ( abap = 'TRANSDOCDT'      json = 'TransDocDt' )
      ( abap = 'TRANSDOCNO'      json = 'TransDocNo' )
      ( abap = 'TRANSACTIONTYPE' json = 'TransactionType' )
      ( abap = 'VEHNO'           json = 'VehNo' )
      ( abap = 'VEHTYPE'         json = 'VehType' )

      " Export ship-to (port) details
      ( abap = 'EXPSHIPDTLS' json = 'ExpShipDtls' )
      ( abap = 'GSTIN'       json = 'Gstin' )
      ( abap = 'NM'          json = 'Nm' )
      ( abap = 'ADDR1'       json = 'Addr1' )
      ( abap = 'ADDR2'       json = 'Addr2' )
      ( abap = 'LOC'         json = 'Loc' )
      ( abap = 'PIN'         json = 'Pin' )
      ( abap = 'STCD'        json = 'Stcd' )
    ).

    " Serialize with mapping
    rv_json = /ui2/cl_json=>serialize(
                data          = ls_payload
                name_mappings = lt_name_map
                pretty_name   = /ui2/cl_json=>pretty_mode-none ).



  ENDMETHOD.


  METHOD build_ewbirn_payload_cancel.

  ENDMETHOD.


  METHOD cancel_ewbirn.

  ENDMETHOD.


  METHOD generate_ewbirn.

    " Declare local variables for base URL, token, and GSTIN
    DATA: lv_baseurl TYPE string,
          lv_token   TYPE string,
          lv_gstin   TYPE string.

    " Fetch e-invoice configuration details (base URL, token, GSTIN)
    CALL METHOD get_einv_config
      EXPORTING
        iv_docnum    = iv_docnum       " Input: document number
      IMPORTING
        ev_baseurl   = lv_baseurl      " Output: base URL of e-invoice API
        ev_authtoken = lv_token        " Output: ClearTax authentication token
        ev_gstin     = lv_gstin.       " Output: GSTIN of the company


    " Declare variables for API URL and HTTP client objects
    DATA: lv_einvurl TYPE string VALUE '/einv/v2/eInvoice/ewaybill', " Relative endpoint for eWaybill generation
          lo_dest    TYPE REF TO if_http_destination,                " HTTP destination object
          lo_client  TYPE REF TO if_web_http_client,                 " HTTP client object
          lo_req     TYPE REF TO if_web_http_request,                " HTTP request object
          lo_resp    TYPE REF TO if_web_http_response,               " HTTP response object
          lv_url     TYPE string.                                    " Complete API URL


    " Build complete API URL by combining base URL and endpoint
    lv_url = |{ lv_baseurl }{ lv_einvurl }|.

    " Create HTTP destination from the URL
    lo_dest   = cl_http_destination_provider=>create_by_url( lv_url ).

    " Create HTTP client from the destination
    lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

    " Prepare HTTP request object
    lo_req = lo_client->get_http_request( ).

    " Set request content type as JSON
    lo_req->set_content_type( 'application/json' ).

    " Set required headers:
    " Authentication token
    lo_req->set_header_field( i_name = 'X-Cleartax-Auth-Token'
                              i_value = lv_token ).
    " GSTIN of the company
    lo_req->set_header_field( i_name = 'gstin'
                              i_value = lv_gstin ).

    " Attach JSON payload (input parameter iv_json) to request body
    lo_req->set_text( iv_json ).

    " Execute HTTP request with PUT method and capture response
    lo_resp     = lo_client->execute( if_web_http_client=>post ).

    " Get response text from HTTP response
    rv_response = lo_resp->get_text( ).

    " Close HTTP client connection
    lo_client->close( ).

  ENDMETHOD.


  METHOD get_einv_config.

    " Local variable to hold configuration record
    "DATA: lv_einvoiceconfig TYPE zune_iv_einvconf.

    " Clear exporting parameters before use
    CLEAR: ev_baseurl, ev_authtoken, ev_gstin.

    " Local variable for document number
    DATA:lv_docno TYPE string.
    lv_docno = iv_docnum.
    " Ensure document number is at least 10 characters long (pad with leading zeros)
    DATA(lv_len) = strlen( lv_docno ).
    IF lv_len < 10.
      DATA(lv_missing) = 10 - lv_len.
      lv_docno = |{ repeat( val = '0' occ = lv_missing ) }{ lv_docno }|.
    ENDIF.
    " Read seller details (GSTIN) for the given billing document
    SELECT SINGLE sellergstin FROM zune_cds_seller_det WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO  @DATA(sellergstin).

    " Read e-invoice configuration for service provider = '1' and seller GSTIN
    SELECT SINGLE einvoicebaseurl,cleartaxauthtoken,gstin
      FROM zune_iv_einvconf WITH PRIVILEGED ACCESS AS a
      WHERE a~serviceprovider = '1'
        AND a~gstin           = @sellergstin
      INTO @Data(lv_einvoiceconfig).
    " If config found, return values to exporting parameters
    IF sy-subrc = 0.
      ev_baseurl   = lv_einvoiceconfig-einvoicebaseurl.
      ev_authtoken = lv_einvoiceconfig-cleartaxauthtoken.
      ev_gstin     = lv_einvoiceconfig-gstin.
    ELSE.
      "Optional: raise exception or leave exporting parameters initial
*      ev_baseurl   = ''.
*      ev_authtoken = ''.
*      ev_gstin     = ''.

    ENDIF.

  ENDMETHOD.


  METHOD get_ewbirn_response.



    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = iv_json
            pretty_name = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data        = rv_response
        ).
      CATCH cx_root INTO DATA(lx).
        DATA(a) = lx.
*        RAISE EXCEPTION NEW cx_static_check(
*          textid   = cx_static_check=>others
*          previous = lx
*        ).
    ENDTRY.

  ENDMETHOD.


  METHOD get_ewbirn_response_err.



    TRY.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = iv_json
            pretty_name = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data        = rv_response
        ).
      CATCH cx_root INTO DATA(lx).
        DATA(a) = lx.
*        RAISE EXCEPTION NEW cx_static_check(
*          textid   = cx_static_check=>others
*          previous = lx
*        ).
    ENDTRY.

  ENDMETHOD.


  METHOD build_ewaybill_payload_cancel.
    " Define structure for eWaybill cancel request
    TYPES: BEGIN OF ty_ewaybill_cancel,
             ewbno         TYPE int8,
             cancelrsncode TYPE string,
             cancelrmrk    TYPE string,
           END OF ty_ewaybill_cancel.
    " Fill payload with input values
    DATA:ls_payload TYPE ty_ewaybill_cancel.
    ls_payload-ewbno = iv_ewaybillno.
    ls_payload-cancelrsncode = COND #( WHEN iv_cancelrsncode = '1' THEN 'DUPLICATE'
                                       WHEN iv_cancelrsncode = '2' THEN 'DATA_ENTRY_MISTAKE'
                                       WHEN iv_cancelrsncode = '3' THEN 'ORDER_CANCELLED'
                                       WHEN iv_cancelrsncode = '4' THEN 'OTHERS' ).
    ls_payload-cancelrmrk = iv_cancelrmrk.
    " JSON field mapping
    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings,
          lv_json     TYPE string.
    lt_name_map = VALUE #(
      ( abap = 'EWBNO'   json = 'ewbNo' )
      ( abap = 'CANCELRSNCODE'   json = 'cancelRsnCode' )
       ( abap = 'CANCELRMRK'   json = 'cancelRmrk' )
       ).
    " Serialize with mapping
    rv_json = /ui2/cl_json=>serialize(
                 data          = ls_payload
                 name_mappings = lt_name_map
                 pretty_name   = /ui2/cl_json=>pretty_mode-none ).
  ENDMETHOD.


 METHOD cancel_ewaybill.
    " Declare local variables for base URL, token, and GSTIN
    DATA: lv_baseurl TYPE string,
          lv_token   TYPE string,
          lv_gstin   TYPE string.
    " Get e-invoice configuration details (base URL, token, GSTIN)
    CALL METHOD get_einv_config
      EXPORTING
        iv_docnum    = iv_docnum
      IMPORTING
        ev_baseurl   = lv_baseurl
        ev_authtoken = lv_token
        ev_gstin     = lv_gstin.



    " Declare variables for API URL and HTTP client objects
    DATA: lv_einvurl TYPE string VALUE '/einv/v2/eInvoice/ewaybill/cancel', " Endpoint for cancel API
          lo_dest    TYPE REF TO if_http_destination,                      " HTTP destination object
          lo_client  TYPE REF TO if_web_http_client,                       " HTTP client object
          lo_req     TYPE REF TO if_web_http_request,                      " HTTP request object
          lo_resp    TYPE REF TO if_web_http_response,                     " HTTP response object
          lv_url     TYPE string.                                          " Full API URL

    " Build complete API URL
    lv_url = |{ lv_baseurl }{ lv_einvurl }|.

    " Create HTTP destination from the API URL
    lo_dest   = cl_http_destination_provider=>create_by_url( lv_url ).
    " Create HTTP client from destination
    lo_client = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
    " Prepare HTTP request
    lo_req = lo_client->get_http_request( ).
    " Set request type as JSON
    lo_req->set_content_type( 'application/json' ).
    " Add required headers:
    " ClearTax authentication token
    lo_req->set_header_field( i_name = 'X-Cleartax-Auth-Token'
                              i_value = lv_token ).
    " GSTIN of company
    lo_req->set_header_field( i_name = 'gstin'
                              i_value = lv_gstin ).
    " Attach input JSON payload (iv_json) to request body
    lo_req->set_text( iv_json ).
    " Execute HTTP request using POST method and capture response
    lo_resp     = lo_client->execute( if_web_http_client=>post ).
    " Extract response text into return variable
    rv_response = lo_resp->get_text( ).
    " Close client connection
    lo_client->close( ).


  ENDMETHOD.


  METHOD get_eway_cancel_response.
    TRY.
        " Deserialize JSON string (iv_json) into ABAP structure/table (rv_response)
        /ui2/cl_json=>deserialize(
         EXPORTING
          json        = iv_json                           " Input JSON string
          pretty_name = /ui2/cl_json=>pretty_mode-none    " Do not modify field names
        CHANGING
          data        = rv_response                       " Output ABAP data structure
      ).
      CATCH cx_root INTO DATA(lx).
        DATA(a) = lx.
*        RAISE EXCEPTION NEW cx_static_check(
*          textid   = cx_static_check=>others
*          previous = lx
*        ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
