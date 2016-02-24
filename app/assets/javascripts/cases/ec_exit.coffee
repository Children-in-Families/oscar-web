$(document).on 'ready page:load', ->

  ec_exit_date = $('input.ec_exit_date').val()
  ec_exit_note = $('.ec_exit_note').val()
  if ec_exit_date == '' or ec_exit_note == ''
    $('.ec_confirm_exit').attr 'disabled', 'disabled'

  $('input.ec_exit_date, .ec_exit_note').keyup ->
    empty = false
    ec_exit_date  = $('input.ec_exit_date').val()
    ec_exit_note  = $('.ec_exit_note').val()
    if ec_exit_date == '' or ec_exit_note == ''
      empty = true
    if empty
      $('.ec_confirm_exit').attr 'disabled', 'disabled'
    else
      $('.ec_confirm_exit').removeAttr 'disabled'