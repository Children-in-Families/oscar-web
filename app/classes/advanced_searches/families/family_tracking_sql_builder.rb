module AdvancedSearches
  module Families
    class FamilyTrackingSqlBuilder
      include FormBuilderHelper
      include FamiliesHelper
      include ClientsHelper
  
      def initialize(tracking_id, rule, program_name=nil)
        @tracking_id   = tracking_id
        field          = rule['field']
        @the_field     = rule['id']
        @field         = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        @operator      = rule['operator']
        @type          = rule['type']
        @input_type    = rule['input']
        @program_name  = program_name
      end
  
      def get_sql
        sql_string = 'families.id IN (?)'
        properties_field = 'enrollment_trackings.properties'
        if @operator != 'is_empty'
          enrollment_trackings = EnrollmentTracking.joins(:enrollment).where(tracking_id: @tracking_id)
        else
          enrollment_trackings = EnrollmentTracking.joins("LEFT OUTER JOIN enrollments ON enrollments.id = enrollment_trackings.enrollment_id")
        end
  
  
        selected_program_stream = $param_rules['program_selected'].presence ? JSON.parse($param_rules['program_selected']) : []
        basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
        results      = mapping_form_builder_param_value(basic_rules, 'tracking')
  
        query_string  = get_query_string(results, 'tracking', properties_field)
  
        if @operator != 'is_empty'
          properties_result = enrollment_trackings.where(enrollments: { program_stream_id: selected_program_stream }).where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
        else
          properties_result = enrollment_trackings.where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))
        end
  
        family_ids = properties_result.pluck('enrollments.programmable_id').uniq
        {id: sql_string, values: family_ids}
      end
    end
  end
end
