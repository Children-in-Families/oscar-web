module AdvancedSearches
  class TrackingSqlBuilder

    def initialize(tracking_id, rule)
      @tracking_id   = tracking_id
      field          = rule['field']
      @field         = field.split('_').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator      = rule['operator']
      @value         = format_value(rule['value'])
      @type          = rule['type']
      @input_type    = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      properties_field = 'client_enrollment_trackings.properties'
      client_enrollment_trackings = ClientEnrollmentTracking.joins(:client_enrollment).where(tracking_id: @tracking_id)

      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(@input_type)
        @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      case @operator
      when 'equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = client_enrollment_trackings.where("lower(#{properties_field} ->> '#{@field}') = '#{@value.squish}' ")
        else
          properties_result = client_enrollment_trackings.where("#{properties_field} -> '#{@field}' ? '#{@value.squish}' ")
        end
      when 'not_equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = client_enrollment_trackings.where.not("lower(#{properties_field} ->> '#{@field}') = '#{@value}' ")
        else
          properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? '#{@value}' ")
        end
      when 'less'
        properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{'::numeric' if integer? } < '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } <= '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } > '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } >= '#{@value}' AND #{properties_field} ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = client_enrollment_trackings.where("#{properties_field} ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
      when 'not_contains'
        properties_result = client_enrollment_trackings.where("#{properties_field} ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
      when 'is_empty'
        if @type == 'checkbox'
          properties_result = client_enrollment_trackings.where("#{properties_field} -> '#{@field}' ? ''")
        else
          properties_result = client_enrollment_trackings.where("#{properties_field} -> '#{@field}' ? '' OR #{properties_field} -> '#{@field}' IS NULL")
        end
      when 'is_not_empty'
        if @type == 'checkbox'
          properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? ''")
        else
          properties_result = client_enrollment_trackings.where.not("#{properties_field} -> '#{@field}' ? '' OR #{properties_field} -> '#{@field}' IS NULL")
        end
      when 'between'
        properties_result = client_enrollment_trackings.where("(#{properties_field} ->> '#{@field}')#{ '::numeric' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND #{properties_field} ->> '#{@field}' != ''")
      end
      client_ids = properties_result.pluck('client_enrollments.client_id').uniq
      {id: sql_string, values: client_ids}
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
