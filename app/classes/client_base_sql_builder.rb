class ClientBaseSqlBuilder
  ASSOCIATION_FIELDS = ['case_type', 'agency_name', 'form_title', 'placement_date', 'family_name', 'age', 'family_id']

  def self.generate(clients, rules)
    @clients     = clients
    @values      = []
    @sql_string  = []

    rules.each do |rule|
      field    = rule[:field]
      operator = rule[:operator]
      value    = rule[:value]
      if ASSOCIATION_FIELDS.include?(field)
        association_filter = ClientAssociationFilter.new(@clients, field, operator, value).get_sql
        
        @sql_string << association_filter[:id]
        @values     << association_filter[:values]
      else
        base_sql(field, operator, value)
      end

    end

    { sql_string: @sql_string, values: @values }
  end

  private

  def self.base_sql(field, operator, value)
    case operator
    when 'equal'
      @sql_string << "clients.#{field} = ?"
      @values << value

    when 'not_equal'
      @sql_string << "clients.#{field} != ?"
      @values << value

    when 'less'
      @sql_string << "clients.#{field} < ?"
      @values << value

    when 'less_or_equal'
      @sql_string << "clients.#{field} <= ?"
      @values << value

    when 'greater'
      @sql_string << "clients.#{field} > ?"
      @values << value

    when 'greater_or_equal'
      @sql_string << "clients.#{field} >= ?"
      @values << value

    when 'contains'
      @sql_string << "clients.#{field} ILIKE ?"
      @values << "%#{value}%"

    when 'not_contains'
      @sql_string << "clients.#{field} NOT ILIKE ?"
      @values << "%#{value}%"

    when 'is_empty'
      @sql_string << "clients.#{field} IS NULL"

    when 'between'
      @sql_string << "clients.#{field} BETWEEN ? AND ?"
      @values << value.first
      @values << value.last
    end
  end
end
