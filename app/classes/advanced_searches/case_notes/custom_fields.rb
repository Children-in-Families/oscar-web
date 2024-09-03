module AdvancedSearches
  module CaseNotes
    class CustomFields < ::AdvancedSearches::CustomFields
      def initialize
        @number_type_list     = []
        @text_type_list       = []
        @date_type_list       = []
        @drop_down_type_list  = []

        find_custom_fields
        generate_field_by_type
        address_translation
      end

      def generate_field_by_type
        @custom_field.fields.each do |json_field|
          json_field['label'] = json_field['label'].gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
          
          if json_field['type'] == 'text' || json_field['type'] == 'textarea'
            @text_type_list << "case_note_custom_field__#{@custom_field.id}__#{json_field['label']}"
          elsif json_field['type'] == 'number'
            @number_type_list << "case_note_custom_field__#{@custom_field.id}__#{json_field['label']}"
          elsif json_field['type'] == 'date'
            @date_type_list << "case_note_custom_field__#{@custom_field.id}__#{json_field['label']}"
          elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
            drop_list_values = []
            drop_list_values << "case_note_custom_field__#{@custom_field.id}__#{json_field['label']}"
            drop_list_values << json_field['values'].map{ |value| { value['label'] => value['label'].gsub('&amp;qoute;', '&quot;') } }
            @drop_down_type_list << drop_list_values
          end
        end
      end
      
      private

      def format_optgroup(_value)
        format_header('case_note')
      end

      def find_custom_fields
        @custom_field = ::CaseNotes::CustomField.first
      end
    end
  end
end
