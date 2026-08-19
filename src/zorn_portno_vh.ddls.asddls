@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Value Help for POrt no'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZORN_PORTNo_VH as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZORN_DOMAIN_PORTNO' )
{
     @ObjectModel.text.element: [ 'text' ]
    key value_low,
    text,
    case value_low
      when 'INASR2' then '143001'
      when 'INBLR4' then '560300'
      when 'INBOM4' then '400099'
      when 'INCPR6' then '141401'
      when 'INDEL4' then '110037'
      when 'INDPR6' then '140506'
      when 'INGAIB' then '262902'
      when 'INHND1' then '743439'
      when 'INJBNB' then '854328'
      when 'INJIGB' then '736182'
      when 'INLDH6' then '141010'
      when 'INMAA1' then '600001'
      when 'INMUN1' then '370405'
      when 'INNSA1' then '400702'
      when 'INPPG6' then '110092'
      when 'INPTPB' then '743405'
      when 'INRXLB' then '845305'
      when 'INSBI6' then '382423'
      when 'INSNLB' then '273164'
      when 'INTKD6' then '110044'
      when 'INTUT6' then '628501'
      else '000000'
    end as PortGSTPostalCode,

    // New Column 2: PortGSTStateCode
    case value_low
      when 'INASR2' then '03'
      when 'INBLR4' then '29'
      when 'INBOM4' then '27'
      when 'INCPR6' then '03'
      when 'INDEL4' then '07'
      when 'INDPR6' then '03'
      when 'INGAIB' then '09'
      when 'INHND1' then '19'
      when 'INJBNB' then '10'
      when 'INJIGB' then '19'
      when 'INLDH6' then '03'
      when 'INMAA1' then '33'
      when 'INMUN1' then '24'
      when 'INNSA1' then '27'
      when 'INPPG6' then '07'
      when 'INPTPB' then '19'
      when 'INRXLB' then '10'
      when 'INSBI6' then '24'
      when 'INSNLB' then '09'
      when 'INTKD6' then '07'
      when 'INTUT6' then '33'
      else '00'
    end as PortGSTStateCode
}
