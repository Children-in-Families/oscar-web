CIF.DonorsIndex = do ->
  _init = ->
    _select2()

  _select2 = ->
    $('select').select2
      minimumInputLength: 0

  { init: _init }
