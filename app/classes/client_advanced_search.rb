class ClientAdvancedSearch
  def initialize(search_rules, clients)
    @condition = search_rules[:condition]
    @clients   = clients
    @rules     = search_rules[:rules]
  end

  def filter
    client_sql = ClientBaseSqlBuilder.generate(@clients, @rules)
    query_string = client_sql[:sql_string].join(" #{@condition} ")
    query_array  = client_sql[:values].prepend(query_string)
    @clients.where(query_array)
  end
end
