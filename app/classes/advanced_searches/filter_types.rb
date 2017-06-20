module AdvancedSearches
  class FilterTypes
    def self.text_options(options = {})
      form_title = options[:form_title]
      form_field = options[:form_label]

      # form = CustomField.find_by(id: custom_field_id).try(:created_at)
      # field_name = custom_field_id.present? ? "custom-field-#{label}" : field_name
      id = form_title.present? ? "custom-field-#{form_title}" : ''
      {
        field: form_field,
        id: id,
        label: form_title,
        type: 'string',
        operators: ['equal', 'not_equal', 'contains', 'not_contains', 'is_empty']
      }  
    end

    # def self.text_options(field_name, label, custom_field_id = nil)
    #   form = CustomField.find_by(id: custom_field_id).try(:created_at)
    #   field_name = custom_field_id.present? ? "custom-field-#{label}" : field_name
    #   {
    #     field: label,
    #     id: field_name,
    #     label: label,
    #     type: 'string',
    #     operators: ['equal', 'not_equal', 'contains', 'not_contains', 'is_empty']
    #   }
    # end

    def self.number_options(field_name, label, custom_field_id = nil)
      form = CustomField.find_by(id: custom_field_id).try(:created_at)
      field_name = custom_field_id.present? ? "custom-field-#{label}" : field_name
      {
        field: label,
        id: field_name,
        label: label,
        type: 'integer',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty']
      }
    end

    def self.date_picker_options(field_name, label, custom_field_id = nil)
      form = CustomField.find_by(id: custom_field_id).try(:created_at)
      field_name = custom_field_id.present? ? "custom-field-#{label}" : field_name
      {
        field: label,
        id: field_name,
        label: label,
        type: 'date',
        operators: ['equal', 'not_equal', 'less', 'less_or_equal', 'greater', 'greater_or_equal', 'between', 'is_empty'],
        plugin: 'datepicker',
        plugin_config: {
          format: 'yyyy-mm-dd',
          todayBtn: 'linked',
          todayHighlight: true,
          autoclose: true
        }
      }
    end

    def self.drop_list_options(field_name, label, values, custom_field_id = nil)
      form = CustomField.find_by(id: custom_field_id).try(:created_at)
      field_name = custom_field_id.present? ? "custom-field-#{label}" : field_name
      {
        field: label,
        id: field_name,
        label: label,
        type: 'string',
        input: 'select',
        values: values,
        operators: ['equal', 'not_equal', 'is_empty']
      }
    end
  end
end
