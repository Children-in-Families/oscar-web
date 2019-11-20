$(document).on 'ready page:load', ->

  $('.date_filter, .input-group.date, #csi_start_date, #csi_end_date, #case_start_date, #case_end_date').datepicker
    autoclose: true,
    format: 'yyyy-mm-dd',
    todayHighlight: true,
    disableTouchKeyboard: true

  $('form.new_client .client_date_of_birth #client_initial_referral_date, form.new_case #case_start_date, .modal#exitFromCase #case_exit_date, form#new_progress_note #progress_note_date').datepicker
    autoclose: true,
    format: 'yyyy-mm-dd',
    todayHighlight: true,
    disableTouchKeyboard: true
  .datepicker 'setDate', new Date

  $('#task_completion_date').datepicker
    autoclose: true,
    format: 'yyyy-mm-dd',
    todayHighlight: true,
    disableTouchKeyboard: true,
    orientation: 'bottom'
    startDate: '1899,01,01',
    todayBtn: true
  .attr('readonly', 'true').css('background-color','#ffffff').keypress (e) ->
    if e.keyCode == 8
      e.preventDefault()
    return

  $('input.date[disabled="disabled"]').parent('.input-group.date').datepicker('remove')
