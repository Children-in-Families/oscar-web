CIF.Client_enrollmentsNew = CIF.Client_enrollmentsCreate = CIF.Client_enrollmentsEdit = CIF.Client_enrollmentsUpdate = do ->
  _init = ->
    _initSelect2()
    _initFileInput()
    _handleDeleteAttachment()

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
      url = $(deleteBtn).data('url')
      confirmDelete = $(deleteBtn).data('comfirm')
      $(deleteBtn).click ->
        result = confirm(confirmDelete)
        return unless result
        $('td .delete').attr('disabled', 'disabled')
        $.ajax
          dataType: "json"
          url: url
          method: 'DELETE'
          success: (response) ->
            _initNotification(response.message)
            $(element).remove()
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

  { init: _init }
