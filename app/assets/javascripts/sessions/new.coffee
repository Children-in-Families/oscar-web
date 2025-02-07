CIF.SessionsNew = CIF.SessionsCreate = do ->
  _init = ->
    _removeUnsupportLanguageNotification()
    _initICheckBox()

    $('#country-select').modal({backdrop: 'static', keyboard: false}).modal('show')
    selectedCountry = localStorage.getItem('selectedCountry');
    if selectedCountry
      selectedInput = $('input[type=radio][value=' + selectedCountry + ']')
      selectedInput.prop('checked', true)
      url = selectedInput.data('url')
      $('form#new_user').attr('action', url);

    $('input[type=radio]').on 'click', (e) ->
      if $(e.target).is(':checked')
        localStorage.setItem('selectedCountry', e.target.value);
        url = e.target.dataset.url
        $('form#new_user').attr('action', url);

      return

  _removeUnsupportLanguageNotification = ->
    locale           = $('.alert-warning').data('locale')
    return if locale == 'en'
    notifyByPanel    = localStorage.getItem('notifyByPanel') or ''
    $('.alert-warning').removeClass('hidden')
    if notifyByPanel == 'yes'
      $('.alert-warning').addClass('hidden')
    else
      localStorage.setItem('notifyByPanel', 'yes')

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'

  { init: _init }
