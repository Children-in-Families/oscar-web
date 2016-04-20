CIF.AssessmentsNew = CIF.AssessmentsEdit = CIF.AssessmentsCreate = CIF.AssessmentsUpdate = do ->
  _init = ->
    formid = $('form').attr('id')
    form   = $('#'+formid)

    _formValidate(form)
    _loadSteps(form)

  _formValidate = (form) ->
    $('.score_option input').attr('required','required')
    $('.col-xs-12').on 'click', '.score_option label', ->
      $('.score_option').removeClass('is_error')

    form.validate errorElement: 'em'
    errorPlacement: (error, element) ->
      element.before error

  _loadSteps = (form) ->
    $("#rootwizard").steps
      headerTag: 'h4'
      bodyTag: 'div'
      transitionEffect: 'slideLeft'
      autoFocus: true

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex > newIndex
          return true

        form.validate().settings.ignore = ':disabled,:hidden'
        form.valid()
        _fileds_validator(currentIndex, newIndex)

      onFinishing: (event, currentIndex, newIndex) ->
        form.validate().settings.ignore = ':disabled'
        form.valid()
        _fileds_validator(currentIndex,newIndex)

      onFinished: ->
        $('.actions a:contains("Done")').removeAttr('href')
        $('form').submit()
      labels:
        finish: 'Done'

  _fileds_validator = (currentIndex, newIndex ) ->
      currentTab   = "#rootwizard-p-#{currentIndex}"
      score_option = $("#{currentTab} .score_option")

      if(score_option.find('input.error').length)
        $(currentTab).find('.score_option').addClass('is_error')
        return false
      else
        $(currentTab).find('.score_option').removeClass('is_error')
        if $(currentTab).find('textarea.valid').length
          return true

  { init: _init }