CIF.Quarterly_reportsIndex = do ->
  _init = ->
    _getFamilyPath()

  _getFamilyPath = ->
    $('table.quarterly-reports tbody tr').click ->
      window.location = $(this).data('href')

  { init: _init }
