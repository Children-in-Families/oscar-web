CIF.ClientsAdvanced_search = do ->
  _init = ->
    _initJqueryQueryBuilder()
    _handleInitDatatable()
    _handleSearch()
    _addRuleCallback()
    _handleScrollTable()


  _initJqueryQueryBuilder = ->
    filterTranslation = $('#builder').data('filter-translation')
    $.ajax
      url: '/api/advanced_searches/'
      method: 'GET'
      success: (response) ->
        fieldList = response.advanced_searches
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
    $('.client-advanced-search table').DataTable(
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
      rules =  JSON.stringify($('#builder').queryBuilder('getRules'))
      if !($.isEmptyObject($('#builder').queryBuilder('getRules')))
        $('#client_search_rules').val(rules)
        $('#advanced-search').submit()

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.client-advanced-search .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')

  { init: _init }
