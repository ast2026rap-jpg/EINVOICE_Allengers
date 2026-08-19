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
select distinct from I_BillingDocument  as a left outer join I_BillingDocumentItem as b on a.BillingDocument = b.BillingDocument
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
where (a.BillingDocumentType = 'F8'  or a.BillingDocumentType = 'F2') 
and b.YY1_IRNNo_BDI is  initial  
and a.BillingDocumentIsCancelled <>'X'
and a.AccountingPostingStatus <> 'A'

