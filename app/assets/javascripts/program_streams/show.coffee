CIF.Program_streamsShow = do ->
  _init = ->
    _initProgramRule()
    _initSelect2()
  
  _initProgramRule = ->
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rules').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        setTimeout ( ->
          _handleRemoveButtonOnProgramRules()
          )
        _handleSetRules()

  _initSelect2 = ->
    $('select').select2()

  _handleSetRules = ->
    rules = $('#rules').data('program-rules')
    rules = JSON.parse(rules.replace(/=>/g, ':'))
    $('#program-rules').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

  _queryBuilderOption = (fieldList) ->
    inputs_separator: ' AND '
    lang:
      operators:
        is_empty: 'is blank'
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
  { init: _init }