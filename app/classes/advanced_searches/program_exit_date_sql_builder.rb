module AdvancedSearches
  class ProgramExitDateSqlBuilder
    def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      @operator = rule['operator']
      @value    = rule['value']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      leave_programs = LeaveProgram.where(program_stream_id: @program_stream_id)

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
        client_ids = ClientEnrollment.where(program_stream_id: @program_stream_id).select("client_id").group(:client_id).having("count(*) = 1 and max(status)= 'Active'")
      when 'is_not_empty'
        leave_program_date = leave_programs.where.not(exit_date: nil)
      when 'between'
        leave_program_date = leave_programs.where('exit_date BETWEEN ? AND ?', @value.first, @value.last)
      end
      client_ids = leave_program_date.joins(:client_enrollment).pluck('client_enrollments.client_id') if leave_program_date.present?
      { id: sql_string, values: client_ids.uniq }
    end
  end
end
