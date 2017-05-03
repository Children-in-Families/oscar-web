class ClientAdvancedSearch
  def initialize(basic_rules, custom_form_rules, clients)
    @condition          = basic_rules[:condition]
    @clients            = clients
    @basic_rules        = basic_rules
    @custom_form        = custom_form_rules
  end

  def filter
    query_array         = []
    client_base_sql     = ClientBaseSqlBuilder.generate(@clients, @basic_rules)
    custom_form_sql     = ClientCustomFormSqlBuilder.generate(@custom_form)

    if client_base_sql[:sql_string].present? && custom_form_sql[:id].present?
      query_string = ([client_base_sql[:sql_string]] + [custom_form_sql[:id]]).join(" AND ")
    else
      query_string = client_base_sql[:sql_string].present? ? client_base_sql[:sql_string] : custom_form_sql[:id]
    end
    client_base_values  = client_base_sql[:values]
    custom_form_values  = custom_form_sql[:values]

    query_array << query_string
    client_base_values.map{ |v| query_array << v }
    custom_form_values.map{ |v| query_array << v }

    @clients.where(query_array)
  end

end
