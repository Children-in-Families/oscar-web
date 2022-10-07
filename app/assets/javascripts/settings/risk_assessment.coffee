CIF.SettingsRisk_assessment = do ->
  _init = ->
    _initICheckBox()
    _handleSettingAssessmentTypeNameChange()
    _tinyMCE()

  _initICheckBox = ->
    if $('#setting_enabled_risk_assessment').is(':checked')
      $('#assessment-type-name').show()
      $('#guidance').show()
    else
      $(".domain-checkbox-wrapper").hide()
      $('#assessment-type-name').hide()
      $('#guidance').hide()

    $('.i-checks').iCheck(
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
    ).on('ifChecked', ->
      $('#assessment-type-name').show()
      $('#guidance').show()
      _showHideDomainCheckBox($('#setting_assessment_type_name:visible').val())
    ).on 'ifUnchecked', ->
      return if @.id.match(/setting_selected_domain_ids/) && @.id.match(/setting_selected_domain_ids/).length

      $(".domain-checkbox-wrapper").hide()
      $('#assessment-type-name').hide()
      $('#guidance').hide()

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

  _tinyMCE = ->
    tinymce.init
      selector: 'textarea.tinymce'
      plugins: 'lists'
      width : '100%'
      toolbar: 'bold italic numlist bullist'
      menubar: false

  { init: _init }
