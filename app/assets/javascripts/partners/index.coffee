CIF.PartnersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getPartnerPath()

  _fixedHeaderTableColumns = ->
    $('.partners-table').removeClass('table-responsive')
    if !$('table.partners tbody tr td').hasClass('noresults')
      $('table.partners').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.partners-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.partners-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getPartnerPath = ->
    return if $('table.partners tbody tr').text().trim() == 'No results found' || $('table.partners tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.partners tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
