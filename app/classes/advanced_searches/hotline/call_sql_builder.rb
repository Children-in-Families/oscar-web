module AdvancedSearches
  module Hotline
    class CallSqlBuilder
      def initialize()
        basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        @basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      end

      def get_sql
        sql_string = 'clients.id IN (?)'

        results      = mapping_allowed_param_value(@basic_rules, Call::FIELDS)
        query_string = get_any_query_string(results, 'calls')
        sql          = query_string.reject(&:blank?).map{|query| "(#{query})" }.join(" #{@basic_rules[:condition]} ")
        client_ids = Client.includes(calls: :call_protection_concerns).where(sql).references(:calls).distinct.ids

        { id: sql_string, values: client_ids }
      end

    end
  end
end
