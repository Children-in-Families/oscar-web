CIF.Case_notesNew = CIF.Case_notesCreate = CIF.Case_notesEdit = CIF.Case_notesUpdate = do ->
  _init = ->
    _initUploader()
    _handleDeleteAttachment()
    _handleNewTask()
    # _hideCompletedTasks()
    _initSelect2CasenoteInteractionType()
    _initSelect2CasenoteDomainGroups()
    _initScorePopover()
    _initICheckBox()
    _scrollToError()
    _hideShowOnGoingTaskLable()
    _hideAddNewTask()
    _handleFormSubmit()
    _initServiceDeliverySelect2()
    _taskProgressNoteToggle()
    _initTaskProgressNoteTooltip()


    $("#case_note_meeting_date").on "change", _submitFormViaAjax
    $("#case_note_interaction_type").on "change", _submitFormViaAjax
    $("#case_note_domain_group_ids").on "change", ->
      _submitFormViaAjax()

    saveTimer = null

    $("#case_note_attendee").on "keyup", ->
      clearTimeout saveTimer
      saveTimer = setTimeout _submitFormViaAjax, 1000

    $("#case_note_note").on "keyup", ->
      clearTimeout saveTimer
      saveTimer = setTimeout _submitFormViaAjax, 1000

    # $("[id^='case_note_custom_field_property_attributes_properties_']").on "keyup", ->
    #   saveTimer = setTimeout _submitFormViaAjax, 1000

  _submitFormViaAjax = ->
    if $("#case-note-form").data("autosave")
      $(".task-arising.task-item-wrapper").addClass("saved")

      $.ajax
        url: $("#case-note-form").attr("action") + "&draft=true"
        type: "PUT"
        data: $("#case-note-form").serialize()
        dataType: "json"
        success: (response) ->
          if response.edit_url
            history.replaceState(null, "", response.edit_url)
          
          $.each $(".task-arising.task-item-wrapper.saved"), (index, element) ->
            $(element).find("input[name='task[]']").remove()

  _initICheckBox = ->
    $('.i-checks').iCheck(
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'
    ).on('ifChecked', ->
      $("#service-delivery-task-#{@.dataset.taskId}").toggleClass('service-delivery hide show')
    ).on 'ifUnchecked', ->
      $("#service-delivery-task-#{@dataset.taskId}").toggleClass('show service-delivery hide')

  _initTaskProgressNoteTooltip = ->
    $('.task-sticky-note').tooltip
      placement: 'auto'
      html: true

  _initScorePopover = ->
    $("button.case-note-domain-score").popover(
      html: true
    ).on 'show.bs.popover', ->
      $(this).data('bs.popover').tip().css
        maxWidth: '600px'
        zIndex: '9999'
      return

  _initSelect2CasenoteInteractionType = ->
    $('#case_note_interaction_type').select2
      width: '100%'

  _initServiceDeliverySelect2 = ->
    $("select.service-delivery-task-ids").select2
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
    $(".case_note_custom_field_property_form_builder_attachments_file .file").fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']

    $('.file .optional').fileinput
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"
      uploadAsync: false
      allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']
      uploadUrl: $("#case-note-form").data("uploadUrl")

    $('.file .optional').on "filebatchselected", (event, files) ->
      $(this).fileinput("upload")
      return


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
        _submitFormViaAjax()
      else
        _showError(taskName, taskDate)
        $('.add-task-btn').removeAttr('disabled')


  _addElementToDom = (taskName, taskDate, domainId, relation, actionUrl, domain_group_identity = null) ->
    appendElement  = $(".domain-#{domainId} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteLink     = ''
    deleteUrl      = "#{actionUrl}/#{domainId}"
    deleteLink     = "<a class='pull-right remove-task fa fa-trash btn btn-outline btn-danger btn-xs' href='javascript:void(0)' data-url='#{deleteUrl}' style='margin: 0;'></a>" if $('#current_user').val() == 'admin'
    taskNameOrign  = taskName
    taskName       = taskName.replace(/,/g, '&#44;').replace(/'/g, 'apos').replace(/"/g, 'qout')
    taskObj        = { name: taskName, expected_date: taskDate, domain_id: domainId, relation: relation, domain_group_identity: domain_group_identity }
    taskObj        = JSON.stringify(taskObj)
    element        = "<li class='list-group-item' style='padding-bottom: 11px;'>#{taskNameOrign}#{deleteLink} <input name='task[]' type='hidden' value='#{taskObj}'></li>"

    if $(".task-domain-#{domainId}").hasClass('hidden')
      $(".task-domain-#{domainId}").removeClass('hidden')

    $("#tasks-domain-#{domainId} .task-arising").removeClass('hidden').addClass("task-item-wrapper")

    $("#tasks-domain-#{domainId} .task-arising ol").append(element)
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
      $(e.target).parent().remove()
    else
      $(e.target).parent().remove()

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
    if $('.case_note_case_note_domain_groups_tasks:visible').length > 0 then $('#on-going-task-label').show() else $('#on-going-task-label').hide()

  _hideAddNewTask = ->
    _checkCasenoteSelectedValue($('#case_note_domain_group_ids'))
    $.each $('#case_note_domain_group_ids').select2('data'), (index, object) ->
      if $("#domain-#{object.id} .task-arising .list-group > li").length > 0 || $("#domain-#{object.id} input[data-task-id]").length > 0
        $("#domain-#{object.id}").show()

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
    $(document).on 'submit', 'form#case-note-form', (e) ->
      inValidate = false
      $.each $("select.required, input.required:not('#task_completion_date'), #case_note_note, #case_note_meeting_date, #case_note_interaction_type"), (index, element)->
        value = $(element).val()
        $(".#{element.id}").removeClass('has-error')
        if _.isEmpty(value)
          if ['case_note_meeting_date', 'case_note_interaction_type'].includes(element.id)
            $(".#{element.id}").addClass('has-error')
          else
            $(element).parent().addClass('has-error')
          inValidate = true

      if inValidate
        setTimeout (->
          $('#case-note-submit-btn').removeAttr('disabled')
          $('#case-note-submit-btn').val(submitText)
          return
        ), 500
        e.preventDefault()
        return false

      return true

  _taskProgressNoteToggle = ->
    $('i.task-sticky-note').on 'click', ->
      taskId = @.id
      $("##{taskId}-progress-note-wrapper").toggleClass('hide show')

  { init: _init }
