class CIF.ClientAdvanceSearch
  constructor: () ->
    @filterTranslation   = ''
    @customFormSelected  = []
    @programSelected     = []
    optionTranslation    = $('#opt-group-translation')

    @enrollmentCheckbox  = $('#enrollment-checkbox')
    @trackingCheckbox    = $('#tracking-checkbox')
    @exitCheckbox        = $('#exit-form-checkbox')

    @CUSTOM_FORM_URL      = '/api/client_advanced_searches/get_custom_field'
    @ENROLLMENT_URL       = '/api/client_advanced_searches/get_enrollment_field'
    @TRACKING_URL         = '/api/client_advanced_searches/get_tracking_field'
    @EXIT_PROGRAM_URL     = '/api/client_advanced_searches/get_exit_program_field'

    @DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
    @BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
    @CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')

    @ENROLLMENT_TRANSLATE     = $(optionTranslation).data('enrollment')
    @TRACKING_TRANSTATE       = $(optionTranslation).data('tracking')
    @EXIT_PROGRAM_TRANSTATE   = $(optionTranslation).data('exitProgram')

    @QUANTITATIVE_TRANSLATE   = $(optionTranslation).data('quantitative')

  setValueToBuilderSelected: ->
    @customFormSelected = $('.custom-form').data('value')
    @programSelected    = $('.program-stream').data('value')

  getTranslation: ->
    @filterTranslation =
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')

  formatSpecialCharacter: (value) ->
    filedName = value.toLowerCase().replace(/[^a-zA-Z0-9]+/gi, ' ').trim()
    filedName.replace(/ /g, '_')

  removeCheckboxColumnPicker: (element, name) ->
    $("#{element} ul.append-child li.#{name}").remove()

  ################################################################################################################################

  initBuilderFilter: ->
    builderFields = $('#client-builder-fields').data('fields')
    advanceSearchBuilder = new CIF.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
    advanceSearchBuilder.initRule()
    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($('#builder'))

  initSelect2: ->
    $('#custom-form-select, #program-stream-select, #quantitative-case-select').select2()
    $('.rule-filter-container select').select2(width: '250px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

  basicFilterSetRule: ->
    basicQueryRules = $('#builder').data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      $('#builder').queryBuilder('setRules', basicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

  ################################################################################################################################

  customFormSelectChange: ->
    self = @
    $('#custom-form-wrapper select').on 'select2-selecting', (element) ->
      self.customFormSelected.push(element.val)
      self.addCustomBuildersFields(element.val, self.CUSTOM_FORM_URL)

  addCustomBuildersFields: (ids, url) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '#custom-form-column' else '#program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)

  addFieldToColumnPicker: (element, fieldList) ->
    self = @
    customFormColumnPicker = $("#{element} ul.append-child")
    fieldsGroupByOptgroup = _.groupBy(fieldList, 'optgroup')
    _.forEach fieldsGroupByOptgroup, (values, key) ->
      headerClass = self.formBuiderFormatHeader(key)
      $(customFormColumnPicker).append("<li class='dropdown-header #{headerClass}'>#{key}</li>")
      _.forEach values, (value) ->
        fieldName = value.id
        keyword   = _.first(fieldName.split('_'))
        if keyword != 'enrollmentdate' and keyword != 'programexitdate'
          checkField  = self.formatSpecialCharacter(fieldName)
          label       = value.label
          $(customFormColumnPicker).append(self.checkboxElement(checkField, headerClass, label))
          $(".#{headerClass} input.i-checks").iCheck
            checkboxClass: 'icheckbox_square-green'

  formBuiderFormatHeader: (value) ->
    keyWords = value.split('|')
    name = _.first(keyWords).trim()
    label = _.last(keyWords).trim()
    combine = "#{name} #{label}"
    @formatSpecialCharacter(combine)

  checkboxElement: (field, name, label) ->
    "<li class='visibility checkbox-margin #{name}'>
      <input type='checkbox' name='#{field}_' id='#{field}_' value='#{field}' class='i-checks' style='position: absolute; opacity: 0;'>
      <label for='#{field}_'>#{label}</label>
    </li>"

  handleHideCustomFormSelect: ->
    self = @
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      $('#custom-form-column ul.append-child li').remove()

      $('#custom-form-select option:selected').each ->
        formTitle = $(@).text()
        handleRemoveFilterBuilder(formTitle, self.CUSTOM_FORM_TRANSLATE)

      self.customFormSelected = []
      $('.custom-form select').select2('val', '')
      $('.custom-form').hide()

  handleShowCustomFormSelect: ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show()
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  ################################################################################################################################

  customFormSelectRemove: ->
    self = @
    $('#custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      formTitle   = removeValue.trim()
      formTitle   = self.formatSpecialCharacter("#{formTitle} Custom Form")

      self.removeCheckboxColumnPicker('#custom-form-column', formTitle)
      $.map self.customFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.customFormSelected.splice(i, 1)

      setTimeout ( ->
        self.handleRemoveFilterBuilder(removeValue, self.CUSTOM_FORM_TRANSLATE)
        ),100

  handleRemoveFilterBuilder: (resourceName, resourcelabel) ->
    self = @
    filterSelects = $('.rule-container .rule-filter-container select')
    for select in filterSelects
      optGroup  = $(':selected', select).parents('optgroup')
      if $(select).val() != '-1' and optGroup[0] != undefined and optGroup[0].label != self.BASIC_FIELD_TRANSLATE and optGroup[0].label != self.DOMAIN_SCORES_TRANSLATE
        label = optGroup[0].label.split('|')
        if $(label).last()[0].trim() == resourcelabel.trim() and label[0].trim() == resourceName.trim()
          container = $(select).parents('.rule-container')
          $(container).find('select').select2('destroy')
          $(container).find('.rule-header button').trigger('click')

    setTimeout ( ->
      if $('.rule-container .rule-filter-container select').length == 0
        $('button[data-add="rule"]').trigger('click')
        filterSelects = $('.rule-container .rule-filter-container select')
      self.handleRemoveBuilderOption(filterSelects, resourceName, resourcelabel)
      )

  handleRemoveBuilderOption: (filterSelects, resourceName, resourcelabel) ->
    values = []
    optGroups = $(filterSelects[0]).find('optgroup')
    for optGroup in optGroups
      label = optGroup.label
      if label != self.BASIC_FIELD_TRANSLATE and label != self.DOMAIN_SCORES_TRANSLATE
        labelValue = label.split('|')
        if $(labelValue).last()[0].trim() == resourcelabel.trim() and labelValue[0].trim() == resourceName.trim()
          $(optGroup).find('option').each ->
            values.push $(@).val()
    $('#builder').queryBuilder('removeFilter', values)
    @initSelect2()

  ################################################################################################################################

  handleShowProgramStreamFilter: ->
    self = @
    if $('#program-stream-checkbox').prop('checked')
      $('.program-stream').show()
    if self.enrollmentCheckbox.prop('checked') || self.trackingCheckbox.prop('checked') || self.exitCheckbox.prop('checked') || self.programSelected.length > 0
      $('.program-association').show()
    $('#program-stream-checkbox').on 'ifChecked', ->
      $('.program-stream').show()

  handleHideProgramStreamSelect: ->
    self = @
    $('#program-stream-checkbox').on 'ifUnchecked', ->
      $('#program-stream-column ul.append-child li').remove()
      self.programSelected = []
      $('.program-stream, .program-association').hide()
      $('.program-association input[type="checkbox"]').iCheck('uncheck')
      $('#program-stream-select').select2("val", "")

  handleProgramSelectChange: ->
    self = @
    $('#program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.programSelected.push programId
      $('.program-association').show()
      if $('#enrollment-checkbox').prop('checked')
        addCustomBuildersFields(programId, self.ENROLLMENT_URL)
      if $('#tracking-checkbox').prop('checked')
        addCustomBuildersFields(programId, self.TRACKING_URL)
      if $('#exit-form-checkbox').prop('checked')
        addCustomBuildersFields(programId, self.EXIT_PROGRAM_URL)

  addCustomBuildersFields: (ids, url) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '#custom-form-column' else '#program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)

