CIF.ClientsShow = do ->
  _init = ->
    _initSelect2()

    _caseModalValidation()
    _exitNgoModalValidation()
    _enterNgoModalValidation()
    _triggerExternalReferral()

  _initSelect2 = ->
    $('select').select2()

  _triggerExternalReferral = ->
    _handleExternalReferralSelected()
    $('.referral_referred_to').on 'change', ->
      _handleExternalReferralSelected()

  _handleExternalReferralSelected = ->
    save = $("#save-text").val()
    save_and_download = $("#save-and-download-text").val()
    referred_to = document.getElementById('referral_referred_to')
    selected_ngo = referred_to.options[referred_to.selectedIndex].value
    if selected_ngo == 'external referral'
      $('.external-referral-warning').removeClass 'text-hide'
      $('.btn-save').val save_and_download
    else
      $('.external-referral-warning').addClass 'text-hide'
      $('.btn-save').val save

  _enterNgoModalValidation = ->
    data = {
      date: '#enter_ngo_accepted_date',
      field: '#enter_ngo_user_ids',
      form: '#enter-ngo-form',
      btn: '.agree-btn'
    }
    _modalFormValidator(data)

  _caseModalValidation = ->
    data = {
      date: '#case_exit_date',
      field: '#case_exit_note',
      form: '#exit-from-case',
      btn: '.confirm-exit'
    }
    _modalFormValidator(data)

  _exitNgoModalValidation = ->

    data = {
      date: '#exitFromNgo #exit_ngo_exit_date',
      field: '#exitFromNgo #exit_ngo_exit_circumstance',
      note: '#exitFromNgo #exit_ngo_exit_note',
      form: '#exitFromNgo',
      btn: '.confirm-exit'
    }
    _modalFormValidator(data)

  _modalFormValidator = (data)->
    date = data['date']
    field = data['field']
    note = data['note']
    form = data['form']
    btn = data['btn']
    _modalButtonAction(form, date, field, note, btn)

    $(date).add(field).add(note).bind 'keyup change', ->
      _modalButtonAction(form, date, field, note, btn)

  _modalButtonAction = (form, date, field, note, btn) ->
    date = $(date).val()
    field = $(field).val()
    note = $(note).val()

    if (field == '' or field == null) or date == '' or note == ''
      $(form).find(btn).attr 'disabled', 'disabled'
    else
      $(form).find(btn).removeAttr 'disabled'

  { init: _init }
