CIF.Common =
  init: ->
    @hideNotification()
    @hideDynamicOperator()

  hideNotification: ->
    notice = $('p#notice')
    if notice
      setTimeout (->
        $(notice).fadeOut()
      ), 5000

  hideDynamicOperator: ->
    $('.dynamic_filter').find('option[value="=~"]').remove('option')
