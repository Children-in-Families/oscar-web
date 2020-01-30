CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =
CIF.Leave_enrolled_programsNew = CIF.Leave_enrolled_programsCreate = CIF.Leave_enrolled_programsEdit = CIF.Leave_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _initDatePicker()
    _preventCreateDatePickerLeaveProgram()
    _preventEditDatePickerLeaveProgram()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initDatePicker = ->
    $('.leave-program-date, .leave-enrolled-program-date').datepicker
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true

  _preventEditDatePickerLeaveProgram = ->
    currentProgram = $('#program_stream_name').val()
    currentRow     = $('.leave-program-date').val()

    $('#case-history-table-leave-program tr.case-history-row').each (index, element) ->
      if element.dataset.classname == "leave_programs"
        leaveProgramStream = element.dataset.name.replace(/Exit/i,'').trim()
        if element.dataset.date == currentRow and leaveProgramStream == currentProgram
          clientEnrollId = element.dataset.caseHistoryId
          currentEnrollDate  = _getCurrentEnrollmentDate(clientEnrollId,currentProgram)
          currentExitNgoDate = _getCurrentExitNgoDate(clientEnrollId)
          $('.leave-program-date').datepicker('setStartDate', currentEnrollDate)
          $('.leave-program-date').datepicker('setEndDate', currentExitNgoDate)

  _getCurrentExitNgoDate = (clientEnrollId) ->
    exitNgoDates       = []
    $.each $("##{clientEnrollId}").siblings().closest('tr[id^="exit_ngos"]'), (index, element) ->
      if new Date($("##{clientEnrollId}").data('date')) <= new Date($(element).data('date'))
        exitNgoDates.push($(element).attr('id'))
    ExitNgoDateId      = exitNgoDates.pop()
    currentExitNgoDate = $("##{ExitNgoDateId}").closest('tr').attr('data-date')

  _getCurrentEnrollmentDate = (clientEnrollId,currentProgram) ->
    enrollProgramDates = []
    $.each $("##{clientEnrollId}").siblings().closest('tr[id^="client_enrollments"]'), (index, element) ->
      enrollProgram = element.dataset.name.replace(/Entry/i, '').trim()
      if enrollProgram == currentProgram
        if new Date($("##{clientEnrollId}").data('created-date')) >= new Date($(element).data('created-date'))
          enrollProgramDates.push($(element).attr('id'))
    EnrollDateId       = enrollProgramDates[0]
    currentEnrollDate  = $("##{EnrollDateId}").closest('tr').attr('data-date')

  _preventCreateDatePickerLeaveProgram = ->
    programStream  = $('#program_stream_name').val()
    enrollmentDates = []
    $('#case-history-table-leave-enrolled-program tr.case-history-row').each (index, element) ->
      if element.dataset.classname == "client_enrollments"
        enrollProgram = element.dataset.name.replace(/Entry/i,'').trim()
        if enrollProgram == programStream
          enrollmentDates.push(element.dataset.date)
        currentEnrollmentDate = enrollmentDates[0]
        $('.leave-enrolled-program-date').datepicker('setStartDate', currentEnrollmentDate)

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
