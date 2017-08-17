module ClientEnrollmentTrackingHelper
  def tracking_report(tracking)
    @program_stream.trackings.find(tracking.tracking_id).fields
  end

  def client_enrollment_tracking_form_action_path
    if action_name.in?(%(new create))
      client_client_enrolled_program_client_enrolled_program_trackings_path(@client, @enrollment)
    else
      client_client_enrolled_program_client_enrolled_program_tracking_path(@client, @enrollment, @client_enrollment_tracking)
    end
  end
end
