CIF.Service_receivesNew = CIF.Service_receivesCreate = do ->
  _init = ->
    _handleNewTask()
    # _hideCompletedTasks()
    _initSelect2CasenoteInteractionType()
    _initSelect2CasenoteDomainGroups()
    _initICheckBox()
    _scrollToError()
    _hideShowOnGoingTaskLable()
    _hideAddNewTask()
    _handleFormSubmit()

  _initICheckBox = ->
    $('.i-checks').iCheck(
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
    ).on('ifChecked', ->
      $("#service-delivery-task-#{@.value}").toggleClass('service-delivery hide show')
    ).on 'ifUnchecked', ->
      $("#service-delivery-task-#{@.value}").toggleClass('show service-delivery hide')

  _initSelect2CasenoteInteractionType = ->
    $('#case_note_interaction_type').select2
      width: '100%'

  _initSelect2CasenoteDomainGroups = ->
    $('.case_note_domain_groups .help-block').hide()
    $('#case_note_domain_group_ids').select2(
      width: '100%'
    ).on('select2-selecting', (event)->
      $("#domain-#{event.val}").show('slow')
    ).on('select2-removing', (event)->
      if $("#domain-#{event.val} .task-arising .list-group-item").length > 0
        event.preventDefault()
        $('.case_note_domain_groups .help-block').show('slow')
      else
        $('.case_note_domain_groups .help-block').hide('slow')
        $("#domain-#{event.val}").hide('slow')
    ).on 'change', ()->
      _checkCasenoteSelectedValue(@)
      # $("#domain-#{e.val}").toggle('hide') if $("#domain-#{e.val} .case_note_case_note_domain_groups_tasks:visible").length == 0
    # ).on('select2-selecting', (e)->
    #   if event.target.textContent.length > 0
    #     $("#domain-#{e.val}").toggle('show') if $("#domain-#{e.val} .case_note_case_note_domain_groups_tasks:visible").length == 0


  _checkCasenoteSelectedValue = (selectedObject)->
    # $("#domain-#{event.val}").show('slow')
    if $(selectedObject).children(":selected").length > 0
      $(".ibox.case-note-domain-group.without-assessments#domain-#{$(selectedObject).children(":selected").val()}").show()
      $('.case-note-task-btn').removeAttr('disabled')
      $('#add-task-message').hide()
      $('.case-note-task-btn').attr('data-target', "#tasksFromModal");
    else
      $('.case-note-task-btn').attr('disabled', true);
      $('#add-task-message').show()
      $('.case-note-task-btn').attr('data-target', "#");
    return

  _initUploader = ->
    $('.file .optional').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

  _hideCompletedTasks = ->
    $('.i-checks.task').each ->
      dataCompleted = $(this).find('span.hidden')[0]
      $(this).addClass('hidden') if dataCompleted == true

  _handleNewTask = ->
    _addTaskToServer()
    _addDomainToSelect()

  _showError = (name, completion_date) ->
    # if completion_date != undefined and completion_date.length <= 0
    #   $('#case_note_task .task_completion_date').addClass('has-error')
    # else
    #   $('#case_note_task .task_completion_date').removeClass('has-error')

    if name != undefined and name.length <= 0
      $('#case_note_task .task_name').addClass('has-error')
    else
      $('#case_note_task .task_name').removeClass('has-error')

  _addTaskToServer = ->
    _postTask()

  _postTask = ->
    $('.add-task-btn').on 'click', (e) ->
      $('.add-task-btn').attr('disabled','disabled')
      actionUrl = undefined
      taskName  = undefined
      taskDate  = undefined
      domainId  = undefined
      relation  = undefined

      actionUrl = $('#case_note_task').attr('action').split('?')[0]

      taskName = $('#task_name').val()
      domainId = $('#task_domain_id').val()
      relation = $('#task_relation').val()
      taskDate = $('#task_completion_date').val()

      if taskName.length > 0 && taskDate.length > 0
        DomainGroupId = $("#tasks-domain-#{domainId}").data('domain-group-identity')
        _addElementToDom(taskName, taskDate, domainId, relation, actionUrl, DomainGroupId)
        $('.add-task-btn').removeAttr('disabled')
        $('#tasksFromModal').modal('hide')
        _hideShowOnGoingTaskLable()
        _hideAddNewTask()
      else
        _showError(taskName, taskDate)
        $('.add-task-btn').removeAttr('disabled')


  _addElementToDom = (taskName, taskDate, domainId, relation, actionUrl, domain_group_identity = null) ->
    appendElement  = $(".domain-#{domainId} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteLink     = ''
    deleteUrl      = "#{actionUrl}/#{domainId}"
    deleteLink     = "<a class='m-l-xs remove-task fa fa-trash btn btn-outline btn-danger btn-xs' href='javascript:void(0)' data-url='#{deleteUrl}'></a>"
    taskNameOrign  = taskName
    taskName       = taskName.replace(/,/g, '&#44;').replace(/'/g, 'apos').replace(/"/g, 'qout')
    taskObj        = { name: taskName, expected_date: taskDate, domain_id: domainId, relation: relation, domain_group_identity: domain_group_identity }
    taskObjString  = JSON.stringify(taskObj)
    element        = "<div class='checkbox-primary m-t-xs'>
                        <div class='icheckbox_square-green' style='position: relative;'><input type='checkbox' name='domain_groups_attributes[tasks][]' value='#{taskObjString}' class='i-checks task task-domain-#{domainId}' style='position: absolute; opacity: 0;'></div>
                        <label>#{taskNameOrign}#{deleteLink}</label>
                      </div>"
    completionDateInputAndServiceDeliverSelectOptions = $("#domain-task-completed-date-service-delivery-#{domainId}").clone(true, true).removeClass('hide').attr('id', "domain-task-completed-date-service-delivery-#{taskName.replace(/\s+/g, '-').toLowerCase()}")
    if $(".task-domain-#{domainId}").hasClass('hidden')
      $(".task-domain-#{domainId}").removeClass('hidden')

    $("#tasks-domain-#{domainId} .task-arising").removeClass('hidden')

    $("#tasks-domain-#{domainId} .task-arising ol").append(element)
    $("#tasks-domain-#{domainId} .task-arising ol").find('.checkbox-primary').last().append(completionDateInputAndServiceDeliverSelectOptions)
    lastTaskInput = $("#tasks-domain-#{domainId} .task-arising ol").find("input[type='checkbox']").last()
    serviceDeliverTaskId = "#domain-task-completed-date-service-delivery-#{taskName.replace(/\s+/g, '-').toLowerCase()}"
    lastTaskInput.iCheck(
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
    ).on('ifChecked', ->
      taskNameAttr = "domain_groups_attributes[domains][#{domainId}][tasks][#{taskName.replace(/\s+/g, '-').toLowerCase()}]"
      $("#tasks-domain-#{domainId} .task-arising ol").find("#{serviceDeliverTaskId} .service-delivery").toggleClass('service-delivery hide show')
      $("#{serviceDeliverTaskId} input.date.form-control").datepicker
        autoclose: true,
        format: 'yyyy-mm-dd',
        todayHighlight: true
      .on 'change', ->
        completionDateValue = $(@).val()
        taskObj['completion_date'] = completionDateValue
        $(@).closest('.checkbox-primary').find("input[type='checkbox']").val(JSON.stringify(taskObj))
      .datepicker 'setDate', null

      $("#{serviceDeliverTaskId} select.service-delivery-task-ids").addClass('service-delivery-select').select2
        width: '100%'
      .on 'change', ->
        selectedValues = $(@).select2('val')
        taskObj['service_delivery_ids'] = selectedValues
        $(@).closest('.checkbox-primary').find("input[type='checkbox']").val(JSON.stringify(taskObj))

    ).on 'ifUnchecked', ->
      $("#tasks-domain-#{domainId} .task-arising ol").find("#{serviceDeliverTaskId} .m-b-sm").toggleClass('show service-delivery hide')

    $(".panel-tasks-domain-#{domainId}").removeClass('hidden')

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

    if $(e.target).data('persisted') == true
      $.ajax
        type: 'delete'
        url: url
        success: (response) ->
      $(e.target).closest('.checkbox-primary').remove()
    else
      $(e.target).closest('.checkbox-primary').remove()

  _addDomainToSelect =  ->
    $('.case-note-task-btn').on 'click', (e) ->
      _clearForm()
      url = $(e.target).data('url')
      doamin_group_ids = encodeURIComponent(JSON.stringify($('#case_note_domain_group_ids').select2('val')))
      urlString = $(e.target).data('url') + '&domain_group_ids=' + doamin_group_ids
      $.ajax
        dataType: "json"
        url: urlString
        method: 'GET'
        success: (response) ->
          domains = response.data
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

  _scrollToError = ->
    if $('.case_note_meeting_date').hasClass('has-error')
      location.href = '#case_note_meeting_date'
    else if $('.case_note_attendee').hasClass('has-error')
      location.href = '#case_note_attendee'
    else if $('.case_note_interaction_type').hasClass('has-error')
      location.href = '#s2id_case_note_interaction_type'

  _hideShowOnGoingTaskLable = ->
    $('#on-going-task-label').show()

  _hideAddNewTask = ->
    _checkCasenoteSelectedValue($('#case_note_domain_group_ids'))
    $.each $('#case_note_domain_group_ids').select2('data'), (index, object) ->
      $("#domain-#{object.id}").show() if $("#domain-#{object.id} .task-arising .list-group > li").length > 0

    $.each $('.case-note-domain-group'), (index, object)->
      if $("##{object.id}").find('span.checkbox').length > 0
        $.each $("##{object.id} div[id^='tasks-domain-']"), (index, task)->
          if $("##{task.id} span.checkbox").length == 0
            domainName = $(".panel-#{task.id}").data('domain-name-panel')
            $("[data-domain-name='#{domainName}']").hide()
            $("##{task.id} label.check_boxes").hide()
          else
            $("##{object.id}").show('slow')
      else
        $.each $("##{object.id} div[id^='tasks-domain-']"), (index, task)->
          if $("##{task.id} span.checkbox").length == 0
            $("##{task.id} label.check_boxes").hide()

  _handleFormSubmit = ->
    submitText = $('#case-note-submit-btn').val()
    $(document).on 'submit', 'form#service-receive-form', (e) ->
      inValidate = false
      $.each $("#case_note_domain_group_ids, #service-receive-form select.service-delivery-select, #service-receive-form input[type='checkbox'], #service-receive-form input.completion-date:visible"), (index, element)->
        value = $(element).val()
        if _.isEmpty(value)
          inValidate = true
          if $(element).attr('class').match(/service-delivery-select/) && $(element).attr('class').match(/service-delivery-select/).length > 0 || 'case_note_domain_group_ids' == element.id
            $(element).siblings('.select2-container').find('.select2-choices').attr('style', "border-color: #ED5565 !important;")
          else
            $(element).parent().addClass('has-error')

      if inValidate
        e.preventDefault()
        setTimeout (->
          $('#case-note-submit-btn').removeAttr('disabled')
          $('#case-note-submit-btn').val(submitText)
          return false
        ), 500
        return false

      return true


  { init: _init }
