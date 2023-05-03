class CIF.CustomFormBuilder
  constructor: () ->

  thematicBreak: ->
    [{
      label: 'Separation Line'
      attrs: type: 'separateLine'
      icon: '<i class="fa fa-minus" aria-hidden="true"></i>'
    }]

  separateLineTemplate: ->
    separateLine: (fieldData) ->
      { field: '<hr/>' }

  eventParagraphOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.subtype-wrap, .className-wrap, .access-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      $('.subtype-wrap, .className-wrap, .access-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)

  eventCheckboxOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap, .toggle-wrap, .inline-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        self.preventClickEnterOrTab(fld)
        ),50

  eventDateOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.date-field').find('.className-wrap, .placeholder-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap, .toggle-wrap, .inline-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.preventClickEnterOrTab(fld)
      ),50

  eventFileOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.file-field').find('.className-wrap, .placeholder-wrap, .subtype-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.preventClickEnterOrTab(fld)
      ),50

  eventNumberOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.number-field').find('.className-wrap, .placeholder-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.preventClickEnterOrTab(fld)
      ),50

  eventRadioOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .inline-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        self.preventClickEnterOrTab(fld)
        ),50

  eventSelectOption: (fields = [])->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        self.preventClickEnterOrTab(fld)
        ),50

  eventTextFieldOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.fld-subtype ').find('option:contains(color)').remove()
      $('.fld-subtype ').find('option:contains(tel)').remove()
      $('.fld-subtype ').find('option:contains(password)').remove()
      $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.preventClickEnterOrTab(fld)
      ),50

  eventTextAreaOption: (fields = []) ->
    self = @
    onadd: (fld) ->
      $('.rows-wrap, .subtype-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.preventClickEnterOrTab(fld)
      self.handleAddTranslateLabelField(fld, fields)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.preventClickEnterOrTab(fld)
      ),50

  eventSeparateLineOption: ->
    onadd: (fld) ->
      $(fld).find('.field-actions .icon-pencil').remove()
      $(fld).on 'dblclick', (e) ->
        e.stopPropagation()
    onclone: (fld) ->
      $(fld).find('.field-actions .icon-pencil').remove()
      $(fld).on 'dblclick', (e) ->
        e.stopPropagation()

  hideOptionValue: ->
    $('.option-selected, .option-value').hide()

  addOptionCallback: (field) ->
    $('.add-opt').on 'click', ->
      setTimeout ( ->
        $(field).find('.option-selected, .option-value').hide()
        )
  generateValueForSelectOption: (field) ->
    $(field).find('input.option-label').on 'keyup change', ->
      value = $(@).val()
      $(@).siblings('.option-value').val(value)

  handleCheckingForm: ->
    @handleDisplayDuplicateWarning()
    @actionRemoveField()
    @actionEditField()

  getDuplicateValues: (elements) ->
    self = @
    $(elements).each (index, label) ->
      displayText = $(label).text()
      $(elements).each (cIndex, cLabel) ->
        return if cIndex == index
        cText = $(cLabel).text()
        if cText == displayText && cText != 'Separation Line'
          self.addDuplicateWarning(label)

  handleDisplayDuplicateWarning: ->
    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      elementFrmbs = $('ul.frmb:visible')
      for element in elementFrmbs
        elements  = $(element).find('.field-label:visible')
        @getDuplicateValues(elements)
    else
      elements = $('ul.frmb:visible .field-label:visible')
      @getDuplicateValues(elements)

  addDuplicateWarning: (element) ->
    errorText = 'Field labels must be unique, please click the edit icon to set a unique field label'
    parentElement = $(element).parents('li.form-field')
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append("<label class='error'>#{errorText}</label>")
      $('#custom-field-submit').attr('disabled', 'true') if $('#custom-field-submit').length

  actionRemoveField: ->
    self = @
    $('.field-actions a.del-button').click ->
      setTimeout ( -> self.removeFieldDuplicate()),300

  actionEditField: ->
    self = @
    labels = $('.field-label:visible')
    $('.field-actions a.icon-pencil').click ->
      $(".form-elements .label-wrap .input-wrap div[name='label']").on 'blur', ->
        setTimeout ( ->
          self.removeFieldDuplicate()
          self.handleDisplayDuplicateWarning(labels)
        ), 300
        self.handlePreventingBlankLabel(@)

  handlePreventingBlankLabel: (element) ->
    text = $(element).text()
    parentElement = $(element).parents('li.form-field')
    errorText = "Label can't be blank"

    if text == 'undefined' || text == ''
      $(parentElement).addClass('has-error')
      $(parentElement).find('input, textarea, select').addClass('error')
      unless $(parentElement).find('label.error').is(':visible')
        $(parentElement).append("<label class='error'>#{errorText}</label>")
    else
      @removeWarning(element)

  getNoneDuplicateLabel: (elements) ->
    labels    = $(elements).map(-> $(@).text().trim()).get()
    values = labels.elementWitoutDuplicates()

    for element in elements
      text = $(element).text().trim()
      continue if text == 'undefined' || text == ''
      if values.includes(text)
        @removeWarning(element)

  removeFieldDuplicate: ->
    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      elementFrmbs = $('ul.frmb:visible')
      for element in elementFrmbs
        elements  = $(element).find('.field-label:visible')
        @getNoneDuplicateLabel(elements)
    else
      elements = $('ul.frmb:visible .field-label:visible')
      @getNoneDuplicateLabel(elements)

  removeWarning: (element) ->
    field = $(element).parents('li.form-field')
    $(field).removeClass('has-error')
    $(field).find('input, textarea, select').removeClass('error')
    $(field).find('label.error').remove()
    $('#custom-field-submit').removeAttr('disabled') if $('#custom-field-submit').length

  preventClickEnterOrTab: (element) ->
    $(element).find('.fld-label').keypress (event) ->
      if event.which == 13 or event.which == 59
        event.preventDefault()
        key = if event.which == 13 then 'Enter key' else 'Semi-colon'
        alert("#{key} is not allowed!")

  handleAddTranslateLabelField: (fld, fields) ->
    fldElement = $(fld)
    fldId = fldElement.attr('id')
    index = fldId.substr(fldId.lastIndexOf('-') + 1)
    localLabelName = "local_label"
    localLabel = "Local Label"
    if fields[index - 1]
      localLabel = if fields[index - 1][localLabelName] then fields[index - 1][localLabelName] else localLabel
    frmHolder = fldElement.find('.frm-holder')
    localLabelBlock = "<div class='form-group local-label-wrap' style='display: block'><label for='#{localLabelName}'>Local Label</label><div class='input-wrap'><div name='#{localLabelName}' placeholder='Local Label' class='fld-label-#{fldId} form-control' id='local-label-#{fldId}' contenteditable='true'>#{localLabel}</div></div></div>"
    localLabelBlockElement = $.parseHTML(localLabelBlock)
    frmHolder.find('.label-wrap').after(localLabelBlockElement)
