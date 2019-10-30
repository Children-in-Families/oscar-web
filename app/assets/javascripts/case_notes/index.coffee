CIF.Case_notesIndex = do ->
  _init = ->
    _initScoreTooltip()
    _initSelect2()

  _initScoreTooltip = ->
    $('.case-note-domain-score').tooltip
      placement: 'top'
      html: true

  _initSelect2 = ->
    $('select').select2
      width: '100%'

  { init: _init }
