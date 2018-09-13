CIF.ClientsShow = do ->
  _init = ->
    _initSelect2()

    _caseModalValidation()
    _exitNgoModalValidation()
    _editExitNgoModalValidation()
    _enterNgoModalValidation()
    _ajaxCheckReferral()
    _initUploader()
    _initDatePicker()

  _initDatePicker = ->
    $('.accepted_date').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      orientation: 'bottom',
      disableTouchKeyboard: true

  _initSelect2 = ->
    $('select').select2()

  _ajaxCheckReferral = ->
    $('a.target-ngo').on 'click', (e) ->
      e.preventDefault()
      self= @
      id= @.id
      href = @.href
      data = {
        org: id
        clientId: $('#client-id').val()
      }
      $.ajax
        type: 'GET'
        url: '/api/referrals/compare'
        data: data

        success: (response) ->
          modalTitle = $('#hidden_title').val()
          modalTextFirst  = $('#body_first').val()
          modalTextSecond = $('#hidden_body_second').val()
          modalTextThird  = $('#hidden_body_third').val()
          responseText = response.text
          if responseText == 'create referral'
            window.location.replace href
          else if responseText == 'exited client'
            $('#confirm-repeat-referral-modal').modal('show')
            $('#confirm-repeat-referral-modal .modal-body').html(modalTextFirst.replace '<<date>>', response.date)
            $('#confirm-box').on 'ifChecked', (event) ->
              window.location.replace href
          else if responseText == 'already exist'
            $('#confirm-referral-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-referral-modal .modal-body').html(modalTextSecond)
            $('#confirm-referral-modal').modal('show')
          else if responseText == 'already referred'
            $('#confirm-referral-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-referral-modal .modal-body').html(modalTextThird)
            $('#confirm-referral-modal').modal('show')

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

  _editExitNgoModalValidation = ->
    $('.exit-ngos').on 'shown.bs.modal', (e) ->
      data = {
        date: "##{e.target.id} #exit_ngo_exit_date",
        field: "##{e.target.id} #exit_ngo_exit_circumstance",
        note: "##{e.target.id} #exit_ngo_exit_note",
        form: "##{e.target.id}",
        btn: ".confirm-exit"
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

  _checkExitReasonsLength = (form) ->
    if form == '#exitFromNgo' or form.indexOf('#exit_ngos-') >= 0 then $(form).find('.i-checks input:checked').length else 1

  _modalFormValidator = (data)->
    date = data['date']
    field = data['field']
    note = data['note']
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

  _modalButtonAction = (form, date, field, note, btn, exitReasonsLength) ->
    date = $(date).val()
    field = $(field).val()
    note = $(note).val()

    if (field == '' or field == null) or date == '' or note == '' or exitReasonsLength == 0
      $(form).find(btn).attr 'disabled', 'disabled'
    else
      $(form).find(btn).removeAttr 'disabled'

  _initUploader = ->
    $('.referral_consent_form').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  { init: _init }
