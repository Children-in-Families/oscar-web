CIF.Client_enrollment_trackingsNew = CIF.Client_enrollment_trackingsCreate = CIF.Client_enrollment_trackingsEdit = CIF.Client_enrollment_trackingsUpdate = do ->

  _init = ->
    _initSelect2()
    _preventRequireFieldInput()
    _preventCheckBox()

  _initSelect2 = ->
    $('select').select2()

  _preventRequireFieldInput = ->
    form = $('form.client-enrollment-tracking')
    $(form).on 'submit', (e) ->
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

  _preventCheckBox = ->
    form = $('form.client-enrollment-tracking')
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
