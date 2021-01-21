CIF.CommunitiesIndex = do ->
  _init = ->
    _initSelect2()
    _initCheckbox()
    _handleUncheckColumnVisibility()
    _columnsVisibility()


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
      allCheckboxes = $('#community-advance-search').find('#new_community_grid ul input.i-checks')
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

  { init: _init }
