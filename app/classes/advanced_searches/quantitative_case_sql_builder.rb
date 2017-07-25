module AdvancedSearches
  class QuantitativeCaseSqlBuilder

    def initialize(clients, rule)
      @clients = clients
      field     = rule['field']
      @field    = field.split('_').last
      @operator = rule['operator']
      @value    = rule['value']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      clients = @clients.joins(:client_quantitative_cases)

      case @operator
      when 'equal'
        clients = clients.where(client_quantitative_cases: {quantitative_case_id: @value})
      when 'not_equal'
        clients = clients.where.not(client_quantitative_cases: {quantitative_case_id: @value})
      when 'is_empty'
        ids = @clients.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: @field }).ids
        clients = @clients.where.not(id: ids)
      when 'is_not_empty'
        clients = @clients.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: @field })
      end
      {id: sql_string, values: clients.ids}
    end
  end
end
