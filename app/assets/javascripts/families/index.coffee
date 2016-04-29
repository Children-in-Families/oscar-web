CIF.FamiliesIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    if !$('table.families tbody tr td').hasClass('noresults')
      $('table.families').DataTable(
        'sScrollY': '500px'
        'sScrollX': true
        'sScrollXInner': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false)

  { init: _init }