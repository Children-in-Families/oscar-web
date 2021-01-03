CIF.Care_plansNew = CIF.Care_plansEdit = CIF.Care_plansCreate = CIF.Care_plansUpdate = do ->
  _init = ->
    forms = $('form.care_plan-form')

    for form in forms
      _loadSteps($(form))
    
    _translatePagination()
    _initDatePicker()
    _initGoalTask()
    _initDatePickerOnTaskClick()
  
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
    # bodyTag = '.assessment-wizard-domain-item'
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
        _initGoalTaskEditPage(currentTab)
        return true if isGoalTaskRequired == 'primary' || isGoalTaskRequired == 'info'
        _requiredGoalTask(currentIndex, currentTab)

      onStepChanging: (event, currentIndex, newIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        isGoalTaskRequired = $("#{currentTab}").find('.score-color').text()
        return true if isGoalTaskRequired == 'primary' || isGoalTaskRequired == 'info'
        _requiredGoalTask(currentIndex, currentTab)

      onStepChanged: (event, currentIndex, priorIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        _initGoalTaskEditPage(currentTab)
      
      onFinished: ->
        form.submit()
  
  _initGoalTask = ->
    $('#care_plans-new .btn-add-goal').click()
    $('#care_plans-new .btn-add-task').click()
    _initDatePicker()

  _initGoalTaskEditPage = (currentTab) ->
    if $("#care_plans-edit #{currentTab} .goal-input-field").length == 0
      $("#care_plans-edit #{currentTab} .btn-add-goal").click()
      $("#care_plans-edit #{currentTab} .btn-add-task").click()
      _initDatePicker()

  _initDatePickerOnTaskClick = ->
    $('body').on 'click', '.btn-add-task', ->
      setTimeout (->
        _initDatePicker()
      ), 400
  
  _requiredGoalTask = (currentIndex, currentTab) ->
    goalValue = $("#{currentTab}").find('.goal-input-field')[0].value
    taskValue = $("#{currentTab}").find('.task-input-field')[0].value
    taskDateValue =  $("#{currentTab}").find('.task-date-field')[0].value
    if goalValue == "" || taskValue == "" || taskDateValue == ""
      $("#{currentTab}").find('.required-message').removeClass('hide')
      return false
    else
      return true

  { init: _init }
