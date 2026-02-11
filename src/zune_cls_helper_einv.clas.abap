CLASS zune_cls_helper_einv DEFINITION
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
             success       TYPE string,
             ackno         TYPE string,
             ackdt         TYPE string,
             irn           TYPE string,
             signedinvoice TYPE string,
             signedqrcode  TYPE string,
             status        TYPE string,
             canceldate    TYPE string,
             errordetails  TYPE ty_t_error_details,
           END OF ty_govt_response.

    "--------------------------------------------------------
    " Main API Response (ClearTax / Govt combined response)
    "--------------------------------------------------------
    TYPES: BEGIN OF ty_response,

             document_status TYPE string,
             error_response  TYPE string,
             errors          TYPE string,
             govt_response   TYPE ty_govt_response,

           END OF ty_response.
    TYPES: ty_t_response TYPE STANDARD TABLE OF ty_response WITH DEFAULT KEY.

    "--------------------------------------------------------
    " METHODS

    " Build payload JSON for e-waybill generation
    METHODS build_einvoice_payload
      IMPORTING
        iv_docnum       TYPE string
        iv_documenttype TYPE string
        iv_fisyear      TYPE string
        iv_companycode  TYPE string

      RETURNING
        VALUE(rv_json)  TYPE string.

    "--------------------------------------------------------

    " Call API to generate e-Invoice
    METHODS generate_einvoie
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
    METHODS get_einvoice_response
      IMPORTING
        iv_json            TYPE string
      RETURNING
        VALUE(rv_response) TYPE ty_response.

    " Call API to cancel e-Invoice
    METHODS cancel_einvoice
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
    METHODS build_einvoice_payload_cancel
      IMPORTING
        iv_docnum        TYPE string
        iv_irnno         TYPE string
        iv_cancelrsncode TYPE string
        iv_cancelrmrk    TYPE string
      RETURNING
        VALUE(rv_json)   TYPE string.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZUNE_CLS_HELPER_EINV IMPLEMENTATION.


  METHOD generate_einvoie.

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
    DATA: lv_einvurl TYPE string VALUE '/einv/v2/eInvoice/generate', " Relative endpoint for eWaybill generation
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


  METHOD build_einvoice_payload.

    TYPES: BEGIN OF ty_attribdtls,
             nm  TYPE string,
             val TYPE string,
           END OF ty_attribdtls.

    TYPES: tt_attribdtls TYPE STANDARD TABLE OF ty_attribdtls WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bchdtls,
             nm    TYPE string,
             expdt TYPE string,
             wrdt  TYPE string,
           END OF ty_bchdtls.

    TYPES: BEGIN OF ty_itemlist,
             slno               TYPE i,
             prddesc            TYPE string,
             isservc            TYPE string,
             hsncd              TYPE string,
             barcde             TYPE string,
             qty                TYPE decfloat34,
             freeqty            TYPE decfloat34,
             unit               TYPE string,
             unitprice          TYPE decfloat34,
             totamt             TYPE decfloat34,
             discount           TYPE decfloat34,
             pretaxval          TYPE decfloat34,
             assamt             TYPE decfloat34,
             gstrt              TYPE decfloat34,
             igstamt            TYPE decfloat34,
             cgstamt            TYPE decfloat34,
             sgstamt            TYPE decfloat34,
             cesrt              TYPE decfloat34,
             cesamt             TYPE decfloat34,
             cesnonadvlamt      TYPE decfloat34,
             statecesrt         TYPE decfloat34,
             statecesamt        TYPE decfloat34,
             statecesnonadvlamt TYPE decfloat34,
             othchrg            TYPE decfloat34,
             totitemval         TYPE decfloat34,
             ordlineref         TYPE string,
             orgcntry           TYPE string,
             prdslno            TYPE string,
             bchdtls            TYPE ty_bchdtls,
             attribdtls         TYPE tt_attribdtls,
           END OF ty_itemlist.

    TYPES: tt_itemlist TYPE STANDARD TABLE OF ty_itemlist WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_trandtls,
             taxsch TYPE string,
             suptyp TYPE string,
           END OF ty_trandtls.

    TYPES: BEGIN OF ty_docdtls,
             typ TYPE string,
             no  TYPE string,
             dt  TYPE string,
           END OF ty_docdtls.

    TYPES: BEGIN OF ty_sellerdtls,
             gstin TYPE string,
             lglnm TYPE string,
             addr1 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_sellerdtls.

    TYPES: BEGIN OF ty_buyerdtls,
             gstin TYPE string,
             lglnm TYPE string,
             pos   TYPE string,
             addr1 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_buyerdtls.

    TYPES: BEGIN OF ty_dispdtls,
             nm    TYPE string,
             addr1 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_dispdtls.

    TYPES: BEGIN OF ty_shipdtls,
             lglnm TYPE string,
             addr1 TYPE string,
             loc   TYPE string,
             pin   TYPE i,
             stcd  TYPE string,
           END OF ty_shipdtls.

    TYPES: BEGIN OF ty_valdtls,
             assval      TYPE decfloat34,
             cgstval     TYPE decfloat34,
             sgstval     TYPE decfloat34,
             igstval     TYPE decfloat34,
             cesval      TYPE decfloat34,
             stcesval    TYPE decfloat34,
             discount    TYPE decfloat34,
             othchrg     TYPE decfloat34,
             rndoffamt   TYPE decfloat34,
             totinvval   TYPE decfloat34,
             totinvvalfc TYPE decfloat34,
           END OF ty_valdtls.

    TYPES: BEGIN OF ty_paydtls,
             nm       TYPE string,
             accdet   TYPE string,
             mode     TYPE string,
             fininsbr TYPE string,
             payterm  TYPE string,
             payinstr TYPE string,
             crtrn    TYPE string,
             dirdr    TYPE string,
             crday    TYPE i,
             paidamt  TYPE decfloat34,
             paymtdue TYPE decfloat34,
           END OF ty_paydtls.

    TYPES: BEGIN OF ty_docperddtls,
             invstdt  TYPE string,
             invenddt TYPE string,
           END OF ty_docperddtls.

    TYPES: BEGIN OF ty_precdocdtls,
             invno    TYPE string,
             invdt    TYPE string,
             othrefno TYPE string,
           END OF ty_precdocdtls.

    TYPES: tt_precdocdtls TYPE STANDARD TABLE OF ty_precdocdtls WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_contrdtls,
             recadvrefr TYPE string,
             recadvdt   TYPE string,
             tendrefr   TYPE string,
             contrrefr  TYPE string,
             extrefr    TYPE string,
             projrefr   TYPE string,
             porefr     TYPE string,
             porefdt    TYPE string,
           END OF ty_contrdtls.

    TYPES: tt_contrdtls TYPE STANDARD TABLE OF ty_contrdtls WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_refdtls,
             invrm       TYPE string,
             docperddtls TYPE ty_docperddtls,
             precdocdtls TYPE tt_precdocdtls,
             contrdtls   TYPE tt_contrdtls,
           END OF ty_refdtls.

    TYPES: BEGIN OF ty_addldocdtls,
             url  TYPE string,
             docs TYPE string,
             info TYPE string,
           END OF ty_addldocdtls.

    TYPES: tt_addldocdtls TYPE STANDARD TABLE OF ty_addldocdtls WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_expdtls,
             shipbno TYPE string,
             shipbdt TYPE string,
             port    TYPE string,
             refclm  TYPE string,
             forcur  TYPE string,
             cntcode TYPE string,
           END OF ty_expdtls.

    TYPES: BEGIN OF ty_ewbdtls,
             transid    TYPE string,
             transname  TYPE string,
             distance   TYPE decfloat34,
             transdocno TYPE string,
             transdocdt TYPE string,
             vehno      TYPE string,
             vehtype    TYPE string,
             transmode  TYPE string,
           END OF ty_ewbdtls.

    TYPES: BEGIN OF ty_transaction,
             version     TYPE string,
             trandtls    TYPE ty_trandtls,
             docdtls     TYPE ty_docdtls,
             sellerdtls  TYPE ty_sellerdtls,
             buyerdtls   TYPE ty_buyerdtls,
             dispdtls    TYPE ty_dispdtls,
             shipdtls    TYPE ty_shipdtls,
             itemlist    TYPE tt_itemlist,
             valdtls     TYPE ty_valdtls,
             paydtls     TYPE ty_paydtls,
             refdtls     TYPE ty_refdtls,
             addldocdtls TYPE tt_addldocdtls,
             expdtls     TYPE ty_expdtls,
             ewbdtls     TYPE ty_ewbdtls,
           END OF ty_transaction.

    TYPES: BEGIN OF ty_custom_fields,
             customfieldlable1 TYPE string,
             customfieldlable2 TYPE string,
             customfieldlable3 TYPE string,
           END OF ty_custom_fields.

    TYPES: BEGIN OF ty_invoice,
             transaction_id TYPE string,
             transaction    TYPE ty_transaction,
             custom_fields  TYPE ty_custom_fields,
           END OF ty_invoice.

    TYPES: tt_invoice TYPE STANDARD TABLE OF ty_invoice WITH DEFAULT KEY.

    DATA : lt_invoice     TYPE tt_invoice,
           ls_invoice     TYPE ty_invoice,
           ls_transaction TYPE ty_transaction,
           lt_itemlist    TYPE tt_itemlist.

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

*       Block 1
    ls_transaction-version = '1.1'.
    ls_transaction-trandtls-taxsch = 'GST'.
    ls_transaction-trandtls-suptyp = 'B2B'.
*       Block2

    ls_transaction-docdtls-typ = 'INV'.
    ls_transaction-docdtls-no = lv_docno.
    ls_transaction-docdtls-dt = lv_date_str.

*       *       SellerDetails
SELECT SINGLE * FROM zune_cds_seller_det WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO  @DATA(selleradd).

    ls_transaction-sellerdtls-gstin = selleradd-sellerGSTIN.
    ls_transaction-sellerdtls-lglnm = selleradd-lglnm.
    ls_transaction-sellerdtls-addr1 = selleradd-Addr1.
    ls_transaction-sellerdtls-loc = selleradd-Loc.
    ls_transaction-sellerdtls-pin = selleradd-Pin.
    ls_transaction-sellerdtls-stcd = selleradd-Stcd.

*    BuyerDetails
    " --- Buyer details ---

    " --- Expected shipping details ---

    SELECT SINGLE

       f~text AS statecode,d~bpcustomerfullname AS lglname,d~streetname AS addr1,d~cityname AS location,d~postalcode AS pin

       FROM  i_billingdocumentitem AS a
      LEFT OUTER JOIN i_outbounddelivery AS b ON a~referencesddocument = b~outbounddelivery
      LEFT OUTER JOIN i_outbounddeliverypartnertp  WITH PRIVILEGED ACCESS AS c ON c~outbounddelivery = b~outbounddelivery
      LEFT OUTER JOIN i_customer AS d ON c~customer = d~customer
      LEFT OUTER JOIN  i_address_2  AS e ON    c~addressid = e~addressid
      LEFT OUTER JOIN zune_cds_stategst WITH PRIVILEGED ACCESS AS f ON f~value_low = d~region
      WHERE a~billingdocument = @lv_docno  AND c~partnerfunction = 'WE'
      INTO  @DATA(expshippingadd).


    " --- Expected billing Details details ---
    SELECT SINGLE * FROM zune_cds_billbuyer WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO  @DATA(buyeradd).

    ls_transaction-buyerdtls-gstin = buyeradd-taxnumber3.
    ls_transaction-buyerdtls-lglnm = buyeradd-lglnm.
    ls_transaction-buyerdtls-addr1 = buyeradd-addr1.
    ls_transaction-buyerdtls-loc = buyeradd-loc.
    ls_transaction-buyerdtls-pin = buyeradd-pin.
    ls_transaction-buyerdtls-stcd = buyeradd-stcd.
    ls_transaction-buyerdtls-pos = expshippingadd-statecode.

*      DispatchDet

    " --- Dispatch details (plant address) ---

    SELECT SINGLE plant FROM i_billingdocumentitem WITH PRIVILEGED ACCESS AS a WHERE a~billingdocument = @lv_docno INTO @DATA(lv_plant).

    SELECT SINGLE
                  a~plantname AS plantname,b~streetname AS addr1,b~streetprefixname2 AS location,b~postalcode AS pincode,c~text AS statecode
    FROM i_plant AS a
    LEFT JOIN i_address_2 WITH PRIVILEGED ACCESS AS b ON ( a~addressid = b~addressid )
    LEFT OUTER JOIN zune_cds_stategst WITH PRIVILEGED ACCESS AS c ON c~value_low = b~region
    WHERE plant = @lv_plant INTO @DATA(sellerplantaddress).


    ls_transaction-dispdtls-nm = sellerplantaddress-plantname.
    ls_transaction-dispdtls-addr1 = sellerplantaddress-addr1.
    ls_transaction-dispdtls-loc = sellerplantaddress-location.
    ls_transaction-dispdtls-pin = sellerplantaddress-pincode.
    ls_transaction-dispdtls-stcd = sellerplantaddress-statecode.

*       Ship details

    ls_transaction-shipdtls-lglnm = expshippingadd-lglname.
    ls_transaction-shipdtls-addr1 = expshippingadd-addr1.
    ls_transaction-shipdtls-loc = expshippingadd-location.
    ls_transaction-shipdtls-pin = expshippingadd-pin..
    ls_transaction-shipdtls-stcd = expshippingadd-statecode.



*        Item List Details
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
    DATA: lv_discount  TYPE p LENGTH 16 DECIMALS 2.
    DATA : lv_count TYPE i VALUE 1.

    LOOP AT  billingdetails ASSIGNING FIELD-SYMBOL(<lv_billingdetails>).


      DATA : ls_itemlist TYPE ty_itemlist.

      ls_itemlist-slno = lv_count.
      ls_itemlist-isservc = 'N'.
      ls_itemlist-qty = <lv_billingdetails>-billingquantity.
      ls_itemlist-unit = <lv_billingdetails>-govunitcode.
      ls_itemlist-unitprice = <lv_billingdetails>-unitprice.
      ls_itemlist-totamt = <lv_billingdetails>-netamount.
      ls_itemlist-discount = <lv_billingdetails>-discountamount.
      ls_itemlist-assamt = <lv_billingdetails>-assamt.
      ls_itemlist-gstrt = COND #( WHEN <lv_billingdetails>-cgstrate <> '0.000' THEN <lv_billingdetails>-cgstrate
                                     WHEN <lv_billingdetails>-sgstrate <> '0.000' THEN <lv_billingdetails>-sgstrate
                                     WHEN <lv_billingdetails>-igstrate <> '0.000' THEN <lv_billingdetails>-igstrate
                                      ).
      ls_itemlist-igstamt = <lv_billingdetails>-igstamount.
      ls_itemlist-cgstamt = <lv_billingdetails>-cgstamount.
      ls_itemlist-sgstamt = <lv_billingdetails>-sgstamount.
      ls_itemlist-othchrg = ( <lv_billingdetails>-netamount - <lv_billingdetails>-assamt ) + <lv_billingdetails>-freightchargestax.
      ls_itemlist-totitemval = <lv_billingdetails>-assamt + <lv_billingdetails>-cgstamount + <lv_billingdetails>-sgstamount + <lv_billingdetails>-igstamount + <lv_billingdetails>-sgstamount.
      ls_itemlist-hsncd = <lv_billingdetails>-hsn.

*        //Consolidated SUM

      lv_totalinvoiceamount = lv_totalinvoiceamount + ls_itemlist-totitemval.
      lv_totalcgstamount = lv_totalcgstamount + ls_itemlist-cgstamt.
      lv_totalsgstamount = lv_totalsgstamount + ls_itemlist-sgstamt.
      lv_totaligstamount = lv_totaligstamount + ls_itemlist-igstamt.
      lv_totalcessamount = lv_totalcessamount + ls_itemlist-cesamt.
      lv_totalassessableamount = lv_totalassessableamount + ls_itemlist-assamt.
      lv_otheramount = lv_otheramount + ls_itemlist-othchrg.
      lv_discount = lv_discount + ls_itemlist-discount.

      APPEND ls_itemlist TO lt_itemlist.
      lv_count = lv_count + 1.

    ENDLOOP.

    DATA: lv_invoice_after_round  TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_invoice_before_round  TYPE p LENGTH 16 DECIMALS 2.
    DATA: lv_roundoff  TYPE p LENGTH 16 DECIMALS 2.
    lv_invoice_after_round = round( val = CONV decfloat34(  lv_totalinvoiceamount )
                                    dec = 0         "0 decimals
                                     ).   "Arithmetic rounding
lv_invoice_before_round = lv_totalinvoiceamount.
    "Round off = Rounded - Actual
    lv_roundoff = lv_invoice_after_round - lv_invoice_before_round.


    ls_transaction-valdtls-assval = lv_totalassessableamount.
    ls_transaction-valdtls-cgstval = lv_totalcgstamount.
    ls_transaction-valdtls-sgstval = lv_totalsgstamount.
    ls_transaction-valdtls-igstval = lv_totaligstamount.
    ls_transaction-valdtls-discount = lv_discount.
    ls_transaction-valdtls-othchrg = lv_otheramount.
    ls_transaction-valdtls-rndoffamt = lv_roundoff.
    ls_transaction-valdtls-totinvval = lv_totalinvoiceamount.
    ls_transaction-itemlist = lt_itemlist.

    ls_invoice-transaction = ls_transaction.
    APPEND ls_invoice TO lt_invoice.

    " --- JSON serialization mappings (ABAP → JSON field names) ---

    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings.


    "----------------------------------------------------------
    " Name mapping: ABAP field name → JSON property name
    "----------------------------------------------------------
    lt_name_map = VALUE #(

      "=== Root level ===
      ( abap = 'TRANSACTION_ID' json = 'transaction_id' )
      ( abap = 'TRANSACTION'    json = 'transaction' )
      ( abap = 'TRANDTLS'    json = 'TranDtls' )
      ( abap = 'DOCDTLS'    json = 'DocDtls' )
      ( abap = 'SELLERDTLS'    json = 'SellerDtls' )
      ( abap = 'BUYERDTLS'    json = 'BuyerDtls' )
      ( abap = 'DISPDTLS'    json = 'DispDtls' )
      ( abap = 'SHIPDTLS'    json = 'ShipDtls' )
      ( abap = 'ITEMLIST'    json = 'ItemList' )
      ( abap = 'ATTRIBDTLS'    json = 'AttribDtls' )
      ( abap = 'VALDTLS'    json = 'ValDtls' )
      ( abap = 'PAYDTLS'    json = 'PayDtls' )
      ( abap = 'REFDTLS'    json = 'RefDtls' )
      ( abap = 'PRECDOCDTLS'    json = 'PrecDocDtls' )
      ( abap = 'CONTRDTLS'    json = 'ContrDtls' )
      ( abap = 'EXPDTLS'    json = 'ExpDtls' )
      ( abap = 'EWBDTLS'    json = 'EwbDtls' )
      ( abap = 'CUSTOM_FIELDS'    json = 'Custom_Fields' )

      "=== Transaction section ===
      ( abap = 'VERSION'    json = 'Version' )

      "--- TranDtls ---
      ( abap = 'TAXSCH'    json = 'TaxSch' )
      ( abap = 'SUPTYP'     json = 'SupTyp' )

      "--- DocDtls ---
      ( abap = 'TYP'     json = 'Typ' )
      ( abap = 'NO'      json = 'No' )
      ( abap = 'DT'      json = 'Dt' )

      "--- SellerDtls ---
      ( abap = 'GSTIN'  json = 'Gstin' )
      ( abap = 'LGLNM'  json = 'LglNm' )
      ( abap = 'ADDR1'  json = 'Addr1' )
      ( abap = 'LOC'    json = 'Loc' )
      ( abap = 'PIN'    json = 'Pin' )
      ( abap = 'STCD'   json = 'Stcd' )

      "--- BuyerDtls ---

      ( abap = 'POS'     json = 'Pos' )


      "--- DispDtls ---
      ( abap = 'NM'       json = 'Nm' )


*
*
*  "=== ItemList ===
      ( abap = 'SLNO'           json = 'SlNo' )
      ( abap = 'BCHDTLS'           json = 'BchDtls' )
      ( abap = 'PRDDESC'        json = 'PrdDesc' )
      ( abap = 'ISSERVC'        json = 'IsServc' )
      ( abap = 'HSNCD'          json = 'HsnCd' )
      ( abap = 'BARCDE'         json = 'Barcde' )
      ( abap = 'QTY'            json = 'Qty' )
      ( abap = 'FREEQTY'        json = 'FreeQty' )
      ( abap = 'UNIT'           json = 'Unit' )
      ( abap = 'UNITPRICE'      json = 'UnitPrice' )
      ( abap = 'TOTAMT'         json = 'TotAmt' )
      ( abap = 'DISCOUNT'       json = 'Discount' )
      ( abap = 'PRETAXVAL'      json = 'PreTaxVal' )
      ( abap = 'ASSAMT'         json = 'AssAmt' )
      ( abap = 'GSTRT'          json = 'GstRt' )
      ( abap = 'IGSTAMT'        json = 'IgstAmt' )
      ( abap = 'CGSTAMT'        json = 'CgstAmt' )
      ( abap = 'SGSTAMT'        json = 'SgstAmt' )
      ( abap = 'CESRT'          json = 'CesRt' )
      ( abap = 'CESAMT'         json = 'CesAmt' )
      ( abap = 'CESNONADVLAMT'  json = 'CesNonAdvlAmt' )
      ( abap = 'STATECESRT'     json = 'StateCesRt' )
      ( abap = 'STATECESAMT'    json = 'StateCesAmt' )
      ( abap = 'STATECESNONADVLAMT' json = 'StateCesNonAdvlAmt' )
      ( abap = 'OTHCHRG'        json = 'OthChrg' )
      ( abap = 'TOTITEMVAL'     json = 'TotItemVal' )
      ( abap = 'ORDLINEREF'     json = 'OrdLineRef' )
      ( abap = 'ORGCNTRY'       json = 'OrgCntry' )
      ( abap = 'PRDSLNO'        json = 'PrdSlNo' )
*
*  "--- BchDtls ---
*
      ( abap = 'EXPDT'       json = 'ExpDt' )
      ( abap = 'WRDT'        json = 'WrDt' )
*
*  "--- AttribDtls ---
*
      ( abap = 'VAL'      json = 'Val' )
*
*  "=== ValDtls ===
      ( abap = 'ASSVAL'         json = 'AssVal' )
      ( abap = 'CGSTVAL'        json = 'CgstVal' )
      ( abap = 'SGSTVAL'        json = 'SgstVal' )
      ( abap = 'IGSTVAL'        json = 'IgstVal' )
      ( abap = 'CESVAL'         json = 'CesVal' )
      ( abap = 'STCESVAL'       json = 'StCesVal' )
      ( abap = 'RNDOFFAMT'      json = 'RndOffAmt' )
      ( abap = 'TOTINVVAL'      json = 'TotInvVal' )
      ( abap = 'TOTINVVALFC'    json = 'TotInvValFc' )
*
*  "=== PayDtls ===
*
      ( abap = 'ACCDET'         json = 'AccDet' )
      ( abap = 'MODE'           json = 'Mode' )
      ( abap = 'FININSBR'       json = 'FinInsBr' )
      ( abap = 'PAYTERM'        json = 'PayTerm' )
      ( abap = 'PAYINSTR'       json = 'PayInstr' )
      ( abap = 'CRTRN'          json = 'CrTrn' )
      ( abap = 'DIRDR'          json = 'DirDr' )
      ( abap = 'CRDAY'          json = 'CrDay' )
      ( abap = 'PAIDAMT'        json = 'PaidAmt' )
      ( abap = 'PAYMTDUE'       json = 'PaymtDue' )
*
*  "=== RefDtls ===
      ( abap = 'INVRM'          json = 'InvRm' )
      ( abap = 'INVSTDT'        json = 'InvStDt' )
      ( abap = 'INVENDDT'       json = 'InvEndDt' )
      ( abap = 'INVNO'          json = 'InvNo' )
      ( abap = 'INVDT'          json = 'InvDt' )
      ( abap = 'OTHREFNO'       json = 'OthRefNo' )
      ( abap = 'RECADVREFR'     json = 'RecAdvRefr' )
      ( abap = 'RECADVDT'       json = 'RecAdvDt' )
      ( abap = 'TENDREFR'       json = 'TendRefr' )
      ( abap = 'CONTRREFR'      json = 'ContrRefr' )
      ( abap = 'EXTREFR'        json = 'ExtRefr' )
      ( abap = 'PROJREFR'       json = 'ProjRefr' )
      ( abap = 'POREFR'         json = 'PORefr' )
      ( abap = 'POREFDT'        json = 'PORefDt' )
*
*  "=== AddlDocDtls ===
      ( abap = 'URL'            json = 'Url' )
      ( abap = 'DOCS'           json = 'Docs' )
      ( abap = 'INFO'           json = 'Info' )
*
*  "=== ExpDtls ===
      ( abap = 'SHIPBNO'        json = 'ShipBNo' )
      ( abap = 'SHIPBDT'        json = 'ShipBDt' )
      ( abap = 'PORT'           json = 'Port' )
      ( abap = 'REFCLM'         json = 'RefClm' )
      ( abap = 'FORCUR'         json = 'ForCur' )
      ( abap = 'CNTCODE'        json = 'CntCode' )
*
*  "=== EwbDtls ===
      ( abap = 'TRANSID'        json = 'TransId' )
      ( abap = 'TRANSNAME'      json = 'TransName' )
      ( abap = 'DISTANCE'       json = 'Distance' )
      ( abap = 'TRANSDOCNO'     json = 'TransDocNo' )
      ( abap = 'TRANSDOCDT'     json = 'TransDocDt' )
      ( abap = 'VEHNO'          json = 'VehNo' )
      ( abap = 'VEHTYPE'        json = 'VehType' )
      ( abap = 'TRANSMODE'      json = 'TransMode' )
*
*  "=== Custom Fields ===
      ( abap = 'CUSTOMFIELDLABLE1' json = 'customfieldLable1' )
      ( abap = 'CUSTOMFIELDLABLE2' json = 'customfieldLable2' )
      ( abap = 'CUSTOMFIELDLABLE3' json = 'customfieldLable3' )
    ).

    "----------------------------------------------------------
    " Usage example (serialize structure to JSON string)
    "----------------------------------------------------------

    rv_json = /ui2/cl_json=>serialize(
                 data          = lt_invoice
                name_mappings = lt_name_map
                 pretty_name   = /ui2/cl_json=>pretty_mode-none
               ).


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


  METHOD get_einvoice_response.
    TRY.


        DATA: lt_response TYPE ty_t_response.
        /ui2/cl_json=>deserialize(
          EXPORTING
            json        = iv_json
            pretty_name = /ui2/cl_json=>pretty_mode-none
          CHANGING
            data        = lt_response
        ).
        "--------------------------------------------------------
        " Pick the first record from response array
        "--------------------------------------------------------
        READ TABLE lt_response INTO rv_response INDEX 1.
      CATCH cx_root INTO DATA(lx).
        DATA(a) = lx.
*        RAISE EXCEPTION NEW cx_static_check(
*          textid   = cx_static_check=>others
*          previous = lx
*        ).
    ENDTRY.
  ENDMETHOD.


  METHOD cancel_einvoice.
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
    DATA: lv_einvurl TYPE string VALUE '/einv/v2/eInvoice/cancel', " Endpoint for cancel API
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
    lo_resp     = lo_client->execute( if_web_http_client=>put ).
    " Extract response text into return variable
    rv_response = lo_resp->get_text( ).
    " Close client connection
    lo_client->close( ).


  ENDMETHOD.


  METHOD build_einvoice_payload_cancel.
    " Define structure for eWaybill cancel request
    TYPES: BEGIN OF ty_einvoice_cancel,
             irn    TYPE string,
             cnlrsn TYPE string,
             cnlrem TYPE string,
           END OF ty_einvoice_cancel.

    TYPES: tt_einvoice_cancel TYPE STANDARD TABLE OF ty_einvoice_cancel WITH DEFAULT KEY.
    " Fill payload with input values
    DATA:lt_payload TYPE tt_einvoice_cancel.
    DATA :  ls_payload TYPE ty_einvoice_cancel.
    ls_payload-irn = iv_irnno.
    ls_payload-cnlrsn = iv_cancelrsncode.
    ls_payload-cnlrem = iv_cancelrmrk.

    APPEND ls_payload TO lt_payload.
    " JSON field mapping
    DATA: lt_name_map TYPE /ui2/cl_json=>name_mappings,
          lv_json     TYPE string.
    lt_name_map = VALUE #(
      ( abap = 'IRN'   json = 'irn' )
      ( abap = 'CNLRSN'   json = 'CnlRsn' )
       ( abap = 'CNLREM'   json = 'CnlRem' )
       ).
    " Serialize with mapping
    rv_json = /ui2/cl_json=>serialize(
                 data          = lt_payload
                 name_mappings = lt_name_map
                 pretty_name   = /ui2/cl_json=>pretty_mode-none ).
  ENDMETHOD.
ENDCLASS.
