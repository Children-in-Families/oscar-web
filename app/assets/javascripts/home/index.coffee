CIF.HomeIndex = do ->
  _init = ->
    _clientGenderChart()
    _clientStatusChart()
    _familyType()
    _resizeChart()

  _handleCreateChart = (element, data) ->
    $(element).highcharts
      colors: ['#01a301', '#037d82', '#038fa8', '#DDDF00', '#24CBE5']
      chart:
        height: 380
        backgroundColor: '#ecf0f1'
        type: 'pie' 
        borderWidth: 1
        borderColor: "#ddd"
      legend: verticalAlign: 'top', y: 10
      title: text: ''
      tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
      plotOptions: pie:
        data: data
        allowPointSelect: true
        cursor: 'pointer'
        showInLegend: true
        point: events: click: ->
          location.href = @options.url
      series: [ {
        name: 'Counts'
        dataLabels:
          distance: -30
          style: fontSize:'13px'
          formatter: ->
            @point.name + ': <b>' + @point.y + '</b>'
      }]
    $('.highcharts-credits').css('display', 'none')

  _resizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        window.dispatchEvent new Event('resize')
    ), 220
     
  _clientGenderChart = ->
    element = $('#client-by-gender')
    data    = $(element).data('content-count')
    _handleCreateChart(element, data)

  _clientStatusChart = ->
    element = $('#client-by-status')
    data    = $(element).data('content-count')
    _handleCreateChart(element, data)

  _familyType = ->
    element = $('#family-type')
    data    = $(element).data('content-count')
    _handleCreateChart(element, data)

  { init: _init }