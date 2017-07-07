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

    $(exitDate).add(exitNote).bind 'keyup change', ->
      if exitNote.val() == '' or exitDate.val() == ''
        $('#exitFromNgo .client_confirm_exit').attr 'disabled', 'disabled'
      else
        $('#exitFromNgo .client_confirm_exit').removeAttr 'disabled'

  _exitModalValidate = ->
    exitDate = $('#case_exit_date')
    exitNote = $('#case_exit_note')

    $(exitDate).add(exitNote).bind 'keyup change', ->
      if exitNote.val() == '' or exitDate.val() == ''
        $('#exit-from-case .case_confirm_exit').attr 'disabled', 'disabled'
      else
        $('#exit-from-case .case_confirm_exit').removeAttr 'disabled'

  # _validateExitButton = (id) ->
  #   exitNote = $("#{id} .exit_note").val()
  #   exitDate = $("#{id} input.exit_date").val()

  #   if exitNote == '' or exitDate == ''
  #     $("#{id} .case_confirm_exit").attr 'disabled', 'disabled'
  #   else
  #     $("#{id} .case_confirm_exit").removeAttr 'disabled'

  { init: _init }