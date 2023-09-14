class CIF.ClientAdvanceSearch
  constructor: () ->
    @filterTranslation   = ''
    @customFormSelected  = []
    @programSelected     = []
    @assessmentSelected  = ''
    optionTranslation    = $('#opt-group-translation')

    @enrollmentCheckbox  = $('#enrollment-checkbox')
    @trackingCheckbox    = $('#tracking-checkbox')
    @exitCheckbox        = $('#exit-form-checkbox')
    @wizardEnrollmentCheckbox    = $('#wizard-enrollment-checkbox')
    @wizardTrackingCheckbox      = $('#wizard-tracking-checkbox')
    @wizardExitCheckbox          = $('#wizard-exit-form-checkbox')

    @CUSTOM_FORM_URL      = '/api/client_advanced_searches/get_custom_field'
    @ENROLLMENT_URL       = '/api/client_advanced_searches/get_enrollment_field'
    @TRACKING_URL         = '/api/client_advanced_searches/get_tracking_field'
    @EXIT_PROGRAM_URL     = '/api/client_advanced_searches/get_exit_program_field'
    @PROGRAM_STREAM_URL   = '/api/client_advanced_searches/get_program_stream_search_field'

    @DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
    @BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
    @CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')

    @ENROLLMENT_TRANSLATE     = $(optionTranslation).data('enrollment')
    @TRACKING_TRANSTATE       = $(optionTranslation).data('tracking')
    @EXIT_PROGRAM_TRANSTATE   = $(optionTranslation).data('exitProgram')

    @QUANTITATIVE_TRANSLATE   = $(optionTranslation).data('quantitative')
    @HOTLINE_TRANSLATE   = optionTranslation.data('hotline')
    @CONCERN_BASIC_FIELDS   = optionTranslation.data('concern-basic-fields')
    loaderButton = document.querySelector('.ladda-button-columns-visibility')
    @LOADER = Ladda.create(loaderButton) if loaderButton

  setValueToBuilderSelected: ->
    @customFormSelected = $('#custom-form-data').data('value')
    @programSelected    = $('#program-stream-data').data('value')
    @assessmentSelected = $('#assessment-form-data').data('value')
    @wizardCustomFormSelected = $('#wizard-custom-form-data').data('value')
    @wizardProgramSelected    = $('#wizard-program-stream-data').data('value')

  getTranslation: ->
    @filterTranslation =
      addCustomGroup: $('#builder').data('filter-translation-add-custom-group')
      addFilter: $('#builder, #wizard-builder').data('filter-translation-add-filter')
      addGroup: $('#builder, #wizard-builder').data('filter-translation-add-group')
      deleteGroup: $('#builder, #wizard-builder').data('filter-translation-delete-group')

  formatSpecialCharacter: (value) ->
    filedName = value.toLowerCase().replace(/[^a-zA-Z0-9]+/gi, ' ').trim() || value.trim()
    filedName.replace(/ /g, '__')

  removeCheckboxColumnPicker: (element, name) ->
    $("#{element} ul.append-child li.#{name}").remove()

  filterSelectChange: ->
    self = @
    $('.rule-filter-container select').on 'select2-close', ->
      ruleParentId = $(@).closest("div[id^='builder_rule']").attr('id')
      setTimeout ( ->
        $("##{ruleParentId} .rule-operator-container select, .rule-value-container select").select2(width: 'resolve')
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
    # builderFields = $('#client-builder-fields').data('fields')
    if $('#wizard-builder').length > 0
      advanceSearchWizardBuilder = new CIF.AdvancedFilterBuilder($('#wizard-builder'), builderFields, @filterTranslation)
      advanceSearchWizardBuilder.initRule()
      @.initRuleOperatorSelect2($('#wizard-builder'))

    advanceSearchBuilder = new CIF.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
    advanceSearchBuilder.initRule()
    advanceSearchBuilder.setRuleFromSavedSearch()
    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($('#builder'))


  initSelect2: ->
    $('#custom-form-select, #wizard-custom-form-select, #program-stream-select, #wizard-program-stream-select, #quantitative-case-select').select2()
    $('#builder select').select2()
    $('#assessment-select').select2()

    $('#wizard-builder select').select2()
    setTimeout ( ->
      ids = ['#custom-form-select', '#wizard-custom-form-select', '#program-stream-select', '#wizard-program-stream-select', '#quantitative-case-select', '#wizard-builder', '#builder', '#assessment-select']
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

    self = @

    $('#assessment-select').on 'change', (e)->
      $(".assessment-data-dropdown li").addClass("hide")
      self.showAssessmentColumns("")

      value = $('#assessment-select').select2('data') && $('#assessment-select').select2('data').id
      $(".assessment-data-dropdown li.csi-#{value}").removeClass("hide")
      $("input[id$='_advanced_search_assessment_selected']").val("[#{value}]")

      self.showAssessmentColumns($('#assessment-select option:selected').data("selectGroup")) 

      unless $("#assessment-checkbox").is(":checked")
        $(".assessment-data-dropdown li").addClass("hide")
        $("input[id$='_advanced_search_assessment_selected']").val("[]")
        self.showAssessmentColumns("")

    $('#assessment-select').trigger('change')

  showAssessmentColumns: (sectionText) ->
    self = @

    # Toggle domain score fields
    $.each $('#assessment-select option'), (index, item) ->
      $options = $("optgroup[label='#{$(item).data("selectGroup")}'] option")

      if $(item).data("selectGroup") == sectionText
        $options.attr("disabled", false)
      else
        $options.attr("disabled", "disabled")

    # Toggle custom assessment fields
    $options = $("optgroup[label='Custom Assessment'] option")
    
    if sectionText != undefined && sectionText.indexOf(" | ") > -1
      $options.attr("disabled", false)
    else
      $options.attr("disabled", "disabled")

    $('#builder select').select2(width: '250px')

    $('#builder select').on 'select2-open', (e)->
      setTimeout ( ->
        self.hideDisabledGroup()
      ), 50


  hideDisabledGroup: ->
    $(".select2-result-with-children").each ->
      $(@).hide() if $(@).find(".select2-disabled").length > 0

  basicFilterSetRule: ->
    self = @
    basicQueryRules = $('#builder').data('basic-search-rules')
    wizardBasicQueryRules = $('#wizard-builder').data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      self.handleAddHotlineFilter()
      console.log(basicQueryRules, 'basic query')
      $('#builder').queryBuilder('setRules', basicQueryRules)
    unless wizardBasicQueryRules == undefined or _.isEmpty(wizardBasicQueryRules.rules)
      $('#wizard-builder').queryBuilder('setRules', wizardBasicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

  ######################################################################################################################

  customFormSelectChange: ->
    self = @
    $('.main-report-builder .custom-form-wrapper select').on 'select2-selecting', (element) ->
      self.customFormSelected.push(element.val)
      self.addCustomBuildersFields(element.val, self.CUSTOM_FORM_URL)

    $('#report-builder-wizard .custom-form-wrapper select').on 'select2-selecting', (element) ->
      $('#custom-form-column').addClass('hidden')
      $('#wizard-custom-form .loader').removeClass('hidden')
      self.wizardCustomFormSelected.push(element.val)
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(element.val, self.CUSTOM_FORM_URL)
      $.when(addCustomBuildersFields).then ->
        $('#custom-form-column').removeClass('hidden')
        $('#wizard-custom-form .loader').addClass('hidden')

  assessmentSelectChange: ->
    self = @
    assessmentSelectValue = $('#assessment-select').find(':selected').val()
    $("div[data-custom-assessment-setting-id='#{assessmentSelectValue}']").show() if $("#assessment-checkbox").is(":checked")
    
    $('.main-report-builder .assessment-form-wrapper select').on 'select2-selecting', (element) ->
      $(".custom-assessment-setting").hide()
      $(".custom-assessment-setting input[type='checkbox']").iCheck("uncheck")
      $("div[data-custom-assessment-setting-id='#{element.val}']").show()

  addCustomBuildersFields: (ids, url, loader=undefined) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '.main-report-builder .custom-form-column' else '.main-report-builder .program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        $('#builder').queryBuilder('addFilter', fieldList)
        self.initSelect2()
        self.addFieldToColumnPicker(element, fieldList)
        loader.stop() if loader
        return

  addCustomBuildersFieldsInWizard: (ids, url) ->
    self = @
    action  = _.last(url.split('/'))
    element = if action == 'get_custom_field' then '#report-builder-wizard .custom-form-column' else '#report-builder-wizard .program-stream-column'
    $.ajax
      url: url
      data: { ids: ids }
      method: 'GET'
      success: (response) ->
        fieldList = response.client_advanced_searches
        if (element == '#report-builder-wizard .custom-form-column' && $('#wizard_custom_form_filter').is(':checked')) || (element == '#report-builder-wizard .program-stream-column' && $('#wizard_program_stream_filter').is(':checked'))
          $('#wizard-builder').queryBuilder('addFilter', fieldList)
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

  handleHideCustomFormSelect: ->
    self = @
    $('#custom-form-checkbox').on 'ifUnchecked', ->
      $('.custom-form-column ul.append-child li').remove()

      # $('#custom-form-select option:selected, #wizard-custom-form-select option:selected').each ->
      $('select.custom-form-select option:selected').each ->
        formTitle = $(@).text()
        self.handleRemoveFilterBuilder(formTitle, self.CUSTOM_FORM_TRANSLATE)

      self.customFormSelected = []
      # $('.custom-form select').select2('val', '')
      $('select.custom-form-select').select2('val', '')
      $('.custom-form').hide()

  handleShowCustomFormSelect: ->
    if $('#custom-form-checkbox').prop('checked')
      $('.custom-form').show()
    $('#custom-form-checkbox').on 'ifChecked', ->
      $('.custom-form').show()

  handleHideAssessmentSelect: ->
    self = @
    $('#assessment-checkbox').on 'ifUnchecked', ->
      ruleFiltersSelect = $('.main-report-builder .rule-container .rule-filter-container select')
      ruleFiltersSelect.select2('destroy')
      ruleFiltersSelect.parents('.rule-container').find('.rule-header button').trigger('click')

      $(".custom-assessment-setting input[type='checkbox']").iCheck("uncheck")
      $('.assessment-column a.dropdown-toggle').addClass('disabled')

      $(".custom-assessment-setting").hide()

      $('.assessment-form').hide()
      $('#builder').queryBuilder('removeFilter', ['assessment_condition_last_two','assessment_condition_first_last'])
      $('button[data-add="rule"]').trigger('click')
      
      return

  handleShowAssessmentSelect: ->
    self = @
    if $('#assessment-checkbox').prop('checked')
      $('.assessment-form').show()

    $('#assessment-checkbox').on 'ifChecked', ->
      $('.assessment-form').show()
      assessmentSelectValue = $('#assessment-select').find(':selected').val()

      $('.assessment-column a.dropdown-toggle').removeClass('disabled')
      # self.initSelect2()

      $("div[data-custom-assessment-setting-id='#{assessmentSelectValue}']").show()
      self.assessmentSelected = $('select.assessment-select').val()
      $.ajax
        url: self.PROGRAM_STREAM_URL
        data: { assesment_checked: true }
        method: 'GET'
        success: (response) ->
          fieldList = response.client_advanced_searches
          $('#builder').queryBuilder('addFilter', fieldList)
          self.initSelect2()
          return

  ######################################################################################################################

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

    $('#report-builder-wizard .custom-form-wrapper select').on 'select2-removed', (element) ->
      removeValue = element.choice.text
      formTitle   = removeValue.trim()
      formTitle   = self.formatSpecialCharacter("#{formTitle} Custom Form")

      self.removeCheckboxColumnPicker('#report-builder-wizard .custom-form-column', formTitle)
      $.map self.wizardCustomFormSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.wizardCustomFormSelected.splice(i, 1)

      if $('#wizard_custom_form_filter').is(':checked')
        self.handleRemoveFilterBuilder(removeValue, self.CUSTOM_FORM_TRANSLATE, '#wizard-builder')

  assessmentSelectRemove: ->
    self = @
    $('.main-report-builder .assessment-form-wrapper select').on 'select2-removed', (element) ->
      $(".custom-assessment-setting").hide()
      $.map self.assessmentSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.assessmentSelected.splice(i, 1)

  removeActiveClientProgramOption: ->
    $('.main-report-builder .rule-container .rule-filter-container select').select2('destroy')
    $('.main-report-builder .rule-container').find('.rule-header button').trigger('click')
    $('button[data-add="rule"]').trigger('click')
    $('#builder').queryBuilder('removeFilter', ['active_client_program'])
    @.initSelect2()

  handleRemoveFilterBuilder: (resourceName, resourcelabel, elementBuilder = '#builder') ->
    self = @
    if elementBuilder == '#builder'
      filterSelects = $('.main-report-builder .rule-container .rule-filter-container select')
    else
      filterSelects = $('#report-builder-wizard .rule-container .rule-filter-container select')
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
    $('#wizard-builder').queryBuilder('removeFilter', values) if $('#wizard-builder').length > 0
    @initSelect2()

  ######################################################################################################################

  handleShowProgramStreamFilter: ->
    self = @
    if $('.main-report-builder #program-stream-checkbox').prop('checked')
      $('.main-report-builder .program-stream').show()
    if self.enrollmentCheckbox.prop('checked') || self.trackingCheckbox.prop('checked') || self.exitCheckbox.prop('checked') || self.programSelected.length > 0
      $('.main-report-builder .program-association').show()
    if self.wizardEnrollmentCheckbox.prop('checked') || self.wizardTrackingCheckbox.prop('checked') || self.wizardExitCheckbox.prop('checked') || self.wizardProgramSelected.length > 0
      $('#report-builder-wizard .program-association').show()
    $('.main-report-builder #program-stream-checkbox').on 'ifChecked', ->
      $('.main-report-builder .program-stream').show()

  handleFamilyShowProgramStreamFilter: ->
    self = @
    if $('.main-report-builder #program-stream-checkbox').prop('checked')
      $('.main-report-builder .program-stream').show()
    if self.enrollmentCheckbox.prop('checked') || self.trackingCheckbox.prop('checked') || self.exitCheckbox.prop('checked') || self.programSelected.length > 0
      $('.main-report-builder .program-association').show()
    $('.main-report-builder #program-stream-checkbox').on 'ifChecked', ->
      $('.main-report-builder .program-stream').show()

  handleHideProgramStreamSelect: ->
    self = @
    $('.main-report-builder .program-stream-checkbox').on 'ifUnchecked', ->
      $('.main-report-builder .program-stream-column ul.append-child li').remove()
      self.programSelected = []
      $('.main-report-builder .program-association, .main-report-builder .program-stream').hide()
      $('.main-report-builder .program-association input[type="checkbox"]').iCheck('uncheck')
      $('.main-report-builder select.program-stream-select').select2("val", "")
      self.removeActiveClientProgramOption()

  handleProgramSelectChange: ->
    self = @
    $('.main-report-builder select.program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.programSelected.push programId
      $('.main-report-builder .program-association').show()
      if self.programSelected.length == 1
        self.addCustomBuildersFields(self.programSelected, self.PROGRAM_STREAM_URL, self.LOADER)

      if $('#enrollment-checkbox').is(':checked')
        self.LOADER.start()
        self.addCustomBuildersFields(programId, self.ENROLLMENT_URL, self.LOADER)
      if $('#tracking-checkbox').is(':checked')
        self.LOADER.start()
        self.addCustomBuildersFields(programId, self.TRACKING_URL, self.LOADER)

      if $('#exit-form-checkbox').is(':checked')
        self.LOADER.start()
        self.addCustomBuildersFields(programId, self.EXIT_PROGRAM_URL, self.LOADER)

    $('#report-builder-wizard select.program-stream-select').on 'select2-selecting', (psElement) ->
      programId = psElement.val
      self.wizardProgramSelected.push programId
      $('#report-builder-wizard .program-association').show()
      if $('#wizard-enrollment-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.ENROLLMENT_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

      if $('#wizard-tracking-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.TRACKING_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

      if $('#wizard-exit-form-checkbox').is(':checked')
        $('#program-stream-column').addClass('hidden')
        $('#wizard-program-stream .loader').removeClass('hidden')
        addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(programId, self.EXIT_PROGRAM_URL)
        $.when(addCustomBuildersFields).then ->
          $('#program-stream-column').removeClass('hidden')
          $('#wizard-program-stream .loader').addClass('hidden')

  triggerEnrollmentInWizard: ->
    self = @
    $('#wizard-enrollment-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.ENROLLMENT_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerTrackingInWizard: ->
    self = @
    $('#wizard-tracking-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.TRACKING_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerExitProgramInWizard: ->
    self = @
    $('#wizard-exit-form-checkbox').on 'ifChecked', ->
      $('#program-stream-column').addClass('hidden')
      $('#wizard-program-stream .loader').removeClass('hidden')
      addCustomBuildersFields = self.addCustomBuildersFieldsInWizard(self.wizardProgramSelected, self.EXIT_PROGRAM_URL)
      $.when(addCustomBuildersFields).then ->
        $('#program-stream-column').removeClass('hidden')
        $('#wizard-program-stream .loader').addClass('hidden')

  triggerEnrollmentFields: ->
    self = @
    $('#enrollment-checkbox').on 'ifChecked', ->
      self.LOADER.start()
      self.addCustomBuildersFields(self.programSelected, self.ENROLLMENT_URL, self.LOADER)
    return

  triggerTrackingFields: ->
    self = @
    $('#tracking-checkbox').on 'ifChecked', ->
      self.LOADER.start()
      self.addCustomBuildersFields(self.programSelected, self.TRACKING_URL, self.LOADER)
    return

  triggerExitProgramFields: ->
    self = @
    $('#exit-form-checkbox').on 'ifChecked', ->
      self.LOADER.start()
      self.addCustomBuildersFields(self.programSelected, self.EXIT_PROGRAM_URL, self.LOADER)
    return

  addgroupCallback: ->
    self = @

    $('#builder').on 'click', '.btn-custom-group', (e) ->
      csiDomainScoresTranslate  = $('#hidden_csi_domain_scores').val()
      builder     = $('#builder')
      root        = builder.queryBuilder 'getModel'
      group       = builder.queryBuilder('addGroup', root, false, false, {no_add_group: true, condition_readonly: true})

      groupId     = "##{group.id}"
      localStorage.setItem("#{group.id}", group.id)
      window.customGroup["#{group.id}"] = group
      $(groupId).addClass('csi-group')
      $('.csi-group .group-conditions .btn-primary').attr('disabled', 'disabled')

      rule      = builder.queryBuilder('addRule', group)
      rule1     = builder.queryBuilder('addRule', group)
      rule2     = builder.queryBuilder('addRule', group)
      rule.filter     = builder.queryBuilder('getFilterById', $('select [label="' + csiDomainScoresTranslate + '"] [value^="domainscore"]').val()) if $('select [label="' + csiDomainScoresTranslate + '"] [value^="domainscore"]').val()
      rule.value      = ''
      rule1.filter    = builder.queryBuilder('getFilterById', 'assessment_number')
      rule2.filter    = builder.queryBuilder('getFilterById', 'assessment_completed')
      rule2.operator  = builder.queryBuilder('getOperatorByType', 'between')
      _changeOperator()

  handleCsiAfterSearch: ->
    $('#builder_group_0').removeClass('csi-group')
    $('.csi-group .group-conditions .btn-primary:nth-child(2)').addClass('hide')

    select2Csi = '.csi-group .rules-list .rule-container:nth-child(1) .rule-operator-container > select'
    $(document).on 'change', select2Csi, (param)->
      group       = window.customGroup[$(this).closest('.csi-group').attr('id')]
      unless _.includes(param.val, 'has_changed') || _.includes(param.val, 'has_not_changed')
        if $(@).closest('.rule-container').siblings().length < 2 && $("##{group.id} option[value='assessment_completed']:selected").length
          builder     = $('#builder')
          rule        = builder.queryBuilder('addRule', group)
          rule.filter = builder.queryBuilder('getFilterById', 'assessment_number')
          wrapper = $('.csi-group .rules-list')
          items = wrapper.children('.rule-container')
          arr = [0, 2, 1]
          wrapper.append $.map(arr, (v) ->
            items[v]
          )

          _changeOperator()
          $(this).closest('.rule-container').find('.rule-value-container').find('.select2-container select')
      else
        if $(@).closest('.rule-container').siblings().length > 1
          $(@).closest('.rules-list').find('.rule-container:nth-child(2) .rule-actions').children().click()
        else
          $(@).closest('.rules-list').find('.rule-container:nth-child(2) .rule-actions').children().click()
          builder     = $('#builder')
          group       = window.customGroup[$(this).closest('.csi-group').attr('id')]
          rule        = builder.queryBuilder('addRule', group)
          rule.filter = builder.queryBuilder('getFilterById', 'assessment_completed')


        $(this).closest('.rule-container').find('.rule-value-container').find('.select2-container').remove()
        $(this).closest('.rule-container').find('.rule-value-container').find('input').show()
    if $('option[value*="has_changed"]:selected').length < 1 || $('option[value*="has_not_changed"]:selected').length < 1

      _changeOperator()
      $('option[value*="assessment_completed"]:selected').closest('.rule-container').find('.rule-value-container').find('.select2-container').remove()
      $('option[value*="assessment_completed"]:selected').closest('.rule-container').find('.rule-value-container').find('input').show()
      $('option[value*="has_changed"]:selected').closest('.rule-container').find('.rule-value-container').find('.select2-container').remove()
      $('option[value*="has_not_changed"]:selected').closest('.rule-container').find('.rule-value-container').find('.select2-container').remove()
      $('option[value*="has_changed"]:selected').closest('.rule-container').find('.rule-value-container').find('input').show()
      $('option[value*="has_not_changed"]:selected').closest('.rule-container').find('.rule-value-container').find('input').show()

  ######################################################################################################################
  _changeOperator = ->
    klasses = '.csi-group .rule-container:nth-child(1) .rule-value-container input.form-control'
    data = [
      {
        id: 1
        tag: '1'
      }
      {
        id: 2
        tag: '2'
      }
      {
        id: 3
        tag: '3'
      }
      {
        id: 4
        tag: '4'
      }
    ]
    if $(klasses).length
      $(klasses).select2
        data:
          results: data
          text: 'tag'
        formatSelection: (item) ->
          item.tag
        formatResult: (item) ->
          item.tag
      $('.rule-container:nth-child(1) .rule-value-container .select2-container').attr("style", "width: 180px;")

  handleRule2SelectChange: ->
    self = @
    dateOfAssessmentTranslate = $('#hidden_date_of_assessments').val()
    select2Csi = '.csi-group .rules-list .rule-container:nth-child(2) .rule-filter-container > select'

    $(document).on 'change', select2Csi, (e)->
      if e.val == 'date_nearest'
        $(@).closest('.rules-list').find('.rule-container:nth-child(3) .rule-actions').children().click()
      else
        if $(@).closest('.rule-container').siblings().length < 2
          builder     = $('#builder')
          group       = window.customGroup[$(@).closest('.csi-group').attr('id')]
          rule        = builder.queryBuilder('addRule', group)
          rule.filter = builder.queryBuilder('getFilterById', 'assessment_completed')
          rule.operator  = builder.queryBuilder('getOperatorByType', 'between')

  hideCsiCustomGroupInRootBuilder: ->
    customCsiGroupTranslate   = $('#hidden_custom_csi_group').val()
    csiDomainScoresTranslate  = $('#hidden_csi_domain_scores').val()
    dateOfAssessmentTranslate = $('#hidden_date_of_assessments').val()
    select2Csi = '#builder_group_0 .rules-list .rule-container .rule-filter-container > select'
    wizardCsi  = '#report-builder-wizard-modal .rules-list .rule-container .rule-filter-container > select'

    $(document).on 'select2-open', select2Csi, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      $.each elements, (index, item) ->
        if item.firstElementChild.textContent == customCsiGroupTranslate
          $(item).hide()

    $(document).on 'select2-open', wizardCsi, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      $.each elements, (index, item) ->
        if item.firstElementChild.textContent == customCsiGroupTranslate
          $(item).hide()

    $(document).on 'select2-open', select2Csi, (e)->
      selectCsiGroup = '.csi-group .rules-list .rule-container:nth-child(2) .rule-filter-container > select'
      $(document).on 'select2-open', selectCsiGroup, (e)->
        elements = $('.select2-results .select2-results-dept-0')
        $.each elements, (index, item) ->
          if item.firstElementChild.textContent == customCsiGroupTranslate
            $(item).show()

  removeOperatorInWizardBuilder: ->
    $('#report-builder-wizard-modal .btn-custom-group').hide()
    $('#wizard-builder').on 'afterAddGroup.queryBuilder', (parent, addRule, level) ->
      $('#report-builder-wizard-modal .btn-custom-group').hide()

    wizardFilter   = '#report-builder-wizard-modal .rules-list .rule-container .rule-filter-container > select'
    wizardOperator = '#report-builder-wizard-modal .rules-list .rule-container .rule-operator-container > select'
    $(document).on 'select2-selected', wizardFilter, (e)->
      setTimeout (->
        $(wizardOperator).select2(width: 'resolve')
      ),
    $(document).on 'select2-open', wizardOperator, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      $.each elements, (index, item) ->
        if item.textContent.match(/has.*change|average/g)
          $(item).hide()

  handleCsiSelectOption: ->
    assessmentNumberTranslate = $('#hidden_assessment_number').val()
    customCsiGroupTranslate   = $('#hidden_custom_csi_group').val()
    monthNumberTranslate      = $('#hidden_month_number').val()
    dateOfAssessmentTranslate = $('#hidden_date_of_assessments').val()
    csiDomainScoresTranslate  = $('#hidden_csi_domain_scores').val()
    customCsiDomainScoresTranslate = $('#hidden_custom_csi_domain_scores').val()

    select2Csi = '.csi-group .rules-list .rule-container:nth-child(1) .rule-filter-container > select'
    $(document).on 'select2-open', select2Csi, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      handleCsiOption(elements, "#{csiDomainScoresTranslate}-#{customCsiDomainScoresTranslate}")

    select2Csi = '.csi-group .rules-list .rule-container:nth-child(2) .rule-filter-container > select'
    $(document).on 'select2-open', select2Csi, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      handleCsiOption(elements, customCsiGroupTranslate, 'second-child')

    select2Csi = '.csi-group .rules-list .rule-container:nth-child(3) .rule-filter-container > select'
    $(document).on 'select2-open', select2Csi, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      handleCsiOption(elements, customCsiGroupTranslate, 'third-child')

  handleAllDomainOperatorOpen: ->
    select2Csi = '.csi-group .rules-list .rule-container:nth-child(1) .rule-operator-container > select'
    $(document).on 'select2-open', select2Csi, (e)->
      group = window.customGroup[$(@).closest('.csi-group').attr('id')]
      if $("##{group.id} option[value='all_domains']:selected").length > 0 || $("##{group.id} option[value='all_custom_domains']:selected").length > 0
        elements = $('.select2-results .select2-results-dept-0')
        $.each elements, (index, item) ->
          if item.textContent.match(/has.*change|between/g)
            $(item).hide()

  handleCsiOption = (elements, group, nthChild = undefined) ->
    customCsiGroupTranslate   = $('#hidden_custom_csi_group').val()
    dateOfAssessmentTranslate = $('#hidden_date_of_assessments').val()
    csiDomainScoresTranslate  = $('#hidden_csi_domain_scores').val()
    customCsiDomainScoresTranslate = $('#hidden_custom_csi_domain_scores').val()
    group = group.split('-')

    $.each elements, (index, item) ->
      last_children = $(item).children().last().children()
      if item.firstElementChild.textContent == customCsiGroupTranslate && nthChild == 'second-child'
        $.each last_children, (index, el) ->
          if el.firstElementChild.textContent == 'Assessment Completed'
            $(el).hide()

        $.each last_children, (index, el) ->
          if $('option[value*="has_changed"]:selected').length > 0 || $('option[value*="has_not_changed"]:selected').length > 0
            if el.firstElementChild.textContent != 'Assessment Completed'
              $(el).hide()
            if el.firstElementChild.textContent == 'Assessment Completed'
              $(item).addClass('hidden')
      if item.firstElementChild.textContent == customCsiGroupTranslate && nthChild == 'third-child'
        $.each $(item).children().last().children(), (index, el) ->
          if el.firstElementChild.textContent != 'Assessment Completed'
            $(el).hide()
      if item.firstElementChild.textContent != group[0] and item.firstElementChild.textContent != group[1]
        $(item).hide()
      if item.firstElementChild.textContent == csiDomainScoresTranslate
        $.each last_children, (index, el) ->
          if el.firstElementChild.textContent == dateOfAssessmentTranslate
            $(el).hide()
      if item.firstElementChild.textContent == 'Custom Domain Scores'
        $.each last_children, (index, el) ->
          if el.firstElementChild.textContent == 'Date of Custom Assessments'
            $(el).hide()

  hideAverageFromIndividualDomainScore: ->
    select2Operator = '.csi-group .rules-list .rule-container:nth-child(1) .rule-operator-container > select'
    $(document).on 'select2-open', select2Operator, (e)->
      elements = $('.select2-results .select2-results-dept-0')
      if $(this.parentElement.parentElement).find('.rule-filter-container').find('option[value="all_domains"]:selected').length == 0 and $(this.parentElement.parentElement).find('.rule-filter-container').find('option[value="all_custom_domains"]:selected').length == 0
        $.each elements, (index, item) ->
          if item.firstElementChild.textContent == 'average'
            $(item).hide()
      else
        $.each elements, (index, item) ->
          if item.firstElementChild.textContent == 'average'
            $(item).show()

  handleSelect2RemoveProgram: ->
    self = @
    programStreamKeyword = ['Enrollment', 'Tracking', 'Exit Program']
    $('.main-report-builder .program-stream-select').on 'select2-removed', (element) ->
      programName = element.choice.text
      self.removeCheckboxColumnPickers(programStreamKeyword, programName, self)

      $.map self.programSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.programSelected.splice(i, 1)

      self.handleRemoveFilterBuilder(programName, self.ENROLLMENT_TRANSLATE)
      self.handleRemoveFilterBuilder(programName, self.TRACKING_TRANSTATE)
      self.handleRemoveFilterBuilder(programName, self.EXIT_PROGRAM_TRANSTATE)
      if $.isEmptyObject($(@).val())
        programStreamAssociation = $('.main-report-builder .program-association')
        $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
        $(programStreamAssociation).hide()

      if self.programSelected.length == 0
        self.removeActiveClientProgramOption()

    $('#report-builder-wizard .program-stream-select').on 'select2-removed', (element) ->
      programName = element.choice.text
      self.removeCheckboxColumnPickers(programStreamKeyword, programName, self)

      $.map self.wizardProgramSelected, (val, i) ->
        if parseInt(val) == parseInt(element.val) then self.wizardProgramSelected.splice(i, 1)
      if $('#wizard_program_stream_filter').is(':checked')
        self.handleRemoveFilterBuilder(programName, self.ENROLLMENT_TRANSLATE, '#wizard-builder')
        self.handleRemoveFilterBuilder(programName, self.TRACKING_TRANSTATE, '#wizard-builder')
        self.handleRemoveFilterBuilder(programName, self.EXIT_PROGRAM_TRANSTATE, '#wizard-builder')
      if $.isEmptyObject($(@).val())
        programStreamAssociation = $('#report-builder-wizard .program-association')
        $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
        $(programStreamAssociation).hide()

  removeCheckboxColumnPickers: (keyWords, programName, self)->
    _.forEach keyWords, (value) ->
      headerClass = self.formatSpecialCharacter("#{programName.trim()} #{value}")
      self.removeCheckboxColumnPicker('#report-builder-wizard #program-stream-column', headerClass)

  handleUncheckedEnrollment: ->
    self = @
    $('#enrollment-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Enrollment")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.ENROLLMENT_TRANSLATE)

    $('#wizard-enrollment-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Enrollment")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.ENROLLMENT_TRANSLATE)

  handleUncheckedTracking: ->
    self = @
    $('#tracking-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Tracking")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.TRACKING_TRANSTATE)

    $('#wizard-tracking-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Tracking")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.TRACKING_TRANSTATE)

  handleUncheckedExitProgram: ->
    self = @
    $('#exit-form-checkbox').on 'ifUnchecked', ->
      for option in $('.main-report-builder select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Exit Program")

        self.removeCheckboxColumnPicker('.main-report-builder .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.EXIT_PROGRAM_TRANSTATE)

    $('#wizard-exit-form-checkbox').on 'ifUnchecked', ->
      for option in $('#report-builder-wizard select.program-stream-select option:selected')
        name          = $(option).text()
        programName   = name.trim()
        headerClass   = self.formatSpecialCharacter("#{programName} Exit Program")

        self.removeCheckboxColumnPicker('#report-builder-wizard .program-stream-column', headerClass)
        self.handleRemoveFilterBuilder(name, self.EXIT_PROGRAM_TRANSTATE)

  ######################################################################################################################

  handleAddQuantitativeFilter: ->
    self = @
    fields = $('#quantitative-fields').data('fields')
    $('#quantitative-type-checkbox').on 'ifChecked', ->
      $('#builder').queryBuilder('addFilter', fields) if $('#builder:visible').length > 0
      $('#wizard-builder').queryBuilder('addFilter', fields) if $('#wizard-builder:visible').length > 0
      self.initSelect2()

  handleRemoveQuantitativFilter: ->
    self = @
    $('#quantitative-type-checkbox').on 'ifUnchecked', ->
      self.handleRemoveFilterBuilder(self.QUANTITATIVE_TRANSLATE, self.QUANTITATIVE_TRANSLATE)

  handleHotlineFilter: ->
    self = @
    fields = $('#hotline-fields').data('fields')
    $('#hotline-checkbox').off('ifChecked').on 'ifChecked', ->
      $('.hotline-call-column a.dropdown-toggle').removeClass('disabled')
      $('#builder').queryBuilder('addFilter', fields) if $('#builder:visible').length > 0
      # $('#wizard-builder').queryBuilder('addFilter', fields) if $('#wizard-builder:visible').length > 0
      self.initSelect2()

    $('#hotline-checkbox').off('ifUnchecked').on 'ifUnchecked', ->
      $('#client_advanced_search_hotline_check').val('')
      $('.hotline-call-column .i-checks').iCheck('uncheck')
      $('.hotline-call-column a.dropdown-toggle').addClass('disabled')
      self.handleRemoveFilterBuilder(self.CONCERN_BASIC_FIELDS, self.CONCERN_BASIC_FIELDS)
      self.handleRemoveFilterBuilder(self.HOTLINE_TRANSLATE, self.HOTLINE_TRANSLATE)
      return

  handleAddHotlineFilter: ->
    fields = $('#hotline-fields').data('fields')
    if $('#hotline-checkbox').is(':checked')
      $('#builder').queryBuilder('addFilter', fields)
      return
  ######################################################################################################################

  prepareSearchParams: (btnID) ->
    self = @

    if btnID == 'search'
      builderElement = '#builder'
      builderForm = '.main-report-builder'
      programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
    else
      builderElement = '#wizard-builder'
      builderForm = '#report-builder-wizard'
      programValues = if self.wizardProgramSelected.length > 0 then "[#{self.wizardProgramSelected}]"
      customFormValues = if self.wizardCustomFormSelected.length > 0 then "[#{self.wizardCustomFormSelected}]"

    basicRules = $(builderElement).queryBuilder('getRules', { skip_empty: true, allow_invalid: true })

    if $('#builder').queryBuilder('getSQL', false, true)
      sql_sting = $('#builder').queryBuilder('getSQL', false, true).sql
      $('#raw_sql').val(sql_sting)

    self.setValueToProgramAssociation()
    $('#client_advanced_search_custom_form_selected').val(customFormValues)
    $('#client_advanced_search_program_selected').val(programValues)

    if $('#quantitative-type-checkbox').prop('checked') then $('#client_advanced_search_quantitative_check').val(1)
    if $('#wizard_quantitative_filter').prop('checked') then $('#client_advanced_search_wizard_quantitative_check').val(1)
    if $('#wizard_custom_form_filter').prop('checked') then $('#client_advanced_search_wizard_custom_form_check').val(1)
    if $('#wizard_program_stream_filter').prop('checked') then $('#client_advanced_search_wizard_program_stream_check').val(1)
    if $('#wizard-enrollment-checkbox').prop('checked') then $('#client_advanced_search_wizard_enrollment_check').val(1)
    if $('#wizard-tracking-checkbox').prop('checked') then $('#client_advanced_search_wizard_tracking_check').val(1)
    if $('#wizard-exit-form-checkbox').prop('checked') then $('#client_advanced_search_wizard_exit_form_check').val(1)
    $('#client_advanced_search_action_report_builder, #family_advanced_search_action_report_builder').val(builderElement)

    if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
      $(builderElement).find('.has-error').removeClass('has-error')
      $('#client_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))

      true
    else
      false

  handleSearch: ->
    self = @
    $('#search, #wizard-search').on 'click', (e)->
      btnID = e.currentTarget.id

      if btnID == 'search'
        builderForm = '.main-report-builder'
      else
        builderForm = '#report-builder-wizard'

      if self.prepareSearchParams(btnID)
        self.handleSelectFieldVisibilityCheckBox(builderForm)
        $('#advanced-search').submit()


  prepareFamilySearch: ->
    self = @
    basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      # customFormValues = "[#{$('#family-advance-search-form').find('#custom-form-select').select2('val')}]"
    customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
    programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

    self.setValueToFamilyProgramAssociation()
    $('#family_advanced_search_custom_form_selected').val(customFormValues)
    $('#family_advanced_search_program_selected').val(programValues)
    if $('#quantitative-type-checkbox').prop('checked') then $('#family_advanced_search_quantitative_check').val(1)

    if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
      $('#builder').find('.has-error').removeClass('has-error')
      console.log(self.handleStringfyRules(basicRules))
      $('#family_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
      return true
    else
      return false

  handleFamilySearch: ->
    self = @

    $('#search').on 'click', ->
      if self.prepareFamilySearch()
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  handlePartnerSearch: ->
    self = @
    $('#search').on 'click', ->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      # customFormValues = "[#{$('#partner-advance-search-form').find('#custom-form-select').select2('val')}]"
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"

      $('#partner_advanced_search_custom_form_selected').val(customFormValues)

      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').removeClass('has-error')
        $('#partner_advanced_search_basic_rules').val(self.handleStringfyRules(basicRules))
        self.handleSelectFieldVisibilityCheckBox()
        $('#advanced-search').submit()

  setValueToProgramAssociation: ->
    enrollmentCheck = $('#client_advanced_search_enrollment_check')
    trackingCheck   = $('#client_advanced_search_tracking_check')
    exitFormCheck   = $('#client_advanced_search_exit_form_check')

    if @enrollmentCheckbox.is(":checked") || @wizardEnrollmentCheckbox.is(':checked') then $(enrollmentCheck).val(1)
    if @trackingCheckbox.is(":checked") || @wizardTrackingCheckbox.is(':checked') then $(trackingCheck).val(1)
    if @exitCheckbox.is(":checked") || @wizardExitCheckbox.is(':checked') then $(exitFormCheck).val(1)
    if ($('#hotline-checkbox').prop('checked')) then $('#client_advanced_search_hotline_check').val(1)

  setValueToFamilyProgramAssociation: ->
    enrollmentCheck = $('#family_advanced_search_enrollment_check')
    trackingCheck   = $('#family_advanced_search_tracking_check')
    exitFormCheck   = $('#family_advanced_search_exit_form_check')

    if @enrollmentCheckbox.is(":checked") then $(enrollmentCheck).val(1)
    if @trackingCheckbox.is(":checked") then $(trackingCheck).val(1)
    if @exitCheckbox.is(":checked") then $(exitFormCheck).val(1)

  handleStringfyRules: (rules) ->
    rules = JSON.stringify(rules)
    return rules.replace(/null/g, '""')

  handleSelectFieldVisibilityCheckBox: (builder = '.main-report-builder')->
    checkedFields = $(builder).find('.visibility .checked input, .all-visibility .checked input')
    $('form#advanced-search').append(checkedFields)

  ######################################################################################################################

  addRuleCallback: ->
    self = @
    $('#builder, #wizard-builder').on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
      self.initSelect2()
      self.handleSelectOptionChange(obj)
      self.referred_to_program()
      self.filterSelecting()

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

  referred_to_program: ->
    $('.rule-filter-container select').change ->
      selectedOption      = $(this).find('option:selected')
      selectedOptionValue = $(selectedOption).val()
      if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
        setTimeout ( ->
          $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
        ),10

  ######################################################################################################################
  filterSelecting: ->
    $(document).on 'select2-open', '.rule-value-container input.form-control', (e)->
      ruleParentElement = $(this.parentElement.parentElement)
      filterValue       = ruleParentElement.find('.rule-filter-container').find('option[value^="domainscore"]:selected')
      allDomainFilter   = ruleParentElement.find('.rule-filter-container').find('option[value="all_domains"]:selected')
      greaterOperator   = ruleParentElement.find('.rule-operator-container').find('option[value="greater"]:selected')
      lessOperator      = ruleParentElement.find('.rule-operator-container').find('option[value="less"]:selected')

      elements = $('.select2-results .select2-results-dept-0')
      $.each elements, (index, item) ->
        if (filterValue.length == 1 || allDomainFilter.length == 1) and greaterOperator.length == 1
          if item.textContent == '10'
            $(item).addClass('not-allowed')
        else if (filterValue.length == 1 || allDomainFilter.length == 1) and lessOperator.length == 1
          if item.textContent == '1'
            $(item).addClass('not-allowed')
      item = elements.name
      setTimeout( ->
        $("select[name='#{item}'], .rule-value-container select").select2(width: 'resolve')
      )

  disableOptions: ->
    $(document).on 'select2-selected', '.rule-operator-container select', (e)->
      ruleParentElement = $(this.parentElement.parentElement)
      schoolGradeFilter = ruleParentElement.find('.rule-filter-container').find('option[value="school_grade"]:selected')
      betweenOperator   = ruleParentElement.find('.rule-operator-container').find('option[value="between"]:selected')
      disableValue      = ['Kindergarten 1', 'Kindergarten 2', 'Kindergarten 3', 'Kindergarten 4', 'Year 1', 'Year 2', 'Year 3', 'Year 4', 'Year 5', 'Year 6', 'Year 7', 'Year 8']
      select            = ruleParentElement.find('.rule-value-container')

      if schoolGradeFilter.length == 1 and betweenOperator.length == 1
        setTimeout( ->
          for value in disableValue
            $(select).find("option[value='#{value}']").attr('disabled', 'disabled')

          first_value_option  = $(select).find('select:first').find(':selected').text()
          second_value_option = $(select).find('select:last').find(':selected').text()
          if disableValue.includes(first_value_option) && disableValue.includes(second_value_option)
            $(select).find('select').val('1').trigger('change')
        )
      setTimeout( ->
        $(".rule-value-container select").select2(width: 'resolve')
      )

  ######################################################################################################################

  handleSaveQuery: ->
    self = @
    $(document).on 'click',  '#submit-query', (e)->
      basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
      if basicRules.valid == false && basicRules.rules.length > 0
        e.preventDefault()
        $('#save-query').modal('hide')
      if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
        $('#builder').find('.has-error').removeClass('has-error')
      customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
      programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

      enrollmentCheck = $('#advanced_search_enrollment_check')
      trackingCheck   = $('#advanced_search_tracking_check')
      exitFormCheck   = $('#advanced_search_exit_form_check')

      if (self.enrollmentCheckbox.prop('checked') || self.wizardEnrollmentCheckbox.prop('checked')) then $(enrollmentCheck).val(1)
      if (self.trackingCheckbox.prop('checked') || self.wizardTrackingCheckbox.prop('checked')) then $(trackingCheck).val(1)
      if (self.exitCheckbox.prop('checked') || self.wizardExitCheckbox.prop('checked')) then $(exitFormCheck).val(1)
      if ($('#quantitative-type-checkbox').prop('checked')) then $('#advanced_search_quantitative_check').val(1)
      if ($('#hotline-checkbox').prop('checked')) then $('#advanced_search_hotline_check').val(1)

      $('#advanced_search_custom_forms').val(customFormValues)
      $('#advanced_search_program_streams').val(programValues)
      $('#advanced_search_queries').val(self.handleStringfyRules(basicRules))
      self.handleAddColumnPickerToInput()

  handleAddColumnPickerToInput: ->
    columnsVisibility = new Object
    # .all-visibility .icheckbox_square-green.checked
    $('#client-advance-search-form .visibility .icheckbox_square-green.checked').each ->
      checkbox = $(@).find('input[type="checkbox"]')
      if $(checkbox).prop('checked')
        attrName = $(checkbox).attr('name')
        columnsVisibility[attrName] = $(checkbox).val()

    $('#advanced_search_field_visible').val(JSON.stringify(columnsVisibility))

  validateSaveQuery: ->
    $(document).on 'keyup', '#advanced_search_name', ->
      if $(@).val() != ''
        $('#submit-query').removeClass('disabled').removeAttr('disabled')
      else
        $('#submit-query').addClass('disabled').attr('disabled', 'disabled')
