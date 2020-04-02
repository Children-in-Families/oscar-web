CIF.Field_settingsIndex = do ->
  _init = ->
    _initICheckBox()
    _toggleSubmitButton()
    $("form.field_setting").validate()


  _initICheckBox = ->
    $('.i-checks-meta-fields').iCheck(
        checkboxClass: 'icheckbox_square-green'
    ).on('ifCreated', (event) ->
      if $(this).attr('title')
        $(this).parent().attr 'title', $(this).attr('title')
      return
    )

  _toggleSubmitButton = ->
    $("form.field_setting").on "click keyup change ifChanged", "input", ->
      $("form.field_setting input[type='submit']").attr("disabled", false)

  { init: _init }
