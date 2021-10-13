module AdvancedSearches
  class EnrollmentDateSqlBuilder
    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      @operator = rule['operator']
      @value    = rule['value']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      client_enrollments = ClientEnrollment.where(program_stream_id: @program_stream_id)
      param_rules = JSON.parse($param_rules['basic_rules'])
      enrollment_rules = param_rules['rules'].select{|rules| rules['id'][/^(enrollment_)/].present? }
      query_string = enrollment_rules.map do |rules|
        client_enrollment_sql(rules['operator'], rules['field'], rules['value'], rules['input'], rules['type'])
      end.join(" #{param_rules['condition']} ")

      case @operator
      when 'equal'
        client_enrollment_date = client_enrollments.where(enrollment_date: @value)
      when 'not_equal'
        client_enrollment_date = client_enrollments.where.not(enrollment_date: @value)
      when 'less'
        client_enrollment_date = client_enrollments.where('enrollment_date < ?', @value)
      when 'less_or_equal'
        client_enrollment_date = client_enrollments.where('enrollment_date <= ?', @value)
      when 'greater'
        client_enrollment_date = client_enrollments.where('enrollment_date > ?', @value)
      when 'greater_or_equal'
        client_enrollment_date = client_enrollments.where('enrollment_date >= ?', @value)
      when 'is_empty'
        client_enrollment_date = ClientEnrollment.where.not(id: client_enrollments.ids)
      when 'is_not_empty'
        client_enrollment_date = client_enrollments
      when 'between'
        client_enrollment_date = client_enrollments.where('enrollment_date BETWEEN ? AND ?', @value.first, @value.last)
      end
      client_ids = client_enrollment_date.where(query_string).pluck(:client_id).uniq
      { id: sql_string, values: client_ids }
    end

    def client_enrollment_sql(operator, field, value, input_type, type)
      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(input_type)
        value = value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      case operator
      when 'equal'
        if input_type == 'text' && field.exclude?('&')
          properties_result = "lower(properties ->> '#{field}') = '#{alue}' "
        else
          properties_result = "properties -> '#{field}' ? '#{value}' "
        end
      when 'not_equal'
        if input_type == 'text' && field.exclude?('&')
          properties_result = "lower(properties ->> '#{field}') != '#{value}' "
        else
          properties_result = "NOT(properties -> '#{field}' ? '#{value}') "
        end
      when 'less'
        properties_result = "(properties ->> '#{field}')#{'::numeric' if integer? } < '#{value}' AND properties ->> '#{field}' != '' "
      when 'less_or_equal'
        properties_result = "(properties ->> '#{field}')#{ '::numeric' if integer? } <= '#{value}' AND properties ->> '#{field}' != '' "
      when 'greater'
        properties_result = "(properties ->> '#{field}')#{ '::numeric' if integer? } > '#{value}' AND properties ->> '#{field}' != '' "
      when 'greater_or_equal'
        properties_result = "(properties ->> '#{field}')#{ '::numeric' if integer? } >= '#{value}' AND properties ->> '#{field}' != '' "
      when 'contains'
        properties_result = "properties ->> '#{field}' ILIKE '%#{value.squish}%' "
      when 'not_contains'
        properties_result = "properties ->> '#{field}' NOT ILIKE '%#{value.squish}%' "
      when 'is_empty'
        if type == 'checkbox'
          properties_result = "properties -> '#{field}' ? ''"
        else
          properties_result = "properties -> '#{field}' ? '' OR (properties -> '#{field}') IS NULL"
        end
      when 'is_not_empty'
        if type == 'checkbox'
          properties_result = "NOT(properties -> '#{@field}' ? '')"
        else
          properties_result = "NOT(properties -> '#{@field}' ? '') OR (properties -> '#{@field}') IS NULL"
        end
      when 'between'
        properties_result = "(properties ->> '#{field}')#{ '::numeric' if integer? } BETWEEN '#{value.first}' AND '#{value.last}' AND properties ->> '#{field}' != ''"
      end
      properties_result
    end
  end
end
