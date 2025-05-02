CIF.SessionsNew = CIF.SessionsCreate = do ->
  _init = ->
    _removeUnsupportLanguageNotification()
    _initICheckBox()

    selectedCountry = JSON.parse localStorage.getItem('selectedCountry');
    if selectedCountry
      url = selectedCountry.url
      flag = selectedCountry.flag;
      $('form#new_user').attr('action', url);
      $("#country-selection span.caret").before(flag);
    else
      $('#country-select').modal({backdrop: 'static', keyboard: false}).modal('show')

    $('a.country-option').on 'click', (e) ->
      value = @.dataset.value
      if value
        url = @.dataset.url
        localStorage.setItem('selectedCountry', JSON.stringify({ value: value, url: url, flag: @.dataset.flag }));
        $('form#new_user').attr('action', url);
        $('#country-select').modal('hide');
        $("#country-selection button img").remove();
        $("#country-selection span.caret").before(@.dataset.flag);

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
