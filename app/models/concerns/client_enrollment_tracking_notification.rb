module ClientEnrollmentTrackingNotification
  def client_enrollment_tracking_notification(clients)
    clients_due_today = []
    clients_overdue = []
    clients.each do |client|
      client_active_enrollments = client.client_enrollments.active
      client_active_enrollments.each do |client_active_enrollment|
        trackings = client_active_enrollment.trackings
        trackings.each do |tracking|
          if tracking.frequency.present?
            last_client_enrollment_tracking = client_active_enrollment.client_enrollment_trackings.last
            if client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) < Date.today
              clients_overdue << client
            elsif client.next_client_enrollment_tracking_date(tracking, last_client_enrollment_tracking) == Date.today
              clients_due_today << client
            end
          end
        end
      end
    end
    { clients_overdue: clients_overdue.uniq, clients_due_today: clients_due_today.uniq}
  end
end
