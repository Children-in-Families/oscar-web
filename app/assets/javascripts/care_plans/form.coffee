CIF.Care_plansNew = CIF.Care_plansEdit = CIF.Care_plansCreate = CIF.Care_plansUpdate = do ->
  _init = ->
    forms = $('form.care_plan-form, #previous-care-plan' )
    for form in forms
      _loadSteps($(form))

    _buttonHelpTextPophover()
    _translatePagination()
    _initDatePicker()
    _initDatePickerOnTaskClick()
    _saveCarePlan(form)

  _buttonHelpTextPophover = ->
    $("a[data-content]").popover(
      html: true
    ).on 'show.bs.popover', ->
      $(this).data('bs.popover').tip().css
        maxWidth: '600px'
        zIndex: '9999'
      return

  _initDatePicker = ->
    $('.date-picker').datepicker
      autoclose: true,
      format: 'yyyy-mm-dd',
      todayHighlight: true,
      disableTouchKeyboard: true,
      startDate: '1899,01,01',
      todayBtn: true,
    .attr('readonly', 'true').css('background-color','#ffffff').keypress (e) ->
      if e.keyCode == 8
        e.preventDefault()
      return

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

  _loadSteps = (form) ->
    bodyTag = 'div'
    bodyTag = '.care-plan-wizard-domain-item' if _disableRequiredFields()
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
        isGoalTaskRequired = $("#{currentTab}").find('.score-color').text()
        _appendSaveButton()
        _appendSaveCancel()
        _initGoalTaskPage(currentTab)
        taskValue = _taskRequiredField(currentTab)
        return true if (isGoalTaskRequired == 'primary' || isGoalTaskRequired == 'info') && taskValue == ""
        _requiredGoalTask(currentIndex, currentTab)

      onStepChanging: (event, currentIndex, newIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        isGoalTaskRequired = $("#{currentTab}").find('.score-color').text()
        taskValue = _taskRequiredField(currentTab)

        return true if _disableRequiredFields() || rootId == '#readonly-rootwizard'
        return true if (isGoalTaskRequired == 'primary' || isGoalTaskRequired == 'info') && taskValue == ""
        _requiredGoalTask(currentIndex, currentTab)

      onStepChanged: (event, currentIndex, priorIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        _initGoalTaskPage(currentTab)
        if $(rootId).find('a[href="#finish"]:visible').length
          $("#{rootId} a[href='#save']").hide()
        else
          $("#{rootId} a[href='#save']").show()
      onFinishing: (event, currentIndex, newIndex) ->
        return false if rootId == '#readonly-rootwizard'
        return true

      onFinished: ->
        return if rootId == '#readonly-rootwizard'

        btnSaving = $(rootId).data('saving')
        $('a[href="#finish"]').addClass('btn disabled').css('font-size', '96%').text(btnSaving)
        $('.actions a:contains("Done")').removeAttr('href')
        form.submit()

  _disableRequiredFields = ->
    form = $('#previous-care-plan')
    form.data("disable-required-fields")

  _taskRequiredField = (currentTab) ->
    $("#{currentTab}").find('.task-input-field')[0] && $("#{currentTab}").find('.task-input-field')[0].value

  _initGoalTaskPage = (currentTab) ->
    if $(".care_plan-form #{currentTab} .goal-input-field").length == 0
      $(".care_plan-form #{currentTab} .btn-add-goal").click()
      $(".care_plan-form #{currentTab} .btn-add-task").click()
    if $(".care_plan-form #{currentTab} .task-input-field").length == 0
      $(".care_plan-form #{currentTab} .btn-add-task").click()
    _initDatePicker()

  _initDatePickerOnTaskClick = ->
    $('body').on 'click', '.btn-add-task', ->
      setTimeout (->
        _initDatePicker()
      ), 400

  _requiredGoalTask = (currentIndex, currentTab) ->
    return unless $("#{currentTab}").find('.goal-input-field').length
    goalValue = $("#{currentTab}").find('.goal-input-field')[0].value
    taskValue = $("#{currentTab}").find('.task-input-field')[0].value
    taskDateValue =  $("#{currentTab}").find('.task-date-field')[0].value
    if goalValue == "" || taskValue == "" || taskDateValue == ""
      $("#{currentTab}").find('.required-message').removeClass('hide')
      return false
    else
      if taskValue != "" && taskDateValue == ""
        $("#{currentTab}").find('.required-message').removeClass('hide')
        return false
      else
        return true

  _appendSaveCancel = ->
    unless $('#rootwizard').find('a[id="btn-cancel"]:visible').length
      careplanHref = $('a.btn-back-default').first().attr('href')
      $('#rootwizard').find("[aria-label=Pagination]").prepend("<li><a id='btn-cancel' href='#{careplanHref}' class='btn btn-default' style='color: #343a40; background: white; border: 1px solid #acb3ac;'></a></li>")

  _appendSaveButton = ->
    if $('#rootwizard').find('a[href="#finish"]:visible').length == 0 && $("#btn-save").length == 0
      $('#rootwizard').find("[aria-label=Pagination]").append("<li><a id='btn-save' href='#save' class='btn btn-info' style='background: #21b9bb;'></a></li>")
      #

  _saveCarePlan = (form) ->
    $(document).on 'click', "#rootwizard a[href='#save']", ->
      if $(form).valid()
        btnSaving = $('#rootwizard').data('saving')
        $("a[href='#save']").addClass('disabled').text(btnSaving)

      $(form).submit()


  { init: _init }
