module ClientEnrollmentTrackingHelper
  def client_enrollment_tracking_title(client, tracking, program_stream)
    "#{client.given_name} (#{client.try(:local_given_name)}) - #{tracking.name} - #{program_stream.name}"
  end
end