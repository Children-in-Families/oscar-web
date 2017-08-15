CIF.Program_streamsIndex = do ->
  _init = ->
    _getFamilyPath()
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _activeTab()

  _fixedHeaderTableColumns = ->
    table = $('.program-stream-table')
    new CIF.TableScroll(table).fixedHeaderTable()

  _handleScrollTable = ->
    new CIF.TableScroll('').hideScrollOnMobile()

  _getFamilyPath = ->
    $('table.program-streams tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(@).data('href')

  _activeTab = ->
    if window.location.href.split('tab')[1].substr(1) == 'all_ngo'
      $('a[href="#ngos-program-streams"]').tab('show')

  { init: _init }