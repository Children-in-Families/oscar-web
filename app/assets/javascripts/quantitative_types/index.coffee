CIF.Quantitative_typesIndex = do ->
  _init = ->
    _validateForm()
    _initSelect2()
    _initICheckBox()

  _initSelect2 = ->
    $('.select2').select2
      allowClear: true

    $('.select2').on "change", ->
      $(@).valid()

  _validateForm = ->
    $('form.edit_quantitative_type').validate
      ignore: null
    $('form.new_quantitative_type').validate
      ignore: null

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  { init: _init }
