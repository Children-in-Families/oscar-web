CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate = do ->
  _init = ->
    _initFormBuilder()

  _initFormBuilder = ->
    formBuilder = $('.build-wrap').formBuilder({
      dataType: 'json'
      editOnAdd: true
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file']
      showActionButtons: false

      typeUserEvents: {
        checkbox: {
          onadd: (fld) ->
            $('.toggle-wrap, .className-wrap, .name-wrap, .value-wrap, .access-wrap').hide()
        }
        'checkbox-group': {
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .name-wrap, .access-wrap').hide()
        }
        date: {
          onadd: (fld) ->
            $('.className-wrap, .name-wrap, .value-wrap, .access-wrap').hide()
        }
        number: {
          onadd: (fld) ->
            $('.className-wrap, .name-wrap, .value-wrap, .step-wrap, .access-wrap').hide()
        }
        'radio-group': {
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .name-wrap, .access-wrap').hide()
        }
        select: {
          onadd: (fld) ->
            $('.className-wrap, .name-wrap, .access-wrap').hide()
        }
        text: {
          onadd: (fld) ->
            $('.className-wrap, .name-wrap, .value-wrap, .access-wrap, .maxlength-wrap').hide()
        }
        textarea: {
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .name-wrap, .value-wrap, .access-wrap, .maxlength-wrap').hide()
        }
      }

    }).data('formBuilder');

    $("#custom-field-submit").click (event)->
      $('#custom_field_fields').val(formBuilder.formData)

  { init: _init }
