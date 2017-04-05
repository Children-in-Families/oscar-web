CIF.ClientsAdvanced_search = do ->
  _init = ->
    _columnsVisibility()
    _initJqueryQueryBuilder()
    _handleInitDatatable()
    _handleSearch()
    _addRuleCallback()
    _handleScrollTable()
    _getClientPath()
    _setDefaultCheckColumnVisibilityAll()

  _initJqueryQueryBuilder = ->
    filterTranslation = $('#builder').data('filter-translation')
    $.ajax
      url: '/api/v1/advance_searches/'
      method: 'GET'
      success: (response) ->
        fieldList = response.advance_searches
        $('#builder').queryBuilder
          allow_groups: false
          conditions: ['AND']
          inputs_separator: ' AND '
          icons:
            remove_rule: 'fa fa-minus'
          lang:
            delete_rule: ''
            add_rule: filterTranslation
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
        _setRuleJqueryQueryBuilder()
        _changeButtonAddRuleSize()
        _handleSelectOptionChange()
        _initSelect2()

  _initSelect2 = ->
    $('select').select2(
      width: 'resolve'
    )

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
      checkboxes = $('.visibility input[type=checkbox]').prop('checked')
      if !checkboxes
        $('.all-visibility #all_').iCheck('check')
      )

  _addRuleCallback = ->
    $('#builder').on 'afterCreateRuleFilters.queryBuilder', ->
      _initSelect2()
      _handleSelectOptionChange()

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

  _changeButtonAddRuleSize = ->
    $("button[data-add='rule']").removeClass('btn-xs btn-success')
    $("button[data-add='rule']").addClass('btn-primary')

  _setRuleJqueryQueryBuilder = ->
    queryRules = $('#builder').data('search-rules')

    queryCondition = $('#builder').data('search-condition')
    if queryRules != undefined
      $('#builder').queryBuilder('setRules', queryRules)

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

  _handleSearch = ->
    $('#search').on 'click', ->
      rules = JSON.stringify($('#builder').queryBuilder('getRules'))
      rules = rules.replace('null', '""')
      if !($.isEmptyObject($('#builder').queryBuilder('getRules')))
        $('#client_search_rules').val(rules)
        _handleSelectValueCheckBox()
        $('#advanced-search').submit()

  _handleSelectValueCheckBox = ->
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

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')

  _getClientPath = ->
    $('table.clients tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
