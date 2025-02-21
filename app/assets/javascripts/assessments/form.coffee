CIF.AssessmentsNew = CIF.AssessmentsEdit = CIF.AssessmentsCreate = CIF.AssessmentsUpdate = do ->
  _init = ->
    window.domainOptionScores = {}
    forms = $('form.assessment-form')

    for form in forms
      _formValidate($(form))
      _loadSteps($(form))

    _addElement()
    _translatePagination()
    _initUploader()
    _handleDeleteAttachment()
    _saveAssessment(form)
    _initICheckBox()

    $("#assessment_assessment_date").on "change", _submitFormViaAjax

    saveTimer = null
    $(".assessment_assessment_domains_reason textarea").on "keyup", ->
      clearTimeout saveTimer
      saveTimer = setTimeout _submitFormViaAjax, 1000

  _submitFormViaAjax = ->
    if $("form.assessment-form").data("autosave")
      $.ajax
        url: $("form.assessment-form").attr("action") + "&draft=true"
        type: "PUT"
        data: $("form.assessment-form").serialize()
        dataType: "json"
        success: (response) ->
          if response.edit_url
            history.replaceState(null, "", response.edit_url)

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

      currentTabLabels = $(@).siblings()
      currentTabLabels.removeClass('active-label')

      domainOptionScores[@.dataset.domainId] = @.dataset.score
      $('.score_option').removeClass('is_error')
      labelColors = 'btn-danger btn-warning btn-primary btn-success btn-secondary'
      currentTabLabels.removeClass(labelColors)
      score       = $(@).data('score')
      scoreColor  = $(@).parents('.score_option').data("score-#{score}")
      domainId    = $(@).parents('.score_option').data("domain-id")

      $('.score_option input').removeClass('error')
      $('.score_option em').remove()
      $(@).addClass("btn-secondary")
      $($(@).siblings().get(-1)).val(score)

      _submitFormViaAjax()

    $('.score_option input').attr('required','required')

    $('.col-xs-12').on 'click', '.score_option label', ->
      return if $(@).closest(".root-wizard").attr("id") == 'readonly-rootwizard'

      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      currentTab  = "#rootwizard-p-#{currentIndex}"

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
        $("[data-toggle='popover'], [data-trigger='hover']").popover
          html: true

        return

      onStepChanging: (event, currentIndex, newIndex) ->
        return true if newIndex < currentIndex

        currentTab  = "#{rootId}-p-#{currentIndex}"
        domainId = $("#{currentTab}").find('.score_option').data('domain-id')

        return true if _disableRequiredFields() || rootId == '#readonly-rootwizard' || domainId == undefined

        form.validate().settings.ignore = ':disabled,:hidden'
        form.valid()

        _formEdit(rootId, currentIndex)
        _filedsValidator(currentIndex, newIndex)

      onStepChanged: (event, currentIndex, priorIndex) ->
        currentTab  = "#{rootId}-p-#{currentIndex}"
        domainId = $("#{currentTab}").find('.score_option').data('domain-id')
        currentStep = $("#{rootId}-p-" + currentIndex)

        unless currentStep.hasClass('domain-last')
          _formEdit(rootId, currentIndex)
          $('a#btn-save').show()

        if (currentStep.hasClass('domain-last') or $(rootId).find('a[href="#finish"]:visible').length)
          _setTotalRiskAssessment()
          if $(rootId).find('a[href="#finish"]:visible').length
            console.log 'hiding save button'
            $("#{rootId} a[href='#save']").hide()

      onFinishing: (event, currentIndex, newIndex) ->
        return true if _disableRequiredFields()
        return false if rootId == '#readonly-rootwizard'

        form.validate().settings.ignore = ':disabled'
        form.valid()
        _filedsValidator(currentIndex, newIndex)

      onFinished: ->
        return if rootId == '#readonly-rootwizard'

        btnSaving = $(rootId).data('saving')
        $('a[href="#finish"]').addClass('btn disabled').css('font-size', '96%').text(btnSaving)
        $('.actions a:contains("Done")').removeAttr('href')
        form.submit()

  _setTotalRiskAssessment = ->
    scoreColors = $('.score_option.with-def')[0].dataset
    total = 0
    $.each $('.risk-assessment-domain-score'), (index, element) ->
      scoreValue = domainOptionScores[element.dataset.domainId] || element.dataset.domainScore

      if scoreValue
        color = scoreColors["score-#{scoreValue}"]
        $(element).addClass("btn-#{color || 'primary'}")
        $(element).html(scoreValue)
        total += parseInt(scoreValue)

    total = Math.abs(parseFloat(total) / $('.risk-assessment-domain-score').length)
    $('#btn-total').html(total) if total != 0

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

    if chosenScore
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
    currentTab  = "#rootwizard-p-#{currentIndex}"

    return true if _disableRequiredFields() || $("#{currentTab}.domain-client-wellbeing-score").length

    scoreOption = $("#{currentTab} .score_option")
    reason      = $("#{currentTab} .reason").val()
    return false unless reason

    isScoreExist = if (scoreOption.children().last().val().length or $(currentTab).find('.active-label').length) then false else true

    if (scoreOption.find('input.error').length || isScoreExist)
      $(currentTab).find('.score_option').addClass('is_error') if isScoreExist
      return false
    else
      $(currentTab).find('.score_option').removeClass('is_error')
      return true

  _removeTask = ->
    $('a.remove-task').on 'click', (e) ->
      _deleteTask(e)
      currentIndex = $("#rootwizard").steps("getCurrentIndex")
      tasksList = $("#rootwizard-p-#{currentIndex} li.list-group-item")
      if tasksList.length
        $("#rootwizard-p-#{currentIndex} .task_required").removeClass('hidden')


  _removeTaskError = ->
    task = '#assessment_domain_task'
    $("#{task} .task_name, #{task} .task_completion_date").removeClass('has-error')
    $("#{task} .task_name_help, #{task} .task_completion_date_help").hide()

  _initUploader = ->
    $fileInputs = $('.file .optional')

    $.each $fileInputs, (index, fileInput) ->
      $(fileInput).fileinput
        uploadAsync: false
        removeClass: 'btn btn-danger btn-outline'
        browseLabel: 'Browse'
        theme: "explorer"
        allowedFileExtensions: ['jpg', 'png', 'jpeg', 'doc', 'docx', 'xls', 'xlsx', 'pdf']
        uploadUrl: $(fileInput).closest(".assessment-domain-item").data("uploadAttachmentUrl")

      $(fileInput).on "filebatchselected", (event, files) ->
        $(this).fileinput("upload")
        return

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
