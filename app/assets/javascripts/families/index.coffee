CIF.FamiliesIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()

  _fixedHeaderTableColumns = ->
    if !$('table.families tbody tr td').hasClass('noresults')
      $('table.families').dataTable(
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
      $('.families-table .dataTables_scrollBody').niceScroll()

  { init: _init }
