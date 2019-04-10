CIF.Referral_sourcesIndex = do ->
  _init = ->
    _initSelect2()
    _newReferralSourceValidation()

  _initSelect2 = ->
    $('select').select2()
  
  _modalFormValidator = (data)->
    name = data['name']
    category = data['category']
    form = data['form']
    btn = data['btn']

    exitReasonsLength = _checkExitReasonsLength(form)
    _modalButtonAction(form, date, field, note, btn, exitReasonsLength)

    $(date).add(field).add(note).bind 'keyup change', ->
      exitReasonsLength = _checkExitReasonsLength(form)
      _modalButtonAction(form, date, field, note, btn, exitReasonsLength)

    $('#exitFromNgo .i-checks, .exit-ngos .i-checks').on 'ifToggled', ->
      exitReasonsLength = _checkExitReasonsLength(form)
      _modalButtonAction(form, date, field, note, btn, exitReasonsLength)
  
  _newReferralSourceValidation = ->
    data = {
      name: '#new_referral_source #referral_source_name',
      category: '#new_referral_source #s2id_referral_source_ancestry'
      form: '#new_referral_source'
      btn: '.form-btn'
    }
    _modalFormValidator(data)
    
  

  { init: _init }
