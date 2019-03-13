CIF.RegistrationsNew = CIF.RegistrationsCreate = CIF.RegistrationsUpdate = CIF.RegistrationsEdit = do ->
  _init = ->
    initIcheck()
    initSelect2()

  initIcheck = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  initSelect2 = ->
    $('select').select2
      minimumInputLength: 0
      allowClear: true
  
  { init: _init }
