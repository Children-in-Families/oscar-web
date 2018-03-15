CIF.ClientsShow = do ->
  _init = ->
    _initSelect2()
    # _rejectModal()
    _exitModalValidate()
    _exitNgoValidator()

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
    exitDate = $('#exitForm #client_exit_date')
    exitNote = $('#exitForm #client_exit_note')
    formId = $('#exitForm')

    _validateExitButton(formId, exitDate)

    $(exitDate).bind 'keyup change', ->
      _validateExitButton(formId, exitDate)

  _exitModalValidate = ->
    exitDate = $('#case_exit_date')
    exitNote = $('#case_exit_note')
    formId = $('#exit-from-case')

    _validateExitButton(formId, exitDate)

    $(exitDate).bind 'keyup change', ->
      _validateExitButton(formId, exitDate)

  _validateExitButton = (formId, exitDate) ->
    exitDate = $(exitDate).val()
    exitNote = $(exitNote).val()

    if exitDate == ''
      $(formId).find('.confirm-exit').attr 'disabled', 'disabled'
    else
      $(formId).find('.confirm-exit').removeAttr 'disabled'

  { init: _init }
