CIF.Client_trackingsNew = CIF.Client_trackingsCreate = CIF.Client_custom_fieldsNew = CIF.Client_custom_fieldsCreate = CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = do ->
  checkedItems = []
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFields()
    _toggleCheckingRadioButton()
    _confirm()
    _initICheckBox()
    _initDatePicker()
    _preventCreateDatePickerClientEnrollment()
    _setAnotherLanguageFieldValue()
    _hideAnotherLanguageField()
    _copyInputTextToLocalLanguage()
    _copyTextAreaTextToLocalLanguage()
    _copyNumberToLocalLanguage()
    _copyDateToLocalLanguage()
    _checkCheckbox()
    _uncheckCheckbox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
      el = $(@)
      el.parents('.radio_buttons').next().children('#' + el.data('option')).val(el.data('value'))
      $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

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

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _initDatePicker = ->
    $('.client-enrollment-date').datepicker
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true

  _preventCreateDatePickerClientEnrollment = ->
    currentEnterNgo = $('#current_enter_ngo').val()
    $('.client-enrollment-date').datepicker('setStartDate', currentEnterNgo)

  _setAnotherLanguageFieldValue = ->
    $('select').on 'select2-selecting', (e) ->
      $('#' + $(e.target).data('label')).val($(e.choice.element).data('value')).trigger("change")
      return
  
  _hideAnotherLanguageField = ->
    $('.client-enrollment').find('.d-none').parent().addClass('hide')

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

  _copyNumberToLocalLanguage = ->
    $('input[type="number"]').on 'keyup mouseup', (e) ->
      el = $(@)
      el.parent().next().find('#' + el.data('local-number')).val(el.val())

  _copyDateToLocalLanguage = ->
    $('input.form-builder-date').on 'changeDate', (e) ->
      el = $(@)
      el.next('#' + el.data('local-date')).val(el.val())

  _preventRequireFields = ->
    preventFileUploader()
    preventRequireFieldInput()
    preventCheckBox()
    preventSelect()
    preventRadioButton()
    _preventClient()
    _preventEnrollmentDate()

  _confirm = ->
    form = $('.multiple-form form')
    $('#yes').on 'click', ->
      $('#confirm').val('true')
      $('#complete-form').modal('hide')
      form.submit()
    $('#no').on 'click', ->
      $('#confirm').val('false')
      $('#complete-form').modal('hide')
      form.submit()
    $('.complete-form').on 'click', (e) ->
      if $('.has-error').length == 0
        $('#complete-form').modal('show')
        e.preventDefault()

  _preventClient = ->
    $('.complete-form').on 'click', (e) ->
      values = $('select.clients').select2('val')
      if _.isEmpty(values)
        $('#client').addClass('has-error')
        $('#client').find('.help-block').removeClass('hidden')
        e.preventDefault()
      else
        $('#client').removeClass('has-error')
        $('#client').find('.help-block').addClass('hidden')

  _preventEnrollmentDate = ->
    $('.complete-form').on 'click', (e) ->
      values = $('input.enrollmentdate').val()
      if _.isEmpty(values)
        $('#enrollmentdate').addClass('has-error')
        e.preventDefault()
      else
        $('#enrollmentdate').removeClass('has-error')

  preventFileUploader = ->
    $('.complete-form').on 'click', (e) ->
      requiredFields = $('input[type="file"]').parents('div.required')
      for requiredField in requiredFields
        continue if $(requiredField).parent().data('used')
        if $(requiredField).find('input').val() == ''
          $(requiredField).parent().addClass('has-error')
          $(requiredField).siblings('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(requiredField).parent().removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')

  preventRequireFieldInput = ->
    $('.complete-form').on 'click', (e) ->
      requiredFields = $('input[type="text"], textarea, input[type=number]').parents('div.required')
      for requiredField in requiredFields
        if $(requiredField).find('input').val() == '' or $(requiredField).find('textarea').val() == ''
          if $(requiredField).find('.select2-chosen, .select2-search-choice').length == 0
            $(requiredField).parent().addClass('has-error')
            $(requiredField).siblings('.help-block').removeClass('hidden')
            e.preventDefault()
        else
          $(requiredField).parent().removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')

  preventCheckBox = ->
    $('.complete-form').on 'click', (e) ->
      checkBoxs = $('input[type="checkbox"]').parents('div.required')
      for checkBox in checkBoxs
        if $(checkBox).find('.checked').length == 0
          $(checkBox).parents('.i-checks').addClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(checkBox).parents('.i-checks').removeClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').addClass('hidden')

  preventSelect = ->
    $('.complete-form').on 'click', (e) ->
      selects = $('select').parents('div.required')
      for select in selects
        if $(select).find('select.required').select2('val') == '' || _.isEmpty($(select).find('select.required').select2('val'))
          $(select).parent().addClass('has-error')
          $(select).siblings('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(select).parent().removeClass('has-error')
          $(select).parents().children('.help-block').addClass('hidden')

  preventRadioButton = ->
    $('.complete-form').on 'click', (e) ->
      radio_buttons = $('.radio_buttons').parents('div.required')
      for radio_button in radio_buttons
        if $(radio_button).find('.iradio_square-green.checked').length == 0
          $(radio_button).parent().addClass('has-error')
          $(radio_button).siblings('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(radio_button).parent().removeClass('has-error')
          $(radio_button).parents('.i-checks').children('.help-block').addClass('hidden')

  { init: _init }
