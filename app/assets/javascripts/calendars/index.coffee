CIF.CalendarsIndex = do ->
  _init = ->
    _calendars()

  _calendars = ->
    $.ajax({
      type: 'GET'
      url: '/calendars/find'
      dataType: "JSON"
    }).success((json)->
      eventLists = json.calendars
      $('#calendar').fullCalendar(
        # displayEventTime: false
        header:
          left: 'prev,next today',
          center: 'title',
          right: 'agendaDay,agendaWeek,month,agendaFourDay'
        views:
          agendaFourDay:
            type: 'agenda',
            duration: { days: 4 },
            buttonText: '4 days'
        events: _fillFullCalendarArray(eventLists)
        eventRender: (event, element) ->
          element.popover
            animation: true
            delay: 300
            content: event.title
            trigger: 'hover'
      )
      $('.loader').hide()
    )

  _fillFullCalendarArray = (eventLists) ->
    events = []
    for eventList in eventLists
      summary = eventList.summary
      startDate = eventList.start.date || eventList.start.date_time
      endDate = eventList.end.date || eventList.end.date_time
      # eventUrl = eventList.html_link
      fullDate = null
      if (Date.parse(startDate) + 86400000) == Date.parse(endDate)
        fullDate = true
      events.push(
        title: summary
        start: moment.parseZone(startDate)
        end: moment.parseZone(endDate)
        # url: eventUrl
        allDay: fullDate
      )
    events

  { init: _init }
