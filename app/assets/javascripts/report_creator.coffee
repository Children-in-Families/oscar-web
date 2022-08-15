class CIF.ReportCreator
  constructor: (data, title, yAxisTitle, element) ->
    @data = data
    @title = title
    @yAxisTitle = yAxisTitle
    @element = element
    @colors = ['#f9c00c', '#4caf50', '#00695c', '#01579b', '#4dd0e1', '#2e7d32', '#4db6ac', '#00897b', '#a5d6a7', '#43a047', '#c5e1a5', '#7cb342', '#fdd835', '#fb8c00', '#6d4c41', '#757575',
              '#ef9a9a', '#e53935', '#f48fb1', '#d81b60', '#ce93d8', '#8e24aa', '#b39ddb', '#7e57c2', '#9fa8da', '#3949ab', '#64b5f6', '#827717']

  columnChart: ->
    theData = @data
    title = @title
    subtitle = @yAxisTitle
    if @data != undefined
      $(@element).highcharts
        colors: @colors
        chart:
          type: 'column'
          styledMode: true
        title: text: title
        subtitle: text: subtitle
        xAxis:
          categories: theData.categories
          crosshair: true
        yAxis:
          min: 0
          title: text: subtitle
        tooltip:
          headerFormat: '<span style="font-size:10px">{point.key}</span><table>'
          pointFormat: '<tr><td style="color:{series.color};padding:0">{series.name}: </td>' + '<td style="padding:0"><b>{point.y}</b></td></tr>'
          footerFormat: '</table>'
          shared: true
          useHTML: true
        plotOptions: column:
          pointPadding: 0.05
          borderWidth: 0
        series: theData.series

    $('.highcharts-credits').css('display', 'none')

  barChart: ->
    if @data != undefined
      $(@element).highcharts
        colors: @colors
        chart:
          type: 'bar'
        legend:
          verticalAlign: 'top'
          y: 30
        plotOptions:
          series:
            stacking: 'normal'
          bar:
            dataLabels:
              enabled: true
        tooltip:
          shared: true
          xDateFormat: '%b %Y'
        title:
          text: @title
        xAxis: [
          categories: @data.categories
          dateTimeLabelFormats:
            month: '%b %Y'
          tickmarkPlacement: 'on'
        ]
        yAxis: [
          allowDecimals: false
          title:
            text: @yAxisTitle
        ]
        series: @data.series
      $('.highcharts-credits').css('display', 'none')

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
    self = @
    [green, blue, africa, brown, yellow] = ["#59b260", "#5096c9", "#1c8781", "#B2912F", "#DECF3F"]
    $(@element).highcharts
      chart:
        type: 'pie'
        height: 550
        backgroundColor: '#ecf0f1'
        borderWidth: 1
        borderColor: "#ddd"
        marginBottom: 50
      title:
        text: @title
        y: 20
        style:
          fontSize: '1.6em'
      legend:
        verticalAlign: 'top'
        y: 30
        itemMarginTop: 5
        itemMarginBottom: 5
        itemStyle:
          fontSize: '11px'
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
          {
            condition:
              maxWidth: 1024
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
          }
          {
            condition:
              minWidth: 1025
            chartOptions: self.responsiveLegend()
          }
        ]
    $('.highcharts-credits').css('display', 'none')

  pieChart: (options = {})->
    self = @
    $(@element).highcharts
      chart:
        height: if _.isEmpty(options) then 380 else 500
        backgroundColor: '#ecf0f1'
        type: 'pie'
        borderWidth: 1
        borderColor: "#ddd"
        marginBottom: 50
      legend:
        verticalAlign: 'top'
        y: 30
        itemDistance: 20
        itemMarginTop: 5
        itemMarginBottom: 5
        itemStyle:
           fontSize: '12px',
      title:
        text: @title
        y: 20
      tooltip:
        formatter: ->
          @point.name + ": " + "<b>" + @point.y + "</b>"
        style:
          fontSize: '1em'
      plotOptions:
        pie:
          size:'100%'
          data: @data
          allowPointSelect: true
          cursor: 'pointer'
          showInLegend: true
          point: events: click: ->
            window.open(@options.url, '_blank')
      series: [ {
        dataLabels:
          distance: if _.isEmpty(options) then -30 else 30
          style:
            fontSize: '1em'
          formatter: ->
            @point.name + ": " + @point.y
      }]
      responsive: unless _.isEmpty(options) then self.resposivePieChart()

    $('.highcharts-credits').css('display', 'none')

  _highChartsPieChart: (options = {}) ->
    $(@element).highcharts
      chart:
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
        type: 'pie'
      title: text: @title
      tooltip: pointFormat: '{series.name}: <b>{point.y}</b>'
      accessibility: point: valueSuffix: '%'
      plotOptions: pie:
        allowPointSelect: true
        cursor: 'pointer'
        showInLegend: true
        point: events: click: ->
          window.open(@options.url, '_blank')
        dataLabels:
          enabled: true
          format: '<b>{point.name}</b><br>{point.y}'
      series: [ {
        name: @title
        data: @data
      } ]
    $('.highcharts-credits').css('display', 'none')

  resposivePieChart: ->
    self = @
    rules: [
      {
        condition: maxWidth: 425
        chartOptions:
          series: [
            id: 'brands'
            dataLabels: enabled: false
         ]
     }
     {
       condition:
         minWidth: 1025
       chartOptions: self.responsiveLegend()
     }
    ]

  responsiveLegend: ->
    chart:
      marginLeft: 300
      marginTop: 70
    legend:
      layout: 'vertical'
      align: 'left'
      verticalAlign: 'top'
      x: 30
      y: 40
      floating: true
      maxHeight: 400
