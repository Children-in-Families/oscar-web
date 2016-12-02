CIF.Government_reportsNew = CIF.Government_reportsCreate = CIF.Government_reportsEdit = CIF.Government_reportsUpdate = do ->
  _init = ->
    _missionCheckable()
    _removeDisabledClass()

  _missionCheckable = ->
    noneObtainable = $('#government_report_mission_obtainable_false')
    obtainable = $('#government_report_mission_obtainable_true')
    missions   = $('#government_report_first_mission, #government_report_second_mission, #government_report_third_mission, #government_report_fourth_mission')
    obtainable.on 'ifChecked', ->
      missions.prop('disabled', false)
      $('#mission-checked').find('.disabled').removeClass('disabled')
      $('#mission-checked').find("input[type='hidden']").removeAttr('disabled')
    noneObtainable.on 'ifChecked', ->
      missions.prop('disabled', true)
      missions.prop('checked', false)
      $('#mission-checked').find('div').addClass('disabled')
      $('#mission-checked').find('div').removeClass('checked')
  _removeDisabledClass = ->
    $('.missions input.disabled').removeClass('disabled')

  { init: _init }
