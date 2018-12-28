CIF.PartnersIndex = do ->
  _init = ->
    _fixedHeaderTableColumns()
    _handleScrollTable()
    _getPartnerPath()
    _initSelect2()
    _handleAutoCollapse()
    _toggleCollapseFilter()
    _checkPartnerSearchForm()
    _columnsVisibility()
    _handleColumnVisibilityParams()
    # _handleUncheckColumnVisibility()
    _initAdavanceSearchFilter()
    _hidePartnerFilters()
    _setDefaultCheckColumnVisibilityAll()
    _initCheckbox()

  _initCheckbox = ->
    $('.i-checks').iCheck
      checkboxClass: 'icheckbox_square-green'
      radioClass: 'iradio_square-green'

  _initAdavanceSearchFilter = ->
    advanceFilter = new CIF.ClientAdvanceSearch()
    advanceFilter.initBuilderFilter('#partner-builder-fields')
    advanceFilter.setValueToBuilderSelected()
    advanceFilter.getTranslation()

    advanceFilter.handleShowCustomFormSelect()
    advanceFilter.customFormSelectChange()
    advanceFilter.customFormSelectRemove()
    advanceFilter.handleHideCustomFormSelect()

    advanceFilter.handlePartnerSearch()
    advanceFilter.addRuleCallback()
    advanceFilter.filterSelectChange()
    advanceFilter.filterSelecting()

    advanceFilter.handleSaveQuery()
    advanceFilter.validateSaveQuery()

  _columnsVisibility = ->
    $('.columns-visibility').click (e) ->
      e.stopPropagation()

    allCheckboxes = $('.all-visibility .all_')

    for checkBox in allCheckboxes
      $(checkBox).on 'ifChecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('check')
      $(checkBox).on 'ifUnchecked', ->
        $(@).parents('.columns-visibility').find('.visibility input[type=checkbox]').iCheck('uncheck')

  _checkPartnerSearchForm = ->
    $("button.query").on 'click', ->
      form = $(@).attr('class')
      if form.includes('partner-advance-search')
        $('#filter_form').hide()
      else
        $('#filter_form').show()

  _handleUncheckColumnVisibility = ->
    params = window.location.search.substr(1)

    if params.includes('partner_advanced_search')
      allCheckboxes = $('#partner-search-form').find('#new_partner_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')
    else
      allCheckboxes = $('#partner-advance-search-form').find('#new_partner_grid ul input.i-checks')
      $(allCheckboxes).iCheck('uncheck')

  _handleColumnVisibilityParams = ->
    $('button#search').on 'click', ->
      allCheckboxes = $('#partner-search-form').find('#new_partner_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

    $('input.datagrid-submit').on 'click', ->
      allCheckboxes = $('#partner-advance-search-form').find('#new_partner_grid ul input[type=checkbox]')
      $(allCheckboxes).attr('disabled', true)

  _setDefaultCheckColumnVisibilityAll = ->
    if $('#partner-search-form .visibility .checked').length == 0
      $('#partner-search-form .all-visibility .all_').iCheck('check')

    if $('#partner-advance-search-form .visibility .checked').length == 0
      $('#partner-advance-search-form .all-visibility .all_').iCheck('check')

  _handleAutoCollapse = ->
    params = window.location.search.substr(1)
    if params.includes('partner_advanced_search')
      $("button[data-target='#partner-advance-search-form']").trigger('click')
    else
      $("button[data-target='#partner-search-form']").trigger('click')

  _hidePartnerFilters = ->
    $('#partner-advance-search-form #filter_form').hide()

  _toggleCollapseFilter = ->
    $('#partner-search-form').on 'show.bs.collapse', ->
      $('#partner-advance-search-form').collapse('hide')

    $('#partner-advance-search-form').on 'show.bs.collapse', ->
      $('#partner-search-form').collapse('hide')

  _initSelect2 = ->
    $('select').select2
      allowClear: true

  _fixedHeaderTableColumns = ->
    $('.partners-table').removeClass('table-responsive')
    if !$('table.partners tbody tr td').hasClass('noresults')
      $('table.partners').dataTable(
        'bPaginate': false
        'bFilter': false
        'bInfo': false
        'bSort': false
        'sScrollY': 'auto'
        'bAutoWidth': true
        'sScrollX': '100%')
    else
      $('.partners-table').addClass('table-responsive')

  _handleScrollTable = ->
    $(window).load ->
      ua = navigator.userAgent
      unless /Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini|Mobile|mobile|CriOS/i.test(ua)
        $('.partners-table .dataTables_scrollBody').niceScroll
          scrollspeed: 30
          cursorwidth: 10
          cursoropacitymax: 0.4

  _getPartnerPath = ->
    return if $('table.partners tbody tr').text().trim() == 'No results found' || $('table.partners tbody tr').text().trim() == 'មិនមានលទ្ធផល'
    $('table.partners tbody tr').click (e) ->
      return if $(e.target).hasClass('btn') || $(e.target).hasClass('fa')
      window.location = $(this).data('href')

  { init: _init }
