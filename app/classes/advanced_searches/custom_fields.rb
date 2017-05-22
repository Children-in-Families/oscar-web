module AdvancedSearches
  class CustomFields

    include AdvancedSearchHelper

    def initialize(options = {})
      @text_type_list = []
      @number_type_list = []
      @date_type_list = []
      @drop_down_type_list = []

      @result = []
      @user = options[:user]
      @custom_form_id = options[:custom_form_id]
      generate_field_by_type
    end

    def render
      number_fields       = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item, item) }
      text_fields         = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item, item) }
      date_picker_fields  = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item, item) }
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first, item.first , item.last) }
      search_fields       = text_fields + drop_list_fields + number_fields + date_picker_fields

      search_fields.sort_by { |f| f[:label] }
    end

    def generate_field_by_type
      custom_fields = CustomField.find(@custom_form_id).fields
      custom_fields.each do |json_field|
        if json_field['type'] == 'text' || json_field['type'] == 'textarea'
          @text_type_list << json_field['label']
        elsif json_field['type'] == 'number'
          @number_type_list << json_field['label']
        elsif json_field['type'] == 'date'
          @date_type_list << json_field['label']
        elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
          drop_list_values = []
          drop_list_values << json_field['label']
          drop_list_values << json_field['values'].map{|value| { value['label'] => value['label'] }}
          @drop_down_type_list << drop_list_values
        end
      end
    end
  end
end
