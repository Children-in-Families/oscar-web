module AdvancedSearches
  module Families
    class FamilyAssociationFilter
      include AdvancedSearchHelper
      include AssessmentHelper
      include FormBuilderHelper

      def initialize(families, field, operator, values)
        @families  = families
        @field    = field
        @operator = operator
        @value   = values
      end

      def get_sql
        sql_string = 'families.id IN (?)'
        case @field
        when 'client_id'
          values = list_families
        when 'case_workers'
          values = case_worker_field_query
        when 'gender'
          values = get_family_member_gender
        when 'case_note_date'
          values = advanced_case_note_query
        when 'case_note_type'
          values = advanced_case_note_query
        when 'date_of_birth'
          values = get_family_member_dob
        when 'no_case_note_date'
          values = advanced_case_note_query
          values = @families.where.not(id: values).ids
        when 'active_families'
          values = get_active_families
        when /assessment_completed|assessment_completed_date|custom_completed_date/
          values = date_of_completed_assessments_query(true)
        when 'date_of_custom_assessments'
          values = date_of_assessments_query(false)
        when 'date_of_assessments'
          values = date_of_assessments_query(true)
        when 'assessment_created_at'
          values = assessment_created_at_query(true)
        when 'custom_assessment_created_at'
          values = assessment_created_at_query(false)
        when 'assessment_condition_last_two'
          values = assessment_condition_last_two_query
        when 'assessment_condition_first_last'
          values = assessment_condition_first_last_query
        when 'custom_assessment'
          values = search_custom_assessment
        when 'number_family_referred_gatekeeping'
          values = number_family_referred_gatekeeping_query
        when 'number_family_billable'
          values = number_family_billable_query
        when 'family_rejected'
          values = get_rejected_families
        when 'assessment_number'
          values = assessment_number_query
        when 'relation'
          values = family_members
        when 'care_plan_completed_date'
          values = date_query(Family, @families, :care_plans, 'care_plans.created_at')
        when 'active_program_stream'
          values = active_program_stream_query
        end
        { id: sql_string, values: values }
      end

      private

      def family_assessment_compare_first_last(compare, selectedAssessment)
        family_ids = []
        families = @families.joins(:assessments).where(assessments: { completed: true })
        conditionString = ""
        assessments = Assessment.completed.joins(:domains).where(family_id: families.ids).distinct
  
        assessments.group_by { |assessment| assessment.family_id }.each do |family_id, _assessments|
          next if _assessments.size < 2

          first_assessment = _assessments.sort_by(&:id).first
          last_assessment = _assessments.sort_by(&:id).last

          first_assessment_domain_scores = first_assessment.assessment_domains.pluck(:score).sum.to_f
          last_assessment_domain_scores = last_assessment.assessment_domains.pluck(:score).sum.to_f

          first_average_score = (first_assessment_domain_scores / first_assessment.assessment_domains.size).round
          last_average_score = (last_assessment_domain_scores / last_assessment.assessment_domains.size).round
          family_ids  << family_id if last_average_score.public_send(compare, first_average_score)
        end

        family_ids
      end
  
      def family_assessment_compare_next_last(compare, selectedAssessment)
        family_ids = []
        families = @families.joins(:assessments).where(assessments: { completed: true })
        conditionString = ""
        
        assessments = Assessment.completed.joins(:domains).where(family_id: families.ids).distinct
  
        assessments.group_by { |assessment| assessment.family_id }.each do |family_id, _assessments|
          next if _assessments.size < 2

          before_last_assessment = _assessments.sort_by(&:id).fetch(_assessments.size - 2)
          last_assessment = _assessments.sort_by(&:id).last

          before_last_assessment_domain_scores = before_last_assessment.assessment_domains.pluck(:score).sum.to_f
          last_assessment_domain_scores = last_assessment.assessment_domains.pluck(:score).sum.to_f

          before_last_assessment_average_score = (before_last_assessment_domain_scores / before_last_assessment.assessment_domains.size).round
          last_average_score = (last_assessment_domain_scores / last_assessment.assessment_domains.size).round
          family_ids  << family_id if last_average_score.public_send(compare, before_last_assessment_average_score)
        end

        family_ids
      end

      def assessment_condition_last_two_query
        case @value.downcase
        when 'better'
          family_ids = family_assessment_compare_next_last(:>, $param_rules[:assessment_selected])
        when 'same'
          family_ids = family_assessment_compare_next_last(:==, $param_rules[:assessment_selected])
        when 'worse'
          family_ids = family_assessment_compare_next_last(:<, $param_rules[:assessment_selected])
        end
        families = family_ids.present? ? family_ids : []
      end
  
      def assessment_condition_first_last_query
        case @value.downcase
        when 'better'
          family_ids = family_assessment_compare_first_last(:>, $param_rules[:assessment_selected])
        when 'same'
          family_ids = family_assessment_compare_first_last(:==, $param_rules[:assessment_selected])
        when 'worse'
          family_ids = family_assessment_compare_first_last(:<, $param_rules[:assessment_selected])
        end
        families = family_ids.present? ? family_ids : []
      end

      def assessment_number_query
        basic_rules = $param_rules['basic_rules']
        basic_rules =  basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
        results = mapping_assessment_query_rules(basic_rules).reject(&:blank?)
        assessment_completed_sql, assessment_number = assessment_filter_values(results)
        sql = "(assessments.completed = true #{assessment_completed_sql}) AND ((SELECT COUNT(*) FROM assessments WHERE families.id = assessments.family_id #{assessment_completed_sql}) >= #{@value})".squish
        @families.joins(:assessments).where(sql).ids
      end

      def assessment_created_at_query(type)
        custom_assessment_setting_id = find_custom_assessment_setting_id(type)
        if custom_assessment_setting_id
          families = @families.joins(:assessments).where(assessments: { default: type, custom_assessment_setting_id: custom_assessment_setting_id })
        else
          families = @families.joins(:assessments).where(assessments: { default: type })
        end
        case @operator
        when 'equal'
          families = families.where('date(assessments.created_at) = ?', @value.to_date)
        when 'not_equal'
          families = families.where("date(assessments.created_at) != ? OR assessments.created_at IS NULL", @value.to_date)
        when 'less'
          families = families.where('date(assessments.created_at) < ?', @value.to_date)
        when 'less_or_equal'
          families = families.where('date(assessments.created_at) <= ?', @value.to_date)
        when 'greater'
          families = families.where('date(assessments.created_at) > ?', @value.to_date)
        when 'greater_or_equal'
          families = families.where('date(assessments.created_at) >= ?', @value.to_date)
        when 'between'
          families = families.where('date(assessments.created_at) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
        when 'is_empty'
          families = @families.includes(:assessments).where(assessments: { created_at: nil , default: type})
        when 'is_not_empty'
          families = families.where(assessments: { default: type }).where.not(assessments: { created_at: nil })
        end

        families.ids
      end

      def search_custom_assessment
        families = @families.joins(:assessments).where(assessments: {default: false })
        case @operator
        when 'equal'
          family_ids = families.where(assessments: { custom_assessment_setting_id: @value }).distinct.ids
        when 'not_equal'
          family_ids = families.where.not(assessments: { custom_assessment_setting_id: @value }).distinct.ids
        when 'is_empty'
          family_ids = @families.includes(:assessments).group('families.id, assessments.id, assessments.custom_assessment_setting_id').having("COUNT(assessments.id) = 0").distinct.ids
        when 'is_not_empty'
          family_ids = @families.includes(:assessments).group('families.id, assessments.id, assessments.custom_assessment_setting_id').having("COUNT(assessments.id) > 0").distinct.ids
        end
      end

      def number_family_referred_gatekeeping_query
        families = @families.where(referral_source_category_id: ReferralSource.gatekeeping_mechanism.ids).distinct
  
        case @operator
        when 'equal'
          family_ids = families.where('date(initial_referral_date) = ?', @value.to_date ).distinct.ids
        when 'not_equal'
          family_ids = families.where('date(initial_referral_date) != ?', @value.to_date ).distinct.ids
        when 'between'
          family_ids = families.where("date(initial_referral_date) BETWEEN ? AND ? ", @value[0].to_date, @value[1].to_date).distinct.ids
        when 'less'
          family_ids = families.where('date(initial_referral_date) < ?', @value.to_date ).distinct.ids
        when 'less_or_equal'
          family_ids = families.where('date(initial_referral_date) <= ?', @value.to_date ).distinct.ids
        when 'greater'
          family_ids = families.where('date(initial_referral_date) > ?', @value.to_date ).distinct.ids
        when 'greater_or_equal'
          family_ids = families.where('date(initial_referral_date) >= ?', @value.to_date ).distinct.ids
        when 'is_empty'
          family_ids = families.where('initial_referral_date IS NULL').distinct.ids
        when 'is_not_empty'
          family_ids = families.where('initial_referral_date IS NOT NULL').distinct.ids
        end

        family_ids.present? ? family_ids : []
      end
  
      def number_family_billable_query
        value = @value.kind_of?(Array) ? @value[0] : @value.to_date
        families = @families.joins(:enter_ngos).includes(:exit_ngos).where('(exit_ngos.exit_date IS NULL OR date(exit_ngos.exit_date) >= ?)', value).distinct
  
        case @operator
        when 'equal'
          family_ids = families.where('date(enter_ngos.accepted_date) = ?', @value.to_date).distinct.ids
        when 'not_equal'
          family_ids = families.where('date(enter_ngos.accepted_date) != ?', @value.to_date).distinct.ids
        when 'between'
          family_ids = families.where("date(enter_ngos.accepted_date) <= ?", @value[1]).distinct.ids
        when 'less'
          family_ids = families.where('date(enter_ngos.accepted_date) < ?', @value.to_date).distinct.ids
        when 'less_or_equal'
          family_ids = families.where('date(enter_ngos.accepted_date) <= ?', @value.to_date).distinct.ids
        when 'greater'
          family_ids = families.where('date(enter_ngos.accepted_date) > ?', @value.to_date).distinct.ids
        when 'greater_or_equal'
          family_ids = families.where('date(enter_ngos.accepted_date) >= ?', @value.to_date).distinct.ids
        when 'is_empty'
          family_ids = families.where('enter_ngos.accepted_date IS NULL').distinct.ids
        when 'is_not_empty'
          family_ids = families.where('enter_ngos.accepted_date IS NOT NULL').distinct.ids
        end

        family_ids.present? ? family_ids : []
      end

      def get_rejected_families
        family_ids = []
        families = @families.joins(:exit_ngos).where(:exit_ngos => {:exit_circumstance => 'Rejected Referral'}).distinct
  
        case @operator
        when 'equal'
          family_ids = families.where('date(exit_ngos.exit_date) = ?', @value.to_date ).distinct.ids
        when 'not_equal'
          family_ids = families.where('date(exit_ngos.exit_date) != ?', @value.to_date ).distinct.ids
        when 'between'
          family_ids = families.where("date(exit_ngos.exit_date) BETWEEN ? AND ?", @value[0], @value[1]).distinct.ids
        when 'less'
          family_ids = families.where('date(exit_ngos.exit_date) < ?', @value.to_date ).distinct.ids
        when 'less_or_equal'
          family_ids = families.where('date(exit_ngos.exit_date) <= ?', @value.to_date ).distinct.ids
        when 'greater'
          family_ids = families.where('date(exit_ngos.exit_date) > ?', @value.to_date ).distinct.ids
        when 'greater_or_equal'
          family_ids = families.where('date(exit_ngos.exit_date) >= ?', @value.to_date ).distinct.ids
        when 'is_empty'
          family_ids = families.where('exit_ngos.exit_date IS NULL').distinct.ids
        when 'is_not_empty'
          family_ids = families.where('exit_ngos.exit_date IS NOT NULL').distinct.ids
        end

        family_ids
      end

      def list_families
        families = @families
        case @operator
        when 'equal'
          families = families.joins(:clients).where('children && ARRAY[?]', @value.to_i)
        when 'not_equal'
          families = families.joins(:clients).where.not('children && ARRAY[?]', @value.to_i)
        when 'is_empty'
          families = families.where(children: '{}')
        when 'is_not_empty'
          families = families.where.not(children: '{}')
        end

        families.ids
      end

      def family_members
        families = @families
        case @operator
        when 'equal'
          families = families.joins(:family_members).where(family_members: { relation: @value })
        when 'not_equal'
          families = Family.includes(:family_members).where("NOT EXISTS (SELECT 1 FROM family_members WHERE family_members.family_id = families.id AND relation = ?)", @value).references(:family_members)
        when 'is_empty'
          families = Family.includes(:family_members).references(:family_members).group(:id).having("COUNT(family_members.*) = 0")
        when 'is_not_empty'
          families = families.joins(:family_members).where.not(family_members: { relation: "" })
        end

        families.ids
      end

      def case_worker_field_query
        family_ids = []
        case @operator
        when 'equal'
          family_ids = @families.joins(:case_worker_families).where(case_worker_families: { user_id: @value }).ids
        when 'not_equal'
          family_ids = Family.includes(:case_worker_families).where.not(case_worker_families: { user_id: @value }).references(:case_worker_families).ids
        when 'is_empty'
          family_ids = Family.includes(:case_worker_families).where.not(id: Family.joins(:case_worker_families).ids).references(:case_worker_families).ids
        when 'is_not_empty'
          family_ids = Family.joins(:case_worker_families).ids
        end
        family_ids
      end

      def get_family_member_gender
        families = @families.joins(:family_members).distinct
        case @operator
        when 'equal'
          families = families.where('family_members.gender = ?', @value)
        when 'not_equal'
          families = families.where('family_members.gender != ?', @value)
        when 'is_empty'
          families = Family.includes(:family_members).where('family_members.gender IS NULL')
        when 'is_not_empty'
          families = families.where('family_members.gender IS NOT NULL')
        end
        families.ids
      end

      def get_family_member_dob
        families = @families.joins(:family_members).distinct
        case @operator
        when 'equal'
          families = families.where('date(family_members.date_of_birth) = ?', @value.to_date)
        when 'not_equal'
          families = families.where("date(family_members.date_of_birth) != ? OR family_members.date_of_birth IS NULL", @value.to_date)
        when 'less'
          families = families.where('date(family_members.date_of_birth) < ?', @value.to_date)
        when 'less_or_equal'
          families = families.where('date(family_members.date_of_birth) <= ?', @value.to_date)
        when 'greater'
          families = families.where('date(family_members.date_of_birth) > ?', @value.to_date)
        when 'greater_or_equal'
          families = families.where('date(family_members.date_of_birth) >= ?', @value.to_date)
        when 'between'
          families = families.where('date(family_members.date_of_birth) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
        when 'is_empty'
          families = Family.includes(:family_members).where(family_members: { date_of_birth: nil })
        when 'is_not_empty'
          families = families.where.not(family_members: { date_of_birth: nil })
        end
        families.ids
      end

      def active_family_between(start_date, end_date)
        enrollments = Enrollment.all
        family_ids = []
        enrollments.each do |enrollment|
          enrollment_date = enrollment.enrollment_date

          if enrollment.leave_program.present?
            exit_date = enrollment.leave_program.exit_date
            if enrollment_date < start_date || enrollment_date.between?(start_date, end_date)
              family_ids << enrollment.programmable_id if exit_date.between?(start_date, end_date) || exit_date > end_date
            end
          else
            family_ids << enrollment.programmable_id if enrollment_date.between?(start_date, end_date) || enrollment_date < start_date
          end
        end
        family_ids
      end

      def get_active_families
        families = @families.joins(:enrollments).where(:enrollments => {:status => 'Active'})

        case @operator
        when 'equal'
          family_ids = families.where('date(enrollments.enrollment_date) = ?', @value.to_date).ids
        when 'not_equal'
          family_ids = families.where('date(enrollments.enrollment_date) != ?', @value.to_date).ids
        when 'less'
          family_ids = families.where('date(enrollments.enrollment_date) < ?', @value.to_date).ids
        when 'less_or_equal'
          family_ids = families.where('date(enrollments.enrollment_date) <= ?', @value.to_date).ids
        when 'greater'
          family_ids = families.where('date(enrollments.enrollment_date) > ?', @value.to_date).ids
        when 'greater_or_equal'
          family_ids = families.where('date(enrollments.enrollment_date) >= ?', @value.to_date).ids
        when 'between'
          family_ids = active_family_between(@value[0].to_date, @value[1].to_date)
        when 'is_empty'
          family_ids = families.where('date(enrollments.enrollment_date) IS NULL').ids
        when 'is_not_empty'
          family_ids = families.where('date(enrollments.enrollment_date) IS NOT NULL').ids
        end

        families = family_ids.present? ? family_ids : []
      end

      def date_of_assessments_query(type)
        families = @families.joins(:assessments).where(assessments: { default: type })
        case @operator
        when 'equal'
          families = families.where('date(assessments.created_at) = ?', @value.to_date)
        when 'not_equal'
          families = families.where("date(assessments.created_at) != ? OR assessments.created_at IS NULL", @value.to_date)
        when 'less'
          families = families.where('date(assessments.created_at) < ?', @value.to_date)
        when 'less_or_equal'
          families = families.where('date(assessments.created_at) <= ?', @value.to_date)
        when 'greater'
          families = families.where('date(assessments.created_at) > ?', @value.to_date)
        when 'greater_or_equal'
          families = families.where('date(assessments.created_at) >= ?', @value.to_date)
        when 'between'
          families = families.where('date(assessments.created_at) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
        when 'is_empty'
          families = Family.includes(:assessments).where(assessments: { created_at: nil })
        when 'is_not_empty'
          families = families.where.not(assessments: { created_at: nil })
        end
        families.ids
      end

      def date_of_completed_assessments_query(type)
        families = @families.joins(:assessments).where(assessments: { completed: true })
        case @operator
        when 'equal'
          families = families.where('date(assessments.completed_date) = ?', @value.to_date)
        when 'not_equal'
          families = families.where('date(assessments.completed_date) != ? OR assessments.completed_date IS NULL', @value.to_date)
        when 'less'
          families = families.where('date(assessments.completed_date) < ?', @value.to_date)
        when 'less_or_equal'
          families = families.where('date(assessments.completed_date) <= ?', @value.to_date)
        when 'greater'
          families = families.where('date(assessments.completed_date) > ?', @value.to_date)
        when 'greater_or_equal'
          families = families.where('date(assessments.completed_date) >= ?', @value.to_date)
        when 'between'
          families = families.where('date(assessments.completed_date) BETWEEN ? AND ? ', @value[0].to_date, @value[1].to_date)
        when 'is_empty'
          families = Family.includes(:assessments).where(assessments: { completed: true, completed_date: nil })
        when 'is_not_empty'
          families = families.where.not(assessments: { completed_date: nil })
        end
        families.ids
      end

      def advanced_case_note_query
        results = []
        @basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        basic_rules   = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
        results       = mapping_allowed_param_value(basic_rules, ['no_case_note_date', 'case_note_date', 'case_note_type'], data_mapping=[])
        query_string  = get_any_query_string(results, 'case_notes')
        sql           = query_string.reject(&:blank?).map{|query| "(#{query})" }.join(" #{basic_rules[:condition]} ")
        families      = Family.joins('LEFT OUTER JOIN case_notes ON case_notes.family_id = families.id')
        families.where(sql).ids
      end

      def case_note_query_results(families, case_note_date_query_array, case_note_type_query_array)
        results = []
        if case_note_date_query_array.first.present? && case_note_type_query_array.first.blank?
          results = families.where(case_note_date_query_array)
        elsif case_note_date_query_array.first.blank? && case_note_type_query_array.first.present?
          results = families.where(case_note_type_query_array)
        else
          results = families.where(case_note_date_query_array).or(families.where(case_note_type_query_array))
        end
        results
      end

      def case_note_basic_rules(basic_rules, field)
        basic_rules.reject{|h| h['id'] != field }.map {|value| [value['id'], value['operator'], value['value']] }
      end

      def active_program_stream_query
        families = @families.joins(:enrollments).where(enrollments: { status: 'Active' })

        basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        return object if basic_rules.nil?
        basic_rules  = basic_rules.is_a?(Hash) ? basic_rules : JSON.parse(basic_rules).with_indifferent_access
        results      = mapping_form_builder_param_value(basic_rules, 'active_program_stream')
        query_string  = get_query_string(results, 'active_program_stream', 'program_streams')

        case @operator
        when 'equal'
          families.where(enrollments: { program_stream_id: @value }).distinct.ids
        when 'not_equal'
          @families.includes(enrollments: :program_stream).where(query_string).references(:program_streams).distinct.ids
        when 'is_empty'
          @families.includes(enrollments: :program_stream).where(query_string).references(:program_streams).distinct.ids
        when 'is_not_empty'
          families.joins(enrollments: :program_stream).distinct.ids
        else
          @families.includes(enrollments: :program_stream).where(program_streams: { id: @value }).references(:program_streams).distinct.ids
        end
      end

      def find_custom_assessment_setting_id(type)
        custom_assessment_setting_id = nil
        if !type && $param_rules['basic_rules'].present?
          custom_assessment_setting_rule = JSON.parse($param_rules['basic_rules'])['rules'].select{|rule| rule['id'] == 'custom_assessment' }.try(:first)
          custom_assessment_setting_id = custom_assessment_setting_rule['value'] if custom_assessment_setting_rule
        end
        custom_assessment_setting_id
      end
    end
  end
end
