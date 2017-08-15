CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =
CIF.Leave_enrolled_programsNew = CIF.Leave_enrolled_programsCreate = CIF.Leave_enrolled_programsEdit = CIF.Leave_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }
