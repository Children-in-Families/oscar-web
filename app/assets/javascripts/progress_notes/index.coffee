CIF.Progress_notesIndex = do ->
  _init = ->
    _select2()

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true

  { init: _init }
