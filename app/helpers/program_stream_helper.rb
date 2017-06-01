module ProgramStreamHelper
  def status_value(client, program_stream)
    enrollments = enrollments_by(client, program_stream)
    return unless enrollments.present?
    enrollments.last.status
  end

  def status_label(client, program_stream)
    program_status = status_value(client, program_stream)
    return if program_status.nil?
    program_status == 'Active' ? 'label label-primary' : 'label label-danger'
  end

  def enroll?(client, program_stream)
    enrollments = enrollments_by(client, program_stream)
    (enrollments.present? && enrollments.last.status == 'Exited') || enrollments.empty?
  end

  def programs_active(client, program_stream)
    program_stream.client_enrollments.active
  end

  private

  def enrollments_by(client, program_stream)
    ClientEnrollment.enrollments_by(client, program_stream)
  end
end
