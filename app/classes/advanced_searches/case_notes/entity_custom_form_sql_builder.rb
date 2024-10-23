module AdvancedSearches
  module CaseNotes
    class EntityCustomFormSqlBuilder
      include FormBuilderHelper
      include ClientsHelper

      def initialize(selected_custom_form, rule)
        @selected_custom_form = selected_custom_form
        field          = rule['field']
        @field         = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        @operator      = rule['operator']
        @type          = rule['type']
        @input_type    = rule['input']
      end

      def get_sql
        sql_string = "clients.id IN (?)"

        return { id: sql_string, values: [] } if $param_rules.blank?

        properties_field = 'case_notes_custom_field_properties.properties'
        custom_field_properties = ::CaseNotes::CustomFieldProperty.where(custom_field_id: @selected_custom_form&.id)

        basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
        results      = mapping_form_builder_param_value(basic_rules, 'case_note_custom_field')

        query_string  = get_query_string(results, 'formbuilder', properties_field)
        sql           = query_string.reverse.reject(&:blank?).map{|sql| "(#{sql})" }.join(" AND ")
        properties_result = custom_field_properties.where(sql)

        object_ids = properties_result.pluck(:custom_formable_id).uniq

        { id: sql_string, values: object_ids }
      end
    end
  end
end
