module AdvancedSearches
  class MultiReferralFieldsSqlFilter
    def initialize(field, operator, values, sensitivity_fields, blank_fields)
      @field = field
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
          clients = SharedClient.where("lower(shared_clients.#{@field}) = ?", @values.downcase.squish)
        else
          clients = SharedClient.where("shared_clients.#{@field} = ?", @values.squish)
        end
      when 'not_equal'
        if @sensitivity_fields.include?(@field)
          clients = SharedClient.where.not("lower(shared_clients.#{@field}) = ?", @values.downcase.squish)
        else
          clients = SharedClient.where.not("shared_clients.#{@field} = ?", @values.squish)
        end
      when 'less'
        clients = SharedClient.where.not("shared_clients.#{@field} < ?", @values)
      when 'less_or_equal'
        clients = SharedClient.where.not("shared_clients.#{@field} <= ?", @values)
      when 'greater'
        clients = SharedClient.where.not("shared_clients.#{@field} > ?", @values)
      when 'greater_or_equal'
        clients = SharedClient.where.not("shared_clients.#{@field} >= ?", @values)
      when 'contains'
        clients = SharedClient.where("shared_clients.#{@field} ILIKE ?", "%#{@values.squish}%")
      when 'not_contains'
        clients = SharedClient.where("shared_clients.#{@field} NOT ILIKE ?", "%#{@values.squish}%")
      when 'is_empty'
        if @blank_fields.include?(@field)
          clients = SharedClient.where("shared_clients.#{@field} IS NULL")
        else
          clients = SharedClient.where("(shared_clients.#{@field} IS NULL OR shared_clients.#{@field} = '')")
        end
      when 'is_not_empty'
        if @blank_fields.include?(@field)
          clients = SharedClient.where.not("shared_clients.#{@field} IS NULL")
        else
          clients = SharedClient.where.not("(shared_clients.#{@field} IS NULL OR shared_clients.#{@field} = '')")
        end
      when 'between'
        clients = SharedClient.where("shared_clients.#{@field} BETWEEN ? AND ?", @values.first, @values.last)
      end
      { id: sql_string, values: clients.pluck(:slug) }
    end
  end
end
