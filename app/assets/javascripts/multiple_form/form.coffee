CIF.Client_trackingsNew = CIF.Client_trackingsCreate = CIF.Client_custom_fieldsNew = CIF.Client_custom_fieldsCreate = do ->

  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFields()
    _toggleCheckingRadioButton()
    _confirm()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
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

  _preventRequireFields = ->
    preventFileUploader()
    preventRequireFieldInput()
    preventCheckBox()
    preventSelect()
    preventRadioButton()
    _preventClient()

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
