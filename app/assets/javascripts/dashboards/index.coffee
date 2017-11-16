CIF.DashboardsIndex = do ->
  _init = ->
    # _clientGenderChart()
    # _clientStatusChart()
    _familyType()
    _resizeChart()
    _clientProgramStreamByGender()
    _clientProgramStream()
    _initSelect2()
    _filterUserTask()
    _openTaskListModal()

  _openTaskListModal = ->
    if window.location.href.indexOf('user_id') >= 0
      $('#active_tasks_list').modal('show')

  _filterUserTask = ->
    $('form#filtered_by_user select#user_id').change ->
      $('form#filtered_by_user').submit()

  _initSelect2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  _resizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        window.dispatchEvent new Event('resize')
    ), 220

  # _clientGenderChart = ->
  #   element = $('#client-by-gender')
  #   data    = $(element).data('content-count')
  #   report = new CIF.ReportCreator(data, '', '', element)
  #   report.donutChart()

  # _clientStatusChart = ->
  #   element = $('#client-by-status')
  #   data    = $(element).data('content-count')
  #   report = new CIF.ReportCreator(data, '', '', element)
  #   report.pieChart()

  _familyType = ->
    element = $('#family-type')
    data    = $(element).data('content-count')
    report = new CIF.ReportCreator(data, '', '', element)
    report.pieChart()

  _clientProgramStreamByGender = ->
    element = $('#client-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')
    report = new CIF.ReportCreator(data, title, '', element)
    report.donutChart()

  _clientProgramStream = ->
    element = $('#client-by-program-stream')
    data    = $(element).data('content-count')
    title    = $(element).data('title')
    report = new CIF.ReportCreator(data, title, '', element)
    report.pieChart(option: true)

  { init: _init }
