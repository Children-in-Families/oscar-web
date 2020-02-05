CIF.CallsEdit = CIF.CallsUpdate = do ->
  _init = ->
    _initICheckBox()
    _initSelect2()

  _initSelect2 = ->
    $('select').select2
      minimumInputLength: 0

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  { init: _init }
