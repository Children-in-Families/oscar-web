module AdvancedSearches
  class EnrollmentSqlBuilder
    def initialize(clients, program_stream_id, rule)
      @clients = clients
      @program_stream_id = program_stream_id
      field = rule['field']
      @field = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator = rule['operator']
      @value = format_value(rule['value'])
      @type = rule['type']
      @input_type = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      client_enrollments = ClientEnrollment.where(program_stream_id: @program_stream_id)

      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(@input_type)
        @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      case @operator
      when 'equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = client_enrollments.where("lower(properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = client_enrollments.where("properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'not_equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = client_enrollments.where.not("lower(properties ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'less'
        properties_result = client_enrollments.where("((properties ->> '#{@field}')#{'::numeric' if integer?} < '#{@value}' OR properties ->> 'Local_label #{@field}')#{'::numeric' if integer?} < '#{@value}') AND properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer?} <= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer?} > '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer?} >= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
      when 'not_contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
      when 'is_empty'
        if @type == 'checkbox'
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? ''")
          client_ids = properties_result.pluck(:client_id)
        else
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '' OR (properties -> '#{@field}') IS NULL")
          client_ids = properties_result.pluck(:client_id)
        end
        client_ids = @clients.where.not(id: client_ids).ids
        return { id: sql_string, values: client_ids }
      when 'is_not_empty'
        if @type == 'checkbox'
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? ''")
        else
          properties_result = client_enrollments.where("properties -> '#{@field}' IS NOT NULL AND properties ->> '#{@field}' <> '' AND properties ->> '#{@field}' <> '{}' AND properties ->> '#{@field}' <> '[]'")
        end
      when 'between'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer?} BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
      end
      client_ids = properties_result.pluck(:client_id).uniq
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
