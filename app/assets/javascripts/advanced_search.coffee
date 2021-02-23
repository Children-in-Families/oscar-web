class CIF.AdvancedSearch
  constructor: () ->
    @filterTranslation   = ''
    @customFormSelected  = []
    @programSelected     = []
    optionTranslation    = $('#opt-group-translation')

    @DOMAIN_SCORES_TRANSLATE  = $(optionTranslation).data('csiDomainScores')
    @BASIC_FIELD_TRANSLATE    = $(optionTranslation).data('basicFields')
    @CUSTOM_FORM_TRANSLATE    = $(optionTranslation).data('customForm')

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
      addFilter: $('#builder').data('filter-translation-add-filter')
      addGroup: $('#builder').data('filter-translation-add-group')
      deleteGroup: $('#builder').data('filter-translation-delete-group')

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
    @.getTranslation()
    if !_.isEmpty(@filterTranslation) and !_.isEmpty(builderFields)
      advanceSearchBuilder = new CIF.AdvancedFilterBuilder($('#builder'), builderFields, @filterTranslation)
      advanceSearchBuilder.initRule()
      advanceSearchBuilder.setRuleFromSavedSearch()

    @.basicFilterSetRule()
    @.initSelect2()
    @.initRuleOperatorSelect2($('#builder'))


  initSelect2: ->
    $('#custom-form-select, #program-stream-select, #quantitative-case-select').select2()
    $('#builder select').select2()
    setTimeout ( ->
      ids = ['#custom-form-select', '#program-stream-select', '#quantitative-case-select', '#builder']
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
    basicQueryRules = $('#builder').data('basic-search-rules')
    unless basicQueryRules == undefined or _.isEmpty(basicQueryRules.rules)
      self.handleAddHotlineFilter()
      $('#builder').queryBuilder('setRules', basicQueryRules)

  initRuleOperatorSelect2: (rowBuilderRule) ->
    operatorSelect = $(rowBuilderRule).find('.rule-operator-container select')
    $(operatorSelect).on 'select2-close', ->
      setTimeout ( ->
        $(rowBuilderRule).find('.rule-value-container select').select2(width: '180px')
      )

  ######################################################################################################################

  handleAddQuantitativeFilter: ->
    self = @
    fields = $('#quantitative-fields').data('fields')
    $('#quantitative-type-checkbox').on 'ifChecked', ->
      $('#builder').queryBuilder('addFilter', fields) if $('#builder:visible').length > 0
      self.initSelect2()

  handleRemoveQuantitativFilter: ->
    self = @
    $('#quantitative-type-checkbox').on 'ifUnchecked', ->
      self.handleRemoveFilterBuilder(self.QUANTITATIVE_TRANSLATE, self.QUANTITATIVE_TRANSLATE)

  handleRemoveFilterBuilder: (resourceName, resourcelabel, elementBuilder = '#builder') ->
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
    $('#builder').queryBuilder('removeFilter', values)
    @initSelect2()

