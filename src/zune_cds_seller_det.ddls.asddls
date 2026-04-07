@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Seller Details-CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_SELLER_DET as 
select from I_BillingDocument as a
left outer join I_SalesOrganization as b on a.SalesOrganization=b.SalesOrganization and a.CompanyCode=b.CompanyCode
left outer join I_Address_2 as c on b.AddressID=c.AddressID
{
   key a.BillingDocument,
    a.SalesOrganization,
    case when a.SalesOrganization='80S0' then '04AAFCD5862R021' 
         when a.SalesOrganization='90S0' then '04AAFCD5862R021'  else '' end as sellerGSTIN,
    case when a.SalesOrganization='80S0' then 'H.B.NO.201, MUKANDPUR, DERABASSI, DISTT. MOHALI(PB.)' 
         when a.SalesOrganization='90S0' then 'BHANKARPUR, MUBARKPUR ROAD DERABASSI, DISTT. MOHALI (PB) DERABASSI'  else '' end as lglnm,
    case when a.SalesOrganization='80S0' then 'H.B.NO.201, MUKANDPUR, DERABASSI, DISTT. MOHALI(PB.)' 
         when a.SalesOrganization='90S0' then 'BHANKARPUR, MUBARKPUR ROAD DERABASSI, DISTT. MOHALI (PB) DERABASSI'  else '' end as Addr1,
   c.CityName as Loc,
  '160017' as Pin, 
     case when a.SalesOrganization='80S0' then '04' 
         when a.SalesOrganization='90S0' then '04'  else '  ' end as Stcd     
         
}
