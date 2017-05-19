CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = do ->
  @formBuilder = ''
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initProgramSteps()
    _initSelect2()
    _ajaxGetProgramStreamField()
  
  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#rule-builder').data('filter-translation-add-filter')
      addGroup: $('#rule-builder').data('filter-translation-add-group')
      deleteGroup: $('#rule-builder').data('filter-translation-delete-group')
      next: $('#rule-builder').data('filter-translation-next')
      previous: $('#rule-builder').data('filter-translation-previous')
      finish: $('#rule-builder').data('filter-translation-finish')

  _handleSelectOptionChange = ->
    $('select').on 'select2-selecting', (e) ->
      setTimeout (->
        $('.rule-operator-container select').select2(
          width: '180px'
        )
        $('.rule-value-container select').select2(
          width: '180px'
        )
      ),100

  _ajaxGetProgramStreamField = ->
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rule').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        _handleSelectOptionChange()

  _queryBuilderOption = (fieldList) ->
    inputs_separator: ' AND '
    icons:
      remove_rule: 'fa fa-minus'
    lang:
      delete_rule: ''
      add_rule: @filterTranslation.addFilter
      add_group: @filterTranslation.addGroup
      delete_group: @filterTranslation.deleteGroup
      operators:
        is_empty: 'is blank'
        equal: 'is'
        not_equal: 'is not'
        less: '<'
        less_or_equal: '<='
        greater: '>'
        greater_or_equal: '>='
        contains: 'includes'
        not_contains: 'excludes'
    filters: fieldList
  
  _initDataToSummary = ->
    programStreamName = $('#program_stream_name').val()
    programStreamDescription = $('#program_stream_description').val()

    $('h3#program-name').text(programStreamName)
    $('#program-description').text(programStreamDescription)
  
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
    @formBuilder = $(element).formBuilder({
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
      
  _initProgramSteps = ->
    self = @
    form = $('.new_program_stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'

      onStepChanging: (event, currentIndex, newIndex) ->
        data = JSON.parse(self.formBuilder.formData) if self.formBuilder != ''
        if currentIndex == 1 and newIndex == 2 and $('#enrollment').is(':visible')
          console.log self.formBuilder.formData
          return false if data.length == 0
        else if currentIndex == 2 and newIndex == 3 and $('#tracking').is(':visible')
          return false if data.length == 0
        else if currentIndex == 3 and newIndex == 4 and $('#exit-program').is(':visible')
          return false if data.length == 0

        $('section ul.frmb.ui-sortable').css('min-height', '266px')
        $(form).validate().settings.ignore = ':disabled,:hidden'
        $(form).valid()

      onStepChanged: (event, currentIndex, newIndex) ->
        if $('#enrollment').is(':visible')
          enrollment = $('#enrollment')
          _initProgramBuilder(enrollment) unless _preventDuplicateFormBuilder(enrollment)
        else if $('#tracking').is(':visible')
          tracking = $('#tracking')
          _initProgramBuilder(tracking) unless _preventDuplicateFormBuilder(tracking)
        else if $('#exit-program').is(':visible')
          exitProgram = $('#exit-program')
          _initProgramBuilder(exitProgram) unless _preventDuplicateFormBuilder(exitProgram)  

      onFinishing: (event, currentIndex) ->
        form.validate().settings.ignore = ':disabled'
        form.valid()

      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Done")').removeAttr('href')
        _handleRemoveUnuseInput()
        # _handleAddFormBuildToInput()
        _handleAddRuleBuilderToInput()
        form.submit()
      labels:
        finish: @filterTranslation.finish
        next: @filterTranslation.next
        previous: @filterTranslation.previous

  _handleRemoveUnuseInput = ->
    $('#enrollment .form-wrap.form-builder, #tracking .form-wrap.form-builder, #exit-program .form-wrap.form-builder').find('input, select, radio, checkbox, textarea').remove()

  _preventDuplicateFormBuilder = (element) ->
    $(element).children().hasClass('form-builder')

  _handleAddFormBuildToInput = ->
    for formBuilder in @formBuilder
      element = formBuilder.element
      formData = formBuilder.formData
      if $(element).is('#enrollment')
        $('#program_stream_enrollment').val(formData)
      else if $(element).is('#tracking')
        $('#program_stream_tracking').val(formData)
      else if $(element).is('#exit-program') 
        $('#program_stream_exit_program').val(formData)

  _handleAddRuleBuilderToInput = ->
    rules = $('#program-rule').queryBuilder('getRules')
    $('#program_stream_rules').val(_handleStringfyRules(rules)) if !($.isEmptyObject(rules))

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  { init: _init }