class CIF.ReportCreator
  constructor: (dataCate, dataValue, title, yAxisTitle, element) ->
    @dataCate = dataCate
    @dataValue = dataValue
    @title = title
    @yAxisTitle = yAxisTitle
    @element = element
    
  perform: ->
    @reportOption()

  reportOption: (@dataCate, @dataValue, @title, @yAxisTitle, @element) ->
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
        categories: @dataCate
        dateTimeLabelFormats:
          month: '%b %Y'
        tickmarkPlacement: 'on'
      yAxis:
        allowDecimals: false
        title:
          text: @yAxisTitle
      series: @dataValue