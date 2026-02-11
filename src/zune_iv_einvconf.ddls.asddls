@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EInvoice Configuration Header-Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_IV_EINVCONF as select from zune_dt_einvconf
{
    key sapid as Sapid,
    serviceprovider as Serviceprovider,
    einvoicebaseurl as Einvoicebaseurl,
    cleartaxauthtoken as Cleartaxauthtoken,
    gstin as Gstin,
     @Semantics.user.createdBy: true
    createdby as Createdby,
     @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
     @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangeat as Lastchangeat
}
