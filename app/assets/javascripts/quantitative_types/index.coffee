CIF.Quantitative_typesIndex = do ->
  _init = ->
    _validateForm()
    _initSelect2()
    _initICheckBox()
    _toggleFieldType()

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

  _toggleFieldType = ->
    console.log("trigger _toggleFieldType")

    $("form").on "change", ".quantitative_type_field_type select", ->
      form = $(this).closest("form")

      if $(this).val() == 'select_option'
        form.find(".quantitative_type_multiple-wrapper").show()
        form.find(".add-quantitative-data-links").show()
        form.find(".nested-fields").show()
      else
        form.find(".quantitative_type_multiple-wrapper").hide()
        form.find(".add-quantitative-data-links").hide()
        form.find(".nested-fields").hide()

    $("form .quantitative_type_field_type select").trigger("change")

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  { init: _init }
