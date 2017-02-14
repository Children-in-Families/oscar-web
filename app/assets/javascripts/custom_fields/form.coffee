CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate =
CIF.Custom_fieldsShow = do ->

  _init = ->
    _initFormBuilder()
    _select2()

  _initFormBuilder = ->
    formBuilder = $('.build-wrap').formBuilder({
      dataType: 'json'
      formData: JSON.stringify($('.build-wrap').data('fields'))
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file','checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }

      typeUserEvents: {
        # checkbox: {
        #   onadd: (fld) ->
        #     $('.toggle-wrap, .value-wrap, .access-wrap').hide()
        #     $('.className-wrap').addClass('hidden')
        # }
        'checkbox-group': {
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap').hide()
        }
        date: {
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap').hide()
        }
        number: {
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap').hide()
        }
        'radio-group': {
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap').hide()
        }
        select: {
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap').hide()
        }
        text: {
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap').hide()
        }
        textarea: {
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap').hide()

        }

      }

    }).data('formBuilder');

    $("#custom-field-submit").click (event)->
      $('#custom_field_fields').val(formBuilder.formData)

  _select2 = ->
    $('#custom_field_entity_name').select2
      minimumInputLength: 0

  { init: _init }
