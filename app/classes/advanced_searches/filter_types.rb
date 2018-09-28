module AdvancedSearches
  class FilterTypes
    def self.text_options(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        operators: ['equal', 'not_equal', 'contains', 'not_contains', 'is_empty', 'is_not_empty']
      }
    end

    def self.number_options(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'integer',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty']
      }
    end

    def self.date_picker_options(field_name, label, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'date',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty'],
        plugin: 'datepicker',
        plugin_config: {
          format: 'yyyy-mm-dd',
          todayBtn: 'linked',
          todayHighlight: true,
          autoclose: true
        }
      }
    end

    def self.drop_list_options(field_name, label, values, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        operators: ['equal', 'not_equal', 'is_empty', 'is_not_empty']
      }
    end

    def self.has_this_form_drop_list_options(field_name, label, values, group)
      {
        id: field_name,
        optgroup: group,
        label: label,
        input: 'select',
        values: values,
        operators: ['equal']
      }
    end
  end
end
