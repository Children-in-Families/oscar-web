class ClientBaseSqlBuilder
  ASSOCIATION_FIELDS = ['case_type', 'agency_name', 'form_title', 'placement_date', 'family', 'age', 'family_id']
  BLANK_FIELDS= ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'grade', 'province_id', 'referral_source_id', 'user_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', ]


  def self.generate(clients, rules)
    @clients     = clients
    @values      = []
    @sql_string  = []
    condition    = rules[:condition]
    basic_rules  = rules[:rules] || []

    basic_rules.each do |rule|
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

    @sql_string = @sql_string.join(" #{condition} ")
    @sql_string = "(#{@sql_string})" if @sql_string.present?
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
      if BLANK_FIELDS.include? field
        @sql_string << "clients.#{field} IS NULL"
      else
        @sql_string << "(clients.#{field} IS NULL OR clients.#{field} = '')"
      end

    when 'between'
      @sql_string << "clients.#{field} BETWEEN ? AND ?"
      @values << value.first
      @values << value.last
    end
  end
end
