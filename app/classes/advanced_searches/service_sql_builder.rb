module AdvancedSearches
  class ServiceSqlBuilder
    include FormBuilderHelper

    def initialize
      basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
    end

    def get_sql
      sql_string = 'clients.id IN (?)'

      clients = Client.includes(program_streams: [program_stream_services: :service]).references(:services)

      results = mapping_program_stream_service_param_value(@basic_rules)
      query_string = get_program_service_query_string(results)

      client_services = clients.where(query_string.reject(&:blank?).join(' AND ')).references(:services)

      { id: sql_string, values: client_services.ids.uniq }
    end
  end
end
