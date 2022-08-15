class GoogleCalendarService
  attr_reader :google_calendar
  def initialize()
    client = Signet::OAuth2::Client.new(
      client_id: Rails.application.secrets.google_client_id,
      client_secret: Rails.application.secrets.google_client_secret,
      token_credential_uri: 'https://accounts.google.com/o/oauth2/token')

    auth = {"access_token"=>"ya29.a0ARrdaM_wycHxA4v4GmPGpm00n6-x51zKZzYjX7SHM6ZrAlwT7Qlj-InYIYVqK_LteeDD6MsA7IyriXmD07ZRd5pG9H1istKE1tap_hPeinI5a7hGLprSBGZQ7ZlNDGqr3vvspv3-4KCP7WyB60v3kEFF6VQ6",
        "expires_in"=>3595,
        "scope"=>"https://www.googleapis.com/auth/calendar",
        "token_type"=>"Bearer"}

    client.update!(auth)
    service = Google::Apis::CalendarV3::CalendarService.new
    service.authorization = client

  end

  def list_task

  end

  def create_task
    google_calendar.create_event do |e|
      e.title = 'A Test Event'
      e.start_time = Time.now
      e.end_time = Time.now + (60 * 60) # seconds * min
    end
  end

  def delete_task(event_id)
    google_calendar.delete_event('primary', event_id) if event_id
  end
end
