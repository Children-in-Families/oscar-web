class CIF.AdvancedFilterBuilder
  constructor: (element, fieldList, filterTranslation) ->
    @element            = element
    @fieldList          = fieldList
    @filterTranslation  = filterTranslation

  initRule: ->
    $(@element.selector).queryBuilder(@builderOption(@element.selector))
    $(@element.selector).on 'afterAddGroup.queryBuilder', (parent, addRule, level) ->
      if $('body#clients-index').length
        if localStorage.getItem(addRule.id) == addRule.id
          addRule.$el.addClass('csi-group')
          $("##{addRule.id} .group-conditions label.btn-primary").attr('disabled', 'disabled')

        window.customGroup["#{addRule.id}"] = addRule if window.customGroup["#{addRule.id}"] == undefined
        $('#builder_group_0').find('.rules-group-body .btn-custom-group').hide()
        $('#builder_group_0').find('.rules-group-body .btn-default-group').hide()

    $(@element.selector).on 'beforeDeleteGroup.queryBuilder', (parent, group) ->
      if $('body#clients-index').length
        localStorage.setItem("#{group.id}", null)
      if $('body#families-index').length
        localStorage.setItem("#{group.id}", null)

  builderOption: (builderId)->
    $(builderId).queryBuilder
      operators: $.fn.queryBuilder.constructor.DEFAULTS.operators.concat([
        {
          type: 'average'
          nb_inputs: 1
          multiple: false
          apply_to: [ 'string' ]
        }
        {
          type: 'assessment_has_changed'
          nb_inputs: 2
          multiple: false
          apply_to: [ 'number' ]
        }
        {
          type: 'assessment_has_not_changed'
          nb_inputs: 2
          multiple: false
          apply_to: [ 'number' ]
        }
        {
          type: 'month_has_changed'
          nb_inputs: 2
          multiple: false
          apply_to: [ 'string' ]
        }
        {
          type: 'month_has_not_changed'
          nb_inputs: 2
          multiple: false
          apply_to: [ 'string' ]
        }
      ])
      templates:
        group:
          '\
          <div id="{{= it.group_id }}" class="rules-group-container">
            <div class="rules-group-header">
              <div class="btn-group pull-right group-actions">
                <button type="button" class="btn btn-xs btn-success btn-add-rule" data-add="rule">
                  <i class="{{= it.icons.add_rule }}"></i> {{= it.translate("add_rule") }}
                </button>
                {{? it.settings.allow_groups===-1 || it.settings.allow_groups>=it.level }}
                  <button type="button" class="btn btn-xs btn-success btn-default-group" data-add="group">
                    <i class="{{= it.icons.add_group }}"></i> {{= it.translate("add_group") }}
                  </button>
                {{?}}

                <button type="button" class="btn btn-xs btn-success btn-custom-group">
                  <i class="{{= it.icons.add_group }}"></i> {{= it.translate("add_custom_group") }}
                </button>

                {{? it.level>1 }}
                  <button type="button" class="btn btn-xs btn-danger" data-delete="group">
                    <i class="{{= it.icons.remove_group }}"></i> {{= it.translate("delete_group") }}
                  </button>
                {{?}}
              </div>
              <div class="btn-group group-conditions">
                {{~ it.conditions: condition }}
                  <label class="btn btn-xs btn-primary">
                    <input type="radio" name="{{= it.group_id }}_cond" value="{{= condition }}"> {{= it.translate("conditions", condition) }}
                  </label>
                {{~}}
              </div>
              {{? it.settings.display_errors }}
                <div class="error-container"><i class="{{= it.icons.error }}"></i></div>
              {{?}}
            </div>
            <div class=rules-group-body>
              <div class=rules-list></div>
            </div>
          </div>'
      inputs_separator: ' AND '
      icons:
        remove_rule: 'fa fa-minus'
      lang:
        delete_rule: ' '
        add_rule: @filterTranslation.addFilter
        add_group: @filterTranslation.addGroup
        add_custom_group: 'Add Assessment Filter'
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
          average: 'average'
          assessment_has_changed: 'score has changed between assessment#'
          assessment_has_not_changed: 'score has not changed between assessment#'
          month_has_changed: 'score has changed between month#'
          month_has_not_changed: 'score has not changed between month#'
      filters: @fieldList
      plugins:
        'sortable': { 'inherit_no_sortable': false, 'inherit_no_drop': false }

  setRuleFromSavedSearch: ->
    self = @
    advancedSearchId = $('#advanced_search_id').val()
    if advancedSearchId and advancedSearchId.length > 0
      rules = $("a[data-save-search-#{advancedSearchId}]").data("save-search-#{advancedSearchId}")
      $('button.client-advance-search').click()
      self.handleAddHotlineFilter()
      $('.program-stream-column li.visibility, .hotline-call-column li.visibility, .assessment-column li.visibility').each ->
        fieldCheckedBoxValue = $($(this).find('input')[0]).val()
        values = self.getSaveSearchFields(rules.rules)
        $($(this).find('input')[0]).iCheck('check') if values.includes(fieldCheckedBoxValue)

      $(@element.selector).queryBuilder('setRules', rules) unless _.isEmpty(rules.rules)

    return

  handleAddHotlineFilter: ->
    fields = $('#hotline-fields').data('fields')
    if $('#hotline-checkbox').is(':checked')
      $(@element.selector).queryBuilder('addFilter', fields)
      return

  getSaveSearchFields: (rules)->
    results = []
    cb = (e) ->
      results.push e.id
      e.rules and e.rules.forEach(cb)
      return

    rules.forEach(cb)
    return results
