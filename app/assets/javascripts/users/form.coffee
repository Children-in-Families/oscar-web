CIF.UsersNew = CIF.UsersCreate = CIF.UsersEdit = CIF.UsersUpdate = do ->
  _init = ->
    _initSelect2()
    _handleDisableManagerField()
    _disableManagerField()

  _initSelect2 = ->
    $('select').select2({ allowClear: true })

  _handleDisableManagerField = ->
    $('#user_roles').on 'select2-selected', ->
      if $(@).val() != 'case worker' and $(@).val() != 'manager'
        $('#user_manager_id').select2('val', '')
        $('#user_manager_id').attr('disabled', 'disabled')
      else
        $('#user_manager_id').removeAttr('disabled')

  _disableManagerField = ->
    if $('#user_roles').val() != 'case worker' and $('#user_roles').val() != 'manager'
      $('#user_manager_id').select2('val', '')
      $('#user_manager_id').attr('disabled', 'disabled')
    else
      $('#user_manager_id').removeAttr('disabled')

  { init: _init }
