CIF.FamilyReferralsNew = CIF.FamilyReferralsCreate = CIF.FamilyReferralsUpdate = CIF.FamilyReferralsEdit = do ->

  _init = ->
    _initSelect2()
    _initExternalReferral()
    _handleExternalReferralSelected()
    _initUploader()

  _handleExternalReferralSelected = ->
    $('.family_referral_referred_to').on 'change', ->
      _initExternalReferral()

  _initSelect2 = ->
    $('select').select2()

  _initExternalReferral = ->
    referredTo = document.getElementById('family_referral_referred_to')
    if referredTo.textContent == ''
      $('.external-referral-warning').removeClass 'text-hide'
    else
      $('.external-referral-warning').addClass 'text-hide'

  _initUploader = ->
    $('#family_referral_consent_form').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  { init: _init }
