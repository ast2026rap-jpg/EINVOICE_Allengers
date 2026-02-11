@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Doc IRN EWAY Header-Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_IV_EINV_H as select from zune_dt_einv_h
{
    key sapid as Sapid,
    companycode as Companycode,
    billingdocnum as Billingdocnum,
    fiscalyear as Fiscalyear,
    documnenttype as Documnenttype,
    businessplace as Businessplace,
    irnno as Irnno,
    irnstatus as Irnstatus,
    irnqr as Irnqr,
    acknowledgeno as Acknowledgeno,
    acknowledgedate as Acknowledgedate,
    irngeneratedate as Irngeneratedate,
    irncanceldate as Irncanceldate,
    irnremarks as Irnremarks,
    irncanrsncode as irncanrsncode, 
    ewaybillno as Ewaybillno,
    ewaybilldate as Ewaybilldate,
    ewaybillvalidto as Ewaybillvalidto,
    validityendsat as Validityendsat,
    ewaybillstatus as Ewaybillstatus,
    ewaybillcanreasoncode as Ewaybillcanreasoncode,
    ewaybillcancelremarks as Ewaybillcancelremarks,
    ewaybillcanceldate as Ewaybillcanceldate,
    transporterid as Transporterid,
    transportdocumentnumber as Transportdocumentnumber,
    transportdocumentdate as Transportdocumentdate,
    transportdistanceinkm as Transportdistanceinkm,
    vehiclenumber as Vehiclenumber,
    vehicletype as Vehicletype,
    modeoftransport as Modeoftransport,
    transportername as Transportername,
    transportergstinnumber as Transportergstinnumber,
    postingjson as Postingjson,
    resposnsejson as Resposnsejson,
    @Semantics.user.createdBy: true
    createdby as Createdby,
    @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
    @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
    @Semantics.systemDateTime.lastChangedAt: true
    lastchangeat as Lastchangeat
}
