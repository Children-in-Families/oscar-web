CIF.CasesNew = CIF.CasesCreate = CIF.CasesUpdate = CIF.CasesEdit = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  {init: _init}