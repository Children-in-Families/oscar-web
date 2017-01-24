CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate =
CIF.Custom_fieldsShow = do ->

  _init = ->
    _initFormBuilder();

  _initFormBuilder = ->
    formBuilder = $('.build-wrap').formBuilder({
      dataType: 'json'
      formData: JSON.stringify($('.build-wrap').data('fields'))
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button']
      showActionButtons: false
      }).data('formBuilder');

    $("#custom-field-submit").click (event)->
      $('#custom_field_fields').val(formBuilder.formData)

  { init: _init }
