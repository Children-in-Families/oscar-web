module AdvancedSearches
  class HasThisFormFields

    include AdvancedSearchHelper

    def initialize(custom_form_ids)
      @custom_form_ids = custom_form_ids

      @drop_down_type_list  = []
      generate_field_by_type
    end

    def render
      drop_list_fields    = @drop_down_type_list.map { |item| AdvancedSearches::FilterTypes.has_this_form_drop_list_options(item.first.gsub('"', '&qoute;'), format_label(item.first) , item.last, format_optgroup(item.first)) }

      results = drop_list_fields
      results.sort_by { |f| f[:label].downcase }
      results
    end

    def generate_field_by_type
      custom_forms = CustomField.where(id: @custom_form_ids)
      custom_forms.each do |custom_form|
        drop_list_values = []
        drop_list_values << "formbuilder__#{custom_form.form_title}__Has This Form"
        drop_list_values << { custom_form.form_title => custom_form.form_title}
        @drop_down_type_list << drop_list_values
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
