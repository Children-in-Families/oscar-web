module ClientEnrollmentHelper
  def disable_client_enrollment_button(client_enrollment)
    client_enrollment.client_enrollment_trackings.present? || client_enrollment.leave_program.present? ? 'disabled' : ''
  end
end
