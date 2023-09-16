CIF.FamiliesIndex = CIF.FamiliesWelcome = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getFamilyPath()
    _initSelect2()
    _handleAutoCollapse()
    _toggleCollapseFilter()
    _checkFamilySearchForm()
    _columnsVisibility()
    _handleColumnVisibilityParams()
    # _handleUncheckColumnVisibility()
    _initAdavanceSearchFilter()
    _hideFamilyFilters()
    # _setDefaultCheckColumnVisibilityAll()
    _initCheckbox()
    _quantitativeCaesByQuantitativeType()
    _initColumnFilter()

  _initColumnFilter = ->
    searchBox = $('ul.columns-visibility .column-search-box')
    searchBox.keyup ->
      valThis = $(this).val().toLowerCase()

      if valThis == ''
        $('ul.columns-visibility li').show()
      else
        $('ul.columns-visibility li:not(:first-child)').each ->
          text = $(this).find("label").text().toLowerCase().trim()

          if text.indexOf(valThis) >= 0 then $(this).show() else $(this).hide()
          return
      return

    $('ul.columns-visibility .btn-clear-text').click ->
      searchBox.val ''
      searchBox.focus()
      $('ul.columns-visibility li').show()
      return

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initAdavanceSearchFilter = ->
    return if $('#family-builder-fields').length == 0
    
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.initBuilderFilter('#family-builder-fields')
    advanceFilter.setValueToBuilderSelected()
    advanceFilter.getTranslation()

    advanceFilter.handleShowCustomFormSelect()
    advanceFilter.customFormSelectChange()
    advanceFilter.customFormSelectRemove()
    advanceFilter.assessmentSelectChange()
    advanceFilter.handleHideCustomFormSelect()

    advanceFilter.handleFamilyShowProgramStreamFilter()
    advanceFilter.handleHideProgramStreamSelect()
    advanceFilter.handleProgramSelectChange()
    advanceFilter.triggerEnrollmentFields()
    advanceFilter.triggerTrackingFields()
    advanceFilter.triggerExitProgramFields()

    advanceFilter.handleSelect2RemoveProgram()
    advanceFilter.handleUncheckedEnrollment()
    advanceFilter.handleUncheckedTracking()
    advanceFilter.handleUncheckedExitProgram()

    advanceFilter.handleAddQuantitativeFilter()
    advanceFilter.handleRemoveQuantitativFilter()

    advanceFilter.handleFamilySearch()
    advanceFilter.addRuleCallback()
    advanceFilter.filterSelectChange()
    advanceFilter.filterSelecting()

    advanceFilter.handleSaveQuery()
    advanceFilter.validateSaveQuery()

    $('.rule-operator-container').change ->
      advanceFilter.initSelect2()

    advanceFilter.handleShowAssessmentSelect()
    advanceFilter.handleHideAssessmentSelect()
    _addDataTableToAssessmentScoreData()


  _addDataTableToAssessmentScoreData = ->
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.prepareFamilySearch()
    _handleAjaxRequestToAssessment("#custom-assessment-score-0", $("#custom-assessment-domain-score-0").data("filename"))

    $('.assessment-domain-score').on 'shown.bs.modal', (e) ->
      $($.fn.dataTable.tables(true)).DataTable().columns.adjust()
      return
  
  _handleAjaxRequestToAssessment = (tableId, fileName)->
    return if $(tableId).length == 0

    url = $("#{tableId} .api-assessment-path").data('assessment-params')
    columns = $("#{tableId} .assessment-domain-headers").data('headers')

    rules = $("#client_advanced_search_basic_rules").val()
    if url.includes("family/assessments")
      rules = $("#family_advanced_search_basic_rules").val()

    table = $(tableId).DataTable
      autoWidth:true
      bFilter: false
      processing: true
      serverSide: true
      sServerMethod: 'POST'
      ajax:
        url: url
        data: 
          basic_rules: rules
        error: (jqXHR, textStatus, errorThrown) ->
          console.log("Datatable Ajax Error:", errorThrown)
      oLanguage: {
        sProcessing: "<i class='fa fa-spinner fa-pulse fa-2x' style='color: #1ab394; z-index: 9999;'></i>"
      }
      scrollX: true
      columnDefs: [{ type: 'formatted-num', targets: 0 }]
      columns: columns
      dom: 'lBrtip'
      lengthMenu: [
        [
          10
          25
          -1
        ]
        [
          10
          25
          'All'
        ]
      ]
      buttons: [ {
        filename: fileName
        extend: 'excel'
        text: '<span class="fa fa-file-excel-o"></span> Excel Export'
        exportOptions: modifier:
          search: 'applied'
          order: 'applied'
        }
      ],
      'drawCallback': (oSettings) ->
        $('.dataTables_scrollHeadInner').css 'width': '100%'
        $(tableId).css 'width': '100%'
        return

  _handleUncheckColumnVisibility = ->
    params = window.location.search.substr(1)

    if params.includes('family_advanced_search')
      allCheckboxes = $('#family-search-form').find('#new_family_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')
    else
      allCheckboxes = $('#family-advance-search-form').find('#new_family_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')

  _handleColumnVisibilityParams = ->
    $('button#search').on 'click', ->
      allCheckboxes = $('#family-search-form').find('#new_family_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

    $('input.datagrid-submit').on 'click', ->
      allCheckboxes = $('#family-advance-search-form').find('#new_family_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

  _setDefaultCheckColumnVisibilityAll = ->
    if $('#family-search-form .visibility .checked').length == 0
      $('#family-search-form .all-visibility .all_').iCheck('check')

    if $('#family-advance-search-form .visibility .checked').length == 0
      $('#family-advance-search-form .all-visibility .all_').iCheck('check')

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('.all-visibility .all_')

    for checkBox in allCheckboxes
      $(checkBox).on 'ifChecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('check')
      $(checkBox).on 'ifUnchecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('uncheck')

  _handleAutoCollapse = ->
    action = $('#search-action').data('action') || 'family_grid'
    if action == '#builder'
      $("button[data-target='#family-advance-search-form']").trigger('click')
    else
      $("button[data-target='#family-search-form']").trigger('click')

  _hideFamilyFilters = ->
    $('#family-advance-search-form #filter_form').hide()

  _toggleCollapseFilter = ->
    $("#accordion-family-filter .panel-title a").click ->
      $filterWrapper = $(@).closest("#accordion-family-filter")
      $panelBody = $filterWrapper.find($(@).attr("href"))

      if $panelBody.hasClass("in")
        $("#accordion-family-filter .panel-collapse").removeClass("in")
      else
        $("#accordion-family-filter .panel-collapse").removeClass("in")
        $panelBody.addClass("in")

    $('#family-search-form').on 'show.bs.collapse', ->
      $('#family-advance-search-form').collapse('hide')

    $('#family-advance-search-form').on 'show.bs.collapse', ->
      $('#family-search-form').collapse('hide')

  _checkFamilySearchForm = ->
    $("button.query").on 'click', ->
      form = $(@).attr('class')
      if form.includes('family-advance-search')
        $('#filter_form').hide()
      else
        $('#filter_form').show()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  _fixedHeaderTableColumns = ->
    $('.families-table').removeClass('table-responsive')
    if !$('table.families tbody tr td').hasClass('noresults')
      $('table.families').dataTable(
        'sScrollX': '100%'
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true)
    else
      $('.families-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.families-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getFamilyPath = ->
    return if $('table.families tbody tr').text().trim() == 'No results found' || $('table.families tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.families tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).hasClass('case-history')
      window.open($(@).data('href'), '_blank')

  _quantitativeCaesByQuantitativeType = ->
    self = @
    quantitativeType = $('#family_grid_quantitative_types')
    closeTag = $('.quantitative_data').find('abbr')
    quantitativeData = $('#family_grid_quantitative_data')
    quantitativeType.on 'change',  ->
      qValue = quantitativeType.val()
      quantitativeCaesText = $('.quantitative_data').find('.select2-chosen')
      quantitativeCaesText.text('')
      closeTag.hide()
      _quantitativeCaes(qValue)
    quantitativeData.on 'change', ->
      closeTag.show()
    closeTag.click ->
      closeTag.hide()

  _quantitativeCaes = (qValue) ->
    $.ajax
      url: '/quantitative_data?id=' + qValue
      method: 'GET'
      success: (response) ->
        data = response.data
        option = []
        $('#family_grid_quantitative_data').html('')
        $('#family_grid_quantitative_data').append '<option value=""></option>'

        $(data).each (index, value) ->
          $('#family_grid_quantitative_data').append '<option value="' + data[index].id + '">' + data[index].value + '</option>'
      error: (error) ->

  { init: _init }
