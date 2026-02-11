@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'UOM Master-Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZUNE_PV_UOM_H provider contract transactional_query as projection on ZUNE_RV_UOM_H
{
    @EndUserText.label: 'SAP ID'
    key Sapid,
    @EndUserText.label: 'Gov UOM Code'
    Govunitcode,
    @EndUserText.label: 'Gov UOM Code Name'
    Govunitcodename,
    @EndUserText.label: 'SAP UOM Code'
    Sapunitcode,
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
