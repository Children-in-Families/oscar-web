CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = CIF.Program_streamsShow = do ->
  @formBuilder = []
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initProgramSteps()
    _addFooterForSubmitForm()
    _handleInitProgramRules()
    _addRuleCallback()
    _initSelect2()
    _handleAddCocoon()
    _handleRemoveCocoon()
    _handleInitProgramFields()
    _initButtonSave()
    _handleSaveProgramStream()
    _handleClickAddTracking()
    
  _stickyFill = ->
    if $('.form-wrap').is(':visible')
      $('.cb-wrap').Stickyfill()

  _initSelect2 = ->
    $('#description select, #rule-tab select').select2()

  _handleSelectTab = ->
    tab = $('.program-steps').data('tab')
    $('li[role="tab"]').each ->
      tabNumber = $(@).find('span.number').text()[0]
      if parseInt(tabNumber) == tab
        $(@).removeClass('disabled')
        $(@).find('a').trigger('click')
      else if parseInt(tabNumber) < tab
        $(@).removeClass('disabled')
        $(@).addClass('done')

  _handleSaveProgramStream = ->
    form = $('form')
    $('#program_stream_submit').on 'click', ->
      if _handleCheckingDuplicateFields()
        return false
      else
        _handleRemoveUnuseInput()
        _handleAddRuleBuilderToInput()
        _handleSetValueToField()
        $('.tracking-builder').find('input').removeAttr('required')
        $('.tracking-builder').find('textarea').removeAttr('required')
        $(form).submit()


  _handleSetRules = ->
    rules = $('#program_stream_rules').val()
    rules = JSON.parse(rules.replace(/=>/g, ':'))
    $('#program-rule').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

  _addRuleCallback = ->
    $('#program-rule').on 'afterCreateRuleFilters.queryBuilder', ->
      _initSelect2()
      _handleSelectOptionChange()

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#program-rule').data('filter-translation-add-filter')
      addGroup: $('#program-rule').data('filter-translation-add-group')
      deleteGroup: $('#program-rule').data('filter-translation-delete-group')
      next: $('.program-steps').data('next')
      previous: $('.program-steps').data('previous')
      save: $('.program-steps').data('save')

  _handleSelectOptionChange = ->
    $('select').on 'select2-selecting', (e) ->
      setTimeout (->
        $('.rule-operator-container select, .rule-value-container select').select2(
          width: '180px'
        )
      ),100

  _handleInitProgramRules = ->
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rule').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        setTimeout (->
          _handleSelectTab()
          _initSelect2()
          ), 100
        _handleSetRules()
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

  _handleAddCocoon = ->
    $('#trackings').on 'cocoon:after-insert', (e, element) ->
      trackingBuilder = $(element).find('.tracking-builder')
      _initProgramBuilder(trackingBuilder, [])
      _stickyFill()
      _editTrackingFormName()

  _handleRemoveCocoon = ->
    $('#trackings').on 'cocoon:after-remove', ->
      _checkDuplicateTrackingName()
    

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

  _initProgramBuilder = (element, data) ->
    data = if data.length != 0 then data.replace(/=>/g, ':') else ''
    @formBuilder.push $(element).formBuilder({
      dataType: 'json'
      formData: data
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file','checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }

      typeUserEvents: {
        'checkbox-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
            ),50

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
            ),50

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
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
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
            ),50

        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
            _handleDisplayDuplicateWarning(fld)
            _handleDeleteField()
            _handleEditLabelName()
          onclone: (fld) ->
            setTimeout ( ->
              _handleDisplayDuplicateWarning(fld)
              _handleDeleteField()
              _handleEditLabelName()
            ),50
      }

    }).data('formBuilder');

  # _handleCheckingForm = ->
  #   if $('#trackings').is(':visible')
  #     _editTrackingFormName()
  #     _handleRemoveCocoon()
  #   else
  #     _duplicateLabelField(fld)
  #     _handleDeleteField()
  #     _alertDuplicateWarning()

  _handleCheckingDuplicateFields = ->
    if $('#trackings').is(':visible')
      errorFields = $('#trackings').find('label.error')
    else
      errorFields = $('.form-wrap').find('label.error')

    if $(errorFields).length > 0 then true else false

  _editTrackingFormName = ->
    $(".program_stream_trackings_name input[type='text']").on 'blur', ->
      _checkDuplicateTrackingName()

  _checkDuplicateTrackingName = ->
    values = []
    nameFields = $('.ibox-content').find(".program_stream_trackings_name input[type='text']")

    $(nameFields).each (index, name) ->
      values.push $(name).val()

    counts = {}
    values.forEach (x) ->
      counts[x] = (counts[x] or 0) + 1

    $.each counts, (nameText, numberOfField) ->
      $(nameFields).each (index, text) ->
        if (numberOfField == 1) && ($(text).val() == nameText)
          $(text).removeClass('error')
          $(text).parent().find('label.error').remove()

        else if (numberOfField > 1) && ($(text).val() == nameText)
          $(text).addClass('error')
          unless $(text).parent().find('label.error').is(':visible')
            $(text).parent().append('<label class="error">Names are duplicate!!</label>')

    errors = $('.ibox-content:visible').find('label.error')
    unless errors.length > 0
      $('.steps ul li.current').removeClass('error')

  _handleDisplayDuplicateWarning = (fld)->
    duplicateLabels = false

    labelFields = $(fld).parents('.form-wrap:visible').find('label.field-label')

    $(labelFields).each (index, label) ->
      displayText = $(label).text()
      $(labelFields).each (cIndex, cLabel) ->
        return if cIndex == index
        cText = $(cLabel).text()
        if cText == displayText
          _addDuplicateWarning(label)

  _handleDeleteField = ->
    $('.field-actions a.del-button').on 'click', ->
      removedField = {}
      removedField = $(@).parents().children('label.field-label')

      labelFields = $(@).parents('.form-wrap:visible').find('label.field-label')
      
      counts = _countDuplicateLabel(labelFields)

      $.each counts, (labelText, numberOfField) ->
        if numberOfField == 2
          $(labelFields).each (index, label) ->
            if label.textContent == removedField.text()
              _removeDuplicateWarning(label)
              $('.steps ul li.current').removeClass('error')

  _handleEditLabelName = ->
    $(".form-wrap:visible .input-wrap input[name='label']").on 'blur', ->
      labelFields = $(@).parents('.form-wrap:visible').find('label.field-label')

      counts = _countDuplicateLabel(labelFields)

      $.each counts, (labelText, numberOfField) ->
        $(labelFields).each (index, label) ->
          if (numberOfField == 1) && (label.textContent == labelText)
            _removeDuplicateWarning(label)

          else if (numberOfField > 1) && (label.textContent == labelText)
            _addDuplicateWarning(label)

      errors = $('.form-wrap:visible').find('label.error')
      unless errors.length > 0
        $('.steps ul li.current').removeClass('error')

  _countDuplicateLabel = (element) ->
    labels = []
    $(element).each (index, label) ->
        labels.push $(label).text()

    counts = {}
    labels.forEach (x) ->
      counts[x] = (counts[x] or 0) + 1

    counts

  _removeDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field') 
    $(parentElement).removeClass('has-error')
    $(parentElement).find('label.error').remove()
    $(parentElement).find('input, textarea, select').removeClass('error')

  _addDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field') 
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append('<label class="error">Field labels must be unique, please click the edit icon to set a unique field label</label>')

  _initProgramSteps = ->
    self = @
    form = $('#program-stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#description').is(':visible')
          form.valid()
          name = $('#program_stream_name').val() == ''
          return false if name
        else if $('#enrollment').is(':visible')
          return false if _handleCheckingDuplicateFields()
        else if $('#trackings').is(':visible')
          return false if _handleCheckingDuplicateFields()
        else if $('#exit-program').is(':visible')
          return false if _handleCheckingDuplicateFields()
        
        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        _stickyFill()
        _editTrackingFormName()
        _handleEditLabelName()
        buttonSave = $('#program_stream_submit')
        if $('#exit-program').is(':visible') then $(buttonSave).hide() else $(buttonSave).show()

      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Finish")').removeAttr('href')
        _handleRemoveUnuseInput()
        _handleAddRuleBuilderToInput()
        _handleSetValueToField()
        form.submit()
      labels:
        finish: self.filterTranslation.save
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous

  _handleClickAddTracking = ->
    if $('#trackings .frmb').length == 0
      $('.links a').trigger('click')

  _handleInitProgramFields = ->
    for element in $('#enrollment, #exit-program')
      dataElement = $(element).data('field')
      _initProgramBuilder($(element), (dataElement || []))

    trackings = $('.tracking-builder')
    for tracking in trackings
      trackingValue = $(tracking).data('tracking')
      _initProgramBuilder(tracking, (trackingValue || []))

  _initButtonSave = ->
    form = $('form')
    btnSaveTranslation = filterTranslation.save
    form.find("[aria-label=Pagination]").append("<li><span id='program_stream_submit' class='btn btn-primary btn-sm'>#{btnSaveTranslation}</span></li>")

  _handleRemoveUnuseInput = ->
    elements = $('#program-rule ,#enrollment .form-wrap.form-builder, #tracking .form-wrap.form-builder, #exit-program .form-wrap.form-builder')
    $(elements).find('input, select, radio, checkbox, textarea').remove()

  _preventDuplicateFormBuilder = (element) ->
    $(element).children().hasClass('form-builder')

  _handleAddRuleBuilderToInput = ->
    rules = $('#program-rule').queryBuilder('getRules')
    $('ul.rules-list li').removeClass('has-error') if ($.isEmptyObject(rules))
    $('#program_stream_rules').val(_handleStringfyRules(rules)) if !($.isEmptyObject(rules))

  _handleSetValueToField = ->
    for formBuilder in @formBuilder
      element = formBuilder.element
      if $(element).is('#enrollment')
        $('#program_stream_enrollment').val(formBuilder.formData)
      else if $(element).is('.tracking-builder')
        hiddenField = $(element).find('.tracking-field-hidden input[type="hidden"]')
        $(hiddenField).val(formBuilder.formData)
      else if $(element).is('#exit-program')
        $('#program_stream_exit_program').val(formBuilder.formData)

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  _addFooterForSubmitForm = ->
    $('.actions.clearfix').addClass('ibox-footer')

  { init: _init }
