CIF.Internal_referralsNew = CIF.Internal_referralsCreate = CIF.Internal_referralsEdit = CIF.Internal_referralsUpdate = do ->
  _init = ->
    _initSelect2()
    _preventRequireFileUploader()
    _initUploader()
    _initDatePicker()
    _handleReferralDecisionField()

    $("input[name='internal_referral[referral_decision]']").on "click", _handleReferralDecisionField

  _initDatePicker = ->
    $('#referral_date').datepicker
      useCurrent: false
      format: 'YYYY-MM-DD'

    $('#referral_date').datepicker('setStartDate', $('#referral_date').data('date-start-date'));

  _initSelect2 = ->
    $('select').select2
      width: '100%'

  _handleReferralDecisionField = ->
    if $("input[name='internal_referral[referral_decision]']:checked").val() == 'not_meet_intake_criteria'
      $(".crisis_management-wrapper").show()
    else
      $(".crisis_management-wrapper").hide()

  _initUploader = ->
    $('#internal_referral_attachments').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _preventRequireFileUploader = ->
    prevent = new CIF.PreventRequiredFileUploader()
    prevent.preventFileUploader()

  { init: _init }
