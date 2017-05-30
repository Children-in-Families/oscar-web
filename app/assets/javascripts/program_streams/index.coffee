CIF.Program_streamsIndex = do ->
  _init = ->
    _getFamilyPath()
    _fixedHeaderTableColumns()
    _handleScrollTable()

  _fixedHeaderTableColumns = ->
    $('.families-table').removeClass('table-responsive')
    if !$('table.families tbody tr td').hasClass('noresults')
      $('table.families').dataTable(
        'sScrollX': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true)
    else
      $('.families-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.families-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getFamilyPath = ->
    $('table.program-streams tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(@).data('href')

  { init: _init }