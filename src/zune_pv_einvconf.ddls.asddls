@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'EInvoice Configuration Header-Projection View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZUNE_PV_EINVCONF
  provider contract transactional_query
  as projection on ZUNE_RV_EINVCONF
{
      @EndUserText.label: 'SAP Id'
  key Sapid,
      @EndUserText.label: 'Service Provider'
      Serviceprovider,
      @EndUserText.label: 'EInvoice Base URL'
      Einvoicebaseurl,
      @EndUserText.label: 'Cleartax Authtoken'
      Cleartaxauthtoken,
      @EndUserText.label: 'GSTIN'
      Gstin,
      @EndUserText.label: 'Sales Organization'
      salesorganization,
      @EndUserText.label: 'Company Code'
      companycode,
      @EndUserText.label: 'Plant'
      plant,
      @EndUserText.label: 'Legal Name'
      lglnm,
      @EndUserText.label: 'Addr1'
      addr1,
      @EndUserText.label: 'Location'
      loc,
      @EndUserText.label: 'Pin'
      pin,
      @EndUserText.label: 'State Code'
      stcd,
      @EndUserText.label: 'Created By'
      @Semantics.user.createdBy: true
      Createdby,
      @Semantics.systemDateTime.createdAt: true
      @EndUserText.label: 'Created At'
      Createdat,
      @Semantics.user.lastChangedBy: true
      @EndUserText.label: 'Last Change By'
      Lastchangedby,
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      @EndUserText.label: 'Last Change At'
      Lastchangeat
}
