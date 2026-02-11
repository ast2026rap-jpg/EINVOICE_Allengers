@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Eway BILL- Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZUNE_RV_EWAYBILL as select from ZUNE_IV_EWAYBILL

{
    key Sapid,
    Supplytype,
    Subtype,
    Subsupplytypedesc,
    Documenttype,
    Documentno,
    Fiscalyera,
    Comapnycode,
    Transactiontype,
    Ewaybillno,
    Ewaybilldate,
    Ewaybillexirationdate,
    Ewaycancellationdate,
    Cancellationresion,
    Cancelremark,
    Updatereason,
    Updateremark,
    Upadtedate,
    Transportercode,
    Transportername,
    Transporterid,
    Trmode,
    Vehicletype,
    Vehicleno,
    Distance,
    Transporterdocno,
    Transporterdocdate,
    Stategstcode,
    Place,
    Zipcode,
    Postingbody,
    Postingerrorresponse,
    Refrenceno,
    Ewaypdfattach,
    MimeType,
    FileName,
     @Semantics.user.createdBy: true
    Createdby as Createdby,
     @Semantics.systemDateTime.createdAt: true
    Createdat as Createdat,
     @Semantics.user.lastChangedBy: true
    Lastchangedby as Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    Lastchangeat as Lastchangeat
    
}
