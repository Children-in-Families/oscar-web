module AdvancedSearches
  class ClientHistoryAdvancedSearch
    def initialize(basic_rules, custom_form_rules, client_histories, date_range = [])
      @condition   = basic_rules[:condition]
      @client_histories = client_histories
      @basic_rules = basic_rules
      @custom_form = custom_form_rules
      @date_range  = date_range
    end

    def filter
      query_array         = []
      client_base_sql     = AdvancedSearches::ClientHistoryBaseSqlBuilder.new(@client_histories, @basic_rules, @date_range).generate
      # custom_form_sql     = AdvancedSearches::ClientCustomFormSqlBuilder.new(@custom_form[:selected_custom_form], @custom_form).generate

      # binding.pry
      # query_string = client_base_sql[:sql_string].present? ? client_base_sql[:sql_string] : custom_form_sql[:id]
      # if client_base_sql[:sql_string].present? && custom_form_sql[:id].present?
      #   query_string = ([client_base_sql[:sql_string]] + [custom_form_sql[:id]]).join(" AND ")
      # else
      #   query_string = client_base_sql[:sql_string].present? ? client_base_sql[:sql_string] : custom_form_sql[:id]
      # end
      # client_base_values  = client_base_sql[:values]
      # custom_form_values  = custom_form_sql[:values]

      # query_array << query_string
      # client_base_values.map{ |v| query_array << v }
      # custom_form_values.map{ |v| query_array << v }
      binding.pry
      @client_histories.where(client_base_sql)
    end
  end
end
