CIF.Program_streamsNew = CIF.Program_streamsEdit = CIF.Program_streamsCreate = CIF.Program_streamsUpdate = do ->
  @programStreamId = $('#program_stream_id').val()

  ENTITY_TYPE      = $("#program_stream_entity_type").val()
  ENROLLMENT_URL   = "/api/program_streams/#{@programStreamId}/enrollment_fields" + "?entity_type=#{ENTITY_TYPE}"
  EXIT_PROGRAM_URL = "/api/program_streams/#{@programStreamId}/exit_program_fields"
  TRACKING_URL     = "/api/program_streams/#{@programStreamId}/tracking_fields" + "?entity_type=#{ENTITY_TYPE}"
  TRACKING = ''
  DATA_TABLE_ID = ''
  @formBuilder = []
  @window.getServiceData = (td)->
    data = {id: td.children[0].value, text: td.children[0].text }

    newOption = new Option(data.text, data.id, true, true)
    # Append it to the select
    $('#type-of-service select').append(newOption).trigger 'change'

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
    _handleShowTracking()
    _handleHideTracking()
    _initSelect2TimeOfFrequency()
    _handleRemoveFrequency()
    _handleSelectFrequency()
    _initFrequencyNote()
    _editTrackingFormName()
    _custom_field_list()
    _initDataTable()
    _filterSelecting()
    _selectServiceTypeTableResult()
    _handleTimeOfFrequencyInput()

  _initDataTable = ->
    $('.custom-field-table').each ->
      self = @
      $(@).DataTable
        bFilter: false
        sScrollY: '500'
        bInfo: false
        processing: true
        serverSide: true
        ajax: $(this).data('url')
        columns: [
          null
          null
          null
          bSortable: false, className: 'text-center'
        ]
        language:
          paginate:
            previous: $(self).data('previous')
            next: $(self).data('next')
        drawCallback: ->
          _getDataTableId()
          _copyCustomForm(self)

  _getDataTableId = ->
    $('.paginate_button a').click ->
      DATA_TABLE_ID = $($(this).parents('.table-responsive').find('.custom-field-table')[1]).attr('id')

  _custom_field_list = ->
    $('.custom-field-list').click ->
      TRACKING = $(@).parents('.nested-fields')

  _copyCustomForm = (element)->
    self = @
    elementId = $(element).attr('id')
    $("##{elementId} .copy-form").click ->
      fields = $(@).data('fields')
      for formBuilder in self.formBuilder
        element = formBuilder.element
        if $(element).is('.tracking-builder') && $('#trackings').is(':visible')
          builderId = $(TRACKING).attr('id')
          formBuilderId = $(formBuilder.element).parents('.nested-fields').attr('id')
          if formBuilderId == builderId
            _addFieldProgramBuilder(formBuilder, fields)
            setTimeout ( ->
              document.getElementById(builderId).scrollIntoView()
            )
      $('#custom-field').modal('hide')

  _addFieldProgramBuilder = (formBuilder, fields) ->
    specialCharacters = { '&amp;': '&', '&lt;': '<', '&gt;': '>', "&qoute;": '"' }
    format = new CIF.FormatSpecialCharacters()
    fields = format.formatSpecialCharacters(fields, specialCharacters)
    combineFields = JSON.parse(formBuilder.actions.save()).concat(fields)
    for field in fields
      formBuilder.actions.addField(field)

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
    $($('.icheckbox_square-green.checked')[0]).addClass('checked')

  _initSelect2 = ->
    $('#description select, #rule-tab select').select2()

  _initSelect2TimeOfFrequency = ->
    $('.program_stream_trackings_frequency select, .allowed_edit_until').select2
      minimumInputLength: 0
      allowClear: true

  _handleRemoveProgramList = ->
    programExclusive = $('#program_stream_program_exclusive')
    mutualDependence = $('#program_stream_mutual_dependence')
    _selectOptonProgramExclusive(programExclusive, mutualDependence)
    _selectOptonMutualDependence(programExclusive, mutualDependence)

  _selectOptonProgramExclusive = (programExclusive, mutualDependence) ->
    if $(programExclusive).val() != null
      for value in $(programExclusive).val()
        $(mutualDependence).find("option[value=#{value}]").attr('disabled', true)

    $(programExclusive).on 'select2-selecting', (select)->
      $(mutualDependence).find("option[value=#{select.val}]").attr('disabled', true)

    $(programExclusive).on 'select2-removed', (select)->
      $(mutualDependence).find("option[value=#{select.val}]").removeAttr('disabled')

  _selectOptonMutualDependence = (programExclusive, mutualDependence) ->
    if $(mutualDependence).val() != null
      for value in mutualDependence.val()
        $(programExclusive).find("option[value=#{value}]").attr('disabled', true)

    $(mutualDependence).on 'select2-selecting', (select)->
      $(programExclusive).find("option[value=#{select.val}]").attr('disabled', true)

    $(mutualDependence).on 'select2-removed', (select)->
      $(programExclusive).find("option[value=#{select.val}]").removeAttr('disabled')

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

  _preventProgramStreamWithoutTracking = ->
    if $('#program_stream_tracking_required:visible').is(':unchecked')
      trackings = $('.nested-fields[style!="display: none;"]')
      if trackings.size() > 0
        for tracking in trackings
          trackingName = $(tracking).find('.program_stream_trackings_name:visible input[type="text"]').val()
          forms = $(tracking).find('.field-label').size()
          if (trackingName && trackingName.trim() == '') || forms < 1
            return true
      else
        return true

  _handleSaveProgramStream = ->
    $('#btn-save-draft').on 'click', ->
      # prevent saving if name or services is blank on first step
      if $('#description').is(':visible')
        form = $('#program-stream')
        form.valid()
        name = $('#program_stream_name').val() == ''
        services = $('#type-of-service select').val() == null
        serviceSelect2 = $('.program_stream_services')
        _handleServiceValidation(services, serviceSelect2)
        return false if name || services

      labelFields = $('[name="label"].fld-label')
      for labelField in labelFields
        labelField.textContent = labelField.textContent.replace(/;/g, '')

      if $('#trackings').is(':visible')
        _checkDuplicateTrackingName()
      if _preventProgramStreamWithoutTracking()
        messageWarning = $('#trackings').data('complete-tracking')
        return alert(messageWarning)
      return false unless _handleCheckingDuplicateFields()
      return false if _handleMaximumProgramEnrollment()
      return false if _handleCheckingInvalidRuleValue() > 0
      return false if $('.program_stream_trackings_name input.error').size() > 1
      _handleAddRuleBuilderToInput()
      _handleSetValueToField()
      $('.tracking-builder').find('input, textarea').removeAttr('required')
      $('#btn-save-draft').css('pointer-events', 'none')
      btnSaving = $('.program-steps').data('saving')
      $('#btn-save-draft').attr('disabled', 'disabled').text(btnSaving)
      $('#program-stream').submit()

  _handleSetRules = ->
    rules = $('#program_stream_rules').val()
    rules = JSON.parse(rules)
    $('#program-rule').queryBuilder('setRules', rules) unless _.isEmpty(rules.rules)
    $('#rule-tab select').select2(width: 'resolved')

  _addRuleCallback = ->
    $('#program-rule').on 'afterCreateRuleFilters.queryBuilder', ->
      $('#rule-tab select').select2(width: 'resolved')
      _handleSelectOptionChange()
      _filterSelecting()

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#program-rule').data('filter-translation-add-filter')
      addGroup: $('#program-rule').data('filter-translation-add-group')
      deleteGroup: $('#program-rule').data('filter-translation-delete-group')
      finish: $('.program-steps').data('finish')
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
    url = '/api/program_stream_add_rule/get_fields' + '?entity_type=' + ENTITY_TYPE
    $.ajax
      url: url
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        builder = new CIF.AdvancedFilterBuilder($('#program-rule'), fieldList, filterTranslation)
        builder.initRule()
        setTimeout (->
          _handleSelectTab()
          $('#rule-tab select').select2(width: 'resolved')
          _opertatorSelecting()
          ), 100
        _handleSetRules()
        _handleSelectOptionChange()
        _checkingForDisableOptions()

  _handleAddCocoon = ->
    $('#trackings').on 'cocoon:after-insert', (e, element) ->
      trackingBuilder = $(element).find('.tracking-builder')
      $(element).attr('id', Date.now())
      _initProgramBuilder(trackingBuilder, [])
      _editTrackingFormName()
      _handleRemoveCocoon()
      _initSelect2TimeOfFrequency()
      _handleRemoveFrequency()
      _handleSelectFrequency()
      _initFrequencyNote()
      _custom_field_list()
      _initCheckbox()

  _initProgramBuilder = (element, data) ->
    builderOption = new CIF.CustomFormBuilder()
    specialCharacters = { '&amp;': '&', '&lt;': '<', '&gt;': '>', "&qoute;": '"' }
    format = new CIF.FormatSpecialCharacters()
    fields = format.formatSpecialCharacters(data, specialCharacters)

    formBuilder = $(element).formBuilder(
      templates: separateLine: (fieldData) ->
        { field: '<hr/>' }
      fields: builderOption.thematicBreak()
      dataType: 'json'
      formData: JSON.stringify(fields)
      disableFields: ['autocomplete', 'header', 'hidden', 'button', 'checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }
      stickyControls: {
        enable: true
        offset:
          width: '17%'
          right: 78
          left: 'auto'
      }
      typeUserEvents: {
        'checkbox-group': builderOption.eventCheckboxOption()
        date: builderOption.eventDateOption()
        file: builderOption.eventFileOption()
        number: builderOption.eventNumberOption()
        'radio-group': builderOption.eventRadioOption()
        select: builderOption.eventSelectOption()
        text: builderOption.eventTextFieldOption()
        textarea: builderOption.eventTextAreaOption()
        separateLine: builderOption.eventSeparateLineOption()
        paragraph: builderOption.eventParagraphOption()
      })
    formBuilder.element = element
    @formBuilder.push formBuilder

   _editTrackingFormName = ->
    inputNames = $(".program_stream_trackings_name input[type='text']")
    $(inputNames).on 'input', ->
      _checkDuplicateTrackingName()

  _checkDuplicateTrackingName = ->
    nameFields = $('.program_stream_trackings_name:visible input[type="text"]')
    values    = $(nameFields).map(-> $(@).val().trim()).get()

    duplicateValues = Object.values(values.getDuplicates())
    indexs    = [].concat.apply([], duplicateValues)

    noneDuplicates = values.elementWitoutDuplicates()
    $(nameFields).each (index, element) ->
      inputWrapper = $(element).parent()
      if indexs.includes(index)
        $(element).addClass('error')
        unless $(inputWrapper).find('label.error').is(':visible')
          $(inputWrapper).append('<label class="error">Tracking name must be unique</label>')
      else if $(element).val() == ''
        if $(inputWrapper).find('label.error').length == 0
          $(inputWrapper).append("<label class='error'>Field can not be blank.</label>")
          $(inputWrapper).addClass('has-error')
          $(element).addClass('error')
      else if $(element).val() != '' or $(element).val() != undefined
        $(element).removeClass('error')
        $(inputWrapper).removeClass('has-error')
        if $(inputWrapper).find('label.error').is(':visible')
          $(inputWrapper).find('label.error').remove()

  _handleRemoveCocoon = ->
    $('#trackings').on 'cocoon:after-remove', ->
      _checkDuplicateTrackingName()

  _handleCheckingDuplicateFields = ->
    errorNumber = $('.form-wrap.form-builder:visible').find('.has-error').size()
    if errorNumber > 0 then false else true

  _initProgramSteps = ->
    self = @
    form = $('#program-stream')

    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'
      enableKeyNavigation: false

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#description').is(':visible')
          form.valid()
          name = $('#program_stream_name').val() == ''
          services = $('#type-of-service select').val() == null
          serviceSelect2 = $('.program_stream_services')
          _handleServiceValidation(services, serviceSelect2)

          return false if name || services
        else if $('#trackings').is(':visible')
          _checkDuplicateTrackingName()
          return true if $('#trackings').hasClass('hide-tracking-form')
          return _handleCheckingDuplicateFields() and _handleCheckTrackingName() and _checkTimeOfFrequencyInput(currentIndex)
        else if $('#enrollment, #exit-program').is(':visible')
          return _handleCheckingDuplicateFields()
          return false if _handleCheckingDuplicateFields()
        else if $('#rule-tab').is(':visible')
          return false if _handleCheckingInvalidRuleValue() > 0
          return false if _handleMaximumProgramEnrollment()
        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        _handleRemoveUnusedOptionFormBuilder()
        buttonSave = $('#btn-save-draft')
        if $('#rule-tab').is(':visible')
          _handleRemoveProgramList()
        else if $('#exit-program').is(':visible') then $(buttonSave).hide() else $(buttonSave).show()

      onFinishing: () ->
        labelFields = $('[name="label"].fld-label')
        for labelField in labelFields
          labelField.textContent = labelField.textContent.replace(/;/g, '')
      onFinished: (event, currentIndex) ->
        return false unless _handleCheckingDuplicateFields()
        _handleAddRuleBuilderToInput()
        _handleSetValueToField()
        if _preventProgramStreamWithoutTracking()
          messageWarning = $('#trackings').data('complete-tracking')
          return alert(messageWarning)

        $('a[href="#finish"]').css('pointer-events', 'none')
        btnSaving = $('.program-steps').data('saving')
        $('a[href="#finish"]').addClass('btn btn-xs disabled').css('font-size', '95%').text(btnSaving)
        form.submit()

      labels:
        finish: self.filterTranslation.finish
        next: self.filterTranslation.next
        previous: self.filterTranslation.previous

  _handleRemoveUnusedOptionFormBuilder = ->
    if $('#enrollment').is(':visible')
      _handlePreventRemoveFieldFormBuilderProgramStream(ENROLLMENT_URL, '#enrollment')
    else if $('#trackings').is(':visible')
      _handlePreventRemoveFieldFormBuilderProgramStream(TRACKING_URL, '#trackings')
    else if $('#exit-program').is(':visible')
      _handlePreventRemoveFieldFormBuilderProgramStream(EXIT_PROGRAM_URL, '#exit-program')

  _handleServiceValidation = (services, serviceSelect2) ->
    if services
      serviceSelect2.append("<label class='error'>Field can not be blank.</label>")
      serviceSelect2.addClass('has-error')
      $('#type-of-service select').addClass('error')
    else
      serviceSelect2.remove("label.error")
      serviceSelect2.removeClass('has-error')
      $('#type-of-service select').removeClass('error')

  _handleCheckingInvalidRuleValue = ->
    invalidIntValues = $('.rule-value-container input[type=number].error').size()
    invalidStrValues = 0
    ruleOperator = ['is_empty', 'is_not_empty']

    strValues = $('.rule-value-container input')
    for strValue in strValues
      elementParent = $(strValue).parent()
      operator = $(elementParent).siblings('.rule-operator-container').find('select').val()
      if $(strValue).val() == '' and !($(strValue).attr('class').includes('select2')) and !(ruleOperator.includes(operator))
        $(strValue).addClass('error')
        $(elementParent).append("<label class='error'>Field can not be blank.</label>") unless $(elementParent).find('label.error').is(':visible')
        invalidStrValues++

    invalidValues = invalidIntValues + invalidStrValues

  _handleCheckTrackingName = ->
    nameFields = $('.program_stream_trackings_name:visible input[type="text"].error')
    if $(nameFields).length > 0 then false else true

  _handleClickAddTracking = ->
    if $('#trackings .nested-fields').length == 0
      $('.links a').trigger('click')

  _handleInitProgramFields = ->
    for element in $('#enrollment, #exit-program')
      dataElement = JSON.parse($(element).children('span').text())
      _initProgramBuilder($(element), (dataElement || []))

      if element.id == 'enrollment' and $('#program_stream_id').val() != ''
        _preventRemoveField(ENROLLMENT_URL, '#enrollment')
      else if element.id == 'exit-program' and $('#program_stream_id').val() != ''
        _preventRemoveField(EXIT_PROGRAM_URL, '#exit-program')

    trackings = $('.tracking-builder')
    for tracking in trackings
      trackingValue = JSON.parse($(tracking).children('span').text())
      _initProgramBuilder(tracking, (trackingValue || []))
    _preventRemoveField(TRACKING_URL, '') if $('#program_stream_id').val() != ''

  _initButtonSave = ->
    form               = $('form#program-stream')
    btnSaveTranslation = filterTranslation.save
    form.find("[aria-label=Pagination]").append("<li><span id='btn-save-draft' class='btn btn-primary btn-sm'>#{btnSaveTranslation}</span></li>")

  _handleAddRuleBuilderToInput = ->
    rules = $('#program-rule').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
    $('#program_stream_rules').val(_handleStringfyRules(rules))

  _handleSetValueToField = ->
    for formBuilder in @formBuilder
      element = formBuilder.element
      specialCharacters = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&qoute;" }
      format = new CIF.FormatSpecialCharacters()
      fields = format.formatSpecialCharacters(JSON.parse(formBuilder.actions.save()), specialCharacters)
      fields = JSON.stringify(fields)
      if $(element).is('#enrollment')
        $('#program_stream_enrollment').val(fields)
      else if $(element).is('.tracking-builder')
        hiddenField = $(element).find('.tracking-field-hidden input[type="hidden"]')
        $(hiddenField).val(fields)
      else if $(element).is('#exit-program')
        $('#program_stream_exit_program').val(fields)

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  _addFooterForSubmitForm = ->
    $('.actions.clearfix').addClass('ibox-footer')

  _handleHideTracking = ->
    if $('#program_stream_tracking_required').prop('checked')
      $('#trackings').addClass('hide-tracking-form')
    $('#program_stream_tracking_required').on 'ifChecked', ->
      $('#trackings').addClass('hide-tracking-form')

  _handleShowTracking = ->
    $('#program_stream_tracking_required').on 'ifUnchecked', ->
      $('#trackings').removeClass('hide-tracking-form')

  _preventRemoveField = (url, elementId) ->
    return false if @programStreamId == ''
    specialCharacters = { "&": "&amp;", "<": "&lt;", ">": "&gt;" }

    $.ajax
      method: 'GET'
      url: url
      dataType: "JSON"
      success: (response) ->
        if response.field == 'tracking'
          _hideActionInTracking(response)
        else
          fields = response.program_streams
          labelFields = $(elementId).find('label.field-label')

          for labelField in labelFields
            text = labelField.textContent.allReplace(specialCharacters)
            if fields.includes(text)
              _removeActionFormBuilder(labelField, elementId)

  _hideActionInTracking = (fields) ->
    trackings = $('#trackings .nested-fields')
    specialCharacters = { '&amp;': '&', '&lt;': '<', '&gt;': '>' }
    for tracking in trackings
      trackingName = $(tracking).find('input.string.optional.readonly.form-control')
      continue if $(trackingName).length == 0
      name = $(trackingName).val()
      labelFields = $(tracking).find('label.field-label')
      # if fields[name].length <= labelFields.length
      #   $(tracking).find('.ibox-footer .remove_fields').remove()
      $(labelFields).each (index, label) ->
        text = label.textContent.allReplace(specialCharacters)

        if fields[name].includes(text)
          _removeActionFormBuilderTracking(label)

  _removeActionFormBuilder = (label, elementId='') ->
    if elementId.present? and $(elementId).is(':visible')
      $('li.paragraph-field.form-field').find('.del-button, .copy-button').remove()
      parent = $(label).parent()
      $(parent).find('.del-button, .copy-button').remove()

  _handlePreventRemoveFieldFormBuilderProgramStream = (url, elementId) ->
    return false if @programStreamId == ''
    specialCharacters = { "&": "&amp;", "<": "&lt;", ">": "&gt;" }

    $.ajax
      method: 'GET'
      url: url
      dataType: "JSON"
      success: (response) ->
        if response.field == 'tracking'
          _hideActionInTrackingProgramStream(response)
        else
          fields = response.program_streams
          labelFields = $(elementId).find('label.field-label')

          for labelField in labelFields
            text = labelField.textContent.allReplace(specialCharacters)
            if fields.includes(text)
              _removeActionFormBuilderProgramStream(labelField)

  _hideActionInTrackingProgramStream = (fields) ->
    trackings = $('#trackings .nested-fields')
    specialCharacters = { '&amp;': '&', '&lt;': '<', '&gt;': '>' }
    for tracking in trackings
      # trackingName = $(tracking).find('input.string.optional.readonly.form-control')
      trackingName = $(tracking).find('input.string.optional.form-control')
      continue if $(trackingName).length == 0
      name = $(trackingName).val()
      labelFields = $(tracking).find('label.field-label')
      if fields[name] && fields[name].length <= labelFields.length
        $(tracking).find('.ibox-footer .remove_fields').remove()

      $(labelFields).each (index, label) ->
        text = label.textContent.allReplace(specialCharacters)

        if fields[name].includes(text)
          _removeActionFormBuilderProgramStream(label)

  _removeActionFormBuilderProgramStream = (label) ->
    parent = $(label).parent()
    $(parent).find('.del-button, .copy-button').remove()

    if $('#enrollment').is(':visible')
      _removeActionFormBuilderEnrollment(label)
    else if $('#trackings').is(':visible')
      _removeActionFormBuilderTracking(label)
    else if $('#exit-program').is(':visible')
      _removeActionFormBuilderExitProgram(label)

  _removeActionFormBuilderEnrollment= (label) ->
    parent = $(label).parent()
    $(parent).find('.del-button, .copy-button').remove()
    if $(parent).attr('class').includes('checkbox-group-field')
        allCheckboxOption = $('#enrollment .checkbox-group-field .sortable-options .ui-sortable-handle .option-label')
        enrollmentCheckbox = $('div[data-enrollment_checkbox_option]').data('enrollment_checkbox_option')
        jQuery.map(allCheckboxOption, (e) ->
          enrollmentCheckbox.forEach (enrollment_checkbox_value) ->
            if enrollment_checkbox_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('radio-group-field')
        allRadioOption = $('#enrollment .radio-group-field .sortable-options .ui-sortable-handle .option-label')
        enrollmentRadio = $('div[data-enrollment_radio_option]').data('enrollment_radio_option')
        jQuery.map(allRadioOption, (e) ->
          enrollmentRadio.forEach (enrollment_radio_value) ->
            if enrollment_radio_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('select-field')
        allSelectOption  = $('#enrollment .select-field .sortable-options .ui-sortable-handle .option-label')
        enrollmentSelect = $('div[data-enrollment-select-option]').data('enrollment-select-option')
        jQuery.map(allSelectOption, (e) ->
          enrollmentSelect.forEach (enrollment_selected_value) ->
            if enrollment_selected_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )

  _removeActionFormBuilderTracking = (label) ->
    parent = $(label).parent()
    $(parent).find('.del-button, .copy-button').remove()

    if $(parent).attr('class').includes('checkbox-group-field')
        allCheckboxOption = $('#trackings .checkbox-group-field .sortable-options .ui-sortable-handle .option-label')
        trackingCheckbox = $('div[data-tracking_checkbox_option]').data('tracking_checkbox_option')
        jQuery.map(allCheckboxOption, (e) ->
          if trackingCheckbox != ""
            trackingCheckbox.forEach (tracking_checkbox_value) ->
              if tracking_checkbox_value == e.value
                $(e).attr('disabled', 'true')
                $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('radio-group-field')
        allRadioOption = $('#trackings .radio-group-field .sortable-options .ui-sortable-handle .option-label')
        trackingRadio = $('div[data-tracking_radio_option]').data('tracking_radio_option')
        jQuery.map(allRadioOption, (e) ->
          if trackingRadio != ""
            trackingRadio.forEach (tracking_radio_value) ->
              if tracking_radio_value == e.value
                $(e).attr('disabled', 'true')
                $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('select-field')
        allSelectOption = $('#trackings .select-field .sortable-options .ui-sortable-handle .option-label')
        trackingSelect = $('div[data-tracking-select-option]').data('tracking-select-option')
        jQuery.map(allSelectOption, (e) ->
           if trackingSelect != ""
            trackingSelect.forEach (tracking_selected_value) ->
              if tracking_selected_value == e.value
                $(e).attr('disabled', 'true')
                $(e).parent().children('a.remove.btn').remove()
        )

  _removeActionFormBuilderExitProgram = (label) ->
    parent = $(label).parent()
    $(parent).find('.del-button, .copy-button').remove()

    if $(parent).attr('class').includes('checkbox-group-field')
        allCheckboxOption = $('#exit-program .checkbox-group-field .sortable-options .ui-sortable-handle .option-label')
        exitingProgramCheckbox = $('div[data-exit_program_checkbox_option]').data('exit_program_checkbox_option')
        jQuery.map(allCheckboxOption, (e) ->
          exitingProgramCheckbox.forEach (exiting_checkbox_value) ->
            if exiting_checkbox_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('radio-group-field')
        allRadioOption = $('#exit-program .radio-group-field .sortable-options .ui-sortable-handle .option-label')
        exitingProgramRadio = $('div[data-exit_program_radio_option]').data('exit_program_radio_option')
        jQuery.map(allRadioOption, (e) ->
          exitingProgramRadio.forEach (exiting_radio_value) ->
            if exiting_radio_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )
    else if $(parent).attr('class').includes('select-field')
        allSelectOption = $('#exit-program .select-field .sortable-options .ui-sortable-handle .option-label')
        exitingProgramSelect = $('div[data-exit_program-select-option]').data('exit_program-select-option')
        jQuery.map(allSelectOption, (e) ->
          exitingProgramSelect.forEach (exiting_selected_value) ->
            if exiting_selected_value == e.value
              $(e).attr('disabled', 'true')
              $(e).parent().children('a.remove.btn').remove()
        )

  _initFrequencyNote = ->
    for nestedField in $('.nested-fields')
      select        = $(nestedField).find('.program_stream_trackings_frequency select')
      timeFrequency = $(nestedField).find('.program_stream_trackings_time_of_frequency input')
      elementNote   = $(nestedField).find('.frequency-note')
      frequency     = _convertFrequency($(select).val())
      value         = parseInt(timeFrequency.val())
      $(timeFrequency).attr(readonly: true) if frequency == ''
      _updateFrequencyNote(value, frequency, elementNote) if value > 0
      _timeOfFrequencyChange(timeFrequency, frequency, elementNote)

  _handleRemoveFrequency = ->
    frequencies = $('.program_stream_trackings_frequency select')
    $(frequencies).on 'select2-removed', (element) ->
      select          = element.currentTarget
      nestedField     = $(select).parents('.nested-fields')
      timeOfFrequency = $(nestedField).find('.program_stream_trackings_time_of_frequency input')
      $(nestedField).find('.frequency-note i').text('')
      $(timeOfFrequency).val(0)
      $(timeOfFrequency).attr(readonly: true)

  _handleSelectFrequency = ->
    frequencies = $('.program_stream_trackings_frequency select')
    $(frequencies).on 'select2-selecting', (element) ->
      select          = element.currentTarget
      frequencyNote   = select.parentElement.nextElementSibling
      frequencyValue  = _convertFrequency(element.val)

      nested = $(select).parents('.nested-fields')
      timeOfFrequency = $(nested).find('.program_stream_trackings_time_of_frequency input')
      $(timeOfFrequency).removeAttr('readonly')
      $(timeOfFrequency).val(1) if $(timeOfFrequency).val() <= 0
      value = parseInt($(timeOfFrequency).val())
      _updateFrequencyNote(value, frequencyValue, frequencyNote)
      _timeOfFrequencyChange(timeOfFrequency, frequencyValue, frequencyNote)

  _timeOfFrequencyChange = (timeOfFrequency, frequencyValue, frequencyNote) ->
    $(timeOfFrequency).on 'change', ->
      value = parseInt($(@).val())
      $(@).val(0) if value < 0
      _updateFrequencyNote(value, frequencyValue, frequencyNote)

  _updateFrequencyNote = (value, frequency, element) ->
    frequencyNote = 'This needs to be done once every'
    single = "#{frequencyNote} #{frequency}"
    plural = "#{frequencyNote} #{value} #{frequency}s"
    frequencNoteUpdate = if value == 1 then single else if value > 1 then plural
    $(element).find('i').text('')
    $(element).find('i').text(frequencNoteUpdate) if value > 0

  _convertFrequency = (frequency)->
    switch(frequency)
      when 'Daily'
        frequency = 'day'
      when 'Weekly'
        frequency = 'week'
      when 'Monthly'
        frequency = 'month'
      when 'Yearly'
        frequency = 'year'
      else
        frequency = ''

  _handleMaximumProgramEnrollment = ->
    quantity = $('#program_stream_quantity')
    if $(quantity).val() < $(quantity).data('maximun') && $(quantity).val() != ''
      $('.help-block.quantity').removeClass('hidden')
      return true
    else
      $('.help-block.quantity').addClass('hidden')
      return false

  _customFieldsFixedHeader = ->
    $('table.custom-field-table').dataTable(
      'bFilter': false
      'bSort': false
      'sScrollY': '500'
      'bInfo': false
      'bLengthChange': false
      'bPaginate': false
    )

  _checkingForDisableOptions = ->
    for element in $('.rule-operator-container select')
      _disableOptions(element)

  _filterSelecting = ->
    $('.rule-filter-container select').on 'select2-selecting', ->
      self = @
      setTimeout ( ->
        _opertatorSelecting()
      )

  _opertatorSelecting = ->
    $('.rule-operator-container select').on 'select2-selected', ->
      _disableOptions(@)
      _setDefaultBetweenSchoolGrade(@)

  _disableOptions = (element) ->
    self = @
    rule = $(element).parent().siblings('.rule-filter-container').find('option:selected').val()
    if rule.split('__')[0] == 'domainscore'
      ruleValueContainer = $(element).parent().siblings('.rule-value-container')
      if $(element).find('option:selected').val() == 'greater'
        $(ruleValueContainer).find("option[value=4]").attr('disabled', 'disabled')
        $(ruleValueContainer).find("option[value=1]").removeAttr('disabled')
        if $(ruleValueContainer).find('option:selected').val() == '4'
          $(ruleValueContainer).find('select').val('1').trigger('change')
      else if $(element).find('option:selected').val() == 'less'
        $(ruleValueContainer).find("option[value='1']").attr('disabled', 'disabled')
        $(ruleValueContainer).find("option[value='4']").removeAttr('disabled')
        if $(ruleValueContainer).find("option:selected").val() == '1'
          $(ruleValueContainer).find('select').val('2').trigger('change')
      else
        $(ruleValueContainer).find("option[value='4']").removeAttr('disabled')
        $(ruleValueContainer).find("option[value='1']").removeAttr('disabled')
    else if rule == 'school_grade'
      select = $(element).parent().siblings('.rule-value-container')
      disableValue = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8']
      if $(element).val() == 'between'
        setTimeout( ->
          for value in disableValue
            $(select).find("option[value='#{value}']").attr('disabled', 'true')
        , 100)

    setTimeout( ->
      _initSelect2()
    )

  _setDefaultBetweenSchoolGrade = (element) ->
    self = @
    rule = $(element).parent().siblings('.rule-filter-container').find('option:selected').val()
    if rule == 'school_grade'
      select = $(element).parent().siblings('.rule-value-container')
      if $(element).val() == 'between'
        setTimeout( ->
          $(select).find('select').val('1').trigger('change')
        , 100)

  _selectServiceTypeTableResult = () ->
    if $('li').hasClass('first current')
      # $('#type-of-service select').select2()

      format = (state) ->
        if !state.id
          return state.text

      serviceFormatSelection = (service) ->
        service.text

      $('#type-of-service select').select2
        width: '100%'
        formatSelection: serviceFormatSelection
        escapeMarkup: (m) ->
          m

      createHeaderElement = (options, indexes)->
        html = ""
        indexes.forEach (entry) ->
          html += "<th><b>#{options[entry][0]}</b></th>"
        html

      createRowElement = (options, indexes) ->
        html = ""
        indexes.forEach (entries) ->
          td = ""
          entries.forEach (index) ->
            td += "<td width='' onclick='getServiceData(this)'><option value='#{options[index][1]}'>#{options[index][0]}</option></td>"

          html += "<tr>#{td}</tr>"
        html

      $('#type-of-service select').on 'select2-open', (e) ->
        arr = []
        i = 0
        while i < $('#type-of-service').data('custom').length
          arr.push i
          i++

        options = $('#type-of-service').data('custom')
        results = []
        chunk_size = 13
        while arr.length > 0
          results.push arr.splice(0, chunk_size)

        indexes = results.shift()
        th  = createHeaderElement(options, indexes)
        row = createRowElement(options, results)

        html = '<table class="table table-bordered" style="margin-top: 5px;margin-bottom: 0px;"><thead>' + th + '</thead><tbody>' + row + '</tbody></table>'
        $('#select2-drop .select2-results').html $(html)
        # $('.select2-results').prepend "#{html}"
        return

      removeError = (element) ->
        element.removeClass('has-error')
        element.find('.help-block').remove()

      $('#type-of-service select').on 'select2-close', (e)->
        uniqueArray = _.compact(_.uniq($(this).val()))

        if uniqueArray.length > 3
          $(this.parentElement).append "<p class='help-block'>#{$('input#confirm-question').val()}</p>" if $(this.parentElement).find('.help-block').length == 0
          $(this.parentElement).addClass('has-error')

        return

      $('#type-of-service select').on 'select2-removed', ->
        uniqueArray = _.compact(_.uniq($(this).val()))
        if uniqueArray.length <= 3
          removeError($(this.parentElement))

  _checkTimeOfFrequencyInput = (currentIndex) ->
    timeOfFrencyInputs = $("#steps-uid-0-p-" + currentIndex + " .program_stream_trackings_time_of_frequency input")
    hasZeroValue = false
    for timeOfFrencyInput in timeOfFrencyInputs
      timeOfFrencyInputAttrIndex = timeOfFrencyInput.id.match(/\d+/g)[0]
      frequencyValue = $("#program_stream_trackings_attributes_#{timeOfFrencyInputAttrIndex}_frequency").val()
      if !_.isEmpty(frequencyValue) && $(timeOfFrencyInput).val() == '0'
        hasZeroValue = true
        setTimeout( ->
          document.getElementById(timeOfFrencyInput.id).scrollIntoView({ behavior: 'smooth', block: 'start' })
        , 100)
        return

    return !hasZeroValue


  _handleTimeOfFrequencyInput = ->
    $("input[id^='program_stream_trackings_attributes']").on 'input', ->
      if $(@).val() == "" || $(@).val() == "0"
        $(@).val(0)
        $(@).parent().addClass('has-error')
        $('#btn-save-draft').addClass('hide')
      else
        $('#btn-save-draft').removeClass('hide')
        $(@).parent().removeClass('has-error')


  { init: _init }
