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

      case @operator
      when 'equal'
        clients = @clients.joins(:enter_ngos).where("(select #{@field} from enter_ngos where enter_ngos.client_id = clients.id ORDER BY enter_ngos.id asc OFFSET ?) = ?", @number_of_referral.to_i - 1, @values).distinct
      when 'not_equal'
        client_ids = @clients.joins(:enter_ngos).where("(select #{@field} from enter_ngos where enter_ngos.client_id = clients.id ORDER BY enter_ngos.id asc OFFSET ?) = ?", @number_of_referral.to_i - 1, @values).distinct.ids
        clients = @clients.where.not(id: client_ids)
      when 'less'
        clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} < ?", @values)
      when 'less_or_equal'
        clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} <= ?", @values)
      when 'greater'
        clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} > ?", @values)
      when 'greater_or_equal'
        clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} >= ?", @values)
      when 'contains'
        clients = @clients.joins(:enter_ngos).where("shared_clients.#{@field} ILIKE ?", "%#{@values.squish}%")
      when 'not_contains'
        clients = @clients.joins(:enter_ngos).where("shared_clients.#{@field} NOT ILIKE ?", "%#{@values.squish}%")
      when 'is_empty'
        clients = @clients.joins(:enter_ngos).where("(select #{@field} from enter_ngos where enter_ngos.client_id = clients.id ORDER BY enter_ngos.id asc OFFSET ?) = NULL", @number_of_referral.to_i - 1).distinct
      when 'is_not_empty'
        clients = @clients.joins(:enter_ngos).where("(select #{@field} from enter_ngos where enter_ngos.client_id = clients.id ORDER BY enter_ngos.id asc OFFSET ?) != NULL", @number_of_referral.to_i - 1).distinct
      when 'between'
        clients = @clients.joins(:enter_ngos).where("shared_clients.#{@field} BETWEEN ? AND ?", @values.first, @values.last)
      end
      { id: sql_string, values: clients.pluck(:slug) }
    end
  end
end
