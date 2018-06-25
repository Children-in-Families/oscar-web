module AdvancedSearches
  class ClientAdvancedSearch
    def initialize(basic_rules, clients, overdue_assessment = false)
      @clients            = clients
      @basic_rules        = basic_rules
      @overdue_assessment = overdue_assessment
    end

    def filter
      query_array         = []
      client_base_sql     = AdvancedSearches::ClientBaseSqlBuilder.new(@clients, @basic_rules).generate

      query_array << client_base_sql[:sql_string]
      # client_ids = overdue_assessment_clients if @overdue_assessment == 'true'
      client_base_values  = client_base_sql[:values].map{ |v| query_array << v }
      @clients.where(query_array)
    end

    # def overdue_assessment_clients
    #   ids = []
    #   Client.joins(:assessments).all_active_types.each do |c|
    #     ids << c.id if c.next_assessment_date < Date.today
    #   end
    #   ids
    # end
  end
end
