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
      clients = @clients.joins(:quantitative_cases).where(quantitative_cases: { quantitative_type_id: @field_value })

      case @operator
      when 'equal'
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
