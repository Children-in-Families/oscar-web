CIF.Field_settingsIndex = do ->
  _init = ->
    _initICheckBox()
    _toggleSubmitButton()

  _initICheckBox = ->
    $('.i-checks-meta-fields').iCheck(
        checkboxClass: 'icheckbox_square-green'
    ).on('ifCreated', (event) ->
      if $(this).attr('title')
        $(this).parent().attr 'title', $(this).attr('title')
      return
    )

    $('.i-checks-meta-fields').each ->
      if $(this).find('input').data('hidden') == true
        $(this).iCheck("check")
      if $(this).find('input').data('required') == true
        $(this).iCheck("uncheck")
        $(this).iCheck("disable")

  _toggleSubmitButton = ->
    $("#accordion").on "click keyup change ifChanged", "input", ->
      if $(@).closest("form").find("#field_setting_label").val().length == 0
        $(@).closest("form").find("input[type='submit']").addClass("hidden")
      else
        $(@).closest("form").find("input[type='submit']").removeClass("hidden")

  { init: _init }
