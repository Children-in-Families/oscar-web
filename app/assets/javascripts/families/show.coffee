CIF.FamiliesShow = do ->
  _init = ->
    _handleInitDatatable()
    _handleScrollTable()

  _handleInitDatatable = ->
    $('.clients-table table').DataTable(
        'sScrollY': 'auto'
        'bFilter': false
        'bAutoWidth': true
        'bSort': false
        'sScrollX': '100%'
        'bInfo': false
        'bLengthChange': false
        'bPaginate': false
      )

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  { init: _init }
