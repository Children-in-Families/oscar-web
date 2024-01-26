module AdvancedSearches
  class ClientAdvancedSearch
    def initialize(basic_rules, clients, overdue_assessment = false)
      @clients = clients
      @basic_rules = basic_rules.is_a?(String) ? JSON.parse(basic_rules) : basic_rules
      @overdue_assessment = overdue_assessment
    end

    def filter
      query_array = []
      rules = []
      client_base_sql = AdvancedSearches::ClientBaseSqlBuilder.new(@clients, @basic_rules).generate
      query_array << client_base_sql[:sql_string]
      client_base_sql[:values].each { |v| query_array << v }

      if client_base_sql[:sql_string].first.present?
        if @basic_rules['rules'].any? { |param| param.key?('rules') }
          rules << @basic_rules['rules'].first
          rules << @basic_rules['rules'].last['rules']
        else
          rules = @basic_rules['rules'].reject { |hash_value| hash_value['id'] != 'active_program_stream' }
          rules = rules.present? ? rules : @basic_rules
        end

        if rules.compact.any? { |rule| !rule.is_a?(Array) && rule.key?('rules') }
          rule_hash = {}
          rules = rules.compact.first.each { |k, v| rule_hash[k] = v if k == 'rules' }
          operators = rule_hash['rules'].map { |value| value['operator'] }.uniq if rules.present?
        elsif rules.present? && rules.is_a?(Array)
          operators = rules.flatten.compact.map { |value| value['operator'] }.uniq if rules.present?
        else
          operators = @basic_rules['rules'].flatten.compact.map { |value| value['operator'] }.uniq if rules.present?
        end

        if @basic_rules['condition'] == 'AND' && rules.count > 1 && operators.presence.reject(&:nil?).sort == ['not_equal', 'equal'].sort && @basic_rules['rules'].any? { |hash| hash['id'] == 'enrolled_program_stream' }
          if rules.is_a?(Hash) && (rules.key?(:rules) || rules.key?('rules'))
            excluded_client_ids = rules['rules'].flatten.map { |rule| rule['value'] if rule['operator'] == 'not_equal' }
          else
            excluded_client_ids = rules.flatten.map { |rule| rule['value'] if rule['operator'] == 'not_equal' }
          end
        end
      end

      [@clients.where(query_array), query_array]
    end
  end
end
