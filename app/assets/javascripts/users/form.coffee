CIF.UsersNew = CIF.UsersCreate = CIF.UsersEdit = CIF.UsersUpdate = CIF.RegistrationsEdit = CIF.RegistrationsUpdate = do ->
  _init = ->
    _initSelect2()
    _handleDisableManagerField()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initSelect2 = ->
    $('select').select2({ allowClear: true }, _clearSelectedOption()).on('select2-removing', (e) ->
      shouldRemove = true
      if $(@).attr('multiple').length > 0 and ($('body').attr('id') == 'users-update' or $('body').attr('id') == 'users-edit')
        path = "/api/clients/#{e.val}/find_client_case_worker?user_id=#{$('#user_id').val()}"
        $.ajax
          dataType: 'json'
          url: path
          method: 'GET'
          async: false,
          success: (response) ->
            shouldRemove = false if response.user_ids.length == 0

      if shouldRemove == false
        $('.select.optional.user_clients').addClass('has-error')
        $(".select2-search-choice div:contains(#{e.choice.text})").addClass('text-danger')
        $('.help-block').remove()
        $('.select.optional.user_clients').append("<span class='help-block'>#{$('#warning_message').val()}</span>")

      return shouldRemove
    ).on 'select2-selecting', (e) ->
      if $(@).attr('id').length > 0 and e.val != 'strategic overviewer'
        $('#clients-selection:hidden').removeClass('hide')
      else
        $('#clients-selection').addClass('hide')

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
