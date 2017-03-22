CIF.ClientsNew = CIF.ClientsCreate = CIF.ClientsUpdate = CIF.ClientsEdit = do ->
  _init = ->
    _ajaxCheckExistClient()
    _clientSelectOption()
    _checkClientBirthdateAvailablity()
    _fixedHeaderStageQuestion()
    _toggleAnswer()

  _ajaxCheckExistClient = ->
    $('#submit-button').on 'click', ->
      name = $('#client_first_name').val()
      gender =  $('#client_gender').val()
      dateOfBirth = $('#client_date_of_birth').val()
      birthProvicnceId = $('#client_birth_province_id').val()

      if dateOfBirth != '' and name != '' and birthProvicnceId != ''
        data = {
          first_name: name
          gender: gender
          birth_province_id: birthProvicnceId
          date_of_birth: dateOfBirth
        }

        $.ajax({
          type: 'GET'
          url: '/clients/find'
          data: data
          dataType: "JSON"
        }).success((json)->
          clientId = $('#client_id').val()
          clientIds = []
          clients = json.clients

          for client in clients
            clientIds.push(String(client.id))

          if clients.length > 0 and clientId not in clientIds
            modalTitle      = $('#hidden_title').val()
            modalTextFirst  = $('#hidden_body_first').val()
            modalTextSecond = $('#hidden_body_second').val()
            clientName      = $('#client_first_name').val()
            organizations   = []
            organizations.push(client.organization for client in clients)
            $.unique(organizations[0])
            modalText = []
            for organization in organizations[0]
              modalText.push("<p>#{modalTextFirst} #{clientName} #{modalTextSecond} #{organization}.<p/>")

            $('#confirm-client-modal .modal-header .modal-title').text(modalTitle)
            $('#confirm-client-modal .modal-body').html(modalText)

            $('#confirm-client-modal').modal('show')
            $('#confirm-client-modal #confirm').on 'click', ->
              $('form').submit()
          else
            $('form').submit()
        )
      else
        $('form').submit()



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

  _fixedHeaderStageQuestion = ->
    $('#stage-question table.client-new').dataTable(
      'sScrollY': '500px'
      'sScrollX': '100%'
      'bPaginate': false
      'bFilter': false
      'bInfo': false
      'bSort': false
      'bAutoWidth': true)

  _arrangeQuestionAndAnswerBlock = ->
    questionsAndAnswers = $('.question_and_answer')
    for questionAndAnswer in questionsAndAnswers
      qa = $(questionAndAnswer)
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
      button.attr('disabled', 'disabled')
    $('#client_date_of_birth').change ->
      if $('#client_date_of_birth').val() == ''
        button.attr('disabled', 'disabled')
      else
        button.removeAttr('disabled')
        _toggleAnswer()

  _getAge = (dateString) ->
    today = new Date
    birthDate = new Date(dateString)
    age = today.getFullYear() - birthDate.getFullYear()
    m = today.getMonth() - birthDate.getMonth()
    if m < 0 or m == 0 and today.getDate() < birthDate.getDate()
      age--
    age

  _toggleAnswer = ->
    answers = $('.answer')
    for answer in answers
      answerObj = $(answer)
      if answerObj.data('is-stage') == false
        answerObj.find('input').removeAttr('disabled')
        answerObj.show()
      else
        if answerObj.data('to-age') != '' && answerObj.data('from-age') >= $('#client_date_of_birth').val() >= answerObj.data('to-age')
          answerObj.find('input').removeAttr('disabled')
          answerObj.show()
          answerObj.removeClass('disable-qa')
        else
          answerObj.addClass('disable-qa')
          answerObj.find('input').attr('disabled', true)
          answerObj.hide()

  window.onload = ->
    ua = navigator.userAgent
    unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
      $('#stage-question.table-responsive, #stage-question .dataTables_scrollBody').niceScroll
        scrollspeed: 30
        cursorwidth: 10
        cursoropacitymax: 0.4

  { init: _init }
