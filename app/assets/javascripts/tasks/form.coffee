CIF.TasksNew = CIF.TasksCreate = do ->
  _init = ->
    _submitValidate()

  _submitValidate = ->
    _formSubmit()
    _showRemoveButton()
    _addTasks()
    _removeTask()

  _formSubmit = ->
    $('form.edit_client input[type="submit"]').click (e) ->
      blankField = 0
      $('input.required').each ->
        id = $(@).attr('id')

        if $(@).val() == ''
          $("span.blank_#{id}").show()
          $("div.blank_#{id}").addClass('has-error')

          e.preventDefault()
          blankField++

        else
          $("span.blank_#{id}").hide()
          $("div.blank_#{id}").removeClass('has-error')

      if blankField > 0
        $('.alert.alert-danger').removeClass('hidden')

  _showRemoveButton = ->
    $('.multi-tasks').each ->
      if $(@).find('.common-domain').length > 1
        $('p.text-right a.remove_fields').show()
      else
        $('p.text-right a.remove_fields').hide()

  _addTasks = ->
    $('form.edit_client'). on 'click', '.add_fields', (event) ->
      time = new Date().getTime()
      regexp = new RegExp($(@).data('id'), 'g')
      $(@).before($(@).data('fields').replace(regexp, time))

      $('.input-group.date').datepicker
        autoclose: true,
        format: 'yyyy-mm-dd',
        todayHighlight: true

      event.preventDefault()

  _removeTask = ->
    $('form.edit_client').on 'click', '.remove_fields', (event) ->
      $(@).closest('.common-domain').remove()
      event.preventDefault()

  { init: _init }