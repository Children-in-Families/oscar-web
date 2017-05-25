CIF.Custom_field_propertiesNew = CIF.Custom_field_propertiesCreate = CIF.Custom_field_propertiesEdit = CIF.Custom_field_propertiesUpdate = do ->
  _init = ->
    _initUploader()
    _handleDeleteAttachment()

  _initUploader = ->
    $("#custom_field_property_attachments").fileinput
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
      $(deleteBtn).click ->
        $('input[type="submit"].form-btn').attr('disabled', 'disabled')
        $.ajax
          dataType: "json"
          url: url
          method: 'DELETE'
          success: (response) ->
            _initNotification(response.message)
            $(element).remove()
            $('input[type="submit"].form-btn').removeAttr('disabled')

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