CIF.Client_program_streamsNew = CIF.Client_program_streamsCreate = do -> 
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  { init: _init }