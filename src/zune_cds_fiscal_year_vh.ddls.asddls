@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Fiscal Year'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_FISCAL_YEAR_VH as select from I_FiscalYearForCompanyCode
{
    
   key FiscalYear,
   key CompanyCode
}
where FiscalYear>'2024' 
