CIF.ReferralsNew = CIF.ReferralsCreate = CIF.ReferralsUpdate = CIF.ReferralsEdit = do ->
  _init = ->
    _initSelect2()
    _initExternalReferral()
    _handleExternalReferralSelected()
    _initUploader()

  _handleExternalReferralSelected = ->
    $('.referral_referred_to').on 'change', ->
      _initExternalReferral()

  _initSelect2 = ->
    $('select').select2()

  _initExternalReferral = ->
    save = $("#save-text").val()
    saveAndDownload = $("#save-and-download-text").val()
    referredTo = document.getElementById('referral_referred_to')
    selectedNgo = referredTo.options[referredTo.selectedIndex].value
    if selectedNgo == 'external referral'
      $('.external-referral-warning').removeClass 'text-hide'
      $('.btn-save').val saveAndDownload
    else
      $('.external-referral-warning').addClass 'text-hide'
      $('.btn-save').val save

  _initUploader = ->
    $(".file").fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  { init: _init }
