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
    $("table.clients .page").infinitescroll
      navSelector: "nav.pagination" # selector for the paged navigation (it will be hidden)
      nextSelector: "nav.pagination a[rel=next]" # selector for the NEXT link (to page 2)
      itemSelector: "table.clients tbody tr" # selector for all items you'll retrieve
      loading: {
        img: 'http://i.imgur.com/qkKy8.gif'
        msgText: '<em>Loading clients...</em>'
      }
      donetext: "<em>You've reached the end.</em>"
      binder: $('.clients-table .dataTables_scrollBody')

  _handleCreateCsiDomainReport = ->
    element = $('#cis-domain-score')
    csiData = element.data('csi-domain')
    csiTitle = element.data('title')
    csiyAxisTitle = element.data('yaxis-title')

    report = new CIF.ReportCreator(csiData, csiTitle, csiyAxisTitle, element)
    report.lineChart()

  _handleCreateCaseReport = ->
    element = $('#case-statistic')
    caseData = element.data('case-statistic')
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
      _handleResizeChart()

  _clickMenuResizeChart = ->
    $('.minimalize-styl-2').click ->
      setTimeout (->
        _handleResizeChart()
      ), 220

  _handleResizeChart = ->
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
    # if !$('table.clients tbody tr td').hasClass('noresults')
    #   $('table.clients').dataTable(
    #     'sScrollY': 'auto'
    #     'bFilter': false
    #     'bAutoWidth': true
    #     'bSort': false
    #     'sScrollX': '100%'
    #     'sScrollXInner': '100%'
    #     # 'oLanguage':
    #     # 'sInfo': "(#{sInfoShow} _START_ #{sInfoTo} _END_ #{sInfoTotal} _TOTAL_)"
    #     # 'bScrollInfinite': true
    #     # 'bScrollCollapse': true
    #     'iDisplayLength': 20
    #     'bInfo': false
    #     'bLengthChange': false
    #     'bPaginate': false
    #   )
    # else
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
      $('.clients-table .dataTables_scrollBody').perfectScrollbar()

  { init: _init }
