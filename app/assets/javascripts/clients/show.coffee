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
    _initICheckBox()
    _preventEditDatepickerEnterNgoExitNgoCaseHistory()
    _preventCreateDatepickerEnterNgo()
    _preventCreateDatepickerExitNgo()
    _globalIDToolTip()
    _buttonHelpTextPophover()
    _initialEnterNGOAcceptedDate()
    _handleEnterNGOModalShow()
    _ajaxChangeDistrict()

    $('table.families').dataTable
      'bPaginate': false
      'bFilter': false
      'bInfo': false
      'bSort': false
      'sScrollY': 'auto'
      'bAutoWidth': true
      'sScrollX': '100%'

    $.fn.editable.defaults.ajaxOptions = {type: "put"}
    $('.editable').editable
      select2:
        width: '250px'
        dropdownAutoWidth: true
        allowClear: true
        viewseparator: ','
      ajaxOptions:
        dataType: 'json'
      error: (response, newValue) ->
        if response.status == 500
          'Service unavailable. Please try later.'
        else
          response.responseText

    $('#client_arrival_at').datetimepicker
      format: "DD/MM/YYYY H:mm:s a"

    $('.input-group-addon').on 'click', ->
      $('#client_arrival_at').data("DateTimePicker").show()

    $('#mo-savy-officials').on 'cocoon:after-insert', ->
      $("#form#clientEdit input[type='submit']").disabled();

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _globalIDToolTip = ->
    $('[data-toggle="tooltip"]').tooltip()

  _initDatePicker = ->
    $('.exit_ngos, .exit_date, .enter_date').datepicker(
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true
    )


  _handleEnterNGOModalShow = ->
    $(document).on 'shown.bs.modal', '.edit-enter-ngos-case-history', (e) ->
      startDate = _getInitialReferralDate()
      $("##{e.currentTarget.id} .enter-ngos-case-history").datepicker('setStartDate', startDate)

  _initialEnterNGOAcceptedDate = ->
    startDate = _getInitialReferralDate()

    $('#enter_ngo_accepted_date').datepicker(
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true
      startDate: startDate
    )

  _getInitialReferralDate = ->
    initialReferralDate = $('#initial_referral_date').val()
    lastExitNgoDate = $('#last_exit_ngo_date').val()
    startDate = if _.isEmpty(lastExitNgoDate) then initialReferralDate else lastExitNgoDate

  _preventEditDatepickerEnterNgoExitNgoCaseHistory = ->
    $('button.edit-case-history-ngo').on 'click', ->
      currentRow          = $(this).closest('tr')[0]
      currentDate         = $($(currentRow)).data('date')
      previousDate        = $($(currentRow).next()[0]).data('date')
      nextDate            = $($(currentRow).prev()[0]).data('date')
      className           = $(this).data('class-name')

      if _.isElement(currentRow) and !_.isEmpty(nextDate) and !_.isEmpty(previousDate)
        if className == "exit_ngos"
          _getNextDatePreviousDate(currentDate, nextDate, previousDate,className)
        else
          $(".#{className}").datepicker('setStartDate', previousDate)
          $(".#{className}").datepicker('setEndDate', nextDate)
      else if _.isElement(currentRow) and !_.isEmpty(previousDate)
        if className == "exit_ngos"
          _getPreviousDate(previousDate, currentDate,className)
        else
          $(".#{className}").datepicker('setStartDate', previousDate)
      else if _.isElement(currentRow) and !_.isEmpty(nextDate)
        $(".#{className}").datepicker('setEndDate', nextDate)


  _getPreviousDate = (previousDate, currentDate,className) ->
    date = _getMaxValueLeaveProgramDate(currentDate)
    if date != ''
      $(".#{className}").datepicker('setStartDate', date)
    else
      $(".#{className}").datepicker('setStartDate', previousDate)

  _getNextDatePreviousDate = (currentDate,nextDate, previousDate,className) ->
    date = _getMaxValueLeaveProgramDate(currentDate)
    if date != ''
      $(".#{className}").datepicker('setStartDate', date )
      $(".#{className}").datepicker('setEndDate', nextDate)
    else
      $(".#{className}").datepicker('setStartDate', previousDate)
      $(".#{className}").datepicker('setEndDate', nextDate)

  _getMaxValueLeaveProgramDate = (currentDate) ->
    leaveProgramDates   = []
    $('#case-history-table tr.case-history-row').each (index, element) ->
      date = element.dataset.date
      if element.dataset.classname == "leave_programs" and date <= currentDate
        leaveProgramDates.push(new Date (date))
    leaveDate = Math.max.apply(Math, leaveProgramDates)
    date = new Date(leaveDate)

  _preventCreateDatepickerEnterNgo = ->
    $('button.enter-ngo-for-client').on 'click', ->
      exitNgoDates      = []
      $('#case-history-table tr.case-history-row').each (index, element) ->
        date = element.dataset.date
        if element.dataset.classname == "exit_ngos"
          exitNgoDates.push(new Date (date))
      maxExitDate = Math.max.apply(Math, exitNgoDates)
      date = new Date(maxExitDate)
      $(".enter_date").datepicker('setStartDate', date)

  _preventCreateDatepickerExitNgo = ->
    $('button.exit-ngo-for-client').on 'click', ->
    leaveProgramDates = []
    $('#case-history-table tr.case-history-row').each (index, element) ->
      date = element.dataset.date
      if element.dataset.classname == "leave_programs"
        leaveProgramDates.push(new Date (date))
      maxLeaveDate = Math.max.apply(Math, leaveProgramDates)
      date = new Date(maxLeaveDate)
      $(".exit_date").datepicker('setStartDate', date)

  _initSelect2 = ->
    $('select').select2(
      allowClear: true
      maximumSelectionLength:1
      placeholder:'--- choose an option ---'
    ).on 'select2-removed', () ->
      return if @.id != 'client_family_member_attributes_family_id'
      $('#client_family_member_attributes__destroy').val('1');

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

  _buttonHelpTextPophover = ->
    $("button[data-content]").popover();

  _ajaxChangeDistrict = ->
    mainAddress = $('#client_carer_province_id, #client_carer_city_id, #client_carer_district_id, #client_carer_commune_id')
    resourceMapping = { cities: 'client_carer_city_id', districts: 'client_carer_district_id', subdistricts: 'client_carer_subdistrict_id', communes: 'client_carer_commune_id', villages: 'client_carer_village_id' }
    mainAddress.on 'change', ->
      type       = $(@).data('type')
      typeId     = $(@).val()
      subAddresses = $(@).data('subaddresses')
      subResource = subAddresses[0]

      $(subAddresses || []).each (index, subAddress) =>
        $("##{resourceMapping[subAddress]}").val(null).trigger('change')
        $("##{resourceMapping[subAddress]}").find('option[value!=""]').remove()

      if typeId != ''
        $.ajax
          method: 'GET'
          url: "/api/#{type}/#{typeId}/#{subResource}"
          dataType: 'JSON'
          success: (response) ->
            for address in response.data
              $("##{resourceMapping[subResource]}").append("<option value='#{address.id}'>#{address.name}</option>")


  { init: _init }
