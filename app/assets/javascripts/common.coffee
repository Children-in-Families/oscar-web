$(document).on 'ready page:load', ->
  notice = $('p#notice')
  if notice
    setTimeout (->
      $(notice).fadeOut 'slow'
    ), 5000