@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EWB Sub Type Header-Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_IV_EWBST_H as select from zune_dt_ewbst_h
{
    key sapid as Sapid,
    ewbsubtype as Ewbsubtype,
    ewbtrtype as Ewbtrtype,
     @Semantics.user.createdBy: true
    createdby as Createdby,
     @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
     @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangeat as Lastchangeat
}
