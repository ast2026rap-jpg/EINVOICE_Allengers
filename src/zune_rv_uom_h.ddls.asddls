@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UOM Master-Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZUNE_RV_UOM_H as select from ZUNE_IV_UOM_H
{
    key Sapid,
    Govunitcode,
    Govunitcodename,
    Sapunitcode,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdat,
    @Semantics.user.lastChangedBy: true
    Lastchangedby,
    @Semantics.systemDateTime.lastChangedAt: true
    Lastchangeat
}
