# CIF.Client_advanced_searchesIndex = do ->
#   optionTranslation        = $('#opt-group-translation')
#   BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
#   DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
#   CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')
#   ENROLLMENT_TRANSLATE     = $(optionTranslation).data('enrollment')
#   EXIT_PROGRAM_TRANSTATE   = $(optionTranslation).data('exitProgram')
#   QUANTITATIVE_TRANSLATE   = $(optionTranslation).data('quantitative')
#   TRACKING_TRANSTATE       = $(optionTranslation).data('tracking')

#   ENROLLMENT_URL       = '/api/client_advanced_searches/get_enrollment_field'
#   TRACKING_URL         = '/api/client_advanced_searches/get_tracking_field'
#   EXIT_PROGRAM_URL     = '/api/client_advanced_searches/get_exit_program_field'
#   CUSTOM_FORM_URL      = '/api/client_advanced_searches/get_custom_field'

#   @enrollmentCheckbox  = $('#enrollment-checkbox')
#   @trackingCheckbox    = $('#tracking-checkbox')
#   @exitCheckbox        = $('#exit-form-checkbox')
#   @customFormSelected  = []
#   @programSelected     = []

#   _init = ->
#     @filterTranslation = ''
#     _initSelect2()
#     _setValueToBuilderSelected()
#     _getTranslation()
#     _initBuilderFilter()

#     _handleShowCustomFormSelect()
#     _customFormSelectChange()
#     _customFormSelectRemove()
#     _handleHideCustomFormSelect()

#     _handleShowProgramStreamFilter()
#     _handleHideProgramStreamSelect()
#     _handleProgramSelectChange()
#     _triggerEnrollmentFields()
#     _triggerTrackingFields()
#     _triggerExitProgramFields()
#     _handleSelect2RemoveProgram()
#     _handleUncheckedEnrollment()
#     _handleUncheckedTracking()
#     _handleUncheckedExitProgram()

#     _handleAddQuantitativeFilter()
#     _handleRemoveQuantitativFilter()
#     _columnsVisibility()
#     _handleInitDatatable()
#     _handleSearch()
#     _addRuleCallback()
#     _filterSelectChange()
#     _handleScrollTable()
#     _getClientPath()
#     _setDefaultCheckColumnVisibilityAll()
#     _filterSelecting()
#     _preventDomainScore()
#     _disableOptionDomainScores()
#     _handleSaveQuery()
#     _validateSaveQuery()

#   _handleSaveQuery = ->
#     self = @
#     $('#submit-query').on 'click', ->
#       basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
#       if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
#         $('#builder').find('.has-error').remove()
#       customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
#       programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

#       enrollmentCheck = $('#advanced_search_enrollment_check')
#       trackingCheck   = $('#advanced_search_tracking_check')
#       exitFormCheck   = $('#advanced_search_exit_form_check')

#       if self.enrollmentCheckbox.prop('checked') then $(enrollmentCheck).val(1)
#       if self.trackingCheckbox.prop('checked') then $(trackingCheck).val(1)
#       if self.exitCheckbox.prop('checked') then $(exitFormCheck).val(1)
#       if $('#quantitative-type-checkbox').prop('checked') then $('#advanced_search_quantitative_check').val(1)

#       $('#advanced_search_custom_forms').val(customFormValues)
#       $('#advanced_search_program_streams').val(programValues)
#       $('#advanced_search_queries').val(_handleStringfyRules(basicRules))
#       _handleAddColumnPickerToInput()

#   _handleAddColumnPickerToInput = ->
#     columnsVisibility = new Object
#     $('.visibility, .all-visibility').each ->
#       checkbox = $(@).find('input[type="checkbox"]')
#       if $(checkbox).prop('checked')
#         attrName = $(checkbox).attr('name')
#         columnsVisibility[attrName] = $(checkbox).val()
#     $('#advanced_search_field_visible').val(JSON.stringify(columnsVisibility))

#   _validateSaveQuery = ->
#     $('#advanced_search_name').keyup ->
#       if $(@).val() != ''
#         $('#submit-query').removeClass('disabled').removeAttr('disabled')
#       else
#         $('#submit-query').addClass('disabled').attr('disabled', 'disabled')

#   _disableOptionDomainScores = ->
#     for domain in $('.rule-operator-container select')
#       _preventOptionDomainScores(domain)

#   _filterSelecting = ->
#     $('.rule-filter-container select').on 'select2-selecting', ->
#       self = @
#       setTimeout ( ->
#         _preventDomainScore()
#       )

#   _preventDomainScore = ->
#     $('.rule-operator-container select').on 'select2-selected', ->
#       _preventOptionDomainScores(@)

#   _preventOptionDomainScores = (element) ->
#     if $(element).parent().siblings('.rule-filter-container').find('option:selected').val().split('_')[0] == 'domainscore'
#       ruleValueContainer = $(element).parent().siblings('.rule-value-container')
#       if $(element).find('option:selected').val() == 'greater'
#         $(ruleValueContainer).find("option[value=4]").attr('disabled', 'disabled')
#         $(ruleValueContainer).find("option[value=1]").removeAttr('disabled')
#         if $(ruleValueContainer).find('option:selected').val() == '4'
#           $(ruleValueContainer).find('select').val('1').trigger('change')
#       else if $(element).find('option:selected').val() == 'less'
#         $(ruleValueContainer).find("option[value='1']").attr('disabled', 'disabled')
#         $(ruleValueContainer).find("option[value='4']").removeAttr('disabled')
#         if $(ruleValueContainer).find("option:selected").val() == '1'
#           $(ruleValueContainer).find('select').val('2').trigger('change')
#       else
#         $(ruleValueContainer).find("option[value='4']").removeAttr('disabled')
#         $(ruleValueContainer).find("option[value='1']").removeAttr('disabled')
#       setTimeout( ->
#         _initSelect2()
#       )

#   _initSelect2 = ->
#     $('#custom-form-select, #program-stream-select, #quantitative-case-select').select2()
#     $('.rule-filter-container select').select2(width: '250px')
#     $('.rule-operator-container select, .rule-value-container select').select2(width: 'resolve')

#   _setValueToBuilderSelected = ->
#     @customFormSelected = $('.custom-form').data('value')
#     @programSelected    = $('.program-stream').data('value')

#   _handleAddQuantitativeFilter = ->
#     fields = $('#quantitative-fields').data('fields')
#     $('#quantitative-type-checkbox').on 'ifChecked', ->
#       $('#builder').queryBuilder('addFilter', fields)
#       _initSelect2()

#   _handleRemoveQuantitativFilter = ->
#     $('#quantitative-type-checkbox').on 'ifUnchecked', ->
#       _handleRemoveFilterBuilder(QUANTITATIVE_TRANSLATE, QUANTITATIVE_TRANSLATE)

#   _handleShowProgramStreamFilter = ->
#     if $('#program-stream-checkbox').prop('checked')
#       $('.program-stream').show()
#     if @enrollmentCheckbox.prop('checked') || @trackingCheckbox.prop('checked') || @exitCheckbox.prop('checked') || @programSelected.length > 0
#       $('.program-association').show()
#     $('#program-stream-checkbox').on 'ifChecked', ->
#       $('.program-stream').show()

#   _handleHideProgramStreamSelect = ->
#     self = @
#     $('#program-stream-checkbox').on 'ifUnchecked', ->
#       $('#program-stream-column ul.append-child li').remove()
#       self.programSelected = []
#       $('.program-stream, .program-association').hide()
#       $('.program-association input[type="checkbox"]').iCheck('uncheck')
#       $('#program-stream-select').select2("val", "")

#   _triggerEnrollmentFields = ->
#     self = @
#     $('#enrollment-checkbox').on 'ifChecked', ->
#       _addCustomBuildersFields(self.programSelected, ENROLLMENT_URL)

#   _triggerTrackingFields = ->
#     self = @
#     $('#tracking-checkbox').on 'ifChecked', ->
#       _addCustomBuildersFields(self.programSelected, TRACKING_URL)

#   _triggerExitProgramFields = ->
#     self = @
#     $('#exit-form-checkbox').on 'ifChecked', ->
#       _addCustomBuildersFields(self.programSelected, EXIT_PROGRAM_URL)

#   _handleUncheckedEnrollment = ->
#     $('#enrollment-checkbox').on 'ifUnchecked', ->
#       for option in $('#program-stream-select option:selected')
#         name          = $(option).text()
#         programName   = name.trim()
#         headerClass   = _formatSpecialCharacter("#{programName} Enrollment")

#         _removeCheckboxColumnPicker('#program-stream-column', headerClass)
#         _handleRemoveFilterBuilder(name, ENROLLMENT_TRANSLATE)

#   _handleUncheckedTracking = ->
#     $('#tracking-checkbox').on 'ifUnchecked', ->
#       for option in $('#program-stream-select option:selected')
#         name          = $(option).text()
#         programName   = name.trim()
#         headerClass   = _formatSpecialCharacter("#{programName} Tracking")

#         _removeCheckboxColumnPicker('#program-stream-column', headerClass)
#         _handleRemoveFilterBuilder(name, TRACKING_TRANSTATE)

#   _handleUncheckedExitProgram = ->
#     $('#exit-form-checkbox').on 'ifUnchecked', ->
#       for option in $('#program-stream-select option:selected')
#         name          = $(option).text()
#         programName   = name.trim()
#         headerClass   = _formatSpecialCharacter("#{programName} Exit Program")

#         _removeCheckboxColumnPicker('#program-stream-column', headerClass)
#         _handleRemoveFilterBuilder(name, EXIT_PROGRAM_TRANSTATE)

#   _handleSelect2RemoveProgram = ->
#     self = @
#     $('#program-stream-select').on 'select2-removed', (element) ->
#       programName = element.choice.text
#       programStreamKeyword = ['Enrollment', 'Tracking', 'Exit Program']
#       _.forEach programStreamKeyword, (value) ->
#         headerClass = _formatSpecialCharacter("#{programName.trim()} #{value}")
#         _removeCheckboxColumnPicker('#program-stream-column', headerClass)

#       $.map self.programSelected, (val, i) ->
#         if parseInt(val) == parseInt(element.val) then self.programSelected.splice(i, 1)

#       _handleRemoveFilterBuilder(programName, ENROLLMENT_TRANSLATE)
#       setTimeout ( ->
#         _handleRemoveFilterBuilder(programName, TRACKING_TRANSTATE)
#         _handleRemoveFilterBuilder(programName, EXIT_PROGRAM_TRANSTATE)
#         )
#       if $.isEmptyObject($(@).val())
#         programStreamAssociation = $('.program-association')
#         $(programStreamAssociation).find('.i-checks').iCheck('uncheck')
#         $(programStreamAssociation).hide()

#   _handleProgramSelectChange = ->
#     self = @
#     $('#program-stream-select').on 'select2-selecting', (psElement) ->
#       programId = psElement.val
#       self.programSelected.push programId
#       $('.program-association').show()
#       if $('#enrollment-checkbox').prop('checked')
#         _addCustomBuildersFields(programId, ENROLLMENT_URL)
#       if $('#tracking-checkbox').prop('checked')
#         _addCustomBuildersFields(programId, TRACKING_URL)
#       if $('#exit-form-checkbox').prop('checked')
#         _addCustomBuildersFields(programId, EXIT_PROGRAM_URL)

#   _handleShowCustomFormSelect = ->
#     if $('#custom-form-checkbox').prop('checked')
#       $('.custom-form').show()
#     $('#custom-form-checkbox').on 'ifChecked', ->
#       $('.custom-form').show()

#   _handleHideCustomFormSelect = ->
#     self = @
#     $('#custom-form-checkbox').on 'ifUnchecked', ->
#       $('#custom-form-column ul.append-child li').remove()

#       $('#custom-form-select option:selected').each ->
#         formTitle = $(@).text()
#         _handleRemoveFilterBuilder(formTitle, CUSTOM_FORM_TRANSLATE)

#       self.customFormSelected = []
#       $('.custom-form select').select2('val', '')
#       $('.custom-form').hide()

#   _customFormSelectChange = ->
#     self = @
#     $('#custom-form-wrapper select').on 'select2-selecting', (element) ->
#       self.customFormSelected.push element.val
#       _addCustomBuildersFields(element.val, CUSTOM_FORM_URL)

#   _customFormSelectRemove = ->
#     self = @
#     $('#custom-form-wrapper select').on 'select2-removed', (element) ->
#       removeValue = element.choice.text
#       formTitle   = removeValue.trim()
#       formTitle   = _formatSpecialCharacter("#{formTitle} Custom Form")

#       _removeCheckboxColumnPicker('#custom-form-column', formTitle)
#       $.map self.customFormSelected, (val, i) ->
#         if parseInt(val) == parseInt(element.val) then self.customFormSelected.splice(i, 1)

#       setTimeout ( ->
#         _handleRemoveFilterBuilder(removeValue, CUSTOM_FORM_TRANSLATE)
#         ),100

#   _addFieldToColumnPicker = (element, fieldList) ->
#     customFormColumnPicker = $("#{element} ul.append-child")
#     fieldsGroupByOptgroup = _.groupBy(fieldList, 'optgroup')

#     _.forEach fieldsGroupByOptgroup, (values, key) ->
#       headerClass = _formBuiderFormatHeader(key)
#       $(customFormColumnPicker).append("<li class='dropdown-header #{headerClass}'>#{key}</li>")
#       _.forEach values, (value) ->
#         fieldName = value.id
#         keyword   = _.first(fieldName.split('_'))
#         if keyword != 'enrollmentdate' and keyword != 'programexitdate'
#           checkField  = _formatSpecialCharacter(fieldName)
#           label       = value.label
#           $(customFormColumnPicker).append(_checkboxElement(checkField, headerClass, label))
#           $(".#{headerClass} input.i-checks").iCheck
#             checkboxClass: 'icheckbox_square-green'

#   _formBuiderFormatHeader = (value) ->
#     keyWords = value.split('|')
#     name = _.first(keyWords).trim()
#     label = _.last(keyWords).trim()
#     combine = "#{name} #{label}"
#     _formatSpecialCharacter(combine)

#   _formatSpecialCharacter = (value) ->
#     filedName = value.toLowerCase().replace(/[^a-zA-Z0-9]+/gi, ' ').trim()
#     filedName.replace(/ /g, '_')

#   _removeCheckboxColumnPicker = (element, name) ->
#     $("#{element} ul.append-child li.#{name}").remove()

#   _checkboxElement = (field, name, label) ->
#    "<li class='visibility checkbox-margin #{name}'>
#       <input type='checkbox' name='#{field}_' id='#{field}_' value='#{field}' class='i-checks' style='position: absolute; opacity: 0;'>
#       <label for='#{field}_'>#{label}</label>
#     </li>"

#   _addCustomBuildersFields = (ids, url) ->
#     action  = _.last(url.split('/'))
#     element = if action == 'get_custom_field' then '#custom-form-column' else '#program-stream-column'
#     $.ajax
#       url: url
#       data: { ids: ids }
#       method: 'GET'
#       success: (response) ->
#         fieldList = response.client_advanced_searches
#         $('#builder').queryBuilder('addFilter', fieldList)
#         _initSelect2()
#         _addFieldToColumnPicker(element, fieldList)

#   _initBuilderFilter = ->
#     builderFields = $('#client-builder-fields').data('fields')
#     advanceSearchBuilder = new CIF.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
#     advanceSearchBuilder.initRule()
#     _basicFilterSetRule()
#     _initSelect2()
#     _initRuleOperatorSelect2($('#builder'))

#   _handleSearch = ->
#     self = @
#     $('#search').on 'click', ->
#       basicRules = $('#builder').queryBuilder('getRules', { skip_empty: true, allow_invalid: true })
#       customFormValues = if self.customFormSelected.length > 0 then "[#{self.customFormSelected}]"
#       programValues = if self.programSelected.length > 0 then "[#{self.programSelected}]"

#       _setValueToProgramAssociation()
#       $('#client_advanced_search_custom_form_selected').val(customFormValues)
#       $('#client_advanced_search_program_selected').val(programValues)
#       if $('#quantitative-type-checkbox').prop('checked')
#         $('#client_advanced_search_quantitative_check').val(1)

#       if (_.isEmpty(basicRules.rules) and !basicRules.valid) or (!(_.isEmpty(basicRules.rules)) and basicRules.valid)
#         $('#builder').find('.has-error').remove()
#         $('#client_advanced_search_basic_rules').val(_handleStringfyRules(basicRules))
#         _handleSelectFieldVisibilityCheckBox()
#         $('#advanced-search').submit()

#   _setValueToProgramAssociation = ->
#     enrollmentCheck = $('#client_advanced_search_enrollment_check')
#     trackingCheck   = $('#client_advanced_search_tracking_check')
#     exitFormCheck   = $('#client_advanced_search_exit_form_check')

#     if @enrollmentCheckbox.prop('checked') then $(enrollmentCheck).val(1)
#     if @trackingCheckbox.prop('checked') then $(trackingCheck).val(1)
#     if @exitCheckbox.prop('checked') then $(exitFormCheck).val(1)

#   _columnsVisibility = ->
#     $('.columns-visibility').click (e) ->
#       e.stopPropagation()

#     allCheckboxes = $('#client-column .all-visibility #all_')

#     allCheckboxes.on 'ifChecked', ->
#       $('#client-column .visibility input[type=checkbox]').iCheck('check')
#     allCheckboxes.on 'ifUnchecked', ->
#       $('#client-column .visibility input[type=checkbox]').iCheck('uncheck')

#   _setDefaultCheckColumnVisibilityAll = ->
#     setTimeout ( ->
#       clientCheckboxChecked     = $('#client-column .visibility .checked')
#       programCheckboxChecked    = $('#program-stream-column .visibility .checked')
#       customFormCheckboxChecked = $('#custom-form-column .visibility .checked')
#       if $(clientCheckboxChecked).length == 0 and $(programCheckboxChecked).length == 0 and $(customFormCheckboxChecked).length == 0
#         $('#client-column .all-visibility #all_').iCheck('check')
#       )

#   _addRuleCallback = ->
#     $('#builder').on 'afterCreateRuleFilters.queryBuilder', (_e, obj) ->
#       _initSelect2()
#       _handleSelectOptionChange(obj)
#       _referred_to_program()
#       _filterSelecting()

#   _handleSelectOptionChange = (obj)->
#     if obj != undefined
#       rowBuilderRule = obj.$el[0]
#       ruleFiltersSelect = $(rowBuilderRule).find('.rule-filter-container select')
#       $(ruleFiltersSelect).on 'select2-close', ->
#         setTimeout ( ->
#           _initSelect2()
#           _initRuleOperatorSelect2(rowBuilderRule)
#         )

#   _filterSelectChange = ->
#     $('.rule-filter-container select').on 'select2-close', ->
#       setTimeout ( ->
#         _initSelect2()
#       )

#   _initRuleOperatorSelect2 = (rowBuilderRule) ->
#     operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
#     $(operatorSelect).on 'select2-close', ->
#       setTimeout ( ->
#         $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
#       )

#   _handleRemoveFilterBuilder = (resourceName, resourcelabel) ->
#     filterSelects = $('.rule-container .rule-filter-container select')
#     for select in filterSelects
#       optGroup  = $(':selected', select).parents('optgroup')
#       if $(select).val() != '-1' and optGroup[0] != undefined and optGroup[0].label != BASIC_FIELD_TRANSLATE and optGroup[0].label != DOMAIN_SCORES_TRANSLATE
#         label = optGroup[0].label.split('|')
#         if $(label).last()[0].trim() == resourcelabel and label[0].trim() == resourceName
#           container = $(select).parents('.rule-container')
#           $(container).find('select').select2('destroy')
#           $(container).find('.rule-header button').trigger('click')

#     setTimeout ( ->
#       if $('.rule-container .rule-filter-container select').length == 0
#         $('button[data-add="rule"]').trigger('click')
#         filterSelects = $('.rule-container .rule-filter-container select')
#       _handleRemoveBuilderOption(filterSelects, resourceName, resourcelabel)
#       )

#   _handleRemoveBuilderOption = (filterSelects, resourceName, resourcelabel) ->
#     values = []
#     optGroups = $(filterSelects[0]).find('optgroup')
#     for optGroup in optGroups
#       label = optGroup.label
#       if label != BASIC_FIELD_TRANSLATE and label != DOMAIN_SCORES_TRANSLATE
#         labelValue = label.split('|')
#         if $(labelValue).last()[0].trim() == resourcelabel and labelValue[0].trim() == resourceName
#           $(optGroup).find('option').each ->
#             values.push $(@).val()
#     $('#builder').queryBuilder('removeFilter', values)
#     _initSelect2()

#   _referred_to_program = ->
#     $('.rule-filter-container select').change ->
#       selectedOption      = $(this).find('option:selected')
#       selectedOptionValue = $(selectedOption).val()
#       if selectedOptionValue == 'referred_to_ec' || selectedOptionValue == 'referred_to_fc' || selectedOptionValue == 'referred_to_kc'
#         setTimeout ( ->
#           $(selectedOption).parents('.rule-filter-container').siblings('.rule-operator-container').find('select option[value="is_empty"]').remove()
#         ),10

#   _getTranslation = ->
#     @filterTranslation =
#       addFilter: $('#builder').data('filter-translation-add-filter')
#       addGroup: $('#builder').data('filter-translation-add-group')
#       deleteGroup: $('#builder').data('filter-translation-delete-group')

#   _basicFilterSetRule = ->
#     basicQueryRules = $('#builder').data('basic-search-rules')
#     unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
#       $('#builder').queryBuilder('setRules', basicQueryRules)

#   _handleInitDatatable = ->
#     $('.clients-table table').DataTable(
#         'sScrollY': '500'
#         'bFilter': false
#         'bAutoWidth': true
#         'bSort': false
#         'sScrollX': '100%'
#         'bInfo': false
#         'bLengthChange': false
#         'bPaginate': false
#       )

#   _handleStringfyRules = (rules) ->
#     rules = JSON.stringify(rules)
#     return rules.replace(/null/g, '""')

#   _handleSelectFieldVisibilityCheckBox = ->
#     checkedFields = $('.visibility .checked input, .all-visibility .checked input')
#     $('form#advanced-search').append(checkedFields)

#   _handleScrollTable = ->
#     $(window).load ->
#       ua = navigator.userAgent
#       unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
#         $('.clients-table .dataTables_scrollBody').niceScroll
#           scrollspeed: 30
#           cursorwidth: 10
#           cursoropacitymax: 0.4

#   _getClientPath = ->
#     $('table.clients tbody tr').click (e) ->
#       return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
#       window.open($(@).data('href'), '_blank')

#   { init: _init }
