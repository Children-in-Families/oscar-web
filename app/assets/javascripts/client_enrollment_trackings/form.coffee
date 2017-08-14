CIF.Client_enrollment_trackingsNew = CIF.Client_enrollment_trackingsCreate = CIF.Client_enrollment_trackingsEdit = CIF.Client_enrollment_trackingsUpdate = CIF.Client_enrolled_program_client_enrolled_program_trackingsUpdate =
CIF.Client_enrolled_program_client_enrolled_program_trackingsNew = CIF.Client_enrolled_program_client_enrolled_program_trackingsCreate = CIF.Client_enrolled_program_client_enrolled_program_trackingsEdit = do ->

  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }
