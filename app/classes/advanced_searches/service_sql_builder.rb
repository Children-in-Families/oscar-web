module AdvancedSearches
  class ServiceSqlBuilder
    include FormBuilderHelper

    def initialize()
      basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    end

    def get_sql
      sql_string = 'clients.id IN (?)'

      program_stream_services = ProgramStreamService.includes([:program_stream, :service]).all

      results = mapping_program_stream_service_param_value(@basic_rules)
      query_string = get_program_service_query_string(results)

      program_stream_services = program_stream_services.where(query_string.reject(&:blank?).join(" AND ")).references(:program_streams)

      client_ids = program_stream_services.map{|pgs| pgs.program_stream.client_ids }.flatten.uniq

      { id: sql_string, values: client_ids }
    end

  end
end
