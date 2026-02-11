@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UOM Master-Interface View'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_IV_UOM_H as select from zune_dt_uom_h
{
    key sapid as Sapid,
    govunitcode as Govunitcode,
    govunitcodename as Govunitcodename,
    sapunitcode as Sapunitcode,
     @Semantics.user.createdBy: true
    createdby as Createdby,
     @Semantics.systemDateTime.createdAt: true
    createdat as Createdat,
     @Semantics.user.lastChangedBy: true
    lastchangedby as Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    lastchangeat as Lastchangeat
}
