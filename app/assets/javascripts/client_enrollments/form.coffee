CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate =
CIF.Client_enrolled_programsNew = CIF.Client_enrolled_programsCreate = CIF.Client_enrolled_programsEdit = CIF.Client_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _initDatePicker()
    _preventEditDatepickerClientEnrollment()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initDatePicker = ->
    $('.client-enrollment-date').datepicker
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true

  _preventEditDatepickerClientEnrollment = ->
    currentProgram     = $('#program_stream_name').val()
    currentRow         = $('.client-enrollment-date').val()
    leaveProgramDates  = []
    enterNgoDates      = []

    $('#case-history-table-client-enrollment tr.case-history-row').each (index, element) ->
      if element.dataset.classname == "client_enrollments"
        programStream = element.dataset.name.replace(/Entry/i,'').trim()
        if element.dataset.date == currentRow and programStream  == currentProgram
          clientEnrollId = element.dataset.caseHistoryId

          $.each $("##{clientEnrollId}").siblings().closest('tr[id^="enter_ngos"]'), (index, element) ->
            if  new Date($("##{clientEnrollId}").data('created-date')) >= new Date($(element).data('created-date'))
              enterNgoDates.push($(element).attr('id'))

          EnterNgoId = enterNgoDates[0]
          currentEnterNgoDate  = $("##{EnterNgoId}").closest('tr').attr('data-date')

          $.each $("##{clientEnrollId}").siblings().closest('tr[id^="leave_programs"]'), (index, element) ->
         g   leaveProgram = element.dataset.name.replace(/Exit/i, '').trim()
            if leaveProgram == currentProgram
              if new Date($(element).data('created-date') >= new Date($("##{clientEnrollId}").data('created-date')))
                leaveProgramDates.push($(element).attr('id'))

          LeaveProgramId = leaveProgramDates[0]
          currentLeaveProgramDate = $("##{LeaveProgramId}").closest('tr').attr('data-date')
          currentProgramName = element.dataset.name
          currentProgramDate = element.dataset.date

          if currentEnterNgoDate > currentLeaveProgramDate
            $('.client-enrollment-date').datepicker('setStartDate', currentEnterNgoDate)
          else
            $('.client-enrollment-date').datepicker('setStartDate', currentEnterNgoDate)
            $('.client-enrollment-date').datepicker('setEndDate', currentLeaveProgramDate)


  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
      $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _preventRequireFileUploader = ->
    prevent = new CIF.PreventRequiredFileUploader()
    prevent.preventFileUploader()

  { init: _init }
