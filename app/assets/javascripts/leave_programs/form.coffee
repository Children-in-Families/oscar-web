CIF.Leave_programsNew = CIF.Leave_programsCreate = CIF.Leave_programsEdit = CIF.Leave_programsUpdate =
CIF.Leave_enrolled_programsNew = CIF.Leave_enrolled_programsCreate = CIF.Leave_enrolled_programsEdit = CIF.Leave_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _initDatePicker()
    _handleDisableAndEnableEditDatePickerLeaveProgram()
    _preventCreateDatePickerLeaveProgram()

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

  _handleDisableAndEnableEditDatePickerLeaveProgram = ->
    currentRow = $('.leave-program-date').val()
    $('#case-history-table-leave-program tr.case-history-row').each (index, element) ->
      if element.dataset.date == currentRow
        if element.previousElementSibling != null and element.nextElementSibling != null
          nextDate     = element.previousElementSibling.dataset.date
          previousDate = element.nextElementSibling.dataset.date
          $('.leave-program-date').datepicker('setStartDate', previousDate)
          $('.leave-program-date').datepicker('setEndDate', nextDate)
        else if element.previousElementSibling != null
          nextDate   = element.previousElementSibling.dataset.date
          $('.leave-program-date').datepicker('setEndDate', nextDate)
        else if element.nextElementSibling != null
          previousDate  = element.nextElementSibling.dataset.date
          $('.leave-program-date').datepicker('setStartDate', previousDate)

  _preventCreateDatePickerLeaveProgram = ->
    currentEnrollProgram = $('#program_stream_name').val()
    enrollPrograms       = []

    $('#case-history-table-leave-enrolled-program tr.case-history-row').each (index, element) ->
      if element.dataset.classname == "client_enrollments"
        enrollProgram = element.dataset.name.replace(/Entry/i,'').trim()
        if enrollProgram == currentEnrollProgram
          clientEnrollId = element.dataset.caseHistoryId
          $.each $("##{clientEnrollId}").siblings().closest('tr[id^="client_enrollments"]'), (index, element) ->
            if new Date($(element).data('created_date') >= new Date($("##{clientEnrollId}").data('created-date')))
              enrollPrograms.push (element.dataset.date)
          currentEnrollDate = enrollPrograms[0]
          $('.leave-enrolled-program-date').datepicker('setStartDate', currentEnrollDate)

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
