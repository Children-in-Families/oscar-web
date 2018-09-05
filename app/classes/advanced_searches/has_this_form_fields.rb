module AdvancedSearches
  class HasThisFormFields

    include AdvancedSearchHelper

    def initialize(custom_form_ids)
      @custom_form_ids = custom_form_ids

      @drop_down_type_list  = []
      generate_field_by_type
    end

    def render
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.drop_list_options(item.first.gsub('"', '&qoute;'), format_label(item.first) , item.last, format_optgroup(item.first)) }

      results = drop_list_fields
      results.sort_by { |f| f[:label].downcase }
      results
    end

    def generate_field_by_type
      custom_forms = CustomField.where(id: @custom_form_ids)
      custom_forms.each do |custom_form|
        # binding.pry
        @drop_down_type_list << custom_form.form_title
        # custom_form.form_title.each do |json_field|
        #   binding.pry
        #   json_field['label'] = json_field['label'].gsub('&amp;', '&').gsub('&lt;', '<').gsub('&gt;', '>')
        #   drop_list_values = []
        #   drop_list_values << "enrollment_#{custom_form.name}_#{json_field['label']}"
        #   drop_list_values << json_field['values'].map{|value| { value['label'] => value['label'].gsub('&amp;qoute;', '&quot;') }}
        #   @drop_down_type_list << drop_list_values
        # end

      end
    end

    private

    def format_label(value)
      value.split('_').last
    end

    def format_optgroup(value)
      name = value.split('_').second
      key_word = format_header('enrollment')
      "#{name} | #{key_word}"
    end
  end
end
