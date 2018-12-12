CIF.Data_trackersIndex = do ->
  _init = ->
    _submitPerPageParams()
    _initProgramRule()
    _initSelect2()
    _handleDisabledInputs()

  _submitPerPageParams = ->
    $('#per_page_form form select').on 'change', ->
      $('#per_page_form form').submit();

  _initProgramRule = ->
    return false unless $('#after, #before').length > 0
    $.ajax
      url: '/api/program_stream_add_rule/get_fields'
      method: 'GET'
      success: (response) ->
        fieldList = response.program_stream_add_rule
        $('#program-rules-before').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        $('#program-rules-after').queryBuilder(
          _queryBuilderOption(fieldList)
        )
        setTimeout ( ->
          _handleRemoveButtonOnProgramRules()
          _handleDisabledInputs()
          )

        _handleSetRules()

  _initSelect2 = ->
    $('select').select2()

  _handleSetRules = ->
    rules = $('#rule-before').data('program-rules')
    unless $.isEmptyObject(rules)
      rules = {} if _.isEmpty(rules.rules)
    $('#program-rules-before').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

    rules = $('#rule-after').data('program-rules')
    unless $.isEmptyObject(rules)
      rules = {} if _.isEmpty(rules.rules)
    $('#program-rules-after').queryBuilder('setRules', rules) unless $.isEmptyObject(rules)

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
    $('#program-rules-before').find('button').remove()
    $('#program-rules-after').find('button').remove()

  _handleDisabledInputs = ->
    $('.modal-body .rules-group-container').find('input, select, textarea, .group-conditions label').attr( 'disabled', 'disabled' )

  { init: _init }
