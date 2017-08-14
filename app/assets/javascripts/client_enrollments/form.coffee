CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate =
CIF.Client_enrolled_programsNew = CIF.Client_enrolled_programsCreate = CIF.Client_enrolled_programsEdit = CIF.Client_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }
