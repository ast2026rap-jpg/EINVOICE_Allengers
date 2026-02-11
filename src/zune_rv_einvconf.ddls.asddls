@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EInvoice Configuration Header-Root View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZUNE_RV_EINVCONF as select from ZUNE_IV_EINVCONF

{
    key Sapid,
    Serviceprovider,
    Einvoicebaseurl,
    Cleartaxauthtoken,
    Gstin,
    @Semantics.user.createdBy: true
    Createdby,
    @Semantics.systemDateTime.createdAt: true
    Createdat,
     @Semantics.user.lastChangedBy: true
    Lastchangedby,
     @Semantics.systemDateTime.localInstanceLastChangedAt: true
    Lastchangeat
}
