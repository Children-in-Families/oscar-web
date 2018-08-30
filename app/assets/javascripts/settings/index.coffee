CIF.SettingsIndex = CIF.SettingsEdit = CIF.SettingsUpdate = CIF.SettingsCreate = CIF.SettingsDefault_columns = do ->
  _init = ->
    _initSelect2()
    _handleAssessmentCheckbox()
    _ajaxChangeDistrict()

  _initSelect2 = ->
    $('select').select2()

  _handleAssessmentCheckbox = ->
    _disableAssessmentSetting()
    $('#setting_disable_assessment.i-checks').on 'ifChecked', ->
      $('#assessment-setting .panel-body').find('input, select').prop('disabled', true)

    $('#setting_disable_assessment.i-checks').on 'ifUnchecked', ->
      $('#assessment-setting .panel-body').find('input, select').prop('disabled', false)

  _disableAssessmentSetting = ->
    disableAssessmentChecked = $('#setting_disable_assessment').is(':checked')
    $('#assessment-setting .panel-body').find('input, select').prop('disabled', true) if disableAssessmentChecked

  _ajaxChangeDistrict = ->
    mainAddress = $('#setting_province_id, #setting_district_id')
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddress = $(@).data('subaddress')

      if type == 'provinces' && subAddress == 'district'
        subResources = 'districts'
        subAddress =  $('#setting_district_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()
      else if type == 'districts' && subAddress == 'commune'
        subResources = 'communes'
        subAddress = $('#setting_commune_id')

        $(subAddress).val(null).trigger('change')
        $(subAddress).find('option[value!=""]').remove()

      if typeId != ''
        $.ajax
          method: 'GET'
          url: "/api/#{type}/#{typeId}/#{subResources}"
          dataType: 'JSON'
          success: (response) ->
            for address in response.data
              subAddress.append("<option value='#{address.id}'>#{address.name}</option>")




  { init: _init }
