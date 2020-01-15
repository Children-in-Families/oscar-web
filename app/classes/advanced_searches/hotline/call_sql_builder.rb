module AdvancedSearches
  module Hotline
    class CallSqlBuilder
      def initialize()
        basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      end

      def get_sql
        sql_string = 'clients.id IN (?)'

        clients = Client.joins(:call)
        results = mapping_allowed_param_value(@basic_rules, Call::FIELDS)
        query_string = get_any_query_string(results, 'calls')
        binding.pry
        client_services = clients.where(query_string.reject(&:blank?).join(" AND ")).references(:services)

        { id: sql_string, values: client_services.ids.uniq }
      end

    end
  end
end
