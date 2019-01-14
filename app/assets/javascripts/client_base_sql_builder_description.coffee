class CIF.ClientBaseSqlBuilderDescription
  constructor: (result) ->
    @condition = result['condition']
    @rules     = result['rules'] || []
    # console.log result
    # @stringText = ''
    # @result = JSON.stringify(result, null, 2)

  explain: ->
    # stringText = @stringText
    # console.log @rules.length
    # console.log @rules
    for rule in @rules
      field    = rule['field']
      operator = rule['operator']
      value    = rule['value']
      # rule     = rule['rules']
      # stringText = field + ' ' + operator + ' ' + value + ' '

    #
    #   # console.log stringText
    #   debugger
      if field != undefined
        stringText = field + ' ' + operator + ' ' + value + ' '
        console.log stringText
      else
        # GOOD JOB
        filter = new CIF.ClientBaseSqlBuilderDescription(rule)
        filter.explain()
    # console.log stringText
    # console.log @condition
    # console.log JSON.stringify(@result, null, 2)
