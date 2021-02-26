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
        when 'active_families'
          values = get_active_families
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

    end
  end
end
