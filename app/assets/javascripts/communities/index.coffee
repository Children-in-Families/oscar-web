CIF.CommunitiesIndex = CIF.CommunitiesWelcome = do ->
  _init = ->
    _initSelect2()
    _initCheckbox()
    _handleUncheckColumnVisibility()
    _columnsVisibility()
    _setDefaultCheckColumnVisibilityAll()
    _handleAutoCollapse()
    _toggleCollapseFilter()
    _checkCommunitySearchForm()
    _initAdavanceSearchFilter()
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getClientPath()

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _handleUncheckColumnVisibility = ->
    params = window.location.search.substr(1)

    if params.includes('cummunity_advanced_search')
      allCheckboxes = $('#community-search-form').find('#new_community_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')
    else
      allCheckboxes = $('#community-advanced-search').find('#new_community_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')

  _columnsVisibility = ->
    $('.columns-visibility').on 'click', (e) ->
      e.stopPropagation()
    allCheckboxes = $('.all-visibility .all_')
    for checkBox in allCheckboxes
      $(checkBox).on 'ifChecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('check')
      $(checkBox).on 'ifUnchecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('uncheck')

  _setDefaultCheckColumnVisibilityAll = ->
    if $('#community-search-form .visibility .checked').length == 0
      $('#community-search-form .all-visibility .all_').iCheck('check')

    if $('#community-advanced-search .visibility .checked').length == 0
      $('#community-advanced-search .all-visibility .all_').iCheck('check')
      $('.program-stream-column .visibility').find('#program_enrollment_date_, #program_exit_date_').iCheck('check')

  _handleAutoCollapse = ->
    action = $('#search-action').data('action') || 'community_grid'
    if action == '#community-builder'
      adButton = $("button[data-target='#community-advanced-search']")
      adButton.trigger('click')
      form = $(adButton).attr('class')
      _hideShowBasicField(form)
    else
      $("button[data-target='#community-search-form']").trigger('click')

  _hideCBasicFilters = ->
    dataFilters = $('#community-search-form .datagrid-filter')
    displayColumns = '#community_grid_name, #community_grid_name_en, #community_grid_id, #community_grid_status, #community_grid_gender, #community_grid_formed_date'
    $(dataFilters).hide()
    $(dataFilters).children("#{displayColumns}").parents('.datagrid-filter').show()

  _toggleCollapseFilter = () ->
    $('#community-search-form').on 'show.bs.collapse', ->
      $('#community-statistic-body').hide()
      $('#community-advanced-search').collapse('hide')

    $('#community-advanced-search').on 'show.bs.collapse', ->
      $('#community-statistic-body').hide()
      $('#community-search-form').collapse('hide')

  _initAdavanceSearchFilter = ->
    advanceFilter = new CIF.AdvancedSearch('#community-builder', '/api/community_advanced_searches/get_custom_field')
    advanceFilter.initBuilderFilter('#community-builder-fields')
    advanceFilter.setValueToBuilderSelected()

    advanceFilter.handleAddQuantitativeFilter()
    advanceFilter.handleRemoveQuantitativFilter()

    advanceFilter.customFormSelectChange()
    advanceFilter.customFormSelectRemove()
    advanceFilter.handleHideCustomFormSelect()
    advanceFilter.handleShowCustomFormSelect()
    advanceFilter.addRuleCallback()

    advanceFilter.handleSearch()

  _checkCommunitySearchForm = ->
    $("button.query").on 'click', ->
      form = $(@).attr('class')
      _hideShowBasicField(form)

  _hideShowBasicField = (form) ->
    if form.includes('community-advanced-search')
      $('#filter_form').hide()
      $('.float-right.pull-right').hide()
    else
      $('#filter_form').show()
      $('.float-right.pull-right').show()
      _hideCBasicFilters()

  _fixedHeaderTableColumns = ->
    sInfoShow = $('#sinfo').data('infoshow')
    sInfoTo = $('#sinfo').data('infoto')
    sInfoTotal = $('#sinfo').data('infototal')
    $('.communities-table').removeClass('table-responsive')
    if !$('table.communities tbody tr td').hasClass('noresults')
      $('table.communities').dataTable(
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
      $('.communities-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.communities-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4
        _handleResizeWindow()

  _getClientPath = ->
    return if $('table.communities tbody tr').text().trim() == 'No results found' || $('table.communities tbody tr').text().trim() == 'មិនមានលទ្ធផល' || $('table.communities tbody tr').text().trim() == 'No data available in table'
    $('table.communities tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa') || $(e.target).is('a')
      window.open($(@).data('href'), '_blank')

  _handleResizeWindow = ->
    window.dispatchEvent new Event('resize')

  { init: _init }
