class CIF.AdvancedFilterBuilder
  constructor: (element, fieldList, filterTranslation) ->
    @element            = element
    @fieldList          = fieldList
    @filterTranslation  = filterTranslation

  initRule: ->
    $(@element).queryBuilder(@builderOption())
    $('#builder').on 'afterAddGroup.queryBuilder', (parent, addRule, level) ->
      window.customGroup["#{addRule.id}"] = addRule if window.customGroup["#{addRule.id}"] == undefined

  builderOption: ->
    $('#builder').queryBuilder
      operators: $.fn.queryBuilder.constructor.DEFAULTS.operators.concat([
        {
          type: 'average'
          nb_inputs: 1
          multiple: false
          apply_to: [ 'string' ]
        }
        {
          type: 'has_changed'
          nb_inputs: 1
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
                  Add CSI Filter
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
          has_changed: 'has changed'
      filters: @fieldList
      plugins:
        'sortable': true
