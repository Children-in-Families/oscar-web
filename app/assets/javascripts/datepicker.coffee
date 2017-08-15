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

  $('input.date[disabled="disabled"]').parent('.input-group.date').datepicker('remove')
