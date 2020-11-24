CIF.Quantitative_typesIndex = do ->
  _init = ->
    _validateForm()
    _initSelect2()

  _initSelect2 = ->
    $('.select2').select2
      allowClear: true

    $('.select2').on "change", ->
      $(@).valid()

  _validateForm = ->
    $('form.edit_quantitative_type, form.new_quantitative_type').validate
      ignore: null

  { init: _init }
