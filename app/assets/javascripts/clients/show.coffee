CIF.ClientsShow = do ->
  _init = ->
    _rejectModal()
    _exitModalValidate()

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

  _exitModalValidate = ->
    exitFromCaseId = '#exitFromCase'
    exitFromCifId  = '#exitFromCif'

    $("#{exitFromCaseId} .exit_note").val('')
    $("#{exitFromCifId} .exit_note").val('')

    $("#{exitFromCaseId} .exit_note, #{exitFromCaseId} .exit_date").bind 'keyup change', ->
      _validateExitButton(exitFromCaseId)

    $("#{exitFromCifId} .exit_note, #{exitFromCifId} .exit_date").bind 'keyup change', ->
      _validateExitButton(exitFromCifId)

  _validateExitButton = (id) ->
    exitNote = $("#{id} .exit_note").val()
    exitDate = $("#{id} input.exit_date").val()

    if exitNote == '' or exitDate == ''
      $("#{id} .case_confirm_exit").attr 'disabled', 'disabled'
    else
      $("#{id} .case_confirm_exit").removeAttr 'disabled'

  { init: _init }