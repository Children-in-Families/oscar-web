CIF.UsersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getUserPath()
    _initSelect2()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  _fixedHeaderTableColumns = ->
    $('.users-table').removeClass('table-responsive')
    if !$('table.users tbody tr td').hasClass('noresults')
      $('table.users').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.users-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.users-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getUserPath = ->
    return if $('table.users tbody tr').text().trim() == 'No results found'|| $('table.users tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.users tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
