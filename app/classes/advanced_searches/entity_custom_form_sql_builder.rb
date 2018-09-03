module AdvancedSearches
  class EntityCustomFormSqlBuilder

    def initialize(selected_custom_form, rule, entity_type)
      @selected_custom_form = selected_custom_form
      field          = rule['field']
      @field         = field.split('_').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator      = rule['operator']
      @value         = rule['value'].is_a?(Array) || rule['value'].is_a?(Fixnum) ? rule['value'] : rule['value'].gsub("'", "''")
      @type          = rule['type']
      @input_type    = rule['input']
      @entity_type   = entity_type
    end

    def get_sql
      custom_formable_type = @entity_type.titleize
      sql_string = "#{@entity_type.pluralize}.id IN (?)"
      custom_field_properties = CustomFieldProperty.where(custom_formable_type: custom_formable_type, custom_field_id: @selected_custom_form)

      type_format = ['select', 'radio-group', 'checkbox-group']
      if type_format.include?(@input_type)
        @value = @value.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      end

      case @operator
      when 'equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = custom_field_properties.where("lower(properties ->> '#{@field}') = '#{@value.downcase.squish}' ")
        else
          properties_result = custom_field_properties.where("properties -> '#{@field}' ? '#{@value.squish}' ")
        end
      when 'not_equal'
        if @input_type == 'text' && @field.exclude?('&')
          properties_result = custom_field_properties.where.not("lower(properties ->> '#{@field}') = '#{@value.downcase}' ")
        else
          properties_result = custom_field_properties.where.not("properties -> '#{@field}' ? '#{@value.squish}' ")
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
        properties_result = custom_field_properties.where("properties ->> '#{@field}' ILIKE '%#{@value.squish}%' ")
      when 'not_contains'
        properties_result = custom_field_properties.where("properties ->> '#{@field}' NOT ILIKE '%#{@value.squish}%' ")
      when 'is_empty'
        if @type == 'checkbox'
          properties_result = custom_field_properties.where("properties -> '#{@field}' ? ''")
        else
          properties_result = custom_field_properties.where("properties -> '#{@field}' ? '' OR properties -> '#{@field}' IS NULL")
        end
      when 'is_not_empty'
        if @type == 'checkbox'
          properties_result = custom_field_properties.where.not("properties -> '#{@field}' ? ''")
        else
          properties_result = custom_field_properties.where.not("properties -> '#{@field}' ? '' OR properties -> '#{@field}' IS NULL")
        end
      when 'between'
        properties_result = custom_field_properties.where("(properties ->> '#{@field}')#{ '::int' if integer? } BETWEEN '#{@value.first}' AND '#{@value.last}' AND properties ->> '#{@field}' != ''")
      end
      entity_ids = properties_result.pluck(:custom_formable_id).uniq
      { id: sql_string, values: entity_ids }
    end

    private

    def integer?
      @type == 'integer'
    end
  end
end
