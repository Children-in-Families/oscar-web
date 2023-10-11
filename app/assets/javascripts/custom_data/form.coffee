CIF.Custom_dataNew = CIF.Custom_dataCreate = CIF.Custom_dataEdit = CIF.Custom_dataUpdate = do ->
  _init = ->
    _initFormBuilder()

  _initFormBuilder = ->
    builderOption = new CIF.CustomFormBuilder()
    specialCharacters = { '&amp;': '&', '&lt;': '<', '&gt;': '>', "&qoute;": '"' }
    fields = $('.build-wrap').data('fields') || []
    format = new CIF.FormatSpecialCharacters()
    fields = format.formatSpecialCharacters(fields, specialCharacters)

    formBuilder = $('.build-wrap').formBuilder
      templates: separateLine: (fieldData) ->
        { field: '<hr/>' }
      fields: builderOption.thematicBreak()
      dataType: 'json'
      formData:  JSON.stringify(fields)
      disableFields: ['autocomplete', 'header', 'hidden', 'button', 'checkbox']
      showActionButtons: false
      messages: {
        cannotBeEmpty: 'name_separated_with_underscore'
      }
      stickyControls: {
        enable: true
        offset:
          top: 20,
          right: 20,
          left: 'auto'
      }

      typeUserEvents: {
        'checkbox-group': builderOption.eventCheckboxOption()
        date: builderOption.eventDateOption()
        file: builderOption.eventFileOption()
        number: builderOption.eventNumberOption()
        'radio-group': builderOption.eventRadioOption()
        select: builderOption.eventSelectOption()
        text: builderOption.eventTextFieldOption()
        textarea: builderOption.eventTextAreaOption()
        separateLine: builderOption.eventSeparateLineOption()
        paragraph: builderOption.eventParagraphOption()
      }

    $("#custom-data-submit").click (event) ->
      labelFields = $('[name="label"].fld-label')
      for labelField in labelFields
        labelField.textContent = labelField.textContent.replace(/;/g, '')

      fields = format.formatSpecialCharacters(JSON.parse(formBuilder.actions.save()), specialCharacters)
      $('#custom_data_fields').val(JSON.stringify(fields))

  { init: _init }
