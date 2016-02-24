$(document).on 'ready page:load', ->
  $("#rootwizard").steps
    headerTag: 'h4'
    bodyTag: 'div'
    transitionEffect: 'slideLeft'
    autoFocus: true
    onFinished: ->
      $('.actions a:contains("Done")').removeAttr('href')
      $('form').submit()
    labels:
      finish: 'Done'
