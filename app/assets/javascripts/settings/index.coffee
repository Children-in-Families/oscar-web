CIF.SettingsIndex = CIF.SettingsUpdate = CIF.SettingsCreate = CIF.SettingsDefault_columns = do ->
  _init = ->
    _initSelect2()
    _handleAssessmentCheckbox()

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




  { init: _init }
