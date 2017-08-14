CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =do ->
  _init = ->
    _initSelect2()
    _preventExitDate()
    _preventRequireFieldInput()
    _preventCheckBox()
    _preventNumberMinMax()

  _initSelect2 = ->
    $('select').select2()

  _preventExitDate = ->
    form = $('form.leave_program')
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
    form = $('form.leave_program')
    $(form).on 'submit', (e) ->
      requiredFields = $('input[type="text"], textarea, input[type=number]').parents('div.required')
      for requiredField in requiredFields
        if $(requiredField).find('input').val() == '' or $(requiredField).find('textarea').val() == ''
          if $(requiredField).find('.select2-chosen, .select2-search-choice').length == 0
            if $(requiredField).find('input').attr('type') == 'number'
              $(requiredField).siblings('.help-block-number').addClass('hidden')
            $(requiredField).parent().addClass('has-error')
            $(requiredField).siblings('.help-block').removeClass('hidden')
            e.preventDefault()
        else
          $(requiredField).parent().removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')

  _preventCheckBox = ->
    form = $('form.leave_program')
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

  messages_lower = $('.help-block-number.lower:first').text().trim()
  messages_greater = $('.help-block-number.lower:first').text().trim()

  _preventNumberMinMax = ->
    form = $('form.leave_program')
    $(form).on 'submit', (e) ->
      requiredFields = $('input[type=number]').parents('div.prevent')
      for requiredField in requiredFields
        if $(requiredField).find('input').attr('type') == 'number' && $(requiredField).find('input').val() != ''
          value = parseInt($(requiredField).find('input').val())
          max = parseInt($(requiredField).find('input').attr('max'))
          min = parseInt($(requiredField).find('input').attr('min_value'))
          if max < value
            $(requiredField).parent().addClass('has-error')
            $(requiredField).find('.help-block-number.greater').removeClass('hidden')
            $(requiredField).find('.help-block-number.lower').addClass('hidden')
            $(requiredField).find('.help-block-number.greater').text("#{messages_greater} #{max}")
            e.preventDefault()
          else if min > value
            $(requiredField).parent().addClass('has-error')
            $(requiredField).find('.help-block-number.greater').addClass('hidden')
            $(requiredField).find('.help-block-number.lower').removeClass('hidden')
            $(requiredField).find('.help-block-number.lower').text("#{messages_lower} #{min}")
            e.preventDefault()
          else if min <= value && max >= value
            $(requiredField).parent().removeClass('has-error')
            $(requiredField).find('.help-block-number').addClass('hidden')

  { init: _init }
