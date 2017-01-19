CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate = do ->
  _init = ->
    _initFormBuilder();

  _initFormBuilder = ->
    formBuilder = $('.build-wrap').formBuilder({
      dataType: 'json',
      editOnAdd: true
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button']
      showActionButtons: false
      }).data('formBuilder');

    $("#custom-field-submit").click (event)->
      $('#custom_field_fields').val(formBuilder.formData)
      console.log $('#custom_field_fields').val()


  { init: _init }
