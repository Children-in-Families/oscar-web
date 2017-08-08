CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =do ->
  _init = ->
    _initSelect2()
    _preventExitDate()
    _preventRequireFieldInput()
    _preventCheckBox()

  _initSelect2 = ->
    $('select').select2()

  _preventExitDate = ->
    form = $('form.simple_form')
    $(form).on 'submit', (e) ->
      requiredField = $('#exit_date')
      if $(requiredField).val() == ''
        $(requiredField).parent().parent().addClass('has-error')
        $(requiredField).parent().siblings('.help-block').removeClass('hidden')
        e.preventDefault()
      else
        $(requiredField).parent().parent().removeClass('has-error')
        $(requiredField).parent().siblings('.help-block').addClass('hidden')

  _preventRequireFieldInput = ->
    form = $('form.simple_form')
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
    form = $('form.simple_form')
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
