module GoogleCalendarServiceConcern
  def initiate_service
    client = Signet::OAuth2::Client.new(client_id: Rails.application.secrets.google_client_id,
    client_secret: Rails.application.secrets.google_client_secret,
    token_credential_uri: 'https://accounts.google.com/o/oauth2/token')
    client.update!(session[:authorization])
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client
    service
  end

  def create_events
    service = initiate_service
    calendars = current_user_calendars
    calendars.each do |event_list|
      event = Google::Apis::CalendarV3::Event.new(start: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.start_date.to_date.to_s),
                                                  end: Google::Apis::CalendarV3::EventDateTime.new(date: event_list.end_date.to_date.to_s),
                                                  summary: event_list.title)

      google_event = service.insert_event('primary', event)
      event_list.update(sync_status: true, google_event_id: google_event.id)
    end
  end

  def delete_events
    service = initiate_service
    completed_calendars = current_user.calendars.completed_tasks
    completed_calendars.each do |event|
      service.delete_event('primary', event.google_event_id)
      event.update_column(:google_event_id, nil)
    end
  end

  def current_user_calendars
    current_user.calendars.sync_status_false
  end

end