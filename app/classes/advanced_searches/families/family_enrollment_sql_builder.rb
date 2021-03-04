module AdvancedSearches
  module Families
    class FamilyEnrollmentSqlBuilder

      def initialize(program_stream_id, rule)
        @program_stream_id = program_stream_id
        field     = rule['field']
        @field    = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        @operator = rule['operator']
        @value    = format_value(rule['value'])
        @type     = rule['type']
        @input_type    = rule['input']
      end
  
      def get_sql
        sql_string = 'families.id IN (?)'
        family_enrollments = Enrollment.where(program_stream_id: @program_stream_id)
  
        type_format = ['select', 'radio-group', 'checkbox-group']
        if type_format.include?(@input_type)
          @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
        end
  
        case @operator
        when 'equal'
          if @input_type == 'text' && @field.exclude?('&')
            properties_result = family_enrollments.where("lower(properties ->> '#{@field}') = '#{@value}' ")
          else
            properties_result = family_enrollments.where("properties -> '#{@field}' ? '#{@value}' ")
          end
        when 'not_equal'
          if @input_type == 'text' && @field.exclude?('&')
            properties_result = family_enrollments.where.not("lower(properties ->> '#{@field}') = '#{@value}' ")
          else
            properties_result = family_enrollments.where.not("properties -> '#{@field}' ? '#{@value}' ")
          end
        when 'less'
          properties_result = family_enrollments.where("(properties ->> '#{@field}')#{'::numeric' if integer? } < '#{@value}' AND properties ->> '#{@field}' != '' ")
        when 'less_or_equal'
          properties_result = family_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } <= '#{@value}' AND properties ->> '#{@field}' != '' ")
        when 'greater'
          properties_result = family_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } > '#{@value}' AND properties ->> '#{@field}' != '' ")
        when 'greater_or_equal'
          properties_result = family_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } >= '#{@value}' AND properties ->> '#{@field}' != '' ")
        when 'contains'
          properties_result = family_enrollments.where("properties ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
        when 'not_contains'
          properties_result = family_enrollments.where("properties ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
        when 'is_empty'
          if @type == 'checkbox'
            properties_result = family_enrollments.where.not("properties -> '#{@field}' ? ''")
            family_ids        = properties_result.pluck(:programmable_id)
          else
            properties_result = family_enrollments.where.not("properties -> '#{@field}' ? '' OR (properties -> '#{@field}') IS NULL")
            family_ids        = properties_result.pluck(:programmable_id)
          end
          family_ids          = Family.where.not(id: family_ids).ids
          return { id: sql_string, values: family_ids }
        when 'is_not_empty'
          if @type == 'checkbox'
            properties_result = family_enrollments.where.not("properties -> '#{@field}' ? ''")
          else
            properties_result = family_enrollments.where.not("properties -> '#{@field}' ? '' OR (properties -> '#{@field}') IS NULL")
          end
        when 'between'
          properties_result = family_enrollments.where("(properties ->> '#{@field}')#{ '::numeric' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
        end
        family_ids = properties_result.pluck(:programmable_id).uniq
        { id: sql_string, values: family_ids }
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
end
