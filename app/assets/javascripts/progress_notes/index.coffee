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
      $('table.progress-notes').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': '500px'
        'bAutoWidth': true
        'sScrollX': '100%'
        'sScrollXInner': '100%'
        )

  { init: _init }
