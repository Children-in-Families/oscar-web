CIF.NotificationsIndex = do ->
  _init = ->
    _initFootable()

  _initFootable = ->
    $('.footable').footable()

  { init: _init }
