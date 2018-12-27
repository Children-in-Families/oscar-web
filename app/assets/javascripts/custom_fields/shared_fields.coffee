CIF.Client_custom_fieldsNew = CIF.Client_custom_fieldsCreate = CIF.Client_custom_fieldsEdit = CIF.Client_custom_fieldsUpdate = do ->
  _init = ->
    _select2()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _select2 = ->
    $('select').select2
      minimumInputLength: 0

  { init: _init }
