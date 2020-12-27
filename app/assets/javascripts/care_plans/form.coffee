CIF.Care_plansNew = CIF.Care_plansEdit = CIF.Care_plansCreate = CIF.Care_plansUpdate = do ->
  _init = ->
    forms = $('form.care_plan-form')

    for form in forms
      _loadSteps($(form))
    
    _translatePagination()
    _initDatePicker()
  
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
      
      onFinished: ->
        form.submit()

  { init: _init }
