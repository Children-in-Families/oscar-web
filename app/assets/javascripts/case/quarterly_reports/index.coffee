CIF.Quarterly_reportsIndex = do ->
  _init = ->
    _getQuarterlyReportPath()

  _getQuarterlyReportPath = ->
    $('table.quarterly-reports tbody tr').click ->
      window.location = $(this).data('href')

  { init: _init }
