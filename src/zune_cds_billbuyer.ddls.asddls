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
left outer join I_BusinessPartner as b on a.Customer=b.BusinessPartner
left outer join  I_Address_2  as c on    c.AddressID = a.AddressID
left outer join I_AddrCurDfltMobilePhoneNumber as d on  d.AddressID = a.AddressID  
/* NEW JOIN: State GST Mapping */
  left outer join ZUNE_CDS_STATEGST as b2
    on c.Region = b2.value_low

left outer join I_BusPartAddrDepdntTaxNmbr as e on a.Customer = e.BusinessPartner and a.AddressID = e.BusinessPartnerAddressID
{
    key a.BillingDocument,
    a.Customer,
   //b.TaxNumber3,
   e.BPTaxNumber as TaxNumber3,
  //b.YY1_BPFullName_bus as lglnm,
  concat_with_space(
               concat_with_space( b.OrganizationBPName1,b.OrganizationBPName2, 1 ),
               concat_with_space( b.OrganizationBPName3,b.OrganizationBPName4, 1 ),

          1 ) as lglname,
  b.YY1_BPFullName_bus as trdnm,
concat_with_space( concat_with_space( concat_with_space( concat_with_space( concat_with_space( concat_with_space( concat_with_space( c.StreetName,c.StreetPrefixName1,1 ),c.StreetPrefixName2,1 ),c.StreetSuffixName1,1 ),c.StreetSuffixName2,1 ),c.HouseNumber,1 ) ,c.Building, 1 ),c.RoomNumber,1 )  as Addr1,
    '' as addr2 ,
     c.CityName as loc,
     c.PostalCode as pin,
     --substring(  e.BPTaxNumber,1,2) as stcd
     b2.text as stcd,c.CareOfName
     
    
    
}
where a.PartnerFunction='RE'
