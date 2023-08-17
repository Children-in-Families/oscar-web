module AdvancedSearches
  module Families
    class FamilyBaseSqlBuilder
      ASSOCIATION_FIELDS = [
        'client_id', 'case_workers', 'relation', 'gender', 'date_of_birth', 'date_of_custom_assessments', 'custom_completed_date', 'custom_assessment',
        'assessment_completed_date', 'assessment_completed', 'case_note_date', 'case_note_type', 'active_families', 'care_plan_completed_date',
        'active_program_stream', 'number_family_referred_gatekeeping', 'number_family_billable', 'family_rejected', 'no_case_note_date', 'completed_date',
        'assessment_created_at', 'date_of_assessments', 'custom_assessment_created_at', 'assessment_number', 'assessment_condition_last_two', 'assessment_condition_first_last'
      ].freeze

      BLANK_FIELDS = %w(created_at contract_date household_income dependable_income female_children_count male_children_count female_adult_count male_adult_count province_id significant_family_member_count district_id commune_id village_id id referral_source_id)
      SENSITIVITY_FIELDS = %w(name code address case_history caregiver_information family_type status)

      def initialize(families, rules)
        @families = families
        @values = []
        @sql_string = []
        @condition = rules['condition']
        @basic_rules = rules['rules'] || []

        @columns_visibility = []
      end

      def generate
        @basic_rules.each do |rule|
          field    = rule['id']
          operator = rule['operator']
          value    = rule['value']
          form_builder = field != nil ? field.split('__') : []

          if ASSOCIATION_FIELDS.include?(field)
            association_filter = AdvancedSearches::Families::FamilyAssociationFilter.new(@families, field, operator, value).get_sql
            @sql_string << association_filter[:id]
            @values     << association_filter[:values]
          elsif form_builder.first == 'domainscore' || field == 'all_domains' || field == 'all_custom_domains'
            domain_scores = AdvancedSearches::Families::DomainScoreSqlBuilder.new(field, rule, @basic_rules).get_sql
            @sql_string << "Families.id IN (?)"
            @values << domain_scores[:values]&.flatten || []
          elsif form_builder.first == 'formbuilder'
            if form_builder.last == 'Has This Form'
              custom_form_value = CustomField.find_by(form_title: value, entity_type: 'Family').try(:id)
              @sql_string << "families.id IN (?)"
              @values << @families.joins(:custom_fields).where('custom_fields.id = ?', custom_form_value).uniq.ids
            elsif form_builder.last == 'Does Not Have This Form'
              client_ids = Family.joins(:custom_fields).where(custom_fields: { form_title: form_builder.second }).ids
              @sql_string << "families.id NOT IN (?)"
              @values << client_ids
            else
              custom_form = CustomField.find_by(form_title: form_builder.second, entity_type: 'Family')
              custom_field = AdvancedSearches::EntityCustomFormSqlBuilder.new(custom_form, rule, 'family').get_sql
  
              @sql_string << custom_field[:id]
              @values << custom_field[:values]
            end
          elsif form_builder.first == 'quantitative'
            quantitative_filter = AdvancedSearches::Families::QuantitativeCaseSqlBuilder.new(@families, rule).get_sql
            @sql_string << quantitative_filter[:id]
            @values << quantitative_filter[:values]

          elsif form_builder.first == 'enrollment'
            program_name = form_builder.second.gsub("&qoute;", '"')
            program_stream = ProgramStream.find_by(name: program_name)
            if program_stream.present?
              enrollment_fields = AdvancedSearches::Families::FamilyEnrollmentSqlBuilder.new(program_stream.id, rule).get_sql
              @sql_string << enrollment_fields[:id]
              @values << enrollment_fields[:values]
            end
          elsif form_builder.first == 'enrollmentdate'
            program_name = form_builder.second.gsub("&qoute;", '"')
            program_stream = ProgramStream.find_by(name: program_name)
            if program_stream
              enrollment_date = AdvancedSearches::Families::FamilyEnrollmentDateSqlBuilder.new(program_stream.id, rule).get_sql
              @sql_string << enrollment_date[:id]
              @values << enrollment_date[:values]
            else
              @sql_string << "Families.id IN (?)"
              @values << []
            end
          elsif form_builder.first == 'tracking'
            tracking = Tracking.joins(:program_stream).where(program_streams: {name: form_builder.second}, trackings: {name: form_builder.third}).last
            if tracking
              tracking_fields = AdvancedSearches::Families::FamilyTrackingSqlBuilder.new(tracking.id, rule, form_builder.second).get_sql
              @sql_string << tracking_fields[:id]
              @values << tracking_fields[:values]
            end
          elsif form_builder.first == 'exitprogram'
            program_stream = ProgramStream.find_by(name: form_builder.second)
            exit_program_fields = AdvancedSearches::Families::FamilyExitProgramSqlBuilder.new(program_stream.id, rule).get_sql
            @sql_string << exit_program_fields[:id]
            @values << exit_program_fields[:values]
          elsif form_builder.first == 'exitprogramdate' || form_builder.first == 'programexitdate'
            program_stream = ProgramStream.find_by(name: form_builder.second)
            if program_stream.present?
              exit_date = AdvancedSearches::Families::FamilyProgramExitDateSqlBuilder.new(program_stream.id, rule).get_sql
              @sql_string << exit_date[:id]
              @values << exit_date[:values]
            end
          elsif field != nil
            base_sql(field, operator, value)
          else
            nested_query =  AdvancedSearches::Families::FamilyBaseSqlBuilder.new(@families, rule).generate
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
            @sql_string << "lower(families.#{field}) = ?"
            @values << value.downcase.squish
          else
            @sql_string << "families.#{field} = ?"
            @values << value
          end

        when 'not_equal'
          if SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(families.#{field}) != ?"
            @values << value.downcase.squish
          elsif BLANK_FIELDS.include? field
            @sql_string << "(families.#{field} IS NULL OR families.#{field} != ?)"
            @values << value
          else
            @sql_string << "families.#{field} != ?"
            @values << value
          end

        when 'less'
          @sql_string << "families.#{field} < ?"
          @values << value

        when 'less_or_equal'
          @sql_string << "families.#{field} <= ?"
          @values << value

        when 'greater'
          @sql_string << "families.#{field} > ?"
          @values << value

        when 'greater_or_equal'
          @sql_string << "families.#{field} >= ?"
          @values << value

        when 'contains'
          @sql_string << "families.#{field} ILIKE ?"
          @values << "%#{value.squish}%"

        when 'not_contains'
          @sql_string << "families.#{field} NOT ILIKE ?"
          @values << "%#{value.squish}%"

        when 'is_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "families.#{field} IS NULL"
        elsif SENSITIVITY_FIELDS.include?(field)
          @sql_string << "families.#{field} = '' OR families.#{field} IS NULL"
          @values << value.downcase.squish
        else
          not_integer_field = field[/\_id/] ? '' : "OR families.#{field} != ''"
          @sql_string << "(families.#{field} IS NULL #{not_integer_field})"
        end

        when 'is_not_empty'
          if BLANK_FIELDS.include? field
            @sql_string << "families.#{field} IS NOT NULL"
          elsif SENSITIVITY_FIELDS.include?(field)
            @sql_string << "lower(families.#{field}) != '' AND families.#{field} IS NOT NULL"
            @values << value.downcase.squish
          else
            not_integer_field = field[/\_id/] ? '' : "AND families.#{field} != ''"
            @sql_string << "(families.#{field} IS NOT NULL #{not_integer_field})"
          end

        when 'between'
          @sql_string << "families.#{field} BETWEEN ? AND ?"
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
end
