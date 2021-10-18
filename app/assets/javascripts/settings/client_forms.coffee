CIF.SettingsClient_forms = CIF.SettingsFamily_case_management = CIF.SettingsCommunity = CIF.SettingsTest_client = do ->
  _init = ->
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
  { init: _init }
