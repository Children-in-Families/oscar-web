CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate =
CIF.Client_enrolled_programsNew = CIF.Client_enrolled_programsCreate = CIF.Client_enrolled_programsEdit = CIF.Client_enrolled_programsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _initDatePicker()
    _handleDisableAndEnableEditDatePickerClientEnrollment()

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

  _handleDisableAndEnableEditDatePickerClientEnrollment = ->
    currentRow = $('.client-enrollment-date').val()
    $('#case-history-table-client-enrollment tr.case-history-row').each (index, element) ->
      if element.dataset.date   == currentRow
        if element.previousElementSibling != null and element.nextElementSibling != null
          nextDate     = element.previousElementSibling.dataset.date
          previousDate = element.nextElementSibling.dataset.date
          $('.client-enrollment-date').datepicker('setStartDate', previousDate)
          $('.client-enrollment-date').datepicker('setEndDate', nextDate)
        else if element.previousElementSibling != null
          nextDate    = element.previousElementSibling.dataset.date
          $('.client-enrollment-date').datepicker('setEndDate', nextDate)
        else if element.nextElementSibling != null
          previousDate = element.nextElementSibling.dataset.date
          $('.client-enrollment-date').datepicker('setStartDate', previousDate)
        return false

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
