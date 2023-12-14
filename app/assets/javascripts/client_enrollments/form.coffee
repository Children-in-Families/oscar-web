CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate =
CIF.Client_enrolled_programsNew = CIF.Client_enrolled_programsCreate = CIF.Client_enrolled_programsEdit = CIF.Client_enrolled_programsUpdate = do ->
  checkedItems = []
  _init = ->
    _initSelect2()
    _initFileInput()
    _preventRequireFileUploader()
    _toggleCheckingRadioButton()
    _initICheckBox()
    _initDatePicker()
    _preventEditDatepickerClientEnrollment()
    _setAnotherLanguageFieldValue()
    _hideAnotherLanguageField()
    _copyInputTextToLocalLanguage()
    _copyTextAreaTextToLocalLanguage()
    _copyNumberToLocalLanguage()
    _copyDateToLocalLanguage()
    _checkCheckbox()
    _uncheckCheckbox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initDatePicker = ->
    initialReferralDate = $('#initial_referral_date').val()
    lastAcceptedDate = $('#last_accepted_date').val()
    startDate = if _.isEmpty(lastAcceptedDate) then initialReferralDate else initialReferralDate

    $('#enrollment_date').datepicker(
      autoclose: true
      format: 'yyyy-mm-dd'
      todayHighlight: true
      orientation: 'bottom'
      disableTouchKeyboard: true
      startDate: startDate
    )

    $('#enrollment_date').datepicker('setStartDate', startDate)

  _preventEditDatepickerClientEnrollment = ->
    currentProgram     = $('#program_stream_name').val()
    currentRow         = $('.client-enrollment-date').val()

    $('#case-history-table-client-enrollment tr.case-history-row').each (index, element) ->
      if element.dataset.classname == "client_enrollments"
        programStream = element.dataset.name.replace(/Entry/i,'').trim()
        if element.dataset.date == currentRow and programStream  == currentProgram
          clientEnrollId = element.dataset.caseHistoryId
          currentEnterNgoDate     = _getCurrentEnterNgoDate(clientEnrollId)
          currentLeaveProgramDate = _getCurrentLeaveProgramDate(clientEnrollId,currentProgram)
          $('.client-enrollment-date').datepicker('setStartDate', currentEnterNgoDate)
          $('.client-enrollment-date').datepicker('setEndDate', currentLeaveProgramDate)

  _getCurrentEnterNgoDate = (clientEnrollId) ->
    enterNgoDates   = []
    $.each $("##{clientEnrollId}").siblings().closest('tr[id^="enter_ngos"]'), (index, element) ->
      if  new Date($("##{clientEnrollId}").data('created-date')) >= new Date($(element).data('created-date'))
        enterNgoDates.push($(element).attr('id'))
    EnterNgoId = enterNgoDates[0]
    currentEnterNgoDate  = $("##{EnterNgoId}").closest('tr').attr('data-date')

  _getCurrentLeaveProgramDate = (clientEnrollId,currentProgram) ->
    leaveProgramDates  = []
    $.each $("##{clientEnrollId}").siblings().closest('tr[id^="leave_programs"]'), (index, element) ->
      leaveProgram = element.dataset.name.replace(/Exit/i, '').trim()
      if leaveProgram == currentProgram
        if new Date($("##{clientEnrollId}").data('created-date')) <= new Date($(element).data('created-date'))
          leaveProgramDates.push($(element).attr('id'))
    LeaveProgramId = leaveProgramDates.pop()
    currentLeaveProgramDate = $("##{LeaveProgramId}").closest('tr').attr('data-date')

  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
      el = $(@)
      el.parents('.radio_buttons').next().children('#' + el.data('option')).val(el.data('value'))
      $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

  _checkCheckbox = ->
    $('input[type="checkbox"]').on 'ifChecked', (e) ->
      el = @
      elementID = el.id
      relatedInput = $(el).closest('.form-group.check_boxes').siblings('div.hidden').find("input##{elementID}")
      relatedInput.attr('checked', 'checked') if relatedInput
    return

  _uncheckCheckbox = ->
    $('input[type="checkbox"]').on 'ifUnchecked', (e) ->
      el = @
      elementID = el.id
      relatedInput = $(el).closest('.form-group.check_boxes').siblings('div.hidden').find("input##{elementID}")
      relatedInput.removeAttr('checked') if relatedInput

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

  _setAnotherLanguageFieldValue = ->
    $('select').on 'select2-selecting', (e) ->
      $('#' + $(e.target).data('label')).val($(e.choice.element).data('value')).trigger("change")
      return

  _hideAnotherLanguageField = ->
    $('.client-enrollment').find('.d-none').parent().addClass('hide')

  _copyInputTextToLocalLanguage = ->
    $('input[type="text"]').on 'keyup', (e) ->
      el = $(@)
      if el.hasClass('date-picker')
      else
        el.parent().next().find('#' + el.data('local-input')).val(el.val())

  _copyTextAreaTextToLocalLanguage = ->
    $('textarea').on 'keyup', (e) ->
      el = $(@)
      el.parent().next().find('#' + el.data('local-textarea')).val(el.val())

  _copyNumberToLocalLanguage = ->
    $('input[type="number"]').on 'keyup mouseup', (e) ->
      el = $(@)
      el.parent().next().find('#' + el.data('local-number')).val(el.val())

  _copyDateToLocalLanguage = ->
    $('input.form-builder-date').on 'changeDate', (e) ->
      el = $(@)
      el.next('#' + el.data('local-date')).val(el.val())

  { init: _init }
