module NextClientEnrollmentTracking
  def next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking)
    (last_client_enrollment_tracking.created_at.to_date) + tracking_frequency(tracking)
  end

  private

  def tracking_frequency(tracking)
    frequency         = tracking.frequency
    time_of_frequency = tracking.time_of_frequency
    case frequency
    when 'Daily'   then time_of_frequency.day
    when 'Weekly'  then time_of_frequency.week
    when 'Monthly' then time_of_frequency.month
    when 'Yearly'  then time_of_frequency.year
    else 0.day
    end
  end
end
