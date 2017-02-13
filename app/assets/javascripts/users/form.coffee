CIF.UsersNew = CIF.UsersCreate = CIF.UsersEdit = CIF.UsersUpdate = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('.select2').select2()

  { init: _init }
