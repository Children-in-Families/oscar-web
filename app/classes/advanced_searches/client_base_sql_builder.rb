module AdvancedSearches
  class ClientBaseSqlBuilder
    include ProgramStreamHelper

    ASSOCIATION_FIELDS = [
      'user_id', 'created_by', 'agency_name', 'donor_name', 'age', 'family', 'family_id',
      'active_program_stream', 'enrolled_program_stream', 'case_note_date', 'no_case_note_date', 'case_note_type',
      'assessment_created_at', 'date_of_assessments', 'date_of_custom_assessments', 'accepted_date', 'assessment_completed_date',
      'custom_assessment', 'custom_assessment_created_at', 'custom_completed_date',
      'exit_date', 'exit_note', 'other_info_of_exit', 'protection_concern_id', 'necessity_id',
      'exit_circumstance', 'exit_reasons', 'referred_to', 'referred_from', 'time_in_cps', 'time_in_ngo',
      'assessment_number', 'month_number', 'date_nearest', 'assessment_completed', 'date_of_referral',
      'referee_name', 'referee_phone', 'referee_email', 'carer_name', 'carer_phone', 'carer_email',
      'client_phone', 'client_email_address', 'phone_owner', 'referee_relationship', 'active_clients',
      'care_plan_counter', 'care_plan_date', 'care_plan_completed_date', 'completed_date', 'custom_completed_date',
      'ratanak_achievement_program_staff_client_ids', 'mo_savy_officials', 'carer_relationship_to_client',
      'referred_in', 'referred_out', 'family_type', 'active_client_program',
      'number_client_referred_gatekeeping', 'number_client_billable', 'assessment_condition_last_two',
      'assessment_condition_first_last', 'client_rejected', 'incomplete_care_plan'
    ].freeze

    BLANK_FIELDS = ['created_at', 'date_of_birth', 'initial_referral_date', 'follow_up_date', 'has_been_in_orphanage', 'has_been_in_government_care', 'province_id', 'referral_source_id', 'birth_province_id', 'received_by_id', 'followed_up_by_id', 'district_id', 'subdistrict_id', 'township_id', 'state_id', 'commune_id', 'village_id', 'referral_source_category_id', 'arrival_at']
    SENSITIVITY_FIELDS = %w(given_name family_name local_given_name local_family_name kid_id code school_name school_grade street_number house_number village commune live_with relevant_referral_information telephone_number name_of_referee main_school_contact what3words address_type concern_address_type)
    SHARED_FIELDS = %w(given_name family_name local_given_name local_family_name gender birth_province_id date_of_birth live_with telephone_number)
    CALL_FIELDS = Call::FIELDS
    OVERDUE_FIELDS = %w[has_overdue_assessment has_overdue_forms has_overdue_task no_case_note].freeze
    RISK_ASSESSMENTS = %w[level_of_risk date_of_risk_assessment has_disability has_hiv_or_aid has_known_chronic_disease].freeze

    def initialize(clients, basic_rules)
      @clients = clients
      @values = []
      @sql_string = []
      @condition = basic_rules['condition']
      basic_rules = format_rule(basic_rules)
      @basic_rules = basic_rules['rules'] || []
      @columns_visibility = []
    end

    def generate
      @basic_rules.each do |rule|
        field = rule['id']
        operator = rule['operator']
        value = rule['value']
        form_builder = field != nil ? field.split('__') : []

        if ASSOCIATION_FIELDS.include?(field)
          association_filter = AdvancedSearches::ClientAssociationFilter.new(@clients, field, operator, value).get_sql
          @sql_string << association_filter[:id]
          @values << association_filter[:values]
        elsif SHARED_FIELDS.include?(field)
          short_name = Organization.current.short_name
          Organization.switch_to 'shared'
          shared_client_filter = AdvancedSearches::SharedFieldsSqlFilter.new(field, operator, value, SENSITIVITY_FIELDS, BLANK_FIELDS).get_sql
          Organization.switch_to short_name
          @sql_string << shared_client_filter[:id]
          @values << shared_client_filter[:values]
        elsif form_builder.first == 'case_note_custom_field'
          custom_form = ::CaseNotes::CustomField.find(form_builder.second)
          custom_field = AdvancedSearches::CaseNotes::EntityCustomFormSqlBuilder.new(custom_form, rule).get_sql
          @sql_string << custom_field[:id]
          @values << custom_field[:values]
        elsif form_builder.first == 'formbuilder'
          if form_builder.last == 'Has This Form'
            custom_form_value = CustomField.find_by(form_title: value, entity_type: 'Client')&.id

            @sql_string << 'clients.id IN (?)'
            @values << @clients.joins(:custom_fields).where('custom_fields.id = ?', custom_form_value).uniq.ids
          elsif form_builder.last == 'Does Not Have This Form'
            client_ids = Client.joins(:custom_fields).where(custom_fields: { form_title: form_builder.second }).ids
            @sql_string << 'clients.id NOT IN (?)'
            @values << client_ids
          else
            custom_form = CustomField.find_by(form_title: form_builder.second, entity_type: 'Client')
            custom_field = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rule, 'client').get_sql

            @sql_string << custom_field[:id]
            @values << custom_field[:values]
          end
        elsif form_builder.first == 'enrollment'
          program_name = form_builder.second.gsub('&qoute;', '"')
          program_stream = ProgramStream.find_by(name: program_name)
          if program_stream.present?
            enrollment_fields = AdvancedSearches::EnrollmentSqlBuilder.new(@clients, program_stream.id, rule).get_sql
            @sql_string << enrollment_fields[:id]
            @values << enrollment_fields[:values]
          end
        elsif form_builder.first == 'enrollmentdate'
          program_name = form_builder.second.gsub('&qoute;', '"')
          program_stream = ProgramStream.find_by(name: program_name)

          if program_stream
            enrollment_date = AdvancedSearches::EnrollmentDateSqlBuilder.new(program_stream.id, rule).get_sql
            @sql_string << enrollment_date[:id]
            @values << enrollment_date[:values]
          else
            @sql_string << 'clients.id IN (?)'
            @values << []
          end
        elsif form_builder.first == 'tracking'
          tracking = Tracking.joins(:program_stream).where(program_streams: { name: form_builder.second }, trackings: { name: form_builder.third }).last
          if form_builder.last == 'Has This Form'
            client_ids = tracking.client_enrollment_trackings.joins(:client_enrollment).where('DATE(client_enrollment_trackings.created_at) BETWEEN ? AND ?', value.first, value.last).pluck('client_enrollments.client_id')
            @sql_string << 'clients.id IN (?)'
            @values << client_ids
          elsif form_builder.last == 'Does Not Have This Form'
            client_ids = tracking.client_enrollment_trackings.joins(:client_enrollment).where.not('DATE(client_enrollment_trackings.created_at) BETWEEN ? AND ?', value.first, value.last).pluck('client_enrollments.client_id')
            @sql_string << 'clients.id IN (?)'
            @values << client_ids
          elsif tracking
            tracking_fields = AdvancedSearches::TrackingSqlBuilder.new(tracking.id, rule, form_builder.second).get_sql
            @sql_string << tracking_fields[:id]
            @values << tracking_fields[:values]
          end
        elsif form_builder.first == 'exitprogram'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          exit_program_fields = AdvancedSearches::ExitProgramSqlBuilder.new(program_stream.id, rule).get_sql
          @sql_string << exit_program_fields[:id]
          @values << exit_program_fields[:values]
        elsif form_builder.first == 'exitprogramdate' || form_builder.first == 'programexitdate'
          program_stream = ProgramStream.find_by(name: form_builder.second)
          if program_stream.present?
            exit_date = AdvancedSearches::ProgramExitDateSqlBuilder.new(program_stream.id, rule).get_sql
            @sql_string << exit_date[:id]
            @values << exit_date[:values]
          end
        elsif form_builder.first == 'quantitative'
          quantitative_filter = AdvancedSearches::QuantitativeCaseSqlBuilder.new(@clients, rule).get_sql
          @sql_string << quantitative_filter[:id]
          @values << quantitative_filter[:values]
        elsif form_builder.first == 'custom_data'
          custom_data_filter = AdvancedSearches::CustomDataSqlBuilder.new(@clients, rule).get_sql
          @sql_string << custom_data_filter[:id]
          @values << custom_data_filter[:values]
        elsif form_builder.first == 'domainscore' || field == 'all_domains' || field == 'all_custom_domains'
          domain_scores = AdvancedSearches::DomainScoreSqlBuilder.new(field, rule, @basic_rules).get_sql
          @sql_string << domain_scores[:id]
          @values << domain_scores[:values]
        elsif form_builder.first == 'type_of_service'
          service_query = AdvancedSearches::ServiceSqlBuilder.new.get_sql
          @sql_string << service_query[:id]
          @values << service_query[:values]
        elsif CALL_FIELDS.include?(field)
          service_query = AdvancedSearches::Hotline::CallSqlBuilder.new.get_sql
          @sql_string << service_query[:id]
          @values << service_query[:values]
        elsif OVERDUE_FIELDS.include?(field)
          overdue_form = AdvancedSearches::OverdueFormSqlBuilder.new(@clients, field, operator, value).get_sql
          @sql_string << overdue_form[:id]
          @values << overdue_form[:values]
        elsif RISK_ASSESSMENTS.include?(field)
          results = AdvancedSearches::RiskAssessmentSqlBuilder.new(@clients, field, operator, value).generate_sql
          @sql_string << results[:id]
          @values << results[:values]
        elsif !field.nil? && form_builder.first != 'type_of_service'
          base_sql(field, operator, value)
        else
          nested_query = AdvancedSearches::ClientBaseSqlBuilder.new(@clients, rule).generate
          @sql_string << nested_query[:sql_string]
          nested_query[:values].select { |v| @values << v }
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
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) = ?"
          @values << value
        elsif field == 'slug'
          @sql_string << 'clients.slug = ?'
          @values << value
        else
          if SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(clients.#{field}) = ?"
            @values << value.downcase.squish
          else
            @sql_string << "clients.#{field} = ?"
            @values << value
          end
        end
      when 'not_equal'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) != ?"
          @values << value
        elsif SENSITIVITY_FIELDS.include?(field)
          @sql_string << "lower(clients.#{field}) != ?"
          @values << value.downcase.squish
        elsif BLANK_FIELDS.include? field
          @sql_string << "(clients.#{field} IS NULL OR clients.#{field} != ?)"
          @values << value
        else
          @sql_string << "clients.#{field} != ?"
          @values << value
        end
      when 'less'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) < ?"
          @values << value
        else
          @sql_string << "clients.#{field} < ?"
          @values << value
        end
      when 'less_or_equal'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) <= ?"
          @values << value
        else
          @sql_string << "clients.#{field} <= ?"
          @values << value
        end
      when 'greater'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) > ?"
          @values << value
        else
          @sql_string << "clients.#{field} > ?"
          @values << value
        end
      when 'greater_or_equal'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) >= ?"
          @values << value
        else
          @sql_string << "clients.#{field} >= ?"
          @values << value
        end
      when 'contains'
        @sql_string << "clients.#{field} ILIKE ?"
        @values << "%#{value.squish}%"
      when 'not_contains'
        @sql_string << "clients.#{field} NOT ILIKE ?"
        @values << "%#{value.squish}%"
      when 'is_empty'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) IS NULL"
        else
          if BLANK_FIELDS.include? field
            @sql_string << "clients.#{field} IS NULL"
          else
            @sql_string << "(clients.#{field} IS NULL OR clients.#{field} = '')"
          end
        end
      when 'is_not_empty'
        if field == 'created_at'
          @sql_string << "date(clients.#{field}) IS NOT NULL"
        else
          if BLANK_FIELDS.include? field
            @sql_string << "clients.#{field} IS NOT NULL"
          else
            @sql_string << "(clients.#{field} IS NOT NULL AND clients.#{field} != '')"
          end
        end
      when 'between'
        created_at_query = "date(clients.#{field}) BETWEEN ? AND ?"
        school_grade_query = "clients.#{field} in (?)"
        default_query = "clients.#{field} BETWEEN ? AND ?"
        @sql_string = field == 'created_at' ? [*@sql_string, created_at_query] : field == 'school_grade' ? [*@sql_string, school_grade_query] : [*@sql_string, default_query]
        @values = field == 'school_grade' ? [*@values, [*value.first..value.last]] : [*@values, *value]
      end
    end

    def validate_integer(values)
      if values.is_a?(Array)
        first_value = values.first.to_i > 1000000 ? '1000000' : values.first
        last_value = values.last.to_i > 1000000 ? '1000000' : values.last
        [first_value, last_value]
      else
        values.to_i > 1000000 ? '1000000' : values
      end
    end
  end
end
