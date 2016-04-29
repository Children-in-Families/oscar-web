CIF.Common =
  init: ->
    @hideNotification()

  hideNotification: ->
    notice = $('p#notice')
    if notice
      setTimeout (->
        $(notice).fadeOut()
      ), 5000
