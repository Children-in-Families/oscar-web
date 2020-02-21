CIF.SettingsCustom_fields = do ->
  _init = ->
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
  { init: _init }