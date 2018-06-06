CIF.ReferralsIndex = do ->
  _init = ->
    _initTooltip()

  _initTooltip = ->
    $('[data-toggle="tooltip"]').tooltip()


  { init: _init }
