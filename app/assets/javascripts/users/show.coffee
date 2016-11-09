CIF.UsersShow = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    $('table.clients').dataTable(
      'bPaginate': false
      'bFilter': false
      'bInfo': false
      'ordering': false
      'sScrollY': 'auto'
      'bAutoWidth': true
      'sScrollX': '100%'
      'sScrollXInner': '100%')

  { init: _init }
