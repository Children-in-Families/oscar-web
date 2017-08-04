module ClientEnrollmentTrackingHelper
  def tracking_report(tracking)
    @program_stream.trackings.find(tracking.tracking_id).fields
  end
end