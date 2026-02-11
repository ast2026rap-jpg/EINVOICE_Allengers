@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Doc IRN EWAY Header-Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZUNE_RV_EINV_H as select from ZUNE_IV_EINV_H
{
    key Sapid,
    Companycode,
    Billingdocnum,
    Fiscalyear,
    Documnenttype,
    Businessplace,
    Irnno,
    Irnstatus,
    Irnqr,
    Acknowledgeno,
    Acknowledgedate,
    Irngeneratedate,
    Irncanceldate,
    Irnremarks,
    irncanrsncode,
    Ewaybillno,
    Ewaybilldate,
    Ewaybillvalidto,
    Validityendsat,
    Ewaybillstatus,
    Ewaybillcanreasoncode,
    Ewaybillcancelremarks,
    Ewaybillcanceldate,
    Transporterid,
    Transportdocumentnumber,
    Transportdocumentdate,
    Transportdistanceinkm,
    Vehiclenumber,
    Vehicletype,
    Modeoftransport,
    Transportername,
    Transportergstinnumber,
    Postingjson,
    Resposnsejson,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdat,
    @Semantics.user.lastChangedBy: true
    Lastchangedby,
    @Semantics.systemDateTime.lastChangedAt: true
    Lastchangeat
}
