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
        sql_string = '? != ANY (exit_reasons)'
      when 'is_empty'
        properties_result = leave_programs.where("leave_programs.properties -> '#{@field}' ? '' ")
      when 'is_not_empty'
        properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? '' ")
      end

      {id: sql_string, values: @value}
    end
  end
end
