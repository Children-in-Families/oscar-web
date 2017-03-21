CIF.Progress_notesIndex = do ->
  _init = ->
    _select2()
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getProgressNotePath()

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
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.progress_notes-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getProgressNotePath = ->
    $('table.progress-notes tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
