@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Eway BILL- Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZUNE_PV_EWAYBILL provider contract transactional_query as projection on ZUNE_RV_EWAYBILL
{
  @EndUserText.label: 'SAP Id'
    key Sapid,
    @EndUserText.label: 'Supply Type'
    Supplytype,
    @EndUserText.label: 'Sub SupplyTyp'
    Subtype,
    @EndUserText.label: 'Sub Supply Type Desc'
    Subsupplytypedesc,
    @EndUserText.label: 'Document Type'
    Documenttype,
    @EndUserText.label: 'Document No'
    Documentno,
    @EndUserText.label: 'Fiscal Year'
    Fiscalyera,
    @EndUserText.label: 'Company Code'
    Comapnycode,
    @EndUserText.label: 'Transaction Type'
    Transactiontype,
    @EndUserText.label: 'Eway Bill No.'
    Ewaybillno,
    @EndUserText.label: 'Eway Bill Date'
    Ewaybilldate,
    @EndUserText.label: 'Eway Bill Expiration Date'
    Ewaybillexirationdate,
    @EndUserText.label: 'Eway Cancellation Date'
    Ewaycancellationdate,
    @EndUserText.label: 'Cancellation Reason'
    Cancellationresion,
    @EndUserText.label: 'Cancel Remark'
    Cancelremark,
    @EndUserText.label:'Update Reason'
    Updatereason,
    @EndUserText.label: 'Update Remark'
    Updateremark,
    @EndUserText.label: 'Update Date'
    Upadtedate,
    @EndUserText.label: 'Transporter Code'
    Transportercode,
    @EndUserText.label: 'Transporter Name'
    Transportername,
    @EndUserText.label: 'Transporter ID'
    Transporterid,
    @EndUserText.label: 'Transport Mode'
    Trmode,
    @EndUserText.label: 'Vehicle Type'
    Vehicletype,
    @EndUserText.label: 'Vehicle No.'
    Vehicleno,
    @EndUserText.label: 'Distance(In KM)'
    Distance,
    @EndUserText.label: 'Transporter Doc. No.'
    Transporterdocno,
    @EndUserText.label: 'Transporter Doc. Date'
    Transporterdocdate,
    @EndUserText.label: 'State GST Code'
    Stategstcode,
    @EndUserText.label: 'Place'
    Place,
    @EndUserText.label: 'ZIP Code'
    Zipcode,
    @EndUserText.label: 'Posting Json'
    Postingbody,
    @EndUserText.label: 'Posting Response Error'
    Postingerrorresponse,
    @EndUserText.label: 'Refrence No.'
    Refrenceno,
    @Semantics.largeObject:{mimeType: 'MimeType',fileName: 'FileName',contentDispositionPreference: #INLINE}
     @EndUserText.label: 'Eway Bill PDF'
    Ewaypdfattach,
     @EndUserText.label: 'File Name'
    FileName,
    @EndUserText.label: 'Mime Type'
    MimeType,
    @EndUserText.label: 'Created By'
     @Semantics.user.createdBy: true
    Createdby as Createdby,
    @EndUserText.label: 'Created At'
     @Semantics.systemDateTime.createdAt: true
    Createdat as Createdat,
    @EndUserText.label: 'Last Change By'
     @Semantics.user.lastChangedBy: true
    Lastchangedby as Lastchangedby,
    @EndUserText.label: 'Last Change At'
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    Lastchangeat as Lastchangeat
    
}
