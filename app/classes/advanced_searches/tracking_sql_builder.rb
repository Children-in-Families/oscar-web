module AdvancedSearches
  class TrackingSqlBuilder
    include FormBuilderHelper
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
      sql_string = 'clients.id IN (?)'
      properties_field = 'client_enrollment_trackings.properties'
      client_enrollment_trackings = ClientEnrollmentTracking.joins(:client_enrollment).where(tracking_id: @tracking_id)

      selected_program_stream = $param_rules['program_selected'].presence ? JSON.parse($param_rules['program_selected']) : []
      basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results      = mapping_form_builder_param_value(basic_rules, 'tracking')

      query_string  = get_query_string(results, 'tracking', properties_field)

      properties_result = client_enrollment_trackings.joins(:client_enrollment).where(client_enrollments: { program_stream_id: selected_program_stream, status: 'Active' }).where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))

      client_ids = properties_result.pluck('client_enrollments.client_id').uniq
      {id: sql_string, values: client_ids}
    end
  end
end
