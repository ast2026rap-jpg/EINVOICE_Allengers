CLASS zune_cls_helper DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    "--------------------------------------------------------
    " Error Details Structure (for API error reporting)
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_error_detail,
             error_code    TYPE string,
             error_message TYPE string,
             error_source  TYPE string,
           END OF ty_error_detail.

    TYPES: ty_t_error_details TYPE STANDARD TABLE OF ty_error_detail WITH DEFAULT KEY.

    "--------------------------------------------------------
    " Govt Response Structure (part of API response)
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_govt_response,
             success      TYPE string,
             status       TYPE string,
             ewbno        TYPE string,
             ewbdt        TYPE string,
             ewbvalidtill TYPE string,
             alert        TYPE string,
             errordetails TYPE ty_t_error_details,
           END OF ty_govt_response.

    "--------------------------------------------------------
    " Main API Response (ClearTax / Govt combined response)
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_response,
             owner_id       TYPE string,
             ewb_status     TYPE string,
             ewb_request    TYPE string,
             govt_response  TYPE ty_govt_response,
             transaction_id TYPE string,
           END OF ty_response.
    "--------------------------------------------------------
    " Cancel E-Waybill Response Structure
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_error_details,
             error_code    TYPE string,
             error_message TYPE string,
             error_source  TYPE string,
           END OF ty_error_details.

    TYPES: BEGIN OF ty_ewaybill_cancel_response,
             ownerid      TYPE string,
             gstin        TYPE string,
             irn          TYPE string,
             ewbnumber    TYPE int8,
             ewbstatus    TYPE string,
             errordetails TYPE ty_error_details,  "nested structure
           END OF ty_ewaybill_cancel_response.

    "--------------------------------------------------------
    " Part B E-Waybill Response Structure
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_error_details_partB,
             error_code    TYPE string,
             error_message TYPE string,
             error_source  TYPE string,
           END OF ty_error_details_partB.
    TYPES: t_ty_error_details_partB TYPE STANDARD TABLE OF ty_error_details_partB WITH DEFAULT KEY.
    TYPES: BEGIN OF ty_ewaybill_partb_response,
             EwbNumber      TYPE int8,
             UpdatedDate        TYPE string,
             ValidUpto          TYPE string,
             errors             TYPE t_ty_error_details_partB,  "nested structure
           END OF ty_ewaybill_partb_response.



    "--------------------------------------------------------
    " METHODS
    "--------------------------------------------------------

    " Call API to generate e-waybill
    METHODS generate_ewaybill
      IMPORTING
        iv_json            TYPE string
        iv_docnum          TYPE string
      RETURNING
        VALUE(rv_response) TYPE string
      RAISING
        cx_web_http_client_error
        cx_web_message_error
        cx_http_dest_provider_error.

    " Build payload JSON for e-waybill generation
    METHODS build_ewaybill_payload
      IMPORTING
        iv_docnum            TYPE string
        iv_documenttype      TYPE string
        iv_supplytype        TYPE string
        iv_subsupplytype     TYPE string
        iv_subsupplytypedesc TYPE string
        iv_transactiontype   TYPE string
        iv_transid           TYPE string
        iv_transname         TYPE string
        iv_transmode         TYPE int4
        iv_distance          TYPE int4
        iv_transdocno        TYPE string
        iv_transdocdt        TYPE string
        iv_vehno             TYPE string
        iv_vehtype           TYPE string
        iv_refrenceno        TYPE string
      RETURNING
        VALUE(rv_json)       TYPE string.

    " Build payload JSON for e-waybill cancellation
    METHODS build_ewaybill_payload_cancel
      IMPORTING
        iv_docnum        TYPE string
        iv_ewaybillno    TYPE string
        iv_cancelrsncode TYPE string
        iv_cancelrmrk    TYPE string
      RETURNING
        VALUE(rv_json)   TYPE string.

    " Parse govt response JSON into ABAP structure
    METHODS get_eway_response
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE ty_response.

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


    " Fetch e-invoice config (Base URL, Token, GSTIN) based on document number
    METHODS get_einv_config
      IMPORTING
        iv_docnum    TYPE string
      EXPORTING
        ev_baseurl   TYPE string
        ev_authtoken TYPE string
        ev_gstin     TYPE string.

    METHODS generate_eway_pdf
      IMPORTING
        ewabillno          TYPE string
        iv_docnum          TYPE string
      RETURNING
        VALUE(rv_response) TYPE string
      RAISING
        cx_web_http_client_error
        cx_web_message_error
        cx_http_dest_provider_error.

    " Build payload JSON for e-waybill generation Part B
    METHODS build_ewaybill_payload_partb
      IMPORTING
        iv_docnum       TYPE string
        iv_ewaybillnum  TYPE string
        iv_distance     TYPE int4
        iv_fromplace    TYPE string
        iv_fromstate    TYPE string
        iv_reasoncode   TYPE string
        iv_reasonremark TYPE string
        iv_transdocno   TYPE string
        iv_transdocdt   TYPE string
        iv_transmode    TYPE int4
        iv_vehno        TYPE string
        iv_vehtype      TYPE string
        iv_refrenceno   TYPE string
      RETURNING
        VALUE(rv_json)  TYPE string.
    " Call API to generate e-waybill
    METHODS generate_ewaybill_partb
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
    METHODS get_eway_partb_response
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE ty_ewaybill_partb_response.



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZUNE_CLS_HELPER IMPLEMENTATION.


  METHOD generate_ewaybill.

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
    DATA: lv_einvurl TYPE string VALUE '/einv/v3/ewaybill/generate', " Relative endpoint for eWaybill generation
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
    lo_resp     = lo_client->execute( if_web_http_client=>put ).

    " Get response text from HTTP response
    rv_response = lo_resp->get_text( ).

    " Close HTTP client connection
    lo_client->close( ).

  ENDMETHOD.


  METHOD build_ewaybill_payload.

    " --- Define structures for buyer, seller, shipping, dispatch, and items ---
    TYPES: BEGIN OF ty_buyer_dtls,
             gstin TYPE string,
             lglnm TYPE string,
             trdnm TYPE string,
             addr1 TYPE string,
             addr2 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_buyer_dtls.

    TYPES: BEGIN OF ty_seller_dtls,
             gstin TYPE string,
             lglnm TYPE string,
             addr1 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_seller_dtls.

    TYPES: BEGIN OF ty_expship_dtls,
             lglnm TYPE string,
             addr1 TYPE string,
             addr2 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_expship_dtls.

    TYPES: BEGIN OF ty_disp_dtls,
             nm    TYPE string,
             addr1 TYPE string,
             addr2 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_disp_dtls.
    " --- Item details (HSN, qty, tax, etc.) ---
    TYPES: BEGIN OF ty_item,
             prodname     TYPE string,
             proddesc     TYPE string,
             hsncd        TYPE string,
             qty          TYPE i,
             unit         TYPE string,
             assamt       TYPE decfloat34,
             cgstrt       TYPE decfloat34,
             cgstamt      TYPE decfloat34,
             sgstrt       TYPE decfloat34,
             sgstamt      TYPE decfloat34,
             igstrt       TYPE decfloat34,
             igstamt      TYPE decfloat34,
             cesrt        TYPE decfloat34,
             cesamt       TYPE decfloat34,
             othchrg      TYPE decfloat34,
             cesnonadvamt TYPE decfloat34,
           END OF ty_item.
    TYPES: ty_item_list TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    " --- Main payload structure for eWaybill ---
    TYPES: BEGIN OF ty_ewaybill,
             documentnumber          TYPE string,
             documenttype            TYPE string,
             documentdate            TYPE string,
             supplytype              TYPE string,
             subsupplytype           TYPE string,
             subsupplytypedesc       TYPE string,
             transactiontype         TYPE string,
             buyerdtls               TYPE ty_buyer_dtls,
             sellerdtls              TYPE ty_seller_dtls,
             expshipdtls             TYPE ty_expship_dtls,
             dispdtls                TYPE ty_disp_dtls,
             itemlist                TYPE ty_item_list,
             totalinvoiceamount      TYPE decfloat34,
             totalcgstamount         TYPE decfloat34,
             totalsgstamount         TYPE decfloat34,
             totaligstamount         TYPE decfloat34,
             totalcessamount         TYPE decfloat34,
             totalcessnonadvolamount TYPE decfloat34,
             totalassessableamount   TYPE decfloat34,
             otheramount             TYPE decfloat34,
             othertcsamount          TYPE decfloat34,
             transid                 TYPE string,
             transname               TYPE string,
             transmode               TYPE i,
             distance                TYPE i,
             transdocno              TYPE string,
             transdocdt              TYPE string,
             vehno                   TYPE string,
             vehtype                 TYPE string,
           END OF ty_ewaybill.

    " --- Working data variables ---
    DATA:lt_items  TYPE ty_item_list.

    DATA:ls_payload TYPE ty_ewaybill.
    DATA: ls_buyer_dtls TYPE ty_buyer_dtls.
    DATA: ls_seller_dtls  TYPE ty_seller_dtls.
    " Format billing document number to 10 characters with leading zeros
    DATA:lv_docno TYPE string.
    lv_docno = iv_docnum.

    DATA(lv_len) = strlen( lv_docno ).
    IF lv_len < 10.
      DATA(lv_missing) = 10 - lv_len.
      lv_docno = |{ repeat( val = '0' occ = lv_missing ) }{ lv_docno }|.
    ENDIF.
    " --- Fetch billing header ---
    SELECT SINGLE billingdocumentdate FROM i_billingdocument WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO @DATA(lv_billingdocumentdate).
    " Format billing document date into DD/MM/YYYY
    DATA: lv_date     TYPE d,   " YYYYMMDD
          lv_date_str TYPE string.
    lv_date = lv_billingdocumentdate.
    lv_date_str = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date(4) }|.

    " --- Populate header values ---
    ls_payload-documentnumber    = iv_refrenceno.
    ls_payload-documenttype      = iv_documenttype.
    ls_payload-documentdate      = lv_date_str.
    ls_payload-supplytype        = iv_supplytype.
    ls_payload-subsupplytype     = iv_subsupplytype.
    ls_payload-subsupplytypedesc = iv_subsupplytypedesc.
    ls_payload-transactiontype   = iv_transactiontype.

    " --- Buyer details ---

    SELECT SINGLE * FROM zune_cds_billbuyer WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO  @DATA(buyeradd).

    ls_buyer_dtls-gstin = buyeradd-taxnumber3.
    ls_buyer_dtls-lglnm = buyeradd-lglnm.
    ls_buyer_dtls-trdnm = buyeradd-trdnm.
    ls_buyer_dtls-addr1 = buyeradd-addr1.
    ls_buyer_dtls-addr2 = buyeradd-addr2.
    ls_buyer_dtls-loc   = buyeradd-loc.
    ls_buyer_dtls-pin   = buyeradd-pin.
    ls_buyer_dtls-stcd  = buyeradd-stcd.
    ls_payload-buyerdtls = ls_buyer_dtls.
    " --- Seller details ---
    SELECT SINGLE * FROM zune_cds_seller_det WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO  @DATA(selleradd).
    ls_seller_dtls-gstin = selleradd-sellergstin.
    ls_seller_dtls-lglnm = selleradd-lglnm.
    ls_seller_dtls-addr1 = selleradd-addr1.
    ls_seller_dtls-loc   = selleradd-loc.
    ls_seller_dtls-pin   = selleradd-pin.
    ls_seller_dtls-stcd  = selleradd-stcd.

    ls_payload-sellerdtls = ls_seller_dtls.

    " --- Expected shipping details ---

    SELECT SINGLE

       *

      FROM  i_billingdocumentitem AS a
      LEFT OUTER JOIN i_outbounddelivery AS b ON a~referencesddocument = b~outbounddelivery
      LEFT OUTER JOIN i_outbounddeliverypartnertp  WITH PRIVILEGED ACCESS AS c ON c~outbounddelivery = b~outbounddelivery
      LEFT OUTER JOIN i_customer AS d ON c~customer = d~customer
      LEFT OUTER JOIN  i_address_2  AS e ON    c~addressid = e~addressid
      LEFT OUTER JOIN zune_cds_stategst WITH PRIVILEGED ACCESS AS f ON f~value_low = d~region
      WHERE a~billingdocument = @lv_docno  AND c~partnerfunction = 'WE'
      INTO  @DATA(expshippingadd).

    ls_payload-expshipdtls-lglnm = expshippingadd-d-bpcustomerfullname.
    ls_payload-expshipdtls-addr1 = expshippingadd-d-streetname.
    ls_payload-expshipdtls-addr2 = expshippingadd-d-bpaddrstreetname.
    ls_payload-expshipdtls-loc   = expshippingadd-d-cityname.
    ls_payload-expshipdtls-pin   = expshippingadd-d-postalcode.
    ls_payload-expshipdtls-stcd  = expshippingadd-f-text.



    " --- Dispatch details (plant address) ---

    SELECT SINGLE plant FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO @DATA(lv_plant).

    SELECT SINGLE
                  *
    FROM i_plant AS a
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS b ON ( a~addressid = b~addressid )
    LEFT OUTER JOIN zune_cds_stategst WITH PRIVILEGED ACCESS AS c ON c~value_low = b~region
    WHERE plant = @lv_plant INTO @DATA(sellerplantaddress).

    ls_payload-dispdtls-nm    = sellerplantaddress-a-plantname.
    ls_payload-dispdtls-addr1 = sellerplantaddress-b-streetname.
    ls_payload-dispdtls-addr2 = sellerplantaddress-b-streetprefixname1.
    ls_payload-dispdtls-loc   = sellerplantaddress-b-streetprefixname2.
    ls_payload-dispdtls-pin   = sellerplantaddress-b-postalcode.
    ls_payload-dispdtls-stcd  = sellerplantaddress-c-text.

    "-----Item level details----
    SELECT * FROM zune_cds_billingitemdetails WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO TABLE  @DATA(billingdetails).
    " Totals initialization
    DATA: lv_totalinvoiceamount TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_totalcgstamount TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_totalsgstamount TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_totaligstamount  TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_totalcessamount  TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_totalassessableamount  TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_otheramount  TYPE p LENGTH 16 DECIMALS 2.


    LOOP AT  billingdetails ASSIGNING FIELD-SYMBOL(<lv_billingdetails>).

      DATA:ls_item    TYPE ty_item.
      " Map billing item fields into eWaybill item
      ls_item-prodname = <lv_billingdetails>-product.
      ls_item-proddesc = <lv_billingdetails>-product.
      ls_item-hsncd    = <lv_billingdetails>-hsn.
      ls_item-qty      = <lv_billingdetails>-billingquantity.
      ls_item-unit     = <lv_billingdetails>-govunitcode.
      ls_item-assamt   = <lv_billingdetails>-assamt.
      ls_item-cgstrt   = <lv_billingdetails>-cgstrate.
      ls_item-cgstamt  = <lv_billingdetails>-cgstamount.
      ls_item-sgstrt   = <lv_billingdetails>-sgstrate.
      ls_item-sgstamt = <lv_billingdetails>-sgstamount.
      ls_item-igstrt   = <lv_billingdetails>-igstrate.
      ls_item-igstamt  = <lv_billingdetails>-igstamount.
      ls_item-cesrt = <lv_billingdetails>-cessrate.
      ls_item-cesamt = <lv_billingdetails>-cessamount.
      ls_item-othchrg = ( <lv_billingdetails>-netamount - <lv_billingdetails>-assamt ) + <lv_billingdetails>-freightchargestax.
      ls_item-cesnonadvamt = 0.

      " Accumulate totals
      lv_totalassessableamount = lv_totalassessableamount + <lv_billingdetails>-assamt.
      lv_totalcgstamount = lv_totalcgstamount + <lv_billingdetails>-cgstamount.
      lv_totalsgstamount = lv_totalsgstamount + <lv_billingdetails>-sgstamount.
      lv_totaligstamount = lv_totaligstamount + <lv_billingdetails>-igstamount.
      lv_totalcessamount = lv_totalcessamount + <lv_billingdetails>-cessamount.
      lv_otheramount = lv_otheramount + ( <lv_billingdetails>-netamount - <lv_billingdetails>-assamt ) + <lv_billingdetails>-freightchargestax.
      APPEND ls_item TO lt_items.
    ENDLOOP.
    " Add items to payload
    ls_payload-itemlist = lt_items.
    " Compute invoice total
    lv_totalinvoiceamount = lv_totalassessableamount + lv_totalcgstamount + lv_totalsgstamount + lv_totaligstamount + lv_totalcessamount.

    " --- Populate totals and transport details ---
    ls_payload-totalinvoiceamount      = lv_totalinvoiceamount + lv_otheramount.
    ls_payload-totalcgstamount         = lv_totalcgstamount.
    ls_payload-totalsgstamount         = lv_totalsgstamount.
    ls_payload-totaligstamount         = lv_totaligstamount.
    ls_payload-totalcessamount         = lv_totalcessamount.
    ls_payload-totalcessnonadvolamount = 0.
    ls_payload-totalassessableamount   = lv_totalassessableamount.
    ls_payload-otheramount             = lv_otheramount.
    ls_payload-othertcsamount          = 0.
    ls_payload-transid                 = iv_transid.
    ls_payload-transname               = iv_transname.
    ls_payload-transmode               = iv_transmode.
    ls_payload-distance                = iv_distance.
    ls_payload-transdocno              = iv_transdocno.
    ls_payload-transdocdt              = iv_transdocdt.
    ls_payload-vehno                   = iv_vehno.
    ls_payload-vehtype                 = iv_vehtype.



    " --- JSON serialization mappings (ABAP → JSON field names) ---

    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings,
          lv_json     TYPE string.

    lt_name_map = VALUE #(
      ( abap = 'DOCUMENTNUMBER'   json = 'DocumentNumber' )
      ( abap = 'DOCUMENTTYPE'     json = 'DocumentType' )
      ( abap = 'DOCUMENTDATE'     json = 'DocumentDate' )
      ( abap = 'SUPPLYTYPE'       json = 'SupplyType' )
      ( abap = 'SUBSUPPLYTYPE'    json = 'SubSupplyType' )
      ( abap = 'SUBSUPPLYTYPEDESC' json = 'SubSupplyTypeDesc' )
      ( abap = 'TRANSACTIONTYPE'  json = 'TransactionType' )

      " Buyer Details
      ( abap = 'BUYERDTLS' json = 'BuyerDtls' )
      ( abap = 'GSTIN'     json = 'Gstin' )
      ( abap = 'LGLNM'     json = 'LglNm' )
      ( abap = 'TRDNM'     json = 'TrdNm' )
      ( abap = 'ADDR1'     json = 'Addr1' )
      ( abap = 'ADDR2'     json = 'Addr2' )
      ( abap = 'LOC'       json = 'Loc' )
      ( abap = 'PIN'       json = 'Pin' )
      ( abap = 'STCD'      json = 'Stcd' )

      " Seller Details
      ( abap = 'SELLERDTLS' json = 'SellerDtls' )

      " Export Ship Details
      ( abap = 'EXPSHIPDTLS' json = 'ExpShipDtls' )

      " Dispatch Details
      ( abap = 'DISPDTLS' json = 'DispDtls' )
      ( abap = 'NM'       json = 'NM' )

      " Item List
      ( abap = 'ITEMLIST'     json = 'ItemList' )
      ( abap = 'PRODNAME'     json = 'ProdName' )
      ( abap = 'PRODDESC'     json = 'ProdDesc' )
      ( abap = 'HSNCD'        json = 'HsnCd' )
      ( abap = 'QTY'          json = 'Qty' )
      ( abap = 'UNIT'         json = 'Unit' )
      ( abap = 'ASSAMT'       json = 'AssAmt' )
      ( abap = 'CGSTRT'       json = 'CgstRt' )
      ( abap = 'CGSTAMT'      json = 'CgstAmt' )
      ( abap = 'SGSTRT'       json = 'SgstRt' )
      ( abap = 'SGSTAMT'      json = 'SgstAmt' )
      ( abap = 'IGSTRT'       json = 'IgstRt' )
      ( abap = 'IGSTAMT'      json = 'IgstAmt' )
      ( abap = 'CESRT'        json = 'CesRt' )
      ( abap = 'CESAMT'       json = 'CesAmt' )
      ( abap = 'OTHCHRG'      json = 'OthChrg' )
      ( abap = 'CESNONADVAMT' json = 'CesNonAdvAmt' )

      " Totals
      ( abap = 'TOTALINVOICEAMOUNT'      json = 'TotalInvoiceAmount' )
      ( abap = 'TOTALCGSTAMOUNT'         json = 'TotalCgstAmount' )
      ( abap = 'TOTALSGSTAMOUNT'         json = 'TotalSgstAmount' )
      ( abap = 'TOTALIGSTAMOUNT'         json = 'TotalIgstAmount' )
      ( abap = 'TOTALCESSAMOUNT'         json = 'TotalCessAmount' )
      ( abap = 'TOTALCESSNONADVOLAMOUNT' json = 'TotalCessNonAdvolAmount' )
      ( abap = 'TOTALASSESSABLEAMOUNT'   json = 'TotalAssessableAmount' )
      ( abap = 'OTHERAMOUNT'             json = 'OtherAmount' )
      ( abap = 'OTHERTCSAMOUNT'          json = 'OtherTcsAmount' )

      " Transport
      ( abap = 'TRANSID'    json = 'TransId' )
      ( abap = 'TRANSNAME'  json = 'TransName' )
      ( abap = 'TRANSMODE'  json = 'TransMode' )
      ( abap = 'DISTANCE'   json = 'Distance' )
      ( abap = 'TRANSDOCNO' json = 'TransDocNo' )
      ( abap = 'TRANSDOCDT' json = 'TransDocDt' )
      ( abap = 'VEHNO'      json = 'VehNo' )
      ( abap = 'VEHTYPE'    json = 'VehType' )
    ).

    " Serialize with mapping
    rv_json = /ui2/cl_json=>serialize(
                 data          = ls_payload
                 name_mappings = lt_name_map
                 pretty_name   = /ui2/cl_json=>pretty_mode-none ).

    " --- Serialize to JSON ---
    "   rv_json = /ui2/cl_json=>serialize( data = ls_payload ).
  ENDMETHOD.


  METHOD get_eway_response.
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


  METHOD get_einv_config.
    " Local variable to hold configuration record
    DATA: lv_einvoiceconfig TYPE zune_iv_einvconf.

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
    SELECT SINGLE *
      FROM zune_iv_einvconf WITH PRIVILEGED ACCESS AS a
      WHERE a~serviceprovider = '1'
        AND a~gstin           = @sellergstin
      INTO @lv_einvoiceconfig.
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


  METHOD generate_eway_pdf.
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
    DATA: lv_einvurl TYPE string VALUE '/einv/v2/eInvoice/ewaybill/print?format=pdf', " Endpoint for cancel API
          lo_dest    TYPE REF TO if_http_destination,                      " HTTP destination object
          lo_client  TYPE REF TO if_web_http_client,                       " HTTP client object
          lo_req     TYPE REF TO if_web_http_request,                      " HTTP request object
          lo_resp    TYPE REF TO if_web_http_response,                     " HTTP response object
          lv_url     TYPE string,     " Full API URL
          lv_json    TYPE string.
    " Build complete API URL
    lv_url = |{ lv_baseurl }{ lv_einvurl }|.

    DATA lv_ewbno TYPE string.
    " Convert integer to string
    lv_ewbno = |{ ewabillno }|.   " inline conversion

    " Build JSON payload
    CONCATENATE
   '{ "ewb_numbers": [ '
   lv_ewbno
   ' ], "print_type": "DETAILED" }'
   INTO lv_json.

    "lv_json = |{{ "ewb_numbers": [ { lv_ewbno } ], "print_type": "DETAILED" }}|.


    "  lv_json = '{   "ewb_numbers": [ ' + lv_ewbno + ' ], "print_type": "DETAILED" }'.


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
    lo_req->set_text( lv_json ).
    " Execute HTTP request using POST method and capture response
    lo_resp     = lo_client->execute( if_web_http_client=>post ).
    " Extract response text into return variable
    "rv_response = lo_resp->get_text( ).
    " Get raw binary response (PDF file)
    rv_response = lo_resp->get_binary( ).
    " Close client connection
    lo_client->close( ).

  ENDMETHOD.


  METHOD build_ewaybill_payload_partb.

    " Define structure for eWaybill Part B request
    TYPES: BEGIN OF ty_ewaybill_payload_partb,
             ewbnumber    TYPE int8,
             fromplace    TYPE string,
             fromstate    TYPE string,
             reasoncode   TYPE string,
             reasonremark TYPE string,
             transdocno   TYPE string,
             transdocdt   TYPE string,
             transmode    TYPE string,
             vehicletype  TYPE string,
             vehno        TYPE string,
           END OF ty_ewaybill_payload_partb.
    " Fill payload with input values
    DATA:ls_payload TYPE ty_ewaybill_payload_partb.
    ls_payload-ewbnumber = iv_ewaybillnum.
    ls_payload-fromplace = iv_fromplace.
    ls_payload-fromstate = iv_fromstate.

    ls_payload-reasoncode = COND #( WHEN iv_reasoncode = '1' THEN 'BREAKDOWN'
                                       WHEN iv_reasoncode = '2' THEN 'TRANSSHIPMENT'
                                       WHEN iv_reasoncode = '3' THEN 'OTHERS'
                                       WHEN iv_reasoncode = '4' THEN 'FIRST_TIME' ).
    ls_payload-reasonremark = iv_reasonremark.
    ls_payload-transdocno = iv_transdocno.
     " Format billing document date into DD/MM/YYYY
    DATA: lv_date     TYPE d,   " YYYYMMDD
          lv_date_str TYPE string.
    lv_date = iv_transdocdt.
    lv_date_str = |{ lv_date+6(2) }/{ lv_date+4(2) }/{ lv_date(4) }|.
    ls_payload-transdocdt = lv_date_str.
    ls_payload-transmode = COND #( WHEN iv_transmode = '1' THEN 'ROAD'
                                       WHEN iv_reasoncode = '2' THEN 'RAIL'
                                       WHEN iv_reasoncode = '3' THEN 'AIR'
                                       WHEN iv_reasoncode = '4' THEN 'SHIP' ).
    ls_payload-vehicletype = iv_vehtype.
    ls_payload-vehno = iv_vehno.


    " JSON field mapping
    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings,
          lv_json     TYPE string.
    lt_name_map = VALUE #(
      ( abap = 'EWBNUMBER'   json = 'EwbNumber' )
      ( abap = 'FROMPLACE'   json = 'FromPlace' )
      ( abap = 'FROMSTATE'   json = 'FromState' )
      ( abap = 'REASONCODE'   json = 'ReasonCode' )
      ( abap = 'REASONREMARK'   json = 'ReasonRemark' )
      ( abap = 'TRANSDOCNO'   json = 'TransDocNo' )
      ( abap = 'TRANSDOCDT'   json = 'TransDocDt' )
      ( abap = 'TRANSMODE'   json = 'TransMode' )
       ( abap = 'VEHICLETYPE'   json = 'VehicleType' )
        ( abap = 'VEHNO'   json = 'VehNo' )
       ).
    " Serialize with mapping
    rv_json = /ui2/cl_json=>serialize(
                 data          = ls_payload
                 name_mappings = lt_name_map
                 pretty_name   = /ui2/cl_json=>pretty_mode-none ).


  ENDMETHOD.


  METHOD generate_ewaybill_partb.

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
    DATA: lv_einvurl TYPE string VALUE '/einv/v1/ewaybill/update?action=PARTB', " Relative endpoint for eWaybill part b generation
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


  METHOD get_eway_partb_response.

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
ENDCLASS.
