module AdvancedSearches
  class CustomFields

    include AdvancedSearchHelper

    def initialize(options = {})
      @number_type_list = []
      @text_type_list = []
      @date_type_list = []
      @drop_down_type_list = []
      generate_field_by_type
    end

    def render
      number_fields       = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, format_label(item)) }
      text_fields         = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, format_label(item)) }
      date_picker_fields  = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, format_label(item)) }
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_label(item.first) , item.last) }
      search_fields       = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label] }
    end

    def generate_field_by_type
      CustomField.all.each do |custom_field|
        title = custom_field.form_title
        custom_field.fields.each do |json_field|
          if json_field['type'] == 'text' || json_field['type'] == 'textarea'
            @text_type_list << "formbuilder_#{title}_#{json_field['label']}"
          elsif json_field['type'] == 'number'
            @number_type_list << "formbuilder_#{title}_#{json_field['label']}"
          elsif json_field['type'] == 'date'
            @date_type_list << "formbuilder_#{title}_#{json_field['label']}"
          elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
            drop_list_values = []
            drop_list_values << "formbuilder_#{title}_#{json_field['label']}"
            drop_list_values << json_field['values'].map{|value| { value['label'] => value['label'] }}
            @drop_down_type_list << drop_list_values
          end
        end
      end
    end

    private
    def format_label(value)
      value = value.split('_').last(2)
      value.join('-')
    end
  end
end
