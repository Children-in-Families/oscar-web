module AdvancedSearches
  module Families
    class FamilyAssociationFilter
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
        when /assessment_completed|assessment_completed_date/
          values = date_of_completed_assessments_query(nil)
        when 'date_of_custom_assessments'
          values = date_of_assessments_query(false)
        end
        { id: sql_string, values: values }
      end

      private

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

      def case_worker_field_query
        family_ids = []
        case @operator
        when 'equal'
          family_ids = Case.joins(:family).non_emergency.active.where(user_id: @value).pluck(:family_id).uniq
        when 'not_equal'
          family_ids = Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true, user_id: @value }).pluck(:family_id).uniq
        when 'is_empty'
          family_ids = @families.where.not(id: Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:family_id).uniq).ids
        when 'is_not_empty'
          family_ids = @families.where(id: Case.joins(:family).where.not(cases: { case_type: 'EC', exited: true }).pluck(:family_id).uniq).ids
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
        if type.nil?
          families = @families.joins(:assessments).where(assessments: { completed: true })
        else
          families = @families.joins(:assessments).where(assessments: { completed: true, default: type })
        end
        case @operator
        when 'equal'
          families = families.where('date(assessments.created_at) = ?', @value.to_date)
        when 'not_equal'
          families = families.where('date(assessments.created_at) != ? OR assessments.created_at IS NULL', @value.to_date)
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
          families = Family.includes(:assessments).where(assessments: { completed: true, created_at: nil })
        when 'is_not_empty'
          families = families.where.not(assessments: { created_at: nil })
        end
        families.ids
      end

      def date_of_completed_assessments_query(type)
        if type.nil?
          families = @families.joins(:assessments).where(assessments: { completed: true })
        else
          families = @families.joins(:assessments).where(assessments: { completed: true, default: type })
        end
        case @operator
        when 'equal'
          families = families.where('date(assessments.created_at) = ?', @value.to_date)
        when 'not_equal'
          families = families.where('date(assessments.created_at) != ? OR assessments.created_at IS NULL', @value.to_date)
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
          families = Family.includes(:assessments).where(assessments: { completed: true, created_at: nil })
        when 'is_not_empty'
          families = families.where.not(assessments: { created_at: nil })
        end
        families.ids
      end

      def advanced_case_note_query
        results = []
        @basic_rules  = $param_rules.present? && $param_rules[:basic_rules] ? $param_rules[:basic_rules] : $param_rules
        basic_rules   = @basic_rules.is_a?(Hash) ? @basic_rules : JSON.parse(@basic_rules).with_indifferent_access
        results       = mapping_allowed_param_value(basic_rules, ['case_note_date', 'case_note_type'], data_mapping=[])
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
    end
  end
end
