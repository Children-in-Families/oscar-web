class CIF.AdvancedFilterBuilder
  constructor: (element, fieldList, filterTranslation) ->
    @element            = element
    @fieldList          = fieldList
    @filterTranslation  = filterTranslation

  initRule: ->
    $(@element).queryBuilder(@builderOption())

  builderOption: ->
    inputs_separator: ' AND '
    icons:
      remove_rule: 'fa fa-minus'
    lang:
      delete_rule: ' '
      add_rule: @filterTranslation.addFilter
      add_group: @filterTranslation.addGroup
      delete_group: @filterTranslation.deleteGroup
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
    filters: @fieldList
    plugins:
      'sortable': true
