CIF.ClientsBook = do ->
  _init = ->
    _initScoreTooltip()

  _initScoreTooltip = ->
    $('.case-note-domain-score').tooltip
      placement: 'top'
      html: true

  { init: _init }
