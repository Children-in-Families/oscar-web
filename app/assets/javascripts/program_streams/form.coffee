CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = CIF.Program_streamsShow = do ->
  @formBuilder = []
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _initProgramSteps()
    _initCheckbox()
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
    _handleRemoveProgramList()
    _handleShowTracking()
    _handleHideTracking()

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'

  _handleDisabledRulesInputs = ->
    disble = $('#program-rule').attr('data-disable')
    if disble == 'true'
      $('#program-rule').find('input, select, textarea, button').attr( 'disabled', 'disabled' )

  _stickyFill = ->
    if $('.form-wrap').is(':visible')
      $('.cb-wrap').Stickyfill()

  _initSelect2 = ->
    $('#description select, #rule-tab select').select2()

  _handleRemoveProgramList = ->
    $('#program_stream_program_exclusive').on 'change', ->
      $("#program_stream_mutual_dependence option:disabled").removeAttr('disabled')
      values = $(@).val()
      for value in values
        $("#program_stream_mutual_dependence option[value=#{value}]").attr('disabled', true)

    $('#program_stream_mutual_dependence').on 'change', ->
      $("#program_stream_program_exclusive option:disabled").removeAttr('disabled')
      values = $(@).val()
      for value in values
        $("#program_stream_program_exclusive option[value=#{value}]").attr('disabled', true)

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
    $('#btn-save-draft').on 'click', ->
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
        is_not_empty: 'is not blank'
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
      _handleRemoveCocoon()

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
            _handleCheckingForm(fld)
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
            ),50

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
            ),50

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm(fld)
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm(fld)
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
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
            _handleCheckingForm(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
            ),50

        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _handleCheckingForm(fld)
            ),50
      }
    }).data('formBuilder');

  _editTrackingFormName = ->
    $(".program_stream_trackings_name input[type='text']").on 'blur', ->
      allLabel = $('.nested-fields:visible').find(".program_stream_trackings_name input[type='text']")
      _checkDuplicateTrackingName(allLabel)

  _handleRemoveCocoon = ->
    $('#trackings').on 'cocoon:after-remove', ->
      allLabel = $('.nested-fields:visible').find(".program_stream_trackings_name input[type='text']")
      _checkDuplicateTrackingName(allLabel)

  _checkDuplicateTrackingName = (element)->
    nameFields = element

    counts = _countDuplicateLabel(nameFields)

    $.each counts, (nameText, numberOfField) ->
      return if nameText == ''
      $(nameFields).each (index, text) ->
        if (numberOfField == 1) && ($(text).val() == nameText)
          _removeDuplicateWarning(text)

        else if (numberOfField > 1) && ($(text).val() == nameText)
          _addDuplicateWarning(text)

    _removeTabErrorClass()

  _handleCheckingForm = (field={}) ->
    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      _handleRemoveCocoon()
      _editTrackingFormName()

    _handleDisplayDuplicateWarning(field)
    _handleDeleteField()
    _handleEditLabelName()

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

      _removeTabErrorClass()

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

      _removeTabErrorClass()

  _countDuplicateLabel = (element) ->
    labels = []

    $(element).each (index, label) ->
      if $(label).val() != ''
        labels.push $(label).val()
      else
        labels.push $(label).text()

    counts = {}
    labels.forEach (x) ->
      counts[x] = (counts[x] or 0) + 1

    counts

  _removeTabErrorClass = ->
    if $('#trackings').is(':visible')
      errors = $('.nested-fields:visible').find('label.error')
    else
      errors = $('.form-wrap:visible').find('label.error')

    if errors.length == 0
      $('.steps ul li.current').removeClass('error')

  _removeDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field')
    $(parentElement).removeClass('has-error')
    $(parentElement).find('input, textarea, select').removeClass('error')
    $(parentElement).find('label.error:last-child').remove()

    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      $(element).removeClass('error')
      $(element).parent().find('label.error').remove()

  _addDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field')
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append('<label class="error">Field labels must be unique, please click the edit icon to set a unique field label</label>')

    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      $(element).addClass('error')
      unless $(element).parent().find('label.error').is(':visible')
        $(element).parent().append('<label class="error">Tracking name must be unique</label>')


  _handleCheckingDuplicateFields = ->
    if $('#trackings').is(':visible')
      errorFields = $('.nested-fields:visible').find('label.error')
    else
      errorFields = $('.form-wrap').find('label.error')

    if $(errorFields).length > 0 then true else false

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
        else if currentIndex == 3 and newIndex == 4 and $('#trackings').is(':visible')
          return true if $('#trackings').hasClass('hide-tracking-form')
          _handleCheckTrackingName()
          return false if _handleCheckingDuplicateFields()
        else if $('#enrollment, #exit-program').is(':visible')
          return false if _handleCheckingDuplicateFields()

        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        _stickyFill()
        _editTrackingFormName()
        _handleEditLabelName()
        buttonSave = $('#btn-save-draft')
        if $('#exit-program').is(':visible') then $(buttonSave).hide() else $(buttonSave).show()
        _handleDisabledRulesInputs() if $('#rule-tab').is(':visible')

      onFinished: (event, currentIndex) ->
        $('.actions a:contains("Finish")').removeAttr('href')
        if _handleCheckingDuplicateFields()
          return false
        else
          _handleRemoveUnuseInput()
          _handleAddRuleBuilderToInput()
          _handleSetValueToField()
          form.submit()

      labels:
        finish: self.filterTranslation.save
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous

  _handleCheckTrackingName = ->
    trackingNames = $('.nested-fields .program_stream_trackings_name')
    for name in trackingNames
      if $(name).find('input').val() == ''
        $(name).find('input').addClass('error')
        $(name).append("<label class='error'>Tracking name can't be blank</label>") unless $(name).find('label.error').is(':visible')

  _handleClickAddTracking = ->
    if $('#trackings .frmb').length == 0
      $('.links a').trigger('click')

  _handleInitProgramFields = ->
    for element in $('#enrollment, #exit-program')
      dataElement = $(element).data('field')
      _initProgramBuilder($(element), (dataElement || []))
    _preventRemoveEnrollmentField()
    _preventRemoveExitProgramField()

    trackings = $('.tracking-builder')
    for tracking in trackings
      trackingValue = $(tracking).data('tracking')
      _initProgramBuilder(tracking, (trackingValue || []))
    _preventRemoveTrackingField()

  _initButtonSave = ->
    form = $('form')
    btnSaveTranslation = filterTranslation.save
    form.find("[aria-label=Pagination]").append("<li><span id='btn-save-draft' class='btn btn-primary btn-sm'>#{btnSaveTranslation}</span></li>")

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

  _handleHideTracking = ->
    if $('#program_stream_tracking').prop('checked')
      $('#trackings').addClass('hide-tracking-form')
    $('#program_stream_tracking').on 'ifChecked', ->
      $('#trackings').addClass('hide-tracking-form')

  _handleShowTracking = ->
    $('#program_stream_tracking').on 'ifUnchecked', ->
      $('#trackings').removeClass('hide-tracking-form')

  _preventRemoveEnrollmentField = ->
    fields = ''
    programStreamId = $('#program_stream_id').val()
    $.ajax({
      type: 'GET'
      url: "/api/program_streams/#{programStreamId}/enrollment_fields"
      dataType: "JSON"
    }).success((json)->
      fields = json.program_streams
      labelFields = $('#steps-uid-0-p-2 label.field-label')
      for labelField in labelFields
        parent = $(labelField).parent()
        for field in fields
          if labelField.textContent == field
            $(parent).children('div.field-actions').remove()
    )

  _preventRemoveExitProgramField = ->
    fields = ''
    programStreamId = $('#program_stream_id').val()
    $.ajax({
      type: 'GET'
      url: "/api/program_streams/#{programStreamId}/exit_program_fields"
      dataType: "JSON"
    }).success((json)->
      fields = json.program_streams
      labelFields = $('#steps-uid-0-p-4 label.field-label')
      for labelField in labelFields
        parent = $(labelField).parent()
        for field in fields
          if labelField.textContent == field
            $(parent).children('div.field-actions').remove()
    )

  _preventRemoveTrackingField = ->
    fields = ''
    programStreamId = $('#program_stream_id').val()
    $.ajax({
      type: 'GET'
      url: "/api/program_streams/#{programStreamId}/tracking_fields"
      dataType: "JSON"
    }).success((json)->
      fields = json
      trackings = $('#trackings .nested-fields')
      for tracking in trackings
        name = $(tracking).find('input.string.optional.readonly.form-control').val()
        labelFields = $(tracking).find('label.field-label')
        for labelField in labelFields
          parent = $(labelField).parent()
          for field in fields[name]
            if labelField.textContent == field
              $(parent).children('div.field-actions').remove()
              $(tracking).find('.ibox-footer').remove()
    )

  { init: _init }
