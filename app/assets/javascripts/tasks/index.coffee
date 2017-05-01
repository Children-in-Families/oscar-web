CIF.TasksIndex = do ->
  _init = ->
    _addToCalendar()
    _initSelect2()

  _addToCalendar = ->
    $('.add-to-calendar').each ->
      title = $(this).parents('td').siblings('.task-detail').html()
      desc  = $(this).parents('td').siblings('.task-domain').data('domain')
      date  = $(this).parents('td').siblings('.task-due-date').html()
      start = new Date(date)
      end   = new  Date(date)
      start.setHours(0,0,0,0)
      end.setHours(23,59,59,999)

      AustDayLunch =
        start: start
        end: end
        title: title
        description: desc
      $(this).icalendar($.extend({sites: ['google', 'yahoo']}, AustDayLunch))

  _initSelect2 = ->
    $('select').select2()

  { init: _init }
