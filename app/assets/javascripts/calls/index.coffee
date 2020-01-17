CIF.CallsIndex = do ->
  _init = ->
    _initSelect2()
    _initAdavanceSearchFilter()
    _getCallPath()

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
