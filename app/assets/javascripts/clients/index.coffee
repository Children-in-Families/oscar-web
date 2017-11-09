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
    _setDefaultCheckColumnVisibilityAll()
    _getClientPath()
    _checkClientSearchForm()
    _initAdavanceSearchFilter()

  _checkClientSearchForm = ->
    $("button.btn-filter").on 'click', ->
      form = $(@).attr('class')
      if form.includes('client-advance-search')
        $('#filter_form').hide()
      else
        $('#filter_form').show()

  _initAdavanceSearchFilter = ->
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.initBuilderFilter()
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
    advanceFilter.preventDomainScore()
    advanceFilter.disableOptionDomainScores()

    advanceFilter.handleSaveQuery()
    advanceFilter.validateSaveQuery()

  _setDefaultCheckColumnVisibilityAll = ->
    if $('.visibility .checked').length == 0
      $('#client-column .all-visibility #all_').iCheck('check')

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

    allCheckboxes.on 'ifChecked', ->
      $('.visibility input[type=checkbox]').iCheck('check')
    allCheckboxes.on 'ifUnchecked', ->
      $('.visibility input[type=checkbox]').iCheck('uncheck')

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

  { init: _init }
