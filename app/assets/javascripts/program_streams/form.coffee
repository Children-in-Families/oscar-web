CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = do ->
  @formBuilder = ''
  _init = ->
    _initProgramSteps()
    # _initProgramBuilder()
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  _generateValueForSelectOption = (field) ->
    $(field).find('input.option-label').on 'keyup change', ->
      value = $(@).val()
      $(@).siblings('.option-value').val(value)

  _hideOptionValue = ->
    $('.option-selected, .option-value').hide()

  _addOptionCallback = (field) ->
    $('.add-opt').on 'click', ->
      setTimeout ( ->
        $(field).find('.option-selected, .option-value').hide()
        )

  _initProgramBuilder = (element) ->
    formBuilder = $(element).formBuilder({
      dataType: 'json'
      formData: ''
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file','checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }

      typeUserEvents: {
        'checkbox-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        text:
          onadd: (fld) ->
            $('.fld-subtype ').find('option:contains(color)').remove()
            $('.fld-subtype ').find('option:contains(tel)').remove()
            $('.fld-subtype ').find('option:contains(password)').remove()
            $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()

        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      }

    }).data('formBuilder');


    $('#save').click ->

      # $('#program_stream_enrollment').val(formBuilder.formData)

  _initProgramSteps = ->
    self = @
    form = $('.new_program_stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'
      onStepChanging: (event, currentIndex, newIndex) ->
      # if newIndex == 1
      #   enrollment = $('#enrollment')
      #   _initProgramBuilder(enrollment)
      #   # $('#program_stream_enrollment').val(enrollmentBuilder.formData)
      #   else if newIndex == 2
      #     tracking = $('#tracking')
      #     _initProgramBuilder(tracking)
      #   else if newIndex == 3
      #     exitProgram = $('#exit-program')
      #     _initProgramBuilder(exitProgram)
      #     # $('#program_stream_exit_program').val(exitProgramBuilder.formData)
        if newIndex == 1
          enrollment = $('#enrollment')
          _initProgramBuilder(enrollment)



        $('section ul.frmb.ui-sortable').css('min-height', '266px')
        $(form).validate().settings.ignore = ':disabled,:hidden'
        $(form).valid()
      onStepChanged: (event, currentIndex, newIndex) ->
        $('#save').trigger 'click'
        debugger
      #   console.log currentIndex
      #   if currentIndex == 2
      #     console.log self.formBuilder
      #     $('#program_stream_enrollment').val(self.formBuilder.formData)
      #     console.log $('#program_stream_enrollment').val()

      onFinishing: (event, currentIndex) ->
        # form.validate().settings.ignore = ':disabled'
        # form.valid()
      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Done")').removeAttr('href')
        # form.submit()
      labels:
        finish: 'Create'


  { init: _init }