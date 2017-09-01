module AdvancedSearches
  class ClientHistoryAdvancedSearch
    def initialize(basic_rules, clients, history_date)
      @clients            = clients
      @basic_rules        = basic_rules
      @history_date       = history_date
    end

    def filter
      query_array         = []
      client_base_sql     = AdvancedSearches::ClientHistoryBaseSqlBuilder.new(@clients, @basic_rules, @history_date).generate

      client_ids = ClientHistory.where(client_base_sql).where('date(created_at)': @history_date['start_date']..@history_date['end_date']).uniq{|a| a.object['id']}.map { |history| history.object['id'] }

      @clients.where(id: client_ids)
    end
  end
end
