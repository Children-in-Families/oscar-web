CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate = do ->
  _init = ->
    _initSelect2()
    _preventEnrollmentDate()
    _preventRequireFieldInput()
    _preventCheckBox()

  _initSelect2 = ->
    $('select').select2()

  _preventEnrollmentDate = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->
      requiredField = $('#enrollment_date')
      if $(requiredField).val() == ''
        $(requiredField).parent().parent().addClass('has-error')
        $(requiredField).parent().siblings('.help-block').removeClass('hidden')
        e.preventDefault()
      else
        $(requiredField).parents('.has-error').removeClass('has-error')
        $(requiredField).parent().siblings('.help-block').addClass('hidden')

  _preventRequireFieldInput = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->

      requiredFields = $(':input').parents('div.required')
      for requiredField in requiredFields
        if $(requiredField).find('input').val() == '' or $(requiredField).find('textarea').val() == ''
          if $(requiredField).find('.select2-chosen, .select2-search-choice').length == 0
            $(requiredField).parent().addClass('has-error')
            $(requiredField).siblings('.help-block').removeClass('hidden')
            e.preventDefault()
        else if $(requiredField).find('input').val() != '' && !_validateEmail($(requiredField).find('input[type="email"]').val())
          invalid_email = $(requiredField).siblings('.help-block').data('email')
          $(requiredField).siblings('.help-block').text(invalid_email)
          $(requiredField).parent().parent().addClass('has-error')
          $(requiredField).siblings('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(requiredField).parents('.has-error').removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')

  _validateEmail = (email) ->
    re = /\S+@\S+\.\S+/
    re.test email

  _preventCheckBox = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->
      checkBoxs = $('input[type="checkbox"]').parents('div.required')
      for checkBox in checkBoxs
        if $(checkBox).find('.checked').length == 0
          $(checkBox).parents('.i-checks').addClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(checkBox).parents('.i-checks').removeClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').addClass('hidden')

  { init: _init }
