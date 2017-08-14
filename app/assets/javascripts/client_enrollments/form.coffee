CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _handleDeleteAttachment()
    _preventEnrollmentDate()
    _preventRequireFieldInput()
    _preventCheckBox()

  _initSelect2 = ->
    $('select').select2()

  _initFileInput = ->
    $('.file').fileinput
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
        url = $(deleteBtn).data('url')
        $('td .delete').attr('disabled', 'disabled')
        $.ajax
          dataType: "json"
          url: url
          method: 'DELETE'
          success: (response) ->
            _initNotification(response.message)
            btns = $(element).parent()
            $(element).remove()
            _generateNewFileIdex(btns)
            $('td .delete').removeAttr('disabled')

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

  _generateNewFileIdex = (element)->
    btnDeletes = $(element).find('.delete')
    index = 0
    return if btnDeletes.length == 0
    for btnDelete in btnDeletes
      btnDelete.dataset.url = _replaceUrlParam(btnDelete.dataset.url, 'file_index', index++)

  _replaceUrlParam = (url, paramName, paramValue) ->
    if paramValue == null
      paramValue = ''
    pattern = new RegExp('\\b(' + paramName + '=).*?(&|$)')
    if url.search(pattern) >= 0
      return url.replace(pattern, '$1' + paramValue + '$2')
    url + (if url.indexOf('?') > 0 then '&' else '?') + paramName + '=' + paramValue

  _preventEnrollmentDate = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->
      requiredField = $('#enrollment_date')
      if $(requiredField).val() == ''
        $(requiredField).parent().parent().addClass('has-error')
        $(requiredField).parent().siblings('.help-block').removeClass('hidden')
        e.preventDefault()
      else
        $(requiredField).parents('.has-error').removeClass('has-error')
        $(requiredField).parent().siblings('.help-block').addClass('hidden')

  _preventRequireFieldInput = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->

      requiredFields = $(':input').parents('div.required')
      for requiredField in requiredFields
        if $(requiredField).find('input').val() == '' or $(requiredField).find('textarea').val() == ''
          if $(requiredField).find('.select2-chosen, .select2-search-choice').length == 0
            $(requiredField).parent().addClass('has-error')
            $(requiredField).siblings('.help-block').removeClass('hidden')
            e.preventDefault()
        else
          $(requiredField).parent().removeClass('has-error')
          $(requiredField).siblings('.help-block').addClass('hidden')

  _preventCheckBox = ->
    form = $('form.client-enrollment')
    $(form).on 'submit', (e) ->
      checkBoxs = $('input[type="checkbox"]').parents('div.required')
      for checkBox in checkBoxs
        if $(checkBox).find('.checked').length == 0
          $(checkBox).parents('.i-checks').addClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').removeClass('hidden')
          e.preventDefault()
        else
          $(checkBox).parents('.i-checks').removeClass('has-error')
          $(checkBox).parents('.i-checks').children('.help-block').addClass('hidden')

  { init: _init }
