CIF.Field_settingsIndex = do ->
  _init = ->
    console.log 'init'
    _initICheckBox()
    # _handleActionHiddenField()

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

  _handleActionHiddenField = ->
    $('.i-checks-meta-fields').each ->
      $(this).find('input').on 'ifChanged', (event) ->
        meta_field_id = event.target.value
        meta_field_hidden = event.target.checked

        $.ajax
          url: '/settings/custom_fields'
          type: 'PUT'
          data:
            meta_field_id: meta_field_id
            meta_field_hidden: meta_field_hidden
          dataType: 'json'
          success: (data) ->
            console.log "Successful updated meta-field"

        if $(this).data('hide-all') != null
          field_type_hide_all = $(this).data('hide-all')
          $('.i-checks-meta-fields').each ->
            if $(this).find('input').hasClass field_type_hide_all
              if meta_field_hidden == true
                $(this).iCheck("check")

        if $(this).hasClass 'family-fields'
          if meta_field_hidden == false && $("#meta-field-family-hide-all").parent('[class*="icheckbox"]').hasClass("checked")
            $('#meta-field-family-icheck').iCheck("uncheck")

        if $(this).hasClass 'partner-fields'
          if meta_field_hidden == false && $("#meta-field-partner-hide-all").parent('[class*="icheckbox"]').hasClass("checked")
            $('#meta-field-partner-icheck').iCheck("uncheck")

  { init: _init }
