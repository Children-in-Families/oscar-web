module AdvancedSearches
  module Families
    class FamilyEnrollmentDateSqlBuilder
      def initialize(program_stream_id, rule)
        @program_stream_id = program_stream_id
        @operator = rule['operator']
        @value    = rule['value']
      end
  
      def get_sql
        sql_string = 'families.id IN (?)'
        family_enrollments = Enrollment.where(program_stream_id: @program_stream_id)
  
        case @operator
        when 'equal'
          family_enrollment_date = family_enrollments.where(enrollment_date: @value)
        when 'not_equal'
          family_enrollment_date = family_enrollments.where.not(enrollment_date: @value)
        when 'less'
          family_enrollment_date = family_enrollments.where('enrollment_date < ?', @value)
        when 'less_or_equal'
          family_enrollment_date = family_enrollments.where('enrollment_date <= ?', @value)
        when 'greater'
          family_enrollment_date = family_enrollments.where('enrollment_date > ?', @value)
        when 'greater_or_equal'
          family_enrollment_date = family_enrollments.where('enrollment_date >= ?', @value)
        when 'is_empty'
          family_enrollment_date = Enrollment.where.not(id: family_enrollments.ids)
        when 'is_not_empty'
          family_enrollment_date = family_enrollments
        when 'between'
          family_enrollment_date = family_enrollments.where('enrollment_date BETWEEN ? AND ?', @value.first, @value.last)
        end
        family_ids = family_enrollment_date.pluck(:programmable_id).uniq
        { id: sql_string, values: family_ids }
      end
    end
  end
end
