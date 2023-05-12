CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate = do ->
  @customFieldId = $('#custom_field_id').val()
  FIELDS_URL = "/api/custom_fields/#{@customFieldId}/fields"
  CUSTOM_FIELDS_URL = '/api/custom_fields/fetch_custom_fields'
  _init = ->
    _initFormBuilder()
    _retrieveData(FIELDS_URL) if $('#custom_field_id').val() != ''
    _retrieveData(CUSTOM_FIELDS_URL) if $('#custom_field_form_title').attr('disabled') != 'disabled'
    _select2()
    _toggleTimeOfFrequency()
    _changeSelectOfFrequency()
    _valTimeOfFrequency()
    _changeTimeOfFrequency()
    _convertFrequency()
    _removeSearchCustomFields()
    _initICheckBox()
    _labelHandleInput()

  _initICheckBox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _valTimeOfFrequency = ->
    $('#custom_field_time_of_frequency').val()

  timeOfFrequency = parseInt(_valTimeOfFrequency())

  _toggleTimeOfFrequency = ->
    frequency = _convertFrequency()
    if frequency == ''
      $('#custom_field_time_of_frequency').attr('readonly', 'true')
        .val(0)
      $('.frequency-note').addClass('hidden')
    else
      if timeOfFrequency == 0
        timeOfFrequency = 1
      $('#custom_field_time_of_frequency').removeAttr('readonly')
        .val(parseInt(timeOfFrequency))

      _updateFrequencyNote(frequency, timeOfFrequency)

  _changeTimeOfFrequency = ->
    $('#custom_field_time_of_frequency').change ->
      if $(this).val() == ''
        $(this).val(1)
      frequency = _convertFrequency()
      _updateFrequencyNote(frequency, parseInt($(this).val()))

  _updateFrequencyNote = (frequency, timeOfFrequency) ->
    if timeOfFrequency <= 0
      $('.frequency-note').addClass('hidden')
    else
      $('.frequency-note').removeClass('hidden')
      if timeOfFrequency == 1
        $('.frequency-note span.frequency').text(" #{frequency}.")
      else
        $('.frequency-note span.frequency').text(" #{timeOfFrequency} #{frequency}s.")

  _changeSelectOfFrequency = ->
    $('#custom_field_frequency').change ->
      _toggleTimeOfFrequency()

  _convertFrequency = ->
    frequency = $('#custom_field_frequency').val()
    switch(frequency)
      when 'Daily'
        frequency = 'day'
      when 'Weekly'
        frequency = 'week'
      when 'Monthly'
        frequency = 'month'
      when 'Yearly'
        frequency = 'year'
      else
        frequency = ''

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

    $("#custom-field-submit").click (event) ->
      labelFields = $('[name="label"].fld-label')
      for labelField in labelFields
        labelField.textContent = labelField.textContent.replace(/;/g, '')

      specialCharacters = { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&qoute;" }
      fields = format.formatSpecialCharacters(JSON.parse(formBuilder.actions.save()), specialCharacters)
      $('#custom_field_fields').val(JSON.stringify(fields))

  _select2 = ->
    $('#custom_field_entity_type').select2
      minimumInputLength: 0
    $('#custom_field_frequency').select2
      minimumInputLength: 0
      allowClear: true

  _retrieveData = (url) ->
    $.ajax
      method: 'GET'
      url: url
      dataType: 'JSON'
      success: (response) ->
        _preventRemoveFields(response.fields) if response.hasOwnProperty('fields')
        _searchCustomFields(response.custom_fields) if response.hasOwnProperty('custom_fields')

  _searchCustomFields = (fields) ->
    $('#custom_field_form_title').keyup ->
      $('#livesearch').css('visibility', 'hidden')
      $('#livesearch').empty()
      form_title = $('#custom_field_form_title').val()
      if form_title != ''
        for field in fields
          if field.form_title.toLowerCase().startsWith(form_title.toLowerCase())
            previewTranslation = $('#livesearch').data('preview-translation')
            copyTranslation = $('#livesearch').data('copy-translation')
            width = $('#custom_field_form_title').css('width')
            $('#livesearch').css('width', width)
            $('#livesearch').css('visibility', 'visible')
            ngo_name = field.ngo_name.replace(/\s/g,"+")
            url_origin = document.location.origin
            preview_link = "#{url_origin}/custom_fields/preview?custom_field_id=#{field.id}&ngo_name=#{ngo_name}"
            $('#livesearch').append("<li><span class='col-xs-8'>#{field.form_title} (#{field.ngo_name})</span>
            <span class='col-xs-4 text-right'><a href=#{preview_link}>#{previewTranslation}</a></span></li>")

  _removeSearchCustomFields = ->
    $('#custom_field_form_title').blur ->
      setTimeout ( ->
        $('#livesearch').css('visibility', 'hidden')
      ), 200

  _preventRemoveFields = (fields) ->
    specialCharacters = { "&": "&amp;", "<": "&lt;", ">": "&gt;" }
    labelFields = $('label.field-label')

    for labelField in labelFields
      text = labelField.textContent.allReplace(specialCharacters)

      if fields.includes(text)
        _removeActionFormBuilder(labelField)

  _removeActionFormBuilder = (label) ->
    $('li.paragraph-field.form-field').find('.del-button, .copy-button').remove()
    parent = $(label).parent()
    $(parent).find('.del-button, .copy-button').remove()

    if $(parent).attr('class').includes('number-field')
      return if $('form.simple_form').includes('is-admin')

      $(parent).find('.fld-min, .fld-max').attr('readonly', 'true')
    else if $(parent).attr('class').includes('select-field')
      allSelectOption  = $('#custom_field .select-field .sortable-options .ui-sortable-handle .option-label')
      customFormSelection = $('div[data-custom-form-select-option]').data('custom-form-select-option')
      jQuery.map(allSelectOption, (e) ->
        customFormSelection.forEach (selected_value) ->
          if selected_value == e.value
            $(e).attr('disabled', 'true')
            $(e).parent().children('a.remove.btn').remove()
      )
    else if $(parent).attr('class').includes('radio-group-field')
      allRadioOption  = $('#custom_field .radio-group-field .sortable-options .ui-sortable-handle .option-label')
      customFormRadio = $('div[data-custom-form-radio-option]').data('custom-form-radio-option')
      jQuery.map(allRadioOption, (e) ->
        customFormRadio.forEach (radio_value) ->
          if radio_value == e.value
            $(e).attr('disabled', 'true')
            $(e).parent().children('a.remove.btn').remove()
      )
    else if $(parent).attr('class').includes('checkbox-group-field')
      allCheckboxOption  = $('#custom_field .checkbox-group-field .sortable-options .ui-sortable-handle .option-label')
      customFormCheckboxOption = $('div[data-custom-form-checkbox-option]').data('custom-form-checkbox-option')
      jQuery.map(allCheckboxOption, (e) ->
        customFormCheckboxOption.forEach (checkbox_value) ->
          if checkbox_value == e.value
            $(e).attr('disabled', 'true')
            $(e).parent().children('a.remove.btn').remove()
      )

  _labelHandleInput = () ->
    $(document).on 'keypress paste', '[name="label"].fld-label',  (event) ->
      if event.type == 'keypress'
        return false if event.originalEvent.key == "[" or event.originalEvent.key == "]"
      else
        key = event.originalEvent.clipboardData.getData('Text')
        if key and key.match(/\[|\]/)
          event.preventDefault()
          return false
      true

  { init: _init }
