CIF.SessionsNew = CIF.SessionsCreate = do ->
  _init = ->
    _removeUnsupportLanguageNotification()

  _removeUnsupportLanguageNotification = ->
    locale           = $('.alert-warning').data('locale')
    return if locale == 'en'
    notifyByPanel    = localStorage.getItem('notifyByPanel') or ''
    $('.alert-warning').removeClass('hidden')
    if notifyByPanel == 'yes'
      $('.alert-warning').addClass('hidden')
    else
      localStorage.setItem('notifyByPanel', 'yes')

  { init: _init }
