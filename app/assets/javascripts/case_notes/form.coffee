CIF.Case_notesNew = CIF.Case_notesCreate = CIF.Case_notesEdit = CIF.Case_notesUpdate = do ->
  _init = ->
    _initUploader()
    _handleDeleteAttachment()
    _handleNewTask()
    _hideCompletedTasks()
    _handlePreventBlankInput()
    _initSelect2()

  _initSelect2 = ->
    $('#case_note_interaction_type').select2()

  _initUploader = ->
    $('.file .optional').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _handleDeleteAttachment = ->
    rows = $('.row-file')
    $(rows).each (_k, element) ->
      deleteBtn = $(element).find('.delete')
      attachments = element.parentElement.getElementsByTagName('tr')
      confirmDelete = $(deleteBtn).data('comfirm')
      $(deleteBtn).click ->
        result = confirm(confirmDelete)
        return unless result
        url = $(deleteBtn)[0].dataset.url
        $.ajax
          dataType: "json"
          url: url
          method: 'DELETE'
          success: (response) ->
            $(element).remove()
            index = 0
            if attachments.length > 0
              for td in attachments
                td.getElementsByClassName('delete')[0].dataset.url = _replaceUrlParam(td.getElementsByClassName('delete')[0].dataset.url, 'file_index', index++)
            _initNotification(response.message)

  _hideCompletedTasks = ->
    $('input.task').each ->
      $(this).parents('span.checkbox').addClass('hidden') if $(this).data('completed')

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
      $('.add-task-btn').attr('disabled','disabled')
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
            $('.add-task-btn').removeAttr('disabled')
            $('#tasksFromModal').modal('hide')
          error: (response) ->
            _showError(response.responseJSON)
            $('.add-task-btn').removeAttr('disabled')

  _addElementToDom = (data, actionUrl) ->
    appendElement  = $("#tasks-domain-#{data.domain_id} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteLink     = ''
    deleteUrl      = "#{actionUrl}/#{data.id}"
    deleteLink     = "<a class='pull-right remove-task fa fa-trash btn btn-outline btn-danger btn-xs' style='margin: 0;' href='javascript:void(0)' data-url='#{deleteUrl}'></a>" if $('#current_user').val() != 'case worker'
    element        = "<li class='list-group-item' style='padding-bottom: 11px;'>#{data.name}#{deleteLink}</li>"

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

  _handlePreventBlankInput = ->
    $('#case-note-submit-btn').on 'click', (e)  ->
      caseNoteMeetingDate = $('#case_note_meeting_date').val()
      caseNoteAttendee = $('#case_note_attendee').val()
      caseNoteInteractionType = $('#case_note_interaction_type').val()
      elements = ['#case_note_meeting_date', '#case_note_attendee', '#case_note_interaction_type']
      for element in elements
        _handlePreventFieldCannotBeBlank(element, e)
      if caseNoteMeetingDate != '' and caseNoteAttendee != '' and caseNoteInteractionType != ''
        document.getElementById('case-note-form').onsubmit = ->
          true

  _handlePreventFieldCannotBeBlank = (element, e) ->
    cannotBeBlank = $('#case-note-form').data('translate')
    parent = $(element).parents('.form-group')
    labelMessage = $(parent).siblings().find('.text-danger')
    if $(element).val() == ''
      $(parent).addClass('has-error')
      $(labelMessage).text(cannotBeBlank)
      e.preventDefault()
    else
      $(parent).removeClass('has-error')
      $(labelMessage).text('')

  _initNotification = (message)->
    messageOption = {
      "closeButton": true,
      "debug": true,
      "progressBar": true,
      "positionClass": "toast-top-center",
      "showDuration": "400",
      "hideDuration": "1000",
      "timeOut": "7000",
      "extendedTimeOut": "1000",
      "showEasing": "swing",
      "hideEasing": "linear",
      "showMethod": "fadeIn",
      "hideMethod": "fadeOut"
    }
    toastr.success(message, '', messageOption)

  _replaceUrlParam = (url, paramName, paramValue) ->
      if paramValue == null
        paramValue = ''
      pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)')
      if url.search(pattern) >= 0
        return url.replace(pattern, '$1' + paramValue + '$2')
      url + (if url.indexOf('?') > 0 then '&' else '?') + paramName + '=' + paramValue

  { init: _init }
