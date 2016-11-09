CIF.FamiliesIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    if !$('table.families tbody tr td').hasClass('noresults')
      $('table.families').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%'
        'sScrollXInner': '100%')

  { init: _init }
