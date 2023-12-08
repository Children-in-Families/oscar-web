module AdvancedSearches
  class CustomDataFields
    include AdvancedSearchHelper

    def initialize()
      @number_type_list ||= []
      @text_type_list ||= []
      @date_type_list ||= []
      @drop_down_type_list ||= []

      generate_field_by_type
    end

    def render
      number_fields = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item.first, format_label(item.second), format_header('custom_data')) }
      text_fields = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item.first, format_label(item.second), format_header('custom_data')) }
      date_picker_fields = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item.first, format_label(item.second), format_header('custom_data')) }
      drop_list_fields = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, format_label(item.second), item.last, format_header('custom_data')) }

      results = text_fields + drop_list_fields + number_fields + date_picker_fields
    end

    def generate_field_by_type
      custom_data = CustomData.first
      (custom_data.try(:fields) || []).each do |json_field|
        @number_type_list
        if json_field['type'] == 'text' || json_field['type'] == 'textarea'
          @text_type_list << ["custom_data__#{json_field['name']}", json_field['label']]
        elsif json_field['type'] == 'number'
          @number_type_list << ["custom_data__#{json_field['name']}", json_field['label']]
        elsif json_field['type'] == 'date'
          @date_type_list << ["custom_data__#{json_field['name']}", json_field['label']]
        elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
          drop_list_values = []
          drop_list_values << "custom_data__#{json_field['name']}"
          drop_list_values << json_field['label']
          drop_list_values << json_field['values'].map { |value| { value['label'] => value['label'].gsub('&amp;qoute;', '&quot;') } }
          @drop_down_type_list << drop_list_values
        end
      end
    end

    private

    def format_label(value)
      value.gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
    end
  end
end
