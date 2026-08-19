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
inner  join ZUNE_IV_EINVCONF as b on a.SalesOrganization=b.salesorganization and a.CompanyCode=b.companycode
{
   key a.BillingDocument,
    b.salesorganization,
   b.Gstin as sellerGSTIN,
b.lglnm as lglnm,
 b.addr1 as Addr1,
  b.loc as Loc,
  b.pin as Pin, 
    b.stcd as Stcd     
         
}
union 
select  from I_BillingDocumentItem as a
inner join ZUNE_IV_EINVCONF as b on a.Plant=b.plant and a.CompanyCode=b.companycode
{
   key a.BillingDocument,
    b.plant as SalesOrganization,
   b.Gstin as sellerGSTIN,
b.lglnm as lglnm,
 b.addr1 as Addr1,
  b.loc as Loc,
  b.pin as Pin, 
    b.stcd as Stcd     
         
} 

