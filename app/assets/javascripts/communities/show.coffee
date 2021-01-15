CIF.CommunitiesShow = do ->
  _init = ->
    _buttonHelpTextPophover()

  _buttonHelpTextPophover = ->
    $("button[data-content]").popover();

  { init: _init }
