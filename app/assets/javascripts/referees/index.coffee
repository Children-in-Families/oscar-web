CIF.RefereesIndex = do ->
  _init = ->
    _initSelect2()
    _getCallPath()
    _fixedHeaderTableColumns()

  _initSelect2 = ->
    $('#referees-index select').select2
      allowClear: true

  _getCallPath = ->
    return if $('table.referees tbody tr').text().trim() == 'No results found' || $('table.referees tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.referees tbody tr').text().trim() == 'No data available in table'
    $('table.referees tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')
    return

  _fixedHeaderTableColumns = ->
    $('.referees-table').removeClass('table-responsive')
    if !$('table.referees tbody tr td').hasClass('noresults')
      $('table.referees').dataTable(
        'sScrollX': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
      )
    else
      $('.referees-table').addClass('table-responsive')

  { init: _init }
