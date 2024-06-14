module AdvancedSearches
  class ExitProgramSqlBuilder
    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      field = rule['field']
      @field = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator = rule['operator']
      @value = format_value(rule['value'])
      @input_type = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      leave_programs = LeaveProgram.joins(:client_enrollment).where(program_stream_id: @program_stream_id)

      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(@input_type)
        @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      case @operator
      when 'equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = leave_programs.where("lower(leave_programs.properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = leave_programs.where("leave_programs.properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'not_equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = leave_programs.where.not("lower(leave_programs.properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? '#{@value}'")
        end
      when 'less'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::numeric' if integer?} < '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::numeric' if integer?} <= '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::numeric' if integer?} > '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::numeric' if integer?} >= '#{@value}' AND leave_programs.properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = leave_programs.where("leave_programs.properties ->> '#{@field}' ILIKE '%#{@value}%' ")
      when 'not_contains'
        properties_result = leave_programs.where("leave_programs.properties ->> '#{@field}' NOT ILIKE '%#{@value}%' ")
      when 'is_empty'
        if @type == 'checkbox'
          properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? ''")
          client_ids = properties_result.pluck('client_enrollments.client_id').uniq
        else
          properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? '' OR (leave_programs.properties -> '#{@field}') IS NULL")
          client_ids = properties_result.pluck('client_enrollments.client_id').uniq
        end

        client_ids = Client.where.not(id: client_ids).ids
        return { id: sql_string, values: client_ids }
      when 'is_not_empty'
        if @type == 'checkbox'
          properties_result = leave_programs.where.not("leave_programs.properties -> '#{@field}' ? ''")
        else
          properties_result = leave_programs.where("leave_programs.properties -> '#{@field}' IS NOT NULL AND leave_programs.properties ->> '#{@field}' <> '' AND leave_programs.properties ->> '#{@field}' <> '{}' AND leave_programs.properties ->> '#{@field}' <> '[]'")
        end
      when 'between'
        properties_result = leave_programs.where("(leave_programs.properties ->> '#{@field}')#{'::numeric' if integer?} BETWEEN '#{@value.first}' AND '#{@value.last}' AND leave_programs.properties ->> '#{@field}' != ''")
      end

      client_ids = properties_result.pluck('client_enrollments.client_id').uniq
      { id: sql_string, values: client_ids }
    end

    private

    def integer?
      @type == 'integer'
    end

    def format_value(value)
      value.is_a?(Array) || value.is_a?(Fixnum) ? value : value.gsub("'", "''")
    end
  end
end
