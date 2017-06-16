module AdvancedSearches
  class ClientHistoryBaseSqlBuilder
    ASSOCIATION_FIELDS = ['case_type', 'agency_name', 'form_title', 'placement_date', 'family', 'age', 'family_id', 'referred_to_ec', 'referred_to_fc', 'referred_to_kc']
    BLANK_FIELDS= ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'grade', 'province_id', 'referral_source_id', 'user_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', 'donor_id']

    def initialize(client_histories, rules, date_range = [])
      @client_histories     = client_histories
      @values      = []
      @sql_string  = []
      @condition   = rules[:condition]
      @basic_rules = rules[:rules] || []
      @date_range  = date_range
    end

    def generate
      @basic_rules.each do |rule|
        field    = rule[:field]
        operator = rule[:operator]
        value    = rule[:value]
        binding.pry

        # if field != nil
        #   value = field == 'grade' ? validate_integer(value) : value
        #   history_base_sql(field, operator, value)
        # else
        #   nested_query =  AdvancedSearches::ClientHistoryBaseSqlBuilder.new(@client_histories, rule).generate
        #   binding.pry
        #   @sql_string << nested_query[:sql_string]
        #   nested_query[:values].select{ |v| @values << v }
        # end
        # if field == nil
        #   nested_query =  AdvancedSearches::ClientHistoryBaseSqlBuilder.new(@client_histories, rule).generate
        #   binding.pry
        #   @sql_string << nested_query
        #   # nested_query[:values].select{ |v| @values << v }
        # end

        # @sql_string << history_base_sql(field, operator, value)
        if ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientHistoryAssociationFilter.new(@client_histories, field, operator, value).get_sql
          @sql_string << association_filter
          # binding.pry
        else
          if field != nil
            @sql_string << history_base_sql(field, operator, value)
          else
            nested_query =  AdvancedSearches::ClientHistoryBaseSqlBuilder.new(@client_histories, rule).generate
            binding.pry
            @sql_string << nested_query
            # nested_query[:values].select{ |v| @values << v }
          end
        end

        # elsif field != nil
        #   value = field == 'grade' ? validate_integer(value) : value
        #   if @date_range.present?
        #     history_base_sql(field, operator, value)
        #   else
        #     base_sql(field, operator, value)
        #   end
        # else
        #   nested_query =  AdvancedSearches::ClientBaseSqlBuilder.new(@clients, rule).generate
        #   @sql_string << nested_query[:sql_string]
        #   nested_query[:values].select{ |v| @values << v }
        # end
      end
      # binding.pry
      # binding.pry
      {"$#{@condition.downcase}" => @sql_string}
      # binding.pry

      # @sql_string = @sql_string.join(" #{@condition} ")
      # @sql_string = "(#{@sql_string})" if @sql_string.present?
      # { sql_string: @sql_string, values: @values }

    end

    private

    def history_base_sql(field, operator, value)
      case operator
      when 'equal'
        a = "object.#{field}"
        {a => value}
        # @values << {a => value}
        # @sql_string << "object.#{field} = ?"
        # @values << value

      when 'not_equal'
        @sql_string << "object.#{field} != ?"
        @values << value

      when 'less'
        @sql_string << "object.#{field} < ?"
        @values << value

      when 'less_or_equal'
        @sql_string << "object.#{field} <= ?"
        @values << value

      when 'greater'
        @sql_string << "object.#{field} > ?"
        @values << value

      when 'greater_or_equal'
        @sql_string << "object.#{field} >= ?"
        @values << value

      when 'contains'
        @sql_string << "object.#{field} ILIKE ?"
        @values << "%#{value}%"

      when 'not_contains'
        @sql_string << "object.#{field} NOT ILIKE ?"
        @values << "%#{value}%"

      when 'is_empty'
        a = "object.#{field}"
        {a => value}
        # if BLANK_FIELDS.include? field
        #   @sql_string << "object.#{field} IS NULL"
        # else
        #   @sql_string << "(object.#{field} IS NULL OR object.#{field} = '')"
        # end

      when 'between'
        # binding.pry
        @sql_string << "object.#{field} BETWEEN ? AND ?"
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
