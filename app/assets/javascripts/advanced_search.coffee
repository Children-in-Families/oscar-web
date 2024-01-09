class CIF.AdvancedSearch
  constructor: (builderId, customFormUrl) ->
    @filterTranslation   = ''
    @customFormSelected  = []
    @programSelected     = []
    optionTranslation    = $('#opt-group-translation')

    @builderId = builderId
    @DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
    @BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
    @CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')
    @CUSTOM_FORM_URL          = customFormUrl

    @ENROLLMENT_TRANSLATE     = $(optionTranslation).data('enrollment')
    @TRACKING_TRANSTATE       = $(optionTranslation).data('tracking')
    @EXIT_PROGRAM_TRANSTATE   = $(optionTranslation).data('exitProgram')

    @QUANTITATIVE_TRANSLATE   = $(optionTranslation).data('quantitative')

    loaderButton = document.querySelector('.ladda-button-columns-visibility')
    @LOADER = Ladda.create(loaderButton) if loaderButton

  setValueToBuilderSelected: ->
    @customFormSelected = $('#custom-form-data').data('value')
    @programSelected    = $('#program-stream-data').data('value')

  getTranslation: ->
    @filterTranslation =
      addFilter: $(@builderId).data('filter-translation-add-filter')
      addGroup: $(@builderId).data('filter-translation-add-group')
      deleteGroup: $(@builderId).data('filter-translation-delete-group')

  formatSpecialCharacter: (value) ->
    filedName = value.toLowerCase().replace(/[^a-zA-Z0-9]+/gi, ' ').trim() || value.trim()
    filedName.replace(/ /g, '__')

  removeCheckboxColumnPicker: (element, name) ->
    $("#{element} ul.append-child li.#{name}").remove()

  filterSelectChange: ->
    self = @
    $('.rule-filter-container select.form-control').on 'select2-close', ->
      ruleParentId = $(@).closest("div[id^='builder_rule']").attr('id')
      setTimeout ( ->
        $("##{ruleParentId} .rule-operator-container select.form-control, .rule-value-container select.form-control").select2(width: 'resolve')
      )

  handleResizeWindow: ->
    window.dispatchEvent new Event('resize')

  handleScrollTable: ->
    self = @
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
        self.handleResizeWindow()

  ######################################################################################################################

  initBuilderFilter: (id)->
    builderFields = $(id).data('fields')
    @.getTranslation()
    if !_.isEmpty(@filterTranslation) and !_.isEmpty(builderFields)
      advanceSearchBuilder = new CIF.AdvancedFilterBuilder($(@builderId), builderFields, @filterTranslation)
      advanceSearchBuilder.initRule()
      advanceSearchBuilder.setRuleFromSavedSearch()

      # $(@builderId).on 'afterCreateRuleInput.queryBuilder', (e, rule) ->
      #   if rule.filter.plugin == 'datepicker'
      #     $input = rule.$el.find('.rule-value-container [name*=_value_]')
      #     $($input).datepicker(rule.filter.plugin_config)
      #     $input.on 'dp.change', ->
      #       $input.trigger 'change'
      #       return
      #   return

    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($(@builderId))

  initSelect2: ->
    $('#custom-form-select, #program-stream-select, #quantitative-case-select').select2()
    $("#{@builderId} select").select2()
    setTimeout ( ->
      ids = ['#custom-form-select', '#program-stream-select', '#quantitative-case-select', @builderId]
      $.each ids, (index, item) ->
        $("#{item} .rule-filter-container select").select2(width: '250px')
        $("#{item} .rule-operator-container select, .rule-value-container select").select2(width: 'resolve')
    )

    $('.csi-group select').select2(minimumResultsForSearch: -1).on 'select2-open', ->
      selectWrapper = $(@).closest('.csi-group')
      if selectWrapper.offset().top > 840
        $('html, body').animate { scrollTop: selectWrapper.offset().top }, "fast"
      return

    setTimeout ( ->
      $(".csi-group .rule-filter-container select").select2(width: '250px', minimumResultsForSearch: -1)
      $(".csi-group .rule-operator-container select, .rule-value-container select").select2(width: 'resolve')
    )

  basicFilterSetRule: ->
    self = @
    basicQueryRules = $(@builderId).data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      self.handleShowCustomFormSelect()
      $(@builderId).queryBuilder('setRules', basicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-filter-container select.form-control')
    $(document).on 'select2-close', operatorSelect, ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-operator-container select.form-control').select2(width: '180px')
      )

    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select.form-control')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select.form-control').select2(width: '180px')
      )

  ######################################################################################################################

  handleAddQuantitativeFilter: ->
    self = @
    fields = $('#quantitative-fields').data('fields')
    $('#quantitative-type-checkbox').on 'ifChecked', ->
      $('#custom-referral-data').show()
      $(self.builderId).queryBuilder('addFilter', fields) if $("#{self.builderId}:visible").length > 0
      self.initSelect2()

  handleRemoveQuantitativFilter: ->
    self = @
    $('#quantitative-type-checkbox').on 'ifUnchecked', ->
      self.handleRemoveFilterBuilder(self.QUANTITATIVE_TRANSLATE, self.QUANTITATIVE_TRANSLATE)

  handleRemoveFilterBuilder: (resourceName, resourcelabel, elementBuilder = @builderId) ->
    self = @
    filterSelects = $('.main-report-builder .rule-container .rule-filter-container select')
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
    $(@builderId).queryBuilder('removeFilter', values)
    @initSelect2()

  ######################################################################################
  handleShowCustomFormSelect: ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show()
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  customFormSelectChange: ->
    self = @
    $('.custom-form-wrapper select').on 'select2-selecting', (element) ->
      self.customFormSelected.push(element.val)
      # $('#community_advanced_search_custom_form_selected').val(element.val)
      self.addCustomBuildersFields(element.val, self.CUSTOM_FORM_URL)

  addCustomBuildersFields: (ids, url, loader=undefined) ->
    self = @
    action  = _.last(url.split('/'))
    controllerName = url.split('/')[2]
    element = if action == 'get_custom_field' then '.main-report-builder .custom-form-column' else '.main-report-builder .program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response[controllerName]
        $(self.builderId).queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)
        loader.stop() if loader
        return

  addFieldToColumnPicker: (element, fieldList) ->
    self = @
    customFormColumnPicker = $("#{element} ul.append-child")
    fieldsGroupByOptgroup = _.groupBy(fieldList, 'optgroup')
    _.forEach fieldsGroupByOptgroup, (values, key) ->
      headerClass = self.formBuiderFormatHeader(key)
      $(customFormColumnPicker).append("<li class='dropdown-header #{headerClass}'>#{key}</li>")
      _.forEach values, (value) ->
        fieldName = value.id
        keyword   = _.first(fieldName.split('__'))
        checkField  = fieldName
        label       = value.label
        $(customFormColumnPicker).append(self.checkboxElement(checkField, headerClass, label))

      $("input.i-checks.#{headerClass}").iCheck
        checkboxClass: 'icheckbox_square-green'

    return

  formBuiderFormatHeader: (value) ->
    keyWords = value.split('|')
    name = _.first(keyWords).trim()
    label = _.last(keyWords).trim()
    combine = "#{name} #{label}"
    @formatSpecialCharacter(combine)

  checkboxElement: (field, name, label) ->
    "<li class='visibility checkbox-margin #{name}'>
      <input type='checkbox' name='#{field}_' id='#{field}_' value='#{field}' class='i-checks #{name}' style='position: absolute; opacity: 0;'>
      <label for='#{field}_'>#{label}</label>
    </li>"

  customFormSelectRemove: ->
    self = @
    $('.main-report-builder .custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      formTitle   = removeValue.trim()
      formTitle   = self.formatSpecialCharacter("#{formTitle} Custom Form")

      self.removeCheckboxColumnPicker('.main-report-builder .custom-form-column', formTitle)
      $.map self.customFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.customFormSelected.splice(i, 1)

      self.handleRemoveFilterBuilder(removeValue, self.CUSTOM_FORM_TRANSLATE)

  handleHideCustomFormSelect: ->
    self = @
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      $('.custom-form-column ul.append-child li').remove()

      $('select.custom-form-select option:selected').each ->
        formTitle = $(@).text()
        self.handleRemoveFilterBuilder(formTitle, self.CUSTOM_FORM_TRANSLATE)

      self.customFormSelected = []
      $('select.custom-form-select').select2('val', '')
      $('.custom-form').hide()

  handleSelectOptionChange: (obj)->
    self = @
    if obj != undefined
      rowBuilderRule = obj.$el[0]
      ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
      $(ruleFiltersSelect).on 'select2-close', ->
        ruleParentId = $(@).closest("div[id^='builder_rule']").attr('id')
        setTimeout ( ->
          $("##{ruleParentId} .rule-operator-container select, .rule-value-container select").select2(width: 'resolve')
          self.initRuleOperatorSelect2(rowBuilderRule)
        )

  addRuleCallback: ->
    self = @
    $(@builderId).on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
      self.initSelect2()
      self.handleSelectOptionChange(obj)

  #======================================Handle Search================================

  handleSearch: ->
    self = @
    $('#search').on 'click', ->
      basicRules = $(self.builderId).queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      customFormValues = "[#{$('#community-advanced-search').find('#custom-form-select').select2('val')}]"
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"

      $('#community_advanced_search_custom_form_selected').val(customFormValues)
      if $('#quantitative-type-checkbox').prop('checked') then $('#community_advanced_search_quantitative_check').val(1)

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $(self.builderId).find('.has-error').removeClass('has-error')
        $('#community_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  handleStringfyRules: (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  handleSelectFieldVisibilityCheckBox: (builder = '.main-report-builder')->
    checkedFields = $(builder).find('.visibility .checked input, .all-visibility .checked input')
    $('form#advanced-search').append(checkedFields)
