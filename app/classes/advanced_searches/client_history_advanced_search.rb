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

      start_date = @history_date[:start_date].to_date.beginning_of_day
      end_date = @history_date[:end_date].to_date.end_of_day

      client_ids = ClientHistory.where(client_base_sql).where(created_at: start_date..end_date).uniq{|a| a.object['id']}.map { |history| history.object['id'] }

      @clients.where(id: client_ids)
    end
  end
end
