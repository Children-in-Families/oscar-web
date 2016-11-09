CIF.UsersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    if !$('table.users tbody tr td').hasClass('noresults')
      $('table.users').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%'
        'sScrollXInner': '100%')

  { init: _init }
