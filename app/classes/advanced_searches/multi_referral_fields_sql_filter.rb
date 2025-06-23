module AdvancedSearches
  class MultiReferralFieldsSqlFilter
    def initialize(clients, field, operator, values, sensitivity_fields, blank_fields)
      @clients = clients
      @field = field[/.*([^_\d])/]
      @number_of_referral = field[/\d$/]
      @operator = operator
      @values = values
      @sensitivity_fields = sensitivity_fields
      @blank_fields = blank_fields
    end

    def get_sql
      sql_string = 'clients.slug IN (?)'
      field_name = @field.gsub(/\d+$/, '') # Remove trailing digits from field name if present

      case @operator
      when 'equal'
        clients = find_clients_with_field_value('=', @values)
      when 'not_equal'
        clients = find_clients_with_field_value('!=', @values)
      when 'less'
        clients = find_clients_with_field_value('<', @values)
      when 'greater'
        clients = find_clients_with_field_value('>', @values)
      when 'less_or_equal'
        clients = find_clients_with_field_value('<=', @values)
      when 'greater_or_equal'
        clients = find_clients_with_field_value('>=', @values)
      when 'contains'
        clients = @clients.joins(:referral_histories)
                          .where(
                            "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) #{operator} ILIKE ?",
                            @number_of_referral.to_i - 1,
                            "%#{@values}%"
                          ).distinct
      when 'not_contains'
        clients = @clients.joins(:referral_histories)
                          .where(
                            "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) #{operator} NOT ILIKE ?",
                            @number_of_referral.to_i - 1,
                            "%#{@values}%"
                          ).distinct
      when 'is_empty'
        clients = @clients.joins(:referral_histories)
                          .where(
                            "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) IS NULL",
                            @number_of_referral.to_i - 1
                          ).distinct
      when 'is_not_empty'
        # Fix bellow query to check for non-empty values

        clients = @clients.joins(:referral_histories)
                          .where(
                            "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) IS NOT NULL",
                            @number_of_referral.to_i - 1

                          ).distinct
      when 'between'
        clients = @clients.joins(:referral_histories)
                          .where(
                            "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) BETWEEN ? AND ?",
                            @number_of_referral.to_i - 1,
                            @values.first,
                            @values.last
                          ).distinct
      end
      { id: sql_string, values: clients.pluck(:slug) }
    end

    private

    def find_clients_with_field_value(operator, value)
      field_name = @field.gsub(/\d+$/, '') # Remove trailing digits from field name if present
      @clients.joins(:referral_histories)
              .where(
                "(SELECT referral_histories.#{field_name} FROM referral_histories WHERE referral_histories.client_id = clients.id ORDER BY referral_histories.id ASC OFFSET ? LIMIT 1) #{operator} ?",
                @number_of_referral.to_i - 1,
                value
              ).distinct
    end
  end
end
