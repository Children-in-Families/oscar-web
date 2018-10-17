CIF.ClientsIndex = do ->
  _init = ->
    _enableSelect2()
    _columnsVisibility()
    _fixedHeaderTableColumns()
    _cssClassForlabelDynamic()
    _restrictNumberFilter()
    _quantitativeCaesByQuantitativeType()
    _clickMenuResizeChart()
    _handleHideShowReport()
    _formatReportxAxis()
    _handleCreateCaseReport()
    _handleCreateCsiDomainReport()
    _handleScrollTable()
    _handleColumnVisibilityParams()
    # _handleUncheckColumnVisibility()
    _getClientPath()
    _checkClientSearchForm()
    _initAdavanceSearchFilter()
    _toggleCollapseFilter()
    _handleAutoCollapse()
    _overdueAssessmentSearch()
    _removeOverdueAssessmentSearch()
    _hideOverdueAssessment()
    _searchNoCaseNote()
    _removeSearchNoCaseNote()
    _searchOverdueTask()
    _removeSearchOverdueTask()
    _overdueFormsSearch()
    _removeOverdueFormsSearch()
    _setDefaultCheckColumnVisibilityAll()
    # _removeProgramStreamExitDate()
    _addTourTip()

  _overdueFormsSearch = ->
    $('#overdue-forms.i-checks').on 'ifChecked', ->
      $('select#client_grid_overdue_forms').select2('val', 'Yes')
      $('input.datagrid-submit').click()

  _removeOverdueFormsSearch = ->
    $('#overdue-forms.i-checks').on 'ifUnchecked', ->
      $('select#client_grid_overdue_forms').select2('val', '')
      $('input.datagrid-submit').click()

  _hideOverdueAssessment = ->
    $('#client-advance-search-form .float-right').hide()

  _overdueAssessmentSearch = ->
    $('#overdue-assessment.i-checks').on 'ifChecked', ->
      $('select#client_grid_assessments_due_to').select2('val', 'Overdue')
      $('input.datagrid-submit').click()

  _removeOverdueAssessmentSearch = ->
    $('#overdue-assessment.i-checks').on 'ifUnchecked', ->
      $('select#client_grid_assessments_due_to').select2('val', '')
      $('input.datagrid-submit').click()

  _searchNoCaseNote = ->
    $('#no_case_note_check_box.i-checks').on 'ifChecked', ->
      $('select#client_grid_no_case_note').select2('val', 'Yes')
      $('input.datagrid-submit').click()

  _removeSearchNoCaseNote = ->
    $('#no_case_note_check_box.i-checks').on 'ifUnchecked', ->
      $('select#client_grid_no_case_note').select2('val', 'No')
      $('input.datagrid-submit').click()

  _searchOverdueTask = ->
    $('#overdue-task.i-checks').on 'ifChecked', ->
      $('select#client_grid_overdue_task').select2('val', 'Overdue')
      $('input.datagrid-submit').click()

  _removeSearchOverdueTask = ->
    $('#overdue-task.i-checks').on 'ifUnchecked', ->
      $('select#client_grid_overdue_task').select2('val', '')
      $('input.datagrid-submit').click()

  _setDefaultCheckColumnVisibilityAll = ->
    if $('#client-search-form .visibility .checked').length == 0
      $('#client-search-form .all-visibility #all_').iCheck('check')

    if $('#client-advance-search-form .visibility .checked').length == 0
      $('#client-advance-search-form .all-visibility #all_').iCheck('check')
      $('#program-stream-column .visibility').find('#program_enrollment_date_, #program_exit_date_').iCheck('check')

  _handleAutoCollapse = ->
    params = window.location.search.substr(1)

    if params.includes('client_advanced_search')
      $("button[data-target='#client-advance-search-form']").trigger('click')
    else
      $("button[data-target='#client-search-form']").trigger('click')

  _hideClientFilters = ->
    dataFilters = $('#client-search-form .datagrid-filter')
    displayColumns = '#client_grid_given_name, #client_grid_family_name, #client_grid_gender, #client_grid_slug, #client_grid_status, #client_grid_user_ids'
    $(dataFilters).hide()
    $(dataFilters).children("#{displayColumns}").parents('.datagrid-filter').show()

  _toggleCollapseFilter = ->
    $('#client-search-form').on 'show.bs.collapse', ->
      $('#client-statistic-body').hide()
      $('#client-advance-search-form').collapse('hide')

    $('#client-advance-search-form').on 'show.bs.collapse', ->
      $('#client-statistic-body').hide()
      $('#client-search-form').collapse('hide')


  _checkClientSearchForm = ->
    $("button.query").on 'click', ->
      form = $(@).attr('class')
      if form.includes('client-advance-search')
        $('#filter_form').hide()
      else
        $('#filter_form').show()
        _hideClientFilters()

  _initAdavanceSearchFilter = ->
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.initBuilderFilter('#client-builder-fields')
    advanceFilter.setValueToBuilderSelected()
    advanceFilter.getTranslation()

    advanceFilter.handleShowCustomFormSelect()
    advanceFilter.customFormSelectChange()
    advanceFilter.customFormSelectRemove()
    advanceFilter.handleHideCustomFormSelect()

    advanceFilter.handleShowProgramStreamFilter()
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

    advanceFilter.handleSearch()
    advanceFilter.addRuleCallback()
    advanceFilter.filterSelectChange()
    advanceFilter.filterSelecting()
    advanceFilter.opertatorSelecting()
    advanceFilter.checkingForDisableOptions()

    advanceFilter.handleSaveQuery()
    advanceFilter.validateSaveQuery()
    $('.rule-operator-container').change ->
      advanceFilter.initSelect2()

  # _removeProgramStreamExitDate = ->
  #   $('#client-advance-search-form').find('#program_enrollment_date,#program_exit_date').remove()

  _handleColumnVisibilityParams = ->
    $('button#search').on 'click', ->
      allCheckboxes = $('#client-search-form').find('#new_client_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

    $('input.datagrid-submit').on 'click', ->
      allCheckboxes = $('#client-advance-search-form').find('#new_client_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

  _handleUncheckColumnVisibility = ->
    params = window.location.search.substr(1)

    if params.includes('client_advanced_search')
      allCheckboxes = $('#client-search-form').find('#new_client_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')
    else
      allCheckboxes = $('#client-advance-search-form').find('#new_client_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')

  _infiniteScroll = ->
    $("table.clients .page").infinitescroll
      navSelector: "ul.pagination" # selector for the paged navigation (it will be hidden)
      nextSelector: "ul.pagination a[rel=next]" # selector for the NEXT link (to page 2)
      itemSelector: "table.clients tbody tr" # selector for all items you'll retrieve
      loading: {
        img: 'http://i.imgur.com/qkKy8.gif'
        msgText: $('.clients-table').data('info-load')
      }
      donetext: $('.clients-table').data('info-end')
      binder: $('.clients-table .dataTables_scrollBody')

  _handleCreateCsiDomainReport = ->
    element = $('#cis-domain-score')
    csiData = element.data('csi-domain')
    csiTitle = element.data('title')
    csiyAxisTitle = element.data('yaxis-title')

    report = new CIF.ReportCreator(csiData, csiTitle, csiyAxisTitle, element)
    report.lineChart()

  _handleCreateCaseReport = ->
    element = $('#program-statistic')
    caseData = element.data('program-statistic')
    caseTitle =  element.data('title')
    caseyAxisTitle =  element.data('yaxis-title')

    report = new CIF.ReportCreator(caseData, caseTitle, caseyAxisTitle, element)
    report.lineChart()

  _enableSelect2 = ->
    $('#clients-index select').select2
      minimumInputLength: 0,
      allowClear: true

  _formatReportxAxis = ->
    Highcharts.setOptions global: useUTC: false

  _handleHideShowReport = ->
    $('#client-statistic').click ->
      $('#client-advance-search-form').collapse('hide')
      $('#client-search-form').collapse('hide')
      $('#client-statistic-body').slideToggle("slow")
      _handleResizeWindow()

  _clickMenuResizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        _handleResizeWindow()
      ), 220

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('.all-visibility #all_')

    for checkBox in allCheckboxes
      $(checkBox).on 'ifChecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('check')
      $(checkBox).on 'ifUnchecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('uncheck')

  _fixedHeaderTableColumns = ->
    sInfoShow = $('#sinfo').data('infoshow')
    sInfoTo = $('#sinfo').data('infoto')
    sInfoTotal = $('#sinfo').data('infototal')
    $('.clients-table').removeClass('table-responsive')
    if !$('table.clients tbody tr td').hasClass('noresults')
      $('table.clients').dataTable(
        'sScrollY': 'auto'
        'bFilter': false
        'bAutoWidth': true
        'bSort': false
        'sScrollX': '100%'
        'bInfo': false
        'bLengthChange': false
        'bPaginate': false
      )
    else
      $('.clients-table').addClass('table-responsive')

  _cssClassForlabelDynamic = ->
    $('.dynamic_filter').prev('label').css( "display", "block" )
    $('.dynamic_filter').find('.select2-search').remove('div')

  _restrictNumberFilter = ->
    arr = ["all_domains", "domain_1a", "domain_1b", "domain_2a", "domain_2b", "domain_3a", "domain_3b", "domain_4a", "domain_4b", "domain_5a", "domain_5b", "domain_6a", "domain_6b"]
    $(arr).each (k, v) ->
      $(".#{v}.value").keydown (e) ->
        charCode = if e.which then e.which else e.keyCode
        if charCode != 46 and charCode > 31 and (charCode < 48 or charCode > 57)
          return false
        true

    $('input.age.float_filter').keydown (e) ->
      if $.inArray(e.keyCode, [
          46
          8
          9
          27
          13
          110
          190
        ]) != -1 or e.keyCode == 65 and e.ctrlKey == true or e.keyCode == 67 and e.ctrlKey == true or e.keyCode == 88 and e.ctrlKey == true or e.keyCode >= 35 and e.keyCode <= 41
        return
      if (e.shiftKey or e.keyCode < 48 or e.keyCode > 57) and (e.keyCode < 96 or e.keyCode > 105)
        e.preventDefault()
      return

  _quantitativeCaesByQuantitativeType = ->
    self = @
    quantitativeType = $('#client_grid_quantitative_types')
    closeTag = $('.quantitative_data').find('abbr')
    quantitativeData = $('#client_grid_quantitative_data')
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
        $('#client_grid_quantitative_data').html('')
        $('#client_grid_quantitative_data').append '<option value=""></option>'

        $(data).each (index, value) ->
          $('#client_grid_quantitative_data').append '<option value="' + data[index].id + '">' + data[index].value + '</option>'
      error: (error) ->

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.clients-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
        _handleResizeWindow()

  _getClientPath = ->
    return if $('table.clients tbody tr').text().trim() == 'No results found' || $('table.clients tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.clients tbody tr').text().trim() == 'No data available in table'
    $('table.clients tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')

  _iterateOverElement = (attr) ->
    total = 0
    $(attr).each (index) ->
      $(this).children().each (index) ->
        return if $(this).hasClass 'hide'
        total += 1
    total = if total != 0 then total else ''

  _addTourTip = ->
    content = $('#content').val()
    btnDone = $('#btn-done').val()
    if !$('#most-recent').length
      tour = new Tour(
        debug: true
        storage: false
        steps: [
          {
            element: '#client-search-form'
            content: content
            placement: 'bottom'
            orphan: true
            template: "<div class='popover tour'>
                      <div class='arrow'></div>
                      <div class='popover-content'></div>
                      <div class='popover-navigation pull-right' style='padding: 5px;' >
                        <button class='btn btn-default' data-role='end' id='btn-done-done'>#{btnDone}</button>
                      </div>
                  </div>"

          }
      ])
      tour.init()
      tour.start()

  { init: _init }
