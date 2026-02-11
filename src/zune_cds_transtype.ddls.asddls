@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transaction Type-CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_TRANSTYPE as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZUNE_D_TRANSACTIONTYPE' )
{  
    @ObjectModel.text.element: [ 'text' ]
    key value_low,
    text
}
