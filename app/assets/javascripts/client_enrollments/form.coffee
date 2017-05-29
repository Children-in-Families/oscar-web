CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = do -> 
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }