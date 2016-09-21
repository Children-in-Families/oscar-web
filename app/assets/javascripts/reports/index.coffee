CIF.ReportsIndex = do ->
  _init = ->
    _rollBackBlankInput()

  _rollBackBlankInput = ->
    $('.statistic-search').click (e) ->
      $('.date-picker').each ->
        inputDate = $(this).val()
        if inputDate == ''
          e.preventDefault()
          $(this).addClass('errors')
        else
          $(this).removeClass('errors')
    
  { init: _init }