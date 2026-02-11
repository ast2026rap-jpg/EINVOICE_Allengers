CLASS lhc_uommaster DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR uommaster RESULT result.


    METHODS validateentry FOR VALIDATE ON SAVE
      IMPORTING keys FOR uommaster~validateentry.

ENDCLASS.

CLASS lhc_uommaster IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.



  METHOD validateentry.

  READ ENTITIES OF zune_rv_uom_h IN LOCAL MODE
      ENTITY UOMMaster
      ALL FIELDS
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_result)
      REPORTED DATA(lt_reported)
      FAILED DATA(lt_failed).





    LOOP AT lt_result INTO DATA(ls_result).
*      IF ls_result-Govunitcode IS NOT INITIAL.
*
*        SELECT SINGLE FROM zune_iv_uom_h WITH PRIVILEGED ACCESS FIELDS COUNT( Govunitcode )  WHERE Govunitcode = @ls_result-Govunitcode AND sapid <> @ls_result-sapid INTO @DATA(Govunitcode).
*
*        IF Govunitcode = 1.
*          APPEND VALUE #( %tky = ls_result-%tky )
*                   TO lt_failed-uommaster.
*          "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
*          reported-uommaster = VALUE #( BASE reported-uommaster
*                                       (
*                                           %tky = ls_result-%tky
*                                           %state_area = 'Validate_Entry_Govunitcode'
*                                           %msg = new_message(
*                                                    id       = 'SY'
*                                                    number   = '002'
*                                                    v1       = 'Entry with same GOV UOM Id already exist'
*                                                    severity = if_abap_behv_message=>severity-error
*                                                  )
*                                           %element-Govunitcode = if_abap_behv=>mk-on
*                                       )
*          ).
*        ENDIF.
*      endif.
      IF ls_result-Govunitcode is initial or ls_result-Sapunitcode is initial.
       APPEND VALUE #( %tky = ls_result-%tky )
                   TO lt_failed-uommaster.
                   APPEND VALUE #( %tky = ls_result-%tky
                                           %state_area = 'Validate_Entry_Govunitcode_Sapunitcode'
                                           %msg = new_message(
                                                   id       = 'SYS'
                                                   number   = '002'
                                                    v1       = 'GOV/SAP UOM Code can not empty'
                                                    severity = if_abap_behv_message=>severity-error

                                                  )

                                           %element-Govunitcode = if_abap_behv=>mk-on
                                           %element-sapunitcode = if_abap_behv=>mk-on

              ) to reported-uommaster.
*
*          "IS INITAL IS TO CHECK THE NULL OR BLANK VALUE
*          reported-uommaster = VALUE #( BASE reported-uommaster
*                                       (
*                                           %tky = ls_result-%tky
*                                           %state_area = 'Validate_Entry_Govunitcode_Sapunitcode'
*                                           %msg = new_message(
*                                                    id       = 'SY'
*                                                    number   = '002'
*                                                    v1       = 'GOV/SAP UOM Code can not empty'
*                                                    severity = if_abap_behv_message=>severity-error
*                                                  )
*                                           %element-Govunitcode = if_abap_behv=>mk-on
*                                           %element-sapunitcode = if_abap_behv=>mk-on
*                                       )
*          ).
      ENDIF.
    endLOOP.
  ENDMETHOD.

ENDCLASS.
