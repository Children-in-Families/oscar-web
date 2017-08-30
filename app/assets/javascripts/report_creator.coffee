class CIF.ReportCreator
  constructor: (data, title, yAxisTitle, element) ->
    @data = data
    @title = title
    @yAxisTitle = yAxisTitle
    @element = element
    @colors = ['#4caf50', '#00695c', '#01579b', '#4dd0e1', '#2e7d32', '#4db6ac', '#00897b', '#a5d6a7', '#43a047', '#c5e1a5', '#7cb342', '#fdd835', '#fb8c00', '#6d4c41', '#757575',
              '#ef9a9a', '#e53935', '#f48fb1', '#d81b60', '#ce93d8', '#8e24aa', '#b39ddb', '#7e57c2', '#9fa8da', '#3949ab', '#64b5f6', '#827717']
  perform: ->
    @lineChart()
    @pieChart()
    @donutChart()

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

  donutChart: ->
    [green, blue, africa, brown, yellow] = ["#59b260", "#5096c9", "#1c8781", "#B2912F", "#DECF3F"]
    $(@element).highcharts
      colors: @colors
      chart:
        type: 'pie'
        height: 500
        backgroundColor: '#ecf0f1'
        borderWidth: 1
        borderColor: "#ddd"
        marginBottom: 50
      title:
        text: @title
        style:
          fontSize: '1.6em'
      legend:
        verticalAlign: 'top'
        itemMarginTop: 5
        itemMarginBottom: 5
        y: 30
        itemStyle:
           fontSize: '12px'
      plotOptions: pie:
        shadow: false
      series: [
        {
          data: @data
          name: 'Gender'
          size: '60%'
          dataLabels:
            formatter: ->
              @point.name + ': ' + @point.y
            color: '#ffffff'
            distance: -50
        }
        {
          data: @data[0].active_data.concat(@data[1].active_data)
          name: 'Case'
          size: '90%'
          innerSize: '60%'
          allowPointSelect: true
          cursor: 'pointer'
          showInLegend: true
          point: events: click: ->
            location.href = @options.url
          dataLabels:
            style: fontSize: '13px'
            distance: 30
            color: '#000000'
            formatter: ->
              @point.name + ': ' + @point.y
          id: 'versions'
        }
      ]
      responsive:
        rules: [
          condition: maxWidth: 1024
          chartOptions:
            series: [
              id: 'versions'
              dataLabels:
                style: fontSize: '13px'
                distance: 20
                color: '#000000'
                formatter: ->
                  if _.includes(@point.name.split(' '), '(Female)') then 'Female: ' + @point.y else 'Male: ' + @point.y
            ]
        ]
    $('.highcharts-credits').css('display', 'none')

  pieChart: ->
    [green, blue, africa, brown, yellow] = ["#59b260", "#5096c9", "#1c8781", "#B2912F", "#DECF3F"]
    $(@element).highcharts
      colors: @colors
      chart:
        height: 380
        backgroundColor: '#ecf0f1'
        type: 'pie'
        borderWidth: 1
        borderColor: "#ddd"
      legend:
        verticalAlign: 'top'
        y: 10
        itemStyle:
           fontSize: '15px'
      title:
        text: ''
      tooltip:
        formatter: ->
          @point.name + ": " + "<b>" + @point.y + "</b>"
        style:
          fontSize: '15px'
      plotOptions:
        pie:
          size:'100%'
          data: @data
          allowPointSelect: true
          cursor: 'pointer'
          showInLegend: true
          point: events: click: ->
            location.href = @options.url
      series: [ {
        dataLabels:
          distance: -30
          style:
            fontSize: '1.3em'
          formatter: ->
            @point.name + ": " + @point.y
      }]
    $('.highcharts-credits').css('display', 'none')
