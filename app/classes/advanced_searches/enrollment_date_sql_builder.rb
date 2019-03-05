module AdvancedSearches
  class EnrollmentDateSqlBuilder
     def initialize(program_stream_id, rule)
      @program_stream_id = program_stream_id
      @operator = rule['operator']
      @value    = rule['value']
    end

    def get_sql
      sql_string = 'clients.id IN (?)'
      client_enrollments = ClientEnrollment.where(program_stream_id: @program_stream_id)

      case @operator
      when 'equal'
        client_enrollment_date = client_enrollments.where(enrollment_date: @value)
      when 'not_equal'
        client_enrollment_date = client_enrollments.where.not(enrollment_date: @value)
      when 'less'
        client_enrollment_date = client_enrollments.where('enrollment_date < ?', @value)
      when 'less_or_equal'
        client_enrollment_date = client_enrollments.where('enrollment_date <= ?', @value)
      when 'greater'
        client_enrollment_date = client_enrollments.where('enrollment_date > ?', @value)
      when 'greater_or_equal'
        client_enrollment_date = client_enrollments.where('enrollment_date >= ?', @value)
      when 'is_empty'
        client_enrollment_date = ClientEnrollment.where.not(id: client_enrollments.ids)
      when 'is_not_empty'
        client_enrollment_date = client_enrollments
      when 'between'
        client_enrollment_date = client_enrollments.where('enrollment_date BETWEEN ? AND ?', @value.first, @value.last)
      end
      client_ids = client_enrollment_date.pluck(:client_id).uniq
      { id: sql_string, values: client_ids }
    end
  end
end
