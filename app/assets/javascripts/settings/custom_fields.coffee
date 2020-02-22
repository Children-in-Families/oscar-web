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
            console.log "successful updated meta-field"

  { init: _init }  