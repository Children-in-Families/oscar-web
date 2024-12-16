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
        if @sensitivity_fields.include?(@field)
          clients = @clients.joins(:enter_ngos).where("lower(shared_clients.#{@field}) = ?", @values.downcase.squish)
        else
          clients = @clients.joins(:enter_ngos).group(:id).having("COUNT(enter_ngos.*) = #{@number_of_referral}").where("enter_ngos.#{@field} = ?", @values)
        end
      when 'not_equal'
        if @sensitivity_fields.include?(@field)
          clients = @clients.joins(:enter_ngos).where.not("lower(shared_clients.#{@field}) = ?", @values.downcase.squish)
        else
          clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} = ?", @values.squish)
        end
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
        if @blank_fields.include?(@field)
          clients = @clients.joins(:enter_ngos).where("shared_clients.#{@field} IS NULL")
        else
          clients = @clients.joins(:enter_ngos).where("(shared_clients.#{@field} IS NULL OR shared_clients.#{@field} = '')")
        end
      when 'is_not_empty'
        if @blank_fields.include?(@field)
          clients = @clients.joins(:enter_ngos).where.not("shared_clients.#{@field} IS NULL")
        else
          clients = @clients.joins(:enter_ngos).where.not("(shared_clients.#{@field} IS NULL OR shared_clients.#{@field} = '')")
        end
      when 'between'
        clients = @clients.joins(:enter_ngos).where("shared_clients.#{@field} BETWEEN ? AND ?", @values.first, @values.last)
      end
      { id: sql_string, values: clients.pluck(:slug) }
    end
  end
end
