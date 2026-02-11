@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Partner Buyer Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_BILLBUYER as 
select 
from I_BillingDocumentPartner as a
left outer join I_Customer as b on a.Customer=b.Customer
left outer join  I_Address_2  as c on    c.AddressID = a.AddressID
left outer join I_AddrCurDfltMobilePhoneNumber as d on  d.AddressID = a.AddressID  
{
    key a.BillingDocument,
    a.Customer,
   b.TaxNumber3,
  concat_with_space( concat_with_space( concat_with_space(c.OrganizationName1, c.OrganizationName2, 1),c.OrganizationName3,1),c.OrganizationName4,1) as lglnm,
  concat_with_space( concat_with_space( concat_with_space(c.OrganizationName1, c.OrganizationName2, 1),c.OrganizationName3,1),c.OrganizationName4,1) as trdnm,
  concat_with_space( concat_with_space( concat_with_space(c.OrganizationName1, c.OrganizationName2, 1),c.OrganizationName3,1),c.OrganizationName4,1) as Addr1,
    '' as addr2 ,
     c.CityName as loc,
     c.PostalCode as pin,
     substring( b.TaxNumber3,1,2) as stcd
    
    
}
where a.PartnerFunction='RE'
