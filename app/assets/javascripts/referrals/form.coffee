CIF.ReferralsNew = CIF.ReferralsCreate = CIF.ReferralsUpdate = CIF.ReferralsEdit = do ->
  _init = ->
    _initSelect2()
    _initExternalReferral()
    _handleExternalReferralSelected()
    _initUploader()
    service_types = new CIF.ServiceTypes({ element: '#type-of-service', isFromDashboard: false })
    service_types.selectServiceTypeTableResult()

  _handleExternalReferralSelected = ->
    $('.referral_referred_to').on 'change', ->
      _initExternalReferral()

  _initSelect2 = ->
    $('select#referral_referred_to').select2()

  _initExternalReferral = ->
    referredTo = document.getElementById('referral_referred_to')
    if referredTo.textContent == ''
      $('.external-referral-warning').removeClass 'text-hide'
    else
      $('.external-referral-warning').addClass 'text-hide'

  _initUploader = ->
    $('#referral_consent_form').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  { init: _init }
