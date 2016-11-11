CIF.PartnersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()

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
        'sScrollX': '100%'
        'sScrollXInner': '100%')
    else
      $('.partners-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      $('.partners-table .dataTables_scrollBody').niceScroll()

  { init: _init }
