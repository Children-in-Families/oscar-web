module AdvancedSearches
  class QuantitativeCaseSqlBuilder

    def initialize(clients, rule)
      @clients      = clients
      field         = rule['field']
      @field_value  = field.split('__').last
      @operator     = rule['operator']
      @value        = rule['value']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      quantitative = QuantitativeType.find_by(name: @field_value)
      clients = @clients.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: quantitative.id })

      # results = []

      # @basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      # basic_rules   = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
      # results       = mapping_allowed_param_value(basic_rules, "quantitative__#{quantitative&.id}")
      # query_string  = get_any_query_string(results, 'quantitative_cases')
      # sql           = query_string.reject(&:blank?).map{|query| "(#{query})" }.join(" #{basic_rules[:condition]} ")

      case @operator
      when 'equal'
        # clients = clients.where(sql)
        clients = clients.where(quantitative_cases: { id: @value })
      when 'not_equal'
        clients = clients.where.not(quantitative_cases: { id: @value })
      when 'is_empty'
        clients = @clients.where.not(id: clients.ids)
      when 'is_not_empty'
        clients
      end
      {id: sql_string, values: clients.ids}
    end
  end
end
