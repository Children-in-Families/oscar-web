CIF.Case_notesNew = do ->
  _init = ->
    _handleNewTask()

  _handleNewTask = ->
    _addTaskToServer()
    _addDomainToSelect()

  _showError = (error) ->
    if error.completion_date != undefined and error.completion_date.length > 0
      $('#case_note_task .task_completion_date').addClass('has-error')
    else
      $('#case_note_task .task_completion_date').removeClass('has-error')

    if error.name != undefined and error.name.length > 0
      $('#case_note_task .task_name').addClass('has-error')
    else
      $('#case_note_task .task_name').removeClass('has-error')

  _addTaskToServer = ->
    _postTask()

  _postTask = ->
    $('.add-task-btn').on 'click', (e) ->
      actionUrl = undefined
      data      = undefined
      data      = $('#case_note_task').serializeArray()
      actionUrl = $('#case_note_task').attr('action').split('?')[0]
      $.ajax
          type: 'POST'
          url: "#{actionUrl}.json"
          data: data
          success: (response) ->
            _addElementToDom(response, actionUrl)
            $('#tasksFromModal').modal('hide')
          error: (response) ->
            _showError(response.responseJSON)

  _addElementToDom = (data, actionUrl) ->
    appendElement  = $("#tasks-domain-#{data.domain_id} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteUrl      = "#{actionUrl}/#{data.id}"

    element        = "<li style='padding-bottom: 5px;'>#{data.name}<a class='pull-right remove-task fa fa-trash btn btn-outline btn-danger btn-xs' style='margin: 0;' href='javascript:void(0)' data-url='#{deleteUrl}'></a></li>"

    if $(".task-domain-#{data.domain_id}").hasClass('hidden')
      $(".task-domain-#{data.domain_id}").removeClass('hidden')

    $("#tasks-domain-#{data.domain_id} .task-arising").removeClass('hidden')
    $("#tasks-domain-#{data.domain_id} .task-arising ol").append(element)
    _clearForm()

    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)

  _clearForm = ->
    _removeError()
    $('#task_name').val('')
    $('#task_completion_date').val('')

    $('.task_completion_date').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true
    .datepicker 'setDate', null

  _removeError = ->
    $('#case_note_task .task_name').removeClass('has-error')
    $('#case_note_task .task_completion_date').removeClass('has-error')

  _deleteTask = (e) ->
    url = $(e.target).data('url').split('?')[0]
    url = "#{url}.json"

    $.ajax
      type: 'delete'
      url: url
      success: (response) ->
    $(e.target).parent().remove()

  _addDomainToSelect =  ->
    $('.case-note-task-btn').on 'click', (e) ->
      _clearForm()
      domains = $(e.target).data('domains')
      $('#task_domain_id').html('')

      domains.map (domain) ->
        $('#task_domain_id').append("<option value='#{domain[0]}'>#{domain[1]}</option>")

  { init: _init }
