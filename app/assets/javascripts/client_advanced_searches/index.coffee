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
    _handleSelectCustomForm()
    _handleInitCustomFormBuilder()

  _referred_to_program = ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10


  _initSelect2 = ->
    $('select').select2(
      width: 'resolve'
    )

  _handleSelectCustomForm = ->
    $('#select-custom-form').on 'select2-selecting', (e) ->
      customFormId = e.val
      if customFormId != ''
        $('#custom-form').show()
        _ajaxGetCustomField(customFormId)
      else
        $('#custom-form').hide()

  _handleInitCustomFormBuilder = ->
    customFormValue = $('#select-custom-form').val()
    if customFormValue != ''
      $('#custom-form').show()
      _ajaxGetCustomField(customFormValue)

  _ajaxGetBasicField = ->
    $.ajax
      url: '/api/client_advanced_searches/get_basic_field'
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        _hideBasicFilter()
        _basicFilterSetRule()
        _handleSelectOptionChange()
        _initSelect2()


  _ajaxGetCustomField = (customFormId) ->
    $.ajax
      url: '/api/client_advanced_searches/get_custom_field'
      data: { custom_form_id: customFormId }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#custom-form').queryBuilder(
          _queryBuilderOption(fieldList)
          )

        $('#custom-form').queryBuilder('reset');
        $('#custom-form').queryBuilder('setFilters', fieldList)
        _customFormSetRule()
        _handleSelectOptionChange()
        _initSelect2()

  _hideBasicFilter = ->
    $("#builder .rule-container button.btn-danger[data-delete='rule']").click()

  _handleValidateSearch = ->
    filterValidate = []
    allFilters = $('.rule-container')
    for filter in allFilters
      filterField     = $(filter).find('.rule-filter-container select').val()
      filterOperator  = $(filter).find('.rule-operator-container select').val()
      filterValue     = $(filter).find('.rule-value-container input.form-control').val()

      if (filterField == '-1') || (filterField != '-1' && filterOperator != 'is_empty' && filterValue == '')
        filterValidate.push filter

    if filterValidate.length == 0
      $('#advanced-search').submit()

  _handleSearch = ->
    $('#search').on 'click', ->
      customFormValue = $('#select-custom-form').val()
      $('#client_advanced_search_selected_custom_form').val(customFormValue)

      basicRules = $('#builder').queryBuilder('getRules')
      customFormRules = _getCustomFormRules(customFormValue)

      if !($.isEmptyObject(basicRules)) || !($.isEmptyObject(customFormRules))
        $('#client_advanced_search_basic_rules').val(_handleStringfyRules(basicRules))
        $('#client_advanced_search_custom_form_rules').val(_handleStringfyRules(customFormRules))
        _handleSelectFieldVisibilityCheckBox()

        _handleValidateSearch()

  _getCustomFormRules = (customFormValue)->
    if customFormValue == ''
      {}
    else
      $('#custom-form').queryBuilder('getRules')

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
    $('#builder, #custom-form').on 'afterCreateRuleFilters.queryBuilder', ->
      _initSelect2()
      _handleSelectOptionChange()
      _referred_to_program()

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

  _getTranslation = ->
    @filterTranslation =
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')


  _customFormSetRule = ->
    customFormQueryRules = $('#custom-form').data('custom-form-search-rules')
    if !$.isEmptyObject customFormQueryRules
      $('#custom-form').queryBuilder('setRules', customFormQueryRules)

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
