@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Update Reason Code'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_UPDRESCODE_VH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZUNE_D_UPDRESCODE' )
{  
    @ObjectModel.text.element: [ 'text' ]
    key value_low,
    text
}
