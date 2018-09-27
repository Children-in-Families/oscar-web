class ActiveEnrollmentStatistic
  def initialize(clients)
    @enrollments = ClientEnrollment.joins(:client).where(clients: { id: clients.ids.uniq }).active
  end

  def statistic_data
    enrollment_dates       = @enrollments.order('enrollment_date').map(&:short_enrollment_date).uniq
    enrollments_by_program = @enrollments.order('enrollment_date').group_by(&:program_stream_id).sort
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
      program_name = ProgramStream.find_by(id: program_id).try(:name)
      program_id = ProgramStream.find_by(id: program_id).id
      data_series << { name: "#{program_name}", data: series }
    end
    [enrollment_dates, data_series]
  end
end
