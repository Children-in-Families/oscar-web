class CIF.CustomFormBuilder
  constructor: () ->

  eventCheckoutOption: ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventDateOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .value-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventNumberOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .value-wrap, .step-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventRadioOption: ->
    self = @
    onadd: (fld) ->
      $('.other-wrap, .className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventSelectOption: ->
    self = @
    onadd: (fld) ->
      $('.className-wrap, .access-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
      self.hideOptionValue()
      self.addOptionCallback(fld)
      self.generateValueForSelectOption(fld)
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
        self.hideOptionValue()
        self.addOptionCallback(fld)
        self.generateValueForSelectOption(fld)
        ),50

  eventTextFieldOption: ->
    self = @
    onadd: (fld) ->
      $('.fld-subtype ').find('option:contains(color)').remove()
      $('.fld-subtype ').find('option:contains(tel)').remove()
      $('.fld-subtype ').find('option:contains(password)').remove()
      $('.className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

  eventTextAreaOption: ->
    self = @
    onadd: (fld) ->
      $('.rows-wrap, .className-wrap, .value-wrap, .access-wrap, .maxlength-wrap, .description-wrap, .name-wrap').hide()
      self.handleCheckingForm()
    onclone: (fld) ->
      setTimeout ( ->
        self.handleCheckingForm()
      ),50

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

  handleDisplayDuplicateWarning: ->
    self = @
    labels = $('.field-label:visible')

    $(labels).each (index, label) ->
      labelText = $(label).text()
      $(labels).each (i, cLabel) ->
        return if i == index
        text = $(cLabel).text()
        if text == labelText
          self.addDuplicateWarning(label)

  addDuplicateWarning: (element) ->
    errorText = 'Field labels must be unique, please click the edit icon to set a unique field label'
    parentElement = $(element).parents('li.form-field')
    $(parentElement).addClass('has-error')
    $(parentElement).find('input, textarea, select').addClass('error')
    unless $(parentElement).find('label.error').is(':visible')
      $(parentElement).append("<label class='error'>#{errorText}</label>")

    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      $(element).addClass('error')
      unless $(element).parent().find('label.error').is(':visible')
        $(element).parent().append('<label class="error">Tracking name must be unique</label>')

  actionRemoveField: ->
    self = @
    $('.field-actions a.del-button').click ->
      self.removeFieldDuplicate(deleteBtn)

  actionEditField: ->
    self = @
    labels = $('.field-label:visible')
    $('.field-actions a.icon-pencil').click ->
      editElement = @
      $("input[name='label']").on 'blur', ->
        self.handleDisplayDuplicateWarning()

        counts = self.countDuplicateLabel(labels)
        $.each counts, (labelText, numberOfField) ->
          $(labels).each (index, label) ->
            if (numberOfField == 1) && (label.textContent == labelText)
              self.removeDuplicateWarning(label)

  removeFieldDuplicate: (element)->
    duplicates = []
    labels = $('.field-label:visible')
    currentLabel  = $(element).parents('.field-actions').next().text()
    for label in labels
      duplicates.push label if currentLabel == $(label).text()

    if duplicates.length == 2
      for field in duplicates
        @removeDuplicateWarning(field)

  removeDuplicateWarning: (element) ->
    field = $(element).parents('li.form-field')
    $(field).removeClass('has-error')
    $(field).find('input, textarea, select').removeClass('error')
    $(field).find('label.error').remove()

    if $('#trackings').is(':visible') and $('.nested-fields').is(':visible')
      $(field).removeClass('error')
      $(field).parent().find('label.error').remove()

  countDuplicateLabel: (elements) ->
    counts = {}
    labels = $(elements).map(-> if $(@).val() != '' then $(@).val() else $(@).text()).get()
    $(labels).map(-> counts[@] = (counts[@] or 0) + 1)
    counts

