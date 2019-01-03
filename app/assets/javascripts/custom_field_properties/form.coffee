CIF.Custom_field_propertiesNew = CIF.Custom_field_propertiesCreate = CIF.Custom_field_propertiesEdit = CIF.Custom_field_propertiesUpdate = do ->
  _init = ->
    _initSelect2()
    _initUploader()
    _handleDeleteAttachment()
    _preventRequireFileUploader()
    # _handlePreventCheckbox()
    _toggleCheckingRadioButton()
    _initICheckBox()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _toggleCheckingRadioButton = ->
    $('input[type="radio"]').on 'ifChecked', (e) ->
      $(@).parents('span.radio').siblings('.radio').find('.iradio_square-green').removeClass('checked')

  _initSelect2 = ->
    $('select').select2()

  _initUploader = ->
    $(".file").fileinput
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

  # _handlePreventCheckbox = ->
  #   form = $('form.simple_form')
  #   $(form).on 'submit', (e) ->
  #     checkboxes = $(form).find('input[type="checkbox"]')
  #     otherInputs = $(form).find('input:not([type="checkbox"], [type="file"], [type="hidden"], [type="submit"])')
  #     checked = false
  #
  #     for checkbox in checkboxes
  #       if $(checkbox).prop('checked')
  #         checked = true
  #         break
  #
  #     if checkboxes.length > 0 and !checked and otherInputs.length == 0
  #       e.preventDefault()
  #       $('#message').text("Please select a checkbox")

  _preventRequireFileUploader = ->
    prevent = new CIF.PreventRequiredFileUploader()
    prevent.preventFileUploader()

  { init: _init }
