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
      client_base_sql[:values].each{ |v| query_array << v }

      if client_base_sql[:sql_string].first.present?
        rules = @basic_rules["rules"].reject {|hash_value| hash_value["id"] != "active_program_stream" }
        operators = rules.map{|value| value["operator"] }.uniq
        if @basic_rules["condition"] == "AND" && rules.count > 1 && operators.sort == ["not_equal", "equal"].sort
          # client_ids = @clients.joins(:client_enrollments).where(query_array).group(:id).having('count(client_enrollments) = 1').ids

          excluded_client_ids = rules.map{|rule| rule['value'] if rule['operator'] == 'not_equal'}
          clients = @clients.joins(:client_enrollments).where(client_enrollments: { status: 'Active' }).where(query_array).reject do |client|
            client_enrollment_ids = client.client_enrollments.map(&:program_stream_id)
            client_enrollment_ids.any? { |e| excluded_client_ids.compact.include?(e.to_s) }
          end
          return @clients.where(id: clients.map(&:id))
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
