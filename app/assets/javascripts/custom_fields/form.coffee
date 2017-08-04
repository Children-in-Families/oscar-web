CIF.Custom_fieldsNew = CIF.Custom_fieldsCreate = CIF.Custom_fieldsEdit = CIF.Custom_fieldsUpdate =
CIF.Custom_fieldsShow = do ->

  _init = ->
    _initFormBuilderWithPrevent()
    _select2()
    _toggleTimeOfFrequency()
    _changeSelectOfFrequency()
    _valTimeOfFrequency()
    _changeTimeOfFrequency()
    _convertFrequency()
    _searchCustomFields()

  _initFormBuilderWithPrevent = ->
    _initFormBuilder()
    _preventRemoveFields()

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

  _generateValueForSelectOption = (field) ->
    $(field).find('input.option-label').on 'keyup change', ->
      value = $(@).val()
      $(@).siblings('.option-value').val(value)

  _hideOptionValue = ->
    $('.option-selected, .option-value').hide()

  _addOptionCallback = (field) ->
    $('.add-opt').on 'click', ->
      setTimeout ( ->
        $(field).find('.option-selected, .option-value').hide()
        )


  _initFormBuilder = ->
    fields = "#{$('.build-wrap').data('fields')}" || ''
    formBuilder = $('.build-wrap').formBuilder({
      dataType: 'json'
      formData:  fields.replace(/=>/g, ':')
      disableFields: ['autocomplete', 'header', 'hidden', 'paragraph', 'button', 'file','checkbox']
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
        'checkbox-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
            _handleCheckingForm()
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              _handleCheckingForm()
              ),50

        date:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm()

        number:
          onadd: (fld) ->
            $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm()

        'radio-group':
          onadd: (fld) ->
            $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
            _handleCheckingForm()
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              _handleCheckingForm()
              ),50

        select:
          onadd: (fld) ->
            $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
            _hideOptionValue()
            _addOptionCallback(fld)
            _generateValueForSelectOption(fld)
            _handleCheckingForm()
          onclone: (fld) ->
            setTimeout ( ->
              _hideOptionValue()
              _addOptionCallback(fld)
              _generateValueForSelectOption(fld)
              _handleCheckingForm()
              ),50

        text:
          onadd: (fld) ->
            $('.fld-subtype ').find('option:contains(color)').remove()
            $('.fld-subtype ').find('option:contains(tel)').remove()
            $('.fld-subtype ').find('option:contains(password)').remove()
            $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm()
        textarea:
          onadd: (fld) ->
            $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
            _handleCheckingForm()
      }

    }).data('formBuilder');

    $("#custom-field-submit").click (event)->
      $('#custom_field_fields').val(formBuilder.formData)

  _select2 = ->
    $('#custom_field_entity_type').select2
      minimumInputLength: 0
    $('#custom_field_frequency').select2
      minimumInputLength: 0
      allowClear: true

  _searchCustomFields = ->
    custom_fields = ''
    $.ajax({
      type: 'GET'
      url: '/api/custom_fields/fetch_custom_fields'
      dataType: "JSON"
    }).success((json)->
      custom_fields = json.custom_fields
    )
    $('#custom_field_form_title').keyup ->
      $('#livesearch').css('visibility', 'hidden')
      $('#livesearch').empty()
      form_title = $('#custom_field_form_title').val()
      if form_title != ''
        for custom_field in custom_fields
          if custom_field.form_title.toLowerCase().startsWith(form_title.toLowerCase())
            previewTranslation = $('#livesearch').data('preview-translation')
            copyTranslation = $('#livesearch').data('copy-translation')
            width = $('#custom_field_form_title').css('width')
            $('#livesearch').css('width', width)
            $('#livesearch').css('visibility', 'visible')
            ngo_name = custom_field.ngo_name.replace(/\s/g,"+")
            url_origin = document.location.origin
            preview_link = "#{url_origin}/custom_fields/preview?custom_field_id=#{custom_field.id}&ngo_name=#{ngo_name}"
            $('#livesearch').append("<li><span class='col-xs-8'>#{custom_field.form_title} (#{custom_field.ngo_name})</span>
            <span class='col-xs-4 text-right'><a href=#{preview_link}>#{previewTranslation}</a></span></li>")

  _preventRemoveFields = ->
    fields = ''
    customFieldId = $('#custom_field_id').val()
    return if customFieldId == ''
    $.ajax({
      type: 'GET'
      url: "/api/custom_fields/#{customFieldId}/fields"
      dataType: "JSON"
    }).success((json)->
      fields = json.custom_fields
      labelFields = $('label.field-label')
      for labelField in labelFields
        parent = $(labelField).parent()
        for field in fields
          if labelField.textContent == field
            $(parent).children('div.field-actions').remove()
    )

  _handleCheckingForm = ->
    _handleDisplayDuplicateWarning()
    _handleDeleteField()
    _handleEditLabelName()

  _handleDisplayDuplicateWarning = ->
    duplicateLabels = false
    labelFields = $('label.field-label')
    $(labelFields).each (index, label) ->
      displayText = $(label).text()
      $(labelFields).each (cIndex, cLabel) ->
        return if cIndex == index
        cText = $(cLabel).text()
        if cText == displayText
          _addDuplicateWarning(label)

  _handleDeleteField = ->
    $('.field-actions a.del-button').on 'click', ->
      removedField = {}
      removedField = $(@).parents().children('label.field-label')
      labelFields = $(@).parents('.form-wrap').find('label.field-label')

      counts = _countDuplicateLabel(labelFields)
      $.each counts, (labelText, numberOfField) ->
        if numberOfField == 2
          $(labelFields).each (index, label) ->
            if label.textContent == removedField.text()
              _removeDuplicateWarning(label)

  _handleEditLabelName = ->
    $(".form-wrap:visible .input-wrap input[name='label']").on 'blur', ->
      labelFields = $(@).parents('.form-wrap').find('label.field-label')

      counts = _countDuplicateLabel(labelFields)
      $.each counts, (labelText, numberOfField) ->
        $(labelFields).each (index, label) ->
          if (numberOfField == 1) && (label.textContent == labelText)
            _removeDuplicateWarning(label)

          else if (numberOfField > 1) && (label.textContent == labelText)
            _addDuplicateWarning(label)

  _countDuplicateLabel = (element) ->
    labels = []

    $(element).each (index, label) ->
      if $(label).val() != ''
        labels.push $(label).val()
      else
        labels.push $(label).text()

    counts = {}
    labels.forEach (x) ->
      counts[x] = (counts[x] or 0) + 1

    counts

  _addDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field')
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append('<label class="error">Field labels must be unique, please click the edit icon to set a unique field label</label>')
      $('#custom-field-submit').attr('disabled', 'true')

  _removeDuplicateWarning = (element) ->
    parentElement = $(element).parents('li.form-field')
    $(parentElement).removeClass('has-error')
    $(parentElement).find('input, textarea, select').removeClass('error')
    $(parentElement).find('label.error:last-child').remove()
    if $('.form-field.has-error').length == 0
      $('#custom-field-submit').removeAttr('disabled')

  { init: _init }
