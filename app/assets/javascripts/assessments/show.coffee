CIF.AssessmentsShow = do ->
  _init = ->
    _initScoreTooltip()

  _initScoreTooltip = ->
    $('.domain-score button').tooltip
      placement: 'top'
      html: true

  { init: _init }
