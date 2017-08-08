CIF.TasksNew = CIF.TasksCreate = CIF.TasksEdit = CIF.TasksUpdate = do ->
  _init = ->
    _initSelect2()
    _disableButtonSave()

  _initSelect2 = ->
    $('select').select2()

  _disableButtonSave = ->
    $('input[type=submit]').on 'click', (e) ->
      domain = $('#select2-chosen-1').text()
      taskName = $('#task_name').val()
      taskCompletionDate = $('#task_completion_date').val()
      if domain != '' && taskName != '' && taskCompletionDate != ''
        $('input[type=submit]').attr('disabled', 'disabled')
        $('form.task-form').submit()

  { init: _init }
