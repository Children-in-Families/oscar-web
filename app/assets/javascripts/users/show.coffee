CIF.UsersShow = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    $('table.clients').DataTable(
      'sScrollY': '500px'
      'sScrollX': true
      'sScrollXInner': '100%'
      'bPaginate': false
      'bFilter': false
      'bInfo': false
      'ordering': false)

  { init: _init }