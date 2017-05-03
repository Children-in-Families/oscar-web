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
          left: 'prev,next today myCustomButton',
          center: 'title',
          right: 'month,agendaWeek,agendaDay,listWeek'
        events: _fillFullCalendarArray(eventLists)
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
      events.push(
        title: summary
        start: moment.parseZone(startDate)
        end: moment.parseZone(endDate)
        # url: eventUrl
      )
    events

  { init: _init }
