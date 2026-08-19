@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'BILLING ITEM Details Export'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZUNE_CDS_BILLINGITEMDETAILS_EX as select from    I_BillingDocument              as a
    left outer join I_BillingDocumentItem          as b on  a.BillingDocument = b.BillingDocument
                                                        and a.CompanyCode     = b.CompanyCode
    left outer join I_ProductPlantBasic            as c on  b.Product = c.Product
                                                        and b.Plant   = c.Plant
    left outer join ZUNE_RV_UOM_H                  as d on b.BillingQuantityUnit = d.Sapunitcode
    left outer join I_BillingDocumentItemPrcgElmnt as e on  b.BillingDocument     = e.BillingDocument
                                                        and b.BillingDocumentItem = e.BillingDocumentItem
                                                        and (
                                                           e.ConditionType        = 'ZOCG' or e.ConditionType = 'JOCG'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as f on  b.BillingDocument     = f.BillingDocument
                                                        and b.BillingDocumentItem = f.BillingDocumentItem
                                                        and (
                                                           f.ConditionType        = 'ZOSG' or f.ConditionType = 'JOSG'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as g on  b.BillingDocument     = g.BillingDocument
                                                        and b.BillingDocumentItem = g.BillingDocumentItem
                                                        and (
                                                           g.ConditionType        = 'ZOIG' or g.ConditionType = 'JOIG'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as h on  b.BillingDocument     = h.BillingDocument
                                                        and b.BillingDocumentItem = h.BillingDocumentItem
                                                        and (
                                                           h.ConditionType        = 'ZFIN' 
                                                           
                                                         )
                                                         
     left outer join I_BillingDocumentItemPrcgElmnt as h1 on  b.BillingDocument     = h1.BillingDocument
                                                        and b.BillingDocumentItem = h1.BillingDocumentItem
                                                        and (
                                                           h1.ConditionType        = 'ZFRH' 
                                                           
                                                         )
                                                         
    left outer join I_BillingDocumentItemPrcgElmnt as i on  b.BillingDocument     = i.BillingDocument
                                                        and b.BillingDocumentItem = i.BillingDocumentItem
                                                        and (
                                                           i.ConditionType        = 'D100'
                                                           or i.ConditionType     = 'DCD2'
                                                           or i.ConditionType     = 'YK07'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as j on  b.BillingDocument     = j.BillingDocument
                                                        and b.BillingDocumentItem = j.BillingDocumentItem
                                                        and (
                                                           j.ConditionType        = 'ZFTX'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as k on  b.BillingDocument     = k.BillingDocument
                                                        and b.BillingDocumentItem = k.BillingDocumentItem
                                                        and (
                                                           k.ConditionType        = 'ZBAS'
                                                           or k.ConditionType     = 'PMV1'
                                                           or k.ConditionType     = 'ZCIP'
                                                         )
    left outer join I_BillingDocumentItemPrcgElmnt as l on  b.BillingDocument     = l.BillingDocument
                                                        and b.BillingDocumentItem = l.BillingDocumentItem
                                                        and (
                                                           l.ConditionType        = 'DRD1'
                                                         )
     left outer join I_BillingDocumentItemPrcgElmnt as O on  b.BillingDocument     = O.BillingDocument
                                                        and b.BillingDocumentItem = O.BillingDocumentItem
                                                        and (
                                                           O.ConditionType        = 'JTC2'
                                                         )
    left outer join I_Product                      as m on b.Product = m.Product
 
{
  key  a.BillingDocument,
  key  b.Product,
  key  b.BillingDocumentItem,
       m.ItemCategoryGroup  as ProductType,
       cast('INR' as abap.cuky) as TargetCurrency,
       b.YY1_Productdetaildesc3_BDI as ProductDescription,
       c.ConsumptionTaxCtrlCode                                                                  as HSN,
       max(cast(b.BillingQuantity as abap.dec(18,2)))                                            as BillingQuantity,
       d.Govunitcode,
       //sum(cast( k.ConditionAmount as abap.dec(18,2)))
      
       cast(currency_conversion(
         amount             => cast(sum(cast( k.ConditionAmount as abap.dec(18,2))) as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))    
         as AssAmt,
       max(cast(e.ConditionRateValue as abap.dec(6,3)))                                          as CGSTRate,
       
         
      
        cast(currency_conversion(
         amount             => cast(sum(cast(e.ConditionAmount as abap.dec(18,2)))   as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))                                          
        as CGSTAmount,
       max( cast(f.ConditionRateValue as abap.dec(6,3)))                                         as SGSTRate,
                                                  
          
      
       cast(currency_conversion(
         amount             => cast(sum(cast(f.ConditionAmount as abap.dec(18,2)))   as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))   
       as SGSTAmount,
       max(cast(g.ConditionRateValue  as abap.dec(6,3)))                                         as IGSTRate,
       
                                               
      
        cast(currency_conversion(
         amount             => cast(sum(cast(g.ConditionAmount as abap.dec(18,2)))      as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))   
        as IGSTAmount,
                                                 
         
        cast(currency_conversion(
         amount             => cast(sum(cast(i.ConditionAmount as abap.dec(18,2)))      as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))   
        as discountAmount,
      
          
       cast( currency_conversion(
         amount             => cast( sum(cast(j.ConditionAmount as abap.dec(18,2)))      as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))                                          
          as FreightChargesTax,
                                                        
               
          
        cast(currency_conversion(
         amount             => cast( sum(cast(O.ConditionAmount as abap.dec(18,2)))       as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       )  as  abap.dec(18,2))   
               as TCSAmount, 
       
        
       cast(currency_conversion(
         amount             => cast( sum(cast( k.ConditionAmount as abap.dec(18,2)))        as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))       
       as NetAmount,
                
       
      cast( currency_conversion(
         amount             => cast( sum(cast( k.ConditionAmount as abap.dec(18,2))) /  max(cast(b.BillingQuantity as abap.dec(18,2)))      as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       )  as  abap.dec(18,2))  
                                as Unitprice,
 
       0                                                                                         as CessRate,
       0                                                                                         as CessAmount,
                                    
      
       cast( currency_conversion(
         amount             => cast( sum(coalesce(cast(h.ConditionAmount as abap.dec(18,2) ),0)) + sum(coalesce(cast(h1.ConditionAmount as abap.dec(18,2) ),0))        as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))  
         as OtherCharges,
 
                                        
      
      cast( currency_conversion(
         amount             => cast( sum(cast(l.ConditionAmount as abap.dec(18,2)))         as abap.curr(15,2)),
         source_currency    => a.TransactionCurrency,
         target_currency    => cast('INR' as abap.cuky),
         exchange_rate_date => a.BillingDocumentDate,
         exchange_rate_type => 'M'
       ) as  abap.dec(18,2))  
           as rounding
 
 
 
 
 
}
where 
b.BillingDocumentItemText <> 'Down Payment Settlement'
//(g.ConditionAmount > 0 or f.ConditionAmount > 0 or e.ConditionAmount > 0)
group by
  a.BillingDocument,
  b.Product,
   m.ItemCategoryGroup,
  b.YY1_Productdetaildesc3_BDI,
  b.BillingDocumentItem,
  c.ConsumptionTaxCtrlCode,
  d.Govunitcode,
  a.TransactionCurrency,
  a.BillingDocumentDate
