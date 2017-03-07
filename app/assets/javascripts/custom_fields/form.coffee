CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate =
CIF.Custom_fieldsShow = do ->

  _init = ->
    _initFormBuilder()
    _select2()
    _toggleTimeOfFrequency()
    _changeSelectOfFrequency()
    _valTimeOfFrequency()

  _valTimeOfFrequency = ->
    $('#custom_field_time_of_frequency').val()

  time_of_frequency = _valTimeOfFrequency()

  _toggleTimeOfFrequency = ->
    frequency = $('#custom_field_frequency').val()
    if frequency == ''
      $('#custom_field_time_of_frequency').attr('disabled', 'disabled')
        .val(0)
    else
      if time_of_frequency == '0'
        time_of_frequency = 1
      $('#custom_field_time_of_frequency').removeAttr('disabled')
        .val(time_of_frequency)

  _changeSelectOfFrequency = ->
      $('#custom_field_frequency').change ->
        _toggleTimeOfFrequency()

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
            $('.fld-subtype ').find('option:contains(color)').remove()
            $('.fld-subtype ').find('option:contains(tel)').remove()
            $('.fld-subtype ').find('option:contains(password)').remove()
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
    $('#custom_field_entity_type').select2
      minimumInputLength: 0

  { init: _init }
