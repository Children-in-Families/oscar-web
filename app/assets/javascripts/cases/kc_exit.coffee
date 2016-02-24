$(document).on 'ready page:load', ->

  kc_exit_date = $('input.kc_exit_date').val()
  kc_exit_note = $('.kc_exit_note').val()
  if kc_exit_date == '' or kc_exit_note == ''
    $('.kc_confirm_exit').attr 'disabled', 'disabled'

  $('input.kc_exit_date, .kc_exit_note').keyup ->
    empty = false
    kc_exit_date  = $('input.kc_exit_date').val()
    kc_exit_note  = $('.kc_exit_note').val()
    if kc_exit_date == '' or kc_exit_note == ''
      empty = true
    if empty
      $('.kc_confirm_exit').attr 'disabled', 'disabled'
    else
      $('.kc_confirm_exit').removeAttr 'disabled'