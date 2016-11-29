CIF.Progress_notesIndex = do ->
  _init = ->
    _select2()
    _fixedHeaderTableColumns()
    _handleScrollTable()

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  _fixedHeaderTableColumns = ->
    $('.progress_notes-table').removeClass('table-responsive')
    if !$('table.progress-notes tbody tr td').hasClass('noresults')
      $('table.progress-notes').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%'
        )
    else
      $('.progress_notes-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      $('.progress_notes-table .dataTables_scrollBody').niceScroll()

  { init: _init }
