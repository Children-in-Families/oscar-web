CIF.UsersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    if !$('table.users tbody tr td').hasClass('noresults')
      $('table.users').DataTable(
        'sScrollY': 'auto'
        'sScrollX': true
        'sScrollXInner': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false)

  { init: _init }
