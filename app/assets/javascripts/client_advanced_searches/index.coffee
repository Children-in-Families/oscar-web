CIF.Client_advanced_searchesIndex = do ->
  @customFormSelected = ''
  @customFormOption = ''
  @customFormDisabled = []
  _init = ->
    @filterTranslation = ''
    _initSelect2()
    _setValueToCustomFormDisabled()
    _getTranslation()
    _columnsVisibility()
    _ajaxGetBasicField()
    _handleShowCustomFormSelect()
    _handleHideCustomFormSelect()
    _customFormSelectChange()
    _handleInitDatatable()
    _handleSearch()
    _addRuleCallback()
    _handleShowProgramStreamFilter()
    _handleHideProgramStreamSelect
    _handleScrollTable()
    _getClientPath()
    _setDefaultCheckColumnVisibilityAll()

  _setValueToCustomFormDisabled = ->
    @customFormDisabled = $('.custom-form').data('value')
    customFormSelected = $('#custom-form-select').val()
    if customFormSelected != ''
      @customFormSelected = parseInt customFormSelected

  _handleShowCustomFormSelect = ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show() 
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  _handleHideCustomFormSelect = ->
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      self.customFormOption = ''
      self.customFormDisabled = []
      _handleRemoveCustomFormFilter()
      $('.custom-form select').select2("val", "")
      $('.custom-form select option').removeAttr('disabled')
      $('.custom-form').hide()

  _customFormSelectChange = ->
    self = @
    $('#custom-form-wrapper select').on 'change', ->
      customFormId = $(@).val()
      option = $(':selected', $(@))
      if self.customFormOption != '' and $(@).val() != ''
        self.customFormOption.attr('disabled', 'disabled')
        self.customFormDisabled.push self.customFormOption.val()
      self.customFormOption = option

      _handleAddCustomFormFilter(customFormId)

  _handleAddCustomFormFilter = (formId)->
    if formId.length > 0
      $.ajax
        url: '/api/client_advanced_searches/get_custom_field'
        data: { custom_form_ids: formId }
        method: 'GET'
        success: (response) ->
          fieldList = response.client_advanced_searches
          $('#builder').queryBuilder('addFilter', fieldList)
          _initSelect2()

  _handleRemoveCustomFormFilter = ->
    filterSelects = $('.rule-container .rule-filter-container select')
    values = []
    for select in filterSelects
      optGroup = $(':selected', select).parents('optgroup')
      if $(select).val() != '-1'
        optLabel = optGroup[0].label.split('|')[0].trim()
        if optLabel == 'Custom Fields'
          $(select).parents('.rule-container').find('.rule-header button').trigger('click')
          $(optGroup).find('option').each ->
            values.push $(@).val()

    $('#builder').queryBuilder('removeFilter', values)
    _initSelect2()

  _handleShowProgramStreamFilter = ->
    $('#program-stream-checkbox').on 'ifChecked', ->
      $(@).parents('#program-stream-wrapper').find('.program-stream').show()

  _handleHideProgramStreamSelect = ->
    $('#program-stream-checkbox').on 'ifUnchecked', ->
      programStream = $(@).parents('#program-stream-wrapper').find('.program-stream')
      $(programStream).hide()
      $(programStream).find('select').select2("val", "")

  _referred_to_program = ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10

  _initSelect2 = ->
    $('#custom-form-select, #program-stream-select').select2(width: '220px')
    $('.rule-filter-container select').select2(width: '320px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

  _ajaxGetBasicField = ->
    customFromIds = @customFormDisabled
    if @customFormSelected != '' then customFromIds.push @customFormSelected

    $.ajax
      url: '/api/client_advanced_searches/get_basic_field'
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder(_queryBuilderOption(fieldList))
        _handleAddCustomFormFilter(customFromIds)
        setTimeout ( ->
          _basicFilterSetRule()
          _initSelect2()
          _initRuleOperatorSelect2($('#builder'))
        ), 300

  _handleValidateSearch = ->
    filterValidate = []
    groupFilters = $('.advanced-search-builder')
    for filters in groupFilters
      filterLength = $(filters).find('.rule-container').length
      if filterLength > 1
        for filter in filters
          filterField     = $(filter).find('.rule-filter-container select').val()
          filterOperator  = $(filter).find('.rule-operator-container select').val()
          filterValue     = $(filter).find('.rule-value-container input.form-control').val()

          if (filterField == '-1') || (filterField != '-1' && filterOperator != 'is_empty' && filterValue == '')
            filterValidate.push filter

      if filterLength == 1 && $(filters).find('.rule-filter-container select').val() == '-1'
        $('.rule-container').removeClass('has-error')

    if filterValidate.length == 0 && !($('.rule-container').hasClass('has-error'))
      $('#advanced-search').submit()

  _handleSearch = ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules')
      $('#client_advanced_search_custom_form_disables').val("[#{self.customFormDisabled}]")
      $('#client_advanced_search_custom_form_selected').val($('#custom-form-select').val())

      if !($.isEmptyObject(basicRules))
        $('#client_advanced_search_basic_rules').val(_handleStringfyRules(basicRules))
        _handleSelectFieldVisibilityCheckBox()
        _handleValidateSearch()

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
    plugins: ['sortable','bt-tooltip-errors']
    filters: fieldList

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('.all-visibility #all_')

    allCheckboxes.on 'ifChecked', ->
      $('.visibility input[type=checkbox]').iCheck('check')
    allCheckboxes.on 'ifUnchecked', ->
      $('.visibility input[type=checkbox]').iCheck('uncheck')

  _setDefaultCheckColumnVisibilityAll = ->
    setTimeout ( ->
      if $('.visibility .checked').length == 0
        $('.all-visibility #all_').iCheck('check')
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

  _initRuleOperatorSelect2 = (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

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
