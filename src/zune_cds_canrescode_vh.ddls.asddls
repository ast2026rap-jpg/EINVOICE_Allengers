@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cancel Reason Code-CDS'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_CANRESCODE_VH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZUNE_D_CANCELRSNCODE' )
{  
    @ObjectModel.text.element: [ 'text' ]
    key value_low,
    text
}
