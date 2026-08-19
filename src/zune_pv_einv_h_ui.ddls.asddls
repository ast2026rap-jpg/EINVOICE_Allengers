@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Doc IRN EWAY Header-Projection View API'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZUNE_PV_EINV_H_UI provider contract transactional_query as projection on ZUNE_RV_EINV_H
{
 @EndUserText.label: 'SAP Id'
    key Sapid,
     @EndUserText.label: 'Company Code'
    Companycode,
     @EndUserText.label: 'Billing Document No.'
    Billingdocnum,
     @EndUserText.label: 'Fiscal Year'
    Fiscalyear,
     @EndUserText.label: 'Document Type'
    Documnenttype,
     @EndUserText.label: 'Business Place'
    Businessplace,
     @EndUserText.label: 'IRN No.'
    Irnno,
     @EndUserText.label: 'IRN Status'
    Irnstatus,
     @EndUserText.label: 'IRN QR'
    Irnqr,
     @EndUserText.label: 'IRN QR Extended'
    Irnqrpartb,
     @EndUserText.label: 'Acknowledge No.'
    Acknowledgeno,
     @EndUserText.label: 'Acknowledge Date'
    Acknowledgedate,
     @EndUserText.label: 'IRN Generate Date'
    Irngeneratedate,
     @EndUserText.label: 'IRN Cancel Date'
    Irncanceldate,
     @EndUserText.label:'IRN Remarks'
    Irnremarks,
    @EndUserText.label:'IRN Can Resion Code'
    irncanrsncode,
     @EndUserText.label: 'Eway Bill No.'
    Ewaybillno,
     @EndUserText.label: 'Eway Bill Date'
    Ewaybilldate,
     @EndUserText.label: 'Eway Bill Valid To'
    Ewaybillvalidto,
     @EndUserText.label: 'Validity End Date'
    Validityendsat,
     @EndUserText.label: 'Eway Bill Status'
    Ewaybillstatus,
     @EndUserText.label: 'Eway Bill Cancel Reason Code'
    Ewaybillcanreasoncode,
     @EndUserText.label: 'Eway Bill Cancel Remarks'
    Ewaybillcancelremarks,
     @EndUserText.label: 'Eway Bill Cancel Date'
    Ewaybillcanceldate,
     @EndUserText.label: 'Trasnporter ID'
    Transporterid,
     @EndUserText.label: 'Transport Document No.'
    Transportdocumentnumber,
     @EndUserText.label: 'Transport Document Date'
    Transportdocumentdate,
     @EndUserText.label: 'Transport Distance(KM)'
    Transportdistanceinkm,
     @EndUserText.label: 'Vehicle Number'
    Vehiclenumber,
     @EndUserText.label: 'Vehicle Type'
    Vehicletype,
     @EndUserText.label: 'Mode Of Transport'
    Modeoftransport,
     @EndUserText.label: 'Transporter Name'
    Transportername,
     @EndUserText.label: 'Transporter GSTIN No.'
    Transportergstinnumber,
    @EndUserText.label: 'Transaction Type.'
    transactiontype,
    @EndUserText.label: 'Eway Bill Expiration Date'
    ewaybillexirationdate,
    @EndUserText.label: 'Reference No.'
    refrenceno,
    @EndUserText.label: 'Place'
    place,
    @EndUserText.label: 'State GST Code'
    stategstcode,
    @EndUserText.label: 'Country for Export'
    countryforexp,
    @EndUserText.label: 'Docket No.'
    docketnumber,
    @EndUserText.label: 'Update Reason'
    updatereason,
    @EndUserText.label: 'Update Remark'
    updateremark,
    @EndUserText.label: 'Updated Date'
    upadtedate,
         @Semantics.largeObject:{mimeType: 'MimeType',fileName: 'FileName',contentDispositionPreference: #INLINE}
     @EndUserText.label: 'Eway Bill PDF'
    Ewaypdfattach,
     @EndUserText.label: 'File Name'
    FileName,
    @EndUserText.label: 'Port No.'
     portno,
    @EndUserText.label: 'Mime Type'
    MimeType,
     @EndUserText.label: 'Posting Json'
    Postingjson,
     @EndUserText.label: 'Response Json'
    Resposnsejson,
     @EndUserText.label: 'Supply Type'
    supplytype,
     @EndUserText.label: 'Created By'
    @Semantics.user.createdBy: true
    Createdby,
     @EndUserText.label: 'Created At'
    @Semantics.systemDateTime.createdAt: true
    Createdat,
     @EndUserText.label: 'Last Change By'
    @Semantics.user.lastChangedBy: true
    Lastchangedby,
     @EndUserText.label: 'Last Change At'
    @Semantics.systemDateTime.lastChangedAt: true
    Lastchangeat
}
