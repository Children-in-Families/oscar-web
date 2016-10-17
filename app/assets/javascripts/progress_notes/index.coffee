CIF.Progress_notesIndex = do ->
  _init = ->
    _select2()
    _fixedHeaderTableColumns()

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  _fixedHeaderTableColumns = ->
    if !$('table.progress-notes tbody tr td').hasClass('noresults')
      $('table.progress-notes').DataTable(
        'sScrollY': '500px'
        'sScrollX': true
        'sScrollXInner': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false)

  { init: _init }
