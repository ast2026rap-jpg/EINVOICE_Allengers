@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EWB Sub Type Header-Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZUNE_RV_EWBST_H as select from ZUNE_IV_EWBST_H
association [0..1] to ZUNE_CDS_EWAYSUBTYPE_VH as _ZUNE_CDS_EWAYSUBTYPE_VH on ZUNE_IV_EWBST_H.Ewbsubtype = _ZUNE_CDS_EWAYSUBTYPE_VH.value_low
association [0..1] to ZUNE_CDS_EWAYTRANSTYPE_VH as _ZUNE_CDS_EWAYTRANSTYPE_VH on ZUNE_IV_EWBST_H.Ewbtrtype = _ZUNE_CDS_EWAYTRANSTYPE_VH.value_low
{
    key Sapid,
    Ewbsubtype,
    Ewbtrtype,
   @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdat,
   @Semantics.user.lastChangedBy: true
    Lastchangedby,
    @Semantics.systemDateTime.lastChangedAt: true
    Lastchangeat,
    _ZUNE_CDS_EWAYSUBTYPE_VH,
    _ZUNE_CDS_EWAYTRANSTYPE_VH
}
