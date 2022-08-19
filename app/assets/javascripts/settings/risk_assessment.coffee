CIF.SettingsRisk_assessment = do ->
  _init = ->
    _initICheckBox()
    _handleSettingAssessmentTypeNameChange()

  _initICheckBox = ->
    if $('#setting_enabled_risk_assessment').is(':checked')
      $('#assessment-type-name').show()
    else
      $(".domain-checkbox-wrapper").hide()
      $('#assessment-type-name').hide()

    $('.i-checks').iCheck(
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
    ).on('ifChecked', ->
      $('#assessment-type-name').show()
      _showHideDomainCheckBox($('#setting_assessment_type_name:visible').val())
    ).on 'ifUnchecked', ->
      $(".domain-checkbox-wrapper").hide()
      $('#assessment-type-name').hide()

  _handleSettingAssessmentTypeNameChange = ->
    $(".domain-checkbox-wrapper").hide()
    _showHideDomainCheckBox($('#setting_assessment_type_name:visible').val())
    $('#setting_assessment_type_name').on 'change', (e) ->
      $(".domain-checkbox-wrapper").hide()
      _showHideDomainCheckBox(e.target.value)

  _showHideDomainCheckBox = (value) ->
    if value == 'csi'
      $("##{value}").show()
    else
      $("#custom-domain-#{value}").show()

    return

  { init: _init }
