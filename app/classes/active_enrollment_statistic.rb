class ActiveEnrollmentStatistic
  def initialize(clients)
    @enrollments = ClientEnrollment.joins(:client).where(clients: { id: clients.ids.uniq }).active
  end

  def statistic_data
    ordered_enrollments    = @enrollments.order('enrollment_date')
    enrollment_dates       = ordered_enrollments.map(&:short_enrollment_date).uniq
    enrollments_by_program = ordered_enrollments.group_by(&:program_stream_id).reject{|ps| ps.nil? }.sort
    data_series            = []

    enrollments_by_program.each do |program_id, enrollment|
      enrollments_by_date = enrollment.group_by(&:short_enrollment_date)

      series = []
      client_enrollments_count_list = []

      enrollment_dates.each do |date|
        if enrollments_by_date[date].present?
          client_enrollments_count_list << enrollments_by_date[date].size
          series << client_enrollments_count_list.sum
        else
          series << nil
        end
      end

      program = ProgramStream.find_by(id: program_id)

      data_series << { name: "#{program&.name}", data: series }
    end
    [enrollment_dates, data_series]
  end
end
