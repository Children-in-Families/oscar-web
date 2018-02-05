CIF.NotificationsIndex = do ->
  _init = ->
    _initFootable()
    _getAssessmentsPath()

  _initFootable = ->
    $('.footable').footable()

  _getAssessmentsPath = ->
    $('table#upcoming_assessment tbody tr').click (e) ->
      window.open($(@).data('href'), '_blank')

  { init: _init }
