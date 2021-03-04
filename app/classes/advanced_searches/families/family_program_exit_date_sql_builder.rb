module AdvancedSearches
  module Families
    class FamilyProgramExitDateSqlBuilder
      def initialize(program_stream_id, rule)
        @program_stream_id = program_stream_id
        @operator = rule['operator']
        @value    = rule['value']
      end
  
      def get_sql
        sql_string = 'families.id IN (?)'
        leave_programs = LeaveProgram.joins(:enrollment).where(program_stream_id: @program_stream_id).distinct
        family_ids = []
  
        case @operator
        when 'equal'
          leave_program_date = leave_programs.where(exit_date: @value)
        when 'not_equal'
          leave_program_date = leave_programs.where.not(exit_date: @value)
        when 'less'
          leave_program_date = leave_programs.where('exit_date < ?', @value)
        when 'less_or_equal'
          leave_program_date = leave_programs.where('exit_date <= ?', @value)
        when 'greater'
          leave_program_date = leave_programs.where('exit_date > ?', @value)
        when 'greater_or_equal'
          leave_program_date = leave_programs.where('exit_date >= ?', @value)
        when 'is_empty'
          # family_ids = Enrollment.where(program_stream_id: @program_stream_id).select("family_id").group(:family_id).having("count(*) = 1 and max(status)= 'Active'")
          leave_program_date = leave_programs.where.not(exit_date: nil)
          family_ids         = leave_program_date.joins(:enrollment).pluck('enrollments.programmable_id').uniq
          family_ids         = family.where.not(id: family_ids).ids
  
          return { id: sql_string, values: family_ids }
        when 'is_not_empty'
          leave_program_date = leave_programs.where.not(exit_date: nil)
        when 'between'
          leave_program_date = leave_programs.where('exit_date BETWEEN ? AND ?', @value.first, @value.last)
        end
        family_ids = leave_program_date.pluck('enrollments.programmable_id')
  
        { id: sql_string, values: family_ids.uniq }
      end
    end
  end
end
