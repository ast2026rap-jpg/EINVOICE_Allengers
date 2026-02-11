@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Billing Item Details'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_BILLINGITEMDETAILS as 
select from  I_BillingDocument as a
left outer join I_BillingDocumentItem as b on a.BillingDocument=b.BillingDocument and a.CompanyCode=b.CompanyCode
left outer join I_ProductPlantBasic  as c on b.Product=c.Product and b.Plant=c.Plant
left outer join ZUNE_RV_UOM_H as d on b.BillingQuantityUnit=d.Sapunitcode
left outer join I_BillingDocumentItemPrcgElmnt as e on b.BillingDocument=e.BillingDocument and b.BillingDocumentItem=e.BillingDocumentItem 
                                                    and ( e.ConditionType='ZOCG')
left outer join I_BillingDocumentItemPrcgElmnt as f on b.BillingDocument=f.BillingDocument and b.BillingDocumentItem=f.BillingDocumentItem 
                                                    and (f.ConditionType='ZOSG')
left outer join I_BillingDocumentItemPrcgElmnt as g on b.BillingDocument=g.BillingDocument and b.BillingDocumentItem=g.BillingDocumentItem 
                                                    and ( g.ConditionType='ZOIG')
left outer join I_BillingDocumentItemPrcgElmnt as h on b.BillingDocument=h.BillingDocument and b.BillingDocumentItem=h.BillingDocumentItem 
                                                    and (h.ConditionType='JTC2' or h.ConditionType='ZFTX')
left outer join I_BillingDocumentItemPrcgElmnt as i on b.BillingDocument=i.BillingDocument and b.BillingDocumentItem=i.BillingDocumentItem 
                                                    and (i.ConditionType='D100' or i.ConditionType='DCD2' or  i.ConditionType='YK07')
left outer join I_BillingDocumentItemPrcgElmnt as j on b.BillingDocument=j.BillingDocument and b.BillingDocumentItem=j.BillingDocumentItem 
                                                    and (j.ConditionType='ZFTX' )
left outer join I_BillingDocumentItemPrcgElmnt as k on b.BillingDocument=k.BillingDocument and b.BillingDocumentItem=k.BillingDocumentItem 
                                                    and (k.ConditionType='ZMRP' )

{
  key  a.BillingDocument,
  key  b.Product,
  key  b.BillingDocumentItem,
     c.ConsumptionTaxCtrlCode as HSN,
   max(cast(b.BillingQuantity as abap.dec(18,2)))   as BillingQuantity,
   d.Govunitcode,
       (sum(cast( k.ConditionAmount as abap.dec(18,2)))+sum( coalesce(cast(i.ConditionAmount as abap.dec(18,2)),0))) -
       ( sum(coalesce(cast( e.ConditionAmount as abap.dec(18,2)),0))+
       sum( coalesce(cast(f.ConditionAmount as abap.dec(18,2)),0))+
       sum( coalesce(cast(g.ConditionAmount as abap.dec(18,2)),0)) ) as AssAmt,
  max(cast(e.ConditionRateValue as abap.dec(6,3))) as CGSTRate,
   sum(cast(e.ConditionAmount as abap.dec(18,2))) as CGSTAmount,
  max( cast(f.ConditionRateValue as abap.dec(6,3))) as SGSTRate,
   sum(cast(f.ConditionAmount as abap.dec(18,2))) as SGSTAmount, 
   max(cast(g.ConditionRateValue  as abap.dec(6,3))) as IGSTRate,
   sum(cast(g.ConditionAmount as abap.dec(18,2))) as IGSTAmount,
   sum(cast(i.ConditionAmount as abap.dec(18,2))) as discountAmount,
   sum(cast(j.ConditionAmount as abap.dec(18,2))) as FreightChargesTax,
    max(cast(b.NetAmount as abap.dec(18,2))) as NetAmount,
    sum(cast( k.ConditionAmount as abap.dec(18,2))) as Unitprice,
   
   0 as CessRate,
   0 as CessAmount,
   sum(cast(h.ConditionAmount as abap.dec(18,2) )) as OtherCharges
   
   
  
   
   
   
}

group by 
 a.BillingDocument,
    b.Product,
    b.BillingDocumentItem,
     c.ConsumptionTaxCtrlCode,d.Govunitcode
