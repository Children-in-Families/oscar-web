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
        clients = @clients.joins(:enter_ngos)
                          .where(
                            "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) #{operator} ILIKE ?",
                            @number_of_referral.to_i - 1,
                            "%#{@values}%"
                          ).distinct
      when 'not_contains'
        clients = @clients.joins(:enter_ngos)
                          .where(
                            "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) #{operator} NOT ILIKE ?",
                            @number_of_referral.to_i - 1,
                            "%#{@values}%"
                          ).distinct
      when 'is_empty'
        clients = @clients.joins(:enter_ngos)
                          .where(
                            "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) = NULL",
                            @number_of_referral.to_i - 1
                          ).distinct
      when 'is_not_empty'
        clients = @clients.joins(:enter_ngos)
                          .where(
                            "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) != NULL",
                            @number_of_referral.to_i - 1

                          ).distinct
      when 'between'
        clients = @clients.joins(:enter_ngos)
                          .where(
                            "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) BETWEEN ? AND ?",
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
      @clients.joins(:enter_ngos)
              .where(
                "(SELECT enter_ngos.#{field_name} FROM enter_ngos WHERE enter_ngos.client_id = clients.id ORDER BY enter_ngos.id ASC OFFSET ? LIMIT 1) #{operator} ?",
                @number_of_referral.to_i - 1,
                value
              ).distinct
    end
  end
end
