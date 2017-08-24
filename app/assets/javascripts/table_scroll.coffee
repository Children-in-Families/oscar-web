class CIF.TableScroll
  constructor: (table) ->
    @table = table

  fixedHeaderTable: ->
    $(@table).dataTable(
      'sScrollY': '500'
      'sScrollX': '100%'
      'bPaginate': false
      'bFilter': false
      'bInfo': false
      'bSort': false
      'bAutoWidth': true)

  hideScrollOnMobile: ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
