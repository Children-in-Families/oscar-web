CIF.CasesNew = CIF.CasesCreate = CIF.CasesUpdate = CIF.CasesEdit = do ->
  _init = ->
    _initSelect2()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initSelect2 = ->
    $('select').select2()

  {init: _init}
