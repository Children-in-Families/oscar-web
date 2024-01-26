module AdvancedSearches
  class CustomDataSqlBuilder
    include FormBuilderHelper
    include ClientsHelper

    def initialize(objects, rule)
      @objects = objects
      field = rule['field']
      @the_field = rule['id']
      @field = field.split('__').last.gsub("'", "''").gsub('&qoute;', '"').gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;')
      @operator = rule['operator']
      @type = rule['type']
      @input_type = rule['input']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      properties_field = 'client_custom_data.properties'
      if @operator != 'is_empty'
        client_custom_data = @objects.joins(:client_custom_data).all
      else
        client_custom_data = @objects.joins('LEFT OUTER JOIN client_custom_data ON client_custom_data.client_id = clients.id')
      end

      basic_rules = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
      basic_rules = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
      results = mapping_form_builder_param_value(basic_rules, 'custom_data')
      query_string = get_query_string(results, 'custom_data', properties_field)

      properties_result = client_custom_data.where(query_string.reject(&:blank?).join(" #{basic_rules['condition']} "))

      object_ids = properties_result.ids
      { id: sql_string, values: object_ids }
    end
  end
end
