@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Document Number-Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_BILL_DOC_NUM_VH as 
select from I_BillingDocument  as a
{
  key  a.BillingDocument,
  key  a.BillingDocumentType,
  key  a.FiscalYear,
   key a.CompanyCode
}
where (a.BillingDocumentType = 'F8' or a.BillingDocumentType = 'JSTO') and a.BillingDocumentIsCancelled <>'X'
