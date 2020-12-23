CIF.CallsIndex = do ->
  _init = ->
    _toggleBasicFilter()
    _toggleAdvancedFilter()
    _initAdavanceSearchFilter()
    _setAdavanceSearchFilter()
    _fixedHeaderTableColumns()
    _initSelect2()
    _getCallPath()


  _toggleBasicFilter = ->
    $("button.btn-filter").on 'click', ->
      $('#builder').queryBuilder('reset');
      $("div#call-advance-search-form").removeClass('in').hide()

  _toggleAdvancedFilter = ->
    $("button.call-advance-search").on 'click', ->
      $('#builder').queryBuilder('reset');
      $("div#call-advance-search-form").show()
      $("div#call-search-form").removeClass('in')

  _fixedHeaderTableColumns = ->
    $('.calls-table').removeClass('table-responsive')
    if !$('table.calls tbody tr td').hasClass('noresults')
      $('table.calls').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.users-table').addClass('table-responsive')

  _initSelect2 = ->
    $('#calls-index #call-search-form select').select2
      minimumInputLength: 0,
      allowClear: true

  _initAdavanceSearchFilter = ->
    filterTranslation =
      addCustomGroup: $('#builder').data('filter-translation-add-custom-group')
      addFilter: $('#builder, #wizard-builder').data('filter-translation-add-filter')
      addGroup: $('#builder, #wizard-builder').data('filter-translation-add-group')
      deleteGroup: $('#builder, #wizard-builder').data('filter-translation-delete-group')

    $('#call-search-btn').val($('#call-search-btn').data('search'))

    filters = $("#call-builder-fields").data('fields')
    $('#builder').queryBuilder
      plugins: [
        'select2'
      ]
      icons:
        remove_rule: 'fa fa-minus'
      lang:
        delete_rule: ' '
        add_rule: filterTranslation.addFilter
        add_group: filterTranslation.addGroup
        delete_group: filterTranslation.deleteGroup
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
          average: 'average'
      filters: filters
      lang_code: 'en'

    $('#call-advanced-search').on 'submit', (e) ->
      query = $('#builder').queryBuilder('getRules')
      if query
        res = $('#builder').queryBuilder('getSQL', false, false)
        $('#query_string').val res.sql
        $('#query_builder_json').val JSON.stringify(query)
      else
        e.preventDefault()
        $('#query_builder_json').val null
      return

  _setAdavanceSearchFilter = ->
    queryJson = $('#builder').data('basic-search-rules')
    $('#builder').queryBuilder 'setRules', queryJson if queryJson

  _getCallPath = ->
    return if $('table.calls tbody tr').text().trim() == 'No results found' || $('table.clients tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.clients tbody tr').text().trim() == 'No data available in table'
    $('table.calls tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')
    return

  { init: _init }
