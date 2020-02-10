CIF.CallsIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _initSelect2()
    _initAdavanceSearchFilter()
    _getCallPath()

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
    $('#calls-index select').select2
      minimumInputLength: 0,
      allowClear: true

  _initAdavanceSearchFilter = ->
    # advanceFilter = new CIF.CallAdvanceSearch()
    # advanceFilter.initBuilderFilter('#call-builder-fields')
    # advanceFilter.setValueToBuilderSelected()
    # advanceFilter.getTranslation()
    return

  _getCallPath = ->
    return if $('table.calls tbody tr').text().trim() == 'No results found' || $('table.clients tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.clients tbody tr').text().trim() == 'No data available in table'
    $('table.calls tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')
    return

  { init: _init }
