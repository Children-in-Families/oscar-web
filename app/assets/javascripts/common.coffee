CIF.Common =
  init: ->
    @hideNotification()
    @hideDynamicOperator()
    @validateFilterNumber()

  hideNotification: ->
    notice = $('p#notice')
    if notice
      setTimeout (->
        $(notice).fadeOut()
      ), 5000

  hideDynamicOperator: ->
    $('.dynamic_filter').find('option[value="=~"]').remove('option')

  validateFilterNumber: ->
    $(window).load ->
      $('input[type="number"]').attr('min','0')


