module AdvancedSearches
  class ClientBaseSqlBuilder
    ASSOCIATION_FIELDS = ['case_type', 'agency_name', 'form_title', 'placement_date', 'family', 'age', 'family_id', 'referred_to_ec', 'referred_to_fc', 'referred_to_kc']
    BLANK_FIELDS= ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'grade', 'province_id', 'referral_source_id', 'user_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', 'donor_id']

    def initialize(clients, rules, date_range = [])
      @clients     = clients
      @values      = []
      @sql_string  = []
      @condition   = rules['condition']
      @basic_rules = rules['rules'] || []
      @date_range  = date_range
    end

    def generate
      @basic_rules.each do |rule|
        field    = rule['field']
        operator = rule['operator']
        value    = rule['value']
        id       = rule['id']
        
        if id.include?('custom-field')
          custom_form_sql = AdvancedSearches::ClientCustomFormSqlBuilder.new(@basic_rules, @condition).generate
        elsif ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientAssociationFilter.new(@clients, field, operator, value).get_sql
          @sql_string << association_filter[:id]
          @values     << association_filter[:values]

        elsif field != nil
          value = field == 'grade' ? validate_integer(value) : value
          if @date_range.present?
            history_base_sql(field, operator, value)
          else
            base_sql(field, operator, value)
          end
        else
          nested_query =  AdvancedSearches::ClientBaseSqlBuilder.new(@clients, rule).generate
          @sql_string << nested_query[:sql_string]
          nested_query[:values].select{ |v| @values << v }
        end
      end

      @sql_string = @sql_string.join(" #{@condition} ")
      @sql_string = "(#{@sql_string})" if @sql_string.present?
      { sql_string: @sql_string, values: @values }
    end

    private

    # def history_base_sql(field, operator, value)
      
    # end

    def base_sql(field, operator, value)
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

    def validate_integer(values)
      if values.is_a?(Array)
        first_value = values.first.to_i > 1000000 ? "1000000" : values.first
        last_value  = values.last.to_i > 1000000 ? "1000000" : values.last
        [first_value, last_value]
      else
        values.to_i > 1000000 ? "1000000" : values
      end
    end
  end
end
