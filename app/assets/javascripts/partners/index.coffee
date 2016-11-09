CIF.PartnersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()

  _fixedHeaderTableColumns = ->
    if !$('table.partners tbody tr td').hasClass('noresults')
      $('table.partners').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'ordering': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%'
        'sScrollXInner': '100%')

  _handleScrollTable = ->
    $(window).load ->
      $('.partners-table .dataTables_scrollBody').niceScroll()

  { init: _init }
