CIF.ClientsShow = do ->
  _init = ->
    _initSelect2()

    _caseModalValidation()
    _exitNgoModalValidation()
    _enterNgoModalValidation()


  _initSelect2 = ->
    $('select').select2()

  # _rejectModal = ->
  #   note = $('#client_rejected_note').val()
  #   if note == ''
  #     $('.confirm-reject').attr 'disabled', 'disabled'
  #   _rejectFormValidate()

  # _rejectFormValidate = ->
  #   $('#client_rejected_note').keyup ->
  #     note  = $('#client_rejected_note').val()
  #     if note == ''
  #       $('.confirm-reject').attr 'disabled', 'disabled'
  #     else
  #       $('.confirm-reject').removeAttr 'disabled'


  _enterNgoModalValidation = ->
    data = {
      date: '#client_accepted_date',
      field: '#client_user_ids',
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
      date: '#exitFromNgo #client_exit_date',
      field: '#exitFromNgo #client_exit_circumstance',
      form: '#exitFromNgo',
      btn: '.confirm-exit'
    }
    _modalFormValidator(data)

  _modalFormValidator = (data)->
    date = data['date']
    field = data['field']
    form = data['form']
    btn = data['btn']
    _modalButtonAction(form, date, field, btn)

    $(date).add(field).bind 'keyup change', ->
      _modalButtonAction(form, date, field, btn)

  _modalButtonAction = (form, date, field, btn) ->
    date = $(date).val()
    field = $(field).val()

    if (field == '' or field == null) or date == ''
      $(form).find(btn).attr 'disabled', 'disabled'
    else
      $(form).find(btn).removeAttr 'disabled'

  { init: _init }
