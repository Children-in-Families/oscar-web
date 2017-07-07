CIF.CalendarsIndex = do ->
  _init = ->
    _calendars()

  _calendars = ->
    $.ajax({
      type: 'GET'
      url: 'api/calendars/find_event'
      dataType: "JSON"
    }).success((json)->
      eventLists = json.calendars
      $('#calendar').fullCalendar(
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
            delay: 200
            placement: 'top'
            content: event.title
            trigger: 'hover'
            container: 'body'
      )
      $('.loader').hide()
    )

  _fillFullCalendarArray = (eventLists) ->
    events = []
    for eventList in eventLists
      summary = eventList.title
      startDate = eventList.start_date
      endDate = eventList.end_date
      fullDate = null
      if (Date.parse(startDate) + 86400000) == Date.parse(endDate)
        fullDate = true
      events.push(
        title: summary
        start: moment.parseZone(startDate)
        end: moment.parseZone(endDate)
        allDay: fullDate
      )
    events

  { init: _init }
