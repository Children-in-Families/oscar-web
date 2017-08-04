CIF.Program_streamsShow = CIF.Program_streamsPreview = do ->
  _init = ->
    _initFileInput()
    _initProgramRule()
    _handleDisabledInputs()
    _initSelect2()

  _initProgramRule = ->
    rules = $('#rules').data('program-rules')
    return if $.isEmptyObject(rules)
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rules').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        setTimeout ( ->
          _initSelect2()
          _handleRemoveButtonOnProgramRules()
          _handleDisabledInputs()
          )

        _handleSetRules()

  _initFileInput = ->
    $('.file').fileinput
      showUpload: false
      removeClass: 'btn btn-danger btn-outline'
      browseLabel: 'Browse'
      theme: "explorer"

  _initSelect2 = ->
    $('.rule-filter-container select').select2(width: '220px')
    $('.rule-operator-container select, .rule-value-container select').select2(width: '180px')

  _handleSetRules = ->
    rules = $('#rules').data('program-rules')
    $('#program-rules').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

  _queryBuilderOption = (fieldList) ->
    inputs_separator: ' AND '
    lang:
      operators:
        is_empty: 'is blank'
        is_not_empty: 'is not blank'
        equal: 'is'
        not_equal: 'is not'
        less: '<'
        less_or_equal: '<='
        greater: '>'
        greater_or_equal: '>='
        contains: 'includes'
        not_contains: 'excludes'
    filters: fieldList

  _handleRemoveButtonOnProgramRules = ->
    $('.panel').find('#program-rules button').remove()

  _handleDisabledInputs = ->
    $('input, select, textarea').attr( 'disabled', 'disabled' )
    $('.rules-group-header .group-conditions label').attr('disabled', 'disabled')

  { init: _init }
