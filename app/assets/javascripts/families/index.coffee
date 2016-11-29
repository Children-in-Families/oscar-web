CIF.FamiliesIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    # _resizeNiceScroll()

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
      $('.families-table .dataTables_scrollBody').niceScroll fixed:true

  _resizeNiceScroll = ->
    $('.navbar-minimalize').click ->
      console.log($('.families-table .dataTables_scrollBody').getNiceScroll())
      $('.families-table .dataTables_scrollBody').getNiceScroll ->
        window.dispatchEvent new Event('resize')

  { init: _init }
