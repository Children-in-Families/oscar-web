CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    _clientSelectOption()
    _checkClientBirthdateAvailablity()
    _arrangeQuestionAndAnswerBlock()

  _clientSelectOption = ->
    $("#clients-edit select, #clients-new select, #clients-update select, #clients-create select").select2
      minimumInputLength: 0

    $('select.able-related-info').change ->
      qtSelectedSize = $('select.able-related-info option:selected').length

      if qtSelectedSize > 0
        $('#client_able').val(true)
        $('#fake_client_able').prop('checked', true)
      else
        $('#client_able').val(false)
        $('#fake_client_able').prop('checked', false)


  _arrangeQuestionAndAnswerBlock = ->
    questionsAndAnswers = $('.question_and_answer')
    for questionAndAnswer in questionsAndAnswers
      qa = $(questionAndAnswer)
      if  _getAge($('#client_date_of_birth').val()) > qa.data('to-age')
        qa.prop('disabled',true);
      if qa.data('is-stage')
        html = qa.html()
        $('#stage-question').append(html)
        qa.remove()
      else
        html = qa.html()
        $('#non-stage-question').append(html)
        qa.remove()

  _checkClientBirthdateAvailablity = ->
    button = $('#able-screening-test')
    if $('#client_date_of_birth').val() == ''
      button.hide()
    $('#client_date_of_birth').change ->
      if $('#client_date_of_birth').val() == ''
        button.attr('disabled', 'disabled')
      else
        button.show()

  _getAge = (dateString) ->
    today = new Date
    birthDate = new Date(dateString)
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()
    if m < 0 or m == 0 and today.getDate() < birthDate.getDate()
      age--
    age

  { init: _init }
