CIF.AssessmentsNew = CIF.AssessmentsEdit = CIF.AssessmentsCreate = CIF.AssessmentsUpdate = do ->
  _init = ->
    forms = $('form.assessment-form')

    for form in forms
      _formValidate($(form))
      _loadSteps($(form))

    _addTasks()
    _postTask()
    _addElement()
    _translatePagination()
    _initUploader()
    _handleDeleteAttachment()
    _removeTask()
    _removeHiddenTaskArising()
    _saveAssessment(form)
    _radioGoalAndTaskRequiredOption()
    _liveGoal()
    _initICheckBox()
    _initTaskRequire()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _liveGoal = ->
    $('textarea.goal').change ->
      goal = $(this).val()
      name = $(this).attr('name')
      $("textarea.goal[name='#{name}']").val(goal)

  _handleAppendAddTaskBtn = ->
    scores = $('.score_option:visible').find('label.collection_radio_buttons.label-danger, label.collection_radio_buttons.label-warning, div.btn-option.btn-warning, div.btn-option.btn-danger')
    if $(scores).length > 0
      $(scores).trigger('click')
      $(".task_required").removeClass('hidden').show()
    else
      $(".task_required").hide()

  _translatePagination = ->
    next     = $('#rootwizard').data('next')
    previous = $('#rootwizard').data('previous')
    finish   = $('#rootwizard').data('finish')
    save     = $('#rootwizard').data('save')
    cancel   = $('#rootwizard').data('cancel')

    $('#rootwizard a[id="btn-cancel"]').text(cancel)
    $('#rootwizard a[href="#next"]').addClass('btn btn-primary').text(next)
    $('#rootwizard a[href="#previous"]').addClass('btn btn-default').text(previous)
    $('#rootwizard a[href="#save"]').text(save)
    $('#rootwizard a[href="#finish"]').text(finish)

  _addElement = ->
    $('.actions.clearfix ul').before("<hr/>")

  _disableRequiredFields = ->
    formid = $('form.assessment-form').attr('id')
    form   = $('#'+formid)
    form.data("disableRequiredFields")

  _formValidate = (form) ->
    scoreColor = undefined
    domainId   = undefined

    rootId = $(form).find(".root-wizard").attr("id")

    return true if rootId == 'readonly-rootwizard'

    $('.score_option .btn-option').attr('required','required')


    $('.col-xs-12').on 'click', '.score_option .btn-option', ->
      return if $(@).closest(".root-wizard").attr("id") == 'readonly-rootwizard'

      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      currentTab  = "#rootwizard-p-#{currentIndex}"
      select = $(currentTab).find('textarea.goal')
      name = 'assessment[assessment_domains_attributes]['+ "#{currentIndex}" +'][goal_required]\']'
      radioName = '\'' + name

      currentTabLabels = $(@).siblings()
      currentTabLabels.removeClass('active-label')


      $('.score_option').removeClass('is_error')
      labelColors = 'btn-danger btn-warning btn-primary btn-success btn-secondary'
      currentTabLabels.removeClass(labelColors)
      score       = $(@).data('score')
      scoreColor  = $(@).parents('.score_option').data("score-#{score}")
      domainId    = $(@).parents('.score_option').data("domain-id")

      $(@).addClass("btn-secondary")
      $($(@).siblings().get(-1)).val(score)

      if(scoreColor == 'danger' or scoreColor == 'warning' or scoreColor == 'success')
        unless _disableRequiredFields()
          $(".domain-#{domainId} .task_required").removeClass('hidden').show()
          _initTaskRequire()

        if scoreColor == 'success'
          $(".domain-#{domainId} .task_required").addClass('hidden')

        $(".domain-#{domainId} .goal-required-option").addClass('hidden')

        $(select).prop('readonly', false)

        unless _disableRequiredFields()
          if $(select).val() != ''
            $(select).addClass('valid').removeClass('error required')
          else
            $(select).addClass('error required')

      else
        $(".domain-#{domainId} .task_required").hide()
        $(".domain-#{domainId} .goal-required-option").removeClass('hidden')
        goalRequiredValue = $("input[name=#{radioName}:checked").val()
        if goalRequiredValue == 'false'
          $(select).val('')
          $(select).prop('readonly', true).addClass('valid').removeClass('error required').siblings().remove()
        else
          $(select).addClass('valid') if $(select).val() != ''

    $('.score_option input').attr('required','required')
    $('.col-xs-12').on 'click', '.score_option label', ->
      return if $(@).closest(".root-wizard").attr("id") == 'readonly-rootwizard'

      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      currentTab  = "#rootwizard-p-#{currentIndex}"
      select = $(currentTab).find('textarea.goal')
      name = 'assessment[assessment_domains_attributes]['+ "#{currentIndex}" +'][goal_required]\']'
      radioName = '\'' + name

      currentTabLabels = $(@).parents('.score_option').find('label label')
      currentTabLabels.removeClass('active-label')
      $(@).children('label').addClass('active-label')

      $('.score_option').removeClass('is_error')
      labelColors = 'label-danger label-warning label-primary label-success label-default'
      currentTabLabels.removeClass(labelColors)
      score       = $(@).children('label').text()
      scoreColor  = $(@).parents('.score_option').data("score-#{score}")
      domainId    = $(@).parents('.score_option').data("domain-id")

      $(@).children('label').addClass("label-default active-label")

      if(scoreColor == 'danger' or scoreColor == 'warning' or scoreColor == 'success')
        unless _disableRequiredFields()
          $(".domain-#{domainId} .task_required").removeClass('hidden').show()

        if scoreColor == 'success'
          $(".domain-#{domainId} .task_required").addClass('hidden')

        $(".domain-#{domainId} .goal-required-option").addClass('hidden')
        $(select).prop('readonly', false)

        unless _disableRequiredFields()
          if $(select).val() != ''
            $(select).addClass('valid').removeClass('error required')
          else
            $(select).addClass('error required')
      else if scoreColor == 'primary'
        $(".domain-#{domainId} .task_required").hide()
        $(".domain-#{domainId} .goal-required-option").removeClass('hidden')
        goalRequiredValue = $("input[name=#{radioName}:checked").val()
        if goalRequiredValue == 'false'
          $(select).val('')
          $(select).prop('readonly', true).addClass('valid').removeClass('error required').siblings().remove()
        else
          $(select).addClass('valid') if $(select).val() != ''

    unless _disableRequiredFields()
      form.validate errorElement: 'em'
      errorPlacement: (error, element) ->
        element.before error

  _validateScore = (form) ->
    $('.task_required').addClass 'text-required'
    if $('.list-group-item').is ':visible'
      $('.task_required').removeClass('text-required')
      return true
    if !$('.text-required').is ':visible'
      return true
    if $('.text-required').is ':visible'
      return false

  _loadSteps = (form) ->
    bodyTag = 'div'
    bodyTag = '.assessment-wizard-domain-item' if _disableRequiredFields()
    rootId = "##{$(form).find(".root-wizard").attr("id")}"

    $(rootId).steps
      headerTag: 'h4'
      bodyTag: bodyTag
      enableAllSteps: true
      transitionEffect: 'slideLeft'
      autoFocus: true
      titleTemplate: 'Domain #title#'
      labels:
        finish: 'Done'
      onInit: (event, currentIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        domainId = $("#{currentTab}").find('.score_option').data('domain-id')
        _formEdit(rootId, currentIndex)
        _appendSaveCancel()
        _appendSaveButton()
        _handleAppendAddTaskBtn()
        _handleAppendDomainAtTheEnd(currentIndex)
        _taskRequiredAtEnd(currentIndex)
        _handleDisplayTaskWarningMessage("#{currentTab}", domainId)
        $("[data-toggle='popover'], [data-trigger='hover']").popover
          html: true

        return

      onStepChanging: (event, currentIndex, newIndex) ->
        console.log 'onStepChanging'
        currentTab  = "#{rootId}-p-#{currentIndex}"
        domainId = $("#{currentTab}").find('.score_option').data('domain-id')

        return true if _disableRequiredFields() || rootId == '#readonly-rootwizard'

        form.validate().settings.ignore = ':disabled,:hidden'
        form.valid()

        _scrollToError(event)
        _taskRequiredAtEnd(currentIndex)
        _handleDisplayTaskWarningMessage("#{currentTab}", domainId)

        if $("#{rootId}-p-" + currentIndex).hasClass('domain-last')
          return true
        else
          console.log 'invalid'
          _formEdit(rootId, currentIndex)
          _filedsValidator(currentIndex, newIndex)

      onStepChanged: (event, currentIndex, priorIndex) ->
        console.log 'onStepChanged'
        currentTab  = "#{rootId}-p-#{currentIndex}"
        domainId = $("#{currentTab}").find('.score_option').data('domain-id')
        currentStep = $("#{rootId}-p-" + currentIndex)

        unless currentStep.hasClass('domain-last')
          _formEdit(rootId, currentIndex)
          $('a#btn-save').show()

        _handleAppendAddTaskBtn()
        _handleAppendDomainAtTheEnd(currentIndex)
        _taskRequiredAtEnd(currentIndex)
        _initTaskRequire()
        _handleDisplayTaskWarningMessage("#{currentTab}", domainId)

        if currentStep.hasClass('domain-last') or $(rootId).find('a[href="#finish"]:visible').length
          if $(rootId).find('a[href="#finish"]:visible').length
            console.log 'hiding save button'
            $("#{rootId} a[href='#save']").hide()
          _toggleEndOfAssessmentMsg()
          _liveGoal()

      onFinishing: (event, currentIndex, newIndex) ->
        return true if _disableRequiredFields()
        return false if rootId == '#readonly-rootwizard'

        form.validate().settings.ignore = ':disabled'
        form.valid()

        _taskRequiredAtEnd(currentIndex)
        currentStep = $("#{rootId}-p-" + currentIndex)

        if newIndex == undefined && currentStep.hasClass('domain-last')
          isTaskRequred = true
          $.each $("#{rootId}-p-#{currentIndex} [id^='domain-task-section']"), (index, item) ->
            if $(item).find('ol.tasks-list li').length
              $(item).find('.task_required').hide()
            else
              isTaskRequred = false
              $(item).find('.task_required').show()

          return isTaskRequred
        else
          _filedsValidator(currentIndex,newIndex)

      onFinished: ->
        return if rootId == '#readonly-rootwizard'

        btnSaving = $(rootId).data('saving')
        $('a[href="#finish"]').addClass('btn disabled').css('font-size', '96%').text(btnSaving)
        $('.actions a:contains("Done")').removeAttr('href')
        form.submit()

  _appendSaveButton = ->
    if $('#rootwizard').find('a[href="#finish"]:visible').length == 0 && $("#btn-save").length == 0
      $('#rootwizard').find("[aria-label=Pagination]").append("<li><a id='btn-save' href='#save' class='btn btn-info' style='background: #21b9bb;'></a></li>")

  _appendSaveCancel = ->
    unless $('#rootwizard').find('a[id="btn-cancel"]:visible').length
      assessmentHref = $('a.btn-back-default').first().attr('href')
      $('#rootwizard').find("[aria-label=Pagination]").prepend("<li><a id='btn-cancel' href='#{assessmentHref}' class='btn btn-default' style='color: #343a40; background: white; border: 1px solid #acb3ac;'></a></li>")

  _saveAssessment = (form) ->
    $(document).on 'click', "#rootwizard a[href='#save']", ->
      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      newIndex = currentIndex + 1
      if !_disableRequiredFields() && (!$(form).valid() || !_validateScore(form) || !_filedsValidator(currentIndex, newIndex))
        _filedsValidator(currentIndex, newIndex)
        _scrollToError(form)
        return false
      else
        unless _disableRequiredFields()
          form.submit (e) ->
            if $(form).valid()
              btnSaving = $('#rootwizard').data('saving')
              $("a[href='#save']").addClass('disabled').text(btnSaving)
        $(form).submit()

  _formEdit = (rootId, currentIndex) ->
    currentTab  = "#{rootId}-p-#{currentIndex}"

    if $("#{currentTab} .score_option.with-def").length > 0
      scoreOption = $("#{currentTab} .score_option.with-def")
      chosenScore = scoreOption.find('input.selected-score').val()

    else if $("#{currentTab} .score_option.without-def").length > 0
      scoreOption = $("#{currentTab} .score_option.without-def")
      chosenScore = scoreOption.find('label input:checked').val()

    scoreColor  = scoreOption.data("score-#{chosenScore}")

    scoreOption.find("label label:contains(#{chosenScore})").addClass("label-default active-label")

    btnScore = scoreOption.find('input:hidden').val()
    $(scoreOption.find("div[data-score='#{btnScore}']").get(0)).addClass("btn-secondary")
    domainName = $(@).data('goal-option')
    name = 'assessment[assessment_domains_attributes]['+ "#{currentIndex}" +'][goal_required]\']'
    radioName = '\'' + name
    goalRequiredValue = $("input[name=#{radioName}:checked").val()
    select = $(currentTab).find('textarea.goal')

    if scoreColor == 'primary'
      if goalRequiredValue == 'false'
        $(select).val('')
        $(select).prop('readonly', true)
        $(select).addClass('valid')
      else if goalRequiredValue == 'true'
        $(select).prop('readonly', false)
        $(select).removeClass('valid')
        $(select).addClass('valid') if $(select).val() != ''
    else
      if $(select).val() != ''
        $(select).addClass('valid')
      else
        $(select).removeClass('valid').addClass('required')

  _filedsValidator = (currentIndex, newIndex ) ->
    return true if _disableRequiredFields()

    currentTab   = "#rootwizard-p-#{currentIndex}"
    scoreOption  = $("#{currentTab} .score_option")

    isScoreExist = if (scoreOption.children().last().val().length or $(currentTab).find('.active-label').length) then false else true

    if (scoreOption.find('input.error').length || isScoreExist)
      $(currentTab).find('.score_option').addClass('is_error') if isScoreExist
      return false
    else
      $(currentTab).find('.score_option').removeClass('is_error')

      if $("#{currentTab} .score_option.with-def").length > 0
        scoreOption = $("#{currentTab} .score_option.with-def")
        chosenScore = scoreOption.find('input.selected-score').val()

      else if $("#{currentTab} .score_option.without-def").length > 0
        scoreOption = $("#{currentTab} .score_option.without-def")
        chosenScore = scoreOption.find('label input:checked').val()

      activeScoreColor  = scoreOption.data("score-#{chosenScore}")

      isGoal = $("#{currentTab} .goal-required-option").find('input.radio_buttons:checked').val()
      isTask = $("#{currentTab} .task-required-option").find('input.radio_buttons:checked').val()

      if (activeScoreColor == 'primary' && isGoal == 'true')
        return true if $(currentTab).find('textarea.reason.valid').length && $(currentTab).find('textarea.goal.valid').length
      else if (activeScoreColor == 'primary' && isGoal == 'false')
        $(currentTab).find('textarea.goal').removeClass('error')
        return true if $(currentTab).find('textarea.reason.valid').length
      else if $("#{currentTab} ol.tasks-list li").length >= 1 && $(currentTab).find('textarea.reason.valid').length && $(currentTab).find('textarea.goal.valid').length
        return true
      else if isTask == 'true' && $(currentTab).find('textarea.reason.valid').length && $(currentTab).find('textarea.goal.valid').length
        return true
      else
        return true if activeScoreColor == 'success' && $(currentTab).find('textarea.reason.valid').length && $(currentTab).find('textarea.goal.valid').length

  _addTasks = ->
    $(document).on 'click', '.assessment-task-btn', (e) ->
      domainId = $(e.target).data('domain-id')

      $('#task_domain_id').val(domainId)
      $('.task_required').removeClass('text-required')

  _postTask = ->
    $('.add-task-btn').on 'click', (e) ->
      console.log 'post task'

      $('.task_required').hide()
      $('.add-task-btn').attr('disabled','disabled')
      e.preventDefault()
      actionUrl = undefined
      taskName  = undefined
      taskDate  = undefined
      domainId  = undefined
      relation  = undefined

      actionUrl = $('#assessment_domain_task').attr('action').split('?')[0]

      taskName = $('#task_name').val()
      domainId = $('#task_domain_id').val()
      relation = $('#task_relation').val()
      taskDate = $('#task_completion_date').val()

      if taskName.length > 0 && taskDate.length > 0
        _addElementToDom(taskName, taskDate, domainId, relation, actionUrl)
        _clearTaskForm()
      else
        $('.add-task-btn').removeAttr('disabled')
        _showTaskError(taskName, taskDate)

  _addElementToDom = (taskName, taskDate, domainId, relation, actionUrl) ->
    appendElement  = $(".domain-#{domainId} .task-arising, #domain-task-section#{domainId} .task-arising");
    deleteUrl      = undefined
    element        = undefined
    deleteLink     = ''
    deleteUrl      = "#{actionUrl}/#{domainId}"
    deleteLink     = "<a class='pull-right remove-task fa fa-trash btn btn-outline btn-danger btn-xs' href='javascript:void(0)' data-url='#{deleteUrl}' style='margin: 0;'></a>" if $('#current_user').val() == 'admin'
    taskNameOrign  = taskName
    taskName       = taskName.replace(/,/g, '&#44;').replace(/'/g, 'apos').replace(/"/g, 'qout')
    taskObj        = { name: taskName, completion_date: taskDate, domain_id: domainId, relation: relation }
    taskObj        = JSON.stringify(taskObj)
    element        = "<li class='list-group-item' style='padding-bottom: 11px;'>#{taskNameOrign}#{deleteLink} <input name='task[]' type='hidden' value='#{taskObj}'></li>"

    $(".domain-#{domainId} .task-arising, #domain-task-section#{domainId} .task-arising").removeClass('hidden')
    $(".domain-#{domainId} .task-arising ol, #domain-task-section#{domainId} .task-arising ol").append(element)
    _clearTaskForm()
    $('.add-task-btn').removeAttr('disabled')
    $('#tasksFromModal').modal('hide')

    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)
      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      tasksList = $("#rootwizard-p-#{currentIndex} li.list-group-item")
      if tasksList.length
        $("#rootwizard-p-#{currentIndex} .task_required").removeClass('hidden')

  _removeHiddenTaskArising = ->
    tasksList = $('li.list-group-item')
    if $(tasksList).length > 0
      $(tasksList).parents('.task-arising').removeClass('hidden')

  _removeTask = ->
    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)
      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      tasksList = $("#rootwizard-p-#{currentIndex} li.list-group-item")
      if tasksList.length
        $("#rootwizard-p-#{currentIndex} .task_required").removeClass('hidden')

  _deleteTask = (e) ->
    url = $(e.target).data('url').split('?')[0]
    url = "#{url}.json"
    if $(e.target).data('persisted') == true
      $(e.target).hide()
      $.ajax
        dataType: 'json'
        url: url
        type: 'DELETE'
        contentType: 'application/json'
        success: (response) ->
          currentTab = $(e.target).closest('.assessment-domain-item').attr('id')
          $(e.target).parent().remove()
          domainId = $("##{currentTab}").find('.score_option').data('domain-id')
          _handleDisplayTaskWarningMessage("##{currentTab}", domainId)
        error: (response, parsererror, error) ->
          console.log 'failed to delete the task.'
    else
      currentTab = $(e.target).closest('.assessment-domain-item').attr('id')
      $(e.target).parent().remove()
      $(e.target).hide()
      domainId = $("##{currentTab}").find('.score_option').data('domain-id')
      _handleDisplayTaskWarningMessage("##{currentTab}", domainId)

  _removeTaskError = ->
    task = '#assessment_domain_task'
    $("#{task} .task_name, #{task} .task_completion_date").removeClass('has-error')
    $("#{task} .task_name_help, #{task} .task_completion_date_help").hide()

  _showTaskError = (taskName, completionDate) ->
    task = '#assessment_domain_task'

    if completionDate != undefined and completionDate.length <= 0
      $("#{task} .task_completion_date").addClass('has-error')
      $("#{task} .task_completion_date_help").show().html($("#{task} #hidden-error-message").text())
    else
      $("#{task} .task_completion_date").removeClass('has-error')
      $("#{task} .task_completion_date_help").hide()

    if taskName != undefined and taskName.length <= 0

      $("#{task} .task_name").addClass('has-error')
      $("#{task} .task_name_help").show().html($("#{task} #hidden-error-message").text())
    else
      $("#{task} .task_name").removeClass('has-error')
      $("#{task} .task_name_help").hide()

  _clearTaskForm = ->
    _removeTaskError()
    task = '#assessment_domain_task'
    $("#{task} #task_name").val('')
    $("#{task} #task_completion_date").val('')

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
      confirmDelete = $(deleteBtn).data('comfirm')
      $(deleteBtn).click ->
        result = confirm(confirmDelete)
        return unless result
        BtnURL = $(deleteBtn)[0].dataset.url
        $.ajax
          dataType: "json"
          url: BtnURL
          method: 'DELETE'
          success: (response) ->
            $(element).remove()
            index = 0
            attachments = $('.row-file:visible')
            if attachments.length > 0
              for td in attachments
                td.getElementsByClassName('delete')[0].dataset.url = _replaceUrlParam(td.getElementsByClassName('delete')[0].dataset.url, 'file_index', index++)
            _initNotification(response.message)

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

  _radioGoalAndTaskRequiredOption = ->
    $('[id^="i-checks-"]').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

    $('.goal-required-option input').on 'ifChecked', (event) ->
      domainName = $(@).data('goal-option')
      if $(@).val() == 'false'
        $("textarea#goal-text-area-#{domainName}").addClass('valid').removeClass('error required').siblings().remove()
        $("textarea#goal-text-area-#{domainName}").val('');
        $("textarea#goal-text-area-#{domainName}").prop('readonly', true);
      else
        $("textarea#goal-text-area-#{domainName}").prop('readonly', false)
        if $("textarea#goal-text-area-#{domainName}").val() != ''
          $("textarea#goal-text-area-#{domainName}").addClass('valid').removeClass('error required')
        else
          $("textarea#goal-text-area-#{domainName}").addClass('error required')

  _taskRequiredAtEnd = (currentIndex) ->
    currentTab = "#rootwizard-p-#{currentIndex}"
    domainId   = $(currentTab).find('.score_option').data('domain-id')
    $("#{currentTab} .task-required-option input").on 'ifChecked', (event) ->
      if $(@).val() == 'true'
        $(".domain-#{domainId} .task_required, .domain-#{domainId} .assessment-task-btn").hide()
      else
        $(".domain-#{domainId} .task_required, .domain-#{domainId} .assessment-task-btn").show()
        if $("#{currentTab} .score_option.with-def").length > 0
          scoreOption = $("#{currentTab} .score_option.with-def")
          chosenScore = scoreOption.find('input.selected-score').val()
        else if $("#{currentTab} .score_option.without-def").length > 0
          scoreOption = $("#{currentTab} .score_option.without-def")
          chosenScore = scoreOption.find('label input:checked').val()

      return if scoreOption == undefined
      scoreColor  = scoreOption.data("score-#{chosenScore}")
      if ['danger', 'warning'].indexOf(scoreColor) >= 0 and $("#{currentTab} .task-arising ol li").length == 0
        $(".domain-#{domainId} .task_required").show()

  _handleDisplayTaskWarningMessage = (currentTab, domainId) ->
    chosenScore = ''
    if $("#{currentTab} .score_option.with-def").length > 0
      scoreOption = $("#{currentTab} .score_option.with-def")
      chosenScore = scoreOption.find('input.selected-score').val()

    else if $("#{currentTab} .score_option.without-def").length > 0
      scoreOption = $("#{currentTab} .score_option.without-def")
      chosenScore = scoreOption.find('label input:checked').val()

    return if scoreOption == undefined
    scoreColor  = scoreOption.data("score-#{chosenScore}")
    if ['danger', 'warning'].indexOf(scoreColor) >= 0 and $("#{currentTab} .task-arising ol li").length == 0
      $(".domain-#{domainId} .task_required").show()

  _handleAppendDomainAtTheEnd = (currentIndex) ->
    if $("form.assessment-form").length
      currentTab   = "#rootwizard-p-#{currentIndex}"
      domainId     = $(currentTab).find('.score_option').data('domain-id')

      $('a#btn-save').hide() if $("#{currentTab} .task-required-option input[value='true']").is(':checked')

      $("#{currentTab} .task-required-option input").on 'ifChecked', (event) ->
        if $(@).attr('value') == 'true'
          $('a#btn-save').hide()
          currentTableObj  = $(currentTab)

          goalLabelClone   = $("#{currentTab} label[for$='_#{currentIndex}_goal']").clone()
          goalSectionClone = currentTableObj.find('textarea.goal').clone()
          domainName       = $(@).data('task-name')
          taskClone        = currentTableObj.find('.add-task-btn-wrapper').clone()
          taskArisingClone = currentTableObj.find('.task-arising').clone()
          textRequiredClone = currentTableObj.find('.task_required').clone()
          taskArisingClone.find('.task-required-option').remove()
          unless $("#required-task-wrapper-domain-#{domainId}").length
            $(".domain-last .ibox-content").append(
              "<div class='row #{$(@).attr('id').replace('true', 'false')} required-task-wrapper' id='required-task-wrapper-domain-#{domainId}'>
                <div class='row'><div class='col-sm-12'><div class='ibox-title'><h5>Domain: #{domainName}</h5></div></div></div>
                <div class='col-sm-12 col-md-6 domain-goal-section#{currentIndex}'></div>
                <div class='col-sm-12 col-md-6' id='domain-task-section#{domainId}'></div>
              </div>")
            $(".domain-goal-section#{currentIndex}").append(goalLabelClone)
            $(".domain-goal-section#{currentIndex}").append(goalSectionClone.removeClass('error required'))
            $("#domain-task-section#{domainId}").append(textRequiredClone)
            $("#domain-task-section#{domainId}").append(taskArisingClone)
            $("#domain-task-section#{domainId}").append(taskClone)
        else
          $(".row.#{$(@).attr('id')}").remove()
          isChecked    = false
          $("[id$='_required_task_last_true']").each ->
            return isChecked = true if $(@).is(':checked')

          unless isChecked
            if $('a#btn-save').length == 0
              _appendSaveButton()
              _translatePagination()
            $('a#btn-save').show()

  _toggleEndOfAssessmentMsg = ->
    if $('.required-task-wrapper:visible').length
      $('#end-of-assessment-msg').addClass('hidden')
    else
      $('#end-of-assessment-msg').removeClass('hidden')

  _initTaskRequire = ->
    currentIndex = $("#rootwizard").steps("getCurrentIndex")
    tasksList = $("#rootwizard-p-#{currentIndex} li.list-group-item")
    console.log tasksList.length
    if tasksList.length
      $("#rootwizard-p-#{currentIndex} .task_required").addClass('hidden')
    else
      $("#rootwizard-p-#{currentIndex} .task_required").removeClass('hidden')

  _scrollToError = (element) ->
    if $('.error').length > 0
      $.each $('.error'), (index, item) ->
        element = $(item).context.id
        if element == ''
          location.href = "#score-required"
        else if element.includes('assessment_assessment_domains_attributes')
          location.href = "##{element}"
          location.href = "#required-scroll"
        else
          location.href = "##{element}"


  { init: _init }
