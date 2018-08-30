module AdvancedSearches
  class EnrollmentSqlBuilder

    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      field     = rule['field']
      @field    = field.split('_').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator = rule['operator']
      @value    = format_value(rule['value'])
      @type     = rule['type']
      @input_type    = rule['input']
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
          properties_result = client_enrollments.where("lower(properties ->> '#{@field}') = '#{@value.squish}' ")
        else
          properties_result = client_enrollments.where("properties -> '#{@field}' ? '#{@value.squish}' ")
        end
      when 'not_equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = client_enrollments.where.not("lower(properties ->> '#{@field}') = '#{@value.squish}' ")
        else
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '#{@value.squish}' ")
        end
      when 'less'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer? } < '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } <= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } > '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } >= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
      when 'not_contains'
        properties_result = client_enrollments.where("properties ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
      when 'is_empty'
        if @type == 'checkbox'
          properties_result = client_enrollments.where("properties -> '#{@field}' ? ''")
        else
          properties_result = client_enrollments.where("properties -> '#{@field}' ? '' OR properties -> '#{@field}' IS NULL")
        end
      when 'is_not_empty'
        if @type == 'checkbox'
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? ''")
        else
          properties_result = client_enrollments.where.not("properties -> '#{@field}' ? '' OR properties -> '#{@field}' IS NULL")
        end
      when 'between'
        properties_result = client_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
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
