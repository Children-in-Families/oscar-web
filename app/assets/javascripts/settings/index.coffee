CIF.SettingsIndex = do ->
  _init = ->
    _initSelect2()

  _initSelect2 = ->
    $('#setting_assessment_frequency').select2()

  { init: _init }