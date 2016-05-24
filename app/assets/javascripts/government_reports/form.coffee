CIF.Government_reportsNew = CIF.Government_reportsCreate = CIF.Government_reportsEdit = CIF.Government_reportsUpdate = do ->
  _init = ->
    _missionCheckable()
    _removeDisabledClass()

  _missionCheckable = ->
    noneObtainable = $('#government_report_mission_obtainable_false')
    obtainable = $('#government_report_mission_obtainable_true')
    missions   = $('#government_report_first_mission, #government_report_second_mission, #government_report_third_mission, #government_report_fourth_mission')
    obtainable.click ->
      missions.prop('disabled', false)
    noneObtainable.click ->
      missions.prop('disabled', true)

  _removeDisabledClass = ->
    $('.missions input.disabled').removeClass('disabled')

  { init: _init }