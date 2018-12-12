CIF.DashboardsIndex = do ->
  _init = ->
    # _clientGenderChart()
    # _clientStatusChart()
    _familyType()
    _resizeChart()
    _clientProgramStreamByGender()
    _clientProgramStream()
    _initSelect2()
    _openTaskListModal()
    _handleApplyFilter()
    _initCustomFieldsDataTable()
    _initTrackingDatatable()

  _handleApplyFilter = ->
    $('button#user-filter-submit').on 'click', (e) ->
      if $('#tasks').prop('checked') || $('#assessments').prop('checked') || $('#forms').prop('checked')
        e.submit
      else if !($('#tasks').prop('checked') && $('#assessments').prop('checked') && $('#forms').prop('checked'))
        e.preventDefault()
        alertTranslation = $('#active_tasks_list').attr('alert-translation')
        alert(alertTranslation)

  _openTaskListModal = ->
    if window.location.href.indexOf('user_id') >= 0
      $('#active_tasks_list').modal('show')

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

  _initCustomFieldsDataTable = ->
    self = $('#custom-fields-table')
    $(self).DataTable
      bFilter: false
      sScrollY: '500'
      bInfo: false
      processing: true
      serverSide: true
      ajax: $(self).data('url')
      columns:  [
        null
        bSortable: false, className: 'text-center'
      ]
      language:
        paginate:
          previous: $(self).data('previous')
          next: $(self).data('next')
      drawCallback: ->
        _getDataTableId()

  _initTrackingDatatable = ->
    self = $('#program-streams-table')
    $(self).DataTable
      bFilter: false
      sScrollY: '500'
      bInfo: false
      processing: true
      serverSide: true
      ajax: $(self).data('url')
      columns: [
        null
        null
        bSortable: false, className: 'text-center'
      ]
      language:
        paginate:
          previous: $(self).data('previous')
          next: $(self).data('next')
      drawCallback: ->
        _getDataTableId()

  _getDataTableId = ->
    $('.paginate_button a').click ->
      DATA_TABLE_ID = $($(this).parents('.table-responsive').find('.custom-field-table')[1]).attr('id')

  { init: _init }
