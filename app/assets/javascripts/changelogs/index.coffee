CIF.ChangelogsIndex = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2();

  { init: _init }
