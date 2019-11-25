module AdvancedSearches
  class TrackingSqlBuilder
    include FormBuilderHelper
    include ClientsHelper

    def initialize(tracking_id, rule)
      @tracking_id   = tracking_id
      field          = rule['field']
      @the_field     = rule['id']
      @field         = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator      = rule['operator']
      @value         = format_value(rule['value'])
      @type          = rule['type']
      @input_type    = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      properties_field = 'client_enrollment_trackings.properties'
      client_enrollment_trackings = ClientEnrollmentTracking.joins(:client_enrollment).where(tracking_id: @tracking_id)

      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(@input_type)
        @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results      = mapping_form_builder_param_value(basic_rules, 'tracking')

      query_string  = get_query_string(results, 'tracking', properties_field)

      properties_result = client_enrollment_trackings.where(query_string.reject(&:blank?).join(" AND "))

      client_ids = properties_result.pluck('client_enrollments.client_id').uniq
      {id: sql_string, values: client_ids}
    end

    private

    def format_value(value)
      value.is_a?(Array) || value.is_a?(Fixnum) ? value : value.gsub("'", "''")
    end
  end
end
