module AdvancedSearches
  class ClientCustomFormSqlBuilder

    def initialize(selected_custom_form, rule)
      @selected_custom_form = selected_custom_form
      field          = rule['field']
      @field         = field.split('_').last.gsub("'", "''").gsub(/\[/, '&#91;').gsub(/\]/, '&#93;')
      @operator      = rule['operator']
      @value         = rule['value'].is_a?(Array) ? rule['value'] : rule['value'].gsub("'", "''")
      @type          = rule['type']
      @input_type    = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      custom_field_properties = CustomFieldProperty.where(custom_formable_type: 'Client', custom_field_id: @selected_custom_form)

      case @operator
      when 'equal'
        if @input_type == 'text'
          properties_result = custom_field_properties.where("lower(properties ->> '#{@field}') = '#{@value.downcase}' ")
        else
          properties_result = custom_field_properties.where("properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'not_equal'
        if @input_type == 'text'
          properties_result = custom_field_properties.where.not("lower(properties ->> '#{@field}') = '#{@value.downcase}' ")
        else
          properties_result = custom_field_properties.where.not("properties -> '#{@field}' ? '#{@value}' ")
        end
      when 'less'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{'::int' if integer? } < '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'less_or_equal'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{ '::int' if integer? } <= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{ '::int' if integer? } > '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'greater_or_equal'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{ '::int' if integer? } >= '#{@value}' AND properties ->> '#{@field}' != '' ")
      when 'contains'
        properties_result = custom_field_properties.where("properties ->> '#{@field}' ILIKE '%#{@value}%' ")
      when 'not_contains'
        properties_result = custom_field_properties.where("properties ->> '#{@field}' NOT ILIKE '%#{@value}%' ")
      when 'is_empty'
        properties_result = custom_field_properties.where("properties -> '#{@field}' ? '' ")
      when 'is_not_empty'
        properties_result = custom_field_properties.where.not("properties -> '#{@field}' ? '' ")
      when 'between'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{ '::int' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
      end
      client_ids = properties_result.pluck(:custom_formable_id).uniq
      {id: sql_string, values: client_ids}
    end

    private
    def integer?
      @type == 'integer'
    end
  end
end
