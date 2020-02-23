CIF.SettingsCustom_fields = do ->
  _init = ->
    _initICheckBox()
    _handleActionHiddenField()

  _initICheckBox = ->
    $('.i-checks-meta-fields').each ->
      $(this).iCheck
        checkboxClass: 'icheckbox_square-green'
      if $(this).find('input').data('hidden') == true
        $(this).iCheck("check")
      if $(this).find('input').data('required') == true
        $(this).iCheck("uncheck")
        $(this).iCheck("disable")
        $(this).attr 'title',"This field is required!\nYou can not hide this field."

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

  { init: _init }  