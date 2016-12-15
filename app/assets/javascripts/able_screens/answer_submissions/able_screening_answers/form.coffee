CIF.Able_screening_answersNew = CIF.Able_screening_answersCreate =
CIF.Able_screening_answersEdit = CIF.Able_screening_answersUpdate = do ->
  _init = ->
    _checkClientBirthdateAvailablity()


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

  { init: _init }
