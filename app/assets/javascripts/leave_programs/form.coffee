CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =
CIF.Client_enrolled_program_leave_programsNew = CIF.Client_enrolled_program_leave_programsCreate = CIF.Client_enrolled_program_leave_programsEdit = CIF.Client_enrolled_program_leave_programsUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }
