$(document).on 'ready page:load', ->

  fc_exit_date = $('input.fc_exit_date').val()
  fc_exit_note = $('.fc_exit_note').val()
  if fc_exit_date == '' or fc_exit_note == ''
    $('.fc_confirm_exit').attr 'disabled', 'disabled'

  $('input.fc_exit_date, .fc_exit_note').keyup ->
    empty = false
    fc_exit_date  = $('input.fc_exit_date').val()
    fc_exit_note  = $('.fc_exit_note').val()
    if fc_exit_date == '' or fc_exit_note == ''
      empty = true
    if empty
      $('.fc_confirm_exit').attr 'disabled', 'disabled'
    else
      $('.fc_confirm_exit').removeAttr 'disabled'