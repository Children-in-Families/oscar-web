CIF.ReferralsNew = CIF.ReferralsCreate = CIF.ReferralsUpdate = CIF.ReferralsEdit = do ->
  _init = ->
    _initSelect2()
    _triggerExternalReferral()

  _initSelect2 = ->
    $('select').select2()

  _triggerExternalReferral = ->
    _handleExternalReferralSelected()
    $('.referral_referred_to').on 'change', ->
      _handleExternalReferralSelected()

  _handleExternalReferralSelected = ->
    save = $("#save-text").val()
    save_and_download = $("#save-and-download-text").val()
    referred_to = document.getElementById('referral_referred_to')
    selected_ngo = referred_to.options[referred_to.selectedIndex].value
    if selected_ngo == 'external referral'
      $('.external-referral-warning').removeClass 'text-hide'
      $('.btn-save').val save_and_download
    else
      $('.external-referral-warning').addClass 'text-hide'
      $('.btn-save').val save

  { init: _init }

