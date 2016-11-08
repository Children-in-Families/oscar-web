CIF.SurveysNew = CIF.SurveysCreate = CIF.SurveysEdit = CIF.SurveysUpdate = do ->
  _init = ->
    _rollbackBlankInput()

  _rollbackBlankInput = ->
    $('.survey-submit').click (e) ->
      $('.question-block').each ->
        radioChecked = $(this).find('input[type="radio"]:checked')
        if radioChecked.length < 1
          e.preventDefault()
          $(this).addClass('errors')
        else
          $(this).removeClass('errors')

  { init: _init }
