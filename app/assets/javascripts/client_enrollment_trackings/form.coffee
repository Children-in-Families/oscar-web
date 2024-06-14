CIF.Client_enrollment_trackingsNew = CIF.Client_enrollment_trackingsCreate = CIF.Client_enrollment_trackingsEdit = CIF.Client_enrollment_trackingsUpdate = CIF.Client_enrolled_program_trackingsUpdate =
CIF.Client_enrolled_program_trackingsNew = CIF.Client_enrolled_program_trackingsCreate = CIF.Client_enrolled_program_trackingsEdit = do ->

  checkedItems = []
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _setAnotherLanguageFieldValue()
    _hideAnotherLanguageField()
    _checkCheckbox()
    _uncheckCheckbox()
    _copyNumberToLocalLanguage()
    _copyInputTextToLocalLanguage()
    _copyTextAreaTextToLocalLanguage()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _toggleCheckingRadioButton = ->
      $('input[type="radio"]').on 'ifChecked', (e) ->
        el = $(@)
        el.parents('.radio_buttons').next().children('#' + el.data('option')).val(el.data('value'))
        $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _preventRequireFileUploader = ->
    prevent = new CIF.PreventRequiredFileUploader()
    prevent.preventFileUploader()

  _setAnotherLanguageFieldValue = ->
    $('select').on 'select2-selecting', (e) ->
      $('#' + $(e.target).data('label')).val($(e.choice.element).data('value')).trigger("change")
      return

  _hideAnotherLanguageField = ->
    $('.client-enrolled-program-tracking').find('.d-none').parent().addClass('hide')

  _checkCheckbox = ->
    $('input[type="checkbox"]').on 'ifChecked', (e) ->
      el = $(@)
      checkedItems.push(el.data('value'))
      el.parents('.check_boxes').next().children('#' + el.data('checkbox')).val(checkedItems).trigger('change')

  _uncheckCheckbox = ->
    $('input[type="checkbox"]').on 'ifUnchecked', (e) ->
      el = $(@)
      checkedItems.splice(checkedItems.indexOf(el.data('value')), 1)
      el.parents('.check_boxes').next().children('#' + el.data('checkbox')).val(checkedItems).trigger('change')

  _copyNumberToLocalLanguage = ->
    $('input[type="number"]').on 'keyup mouseup', (e) ->
      el = $(@)
      el.parent().next().find('#' + el.data('local-number')).val(el.val())

  _copyInputTextToLocalLanguage = ->
    $('input[type="text"]').on 'keyup', (e) ->
      el = $(@)
      if el.hasClass('date-picker')
      else
        el.parent().next().find('#' + el.data('local-input')).val(el.val())

  _copyTextAreaTextToLocalLanguage = ->
    $('textarea').on 'keyup', (e) ->
      el = $(@)
      el.parent().next().find('#' + el.data('local-textarea')).val(el.val())

  _copyDateToLocalLanguage = ->
    $('input.form-builder-date').on 'changeDate', (e) ->
      el = $(@)
      el.next('#' + el.data('local-date')).val(el.val())

  { init: _init }
