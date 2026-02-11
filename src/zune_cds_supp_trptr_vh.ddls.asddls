@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Supplier Transporter - Value Help'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZUNE_CDS_SUPP_TRPTR_VH as select from I_Supplier
{
    key Supplier,
    SupplierFullName,
    @EndUserText.label: 'GSTIN'
    TaxNumber3 as GSTIN
}
