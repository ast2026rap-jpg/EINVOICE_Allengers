@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Document for Invoice'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_ENVBillingDoc as 
select from I_BillingDocument  as a
{
  key  a.BillingDocument,
  key  a.BillingDocumentType,
  key  a.FiscalYear,
  key a.CompanyCode
    
}
where (a.BillingDocumentType = 'F2' or a.BillingDocumentType = 'CBD2' or a.BillingDocumentType = 'L2' or a.BillingDocumentType = 'G2') and a.BillingDocumentIsCancelled <>'X'
