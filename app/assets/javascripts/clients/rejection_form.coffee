$(document).on 'ready page:load', ->
  $("#clients-edit select, #clients-new select, #clients-update select,
#clients-create").select2
      minimumInputLength: 0
  note = $('#client_rejected_note').val()
  if note == ''
    $('.confirm-reject').attr 'disabled', 'disabled'

  $('#client_rejected_note').keyup ->
    empty = false
    note  = $('#client_rejected_note').val()
    if note == ''
      empty = true
    if empty
      $('.confirm-reject').attr 'disabled', 'disabled'
    else
      $('.confirm-reject').removeAttr 'disabled'
