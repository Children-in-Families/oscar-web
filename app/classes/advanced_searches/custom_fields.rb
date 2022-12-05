module AdvancedSearches
  class CustomFields
    include AdvancedSearchHelper
    attr_reader :attach_with
    def initialize(custom_form_ids, attach_with = 'Client')
      @custom_form_ids = custom_form_ids
      @number_type_list     = []
      @text_type_list       = []
      @date_type_list       = []
      @drop_down_type_list  = []
      @attach_with          = attach_with

      generate_field_by_type
      address_translation
    end

    def render
      number_fields       = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      text_fields         = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      date_picker_fields  = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first.gsub('"', '&qoute;'), format_label(item.first) , item.last, format_optgroup(item.first)) }

      results = text_fields + drop_list_fields + number_fields + date_picker_fields
    end

    def generate_field_by_type
      if attach_with == 'Community'
        @custom_fields = CustomField.cached_custom_form_ids_attach_with(@custom_form_ids, attach_with)
      else
        @custom_fields = CustomField.cached_custom_form_ids(@custom_form_ids)
      end

      @custom_fields.each do |custom_field|
        custom_field.fields.each do |json_field|
          json_field['label'] = json_field['label'].gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
          if json_field['type'] == 'text' || json_field['type'] == 'textarea'
            @text_type_list << "formbuilder__#{custom_field.form_title}__#{json_field['label']}"
          elsif json_field['type'] == 'number'
            @number_type_list << "formbuilder__#{custom_field.form_title}__#{json_field['label']}"
          elsif json_field['type'] == 'date'
            @date_type_list << "formbuilder__#{custom_field.form_title}__#{json_field['label']}"
          elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
            drop_list_values = []
            drop_list_values << "formbuilder__#{custom_field.form_title}__#{json_field['label']}"
            drop_list_values << json_field['values'].map{|value| { value['label'] => value['label'].gsub('&amp;qoute;', '&quot;') }}
            @drop_down_type_list << drop_list_values
          end
        end
      end
    end

    private

    def format_label(value)
      value.split('__').last
    end

    def format_optgroup(value)
      form_title = value.split('__').second
      key_word = format_header('custom_form')
      "#{form_title} | #{key_word}"
    end
  end
end
