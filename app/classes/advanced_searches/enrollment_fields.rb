module AdvancedSearches
  class EnrollmentFields

    include AdvancedSearchHelper

    def initialize(program_ids)
      @program_ids = program_ids

      @number_type_list     = []
      @text_type_list       = []
      @date_type_list       = []
      @drop_down_type_list  = []
      @enrollment_data_list = []

      generate_field_by_type
      address_translation
    end

    def render
      number_fields       = @number_type_list.map { |item| AdvancedSearches::FilterTypes.number_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      text_fields         = @text_type_list.map { |item| AdvancedSearches::FilterTypes.text_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      date_picker_fields  = @date_type_list.map { |item| AdvancedSearches::FilterTypes.date_picker_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first.gsub('"', '&qoute;'), format_label(item.first) , item.last, format_optgroup(item.first)) }

      results = text_fields + drop_list_fields + number_fields + date_picker_fields

      @enrollment_data_list.map{ |item|results.unshift AdvancedSearches::FilterTypes.date_picker_options(item.gsub('"', '&qoute;'), format_label(item), format_optgroup(item)) }

      results
    end

    def generate_field_by_type
      program_streams = ProgramStream.cached_program_ids(@program_ids)

      program_streams.each do |program_stream|
        @enrollment_data_list << "enrollmentdate__#{program_stream.name}__Enrollment Date"
        program_stream.enrollment.each do |json_field|
          json_field['label'] = json_field['label'].gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
          if json_field['type'] == 'text' || json_field['type'] == 'textarea'
            @text_type_list << "enrollment__#{program_stream.name}__#{json_field['label']}"
          elsif json_field['type'] == 'number'
            @number_type_list << "enrollment__#{program_stream.name}__#{json_field['label']}"
          elsif json_field['type'] == 'date'
            @date_type_list << "enrollment__#{program_stream.name}__#{json_field['label']}"
          elsif json_field['type'] == 'select' || json_field['type'] == 'checkbox-group' || json_field['type'] == 'radio-group'
            drop_list_values = []
            drop_list_values << "enrollment__#{program_stream.name}__#{json_field['label']}"
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
      name = value.split('__').second
      key_word = format_header('enrollment')
      "#{name} | #{key_word}"
    end
  end
end
