CIF.Client_advanced_searchesIndex = do ->
  _init = ->
    @filterTranslation = ''
    _getTranslation()
    _columnsVisibility()
    _ajaxGetBasicField()
    _handleInitDatatable()
    _handleSearch()
    _addRuleCallback()
    _handleScrollTable()
    _getClientPath()
    _setDefaultCheckColumnVisibilityAll()

  _referred_to_program = ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10

  _initSelect2 = ->
    $('.rule-filter-container select').select2(width: '320px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

  _handleSetTitleToOption = ->
    $('.rule-filter-container select').on 'select2-open', ->
      self = @
      elements = $('ul.select2-results li')
      $(elements).each (index, element) ->
        option = $(self).find('option')[index]
        value = $(option).text()
        $(element).attr('title', value)
        truncate = value.substring(0, 42)
        result = if truncate.length == 42 then "#{truncate} ..." else truncate
        $(element).find('.select2-result-label').text(result)

  _ajaxGetBasicField = ->
    $.ajax
      url: '/api/client_advanced_searches/get_basic_field'
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        _basicFilterSetRule()
        _handleSetTitleToOption()
        _initSelect2()
        _handleSelectOptionChange()

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
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules')

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
      _handleSetTitleToOption()
      _handleSelectOptionChange(obj)
      _referred_to_program()

  _handleSelectOptionChange = (obj) ->
    if obj != undefined
      rowBuilderRule = obj.$el[0]
      ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
      $(ruleFiltersSelect).on 'select2-close', ->
        setTimeout ( ->
          _initSelect2()
          operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
          $(operatorSelect).on 'select2-close', ->
            setTimeout ( ->
              $(rowBuilderRule).find('.rule-value-container select').select2(
                width: '180px')
              )
          )

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')

  _basicFilterSetRule = ->
    basicQueryRules = $('#builder').data('basic-search-rules')
    queryCondition = $('#builder').data('search-condition')
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
