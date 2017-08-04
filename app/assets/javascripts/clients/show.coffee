CIF.ClientsShow = do ->
  _init = ->
    _rejectModal()
    _exitModalValidate()
    _exitNgoValidator()
    _initSelect2()

  _initSelect2 = ->
    $('select').select2()

  _rejectModal = ->
    note = $('#client_rejected_note').val()
    if note == ''
      $('.confirm-reject').attr 'disabled', 'disabled'
    _rejectFormValidate()

  _rejectFormValidate = ->
    $('#client_rejected_note').keyup ->
      note  = $('#client_rejected_note').val()
      if note == ''
        $('.confirm-reject').attr 'disabled', 'disabled'
      else
        $('.confirm-reject').removeAttr 'disabled'

  _exitNgoValidator = ->
    exitDate = $('#exitFromNgo #client_exit_date')
    exitNote = $('#exitFromNgo #client_exit_note')
    formId = $('#exitFromNgo')

    _validateExitButton(formId, exitDate, exitNote)

    $(exitDate).add(exitNote).bind 'keyup change', ->
      _validateExitButton(formId, exitDate, exitNote)

  _exitModalValidate = ->
    exitDate = $('#case_exit_date')
    exitNote = $('#case_exit_note')
    formId = $('#exit-from-case')

    _validateExitButton(formId, exitDate, exitNote)

    $(exitDate).add(exitNote).bind 'keyup change', ->
      _validateExitButton(formId, exitDate, exitNote)

  _validateExitButton = (formId, exitDate, exitNote) ->
    exitDate = $(exitDate).val()
    exitNote = $(exitNote).val()

    if exitNote == '' or exitDate == ''
      $(formId).find('.confirm-exit').attr 'disabled', 'disabled'
    else
      $(formId).find('.confirm-exit').removeAttr 'disabled'

  { init: _init }