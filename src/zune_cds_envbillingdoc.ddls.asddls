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
  key a.CompanyCode,
   key case when a.YY1_TransportMode_BDH = '01' then '1' 
       when a.YY1_TransportMode_BDH = '02' then '2' 
       when a.YY1_TransportMode_BDH = '05' then '3'
       when a.YY1_TransportMode_BDH = '04' then '4' else ' 'end as TransportMode,
  key a.YY1_Transportname_BDH as TransporterName,
  key a.YY1_VehicleNumber1_BDH as VehicleNo,
  key a.YY1_DocketNumber_BDH as DocketNumber
    
}
where (a.BillingDocumentType = 'F2' or a.BillingDocumentType = 'CBD2' or a.BillingDocumentType = 'L2' 
or a.BillingDocumentType = 'G2' or a.BillingDocumentType = 'JSTO') and a.BillingDocumentIsCancelled <>'X'
and a.AccountingPostingStatus <> 'A'
