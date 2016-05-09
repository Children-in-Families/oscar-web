CIF.Government_reportsNew = CIF.Government_reportsCreate = CIF.Government_reportsEdit = CIF.Government_reportsUpdate = do ->
  _init = ->
    _missionCheckable()

  _missionCheckable = ->
    obtainable   = $('#government_report_mission_obtainable')
    missions   = $('#government_report_first_mission, #government_report_second_mission, #government_report_third_mission, #government_report_fourth_mission')
    if obtainable.prop('checked') == true
      missions.prop('disabled', false)
    else
      missions.prop('disabled', true)
    
    obtainable.change ->
      _missionCheckable()

  { init: _init }