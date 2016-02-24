

$(document).on 'ready page:load', ->
  @taskIds = []
  _handleTaskCompleted(@)
  _handleFormSubmitted(@)

_handleTaskCompleted = (context) ->
  $('input.task').change ->
    id = $(@).data('task-id')
    if @checked
      context.taskIds.push(id)
    else
      index = context.taskIds.indexOf(id)
      context.taskIds.splice(index, 1)

_handleFormSubmitted = (context) ->
  $('#case-note-submit-btn').click ->
    $.ajax
      url: '/tasks/set_complete'
      method: 'PUT'
      dataType: 'json'
      data: { ids: context.taskIds }
