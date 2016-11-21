class CIF.ReportCreator
  constructor: (data, title, yAxisTitle, element) ->
    @data = data
    @title = title
    @yAxisTitle = yAxisTitle
    @element = element
    
  perform: ->
    @lineChart()
    @pieChart()

  lineChart: ->
    if @data != undefined
      $(@element).highcharts
        chart:
          type: 'spline'
        legend:
          verticalAlign: 'top'
          y: 30
        plotOptions:
          series:
            connectNulls: true
        tooltip:
          shared: true
          xDateFormat: '%b %Y'
        title:
          text: @title
        xAxis:
          categories: @data[0]
          dateTimeLabelFormats:
            month: '%b %Y'
          tickmarkPlacement: 'on'
        yAxis:
          allowDecimals: false
          title:
            text: @yAxisTitle
        series: @data[1]
      $('.highcharts-credits').css('display', 'none')

  pieChart: ->
    $(@element).highcharts
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
        size:'100%'
        data: @data
        allowPointSelect: true
        cursor: 'pointer'
        showInLegend: true
        point: events: click: ->
          location.href = @options.url
      series: [ {
        name: 'Counts'
        borderWidth: 0
        dataLabels:
          distance: -30
          style: fontSize: '1.3em'
          formatter: ->
            @point.name + ": " + @point.y
      }]
    $('.highcharts-credits').css('display', 'none')