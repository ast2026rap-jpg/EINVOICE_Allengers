@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EWB Sub Type Header-Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZUNE_PV_EWBST_H provider contract transactional_query as projection on ZUNE_RV_EWBST_H
{
 @EndUserText.label: 'SAP Id'
    key Sapid,
  @EndUserText.label: 'EWB Sub Type'
   Ewbsubtype,
   @EndUserText.label: 'EWB Transaction Type'
    Ewbtrtype,
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
    Lastchangeat,
    _ZUNE_CDS_EWAYSUBTYPE_VH,
    _ZUNE_CDS_EWAYTRANSTYPE_VH
   // _ZUNE_CDS_EWAYSUBTYPE_VH-text as EwbsubtypeText
    
}
