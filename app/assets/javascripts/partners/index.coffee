CIF.PartnersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()

  _fixedHeaderTableColumns = ->
    if !$('table.partners tbody tr td').hasClass('noresults')
      $('table.partners').DataTable(
        'sScrollY': '500px'
        'sScrollX': true
        'sScrollXInner': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false)

  { init: _init }