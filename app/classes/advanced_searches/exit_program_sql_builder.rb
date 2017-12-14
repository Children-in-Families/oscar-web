module AdvancedSearches
  class ExitProgramSqlBuilder

    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      field          = rule['field']
      @field         = field.split('_').last.gsub(/\[/, '&#91;').gsub(/\]/, '&#93;')
      @operator      = rule['operator']
      @value         = rule['value']
      @input_type    = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      leave_programs = LeaveProgram.joins(:client_enrollment).where(program_stream_id: @program_stream_id)

      case @operator
      when 'equal'
        if @input_type == 'text'
          properties_result = leave_programs.where("lower(leave_programs.properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = leave_programs.where("leave_programs.properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'not_equal'
        if @input_type == 'text'
          properties_result = leave_programs.where.not("lower(leave_programs.properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? '#{@value}'")
        end
      when 'less'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::int' if integer? } < '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{ '::int' if integer? } <= '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{ '::int' if integer? } > '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{ '::int' if integer? } >= '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = leave_programs.where("leave_programs.properties ->> '#{@field}' ILIKE '%#{@value}%' ")
      when 'not_contains'
        properties_result = leave_programs.where("leave_programs.properties ->> '#{@field}' NOT ILIKE '%#{@value}%' ")
      when 'is_empty'
        properties_result = leave_programs.where("leave_programs.properties -> '#{@field}' ? '' ")
      when 'is_not_empty'
        properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? '' ")
      when 'between'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{ '::int' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND leave_programs.properties ->> '#{@field}' != ''")
      end
      client_ids = properties_result.pluck('client_enrollments.client_id').uniq
      {id: sql_string, values: client_ids}
    end

    private
    def integer?
      @type == 'integer'
    end

    def format_value(value)
      value.is_a?(Array) ? value : value.gsub("'", "''")
    end
  end
end
