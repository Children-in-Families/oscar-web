module AdvancedSearches
  class ClientHistoryBaseSqlBuilder
    ASSOCIATION_FIELDS = ['user_id', 'case_type', 'agency_name', 'form_title', 'placement_date', 'family', 'age', 'family_id', 'referred_to_ec', 'referred_to_fc', 'referred_to_kc', 'exit_ec_date', 'exit_fc_date', 'exit_kc_date', 'program_stream']
    BLANK_FIELDS = ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'grade', 'province_id', 'referral_source_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', 'donor_id', 'id_poor', 'exit_date', 'accepted_date']

    def initialize(clients, rules, history_date)
      @clients     = clients
      @values      = []
      @sql_string  = []
      @condition    = rules['condition']
      @basic_rules  = rules['rules'] || []
      @history_date   = history_date

      @columns_visibility = []
    end

    def generate
      @basic_rules.each do |rule|
        field    = rule['field']
        operator = rule['operator']
        value    = rule['value']
        form_builder = field != nil ? field.split('_') : []
        if ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientAssociationFilter.new(@clients, field, operator, value).get_sql
          @sql_string << association_filter[:id]
          @values     << association_filter[:values]

        elsif form_builder.first == 'formbuilder'
          custom_form = CustomField.find_by(form_title: form_builder.second)
          custom_field = AdvancedSearches::ClientCustomFormSqlBuilder.new(custom_form, rule).get_sql
          @sql_string << custom_field[:id]
          @values << custom_field[:values]

        elsif form_builder.first == 'enrollment'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          enrollment_fields = AdvancedSearches::EnrollmentSqlBuilder.new(program_stream.id, rule).get_sql
          @sql_string << enrollment_fields[:id]
          @values << enrollment_fields[:values]

        elsif form_builder.first == 'enrollmentdate'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          enrollment_date = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rule).get_sql
          @sql_string << enrollment_date[:id]
          @values << enrollment_date[:values]

        elsif form_builder.first == 'tracking'
          tracking = Tracking.joins(:program_stream).where(program_streams: {name: form_builder.second}, trackings: {name: form_builder.third}).last
          tracking_fields = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rule).get_sql
          @sql_string << tracking_fields[:id]
          @values << tracking_fields[:values]

        elsif form_builder.first == 'exitprogram'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          exit_program_fields = AdvancedSearches::ExitProgramSqlBuilder.new(program_stream.id, rule).get_sql
          @sql_string << exit_program_fields[:id]
          @values << exit_program_fields[:values]

        elsif form_builder.first == 'programexitdate'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          exit_date = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rule).get_sql
          @sql_string << exit_date[:id]
          @values << exit_date[:values]

        elsif form_builder.first == 'quantitative'
          quantitative_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(@clients, rule).get_sql
          @sql_string << quantitative_filter[:id]
          @values << quantitative_filter[:values]

        elsif field != nil
          value = field == 'grade' ? validate_integer(value) : value
          date = @history_date
          historical_base_sql(field, operator, value, date)

        else
          nested_query =  AdvancedSearches::ClientBaseSqlBuilder.new(@clients, rule).generate
          @sql_string << nested_query[:sql_string]
          nested_query[:values].select{ |v| @values << v }
        end
      end
      
      @sql_string = { "$#{@condition.downcase}": @sql_string }
      # { sql_string: @sql_string }
    end

    private

    def historical_base_sql(field, operator, value, date)
      case operator
      when 'equal'
        @sql_string << { "object.#{field}": value }

      when 'not_equal'
        @sql_string << { "object.#{field}": { '$ne': value } }

      when 'less'
        @sql_string << { "object.#{field}": { '$lt': value } }

      when 'less_or_equal'
        @sql_string << { "object.#{field}": { '$lte': value } }

      when 'greater'
        @sql_string << { "object.#{field}": { '$gt': value } }

      when 'greater_or_equal'
        @sql_string << { "object.#{field}": { '$gte': value } }

      when 'contains'
        @sql_string << { "object.#{field}": /.*#{value}.*/i }

      when 'not_contains'
        @sql_string << { "object.#{field}": { '$not': /.*#{value}.*/i } }

      when 'is_empty'
        if BLANK_FIELDS.include? field
          @sql_string << { "object.#{field}": { '$in': [nil] } }
        else
          @sql_string << { "object.#{field}": { '$in': ['', nil] } }
        end

      when 'is_not_empty'
        if BLANK_FIELDS.include? field
          @sql_string << { "object.#{field}": { '$nin': [nil] } }
        else
          @sql_string << { "object.#{field}": { '$nin': ['', nil] } }
        end

      when 'between'
        @sql_string << { "object.#{field}": value.first..value.last }
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
