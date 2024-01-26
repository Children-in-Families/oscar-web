module AdvancedSearches
  class FilterTypes
    OVERDUE_FIELDS = %w(has_overdue_assessment has_overdue_forms has_overdue_task no_case_note assessment_condition_last_two assessment_condition_first_last incomplete_care_plan)
    def self.text_options(field_name, label, group)
      {
        id: field_name,
        field: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        operators: ['equal', 'not_equal', 'contains', 'not_contains', 'is_empty', 'is_not_empty']
      }
    end

    def self.number_options(field_name, label, group)
      {
        id: field_name,
        field: field_name,
        optgroup: group,
        label: label,
        type: 'integer',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty', 'is_not_empty']
      }
    end

    def self.date_picker_options(field_name, label, group)
      {
        id: field_name,
        field: field_name,
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
      foramted_data = format_data(field_name, values)
      is_association = is_association?(field_name, values)
      {
        id: field_name,
        field: field_name,
        optgroup: group,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        plugin: 'select2',
        data: { values: foramted_data, isAssociation: is_association },
        operators: OVERDUE_FIELDS.include?(field_name) ? ['equal'] : ['equal', 'not_equal', 'is_empty', 'is_not_empty']
      }
    end

    def self.has_this_form_drop_list_options(field_name, label, values, group)
      foramted_data = format_data(field_name, values)
      {
        id: field_name,
        field: field_name,
        optgroup: group,
        label: label,
        input: 'select',
        values: values,
        plugin: 'select2',
        data: { values: foramted_data, isAssociation: false },
        operators: ['equal']
      }
    end

    def self.format_data(field_name, values)
      data = []
      case field_name
      when 'birth_province_id'
        values.each do |value|
          data << { value[:value] => value[:label] }
        end
      when 'gender', 'has_been_in_orphanage', 'has_been_in_government_care'
        data = values.map { |key, value| { key => value } }
      else
        data = values
      end
      data
    end

    def self.is_association?(field, values)
      begin
        values.each do |value|
          next if Integer value.keys[0]
        end
        return true
      rescue
        special_case_fields = ['birth_province_id', 'gender', 'has_been_in_orphanage', 'has_been_in_government_care']
        return true if field.in? special_case_fields
        return false
      end
    end
  end
end
