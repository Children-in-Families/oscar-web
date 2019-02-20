class CIF.ClientAdvanceSearch
  constructor: () ->
    @filterTranslation   = ''
    @customFormSelected  = []
    @programSelected     = []
    optionTranslation    = $('#opt-group-translation')

    @enrollmentCheckbox  = $('#enrollment-checkbox')
    @trackingCheckbox    = $('#tracking-checkbox')
    @exitCheckbox        = $('#exit-form-checkbox')
    @wizardEnrollmentCheckbox    = $('#wizard-enrollment-checkbox')
    @wizardTrackingCheckbox      = $('#wizard-tracking-checkbox')
    @wizardExitCheckbox          = $('#wizard-exit-form-checkbox')

    @CUSTOM_FORM_URL      = '/api/client_advanced_searches/get_custom_field'
    @ENROLLMENT_URL       = '/api/client_advanced_searches/get_enrollment_field'
    @TRACKING_URL         = '/api/client_advanced_searches/get_tracking_field'
    @EXIT_PROGRAM_URL     = '/api/client_advanced_searches/get_exit_program_field'

    @DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
    @BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
    @CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')

    @ENROLLMENT_TRANSLATE     = $(optionTranslation).data('enrollment')
    @TRACKING_TRANSTATE       = $(optionTranslation).data('tracking')
    @EXIT_PROGRAM_TRANSTATE   = $(optionTranslation).data('exitProgram')

    @QUANTITATIVE_TRANSLATE   = $(optionTranslation).data('quantitative')

  setValueToBuilderSelected: ->
    @customFormSelected = $('#custom-form-data').data('value')
    @programSelected    = $('#program-stream-data').data('value')
    @wizardCustomFormSelected = $('#wizard-custom-form-data').data('value')
    @wizardProgramSelected    = $('#wizard-program-stream-data').data('value')

  getTranslation: ->
    @filterTranslation =
      addFilter: $('#builder, #wizard-builder').data('filter-translation-add-filter')
      addGroup: $('#builder, #wizard-builder').data('filter-translation-add-group')
      deleteGroup: $('#builder, #wizard-builder').data('filter-translation-delete-group')

  formatSpecialCharacter: (value) ->
    filedName = value.toLowerCase().replace(/[^a-zA-Z0-9]+/gi, ' ').trim() || value.trim()
    filedName.replace(/ /g, '__')

  removeCheckboxColumnPicker: (element, name) ->
    $("#{element} ul.append-child li.#{name}").remove()

  filterSelectChange: ->
    self = @
    $('.rule-filter-container select').on 'select2-close', ->
      setTimeout ( ->
        self.initSelect2()
      )

  handleResizeWindow: ->
    window.dispatchEvent new Event('resize')

  handleScrollTable: ->
    self = @
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
        self.handleResizeWindow()

  ######################################################################################################################

  initBuilderFilter: (id)->
    builderFields = $(id).data('fields')
    # builderFields = $('#client-builder-fields').data('fields')
    if $('#wizard-builder').length > 0
      advanceSearchWizardBuilder = new CIF.AdvancedFilterBuilder($('#wizard-builder'), builderFields, @filterTranslation)
      advanceSearchWizardBuilder.initRule()
      @.initRuleOperatorSelect2($('#wizard-builder'))
    advanceSearchBuilder = new CIF.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
    advanceSearchBuilder.initRule()
    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($('#builder'))

  initSelect2: ->
    # $('#custom-form-select, #wizard-custom-form-select, #program-stream-select, #wizard-program-stream-select, #quantitative-case-select').select2()
    # $('.custom-form-select, .program-stream-select, .quantitative-case-select').select2()
    $('select').select2()
    setTimeout ( ->
      $('.rule-filter-container select').select2(width: '250px')
      $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')
    )

  basicFilterSetRule: ->
    basicQueryRules = $('#builder').data('basic-search-rules')
    wizardBasicQueryRules = $('#wizard-builder').data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      $('#builder').queryBuilder('setRules', basicQueryRules)
    unless wizardBasicQueryRules == undefined or _.isEmpty(wizardBasicQueryRules.rules)
      $('#wizard-builder').queryBuilder('setRules', wizardBasicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

  ######################################################################################################################

  customFormSelectChange: ->
    self = @
    self.customFormSelected = []
    $('.main-report-builder .custom-form-wrapper select').on 'select2-selecting', (element) ->
      self.customFormSelected.push(element.val)
      self.addCustomBuildersFields(element.val, self.CUSTOM_FORM_URL)

    $('#report-builder-wizard .custom-form-wrapper select').on 'select2-selecting', (element) ->
      $('#custom-form-column').addClass('hidden')
      $('#wizard-custom-form .loader').removeClass('hidden')
      self.wizardCustomFormSelected.push(element.val)
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(element.val, self.CUSTOM_FORM_URL)
      $.when(addCustomBuildersFields).then ->
        $('#custom-form-column').removeClass('hidden')
        $('#wizard-custom-form .loader').addClass('hidden')

  addCustomBuildersFields: (ids, url) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '.main-report-builder .custom-form-column' else '.main-report-builder .program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)

  addCustomBuildersFieldsInWizard: (ids, url) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '#report-builder-wizard .custom-form-column' else '#report-builder-wizard .program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        if (element == '#report-builder-wizard .custom-form-column' && $('#wizard_custom_form_filter').is(':checked')) || (element == '#report-builder-wizard .program-stream-column' && $('#wizard_program_stream_filter').is(':checked'))
          $('#wizard-builder').queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)

  addFieldToColumnPicker: (element, fieldList) ->
    self = @
    customFormColumnPicker = $("#{element} ul.append-child")
    fieldsGroupByOptgroup = _.groupBy(fieldList, 'optgroup')
    _.forEach fieldsGroupByOptgroup, (values, key) ->
      headerClass = self.formBuiderFormatHeader(key)
      $(customFormColumnPicker).append("<li class='dropdown-header #{headerClass}'>#{key}</li>")
      _.forEach values, (value) ->
        fieldName = value.id
        keyword   = _.first(fieldName.split('__'))
        checkField  = fieldName
        label       = value.label
        $(customFormColumnPicker).append(self.checkboxElement(checkField, headerClass, label))
        $(".#{headerClass} input.i-checks").iCheck
          checkboxClass: 'icheckbox_square-green'

  formBuiderFormatHeader: (value) ->
    keyWords = value.split('|')
    name = _.first(keyWords).trim()
    label = _.last(keyWords).trim()
    combine = "#{name} #{label}"
    @formatSpecialCharacter(combine)

  checkboxElement: (field, name, label) ->
    "<li class='visibility checkbox-margin #{name}'>
      <input type='checkbox' name='#{field}_' id='#{field}_' value='#{field}' class='i-checks' style='position: absolute; opacity: 0;'>
      <label for='#{field}_'>#{label}</label>
    </li>"

  handleHideCustomFormSelect: ->
    self = @
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      $('.custom-form-column ul.append-child li').remove()

      # $('#custom-form-select option:selected, #wizard-custom-form-select option:selected').each ->
      $('select.custom-form-select option:selected').each ->
        formTitle = $(@).text()
        self.handleRemoveFilterBuilder(formTitle, self.CUSTOM_FORM_TRANSLATE)

      self.customFormSelected = []
      # $('.custom-form select').select2('val', '')
      $('select.custom-form-select').select2('val', '')
      $('.custom-form').hide()

  handleShowCustomFormSelect: ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show()
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  ######################################################################################################################

  customFormSelectRemove: ->
    self = @
    $('.main-report-builder .custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      formTitle   = removeValue.trim()
      formTitle   = self.formatSpecialCharacter("#{formTitle} Custom Form")

      self.removeCheckboxColumnPicker('.main-report-builder .custom-form-column', formTitle)
      $.map self.customFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.customFormSelected.splice(i, 1)

      self.handleRemoveFilterBuilder(removeValue, self.CUSTOM_FORM_TRANSLATE)

    $('#report-builder-wizard .custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      formTitle   = removeValue.trim()
      formTitle   = self.formatSpecialCharacter("#{formTitle} Custom Form")

      self.removeCheckboxColumnPicker('#report-builder-wizard .custom-form-column', formTitle)
      $.map self.wizardCustomFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.wizardCustomFormSelected.splice(i, 1)

      if $('#wizard_custom_form_filter').is(':checked')
        self.handleRemoveFilterBuilder(removeValue, self.CUSTOM_FORM_TRANSLATE, '#wizard-builder')

  handleRemoveFilterBuilder: (resourceName, resourcelabel, elementBuilder = '#builder') ->
    self = @
    if elementBuilder == '#builder'
      filterSelects = $('.main-report-builder .rule-container .rule-filter-container select')
    else
      filterSelects = $('#report-builder-wizard .rule-container .rule-filter-container select')
    for select in filterSelects
      optGroup  = $(':selected', select).parents('optgroup')
      if $(select).val() != '-1' and optGroup[0] != undefined and optGroup[0].label != self.BASIC_FIELD_TRANSLATE and optGroup[0].label != self.DOMAIN_SCORES_TRANSLATE
        label = optGroup[0].label.split('|')
        if $(label).last()[0].trim() == resourcelabel.trim() and label[0].trim() == resourceName.trim()
          container = $(select).parents('.rule-container')
          $(container).find('select').select2('destroy')
          $(container).find('.rule-header button').trigger('click')
    setTimeout ( ->
      if $('.rule-container .rule-filter-container select').length == 0
        $('button[data-add="rule"]').trigger('click')
        filterSelects = $('.rule-container .rule-filter-container select')
      self.handleRemoveBuilderOption(filterSelects, resourceName, resourcelabel)
      )

  handleRemoveBuilderOption: (filterSelects, resourceName, resourcelabel) ->
    values = []
    optGroups = $(filterSelects[0]).find('optgroup')
    for optGroup in optGroups
      label = optGroup.label
      if label != self.BASIC_FIELD_TRANSLATE and label != self.DOMAIN_SCORES_TRANSLATE
        labelValue = label.split('|')
        if $(labelValue).last()[0].trim() == resourcelabel.trim() and labelValue[0].trim() == resourceName.trim()
          $(optGroup).find('option').each ->
            values.push $(@).val()
    $('#builder').queryBuilder('removeFilter', values)
    $('#wizard-builder').queryBuilder('removeFilter', values) if $('#wizard-builder').length > 0
    @initSelect2()

  ######################################################################################################################

  handleShowProgramStreamFilter: ->
    self = @
    if $('.main-report-builder #program-stream-checkbox').prop('checked')
      $('.main-report-builder .program-stream').show()
    if self.enrollmentCheckbox.prop('checked') || self.trackingCheckbox.prop('checked') || self.exitCheckbox.prop('checked') || self.programSelected.length > 0
      $('.main-report-builder .program-stream').show()
    if self.wizardEnrollmentCheckbox.prop('checked') || self.wizardTrackingCheckbox.prop('checked') || self.wizardExitCheckbox.prop('checked') || self.wizardProgramSelected.length > 0
      $('#report-builder-wizard .program-association').show()
    $('.main-report-builder #program-stream-checkbox').on 'ifChecked', ->
      $('.main-report-builder .program-stream').show()

  handleHideProgramStreamSelect: ->
    self = @
    $('.main-report-builder .program-stream-checkbox').on 'ifUnchecked', ->
      $('.main-report-builder .program-stream-column ul.append-child li').remove()
      self.programSelected = []
      $('.main-report-builder .program-association, .main-report-builder .program-stream').hide()
      $('.main-report-builder .program-association input[type="checkbox"]').iCheck('uncheck')
      $('.main-report-builder select.program-stream-select').select2("val", "")

  handleProgramSelectChange: ->
    self = @
    $('.main-report-builder select.program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.programSelected.push programId
      $('.main-report-builder .program-association').show()
      if $('#enrollment-checkbox').is(':checked')
        self.addCustomBuildersFields(programId, self.ENROLLMENT_URL)
      if $('#tracking-checkbox').is(':checked')
        self.addCustomBuildersFields(programId, self.TRACKING_URL)
      if $('#exit-form-checkbox').is(':checked')
        self.addCustomBuildersFields(programId, self.EXIT_PROGRAM_URL)

    $('#report-builder-wizard select.program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.wizardProgramSelected.push programId
      $('#report-builder-wizard .program-association').show()
      if $('#wizard-enrollment-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.ENROLLMENT_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

      if $('#wizard-tracking-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.TRACKING_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

      if $('#wizard-exit-form-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.EXIT_PROGRAM_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

  triggerEnrollmentInWizard: ->
    self = @
    $('#wizard-enrollment-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.ENROLLMENT_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerTrackingInWizard: ->
    self = @
    $('#wizard-tracking-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.TRACKING_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerExitProgramInWizard: ->
    self = @
    $('#wizard-exit-form-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.EXIT_PROGRAM_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerEnrollmentFields: ->
    self = @
    $('#enrollment-checkbox').on 'ifChecked', ->
      self.addCustomBuildersFields(self.programSelected, self.ENROLLMENT_URL)

  triggerTrackingFields: ->
    self = @
    $('#tracking-checkbox').on 'ifChecked', ->
      self.addCustomBuildersFields(self.programSelected, self.TRACKING_URL)

  triggerExitProgramFields: ->
    self = @
    $('#exit-form-checkbox').on 'ifChecked', ->
      self.addCustomBuildersFields(self.programSelected, self.EXIT_PROGRAM_URL)

  ######################################################################################################################

  handleSelect2RemoveProgram: ->
    self = @
    programStreamKeyword = ['Enrollment', 'Tracking', 'Exit Program']
    $('.main-report-builder .program-stream-select').on 'select2-removed', (element) ->
      programName = element.choice.text
      self.removeCheckboxColumnPickers(programStreamKeyword, programName, self)

      $.map self.programSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.programSelected.splice(i, 1)

      self.handleRemoveFilterBuilder(programName, self.ENROLLMENT_TRANSLATE)
      self.handleRemoveFilterBuilder(programName, self.TRACKING_TRANSTATE)
      self.handleRemoveFilterBuilder(programName, self.EXIT_PROGRAM_TRANSTATE)
      if $.isEmptyObject($(@).val())
        programStreamAssociation = $('.main-report-builder .program-association')
        $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
        $(programStreamAssociation).hide()

    $('#report-builder-wizard .program-stream-select').on 'select2-removed', (element) ->
      programName = element.choice.text
      self.removeCheckboxColumnPickers(programStreamKeyword, programName, self)

      $.map self.wizardProgramSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.wizardProgramSelected.splice(i, 1)
      if $('#wizard_program_stream_filter').is(':checked')
        self.handleRemoveFilterBuilder(programName, self.ENROLLMENT_TRANSLATE, '#wizard-builder')
        self.handleRemoveFilterBuilder(programName, self.TRACKING_TRANSTATE, '#wizard-builder')
        self.handleRemoveFilterBuilder(programName, self.EXIT_PROGRAM_TRANSTATE, '#wizard-builder')
      if $.isEmptyObject($(@).val())
        programStreamAssociation = $('#report-builder-wizard .program-association')
        $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
        $(programStreamAssociation).hide()

  removeCheckboxColumnPickers: (keyWords, programName, self)->
    _.forEach keyWords, (value) ->
      headerClass = self.formatSpecialCharacter("#{programName.trim()} #{value}")
      self.removeCheckboxColumnPicker('#report-builder-wizard #program-stream-column', headerClass)

  handleUncheckedEnrollment: ->
    self = @
    $('#enrollment-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Enrollment")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.ENROLLMENT_TRANSLATE)

    $('#wizard-enrollment-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Enrollment")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.ENROLLMENT_TRANSLATE)

  handleUncheckedTracking: ->
    self = @
    $('#tracking-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Tracking")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.TRACKING_TRANSTATE)

    $('#wizard-tracking-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Tracking")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.TRACKING_TRANSTATE)

  handleUncheckedExitProgram: ->
    self = @
    $('#exit-form-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Exit Program")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.EXIT_PROGRAM_TRANSTATE)

    $('#wizard-exit-form-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Exit Program")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.EXIT_PROGRAM_TRANSTATE)

  ######################################################################################################################

  handleAddQuantitativeFilter: ->
    self = @
    fields = $('#quantitative-fields').data('fields')
    $('#quantitative-type-checkbox').on 'ifChecked', ->
      $('#builder').queryBuilder('addFilter', fields)
      $('#wizard-builder').queryBuilder('addFilter', fields)
      self.initSelect2()

  handleRemoveQuantitativFilter: ->
    self = @
    $('#quantitative-type-checkbox').on 'ifUnchecked', ->
      self.handleRemoveFilterBuilder(self.QUANTITATIVE_TRANSLATE, self.QUANTITATIVE_TRANSLATE)

  ######################################################################################################################

  handleSearch: ->
    self = @
    $('#search, #wizard-search').on 'click', (e)->
      btnID = e.currentTarget.id
      if btnID == 'search'
        builderElement = '#builder'
        builderForm = '.main-report-builder'
        programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"
        customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
      else
        builderElement = '#wizard-builder'
        builderForm = '#report-builder-wizard'
        programValues = if self.wizardProgramSelected.length > 0 then "[#{self.wizardProgramSelected}]"
        customFormValues = if self.wizardCustomFormSelected.length > 0 then "[#{self.wizardCustomFormSelected}]"

      basicRules = $(builderElement).queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      self.setValueToProgramAssociation()
      $('#client_advanced_search_custom_form_selected').val(customFormValues)
      $('#client_advanced_search_program_selected').val(programValues)
      if $('#quantitative-type-checkbox').prop('checked') then $('#client_advanced_search_quantitative_check').val(1)
      if $('#wizard_quantitative_filter').prop('checked') then $('#client_advanced_search_wizard_quantitative_check').val(1)
      if $('#wizard_custom_form_filter').prop('checked') then $('#client_advanced_search_wizard_custom_form_check').val(1)
      if $('#wizard_program_stream_filter').prop('checked') then $('#client_advanced_search_wizard_program_stream_check').val(1)
      if $('#wizard-enrollment-checkbox').prop('checked') then $('#client_advanced_search_wizard_enrollment_check').val(1)
      if $('#wizard-tracking-checkbox').prop('checked') then $('#client_advanced_search_wizard_tracking_check').val(1)
      if $('#wizard-exit-form-checkbox').prop('checked') then $('#client_advanced_search_wizard_exit_form_check').val(1)
      $('#client_advanced_search_action_report_builder').val(builderElement)

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $(builderElement).find('.has-error').removeClass('has-error')
        $('#client_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox(builderForm)
        $('#advanced-search').submit()

  handleFamilySearch: ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      customFormValues = "[#{$('#family-advance-search-form').find('.custom-form-select').select2('val')}]"

      $('#family_advanced_search_custom_form_selected').val(customFormValues)

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').removeClass('has-error')
        $('#family_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  handlePartnerSearch: ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      customFormValues = "[#{$('#partner-advance-search-form').find('.custom-form-select').select2('val')}]"

      $('#partner_advanced_search_custom_form_selected').val(customFormValues)

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').removeClass('has-error')
        $('#partner_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  setValueToProgramAssociation: ->
    enrollmentCheck = $('#client_advanced_search_enrollment_check')
    trackingCheck   = $('#client_advanced_search_tracking_check')
    exitFormCheck   = $('#client_advanced_search_exit_form_check')

    if @enrollmentCheckbox.is(":checked") || @wizardEnrollmentCheckbox.is(':checked') then $(enrollmentCheck).val(1)
    if @trackingCheckbox.is(":checked") || @wizardTrackingCheckbox.is(':checked') then $(trackingCheck).val(1)
    if @exitCheckbox.is(":checked") || @wizardExitCheckbox.is(':checked') then $(exitFormCheck).val(1)

  handleStringfyRules: (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  handleSelectFieldVisibilityCheckBox: (builder = '.main-report-builder')->
    checkedFields = $(builder).find('.visibility .checked input, .all-visibility .checked input')
    $('form#advanced-search').append(checkedFields)

  ######################################################################################################################

  addRuleCallback: ->
    self = @
    $('#builder, #wizard-builder').on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
      self.initSelect2()
      self.handleSelectOptionChange(obj)
      self.referred_to_program()
      self.filterSelecting()

  handleSelectOptionChange: (obj)->
    self = @
    if obj != undefined
      rowBuilderRule = obj.$el[0]
      ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
      $(ruleFiltersSelect).on 'select2-close', ->
        setTimeout ( ->
          self.initSelect2()
          self.initRuleOperatorSelect2(rowBuilderRule)
        )

  referred_to_program: ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10

  ######################################################################################################################

  filterSelecting: ->
    self = @
    $('.rule-filter-container select').on 'select2-selecting', ->
      setTimeout ( ->
        self.opertatorSelecting()
      )

  opertatorSelecting: ->
    self = @
    $('.rule-operator-container select').on 'select2-selected', ->
      self.disableOptions(@)

  disableOptions: (element) ->
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
          first_value_option = $(select).find('select:first').find(':selected').text()
          second_value_option = $(select).find('select:last').find(':selected').text()
          if disableValue.includes(first_value_option) && disableValue.includes(second_value_option)
            $(select).find('select').val('1').trigger('change')
        , 100)

    setTimeout( ->
      self.initSelect2()
    )

  checkingForDisableOptions: ->
    self = @
    for element in $('.rule-operator-container select')
      self.disableOptions(element)

  ######################################################################################################################

  handleSaveQuery: ->
    self = @
    $('#submit-query').on 'click', (e)->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      if basicRules.valid == false && basicRules.rules.length > 0
        e.preventDefault()
        $('#save-query').modal('hide')
      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').removeClass('has-error')
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
      programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

      enrollmentCheck = $('#advanced_search_enrollment_check')
      trackingCheck   = $('#advanced_search_tracking_check')
      exitFormCheck   = $('#advanced_search_exit_form_check')

      if (self.enrollmentCheckbox.prop('checked') || self.wizardEnrollmentCheckbox.prop('checked')) then $(enrollmentCheck).val(1)
      if (self.trackingCheckbox.prop('checked') || self.wizardTrackingCheckbox.prop('checked')) then $(trackingCheck).val(1)
      if (self.exitCheckbox.prop('checked') || self.wizardExitCheckbox.prop('checked')) then $(exitFormCheck).val(1)
      if ($('#quantitative-type-checkbox').prop('checked')) then $('#advanced_search_quantitative_check').val(1)

      $('#advanced_search_custom_forms').val(customFormValues)
      $('#advanced_search_program_streams').val(programValues)
      $('#advanced_search_queries').val(self.handleStringfyRules(basicRules))
      self.handleAddColumnPickerToInput()

  handleAddColumnPickerToInput: ->
    columnsVisibility = new Object
    $('.visibility, .all-visibility').each ->
      checkbox = $(@).find('input[type="checkbox"]')
      if $(checkbox).prop('checked')
        attrName = $(checkbox).attr('name')
        columnsVisibility[attrName] = $(checkbox).val()
    $('#advanced_search_field_visible').val(JSON.stringify(columnsVisibility))

  validateSaveQuery: ->
    $('#advanced_search_name').keyup ->
      if $(@).val() != ''
        $('#submit-query').removeClass('disabled').removeAttr('disabled')
      else
        $('#submit-query').addClass('disabled').attr('disabled', 'disabled')
