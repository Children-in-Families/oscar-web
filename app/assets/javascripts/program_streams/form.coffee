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
    _handleInitProgramFields()
    _initButtonSave()
    _handleSaveProgramStream()
    _handleClickAddTracking()
    # _alertDuplicateWarning()
    # _removeDuplicateWarning()
    
  _stickyFill = ->
    if $('.form-wrap').is(':visible')
      $('.cb-wrap').Stickyfill()

  _initSelect2 = ->
    $('#rule-tab select').select2()

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
      if _duplicateFieldLable()
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
            _duplicateFieldLable()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _duplicateFieldLable()
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _duplicateFieldLable()

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _duplicateFieldLable()

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _duplicateFieldLable()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _duplicateFieldLable()
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _duplicateFieldLable()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
          onclone: (fld) ->
            setTimeout ( ->
              _duplicateFieldLable()
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
            _duplicateFieldLable()
        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
            _duplicateFieldLable()
      }

    }).data('formBuilder');

  _duplicateFieldLable = ->
    labelFields = $('.form-wrap:visible').find("ul li input[name='label']")
    # labelFields = $('.form-wrap:visible').find("label.field-label")
    # duplicateLabels = false
    # labels = []

    # $(labelFields).each (value, index) ->
    #   console.log value
    #   console.log index
    # for labelField in $(labelFields)
    #   labels.push $(labelField).text()
    #   # debugger
    #   i = 0
    #   for i in [i...labels.length]
    #     continue if i = labels.length-1
    #     if labels.includes($(labelFields).text())
    #       parentElement = $(labelFields).parents('li.form-field')
    #       $(parentElement).addClass('has-error')
    #       unless $(parentElement).find('label.error').is(':visible')
    #         $(parentElement).append('<label class="error">This field is duplicated.</label>')
    #       $(parentElement).find('input, textarea, select').addClass('error')          
    #       duplicateLabels = true 
    #     i++
    # debugger
    i = 0
    for i in [i..labelFields.length - 1]
      label = $(labelFields[i]).val()
      j = 0
      for j in [j..labelFields.length - 1]
        continue if i == j
        if label == $(labelFields[j]).val()
          parentElement = $(labelFields[i]).parents('li.form-field')
          $(parentElement).addClass('has-error')
          unless $(parentElement).find('label.error').is(':visible')
            $(parentElement).append('<label class="error">This field is duplicated.</label>')
          $(parentElement).find('input, textarea, select').addClass('error')          
          duplicateLabels = true 
    
    if duplicateLabels == true
      $('section:visible .text-danger').text('Duplicate fields')  
      return duplicateLabels

    # $(labelFields).each (index, label) ->
      # displayText = $(label).text()
      # $(labelFields).each (cIndex, cLabel) ->
      #   continue if cIndex == index
      #   cText = $(cLabel).text()
      #   if cText == displayText
      #     parentElement = $(label).parents('li.form-field')
      #     $(parentElement).addClass('has-error')
      #     unless $(parentElement).find('label.error').is(':visible')
      #       $(parentElement).append('<label class="error">This field is duplicated.</label>')
      #     $(parentElement).find('input, textarea, select').addClass('error')          
      #     duplicateLabels = true 


  _removeDuplicateWarning = ->
    $('.field-actions a.del-button').on 'click', (e) ->
      removedField = $(@).parents().children('label.field-label')
      labelFields = $('.form-wrap:visible').find('label.field-label')
      labels = []

      for labelField in $(labelFields)
        labels.push $(labelField).text()

      counts = {}
      labels.forEach (x) ->
        counts[x] = (counts[x] or 0) + 1

      if counts[$(removedField).text()] == 2
        # field = $(@)
        # $(labelFields).each (index, label)->
        for labelField in $(labelFields)
          debugger
          # if $(label).contentText == $(removedField).text()

      else if counts[$(removedField).text()] > 2
        $(removedField).parent().removeClass('has-error')
        $(removedField).parent().find('label.error').remove()
        $(removedField).parent().find('input, textarea, select').removeClass('error')

      # duplicatFields = $('.form-wrap:visible').find('label.error').text()

      # if duplicatFields.length == 2
        # $('li.form-field').find('label.error').remove()
        # $('li.form-field').removeClass('has-error')
        # $('li.form-field').find('input, textarea, select').removeClass('error')        
        # $('section:visible .text-danger').text('')
  
  _alertDuplicateWarning = ->
    $(".form-wrap:visible .input-wrap input[name='label']").on 'blur', ->
      labelFields = $('.form-wrap:visible').find('label.field-label')
      i = 0
      for i in [i..labelFields.length - 1]
        label = $(labelFields[i]).text()
        j = 0
        for j in [j..labelFields.length - 1]
          continue if i == j
          if label == $(labelFields[j]).text()
            $(labelFields[i]).parents('li.form-field').addClass('has-error')
            $(labelFields[i]).parents('li.form-field').append('<label class="error">This field is duplicated.</label>')
            $(labelFields[i]).parents('li.form-field').find('input, textarea, select').addClass('error')
          else
            $(labelFields[i]).parents('li.form-field').find('label.error').remove()
            $(labelFields[i]).parents('li.form-field').removeClass('has-error')
            $(labelFields[i]).parents('li.form-field').find('input, textarea, select').removeClass('error')
            $('section:visible .text-danger').text('')

  _initProgramSteps = ->
    self = @
    form = $('#program-stream')
    form.children('.program-steps').steps
      headerTag: 'h4'
      bodyTag: 'section'
      transitionEffect: 'slideLeft'

      onStepChanging: (event, currentIndex, newIndex) ->
        if currentIndex == 0 and newIndex == 1 and $('#program-rule').is(':visible')
          form.valid()
          name = $('#program_stream_name').val() == ''
          return false if $.isEmptyObject($('#program-rule').queryBuilder('getRules')) || name
        else if $('#enrollment').is(':visible')
          return false if _duplicateFieldLable()
        else if $('#tracking').is(':visible')
          return false if _duplicateFieldLable()
        else if $('#exit-program').is(':visible')
          return false if _duplicateFieldLable()
        
        $('section ul.frmb.ui-sortable').css('min-height', '266px')

      onStepChanged: (event, currentIndex, newIndex) ->
        _stickyFill()
        _alertDuplicateWarning()
        _removeDuplicateWarning()
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
