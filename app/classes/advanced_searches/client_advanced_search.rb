module AdvancedSearches
  class ClientAdvancedSearch
    def initialize(basic_rules, clients, overdue_assessment = false)
      @clients                = clients
      @basic_rules            = basic_rules
      @overdue_assessment     = overdue_assessment
    end

    def filter
      query_array         = []

      client_base_sql     = AdvancedSearches::ClientBaseSqlBuilder.new(@clients, @basic_rules).generate

      query_array << client_base_sql[:sql_string]
      # client_ids = overdue_assessment_clients if @overdue_assessment == 'true'
      if client_base_sql.first.present?
        rules = @basic_rules["rules"].reject {|hash_value| hash_value["id"] != "active_program_stream" }
        operators = rules.map{|value| value["operator"] }.uniq
        if @basic_rules["condition"] == "AND" && rules.count > 1 && operators.sort == ["not_equal", "equal"].sort
          result = []
          client_base_sql[:values].each do |client_ids|
            if result.size > client_ids.size
              result = result - client_ids
            else
              result = client_ids - result
            end
          end
          client_base_sql[:values].each{ |v| query_array << result }
        else
          client_base_sql[:values].each{ |v| query_array << v }
        end
      end

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
