module AdvancedSearches
  class ExitReasonsSqlBuilder

    def initialize(clients, rule)
      @clients = clients
      field          = rule['field']
      @field         = field.split('_').last
      @operator      = rule['operator']
      @value         = rule['value']
    end

    def get_sql
      case @operator
      when 'equal'
        sql_string = '? = ANY (exit_reasons)'
      when 'not_equal'
        sql_string = "NOT (? = ANY (exit_reasons)) AND NOT ((exit_reasons is null or exit_reasons = '{}'))"
      when 'is_empty'
        sql_string = "exit_reasons = '{}' OR exit_reasons is null"
      when 'is_not_empty'
        sql_string = "NOT (exit_reasons is null or exit_reasons = '{}')"
      end

      {id: sql_string, values: @value}
    end
  end
end
