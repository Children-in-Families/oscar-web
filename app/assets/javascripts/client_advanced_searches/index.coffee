CIF.Client_advanced_searchesIndex = do ->
  optionTranslation      = $('#opt-group-translation')
  BASIC_FIELD_TRANSLATE  = $(optionTranslation).data('basicFields')
  CUSTOM_FORM_TRANSLATE  = $(optionTranslation).data('customForm')
  ENROLLMENT_TRANSLATE   = $(optionTranslation).data('enrollment')
  EXIT_PROGRAM_TRANSTATE = $(optionTranslation).data('exitProgram')
  QUANTITATIVE_TRANSLATE = $(optionTranslation).data('quantitative')
  TRACKING_TRANSTATE     = $(optionTranslation).data('tracking')

  ENROLLMENT_URL       = '/api/client_advanced_searches/get_enrollment_field'
  TRACKING_URL         = '/api/client_advanced_searches/get_tracking_field'
  EXIT_PROGRAM_URL     = '/api/client_advanced_searches/get_exit_program_field'
  CUSTOM_FORM_URL      = '/api/client_advanced_searches/get_custom_field'

  @enrollmentCheckbox  = $('#enrollment-checkbox')
  @trackingCheckbox    = $('#tracking-checkbox')
  @exitCheckbox        = $('#exit-form-checkbox')
  @customFormSelected  = []
  @programSelected     = []

  _init = ->
    @filterTranslation = ''
    _initSelect2()
    _setValueToBuilderSelected()
    _getTranslation()
    _initBuilderFilter()

    _handleShowCustomFormSelect()
    _customFormSelectChange()
    _customFormSelectRemove()
    _handleHideCustomFormSelect()
    
    _handleShowProgramStreamFilter()
    _handleHideProgramStreamSelect()
    _handleProgramSelectChange()
    _triggerEnrollmentFields()
    _triggerTrackingFields()
    _triggerExitProgramFields()
    _handleSelect2RemoveProgram()
    _handleUncheckedEnrollment()
    _handleUncheckedTracking()
    _handleUncheckedExitProgram()

    _handleAddQuantitativeFilter()
    _handleRemoveQuantitativFilter()

    _columnsVisibility()
    _handleInitDatatable()
    _handleSearch()
    _addRuleCallback()
    _filterSelectChange()
    _handleScrollTable()
    _getClientPath()
    _setDefaultCheckColumnVisibilityAll()

  _initSelect2 = ->
    $('#custom-form-select, #program-stream-select, #quantitative-case-select').select2()
    $('.rule-filter-container select').select2(width: '250px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

  _setValueToBuilderSelected = ->
    @customFormSelected = $('.custom-form').data('value')
    @programSelected    = $('.program-stream').data('value')

  _handleAddQuantitativeFilter = ->
    fields = $('#quantitative-fields').data('fields')
    $('#quantitative-type-checkbox').on 'ifChecked', ->
      $('#builder').queryBuilder('addFilter', fields)
      _initSelect2() 

  _handleRemoveQuantitativFilter = ->
    $('#quantitative-type-checkbox').on 'ifUnchecked', ->
      _handleRemoveFilterBuilder(QUANTITATIVE_TRANSLATE, QUANTITATIVE_TRANSLATE)

  _handleShowProgramStreamFilter = ->
    if $('#program-stream-checkbox').prop('checked')
      $('.program-stream').show()
    if @enrollmentCheckbox.prop('checked') || @trackingCheckbox.prop('checked') || @exitCheckbox.prop('checked') || @programSelected.length > 0
      $('.program-association').show()
    $('#program-stream-checkbox').on 'ifChecked', ->
      $('.program-stream').show()

  _handleHideProgramStreamSelect = ->
    self = @
    $('#program-stream-checkbox').on 'ifUnchecked', ->
      self.programSelected = []
      $('.program-stream, .program-association').hide()
      $('#program-stream-select option:selected').each ->
        name = $(@).text()
        _handleRemoveFilterBuilder(name, BASIC_FIELD_TRANSLATE)
        _handleRemoveFilterBuilder(name, TRACKING_TRANSTATE)
        _handleRemoveFilterBuilder(name, EXIT_PROGRAM_TRANSTATE)
      $('.program-association input[type="checkbox"]').iCheck('uncheck')
      $('#program-stream-select').select2("val", "")

  _triggerEnrollmentFields = ->
    self = @
    $('#enrollment-checkbox').on 'ifChecked', ->
      _addCustomBuildersFields(self.programSelected, ENROLLMENT_URL)

  _triggerTrackingFields = ->
    self = @
    $('#tracking-checkbox').on 'ifChecked', ->
      _addCustomBuildersFields(self.programSelected, TRACKING_URL)

  _triggerExitProgramFields = ->
    self = @
    $('#exit-form-checkbox').on 'ifChecked', ->
      _addCustomBuildersFields(self.programSelected, EXIT_PROGRAM_URL)

  _handleUncheckedEnrollment = ->
    $('#enrollment-checkbox').on 'ifUnchecked', ->
      for option in $('#program-stream-select option:selected')
        name = $(option).text()
        _handleRemoveFilterBuilder(name, ENROLLMENT_TRANSLATE)

  _handleUncheckedTracking = ->
    $('#tracking-checkbox').on 'ifUnchecked', ->
      for option in $('#program-stream-select option:selected')
        name = $(option).text()
        _handleRemoveFilterBuilder(name, TRACKING_TRANSTATE)

  _handleUncheckedExitProgram = ->
    $('#exit-form-checkbox').on 'ifUnchecked', ->
      for option in $('#program-stream-select option:selected')
        name = $(option).text()
        _handleRemoveFilterBuilder(name, EXIT_PROGRAM_TRANSTATE)

  _handleSelect2RemoveProgram = ->
    self = @
    $('#program-stream-select').on 'select2-removed', (element) ->
      programName = element.choice.text
      $.map self.programSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.programSelected.splice(i, 1)

      _handleRemoveFilterBuilder(programName, ENROLLMENT_TRANSLATE)
      setTimeout ( ->
        _handleRemoveFilterBuilder(programName, TRACKING_TRANSTATE)
        _handleRemoveFilterBuilder(programName, EXIT_PROGRAM_TRANSTATE)
        )
      if $.isEmptyObject($(@).val())
        programStreamAssociation = $('.program-association')
        $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
        $(programStreamAssociation).hide()

  _handleProgramSelectChange = ->
    self = @
    $('#program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.programSelected.push programId
      $('.program-association').show()
      if $('#enrollment-checkbox').prop('checked')
        _addCustomBuildersFields(programId, ENROLLMENT_URL)
      if $('#tracking-checkbox').prop('checked')
        _addCustomBuildersFields(programId, TRACKING_URL)
      if $('#exit-form-checkbox').prop('checked')
        _addCustomBuildersFields(programId, EXIT_PROGRAM_URL)

  _handleShowCustomFormSelect = ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show()
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  _handleHideCustomFormSelect = ->
    self = @
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      $('#custom-form-select option:selected').each ->
        formTitle = $(@).text()
        _handleRemoveFilterBuilder(formTitle, CUSTOM_FORM_TRANSLATE)

      self.customFormSelected = []
      $('.custom-form select').select2('val', '')
      $('.custom-form').hide()

  _customFormSelectChange = ->
    self = @
    $('#custom-form-wrapper select').on 'select2-selecting', (element) ->
      self.customFormSelected.push element.val
      _addCustomBuildersFields(element.val, CUSTOM_FORM_URL)

  _customFormSelectRemove = ->
    self = @
    $('#custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      $.map self.customFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.customFormSelected.splice(i, 1)

      setTimeout ( ->
        _handleRemoveFilterBuilder(removeValue, CUSTOM_FORM_TRANSLATE)
        ),100

   _addCustomBuildersFields = (ids, url) ->
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder('addFilter', fieldList)
        _initSelect2()

  _initBuilderFilter = ->
    builderFields = $('#client-builder-fields').data('fields')
    $('#builder').queryBuilder(_queryBuilderOption(builderFields))
    _basicFilterSetRule()
    _initSelect2()
    _initRuleOperatorSelect2($('#builder'))

  _handleSearch = ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules')
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
      programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

      _setValueToProgramAssociation()
      $('#client_advanced_search_custom_form_selected').val(customFormValues)
      $('#client_advanced_search_program_selected').val(programValues)
      if $('#quantitative-type-checkbox').prop('checked')
        $('#client_advanced_search_quantitative_check').val(1)

      if !($.isEmptyObject(basicRules))
        $('#client_advanced_search_basic_rules').val(_handleStringfyRules(basicRules))
        _handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  _setValueToProgramAssociation = ->
    enrollmentCheck = $('#client_advanced_search_enrollment_check')
    trackingCheck   = $('#client_advanced_search_tracking_check')
    exitFormCheck   = $('#client_advanced_search_exit_form_check')

    if @enrollmentCheckbox.prop('checked') then $(enrollmentCheck).val(1)
    if @trackingCheckbox.prop('checked') then $(trackingCheck).val(1)
    if @exitCheckbox.prop('checked') then $(exitFormCheck).val(1)

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
    plugins: ['sortable','bt-tooltip-errors']
    filters: fieldList

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('#client-column .all-visibility #all_')

    allCheckboxes.on 'ifChecked', ->
      $('#client-column .visibility input[type=checkbox]').iCheck('check')
    allCheckboxes.on 'ifUnchecked', ->
      $('#client-column .visibility input[type=checkbox]').iCheck('uncheck')

  _setDefaultCheckColumnVisibilityAll = ->
    setTimeout ( ->
      if $('#client-column .visibility .checked').length == 0
        $('#client-column .all-visibility #all_').iCheck('check')
      )

  _addRuleCallback = ->
    $('#builder').on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
      _initSelect2()
      _handleSelectOptionChange(obj)
      _referred_to_program()

  _handleSelectOptionChange = (obj)->
    if obj != undefined
      rowBuilderRule = obj.$el[0]
      ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
      $(ruleFiltersSelect).on 'select2-close', ->
        setTimeout ( ->
          _initSelect2()
          _initRuleOperatorSelect2(rowBuilderRule)
        )

  _filterSelectChange = ->
    $('.rule-filter-container select').on 'select2-close', ->
      setTimeout ( ->
        _initSelect2()
      )

  _initRuleOperatorSelect2 = (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

  _handleRemoveFilterBuilder = (resourceName, resourcelabel) ->
    filterSelects = $('.rule-container .rule-filter-container select')
    for select in filterSelects
      optGroup  = $(':selected', select).parents('optgroup')
      if $(select).val() != '-1' and optGroup[0] != undefined and optGroup[0].label != BASIC_FIELD_TRANSLATE
        label = optGroup[0].label.split('|')
        if $(label).last()[0].trim() == resourcelabel and label[0].trim() == resourceName
          container = $(select).parents('.rule-container')
          $(container).find('select').select2('destroy')
          $(container).find('.rule-header button').trigger('click')

    setTimeout ( ->
      if $('.rule-container .rule-filter-container select').length == 0
        $('button[data-add="rule"]').trigger('click')
        filterSelects = $('.rule-container .rule-filter-container select')
      _handleRemoveBuilderOption(filterSelects, resourceName, resourcelabel)
      )

  _handleRemoveBuilderOption = (filterSelects, resourceName, resourcelabel) ->
    values = []
    optGroups = $(filterSelects[0]).find('optgroup')
    for optGroup in optGroups
      label = optGroup.label
      if label != BASIC_FIELD_TRANSLATE
        labelValue = label.split('|')
        if $(labelValue).last()[0].trim() == resourcelabel and labelValue[0].trim() == resourceName
          $(optGroup).find('option').each ->
            values.push $(@).val()
    $('#builder').queryBuilder('removeFilter', values)
    _initSelect2()

  _referred_to_program = ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')

  _basicFilterSetRule = ->
    basicQueryRules = $('#builder').data('basic-search-rules')
    if !$.isEmptyObject basicQueryRules
      $('#builder').queryBuilder('setRules', basicQueryRules)

  _handleInitDatatable = ->
    $('.clients-table table').DataTable(
        'sScrollY': 'auto'
        'bFilter': false
        'bAutoWidth': true
        'bSort': false
        'sScrollX': '100%'
        'bInfo': false
        'bLengthChange': false
        'bPaginate': false
      )

  _handleStringfyRules = (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  _handleSelectFieldVisibilityCheckBox = ->
    checkedFields = $('.visibility .checked input, .all-visibility .checked input')
    $('form#advanced-search').append(checkedFields)

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getClientPath = ->
    $('table.clients tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
