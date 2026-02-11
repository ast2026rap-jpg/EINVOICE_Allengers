@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Eway BILL- Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_IV_EWAYBILL as select from zune_dt_ewaybill
{
   key sapid as Sapid,
    supplytype as Supplytype,
    subtype as Subtype,
    subsupplytypedesc as Subsupplytypedesc,
    documenttype as Documenttype,
    documentno as Documentno,
    fiscalyera as Fiscalyera,
    comapnycode as Comapnycode,
    transactiontype as Transactiontype,
    ewaybillno as Ewaybillno,
    ewaybilldate as Ewaybilldate,
    ewaybillexirationdate as Ewaybillexirationdate,
    ewaycancellationdate as Ewaycancellationdate,
    cancellationresion as Cancellationresion,
    cancelremark as Cancelremark,
    updatereason as Updatereason,
    updateremark as Updateremark,
    upadtedate as Upadtedate,
    transportercode as Transportercode,
    transportername as Transportername,
    transporterid as Transporterid,
    trmode as Trmode,
    vehicletype as Vehicletype,
    vehicleno as Vehicleno,
    distance as Distance,
    transporterdocno as Transporterdocno,
    transporterdocdate as Transporterdocdate,
    stategstcode as Stategstcode,
    place as Place,
    zipcode as Zipcode,
    postingbody as Postingbody,
    postingerrorresponse as Postingerrorresponse,
    refrenceno as Refrenceno,
    ewaypdfattach as Ewaypdfattach,
    mimetype as MimeType,
    filename as FileName,
    @Semantics.user.createdBy: true
    createdby as Createdby,
     @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
     @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangeat as Lastchangeat
    
}
