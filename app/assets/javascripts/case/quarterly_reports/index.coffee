CIF.Quarterly_reportsIndex = do ->
  _init = ->
    _getQuarterlyReportPath()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _getQuarterlyReportPath = ->
    $('table.quarterly-reports tbody tr').click ->
      window.location = $(this).data('href')

  { init: _init }
