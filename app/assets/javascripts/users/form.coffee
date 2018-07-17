CIF.UsersNew = CIF.UsersCreate = CIF.UsersEdit = CIF.UsersUpdate = do ->
  _init = ->
    _initSelect2()
    _handleDisableManagerField()

  _initSelect2 = ->
    $('select').select2
      allowClear: true
      _clearSelectedOption()

  _clearSelectedOption = ->
    formAction = $('body').attr('id')
    $('#user_roles').val('') unless formAction.includes('edit')

  _handleDisableManagerField = ->
    $('#user_roles').change ->
      if $(@).val() == 'admin' || $(@).val() == 'strategic overviewer'
        $('#user_manager_id').select2('val', '')
        $('#user_manager_id').attr('disabled', 'disabled')
      else
        $('#user_manager_id').removeAttr('disabled')
    .change()

  { init: _init }
