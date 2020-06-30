module AdvancedSearches
  module Families
    class FamilyAssociationFilter
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
          values = clients
        when 'case_workers'
          values = case_worker_field_query
        when 'gender'
          values = get_family_member_gender
        when 'date_of_birth'
          values = get_family_member_dob
        end
        { id: sql_string, values: values }
      end

      private

      def clients
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
    end
  end
end
