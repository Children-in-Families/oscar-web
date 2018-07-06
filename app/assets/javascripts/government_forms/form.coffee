CIF.Government_formsNew = CIF.Government_formsCreate = CIF.Government_formsEdit = CIF.Government_formsUpdate = do ->
  _init = ->
    _select2()

  _select2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true
  #   _missionCheckable()
  #   _removeDisabledClass()
  #
  # _missionCheckable = ->
  #   noneObtainable = $('#government_form_mission_obtainable_false')
  #   obtainable = $('#government_form_mission_obtainable_true')
  #   missions   = $('#government_form_first_mission, #government_form_second_mission, #government_form_third_mission, #government_form_fourth_mission')
  #   obtainable.on 'ifChecked', ->
  #     missions.prop('disabled', false)
  #     $('#mission-checked').find('.disabled').removeClass('disabled')
  #     $('#mission-checked').find("input[type='hidden']").removeAttr('disabled')
  #   noneObtainable.on 'ifChecked', ->
  #     missions.prop('disabled', true)
  #     missions.prop('checked', false)
  #     $('#mission-checked').find('div').addClass('disabled')
  #     $('#mission-checked').find('div').removeClass('checked')
  # _removeDisabledClass = ->
  #   $('.missions input.disabled').removeClass('disabled')

  { init: _init }
