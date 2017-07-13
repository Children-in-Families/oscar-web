module AdvancedSearches
  class ClientCustomFormSqlBuilder

    def initialize(selected_custom_form, rules)
      @sql_string = []
      @values = []
      @custom_form_rules    = rules[:rules]
      @selected_custom_form = selected_custom_form
      @condition = rules[:condition]
    end

    def generate
      get_sql if @custom_form_rules.present?
      @sql_string = @sql_string.join(" #{@condition} ")

      @sql_string = "(#{@sql_string})" if @sql_string.present?

      {id: @sql_string, values: @values}
    end

    private

    def get_sql
      sql_string = 'clients.id IN (?)'
      custom_field_properties = CustomFieldProperty.where(custom_formable_type: 'Client', custom_field_id: @selected_custom_form)

      @custom_form_rules.each do |rule|
        field = rule[:field].gsub("'", "''")
        value = rule[:value].is_a?(Array) ? rule[:value] : rule[:value].gsub("'", "''")
        @type = rule[:type]
        if rule[:field] != nil
          case rule[:operator]
          when 'equal'
            properties_result = custom_field_properties.where("properties -> '#{field}' ? '#{value}' ")
          when 'not_equal'
            properties_result = custom_field_properties.where.not("properties -> '#{field}' ? '#{value}' ")
          when 'less'
            properties_result = custom_field_properties.where("(properties ->> '#{field}')#{'::int' if integer? } < '#{value}' AND properties ->> '#{field}' != '' ")
          when 'less_or_equal'
            properties_result = custom_field_properties.where("(properties ->> '#{field}')#{ '::int' if integer? } <= '#{value}' AND properties ->> '#{field}' != '' ")
          when 'greater'
            properties_result = custom_field_properties.where("(properties ->> '#{field}')#{ '::int' if integer? } > '#{value}' AND properties ->> '#{field}' != '' ")
          when 'greater_or_equal'
            properties_result = custom_field_properties.where("(properties ->> '#{field}')#{ '::int' if integer? } >= '#{value}' AND properties ->> '#{field}' != '' ")
          when 'contains'
            properties_result = custom_field_properties.where("properties ->> '#{field}' ILIKE '%#{value}%' ")
          when 'not_contains'
            properties_result = custom_field_properties.where("properties ->> '#{field}' NOT ILIKE '%#{value}%' ")
          when 'is_empty'
            properties_result = custom_field_properties.where("properties -> '#{field}' ? '' ")
          when 'between'
            properties_result = custom_field_properties.where("(properties ->> '#{field}')#{ '::int' if integer? } BETWEEN '#{value.first}' AND '#{value.last}' AND properties ->> '#{field}' != ''")
          end
          @sql_string << sql_string
          @values     << properties_result.pluck(:custom_formable_id).uniq
        else
          nested_query = AdvancedSearches::ClientCustomFormSqlBuilder.new(@selected_custom_form, rule).generate
          @sql_string << nested_query[:id]
          nested_query[:values].select { |v| @values << v}
        end
      end
    end

    private
    def integer?
      @type == 'integer'
    end
  end
end
