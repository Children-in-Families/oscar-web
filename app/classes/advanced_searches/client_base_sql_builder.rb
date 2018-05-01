module AdvancedSearches
  class ClientBaseSqlBuilder
    ASSOCIATION_FIELDS = ['user_id', 'agency_name', 'form_title', 'age', 'family', 'family_id',
                          'program_stream', 'case_note_date', 'case_note_type',
                          'date_of_assessments', 'accepted_date',
                          'exit_date', 'exit_note', 'other_info_of_exit',
                          'exit_circumstance', 'exit_reasons']

    BLANK_FIELDS = ['date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'province_id', 'referral_source_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', 'donor_id', 'district_id', 'subdistrict_id', 'township_id', 'state_id']
    SENSITIVITY_FIELDS = %w(given_name family_name local_given_name local_family_name kid_id code school_name school_grade street_number house_number village commune live_with relevant_referral_information telephone_number name_of_referee main_school_contact what3words)

    def initialize(clients, rules)
      @clients     = clients
      @values      = []
      @sql_string  = []
      @condition    = rules['condition']
      @basic_rules  = rules['rules'] || []

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
          custom_form = CustomField.find_by(form_title: form_builder.second, entity_type: 'Client')
          custom_field = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rule, 'client').get_sql
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

        elsif form_builder.first == 'domainscore'
          domain_scores = AdvancedSearches::DomainScoreSqlBuilder.new(form_builder.second, rule).get_sql
          @sql_string << domain_scores[:id]
          @values << domain_scores[:values]
        elsif field != nil
          # value = field == 'grade' ? validate_integer(value) : value
          base_sql(field, operator, value)
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

    def base_sql(field, operator, value)
      case operator
      when 'equal'
        if SENSITIVITY_FIELDS.include?(field)
          @sql_string << "lower(clients.#{field}) = ?"
          @values << value.downcase
        else
          @sql_string << "clients.#{field} = ?"
          @values << value
        end

      when 'not_equal'
        if SENSITIVITY_FIELDS.include?(field)
          @sql_string << "lower(clients.#{field}) != ?"
          @values << value.downcase
        else
          @sql_string << "clients.#{field} != ?"
          @values << value
        end

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

      when 'is_not_empty'
        if BLANK_FIELDS.include? field
          @sql_string << "clients.#{field} IS NOT NULL"
        else
          @sql_string << "(clients.#{field} IS NOT NULL AND clients.#{field} != '')"
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
